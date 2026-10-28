#!/usr/bin/env python3
"""Prepare a checked Vicinae stable-release candidate without publishing it."""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
from dataclasses import dataclass
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen


ROOT = Path(__file__).resolve().parents[1]
PACKAGE = Path("gui-apps/vicinae")
UPSTREAM = "vicinaehq/vicinae"
AUTOMATION_BRANCH = "automation/vicinae-stable-update"
VERSION_RE = re.compile(r"^v?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")
EBUILD_RE = re.compile(r"^vicinae-(\d+\.\d+\.\d+)\.ebuild$")
PATCH_REF_RE = re.compile(r'^\s*"\$\{FILESDIR\}/\$\{P\}-(.+)"\s*$')


class PrepareError(Exception):
    pass


@dataclass(frozen=True)
class Release:
    version: str
    tag: str
    commit: str


@dataclass(frozen=True)
class Plan:
    action: str
    release: Release
    current: str
    branch: str = AUTOMATION_BRANCH


def version_tuple(version):
    match = VERSION_RE.fullmatch(version)
    if not match:
        raise PrepareError(f"unsupported stable release tag: {version!r}; expected vX.Y.Z")
    return tuple(int(part) for part in match.groups())


def parse_release(payload, commit_payload):
    tag = payload.get("tag_name", "")
    if not re.fullmatch(r"v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)", tag):
        raise PrepareError(f"unsupported stable release tag: {tag!r}; expected vX.Y.Z")
    parts = version_tuple(tag)
    if payload.get("draft") is True or payload.get("prerelease") is True:
        raise PrepareError(f"latest release {tag} is draft or prerelease; stopping")
    if payload.get("draft") is not False or payload.get("prerelease") is not False:
        raise PrepareError(f"release {tag} is missing explicit stable status fields")
    commit = commit_payload.get("sha", "")
    if not re.fullmatch(r"[0-9a-f]{40}", commit):
        raise PrepareError(f"cannot resolve release tag {tag} to a full commit SHA")
    return Release(".".join(map(str, parts)), tag, commit)


def decide(current_version, release, open_pr_exists):
    if open_pr_exists:
        return Plan("duplicate-pr", release, current_version)
    if version_tuple(release.version) <= version_tuple(current_version):
        return Plan("up-to-date", release, current_version)
    return Plan("candidate", release, current_version)


def publish_candidate(plan, dry_run):
    return plan.action == "candidate" and not dry_run


def request_json(url):
    request = Request(url, headers={"Accept": "application/vnd.github+json", "User-Agent": "vicinae-overlay-updater"})
    try:
        with urlopen(request, timeout=30) as response:
            return json.load(response)
    except (HTTPError, URLError, TimeoutError, json.JSONDecodeError) as error:
        raise PrepareError(f"GitHub read request failed for {url}: {error}") from error


def current_ebuilds(package_dir):
    versions = []
    for path in package_dir.glob("vicinae-*.ebuild"):
        match = EBUILD_RE.fullmatch(path.name)
        if match:
            versions.append((version_tuple(match.group(1)), match.group(1), path))
    if not versions:
        raise PrepareError(f"no versioned Vicinae ebuild found in {package_dir}")
    return sorted(versions)


def rotation_policy(existing_versions, candidate_version):
    """Keep the current package as fallback; remove only older fallback versions."""
    ordered = sorted((version_tuple(version), version) for version in existing_versions)
    if not ordered or version_tuple(candidate_version) <= ordered[-1][0]:
        raise PrepareError("candidate must be newer than the current ebuild")
    return {ordered[-1][1], candidate_version}, {version for _, version in ordered[:-1]}


