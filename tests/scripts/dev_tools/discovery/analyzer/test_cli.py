"""Verify inventory adapter forwarding and refusal without legacy context authority."""

from __future__ import annotations

import json
import sys
from collections.abc import Sequence
from typing import TYPE_CHECKING, cast, overload

import pytest
from drm_copilot_discovery import cli as installed
from drm_copilot_discovery.analyzer import pipeline
from drm_copilot_discovery.cli_arguments import CliError, CliHelp, CliInvocation
from drm_copilot_discovery.models import ParseLimits

from scripts.dev_tools.discovery import analyzer
from scripts.dev_tools.discovery.analyzer import cli

if TYPE_CHECKING:
    from pathlib import Path
    from typing import NoReturn

    from drm_copilot_discovery.analyzer.pipeline import AnalyzerFileSystem


@pytest.mark.parametrize("code", [0, 1, 2, 3])
@pytest.mark.parametrize("argv", [None, (), ("--profile", "custom.yaml", "--write")])
def test_canonical_inventory_forwards_exact_arguments_and_exit(
    monkeypatch: pytest.MonkeyPatch, argv: Sequence[str] | None, code: int
) -> None:
    """Retain argv (Sequence[str] | None) identity and code (int) without effects.

    monkeypatch (pytest.MonkeyPatch) isolates the installed entry. Return None
    after exact command/argument/exit assertions; only local call records change.
    """
    calls: list[tuple[str, Sequence[str] | None]] = []

    def forward(command: str, arguments: Sequence[str] | None = None) -> int:
        """Record command (str)/arguments (Sequence[str] | None); return code int.

        Mutates only the local list; no errors or provider operations are expected.
        """
        calls.append((command, arguments))
        return code

    monkeypatch.setattr(installed, "run_installed_cli", forward)
    assert cli.main(argv) == code
    assert len(calls) == 1 and calls[0][0] == "inventory"
    assert calls[0][1] is argv


def test_module_entry_point_imports_cli_main() -> None:
    """Return None after module main and legacy protocol identity checks; no I/O."""
    from scripts.dev_tools.discovery.analyzer import __main__ as module_entry

    assert module_entry.main is cli.main
    assert analyzer.main is cli.main
    assert analyzer.Analyzer is pipeline.Analyzer
    assert analyzer.run_analyzer is pipeline.run_analyzer
    assert analyzer.__all__ == ["Analyzer", "main", "run_analyzer"]
    with pytest.raises(AttributeError, match="has no attribute"):
        analyzer.__getattr__("not_exported")


@pytest.mark.parametrize("seam", ["clock", "fs", "schema_path"])
def test_unsupported_seams_refuse_before_callbacks_or_installed_entry(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str], seam: str
) -> None:
    """Refuse seam (str) without invoking or inspecting supplied legacy values.

    monkeypatch (pytest.MonkeyPatch) traps installed execution; capsys
    (CaptureFixture[str]) captures fixed output. Return None; only capture buffers
    change. Any callback/value access raises AssertionError as a negative control.
    """

    class ForbiddenValue:
        """Represent unsupported authority; all observable value access is forbidden.

        Test-local construction stores no data. Identity checks are allowed;
        formatting/equality/calling raises AssertionError without I/O.
        """

        def __call__(self) -> str:
            """Raise AssertionError without arguments, effects or a returned clock."""
            raise AssertionError("Legacy callback accessed")

        def __str__(self) -> str:
            """Raise AssertionError instead of exposing a legacy value; no effects."""
            raise AssertionError("Legacy value formatted")

        def __eq__(self, other: object) -> bool:
            """Reject comparison with other (object); raise AssertionError, no I/O."""
            raise AssertionError("Legacy value compared")

    def forbidden(command: str, argv: Sequence[str] | None = None) -> NoReturn:
        """Reject command (str)/argv (Sequence[str] | None) before effects."""
        raise AssertionError("Installed entry must not run")

    value = ForbiddenValue()
    monkeypatch.setattr(installed, "run_installed_cli", forbidden)
    code = cli.main(
        ("--help",),
        clock=value if seam == "clock" else None,
        fs=cast("AnalyzerFileSystem", value) if seam == "fs" else None,
        schema_path=cast("Path", value) if seam == "schema_path" else None,
    )
    output = capsys.readouterr()
    assert code == 2 and output.out == ""
    assert "Migrate" in output.err and "CliPorts" in output.err
    assert "No files were read or written" in output.err


