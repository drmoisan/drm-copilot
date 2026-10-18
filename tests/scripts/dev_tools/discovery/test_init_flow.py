"""Retain legacy diagnostics/imports while rejecting unchecked v1 initialization."""

from __future__ import annotations

from pathlib import Path

import pytest
from drm_copilot_discovery import init_flow as runtime

from scripts.dev_tools.discovery import init_flow as mod
from scripts.dev_tools.discovery.init_models import EXPECTED_TEMPLATE_RELATIVE_PATHS


class FakeFileSystem:
    """Represent the legacy unchecked interface entirely in test-owned memory."""

    def __init__(self) -> None:
        """Start with no files, directories or writes from another test."""
        self.files: dict[Path, str] = {}
        self.dirs: set[Path] = set()

    def exists(self, path: Path) -> bool:
        """Read this test's exact namespace membership."""
        return path in self.files or path in self.dirs

    def is_dir(self, path: Path) -> bool:
        """Distinguish files from directories without native filesystem calls."""
        return path in self.dirs

    def list_dir(self, path: Path) -> list[Path]:
        """Enumerate complete immediate memory children."""
        return [
            item
            for item in {*self.files, *self.dirs}
            if item != path and item.parent == path
        ]

    def ensure_dir(self, path: Path) -> None:
        """Expose the old unchecked capability so rejection can prove it is unused."""
        self.dirs.add(path)

    def read_text(self, path: Path) -> str:
        """Return exact fixture text or the established missing-file error."""
        if path not in self.files:
            raise FileNotFoundError(path)
        return self.files[path]

    def write_text(self, path: Path, content: str) -> None:
        """Model the overwrite capability that must never grant v2 authority."""
        self.files[path] = content


def seed_templates(fs: FakeFileSystem, root: Path) -> None:
    """Retain the complete legacy template shape for helper compatibility tests."""
    fs.dirs.add(root)
    for path in EXPECTED_TEMPLATE_RELATIVE_PATHS:
        fs.files[root / path] = "legacy fixture"


def test_public_exports_are_thin_runtime_aliases() -> None:
    """Every supported old import resolves to the authoritative runtime function."""
    for name in mod.__all__:
        assert getattr(mod, name) is getattr(runtime, name)


@pytest.mark.parametrize("tokens", [None, {}, {"<a>": "one", "<b>": "two"}])
def test_literal_substitution_helper_remains_compatible(
    tokens: dict[str, str] | None,
) -> None:
    """Repeated literal replacements remain independent of typed v2 rendering."""
    result = mod.substitute_placeholders("<a> <a> <b>", tokens)
    assert result == ("one one two" if tokens else "<a> <a> <b>")


@pytest.mark.parametrize("force", [False, True])
@pytest.mark.parametrize("nonempty", [False, True])
def test_legacy_calls_require_explicit_v2_context_and_never_write(
    force: bool, nonempty: bool
) -> None:
    """Deprecated force cannot turn the unchecked legacy FileSystem into authority."""
    fs = FakeFileSystem()
    target, root = Path("/consumer/discovery"), Path("/templates")
    fs.dirs.update((target.parent, target))
    seed_templates(fs, root)
    if nonempty:
        fs.files[target / "keep.txt"] = "preserve original bytes"
    before = (dict(fs.files), set(fs.dirs))

    with pytest.raises(ValueError, match="initialize_workspace") as failure:
        mod.create_discovery_workspace(target, root, fs, force=force)

    assert "system ID/name" in str(failure.value)
    assert "force never permits overwriting" in str(failure.value)
    assert (fs.files, fs.dirs) == before


def test_template_override_and_complete_missing_template_diagnostics() -> None:
    """Helpers retain caller-selected roots and report every missing template."""
    fs, root = FakeFileSystem(), Path("/alternate-templates")
    with pytest.raises(FileNotFoundError, match="alternate-templates"):
        mod.validate_template_set(root, fs)
    seed_templates(fs, root)
    mod.validate_template_set(root, fs)
    missing = EXPECTED_TEMPLATE_RELATIVE_PATHS[-2:]
    for path in missing:
        del fs.files[root / path]
    with pytest.raises(FileNotFoundError) as failure:
        mod.validate_template_set(root, fs)
    assert all(str(path) in str(failure.value) for path in missing)


def test_target_type_and_parent_errors_remain_actionable() -> None:
    """An invalid parent or file target fails before the migration diagnostic."""
    fs, target = FakeFileSystem(), Path("/consumer/discovery")
    with pytest.raises(FileNotFoundError, match="parent"):
        mod.validate_target_path(target, fs, force=False)
    fs.dirs.add(target.parent)
    fs.files[target] = "existing file"
    with pytest.raises(NotADirectoryError, match="not a directory"):
        mod.validate_target_path(target, fs, force=True)


@pytest.mark.parametrize("force", [False, True])
def test_nonempty_target_is_not_itself_a_conflict(force: bool) -> None:
    """Conflict assessment belongs to complete v2 artifact validation."""
    fs, target = FakeFileSystem(), Path("/consumer/discovery")
    fs.dirs.update((target.parent, target))
    fs.files[target / "unrelated.txt"] = "keep"
    mod.validate_target_path(target, fs, force=force)
    assert fs.files[target / "unrelated.txt"] == "keep"
