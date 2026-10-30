"""Verify fixed stack forwarding and fail-closed legacy seams without source access."""

from __future__ import annotations

import builtins
import json
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import cli as installed
from drm_copilot_discovery.cli_arguments import CliInvocation, parse_cli_arguments
from drm_copilot_discovery.models import JsonObject, ParseLimits

from scripts.dev_tools.discovery.analyzer import stack_cli

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence
    from pathlib import Path
    from types import ModuleType
    from typing import NoReturn

    from drm_copilot_discovery.analyzer.pipeline import AnalyzerFileSystem

    EntryPoint = Callable[..., int]


@pytest.mark.parametrize(
    "entry,command,selected",
    [
        (stack_cli.main_dotnet, "dotnet", "dotnet"),
        (stack_cli.main_vsto, "vsto", "office-vsto"),
    ],
)
@pytest.mark.parametrize("argv", [None, (), ("--dry-run",), ("--write",)])
def test_fixed_stack_route_retains_explicit_selector_and_publication_flags(
    monkeypatch: pytest.MonkeyPatch,
    entry: EntryPoint,
    command: str,
    selected: str,
    argv: Sequence[str] | None,
) -> None:
    """Forward one fixed alias without implementing selection or publication.

    monkeypatch (pytest.MonkeyPatch) replaces installed execution; entry
    (EntryPoint), command/selected (str), argv (Sequence[str] | None) choose a
    canonical request. Return None after exact identity/read-only/flag checks.
    Only local records change; no source, registry or optional module is accessed.
    """
    seen: list[JsonObject] = []

    def forward(name: str, arguments: Sequence[str] | None = None) -> int:
        """Check name (str)/arguments (Sequence[str] | None); return synthetic exit 0.

        Parse only the immutable request; local records change, never providers.
        Assertions diagnose mismatched forwarding rather than grant consent.
        """
        assert name == command and arguments is argv
        parsed = parse_cli_arguments(name, arguments or (), limits=ParseLimits())
        assert isinstance(parsed, CliInvocation)
        seen.append(parsed.request)
        return 0

    monkeypatch.setattr(installed, "run_installed_cli", forward)
    assert entry(argv) == 0 and len(seen) == 1
    inputs = seen[0]["inputs"]
    assert isinstance(inputs, JsonObject) and inputs["analyzer_ids"] == (selected,)
    assert seen[0]["write"] is (argv == ("--write",))
    assert seen[0]["dry_run"] is (argv == ("--dry-run",))


@pytest.mark.parametrize("entry", [stack_cli.main_dotnet, stack_cli.main_vsto])
@pytest.mark.parametrize("code", [1, 2, 3])
def test_installed_failure_survives_without_fabricating_success(
    monkeypatch: pytest.MonkeyPatch, entry: EntryPoint, code: int
) -> None:
    """Preserve installed code (int) through entry (EntryPoint), without fallback.

    monkeypatch (pytest.MonkeyPatch) isolates execution. Return None after one
    forwarding call; no legacy profile/pipeline/clock or external I/O is used.
    """
    calls: list[str] = []

    def forward(command: str, argv: Sequence[str] | None = None) -> int:
        """Record command (str), ignore argv (Sequence[str] | None); return code int.

        Only the test-local call list changes; no provider effects or errors.
        """
        calls.append(command)
        return code

    monkeypatch.setattr(installed, "run_installed_cli", forward)
    assert entry(()) == code and len(calls) == 1


@pytest.mark.parametrize("entry", [stack_cli.main_dotnet, stack_cli.main_vsto])
@pytest.mark.parametrize("seam", ["clock", "fs", "schema_path"])
def test_unsupported_stack_seams_refuse_without_access(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    entry: EntryPoint,
    seam: str,
) -> None:
    """Refuse seam (str) before entry (EntryPoint) can reach any installed provider.

    monkeypatch (pytest.MonkeyPatch) traps execution; capsys (CaptureFixture[str])
    captures fixed refusal. Return None; no callback, profile or filesystem access.
    """

    def forbidden(*args: object, **kwargs: object) -> NoReturn:
        """Reject args/kwargs (object) with AssertionError; no return or effects."""
        raise AssertionError("Unsupported seam was evaluated")

    monkeypatch.setattr(installed, "run_installed_cli", forbidden)
    code = entry(
        ("--repository-id", "repository"),
        clock=forbidden if seam == "clock" else None,
        fs=cast("AnalyzerFileSystem", forbidden) if seam == "fs" else None,
        schema_path=cast("Path", forbidden) if seam == "schema_path" else None,
    )
    output = capsys.readouterr()
    assert code == 2 and output.out == ""
    assert "Migrate" in output.err and "No files were read or written" in output.err


@pytest.mark.parametrize("entry", [stack_cli.main_dotnet, stack_cli.main_vsto])
@pytest.mark.parametrize(
    "argv,code",
    [
        (("--help",), 0),
        (("--nonexistent-flag",), 2),
        (("missing.yaml",), 2),
        (("--output-dir", "ignored"), 2),
        (("--analyzer", "repository"), 2),
    ],
)
def test_optional_cli_preserves_help_usage_and_refuses_ambiguous_inputs(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    entry: EntryPoint,
    argv: tuple[str, ...],
    code: int,
) -> None:
    """Use actual installed parsing before any optional import/provider work.

    monkeypatch (pytest.MonkeyPatch) restores traps; capsys (CaptureFixture[str])
    captures streams. entry (EntryPoint), argv (tuple[str, ...]), code (int) select
    the case. Return None after refusal/help checks; local records/streams only.
    """
    imports: list[str] = []
    original = builtins.__import__

    def tracked(
        name: str,
        globals: dict[str, object] | None = None,
        locals: dict[str, object] | None = None,
        fromlist: Sequence[str] = (),
        level: int = 0,
    ) -> ModuleType:
        """Trap optional name (str); otherwise preserve the original import contract.

        globals/locals (dict[str, object] | None), fromlist (Sequence[str]), level
        (int) are forwarded unchanged. Return ModuleType or original error;
        optional imports raise AssertionError. Only local counters may change.
        """
        if ".optional" in name:
            imports.append(name)
            raise AssertionError("Optional implementation imported before selection")
        return original(name, globals, locals, fromlist, level)

    def forbidden(selected: str) -> NoReturn:
        """Reject selected (str) workspace with AssertionError; no I/O or return."""
        raise AssertionError("Invalid/help argv reached a provider")

    monkeypatch.setattr(installed, "_resolve_workspace", forbidden)
    # Restore import interception before pytest formats any assertion or failure.
    with monkeypatch.context() as scoped:
        scoped.setattr(builtins, "__import__", tracked)
        result = entry(argv)
    output = capsys.readouterr()
    assert result == code and not imports
    if code:
        assert json.loads(output.out)["exit_code"] == code and output.err
    else:
        assert "dev.discovery." in output.out and not output.err
