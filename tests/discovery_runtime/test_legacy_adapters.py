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

from scripts.dev_tools import (
    generate_acceptance_scenarios,
    validate_discovery_artifacts,
)
from scripts.dev_tools.discovery import (
    completion_report,
    coverage_report,
    init_cli,
    parity_report,
    profile_cli,
)
from scripts.dev_tools.discovery.analyzer import cli as analyzer_cli
from scripts.dev_tools.discovery.analyzer import stack_cli
from tests.discovery_runtime.test_cli_errors import CountedArguments

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence
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


@pytest.fixture
def installed_dispatch(
    monkeypatch: pytest.MonkeyPatch,
    installed_boundary: tuple[io.StringIO, io.StringIO, list[str]],
) -> list[tuple[str, Sequence[str]]]:
    """Observe the final CLI seam while retaining every real adapter/public call.

    monkeypatch (pytest.MonkeyPatch) restores only the cli.run_cli recorder;
    installed_boundary (tuple[StringIO, StringIO, list[str]]) blocks providers.
    Return list[tuple[str, Sequence[str]]] retaining original argument objects.
    The recorder returns exit 3, raises AssertionError for changed installed
    wiring, and changes only the returned memory list. No service I/O occurs.
    """
    output, errors, _ = installed_boundary
    observed: list[tuple[str, Sequence[str]]] = []

    def record(
        command: str,
        argv: Sequence[str],
        *,
        ports: CliPorts,
        stdout: TextIO,
        stderr: TextIO,
        limits: ParseLimits,
    ) -> int:
        """Retain command (str) and argv (Sequence[str]) without copying tokens.

        ports (CliPorts), stdout/stderr (TextIO), and limits (ParseLimits) must
        retain installed wiring. Return int 3 after appending the call; raise
        AssertionError on mismatched ports/streams. No external effects occur.
        """
        assert isinstance(ports, CliPorts) and limits == ParseLimits()
        assert stdout is output and stderr is errors
        observed.append((command, argv))
        return 3

    monkeypatch.setattr(cli, "run_cli", record)
    return observed


@pytest.mark.parametrize(
    ("entry", "command"),
    [
        (profile_cli.main, "profile"),
        (init_cli.main, "init"),
        (analyzer_cli.main, "inventory"),
        (stack_cli.main_dotnet, "dotnet"),
        (stack_cli.main_vsto, "vsto"),
        (generate_acceptance_scenarios.main, "generate-acceptance-scenarios"),
    ],
    ids=["profile", "init", "inventory", "dotnet", "vsto", "acceptance"],
)
def test_direct_legacy_routes_reach_installed_dispatch_with_original_arguments(
    monkeypatch: pytest.MonkeyPatch,
    entry: Callable[[Sequence[str] | None], int],
    command: str,
    installed_dispatch: list[tuple[str, Sequence[str]]],
    installed_boundary: tuple[io.StringIO, io.StringIO, list[str]],
) -> None:
    """Compose six unchanged-vector routes through the real public entry.

    monkeypatch (pytest.MonkeyPatch) restores call-phase streams. entry
    (Callable[[Sequence[str] | None], int]) and command (str) select a fixed
    adapter. installed_dispatch (list[tuple[str, Sequence[str]]]) records only
    the final run_cli seam; installed_boundary (tuple[StringIO, StringIO,
    list[str]]) supplies memory streams/markers.
    Return None after exact command/object/exit/nonmutation assertions. The
    adapter and public entry execute; providers and output remain untouched.
    """
    arguments = ["--workspace-root", "memory-workspace"]
    output, errors, calls = installed_boundary
    monkeypatch.setattr(sys, "stdout", output)
    monkeypatch.setattr(sys, "stderr", errors)

    result = entry(arguments)

    assert result == 3 and len(installed_dispatch) == 1
    actual_command, actual_arguments = installed_dispatch[0]
    assert actual_command == command and actual_arguments is arguments
    assert arguments == ["--workspace-root", "memory-workspace"]
    assert not calls and output.getvalue() == errors.getvalue() == ""


