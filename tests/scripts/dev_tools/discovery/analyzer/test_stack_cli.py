"""CLI tests for the stack-analyzer console entry points.

Exercises ``main_dotnet`` and ``main_vsto`` over an in-memory consumer tree and a
patched profile loader (patched at its import location in ``stack_cli`` per the
python.md rule). No temporary files are created; the injected clock is pinned.
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools.discovery.analyzer import stack_cli
from scripts.dev_tools.discovery.analyzer.pipeline import RealAnalyzerFileSystem
from scripts.dev_tools.discovery.domain_profile_models import (
    ArtifactsConfig,
    DomainProfile,
    DomainProfileError,
    LegacySourceConfig,
    TargetConfig,
    TechnologyStackConfig,
)

if TYPE_CHECKING:
    from collections.abc import Callable
    from pathlib import Path

    # Both console entry points share this callable shape.
    EntryPoint = Callable[..., int]

_CLOCK = "2026-07-18T12:34:56Z"
_SOURCE = "namespace Foo;\npublic class Bar : IRibbonExtensibility {}\n"


def _clock() -> str:
    """Return a pinned ISO-8601 timestamp for deterministic emission."""
    return _CLOCK


def _profile(source_root: Path, out_root: Path) -> DomainProfile:
    """Build a valid domain profile pointing at the given in-memory roots."""
    return DomainProfile(
        profile_version=1,
        legacy_source=LegacySourceConfig(root=str(source_root)),
        target=TargetConfig(root=str(source_root / "target")),
        technology_stack=TechnologyStackConfig(legacy=("csharp", "vsto")),
        artifacts=ArtifactsConfig(root=str(out_root)),
    )


def _build_source(source_root: Path) -> None:
    """Populate an in-memory consumer source tree with one C# file."""
    source_root.mkdir(parents=True, exist_ok=True)
    (source_root / "a.cs").write_text(_SOURCE, encoding="utf-8")


def _patch_loader(monkeypatch: pytest.MonkeyPatch, profile: DomainProfile) -> None:
    """Patch the profile loader at its import location in ``stack_cli``."""

    def _fake_loader(path: Path) -> DomainProfile:
        """Return the prebuilt profile regardless of the requested path."""
        del path
        return profile

    monkeypatch.setattr(stack_cli, "load_domain_profile", _fake_loader)


@pytest.mark.parametrize("entry", [stack_cli.main_dotnet, stack_cli.main_vsto])
class TestSuccessPaths:
    """Success-path behavior shared by both entry points."""

    def test_success_writes_instances(
        self, entry: EntryPoint, mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """A valid run exits 0 and writes at least one instance."""
        # Arrange
        source_root = mem_fs_path / "consumer"
        out_root = mem_fs_path / "out"
        _build_source(source_root)
        _patch_loader(monkeypatch, _profile(source_root, out_root))

        # Act
        code = entry(
            ["discovery-profile.yaml"],
            clock=_clock,
            fs=RealAnalyzerFileSystem(),
            schema_path=mem_fs_path / "schemas" / "s.json",
        )

        # Assert
        assert code == 0
        written = list(out_root.iterdir())
        assert written
        assert all(p.name.endswith(".json") for p in written)

    def test_json_summary(
        self,
        entry: EntryPoint,
        mem_fs_path: Path,
        monkeypatch: pytest.MonkeyPatch,
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """The ``--json`` flag prints a machine-readable run summary."""
        # Arrange
        source_root = mem_fs_path / "consumer"
        out_root = mem_fs_path / "out"
        _build_source(source_root)
        _patch_loader(monkeypatch, _profile(source_root, out_root))

        # Act
        code = entry(
            ["discovery-profile.yaml", "--json"],
            clock=_clock,
            fs=RealAnalyzerFileSystem(),
            schema_path=mem_fs_path / "schemas" / "s.json",
        )
        summary = json.loads(capsys.readouterr().out)

        # Assert
        assert code == 0
        assert summary["record_count"] == len(summary["written_paths"])
        assert summary["record_count"] >= 1

    def test_output_dir_override(
        self, entry: EntryPoint, mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """The ``--output-dir`` flag overrides the profile artifacts root."""
        # Arrange
        source_root = mem_fs_path / "consumer"
        profile_out = mem_fs_path / "profile_out"
        override_out = mem_fs_path / "override_out"
        _build_source(source_root)
        _patch_loader(monkeypatch, _profile(source_root, profile_out))

        # Act
        code = entry(
            ["discovery-profile.yaml", "--output-dir", str(override_out)],
            clock=_clock,
            fs=RealAnalyzerFileSystem(),
            schema_path=mem_fs_path / "schemas" / "s.json",
        )

        # Assert: instances land under the override root, not the profile root.
        assert code == 0
        assert list(override_out.iterdir())
        assert not profile_out.exists()


@pytest.mark.parametrize("entry", [stack_cli.main_dotnet, stack_cli.main_vsto])
class TestErrorPaths:
    """Error-path and usage-error behavior shared by both entry points."""

    def test_malformed_profile_exits_one(
        self,
        entry: EntryPoint,
        mem_fs_path: Path,
        monkeypatch: pytest.MonkeyPatch,
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """A malformed profile exits 1 with a specific error on stderr."""

        # Arrange: the loader raises DomainProfileError for a malformed profile.
        def _raise(path: Path) -> DomainProfile:
            del path
            raise DomainProfileError("profile is malformed: missing legacy_source")

        monkeypatch.setattr(stack_cli, "load_domain_profile", _raise)

        # Act
        code = entry(
            ["discovery-profile.yaml"],
            clock=_clock,
            fs=RealAnalyzerFileSystem(),
            schema_path=mem_fs_path / "schemas" / "s.json",
        )

        # Assert
        assert code == 1
        assert "malformed" in capsys.readouterr().err

    def test_unreachable_root_exits_one(
        self,
        entry: EntryPoint,
        mem_fs_path: Path,
        monkeypatch: pytest.MonkeyPatch,
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """An unreachable legacy_source.root exits 1 naming the path."""
        # Arrange: the profile points at a source root that does not exist.
        missing_root = mem_fs_path / "missing"
        _patch_loader(monkeypatch, _profile(missing_root, mem_fs_path / "out"))

        # Act
        code = entry(
            ["discovery-profile.yaml"],
            clock=_clock,
            fs=RealAnalyzerFileSystem(),
            schema_path=mem_fs_path / "schemas" / "s.json",
        )

        # Assert
        assert code == 1
        assert "missing" in capsys.readouterr().err

    def test_usage_error_exits_two(self, entry: EntryPoint) -> None:
        """An argparse usage error exits 2 via SystemExit."""
        # Act / Assert
        with pytest.raises(SystemExit) as exc_info:
            entry(["--nonexistent-flag"])
        assert exc_info.value.code == 2
