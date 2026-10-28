import tempfile
import unittest
from pathlib import Path

from scripts.prepare_stable_release import (
    Plan,
    PrepareError,
    Release,
    apply_patches,
    apply_artifact,
    decide,
    parse_release,
    publish_candidate,
    remove_unused_patches,
    rotation_policy,
    validate_artifact,
    validate_packaging_stability,
    validate_publish_paths,
)


class ReleasePlanTests(unittest.TestCase):
    def setUp(self):
        self.release = Release("0.30.0", "v0.30.0", "a" * 40)

    def test_up_to_date_does_not_prepare(self):
        self.assertEqual(decide("0.30.0", self.release, False).action, "up-to-date")

    def test_existing_open_pr_suppresses_duplicate(self):
        self.assertEqual(decide("0.29.2", self.release, True).action, "duplicate-pr")

    def test_new_version_produces_only_a_plan(self):
        plan = decide("0.29.2", self.release, False)
        self.assertEqual(plan, Plan("candidate", self.release, "0.29.2"))
        self.assertFalse(publish_candidate(plan, True))
        self.assertTrue(publish_candidate(plan, False))

    def test_release_requires_stable_semver_and_full_commit(self):
        with self.assertRaisesRegex(PrepareError, "stable release tag"):
            parse_release({"tag_name": "v0.30.0-rc1", "draft": False, "prerelease": False}, {"sha": "a" * 40})
        with self.assertRaisesRegex(PrepareError, "stable release tag"):
            parse_release({"tag_name": "0.30.0", "draft": False, "prerelease": False}, {"sha": "a" * 40})
        with self.assertRaisesRegex(PrepareError, "full commit SHA"):
            parse_release({"tag_name": "v0.30.0", "draft": False, "prerelease": False}, {"sha": "short"})