@pytest.mark.parametrize(
    ("entry", "command"),
    [
        (coverage_report.main, "coverage-report"),
        (parity_report.main, "parity-report"),
        (completion_report.main, "completion-report"),
    ],
    ids=["coverage", "parity", "completion"],
)
def test_report_legacy_routes_retain_bounded_captured_arguments(
    monkeypatch: pytest.MonkeyPatch,
    entry: Callable[[Sequence[str] | None], int],
    command: str,
    installed_dispatch: list[tuple[str, Sequence[str]]],
    installed_boundary: tuple[io.StringIO, io.StringIO, list[str]],
) -> None:
    """Preserve the reports' bounded immutable capture before public forwarding.

    monkeypatch (pytest.MonkeyPatch) restores call-phase streams. entry
    (Callable[[Sequence[str] | None], int]) and command (str) select one
    report. installed_dispatch (list[tuple[str, Sequence[str]]]) observes the
    final CLI seam; installed_boundary (tuple[StringIO, StringIO, list[str]])
    supplies memory streams/markers. Return None after captured tuple, exact
    tokens/exit and unchanged caller checks.
    Real routing/public composition runs without legacy reads or service effects.
    """
    arguments = ["--workspace-root", "memory-workspace"]
    output, errors, calls = installed_boundary
    monkeypatch.setattr(sys, "stdout", output)
    monkeypatch.setattr(sys, "stderr", errors)

    result = entry(arguments)

    assert result == 3 and len(installed_dispatch) == 1
    actual_command, actual_arguments = installed_dispatch[0]
    assert actual_command == command and type(actual_arguments) is tuple
    assert actual_arguments == ("--workspace-root", "memory-workspace")
    assert arguments == ["--workspace-root", "memory-workspace"]
    assert not calls and output.getvalue() == errors.getvalue() == ""


@pytest.mark.parametrize(
    ("entry", "command"),
    [
        (validate_discovery_artifacts.main_profile, "validate-profile"),
        (
            validate_discovery_artifacts.main_feature_contract,
            "validate-feature-contract",
        ),
        (validate_discovery_artifacts.main_coverage_ledger, "validate-coverage-ledger"),
        (
            validate_discovery_artifacts.main_runtime_scenario,
            "validate-runtime-scenario",
        ),
        (validate_discovery_artifacts.main_parity_matrix, "validate-parity-matrix"),
        (
            validate_discovery_artifacts.main_unspecified_behavior,
            "validate-unspecified-behavior",
        ),
        (
            validate_discovery_artifacts.main_product_decision,
            "validate-product-decision",
        ),
        (
            validate_discovery_artifacts.main_evidence_reference,
            "validate-evidence-reference",
        ),
    ],
    ids=[
        "profile",
        "feature",
        "coverage",
        "runtime",
        "parity",
        "unknown",
        "decision",
        "evidence",
    ],
)
def test_fixed_validator_routes_select_process_tokens_without_mutation(
    monkeypatch: pytest.MonkeyPatch,
    entry: Callable[[], int],
    command: str,
    installed_dispatch: list[tuple[str, Sequence[str]]],
    installed_boundary: tuple[io.StringIO, io.StringIO, list[str]],
) -> None:
    """Retain eight zero-argument wrapper signatures and installed token selection.

    monkeypatch (pytest.MonkeyPatch) restores process argv; entry (Callable[[],
    int]) and command (str) select a fixed validator. installed_dispatch
    (list[tuple[str, Sequence[str]]]) records the final seam; installed_boundary
    (tuple[StringIO, StringIO, list[str]]) supplies memory streams/markers.
    Return None after exact tokens/exit and
    unchanged process-vector assertions. No file, validator or service executes.
    """
    arguments = ["legacy-validator", "--workspace-root", "memory-workspace"]
    output, errors, calls = installed_boundary
    monkeypatch.setattr(sys, "argv", arguments)
    monkeypatch.setattr(sys, "stdout", output)
    monkeypatch.setattr(sys, "stderr", errors)

    result = entry()

    assert result == 3 and installed_dispatch == [
        (command, ["--workspace-root", "memory-workspace"])
    ]
    assert sys.argv is arguments
    assert arguments == ["legacy-validator", "--workspace-root", "memory-workspace"]
    assert not calls and output.getvalue() == errors.getvalue() == ""
