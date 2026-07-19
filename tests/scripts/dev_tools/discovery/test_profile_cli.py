"""Unit tests for the ``dev.discovery.profile`` console entry point.

Covers ``parse_args`` (default path, explicit path, ``--json``) and ``main``
success and failure paths via ``capsys`` and the in-memory ``mem_fs_path``
fixture. No temporary files are used.
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

from scripts.dev_tools.discovery.domain_profile import DEFAULT_PROFILE_FILENAME
from scripts.dev_tools.discovery.profile_cli import main, parse_args

if TYPE_CHECKING:
    from pathlib import Path

    import pytest

VALID_FULL = (
    "profile_version: 1\n"
    "profile_name: my-migration\n"
    "legacy_source:\n"
    "  root: ../Legacy\n"
    "  include: [src/**]\n"
    "target:\n"
    "  root: ../Target\n"
    "technology_stack:\n"
    "  legacy: [csharp]\n"
    "  target: [typescript]\n"
    "artifacts:\n"
    "  root: discovery/\n"
    "  conventions:\n"
    "    feature-contract: contracts/\n"
)

VALID_MINIMAL = (
    "profile_version: 1\n"
    "legacy_source: {root: ../Legacy}\n"
    "target: {root: ../Target}\n"
    "technology_stack: {legacy: [csharp]}\n"
    "artifacts: {root: discovery/}\n"
)

MALFORMED = (
    "profile_version: 2\n"
    "legacy_source: {root: 7}\n"
    "target: {root: b}\n"
    "technology_stack: {legacy: []}\n"
    "artifacts: {root: d}\n"
)


def test_parse_args_defaults_to_documented_filename() -> None:
    """With no arguments, the positional path defaults and ``--json`` is off."""
    args = parse_args([])
    assert args.profile_path == DEFAULT_PROFILE_FILENAME
    assert args.json is False


def test_parse_args_accepts_explicit_path_and_json_flag() -> None:
    """An explicit path and ``--json`` are captured on the namespace."""
    args = parse_args(["custom.yaml", "--json"])
    assert args.profile_path == "custom.yaml"
    assert args.json is True


def test_main_prints_resolved_text_and_exits_zero(
    mem_fs_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """A valid profile renders aligned text on stdout and exits 0."""
    # Arrange
    profile_path = mem_fs_path / DEFAULT_PROFILE_FILENAME
    profile_path.write_text(VALID_FULL, encoding="utf-8")

    # Act
    exit_code = main([str(profile_path)])

    # Assert
    captured = capsys.readouterr()
    assert exit_code == 0
    assert "profile_version" in captured.out
    assert "legacy_source.root" in captured.out
    assert "../Legacy" in captured.out
    assert captured.err == ""


def test_main_json_output_round_trips_and_exits_zero(
    mem_fs_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """The ``--json`` output parses back into the resolved profile structure."""
    # Arrange
    profile_path = mem_fs_path / DEFAULT_PROFILE_FILENAME
    profile_path.write_text(VALID_FULL, encoding="utf-8")

    # Act
    exit_code = main([str(profile_path), "--json"])

    # Assert
    captured = capsys.readouterr()
    assert exit_code == 0
    payload = json.loads(captured.out)
    assert payload["profile_version"] == 1
    assert payload["profile_name"] == "my-migration"
    assert payload["legacy_source"]["root"] == "../Legacy"
    assert payload["technology_stack"]["legacy"] == ["csharp"]
    assert payload["artifacts"]["root"] == "discovery/"


def test_main_minimal_profile_shows_applied_defaults(
    mem_fs_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """A minimal profile prints resolved defaults explicitly and exits 0."""
    # Arrange
    profile_path = mem_fs_path / DEFAULT_PROFILE_FILENAME
    profile_path.write_text(VALID_MINIMAL, encoding="utf-8")

    # Act
    exit_code = main([str(profile_path)])

    # Assert
    captured = capsys.readouterr()
    assert exit_code == 0
    assert "profile_name" in captured.out
    assert "(none)" in captured.out


def test_main_missing_file_exits_one_with_stderr_message(
    mem_fs_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """A missing profile file exits 1 and names the path on stderr."""
    # Arrange
    missing = mem_fs_path / "absent-profile.yaml"

    # Act
    exit_code = main([str(missing)])

    # Assert
    captured = capsys.readouterr()
    assert exit_code == 1
    assert "absent-profile.yaml" in captured.err
    assert captured.out == ""


def test_main_malformed_profile_reports_all_errors_on_stderr(
    mem_fs_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """A malformed profile exits 1 with every field error on stderr."""
    # Arrange
    profile_path = mem_fs_path / DEFAULT_PROFILE_FILENAME
    profile_path.write_text(MALFORMED, encoding="utf-8")

    # Act
    exit_code = main([str(profile_path)])

    # Assert
    captured = capsys.readouterr()
    assert exit_code == 1
    assert "profile_version: unsupported profile_version 2" in captured.err
    assert "legacy_source.root: expected non-empty string, got int" in captured.err
    assert "technology_stack.legacy: expected a non-empty list" in captured.err


def test_main_default_filename_resolution(
    capsys: pytest.CaptureFixture[str],
) -> None:
    """With no path argument, ``main`` resolves the default filename.

    No ``discovery-profile.yaml`` exists in the working directory during the
    test, so the default-resolved path surfaces on stderr with exit code 1,
    demonstrating that the default filename was used.
    """
    # Act
    exit_code = main([])

    # Assert
    captured = capsys.readouterr()
    assert exit_code == 1
    assert DEFAULT_PROFILE_FILENAME in captured.err
