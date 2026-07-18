"""Tests for `scripts.dev_tools.discovery.init_flow`."""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools.discovery import init_flow as mod
from scripts.dev_tools.discovery.init_models import (
    EXPECTED_TEMPLATE_RELATIVE_PATHS,
    OUTPUT_RELATIVE_PATHS,
)

if TYPE_CHECKING:
    from scripts.dev_tools.discovery.init_models import FileSystem


class FakeFileSystem:
    """In-memory `FileSystem` test double with no real disk I/O."""

    def __init__(self) -> None:
        self.files: dict[Path, str] = {}
        self.dirs: set[Path] = set()

    def exists(self, path: Path) -> bool:
        return path in self.files or path in self.dirs

    def is_dir(self, path: Path) -> bool:
        return path in self.dirs

    def list_dir(self, path: Path) -> list[Path]:
        children: list[Path] = []
        for candidate in {*self.files, *self.dirs}:
            if candidate != path and candidate.parent == path:
                children.append(candidate)
        return children

    def ensure_dir(self, path: Path) -> None:
        self.dirs.add(path)

    def read_text(self, path: Path) -> str:
        if path not in self.files:
            raise FileNotFoundError(path)
        return self.files[path]

    def write_text(self, path: Path, content: str) -> None:
        self.files[path] = content


def _seed_template_root(fs: FakeFileSystem, template_root: Path) -> None:
    """Seed `fs` with a complete, 8-file expected template set under `template_root`."""
    fs.dirs.add(template_root)
    for relative_path in EXPECTED_TEMPLATE_RELATIVE_PATHS:
        fs.files[template_root / relative_path] = f"template:{relative_path}"


def test_substitute_placeholders_no_tokens_returns_unchanged() -> None:
    """With `tokens=None`, the input text is returned unchanged."""
    text = "<legacy-source-path> stays intact"
    assert mod.substitute_placeholders(text) == text
    assert mod.substitute_placeholders(text, None) == text


def test_substitute_placeholders_replaces_every_occurrence() -> None:
    """Every occurrence of each mapped token is replaced by its value."""
    text = "<a> and <a> and <b>"
    result = mod.substitute_placeholders(text, {"<a>": "1", "<b>": "2"})
    assert result == "1 and 1 and 2"


def test_create_discovery_workspace_success_full_layout() -> None:
    """A complete template set scaffolds exactly the 8 expected output files."""
    fs = FakeFileSystem()
    template_root = Path("/templates")
    target_dir = Path("/consumer/discovery")
    fs.dirs.add(target_dir.parent)
    _seed_template_root(fs, template_root)

    mod.create_discovery_workspace(target_dir, template_root, fs)

    written = {path for path in fs.files if path != template_root}
    expected_paths = {
        target_dir / output_relative for output_relative in OUTPUT_RELATIVE_PATHS
    }
    assert written.issuperset(expected_paths)
    assert len(expected_paths) == 8
    for template_relative, output_relative in zip(
        EXPECTED_TEMPLATE_RELATIVE_PATHS, OUTPUT_RELATIVE_PATHS, strict=True
    ):
        assert fs.files[target_dir / output_relative] == f"template:{template_relative}"


def test_create_discovery_workspace_template_root_override() -> None:
    """An alternate template root is read from, instead of any default root."""
    fs = FakeFileSystem()
    default_root = Path("/default-templates")
    alternate_root = Path("/alternate-templates")
    target_dir = Path("/consumer/discovery")
    fs.dirs.add(target_dir.parent)
    _seed_template_root(fs, default_root)
    fs.dirs.add(alternate_root)
    for relative_path in EXPECTED_TEMPLATE_RELATIVE_PATHS:
        fs.files[alternate_root / relative_path] = f"alternate:{relative_path}"

    mod.create_discovery_workspace(target_dir, alternate_root, fs)

    for template_relative, output_relative in zip(
        EXPECTED_TEMPLATE_RELATIVE_PATHS, OUTPUT_RELATIVE_PATHS, strict=True
    ):
        assert (
            fs.files[target_dir / output_relative] == f"alternate:{template_relative}"
        )


def test_target_path_not_a_directory_raises() -> None:
    """A target path that exists as a file raises `NotADirectoryError`."""
    fs = FakeFileSystem()
    template_root = Path("/templates")
    target_dir = Path("/consumer/discovery")
    fs.dirs.add(target_dir.parent)
    fs.files[target_dir] = "not a directory"
    _seed_template_root(fs, template_root)
    pre_seeded_files = set(fs.files)

    with pytest.raises(NotADirectoryError):
        mod.create_discovery_workspace(target_dir, template_root, fs)

    assert set(fs.files) == pre_seeded_files


