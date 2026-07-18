"""Tests for `scripts.dev_tools.discovery.init_flow`."""

from __future__ import annotations

import json
from pathlib import Path
from typing import TYPE_CHECKING

import jsonschema
import pytest

from scripts.dev_tools.discovery import init_flow as mod
from scripts.dev_tools.discovery.domain_profile import parse_domain_profile_text
from scripts.dev_tools.discovery.init_models import (
    DOMAIN_PROFILE_RELATIVE_PATH,
    EXPECTED_TEMPLATE_RELATIVE_PATHS,
    OUTPUT_RELATIVE_PATHS,
    resolve_default_template_root,
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


def test_domain_profile_template_parses_with_real_loader() -> None:
    """The bundled domain-profile template parses under the real #360 loader.

    Reads the in-repo domain-profile template, renders it both with no tokens and
    with a representative domain-neutral token mapping, and asserts the real
    ``parse_domain_profile_text`` returns a ``DomainProfile`` with
    ``profile_version == 1`` in each case. The only filesystem access is reading
    the in-repo template file.
    """
    template_path = resolve_default_template_root() / DOMAIN_PROFILE_RELATIVE_PATH
    template_text = template_path.read_text(encoding="utf-8")
    tokens = {
        "<legacy-source-path>": "legacy/src",
        "<target-path>": "modern/src",
        "<technology-stack>": "example-runtime",
        "<artifact-output-dir>": "discovery/artifacts",
    }

    for rendered in (
        mod.substitute_placeholders(template_text),
        mod.substitute_placeholders(template_text, tokens),
    ):
        profile = parse_domain_profile_text(rendered)
        assert profile.profile_version == 1


def test_generated_artifacts_conform_to_real_schemas() -> None:
    """Each generated artifact validates against its merged v1 JSON schema.

    Seeds an in-memory filesystem with the real bundled template texts, scaffolds
    a workspace via `create_discovery_workspace`, then loads each of the seven
    rendered artifact instances and validates it against the corresponding merged
    schema file under `schemas/discovery/v1/`. The only filesystem access is
    reading the in-repo template and schema files.
    """
    template_root = resolve_default_template_root()
    schema_root = template_root.parents[2] / "schemas" / "discovery" / "v1"
    fs = FakeFileSystem()
    fs.dirs.add(template_root)
    for relative_path in EXPECTED_TEMPLATE_RELATIVE_PATHS:
        fs.files[template_root / relative_path] = (
            template_root / relative_path
        ).read_text(encoding="utf-8")
    target_dir = Path("/consumer/discovery")
    fs.dirs.add(target_dir.parent)

    mod.create_discovery_workspace(target_dir, template_root, fs)

    # OUTPUT_RELATIVE_PATHS[0] is the non-JSON domain-profile.yaml; the remaining
    # seven entries are the artifact JSON instances validated here.
    for output_relative in OUTPUT_RELATIVE_PATHS[1:]:
        instance = json.loads(fs.files[target_dir / output_relative])
        schema_name = output_relative.stem + ".schema.json"
        schema = json.loads((schema_root / schema_name).read_text(encoding="utf-8"))
        jsonschema.validate(instance=instance, schema=schema)
