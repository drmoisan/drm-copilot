"""CLI tests for the stack-analyzer console entry points.

Exercises ``main_dotnet`` and ``main_vsto`` over an in-memory consumer tree and a
patched profile loader (patched at its import location in ``stack_cli`` per the
python.md rule). No temporary files are created; the injected clock is pinned.
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING, Never, cast

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

    from scripts.dev_tools.discovery.analyzer.pipeline import AnalyzerFileSystem

    # Both console entry points share this callable shape.
    EntryPoint = Callable[..., int]

_CLOCK = "2026-07-18T12:34:56Z"
_SOURCE = "namespace Foo;\npublic class Bar : IRibbonExtensibility {}\n"


def _clock() -> str:
    """Return str pinned ISO-8601 time; no parameters, I/O or expected errors."""
    return _CLOCK


def _profile(source_root: Path, out_root: Path) -> DomainProfile:
    """Return DomainProfile for source_root/out_root (Path) in the memory fixture.

    Pure construction; invalid metadata raises DomainProfileError. No I/O.
    """
    return DomainProfile(
        profile_version=1,
        legacy_source=LegacySourceConfig(root=str(source_root)),
        target=TargetConfig(root=str(source_root / "target")),
        technology_stack=TechnologyStackConfig(legacy=("csharp", "vsto")),
        artifacts=ArtifactsConfig(root=str(out_root)),
    )


def _build_source(source_root: Path) -> None:
    """Populate source_root (Path) in the injected in-memory filesystem.

    Returns None; creates a directory and source file only in the fake filesystem.
    OSError propagates if the fake rejects an operation.
    """
    source_root.mkdir(parents=True, exist_ok=True)
    (source_root / "a.cs").write_text(_SOURCE, encoding="utf-8")


def _patch_loader(monkeypatch: pytest.MonkeyPatch, profile: DomainProfile) -> None:
    """Install profile (DomainProfile) through monkeypatch (pytest.MonkeyPatch).

    Returns None; changes only the scoped loader seam, restored by pytest.
    No external I/O or expected errors.
    """

    def _fake_loader(path: Path) -> DomainProfile:
        """Return the captured DomainProfile for ignored path (Path); no I/O/errors."""
        del path
        return profile

    monkeypatch.setattr(stack_cli, "load_domain_profile", _fake_loader)


@pytest.mark.parametrize("entry", [stack_cli.main_dotnet])
class TestSuccessPaths:
    """Preserve .NET success behavior with isolated in-memory fixtures and no writes."""

    def test_success_keeps_default_run_read_only(
        self, entry: EntryPoint, mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Verify entry (EntryPoint) succeeds without publication.

        mem_fs_path (Path) identifies a memory fixture and monkeypatch
        (pytest.MonkeyPatch) isolates the loader. Returns None; AssertionError
        signals a changed exit or writes. Uses only fake filesystem operations.
        """
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
        assert not out_root.exists()

    def test_json_summary(
        self,
        entry: EntryPoint,
        mem_fs_path: Path,
        monkeypatch: pytest.MonkeyPatch,
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """Verify entry (EntryPoint) prints the retained JSON result shape.

        mem_fs_path (Path), monkeypatch (pytest.MonkeyPatch) and capsys
        (CaptureFixture[str]) isolate files, loader and output. Returns None;
        AssertionError signals changed records/publication. No external I/O.
        """
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
        assert summary["written_paths"] == []
        assert summary["record_count"] >= 1

    def test_output_dir_override(
        self, entry: EntryPoint, mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Verify entry (EntryPoint) honors output selection without publication.

        mem_fs_path (Path) and monkeypatch (pytest.MonkeyPatch) isolate filesystem
        and loader. Returns None; AssertionError signals writes or a failed run.
        Uses only the fake filesystem.
        """
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

        # Assert: selecting an output root alone does not authorize publication.
        assert code == 0
        assert not override_out.exists()
        assert not profile_out.exists()


@pytest.mark.parametrize("entry", [stack_cli.main_dotnet])
class TestErrorPaths:
    """Preserve .NET error paths using isolated loader and filesystem seams."""

    def test_malformed_profile_exits_one(
        self,
        entry: EntryPoint,
        mem_fs_path: Path,
        monkeypatch: pytest.MonkeyPatch,
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """Verify entry (EntryPoint) reports malformed input with exit 1.

        mem_fs_path (Path), monkeypatch (pytest.MonkeyPatch) and capsys
        (CaptureFixture[str]) isolate dependencies/output. Returns None;
        AssertionError signals an incorrect diagnostic. No external I/O.
        """

        # Arrange: the loader raises DomainProfileError for a malformed profile.
        def _raise(path: Path) -> DomainProfile:
            """Reject path (Path) with DomainProfileError; never return a profile.

            Performs no I/O or mutation; represents malformed synthetic input.
            """
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
        """Verify entry (EntryPoint) reports an unreachable root with exit 1.

        mem_fs_path (Path), monkeypatch (pytest.MonkeyPatch) and capsys
        (CaptureFixture[str]) isolate dependencies/output. Returns None;
        AssertionError signals wrong diagnostics. Uses only fake filesystem state.
        """
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
        """Verify entry (EntryPoint) raises SystemExit(2) for invalid usage.

        Returns None; AssertionError signals a changed exit. Only argparse output
        is produced; no filesystem access.
        """
        # Act / Assert
        with pytest.raises(SystemExit) as exc_info:
            entry(["--nonexistent-flag"])
        assert exc_info.value.code == 2


@pytest.mark.parametrize(
    "argv", [[], ["missing.yaml"], ["--json"], ["--output-dir", "ignored"]]
)
def test_optional_cli_rejects_before_profile_clock_or_filesystem(
    argv: list[str],
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Keep valid legacy syntax but reject unconsented execution before all I/O.

    argv (list[str]) supplies fixed syntax; monkeypatch (pytest.MonkeyPatch) traps
    collaborator calls; capsys (CaptureFixture[str]) captures diagnostics. Returns
    None; AssertionError signals any I/O/default construction or wrong exit.
    """

    def forbidden(*args: object, **kwargs: object) -> Never:
        """Reject args/kwargs (object) with AssertionError; never return or do I/O."""
        del args, kwargs
        raise AssertionError("Legacy optional command must stop before I/O")

    monkeypatch.setattr(stack_cli, "load_domain_profile", forbidden)
    monkeypatch.setattr(stack_cli, "RealAnalyzerFileSystem", forbidden)
    monkeypatch.setattr(stack_cli, "_default_schema_path", forbidden)
    result = stack_cli.main_vsto(argv)
    explicit = stack_cli.main_vsto(
        argv,
        clock=forbidden,
        fs=cast("AnalyzerFileSystem", object()),
        schema_path=cast("Path", object()),
    )
    output = capsys.readouterr()
    assert result == explicit == 1 and output.out == ""
    assert "v2 InventoryCapture" in output.err and "office-vsto" in output.err
    assert "No files were read or written" in output.err


@pytest.mark.parametrize("argv,code", [(["--help"], 0), (["--nonexistent-flag"], 2)])
def test_optional_cli_preserves_help_and_usage(argv: list[str], code: int) -> None:
    """Retain argparse help/error behavior before the migration response.

    argv (list[str]) selects help or invalid syntax; code (int) is the expected
    SystemExit status. Returns None; AssertionError signals changed usage. No I/O
    beyond argparse output and no optional analyzer imports.
    """
    with pytest.raises(SystemExit) as error:
        stack_cli.main_vsto(argv)
    assert error.value.code == code