def test_target_parent_missing_raises() -> None:
    """A target whose parent directory does not exist raises `FileNotFoundError`."""
    fs = FakeFileSystem()
    template_root = Path("/templates")
    target_dir = Path("/consumer/discovery")
    _seed_template_root(fs, template_root)
    pre_seeded_files = set(fs.files)

    with pytest.raises(FileNotFoundError):
        mod.create_discovery_workspace(target_dir, template_root, fs)

    assert set(fs.files) == pre_seeded_files


def test_target_non_empty_without_force_raises() -> None:
    """A non-empty target without `force` raises `FileExistsError`."""
    fs = FakeFileSystem()
    template_root = Path("/templates")
    target_dir = Path("/consumer/discovery")
    fs.dirs.add(target_dir.parent)
    fs.dirs.add(target_dir)
    pre_seeded = target_dir / "existing.txt"
    fs.files[pre_seeded] = "already here"
    _seed_template_root(fs, template_root)
    pre_seeded_files = set(fs.files)

    with pytest.raises(FileExistsError):
        mod.create_discovery_workspace(target_dir, template_root, fs)

    assert set(fs.files) == pre_seeded_files


def test_target_non_empty_with_force_succeeds() -> None:
    """A non-empty target with `force=True` succeeds and writes the full output set."""
    fs = FakeFileSystem()
    template_root = Path("/templates")
    target_dir = Path("/consumer/discovery")
    fs.dirs.add(target_dir.parent)
    fs.dirs.add(target_dir)
    pre_seeded = target_dir / "existing.txt"
    fs.files[pre_seeded] = "already here"
    _seed_template_root(fs, template_root)

    mod.create_discovery_workspace(target_dir, template_root, fs, force=True)

    expected_paths = {
        target_dir / output_relative for output_relative in OUTPUT_RELATIVE_PATHS
    }
    assert expected_paths.issubset(set(fs.files))
    assert pre_seeded in fs.files


def test_missing_template_root_raises() -> None:
    """A wholly missing template root raises `FileNotFoundError` and writes nothing."""
    fs: FileSystem = FakeFileSystem()
    template_root = Path("/templates")
    target_dir = Path("/consumer/discovery")
    fs.dirs.add(target_dir.parent)

    with pytest.raises(FileNotFoundError):
        mod.create_discovery_workspace(target_dir, template_root, fs)

    assert not fs.files


def test_partial_template_set_raises() -> None:
    """A template root missing one file raises `FileNotFoundError` naming it."""
    fs = FakeFileSystem()
    template_root = Path("/templates")
    target_dir = Path("/consumer/discovery")
    fs.dirs.add(target_dir.parent)
    _seed_template_root(fs, template_root)
    missing_relative = EXPECTED_TEMPLATE_RELATIVE_PATHS[-1]
    del fs.files[template_root / missing_relative]
    pre_seeded_files = set(fs.files)

    with pytest.raises(FileNotFoundError) as excinfo:
        mod.create_discovery_workspace(target_dir, template_root, fs)

    assert str(missing_relative) in str(excinfo.value)
    assert set(fs.files) == pre_seeded_files


@pytest.mark.skip(
    reason=(
        "blocked pending legacy-discovery-schemas issue 9002: no schema files "
        "exist in the repository yet"
    )
)
def test_schema_conformance_pending_issue_9002() -> None:
    """Each generated starter artifact should validate against its 9002 schema.

    This test is intentionally skipped until issue 9002 lands the seven versioned
    JSON schema files. Once available, this test should load each schema under
    `docs/discovery/schemas/v1/` and assert `jsonschema.validate(...)` succeeds
    for each of the 8 generated starter artifacts produced by
    `create_discovery_workspace(...)`, per 9002's planned schema-versioning shape.
    """
    fs = FakeFileSystem()
    template_root = Path("/templates")
    target_dir = Path("/consumer/discovery")
    fs.dirs.add(target_dir.parent)
    _seed_template_root(fs, template_root)

    mod.create_discovery_workspace(target_dir, template_root, fs)

    # Intended assertion body (pending issue 9002 schema files):
    # for output_relative in OUTPUT_RELATIVE_PATHS[1:]:
    #     instance = json.loads(fs.files[target_dir / output_relative])
    #     schema = load_schema_for(instance["$schema"])
    #     jsonschema.validate(instance=instance, schema=schema)
