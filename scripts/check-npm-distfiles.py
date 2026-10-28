#!/usr/bin/env python3
"""Check or regenerate the optional npm distfile blocks for Vicinae."""

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from urllib.parse import urlsplit


ROOT = Path(__file__).resolve().parents[1]
PACKAGE_DIR = ROOT / "gui-apps/vicinae"
LOCKFILES = (
    Path("src/typescript/api/package-lock.json"),
    Path("src/typescript/extension-manager/package-lock.json"),
)


class CheckError(Exception):
    pass


def values(value):
    if value is None:
        return ()
    if isinstance(value, str):
        return (value,)
    if isinstance(value, list) and all(isinstance(item, str) for item in value):
        return tuple(value)
    raise CheckError(f"invalid os/cpu constraint: {value!r}")


def supports_platform(constraints, target):
    positive = [item for item in constraints if not item.startswith("!")]
    negative = [item[1:] for item in constraints if item.startswith("!")]
    return (not positive or target in positive) and target not in negative


def summarize(items):
    items = sorted(items)
    shown = items[:5]
    suffix = f", … ({len(items)} total)" if len(items) > len(shown) else ""
    return f"{shown}{suffix}"


def npm_packages(source_root):
    packages = {}
    for relative in LOCKFILES:
        path = source_root / relative
        if not path.is_file():
            raise CheckError(f"missing lockfile: {path}")
        try:
            lock = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            raise CheckError(f"cannot read {path}: {error}") from error
        entries = lock.get("packages")
        if lock.get("lockfileVersion") != 3 or not isinstance(entries, dict):
            raise CheckError(f"unsupported lockfile format: {path}")

        for package, entry in entries.items():
            if not isinstance(entry, dict):
                raise CheckError(f"invalid package entry {package!r} in {path}")
            if entry.get("link"):
                continue
            if not supports_platform(values(entry.get("os")), "linux"):
                continue
            if not supports_platform(values(entry.get("cpu")), "x64"):
                continue
            url = entry.get("resolved")
            if not url:
                continue
            if not isinstance(url, str) or urlsplit(url).scheme not in ("http", "https"):
                raise CheckError(f"unsupported resolved URL for {package!r} in {path}: {url!r}")
            packages[url] = urlsplit(url).path.rsplit("/", 1)[-1]
    return packages


def read_ebuild():
    candidates = sorted(PACKAGE_DIR.glob("vicinae-*.ebuild"))
    if len(candidates) != 1:
        raise CheckError(f"expected one vicinae ebuild, found {len(candidates)}")
    path = candidates[0]
    return path, path.read_text(encoding="utf-8"), path.name.removesuffix(".ebuild")


def npm_blocks(packages):
    distfiles = []
    src_uri = []
    for url in sorted(packages):
        digest = hashlib.sha256(url.encode("utf-8")).hexdigest()[:20]
        filename = f"${{P}}-npm-{digest}.tgz"
        distfiles.append(f"\t{filename}")
        if url.startswith("https://registry.npmjs.org/"):
            url = "${NPM_REGISTRY_URI}" + url.removeprefix("https://registry.npmjs.org")
        src_uri.extend((f"\t{url}", f"\t\t-> {filename}"))
    return "\n".join(distfiles), "\n".join(src_uri)


def expected_from_ebuild(text, package_name):
    def block(name):
        match = re.search(rf"^{name}=\"\n(.*?)\n\"$", text, re.MULTILINE | re.DOTALL)
        if not match:
            raise CheckError(f"could not find {name} block in ebuild")
        return match.group(1)

    distfiles = {
        line.strip().replace("${P}", package_name)
        for line in block("NPM_DISTFILES").splitlines()
        if line.strip()
    }
    src_uri = {}
    lines = block("NPM_SRC_URI").splitlines()
    index = 0
    while index < len(lines):
        line = lines[index]
        url = line.strip()
        if not url:
            index += 1
            continue
        if index + 1 >= len(lines):
            raise CheckError(f"missing rename target after npm URL {url}")
        target = re.fullmatch(r"\s*->\s*([^\s]+\.tgz)\s*", lines[index + 1])
        if not target:
            raise CheckError(f"invalid rename target after npm URL {url}")
        url = url.replace("${NPM_REGISTRY_URI}", "https://registry.npmjs.org")
        if url in src_uri:
            raise CheckError(f"duplicate npm URL in ebuild: {url}")
        src_uri[url] = target.group(1).replace("${P}", package_name)
        index += 2
    return distfiles, src_uri


def check_manifest(expected_names, package_name):
    manifest = PACKAGE_DIR / "Manifest"
    if not manifest.is_file():
        raise CheckError(f"missing Manifest: {manifest}")
    manifest_names = set()
    for line in manifest.read_text(encoding="utf-8").splitlines():
        fields = line.split()
        if len(fields) >= 2 and fields[0] == "DIST" and fields[1].startswith(f"{package_name}-npm-"):
            manifest_names.add(fields[1])
    if manifest_names != expected_names:
        missing = sorted(expected_names - manifest_names)
        extra = sorted(manifest_names - expected_names)
        raise CheckError(
            "Manifest npm distfiles differ; "
            f"missing={summarize(missing)}, extra={summarize(extra)}"
        )


def replace_block(text, name, content):
    pattern = rf"^{name}=\"\n.*?\n\"$"
    replacement = f'{name}="\n{content}\n"'
    updated, count = re.subn(pattern, lambda _: replacement, text, count=1, flags=re.MULTILINE | re.DOTALL)
    if count != 1:
        raise CheckError(f"could not replace {name} block in ebuild")
    return updated


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-dir", type=Path, default=Path.cwd(), help="extracted Vicinae source tree")
    parser.add_argument("--generate", action="store_true", help="rewrite the existing npm blocks in the ebuild")
    args = parser.parse_args()

    try:
        packages = npm_packages(args.source_dir.resolve())
        ebuild_path, ebuild_text, package_name = read_ebuild()
        expected_block, expected_uri_block = npm_blocks(packages)
        expected_names = {
            line.strip().replace("${P}", package_name)
            for line in expected_block.splitlines()
        }

        if args.generate:
            updated = replace_block(ebuild_text, "NPM_DISTFILES", expected_block)
            updated = replace_block(updated, "NPM_SRC_URI", expected_uri_block)
            ebuild_path.write_text(updated, encoding="utf-8")
            print(f"generated {len(packages)} npm distfile entries in {ebuild_path}")
            return 0

        actual_names, actual_uris = expected_from_ebuild(ebuild_text, package_name)
        expected_uris = {
            url: f"{package_name}-npm-{hashlib.sha256(url.encode('utf-8')).hexdigest()[:20]}.tgz"
            for url in packages
        }
        if actual_names != expected_names:
            raise CheckError(
                "NPM_DISTFILES differ; "
                f"missing={summarize(expected_names-actual_names)}, "
                f"extra={summarize(actual_names-expected_names)}"
            )
        if actual_uris != expected_uris:
            missing = {f"{url} -> {name}" for url, name in set(expected_uris.items()) - set(actual_uris.items())}
            extra = {f"{url} -> {name}" for url, name in set(actual_uris.items()) - set(expected_uris.items())}
            raise CheckError(
                "NPM_SRC_URI differs; "
                f"missing={summarize(missing)}, extra={summarize(extra)}"
            )
        check_manifest(expected_names, package_name)
        print(f"npm lockfiles, ebuild URLs/distfiles, and Manifest agree ({len(packages)} Linux amd64 distfiles)")
    except CheckError as error:
        print(f"npm distfile check failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