@pytest.mark.parametrize(
    "argv,code",
    [
        (("--help",), 0),
        (("--unknown-flag",), 2),
        (("profile.yaml",), 2),
        (("--output-dir", "arbitrary"), 2),
        (("--json",), 2),
    ],
)
def test_help_usage_and_ambiguous_legacy_arguments_never_access_providers(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    argv: tuple[str, ...],
    code: int,
) -> None:
    """Keep help/usage/refusal through actual installed parsing with no providers.

    monkeypatch (pytest.MonkeyPatch) traps resolution; capsys (CaptureFixture[str])
    captures output; argv (tuple[str, ...])/code (int) select expected behavior.
    Return None after fixed outcome checks; no filesystem or service access.
    """

    def forbidden(selected: str) -> NoReturn:
        """Reject selected root (str) with AssertionError; no I/O or returned path."""
        raise AssertionError("Invalid/help argv reached a provider")

    monkeypatch.setattr(installed, "_resolve_workspace", forbidden)
    assert cli.main(argv) == code
    output = capsys.readouterr()
    # Only help is text; every invalid request retains the installed typed envelope.
    if code:
        assert json.loads(output.out)["exit_code"] == code and output.err
    else:
        assert "inventory" in output.out and not output.err


@pytest.mark.parametrize("process", [False, True])
def test_parse_args_preserves_pure_public_carriers(
    monkeypatch: pytest.MonkeyPatch, process: bool
) -> None:
    """Use process (bool) or explicit argv; preserve parser carriers without I/O.

    monkeypatch (pytest.MonkeyPatch) restores process argv. Return None after
    exact read-only request/help/error checks; no providers or source access.
    """
    argv = ["--profile", "custom.yaml"]
    monkeypatch.setattr(sys, "argv", ["entry", *argv])
    parsed = cli.parse_args(None if process else argv)
    assert isinstance(parsed, CliInvocation)
    assert parsed.request["profile_path"] == "custom.yaml"
    assert parsed.request["write"] is False and parsed.request["dry_run"] is False
    assert isinstance(cli.parse_args(["--help"]), CliHelp)
    assert isinstance(cli.parse_args(["profile.yaml"]), CliError)


def test_parse_args_precharges_process_copy(monkeypatch: pytest.MonkeyPatch) -> None:
    """Refuse oversized process argv before slicing; monkeypatch restores globals.

    monkeypatch (pytest.MonkeyPatch) installs a counted vector and tiny limits.
    Return None after refusal; slicing raises AssertionError, no external effects.
    """

    class NoCopy(Sequence[str]):
        """Reject slicing while retaining normal length for prepaid parser refusal.

        A test-local process vector; integer access is not needed or permitted.
        All indexing raises AssertionError and changes no state.
        """

        def __len__(self) -> int:
            """Return oversized count 3 without traversal, arguments or effects."""
            return 3

        @overload
        def __getitem__(self, key: int) -> str:
            """Reject int key without returning text; no effects."""

        @overload
        def __getitem__(self, key: slice) -> Sequence[str]:
            """Reject slice key without returning a sequence; no effects."""

        def __getitem__(self, key: int | slice) -> str | Sequence[str]:
            """Reject key (object) with AssertionError; no returned element/effects."""
            raise AssertionError("Oversized process vector copied")

    monkeypatch.setattr(sys, "argv", NoCopy())
    monkeypatch.setattr(cli, "ParseLimits", lambda: ParseLimits(artifact_records=1))
    parsed = cli.parse_args()
    assert isinstance(parsed, CliError) and parsed.findings[0].code == "CLI_LIMIT"
