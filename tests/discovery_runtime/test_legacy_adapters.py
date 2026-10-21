"""Keep legacy entry forwarding on the bounded installed CLI composition."""

from __future__ import annotations

import io
import json
import sys
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery import cli
from drm_copilot_discovery.cli import CliPorts
from drm_copilot_discovery.models import ParseLimits

from tests.discovery_runtime.test_cli_errors import CountedArguments

if TYPE_CHECKING:
    from collections.abc import Sequence
    from typing import NoReturn, TextIO


@pytest.fixture
def installed_boundary(
    monkeypatch: pytest.MonkeyPatch,
) -> tuple[io.StringIO, io.StringIO, list[str]]:
    """Refuse installed effects and create streams for call-phase binding.

    monkeypatch (pytest.MonkeyPatch) restores all process/module references.
    Return tuple[StringIO, StringIO, list[str]] for stdout, stderr and observed
    provider calls. Any provider invocation raises AssertionError; no filesystem,
    clock, process or service operation is performed.
    """
    output, errors = io.StringIO(), io.StringIO()
    calls: list[str] = []

    def forbidden(*values: object, **options: object) -> NoReturn:
        """Record values/options (object) reaching a forbidden provider, then fail.

        Return never: raise AssertionError after changing only the memory call
        marker. The marker also exposes calls caught by the CLI error boundary.
        """
        calls.append("provider")
        raise AssertionError("Parsing must finish before installed effects")

    # Any provider access would violate the help/refusal boundary under test.
    for name in (
        "_resolve_workspace",
        "_repository",
        "_create_io",
        "_clock",
        "_execute",
    ):
        monkeypatch.setattr(cli, name, forbidden)
    return output, errors, calls


@pytest.mark.parametrize("mutable", [False, True])
def test_installed_entry_preserves_explicit_arguments_and_process_state(
    monkeypatch: pytest.MonkeyPatch,
    installed_boundary: tuple[io.StringIO, io.StringIO, list[str]],
    mutable: bool,
) -> None:
    """Forward an explicit tuple/list unchanged through the existing run_cli seam.

    monkeypatch (pytest.MonkeyPatch) restores the recorder and process argv;
    installed_boundary (tuple[StringIO, StringIO, list[str]]) prevents effects;
    mutable (bool) selects list or tuple tokens. Return None after identity,
    nonmutation, streams and exit assertions; only memory references change.
    """
    output, errors, calls = installed_boundary
    arguments: Sequence[str] = ["--help"] if mutable else ("--help",)
    process_arguments = ["unrelated-entry", "--must-not-be-read"]
    observed: list[Sequence[str]] = []

    def record(
        command: str,
        argv: Sequence[str],
        *,
        ports: CliPorts,
        stdout: TextIO,
        stderr: TextIO,
        limits: ParseLimits,
    ) -> int:
        """Record argv (Sequence[str]) and validate the fixed installed arguments.

        command (str), ports (CliPorts), stdout/stderr (TextIO) and limits
        (ParseLimits) must preserve their established contract. Return exit 1;
        raise AssertionError for incorrect wiring. Only observed gains a reference.
        """
        assert command == "doctor" and argv is arguments
        assert isinstance(ports, CliPorts) and limits == ParseLimits()
        assert stdout is output and stderr is errors
        observed.append(argv)
        return 1

    monkeypatch.setattr(sys, "argv", process_arguments)
    monkeypatch.setattr(cli, "run_cli", record)
    monkeypatch.setattr(sys, "stdout", output)
    monkeypatch.setattr(sys, "stderr", errors)

    assert cli.run_installed_cli("doctor", arguments) == 1
    assert observed == [arguments] and tuple(arguments) == ("--help",)
    assert sys.argv is process_arguments
    assert process_arguments == ["unrelated-entry", "--must-not-be-read"]
    assert not calls and output.getvalue() == errors.getvalue() == ""


def test_installed_entry_default_arguments_preserve_process_vector(
    monkeypatch: pytest.MonkeyPatch,
    installed_boundary: tuple[io.StringIO, io.StringIO, list[str]],
) -> None:
    """Use process option tokens for omitted argv without mutating the vector.

    monkeypatch (pytest.MonkeyPatch) restores process argv; installed_boundary
    (tuple[StringIO, StringIO, list[str]]) records memory output/refused providers.
    Return None after real bounded-parser help and no-effect assertions; no I/O.
    """
    output, errors, calls = installed_boundary
    arguments = ["legacy-entry", "--help"]
    monkeypatch.setattr(sys, "argv", arguments)
    monkeypatch.setattr(sys, "stdout", output)
    monkeypatch.setattr(sys, "stderr", errors)

    assert cli.run_installed_cli("doctor") == 0
    assert "doctor" in output.getvalue() and errors.getvalue() == ""
    assert sys.argv is arguments and arguments == ["legacy-entry", "--help"]
    assert not calls


def test_installed_entry_rejects_explicit_count_before_argument_access(
    monkeypatch: pytest.MonkeyPatch,
    installed_boundary: tuple[io.StringIO, io.StringIO, list[str]],
) -> None:
    """Reject oversized explicit input before copying tokens or invoking providers.

    monkeypatch (pytest.MonkeyPatch) supplies a fixed two-record ParseLimits;
    installed_boundary (tuple[StringIO, StringIO, list[str]]) observes output.
    Return None after count-first refusal, zero token reads and absent effects;
    only the in-memory JSON/error streams change.
    """
    output, errors, calls = installed_boundary
    arguments = CountedArguments(3, "secret-token")
    monkeypatch.setattr(cli, "ParseLimits", lambda: ParseLimits(artifact_records=2))
    monkeypatch.setattr(sys, "stdout", output)
    monkeypatch.setattr(sys, "stderr", errors)

    assert cli.run_installed_cli("doctor", arguments) == 2
    result = json.loads(output.getvalue())
    assert result["findings"][0]["code"] == "CLI_LIMIT"
    assert result["runtime"] is None and result["input_manifest"] is None
    assert arguments.reads == 0 and not calls
    assert "secret-token" not in output.getvalue() and errors.getvalue()


def test_unknown_installed_command_refuses_before_provider_access(
    monkeypatch: pytest.MonkeyPatch,
    installed_boundary: tuple[io.StringIO, io.StringIO, list[str]],
) -> None:
    """Keep unregistered command names outside all installed provider authority.

    monkeypatch (pytest.MonkeyPatch) restores call-phase output streams;
    installed_boundary (tuple[StringIO, StringIO, list[str]]) observes the real
    parser refusal and prevents effects. Return None after fixed exit/context,
    actionable diagnostic and redaction assertions; only memory streams change.
    """
    output, errors, calls = installed_boundary
    arguments = ("--workspace-root", "secret-workspace")
    monkeypatch.setattr(sys, "stdout", output)
    monkeypatch.setattr(sys, "stderr", errors)

    assert cli.run_installed_cli("unsupported-secret", arguments) == 2
    result = json.loads(output.getvalue())
    assert result["operation"] is None and result["artifacts"] == []
    assert result["runtime"] is None and result["input_manifest"] is None
    assert result["findings"][-1]["code"] == "CLI_REQUEST"
    assert result["findings"][-1]["next_action"]
    assert not calls and "secret" not in output.getvalue() and errors.getvalue()