def fetch_plan(repository, package_dir):
    release_payload = request_json(f"https://api.github.com/repos/{UPSTREAM}/releases/latest")
    tag = release_payload.get("tag_name", "")
    version_tuple(tag)
    commit_payload = request_json(f"https://api.github.com/repos/{UPSTREAM}/commits/{tag}")
    release = parse_release(release_payload, commit_payload)
    current = current_ebuilds(package_dir)[-1][1]
    query = urlencode({"state": "open", "head": f"{repository.split('/', 1)[0]}:{AUTOMATION_BRANCH}", "per_page": 100})
    pulls = request_json(f"https://api.github.com/repos/{repository}/pulls?{query}")
    return decide(current, release, bool(pulls))


def emit_output(path, plan, dry_run):
    if not path:
        return
    candidate = publish_candidate(plan, dry_run)
    with Path(path).open("a", encoding="utf-8") as output:
        output.write(f"candidate={'true' if candidate else 'false'}\n")
        output.write(f"dry_run={'true' if dry_run else 'false'}\n")
        output.write(f"base_sha={os.environ.get('GITHUB_SHA', '')}\n")


def print_plan(plan, dry_run=False):
    print(f"result: {plan.action}")
    print(f"current version: {plan.current}")
    print(f"latest stable release: {plan.release.tag}")
    print(f"resolved commit: {plan.release.commit}")
    if plan.action == "candidate":
        print(f"automation branch: {plan.branch}")
        print("next: validate candidate and open a Draft PR" if not dry_run else "dry-run: no files, branch, commit, or PR will be created")
    elif plan.action == "duplicate-pr":
        print(f"open PR already exists for {plan.branch}; nothing to publish")
    else:
        print("repository is up to date; nothing to publish")


def read_ebuild_patches(ebuild):
    text = ebuild.read_text(encoding="utf-8")
    match = re.search(r"^PATCHES=\(\n(.*?)^\)", text, re.MULTILINE | re.DOTALL)
    if not match:
        raise PrepareError(f"cannot read PATCHES from {ebuild}")
    suffixes = [m.group(1) for line in match.group(1).splitlines() if (m := PATCH_REF_RE.fullmatch(line))]
    if not suffixes or len(suffixes) != len(match.group(1).splitlines()):
        raise PrepareError(f"unsupported or empty PATCHES list in {ebuild}")
    return suffixes


def extract_archive(url, destination):
    request = Request(url, headers={"User-Agent": "vicinae-overlay-updater"})
    try:
        with urlopen(request, timeout=60) as response, tempfile.SpooledTemporaryFile(max_size=16 * 1024 * 1024) as archive:
            shutil.copyfileobj(response, archive)
            archive.seek(0)
            with tarfile.open(fileobj=archive, mode="r:gz") as tar:
                members = tar.getmembers()
                roots = {member.name.split("/", 1)[0] for member in members if "/" in member.name}
                if len(roots) != 1:
                    raise PrepareError("upstream archive has an unexpected directory layout")
                root = next(iter(roots))
                for member in members:
                    if not member.name.startswith(root + "/"):
                        continue
                    relative = Path(member.name[len(root) + 1:])
                    if not relative.parts:
                        continue
                    if relative.is_absolute() or ".." in relative.parts:
                        raise PrepareError(f"unsafe or unsupported upstream archive entry: {member.name}")
                    target = destination / relative
                    if member.isdir():
                        target.mkdir(parents=True, exist_ok=True)
                    elif member.issym():
                        link_target = Path(member.linkname)
                        resolved_target = (target.parent / link_target).resolve()
                        if link_target.is_absolute() or not resolved_target.is_relative_to(destination.resolve()):
                            raise PrepareError(f"unsafe upstream symlink: {member.name}")
                        target.parent.mkdir(parents=True, exist_ok=True)
                        target.symlink_to(member.linkname)
                    else:
                        if not member.isfile():
                            raise PrepareError(f"unsupported upstream archive entry: {member.name}")
                        target.parent.mkdir(parents=True, exist_ok=True)
                        source = tar.extractfile(member)
                        if source is None:
                            raise PrepareError(f"cannot read upstream archive entry: {member.name}")
                        with source, target.open("wb") as output:
                            shutil.copyfileobj(source, output)
    except (HTTPError, URLError, TimeoutError, tarfile.TarError, OSError) as error:
        raise PrepareError(f"cannot retrieve or unpack upstream source archive: {error}") from error


