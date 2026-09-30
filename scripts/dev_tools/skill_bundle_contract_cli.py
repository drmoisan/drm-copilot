"""Command-line guard that fails when a skill invokes an unbundled script.

Purpose:
    The I/O boundary for ``scripts/dev_tools/skill_bundle_contract.py``. It
    reads the skill texts, the skill folders, the Claude customization bundle,
    and the pack manifests from a repository checkout into a
    ``SkillBundleInputs`` snapshot, runs the pure evaluation, and reports each
    violation and each stale exception on stderr (issue #762).

Usage:
    ``poetry run python -m scripts.dev_tools.skill_bundle_contract_cli``
    from the repository root, optionally with ``--repo-root <path>``. The exit
    code is 1 when any line was reported and 0 otherwise.

Side effects:
    ``load_repository_inputs`` reads files under the repository root.
    ``main`` writes report lines to stderr. Nothing is written to disk.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import TYPE_CHECKING, cast

from scripts.dev_tools.skill_bundle_contract import (
    KNOWN_UNBUNDLED_REFERENCES,
    PUBLISHED_ROOT_FOLDERS,
    SkillBundleInputs,
    extract_script_references,
    find_stale_exceptions,
    find_violations,
)

if TYPE_CHECKING:
    from collections.abc import Callable, Iterable, Sequence

    from scripts.dev_tools.skill_bundle_contract import KnownUnbundledReference

BUNDLE_ROOT = Path("extensions/drm-copilot/resources/claude-customizations")
_SKILLS_ROOT = Path(".claude/skills")
_MANIFEST_FOLDER = "pack-manifests"


def _files_under(folder: Path, relative_to: Path) -> frozenset[str]:
    """List every file below a folder as POSIX paths relative to a base.

    Args:
        folder (Path): Folder to walk; a missing folder yields no files.
        relative_to (Path): Base the returned paths are relative to.

    Returns:
        frozenset[str]: Relative POSIX paths of every file below ``folder``.

    Side Effects:
        Reads the directory tree.
    """

    if not folder.is_dir():
        return frozenset()
    # Walk the tree and keep regular files only.
    return frozenset(
        entry.relative_to(relative_to).as_posix()
        for entry in folder.rglob("*")
        if entry.is_file()
    )


def _load_pack_paths(manifest_folder: Path) -> dict[str, frozenset[str]]:
    """Parse every pack manifest into its listed ``paths``.

    Args:
        manifest_folder (Path): The bundle's ``pack-manifests`` folder.

    Returns:
        dict[str, frozenset[str]]: Pack name (file stem) to listed paths.

    Raises:
        ValueError: When a manifest has no ``paths`` list of strings.

    Side Effects:
        Reads the manifest files.
    """

    pack_paths: dict[str, frozenset[str]] = {}
    # Each manifest file contributes one pack keyed by its file stem.
    for manifest in sorted(manifest_folder.glob("*.json")):
        document: object = json.loads(manifest.read_text(encoding="utf-8"))
        paths: object = (
            cast("dict[str, object]", document).get("paths")
            if isinstance(document, dict)
            else None
        )
        if not isinstance(paths, list) or not all(
            isinstance(entry, str) for entry in cast("list[object]", paths)
        ):
            raise ValueError(
                f"Pack manifest has no 'paths' list of strings: {manifest.name}"
            )
        pack_paths[manifest.stem] = frozenset(cast("list[str]", paths))
    return pack_paths


def load_repository_inputs(repo_root: Path) -> SkillBundleInputs:
    """Build the evaluation snapshot from a repository checkout.

    Args:
        repo_root (Path): Repository root directory.

    Returns:
        SkillBundleInputs: Skill texts, skill-folder files, the existing
        referenced files, the bundle files under the published roots, and the
        pack manifests.

    Raises:
        FileNotFoundError: When ``.claude/skills`` or the bundle's manifest
            folder is absent.
        ValueError: When a skill frontmatter or a pack manifest is malformed.

    Side Effects:
        Reads files under ``repo_root``.
    """

    skills_root = repo_root / _SKILLS_ROOT
    bundle_root = repo_root / BUNDLE_ROOT
    manifest_folder = bundle_root / _MANIFEST_FOLDER
    if not skills_root.is_dir():
        raise FileNotFoundError(f"Skills folder not found: {skills_root}")
    if not manifest_folder.is_dir():
        raise FileNotFoundError(f"Pack manifest folder not found: {manifest_folder}")

    skill_texts: dict[str, str] = {}
    skill_folder_files: dict[str, frozenset[str]] = {}
    # Read each skill folder: its SKILL.md text and the files it contains.
    for skill_folder in sorted(
        entry for entry in skills_root.iterdir() if entry.is_dir()
    ):
        skill_text_file = skill_folder / "SKILL.md"
        if skill_text_file.is_file():
            skill_texts[skill_folder.name] = skill_text_file.read_text(encoding="utf-8")
        skill_folder_files[skill_folder.name] = _files_under(skill_folder, repo_root)

    repository_files: set[str] = set()
    # The snapshot needs to know which files exist: the skill-folder files and
    # every extracted reference that resolves to a file in the checkout.
    for files in skill_folder_files.values():
        repository_files |= files
    for text in skill_texts.values():
        repository_files.update(
            reference
            for reference in extract_script_references(text)
            if (repo_root / reference).is_file()
        )

    bundle_files: set[str] = set()
    # Only the published root folders of the bundle reach a destination.
    for root_folder in PUBLISHED_ROOT_FOLDERS:
        bundle_files |= _files_under(bundle_root / root_folder, bundle_root)

    return SkillBundleInputs(
        skill_texts=skill_texts,
        skill_folder_files=skill_folder_files,
        repository_files=frozenset(repository_files),
        bundle_files=frozenset(bundle_files),
        pack_paths=_load_pack_paths(manifest_folder),
    )


def main(
    argv: Sequence[str] | None = None,
    *,
    loader: Callable[[Path], SkillBundleInputs] = load_repository_inputs,
    exceptions: Iterable[KnownUnbundledReference] = KNOWN_UNBUNDLED_REFERENCES,
) -> int:
    """Run the guard and report violations and stale exceptions on stderr.

    Args:
        argv (Sequence[str] | None): Arguments; ``None`` reads ``sys.argv``.
        loader (Callable[[Path], SkillBundleInputs]): Snapshot builder;
            injectable so tests supply inline inputs.
        exceptions (Iterable[KnownUnbundledReference]): Registered exceptions;
            injectable so tests exercise the suppression and staleness branches
            with an empty default registry.

    Returns:
        int: 1 when any line was reported, else 0.

    Side Effects:
        Writes one stderr line per violation and per stale exception.
    """

    parser = argparse.ArgumentParser(
        description="Fail when a skill invokes a script that is not bundled with it."
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=Path(),
        help="Repository root (default: current directory).",
    )
    arguments = parser.parse_args(argv)
    inputs = loader(cast("Path", arguments.repo_root))
    # Materialize the registry once so both finders read the same entries even
    # when the caller passes a one-shot iterable.
    registered = tuple(exceptions)

    # Render one report line per unregistered violation.
    report = [
        "skill-bundle violation: "
        f"{violation.skill} | {violation.path} | {violation.reason}"
        for violation in find_violations(inputs, exceptions=registered)
    ]
    # Stale exceptions are reported alongside violations so a fixed exception
    # cannot stay in the registry unnoticed.
    report.extend(
        "skill-bundle stale exception: "
        f"{exception.skill} | {exception.path} | {exception.issue}"
        for exception in find_stale_exceptions(inputs, exceptions=registered)
    )
    # Emit each report line on stderr.
    for line in report:
        sys.stderr.write(line + "\n")
    return 1 if report else 0


if __name__ == "__main__":
    raise SystemExit(main())