class RotationAndGuardTests(unittest.TestCase):
    def test_first_rotation_keeps_existing_ebuild_as_fallback(self):
        keep, remove = rotation_policy(["0.29.2"], "0.30.0")
        self.assertEqual(keep, {"0.29.2", "0.30.0"})
        self.assertEqual(remove, set())

    def test_later_rotation_removes_only_previous_fallback(self):
        keep, remove = rotation_policy(["0.29.2", "0.30.0"], "0.31.0")
        self.assertEqual(keep, {"0.30.0", "0.31.0"})
        self.assertEqual(remove, {"0.29.2"})

    def test_publish_allowlist_rejects_scripts_and_workflows(self):
        validate_publish_paths({"gui-apps/vicinae/Manifest", "gui-apps/vicinae/vicinae-0.30.0.ebuild"})
        for path in ("scripts/prepare_stable_release.py", ".github/workflows/ci.yml", "README.md"):
            with self.subTest(path=path), self.assertRaisesRegex(PrepareError, "outside the package allowlist"):
                validate_publish_paths({path})

    def test_artifact_preserves_fallback_and_reuses_patches(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            base = root / "base/gui-apps/vicinae"
            package = root / "artifact/gui-apps/vicinae"
            (base / "files").mkdir(parents=True)
            (package / "files").mkdir(parents=True)
            content = 'PATCHES=(\n "${FILESDIR}/${P}-wayland-only.patch"\n)\n'
            current = base / "vicinae-0.29.2.ebuild"
            current.write_text(content, encoding="utf-8")
            fallback = package / current.name
            fallback.write_text(content, encoding="utf-8")
            candidate = package / "vicinae-0.30.0.ebuild"
            candidate.write_text(content, encoding="utf-8")
            for directory, version in ((base / "files", "0.29.2"), (package / "files", "0.29.2"), (package / "files", "0.30.0")):
                (directory / f"vicinae-{version}-wayland-only.patch").write_text("patch\n", encoding="utf-8")
            (package / "Manifest").write_text("", encoding="utf-8")
            validate_artifact(root / "artifact", base)
            fallback.write_text(content + "# changed\n", encoding="utf-8")
            with self.assertRaisesRegex(PrepareError, "preserve the current ebuild unchanged"):
                validate_artifact(root / "artifact", base)

    def test_patch_cleanup_keeps_referenced_patch_filenames(self):
        with tempfile.TemporaryDirectory() as temporary:
            package = Path(temporary) / "gui-apps/vicinae"
            files = package / "files"
            files.mkdir(parents=True)
            for version in ("0.29.2", "0.30.0"):
                (package / f"vicinae-{version}.ebuild").write_text(
                    'PATCHES=(\n "${FILESDIR}/${P}-wayland-only.patch"\n'
                    ' "${FILESDIR}/${P}-destdir-install.patch"\n)\n',
                    encoding="utf-8",
                )
                for name in ("wayland-only", "destdir-install"):
                    (files / f"vicinae-{version}-{name}.patch").write_text("patch\n", encoding="utf-8")
            unused = files / "vicinae-0.28.0-unused.patch"
            unused.write_text("unused\n", encoding="utf-8")
            remove_unused_patches(package)
            self.assertTrue((files / "vicinae-0.29.2-wayland-only.patch").exists())
            self.assertTrue((files / "vicinae-0.29.2-destdir-install.patch").exists())
            self.assertTrue((files / "vicinae-0.30.0-wayland-only.patch").exists())
            self.assertTrue((files / "vicinae-0.30.0-destdir-install.patch").exists())
            self.assertFalse(unused.exists())

    def test_artifact_application_removes_obsolete_fallback_and_patches(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            package = root / "checkout/gui-apps/vicinae"
            artifact_package = root / "artifact/gui-apps/vicinae"
            (package / "files").mkdir(parents=True)
            (artifact_package / "files").mkdir(parents=True)
            content = (
                'PATCHES=(\n "${FILESDIR}/${P}-wayland-only.patch"\n'
                ' "${FILESDIR}/${P}-destdir-install.patch"\n)\n'
            )
            for version in ("0.29.2", "0.30.0"):
                (package / f"vicinae-{version}.ebuild").write_text(content, encoding="utf-8")
                for name in ("wayland-only", "destdir-install"):
                    (package / "files" / f"vicinae-{version}-{name}.patch").write_text("patch\n", encoding="utf-8")
            unrelated = package / "files/vicinae-local.patch"
            unrelated.write_text("local\n", encoding="utf-8")
            (package / "Manifest").write_text("base\n", encoding="utf-8")
            for version in ("0.30.0", "0.31.0"):
                (artifact_package / f"vicinae-{version}.ebuild").write_text(content, encoding="utf-8")
                for name in ("wayland-only", "destdir-install"):
                    (artifact_package / "files" / f"vicinae-{version}-{name}.patch").write_text("patch\n", encoding="utf-8")
            (artifact_package / "Manifest").write_text("candidate\n", encoding="utf-8")

            apply_artifact(root / "artifact", package)

            self.assertFalse((package / "vicinae-0.29.2.ebuild").exists())
            self.assertTrue((package / "vicinae-0.30.0.ebuild").exists())
            self.assertTrue((package / "vicinae-0.31.0.ebuild").exists())
            self.assertEqual(len(list(package.glob("vicinae-*.ebuild"))), 2)
            self.assertFalse((package / "files/vicinae-0.29.2-wayland-only.patch").exists())
            self.assertEqual(len(list((package / "files").glob("vicinae-*.patch"))), 5)
            self.assertTrue(unrelated.exists())

    def test_incompatible_patch_stops_without_fuzz(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "source"
            package = root / "gui-apps/vicinae"
            (source / "src").mkdir(parents=True)
            (package / "files").mkdir(parents=True)
            (source / "src/file.txt").write_text("candidate content\n", encoding="utf-8")
            ebuild = package / "vicinae-0.30.0.ebuild"
            ebuild.write_text('PATCHES=(\n "${FILESDIR}/${P}-change.patch"\n)\n', encoding="utf-8")
            (package / "files/vicinae-0.30.0-change.patch").write_text(
                "--- a/src/file.txt\n+++ b/src/file.txt\n@@ -1 +1 @@\n-old content\n+patched\n",
                encoding="utf-8",
            )
            with self.assertRaisesRegex(PrepareError, "does not apply cleanly"):
                apply_patches(source, package, ebuild)

    def test_changed_pinned_dependency_stops_preparation(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            old = root / "old"
            new = root / "new"
            for source, version in ((old, "0.8.1"), (new, "0.9.0")):
                source.mkdir(parents=True)
                (source / "CMakeLists.txt").write_text(
                    "cmake_minimum_required(VERSION 3.16)\nproject(vicinae VERSION 1.0.0 LANGUAGES C CXX)\n",
                    encoding="utf-8",
                )
                (source / "src/server").mkdir(parents=True)
                (source / "src/server/CMakeLists.txt").write_text(
                    f"FetchContent_Declare(numen GIT_TAG v{version})\n", encoding="utf-8"
                )
                (source / "src/typescript/api").mkdir(parents=True)
                (source / "src/typescript/extension-manager").mkdir(parents=True)
                (source / "src/typescript/api/package-lock.json").write_text("{}", encoding="utf-8")
                (source / "src/typescript/extension-manager/package-lock.json").write_text("{}", encoding="utf-8")
                for package in ("api", "extension-manager"):
                    (source / f"src/typescript/{package}/package.json").write_text(
                        '{"scripts":{"install":"node install.js"}}', encoding="utf-8"
                    )
            with self.assertRaisesRegex(PrepareError, "pinned or fetched dependency declarations changed"):
                validate_packaging_stability(old, new)

    def test_changed_npm_lifecycle_stops_preparation(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            old = root / "old"
            new = root / "new"
            for source in (old, new):
                source.mkdir(parents=True)
                (source / "CMakeLists.txt").write_text(
                    "cmake_minimum_required(VERSION 3.16)\nproject(vicinae VERSION 1.0.0 LANGUAGES C CXX)\n",
                    encoding="utf-8",
                )
                (source / "src/typescript/api").mkdir(parents=True)
                (source / "src/typescript/extension-manager").mkdir(parents=True)
                (source / "src/typescript/api/package-lock.json").write_text("{}", encoding="utf-8")
                (source / "src/typescript/extension-manager/package-lock.json").write_text("{}", encoding="utf-8")
                (source / "src/server").mkdir(parents=True)
                (source / "src/server/CMakeLists.txt").write_text("", encoding="utf-8")
            for package in ("api", "extension-manager"):
                (old / f"src/typescript/{package}/package.json").write_text('{"scripts":{}}', encoding="utf-8")
                (new / f"src/typescript/{package}/package.json").write_text(
                    '{"scripts":{"prepare":"node prepare.js"}}', encoding="utf-8"
                )
            with self.assertRaisesRegex(PrepareError, "npm install method or lifecycle"):
                validate_packaging_stability(old, new)


if __name__ == "__main__":
    unittest.main()