def cmake_signatures(source):
    signatures = {"dependencies": set(), "fetched": set(), "options": set(), "install": set(), "build": set()}
    relevant_option = re.compile(r"USE_SYSTEM_|WAYLAND_LAYER_SHELL|TYPESCRIPT_EXTENSIONS|VICINAE_NODE_RUNTIME|INSTALL_NODE_MODULES|AUTO_ENABLE_AUTOSTART")
    for path in sorted(source.rglob("CMakeLists.txt")) + sorted(source.rglob("*.cmake")):
        relpath = path.relative_to(source).as_posix()
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
        index = 0
        while index < len(lines):
            line = lines[index]
            match = re.search(r"\b(find_package|pkg_check_modules|find_library|find_program|target_link_libraries|FetchContent_Declare|FetchContent_MakeAvailable|ExternalProject_Add|option|set|install|cmake_minimum_required|project)\s*\(", line, re.I)
            if not match:
                index += 1
                continue
            call = [line.strip()]
            depth = line.count("(") - line.count(")")
            while depth > 0 and index + 1 < len(lines):
                index += 1
                call.append(lines[index].strip())
                depth += lines[index].count("(") - lines[index].count(")")
            normalized = re.sub(r"\s+", " ", " ".join(call))
            function = match.group(1).lower()
            if "catch2" in normalized.lower():
                index += 1
                continue
            if function in {"find_package", "pkg_check_modules", "find_library", "find_program", "target_link_libraries"}:
                signatures["dependencies"].add(f"{relpath}:{normalized}")
            elif function in {"fetchcontent_declare", "fetchcontent_makeavailable", "externalproject_add"}:
                signatures["fetched"].add(f"{relpath}:{normalized}")
            elif function == "install":
                signatures["install"].add(f"{relpath}:{normalized}")
            elif function in {"cmake_minimum_required", "project"}:
                if relpath == "CMakeLists.txt":
                    signatures["build"].add(f"{relpath}:{normalized}")
            elif relevant_option.search(normalized):
                signatures["options"].add(f"{relpath}:{normalized}")
            index += 1
    return {key: tuple(sorted(value)) for key, value in signatures.items()}


