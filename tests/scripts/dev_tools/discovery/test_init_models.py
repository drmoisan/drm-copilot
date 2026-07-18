"""Tests for `scripts.dev_tools.discovery.init_models`."""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools.discovery import init_models as mod

if TYPE_CHECKING:
    import pytest


def test_real_file_system_delegates_to_pathlib(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """`RealFileSystem` delegates each method to `pathlib.Path` with no real I/O."""
    calls: list[str] = []

    def fake_exists(self: Path) -> bool:  # noqa: ARG001
        calls.append("exists")
        return True

    def fake_is_dir(self: Path) -> bool:  # noqa: ARG001
        calls.append("is_dir")
        return True

    def fake_iterdir(self: Path):  # noqa: ARG001
        calls.append("iterdir")
        return iter([Path("a"), Path("b")])

    def fake_mkdir(self: Path, parents: bool, exist_ok: bool) -> None:  # noqa: ARG001
        calls.append("mkdir")

    def fake_read_text(self: Path, encoding: str) -> str:  # noqa: ARG001
        calls.append("read_text")
        return "content"

    def fake_write_text(
        self: Path, content: str, encoding: str
    ) -> None:  # noqa: ARG001
        calls.append("write_text")

    monkeypatch.setattr(Path, "exists", fake_exists, raising=True)
    monkeypatch.setattr(Path, "is_dir", fake_is_dir, raising=True)
    monkeypatch.setattr(Path, "iterdir", fake_iterdir, raising=True)
    monkeypatch.setattr(Path, "mkdir", fake_mkdir, raising=True)
    monkeypatch.setattr(Path, "read_text", fake_read_text, raising=True)
    monkeypatch.setattr(Path, "write_text", fake_write_text, raising=True)

    fs = mod.RealFileSystem()
    target = Path("/workspace/target")

    assert fs.exists(target) is True
    assert fs.is_dir(target) is True
    assert fs.list_dir(target) == [Path("a"), Path("b")]
    fs.ensure_dir(target)
    assert fs.read_text(target / "file.txt") == "content"
    fs.write_text(target / "file.txt", "new content")

    assert calls == [
        "exists",
        "is_dir",
        "iterdir",
        "mkdir",
        "read_text",
        "mkdir",
        "write_text",
    ]


def test_expected_template_relative_paths_has_eight_entries() -> None:
    """The template/output path constants have the expected, index-aligned shape."""
    assert len(mod.EXPECTED_TEMPLATE_RELATIVE_PATHS) == 8
    assert len(mod.ARTIFACT_RELATIVE_PATHS) == 7
    assert len(mod.OUTPUT_RELATIVE_PATHS) == 8

    assert mod.EXPECTED_TEMPLATE_RELATIVE_PATHS[0] == mod.DOMAIN_PROFILE_RELATIVE_PATH
    assert mod.OUTPUT_RELATIVE_PATHS[0] == Path("domain-profile.yaml")

    for template_path, output_path in zip(
        mod.EXPECTED_TEMPLATE_RELATIVE_PATHS[1:],
        mod.OUTPUT_RELATIVE_PATHS[1:],
        strict=True,
    ):
        assert template_path in mod.ARTIFACT_RELATIVE_PATHS
        assert output_path.parent == Path("artifacts")
        assert output_path.suffix == ".json"


def test_resolve_default_template_root_returns_expected_path() -> None:
    """The default template root ends in `docs/discovery/templates`."""
    result = mod.resolve_default_template_root()
    assert result.parts[-3:] == ("docs", "discovery", "templates")
