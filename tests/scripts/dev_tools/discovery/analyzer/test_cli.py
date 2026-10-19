"""Unit tests for the inventory CLI exit-code contract (scenario 7)."""

from __future__ import annotations

import json
import re
from typing import TYPE_CHECKING
from unittest.mock import patch

import pytest

from scripts.dev_tools.discovery.analyzer import cli
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


def _fixed_clock() -> str:
    """Injected clock returning a fixed schema-conforming timestamp."""
    return "2026-07-18T12:34:56Z"


def _stub_loader(profile: DomainProfile) -> Callable[[Path], DomainProfile]:
    """Return a typed loader stub that ignores its path and returns ``profile``."""

    def _load(_path: Path) -> DomainProfile:
        return profile

    return _load


def _profile(source_root: str, artifacts_root: str) -> DomainProfile:
    """Build a valid DomainProfile pointing at the given roots."""
    return DomainProfile(
        profile_version=1,
        legacy_source=LegacySourceConfig(root=source_root, include=(), exclude=()),
        target=TargetConfig(root="target"),
        technology_stack=TechnologyStackConfig(legacy=("neutral",)),
        artifacts=ArtifactsConfig(root=artifacts_root),
    )


# Default provider and module entry point.


def test_default_clock_produces_iso_8601_timestamp(
    mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Omitting the clock uses the default UTC provider for captured_at."""
    # Arrange
    source_root = mem_fs_path / "src"
    source_root.mkdir(parents=True, exist_ok=True)
    (source_root / "a.txt").write_text("aaa", encoding="utf-8")
    profile = _profile(str(source_root), str(mem_fs_path / "out"))
    monkeypatch.setattr(cli, "load_domain_profile", _stub_loader(profile))
    schema_path = mem_fs_path / "schemas" / "evidence-reference.schema.json"

    # Act (no clock injected -> production default provider runs)
    with patch.object(cli, "run_analyzer", wraps=cli.run_analyzer) as run:
        exit_code = cli.main(["profile.yaml"], schema_path=schema_path)

    # Assert
    assert exit_code == 0
    assert run.call_count == 1
    assert re.match(
        r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$", run.call_args.args[1].captured_at
    )
    assert not (mem_fs_path / "out").exists()


def test_module_entry_point_imports_cli_main() -> None:
    """The ``python -m`` entry module re-exports the CLI main callable."""
    # Act
    from scripts.dev_tools.discovery.analyzer import __main__ as module_entry

    # Assert
    assert module_entry.main is cli.main


# Exit-code group: usage errors (argparse owns exit code 2) and --help.


def test_bad_args_raise_system_exit_2() -> None:
    """An unrecognized flag exits with argparse usage code 2."""
    # Act / Assert
    with pytest.raises(SystemExit) as exc_info:
        cli.main(["--unknown-flag"])
    assert exc_info.value.code == 2


def test_help_exits_zero() -> None:
    """--help exits cleanly with argparse's standard code 0."""
    # Act / Assert
    with pytest.raises(SystemExit) as exc_info:
        cli.main(["--help"])
    assert exc_info.value.code == 0


# Exit-code group: successful run over an in-memory tree.


def test_valid_run_exit_0_is_read_only_with_json_summary(
    mem_fs_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A valid run returns detected counts without implicitly publishing records."""
    # Arrange
    source_root = mem_fs_path / "src"
    (source_root).mkdir(parents=True, exist_ok=True)
    (source_root / "a.txt").write_text("aaa", encoding="utf-8")
    (source_root / "app.sln").write_text("s", encoding="utf-8")
    profile = _profile(str(source_root), str(mem_fs_path / "out"))
    monkeypatch.setattr(cli, "load_domain_profile", _stub_loader(profile))
    schema_path = mem_fs_path / "schemas" / "evidence-reference.schema.json"

    # Act
    exit_code = cli.main(
        ["profile.yaml", "--json"], clock=_fixed_clock, schema_path=schema_path
    )

    # Assert
    assert exit_code == 0
    summary = json.loads(capsys.readouterr().out)
    assert summary["record_count"] == 2
    assert summary["written_paths"] == []
    assert not (mem_fs_path / "out").exists()


def test_valid_run_output_dir_override(
    mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """--output-dir overrides the profile artifacts.root location."""
    # Arrange
    source_root = mem_fs_path / "src"
    source_root.mkdir(parents=True, exist_ok=True)
    (source_root / "a.txt").write_text("aaa", encoding="utf-8")
    profile = _profile(str(source_root), str(mem_fs_path / "profile_out"))
    monkeypatch.setattr(cli, "load_domain_profile", _stub_loader(profile))
    override = mem_fs_path / "override_out"
    schema_path = mem_fs_path / "schemas" / "evidence-reference.schema.json"

    # Act
    with patch.object(cli, "run_analyzer", wraps=cli.run_analyzer) as run:
        exit_code = cli.main(
            ["profile.yaml", "--output-dir", str(override)],
            clock=_fixed_clock,
            schema_path=schema_path,
        )

    # Assert
    assert exit_code == 0
    assert run.call_args.args[1].artifact_root == override
    assert not override.exists()


# Exit-code group: domain / analyzer errors map to exit code 1.


def test_malformed_profile_exit_1(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """A DomainProfileError from the loader maps to exit code 1."""

    # Arrange
    def _raise(_path: Path) -> DomainProfile:
        raise DomainProfileError("profile.yaml: 1 profile error(s):\n  - broken")

    monkeypatch.setattr(cli, "load_domain_profile", _raise)

    # Act
    exit_code = cli.main(["profile.yaml"], clock=_fixed_clock)

    # Assert
    assert exit_code == 1
    assert "broken" in capsys.readouterr().err


def test_unreachable_root_exit_1(
    mem_fs_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """An unreachable source root (AnalyzerError) maps to exit code 1."""
    # Arrange
    missing = mem_fs_path / "missing"
    profile = _profile(str(missing), str(mem_fs_path / "out"))
    monkeypatch.setattr(cli, "load_domain_profile", _stub_loader(profile))
    schema_path = mem_fs_path / "schemas" / "evidence-reference.schema.json"

    # Act
    exit_code = cli.main(["profile.yaml"], clock=_fixed_clock, schema_path=schema_path)

    # Assert
    assert exit_code == 1
    assert str(missing) in capsys.readouterr().err