def npm_method_signature(source):
    signatures = {}
    for relative in ("src/typescript/api/package.json", "src/typescript/extension-manager/package.json"):
        try:
            data = json.loads((source / relative).read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            raise PrepareError(f"stop condition: cannot read npm preparation input {relative}: {error}") from error
        scripts = data.get("scripts", {})
        signatures[relative] = {
            "packageManager": data.get("packageManager"),
            "workspaces": data.get("workspaces"),
            "lifecycle": {name: scripts.get(name) for name in ("preinstall", "install", "postinstall", "prepare")},
        }
    return signatures


def license_files(source):
    files = []
    for path in source.rglob("*"):
        if path.is_file() and path.name.lower() in {"license", "license.md", "license.txt", "copying", "copying.md", "copying.txt"}:
            files.append((path.relative_to(source).as_posix(), path.read_bytes()))
    return tuple(sorted(files))


def validate_packaging_stability(old_source, new_source):
    if not (old_source / "CMakeLists.txt").is_file() or not (new_source / "CMakeLists.txt").is_file():
        raise PrepareError("stop condition: upstream CMake build entry point changed")
    old = cmake_signatures(old_source)
    new = cmake_signatures(new_source)
    labels = {
        "dependencies": "system dependency declarations changed (find_package/pkg_check_modules)",
        "fetched": "upstream pinned or fetched dependency declarations changed (including numen)",
        "options": "CMake packaging or USE mapping options changed",
        "install": "CMake install layout or packaging declarations changed",
        "build": "CMake build requirements or project declaration changed",
    }
    for kind, message in labels.items():
        if old[kind] != new[kind]:
            raise PrepareError(f"stop condition: {message}; manual packaging review is required")
    if license_files(old_source) != license_files(new_source):
        raise PrepareError("stop condition: upstream license files changed; manual license review is required")
    if npm_method_signature(old_source) != npm_method_signature(new_source):
        raise PrepareError("stop condition: npm install method or lifecycle requirements changed")
    for relative in ("src/typescript/api/package-lock.json", "src/typescript/extension-manager/package-lock.json"):
        if not (new_source / relative).is_file():
            raise PrepareError(f"stop condition: npm preparation inputs changed; missing {relative}")


def apply_patches(source, package_dir, ebuild):
    for suffix in read_ebuild_patches(ebuild):
        patch = package_dir / "files" / f"{ebuild.stem}-{suffix}"
        if not patch.is_file():
            raise PrepareError(f"ebuild patch file is missing: {patch}")
        result = subprocess.run(
            ["patch", "--batch", "--fuzz=0", "-p1", "-d", str(source)],
            input=patch.read_bytes(),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=False,
        )
        if result.returncode:
            raise PrepareError(
                f"stop condition: patch {patch.name} does not apply cleanly to candidate sources\n"
                + result.stdout.decode(errors="replace")
            )


def run_checked(command, cwd):
    try:
        result = subprocess.run(command, cwd=cwd, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    except OSError as error:
        raise PrepareError(f"required command is unavailable ({command[0]}): {error}") from error
    if result.returncode:
        raise PrepareError(f"command failed ({' '.join(map(str, command))}):\n{result.stdout}")
    return result.stdout


def prepare_candidate(plan, root, artifact_dir):
    package_dir = root / PACKAGE
    ebuilds = current_ebuilds(package_dir)
    _, old_version, old_ebuild = ebuilds[-1]
    new_version = plan.release.version
    new_ebuild = package_dir / f"vicinae-{new_version}.ebuild"
    if new_ebuild.exists():
        raise PrepareError(f"candidate ebuild already exists unexpectedly: {new_ebuild}")
    suffixes = read_ebuild_patches(old_ebuild)
    with tempfile.TemporaryDirectory(prefix="vicinae-update-") as temporary:
        tmp = Path(temporary)
        old_source = tmp / "current"
        candidate_source = tmp / "candidate"
        old_source.mkdir()
        candidate_source.mkdir()
        extract_archive(f"https://github.com/{UPSTREAM}/archive/refs/tags/v{old_version}.tar.gz", old_source)
        extract_archive(f"https://github.com/{UPSTREAM}/archive/{plan.release.commit}.tar.gz", candidate_source)
        validate_packaging_stability(old_source, candidate_source)
        for suffix in suffixes:
            shutil.copy2(package_dir / "files" / f"{old_ebuild.stem}-{suffix}", package_dir / "files" / f"vicinae-{new_version}-{suffix}")
        text = old_ebuild.read_text(encoding="utf-8")
        text, count = re.subn(
            r'(-DVICINAE_GIT_COMMIT_HASH=")[0-9a-f]{40}("$)',
            rf"\g<1>{plan.release.commit}\2",
            text,
            count=1,
            flags=re.MULTILINE,
        )
        if count != 1:
            raise PrepareError("cannot update exactly one upstream commit SHA in the ebuild")
        new_ebuild.write_text(text, encoding="utf-8")
        apply_patches(candidate_source, package_dir, new_ebuild)
        run_checked(
            [sys.executable, str(root / "scripts/check-npm-distfiles.py"), "--source-dir", str(candidate_source), "--ebuild", str(new_ebuild), "--generate"],
            root,
        )

        # Retain the current ebuild as the only fallback and its referenced patches.
        _, remove_versions = rotation_policy([version for _, version, _ in ebuilds], new_version)
        for _, version, path in ebuilds:
            if version not in remove_versions:
                continue
            path.unlink()
            for old_patch in (package_dir / "files").glob(f"{path.stem}-*.patch"):
                old_patch.unlink()

        # Remove only patch files no longer referenced by any remaining ebuild.
        referenced = set()
        for path in package_dir.glob("vicinae-*.ebuild"):
            referenced.update(f"{path.stem}-{suffix}" for suffix in read_ebuild_patches(path))
        for path in (package_dir / "files").glob("vicinae-*.patch"):
            if path.stem not in referenced:
                path.unlink()

        # Portage's package tooling computes the Manifest from the actual SRC_URI.
        run_checked(["pkgdev", "manifest", "--force", str(package_dir)], root)
        for version in (old_version, new_version):
            ebuild = package_dir / f"vicinae-{version}.ebuild"
            source = old_source if version == old_version else candidate_source
            run_checked(
                [sys.executable, str(root / "scripts/check-npm-distfiles.py"), "--source-dir", str(source), "--ebuild", str(ebuild)],
                root,
            )

    # Only package sources needed by the candidate may cross into the publisher job.
    package_relative = root / PACKAGE
    allowed = {PACKAGE / "Manifest"}
    allowed.update(path.relative_to(root) for path in package_relative.glob("vicinae-*.ebuild"))
    allowed.update(path.relative_to(root) for path in (package_relative / "files").glob("vicinae-*.patch"))
    for path in allowed:
        if path.is_symlink() or not path.is_file():
            raise PrepareError(f"unsafe or unexpected candidate file: {path}")
    artifact_dir.mkdir(parents=True, exist_ok=True)
    for relative in sorted(allowed):
        target = artifact_dir / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(root / relative, target)

    # Validate the complete generated diff before any artifact can be published.
    changed = set(run_checked(["git", "diff", "--name-only"], root).splitlines())
    untracked = set(run_checked(["git", "ls-files", "--others", "--exclude-standard"], root).splitlines())
    validate_publish_paths(changed | untracked)
    run_checked(["git", "diff", "--check"], root)


def check_source(ebuild, source):
    package_dir = ebuild.resolve().parent
    apply_patches(source.resolve(), package_dir, ebuild.resolve())
    print(f"patches apply without fuzz for {ebuild.name}")


def validate_publish_paths(paths):
    allowed_patterns = (
        re.compile(r"^gui-apps/vicinae/vicinae-\d+\.\d+\.\d+\.ebuild$"),
        re.compile(r"^gui-apps/vicinae/files/vicinae-\d+\.\d+\.\d+-.+\.patch$"),
        re.compile(r"^gui-apps/vicinae/Manifest$"),
    )
    unexpected = sorted(path for path in paths if not any(pattern.fullmatch(path) for pattern in allowed_patterns))
    if unexpected:
        raise PrepareError(f"generated diff includes paths outside the package allowlist: {unexpected}")


def validate_artifact(artifact_dir, base_package_dir):
    artifact_dir = artifact_dir.resolve()
    paths = set()
    for path in artifact_dir.rglob("*"):
        if path.is_symlink():
            raise PrepareError(f"candidate artifact contains a symlink: {path.relative_to(artifact_dir)}")
        if path.is_file():
            paths.add(path.relative_to(artifact_dir).as_posix())
    validate_publish_paths(paths)
    package = artifact_dir / PACKAGE
    ebuilds = sorted(package.glob("vicinae-*.ebuild"))
    if len(ebuilds) != 2 or not (package / "Manifest").is_file():
        raise PrepareError("candidate artifact must contain exactly the new and fallback ebuilds plus Manifest")
    baseline_ebuilds = current_ebuilds(base_package_dir)
    baseline_version, baseline_ebuild = baseline_ebuilds[-1][1:]
    artifact_versions = current_ebuilds(package)
    fallback = next((path for _, version, path in artifact_versions if version == baseline_version), None)
    if fallback is None or fallback.read_bytes() != baseline_ebuild.read_bytes():
        raise PrepareError("candidate artifact does not preserve the current ebuild unchanged as fallback")
    candidate = artifact_versions[-1][2]
    if artifact_versions[-1][1] == baseline_version:
        raise PrepareError("candidate artifact version is not newer than the checked base")
    baseline_suffixes = read_ebuild_patches(baseline_ebuild)
    if read_ebuild_patches(candidate) != baseline_suffixes:
        raise PrepareError("candidate PATCHES differ from the checked base; manual patch review is required")
    for suffix in baseline_suffixes:
        old_patch = base_package_dir / "files" / f"{baseline_ebuild.stem}-{suffix}"
        if not old_patch.is_file():
            raise PrepareError(f"checked base patch is missing: {old_patch.name}")
        for ebuild in (fallback, candidate):
            patch = package / "files" / f"{ebuild.stem}-{suffix}"
            if not patch.is_file() or patch.read_bytes() != old_patch.read_bytes():
                raise PrepareError(f"artifact patch {patch.name} differs from the checked base patch")
    expected = {f"{PACKAGE}/Manifest"}
    for ebuild in ebuilds:
        expected.add(f"{PACKAGE}/{ebuild.name}")
        for suffix in read_ebuild_patches(ebuild):
            expected.add(f"{PACKAGE}/files/{ebuild.stem}-{suffix}")
    if paths != expected:
        raise PrepareError(f"candidate artifact does not match ebuild PATCHES; extra={sorted(paths-expected)}, missing={sorted(expected-paths)}")


def validate_staged_paths(root):
    paths = set(run_checked(["git", "diff", "--cached", "--name-only"], root).splitlines())
    validate_publish_paths(paths)
    run_checked(["git", "diff", "--cached", "--check"], root)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repository", default=os.environ.get("GITHUB_REPOSITORY"), help="overlay owner/name")
    parser.add_argument("--repo-dir", type=Path, default=ROOT)
    parser.add_argument("--artifact-dir", type=Path, help="allowlisted output directory for the publisher job")
    parser.add_argument("--output", help="GitHub Actions output file")
    parser.add_argument("--dry-run", action="store_true", help="show the plan without preparing or publishing files")
    parser.add_argument("--check-source", action="store_true", help="check the ebuild's actual PATCHES against --source-dir")
    parser.add_argument("--ebuild", type=Path, help="ebuild used with --check-source")
    parser.add_argument("--source-dir", type=Path, help="extracted upstream source tree")
    parser.add_argument("--check-artifact", type=Path, help="validate an artifact before applying it in the publisher job")
    parser.add_argument("--validate-staged", action="store_true", help="validate staged paths in the publisher job")
    args = parser.parse_args()
    root = args.repo_dir.resolve()

    try:
        if args.check_source:
            if not args.ebuild or not args.source_dir:
                raise PrepareError("--check-source requires both --ebuild and --source-dir")
            check_source(args.ebuild, args.source_dir)
            return 0
        if args.check_artifact:
            validate_artifact(args.check_artifact, root / PACKAGE)
            print("candidate artifact contains only allowlisted ebuild, patch, and Manifest files")
            return 0
        if args.validate_staged:
            validate_staged_paths(root)
            print("staged paths and diff check are valid")
            return 0
        if not args.repository or "/" not in args.repository:
            raise PrepareError("--repository owner/name is required")
        plan = fetch_plan(args.repository, root / PACKAGE)
        print_plan(plan, args.dry_run)
        emit_output(args.output, plan, args.dry_run)
        if plan.action != "candidate" or args.dry_run:
            return 0
        if not args.artifact_dir:
            raise PrepareError("--artifact-dir is required when preparing a candidate")
        prepare_candidate(plan, root, args.artifact_dir.resolve())
        return 0
    except PrepareError as error:
        print(f"stable release preparation stopped: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
