"""Verify installed profile forwarding while preserving pure v1 display contracts."""

from __future__ import annotations

import json
import runpy
import sys
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery import cli as runtime_cli
from drm_copilot_discovery.domain_profile import (
    DEFAULT_PROFILE_FILENAME,
    DomainProfileError,
    parse_domain_profile_text,
)

from scripts.dev_tools.discovery import profile_cli as mod
from tests.discovery_runtime.gateway_test_support import (
    installed_schema as installed_schema,
)
from tests.discovery_runtime.test_configuration import config_catalog as config_catalog
from tests.scripts.dev_tools.discovery.test_init_cli import (
    forbid_effects as forbid_effects,
)

if TYPE_CHECKING:
    from collections.abc import Sequence

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
    """Return None after asserting historical defaults; no file access occurs."""
    args = mod.parse_args([])
    assert args.profile_path == DEFAULT_PROFILE_FILENAME
    assert args.json is False


def test_parse_args_accepts_explicit_path_and_json_flag(
    forbid_effects: list[str],
) -> None:
    """Use forbid_effects (list[str]) to prove old parsing is nonauthoritative.

    Return None after namespace/no-call assertions; no profile is read or rendered.
    """
    args = mod.parse_args(["custom.yaml", "--json"])
    assert args.profile_path == "custom.yaml"
    assert args.json is True
    assert forbid_effects == []


def test_render_text_preserves_resolved_v1_values() -> None:
    """Return None after full v1 text assertions; parse/render stay memory-only."""
    profile = parse_domain_profile_text(VALID_FULL)
    rendered = mod.render_text(profile)
    assert "profile_version" in rendered and "legacy_source.root" in rendered
    assert "../Legacy" in rendered and "src/**" in rendered
    assert "csharp" in rendered and "typescript" in rendered
    assert "feature-contract=contracts/" in rendered and "my-migration" in rendered
    assert len(rendered.splitlines()) == 12


def test_render_json_preserves_resolved_v1_structure() -> None:
    """Return None after sorted v1 JSON assertions; no parameters or external I/O."""
    profile = parse_domain_profile_text(VALID_FULL)
    rendered = mod.render_json(profile)
    payload = json.loads(rendered)
    assert payload["profile_version"] == 1 and payload["profile_name"] == "my-migration"
    assert payload["legacy_source"]["root"] == "../Legacy"
    assert payload["technology_stack"]["legacy"] == ["csharp"]
    assert payload["artifacts"]["root"] == "discovery/"
    assert rendered == json.dumps(payload, sort_keys=True, indent=2)


def test_render_minimal_profile_preserves_applied_defaults() -> None:
    """Return None after absent optional values render explicitly; no I/O."""
    profile = parse_domain_profile_text(VALID_MINIMAL)
    rendered = mod.render_text(profile)
    payload = json.loads(mod.render_json(profile))
    assert "profile_name" in rendered and "(none)" in rendered
    assert payload["profile_name"] is None
    assert payload["legacy_source"]["include"] == []
    assert payload["legacy_source"]["exclude"] == []
    assert payload["technology_stack"]["target"] == []


def test_v1_reader_preserves_invalid_profile_diagnostics() -> None:
    """Return None after the actual v1 reader raises all expected field errors.

    No parameters or effects; malformed historical input cannot become v2 proof.
    """
    with pytest.raises(DomainProfileError) as invalid:
        parse_domain_profile_text(MALFORMED)
    assert "profile_version: unsupported profile_version 2" in str(invalid.value)
    assert "legacy_source.root: expected non-empty string, got int" in str(
        invalid.value
    )
    assert "technology_stack.legacy: expected a non-empty list" in str(invalid.value)


@pytest.mark.parametrize("exit_code", [0, 1, 2, 3])
def test_main_forwards_profile_selection_and_typed_exit(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    exit_code: int,
) -> None:
    """Forward explicit selection and exit_code (int) without legacy rendering.

    monkeypatch (pytest.MonkeyPatch) supplies a memory entry; capsys
    (pytest.CaptureFixture[str]) detects extra output. Return None; no external I/O.
    """
    argv = ("--workspace-root", "/consumer", "--profile", "docs/profile.yaml")
    calls: list[tuple[str, Sequence[str] | None]] = []

    def installed(command: str, arguments: Sequence[str] | None = None) -> int:
        """Record command/arguments (str/Sequence[str] | None); return int exit.

        Only the call list changes; the supplied vector remains untouched.
        """
        calls.append((command, arguments))
        return exit_code

    monkeypatch.setattr(runtime_cli, "run_installed_cli", installed)
    assert mod.main(argv) == exit_code
    assert calls == [("profile", argv)] and calls[0][1] is argv
    assert capsys.readouterr() == ("", "")


@pytest.mark.parametrize("argv", [None, ()], ids=["process", "explicit-empty"])
def test_main_retains_installed_argument_selection(
    monkeypatch: pytest.MonkeyPatch, argv: tuple[str, ...] | None
) -> None:
    """Forward argv (tuple[str, ...] | None) without default-file or ancestor lookup.

    monkeypatch (pytest.MonkeyPatch) supplies a memory entry. Return None after
    argument identity/exit assertions; no process arguments or filesystem are read.
    """
    calls: list[tuple[str, Sequence[str] | None]] = []

    def installed(command: str, arguments: Sequence[str] | None = None) -> int:
        """Record command/arguments (str/Sequence[str] | None); return 1, no I/O."""
        calls.append((command, arguments))
        return 1

    monkeypatch.setattr(runtime_cli, "run_installed_cli", installed)
    assert mod.main(argv) == 1
    assert calls == [("profile", argv)] and calls[0][1] is argv


@pytest.mark.parametrize(
    "argv",
    [
        ("absent-profile.yaml",),
        ("malformed-profile.yaml", "--json"),
        ("--json",),
        ("--workspace-root", "/consumer", "profile.yaml"),
        ("--workspace-root", "/consumer", "--template-root", "/arbitrary"),
        ("--workspace-root", "/consumer", "--force"),
    ],
    ids=[
        "missing-positional",
        "invalid-positional",
        "json",
        "mixed",
        "template",
        "force",
    ],
)
def test_legacy_profile_inputs_refuse_before_effects(
    argv: tuple[str, ...], forbid_effects: list[str], capsys: pytest.CaptureFixture[str]
) -> None:
    """Reject ambiguous argv (tuple[str, ...]) through the installed parser.

    forbid_effects (list[str]) blocks ports; capsys (pytest.CaptureFixture[str])
    captures output. Return None after typed refusal/no-call assertions; no I/O.
    """
    assert mod.main(argv) == 2
    captured = capsys.readouterr()
    payload = json.loads(captured.out)
    assert payload["exit_code"] == 2 and payload["operation"] == "profile"
    assert payload["runtime"] is None and payload["input_manifest"] is None
    assert payload["artifacts"] == [] and forbid_effects == []
    assert payload["findings"][0]["code"] == "CLI_ARGUMENTS"
    assert payload["findings"][1]["code"] == "CLI_REQUEST"
    assert "--help" in payload["findings"][0]["next_action"]
    assert "/arbitrary" not in captured.out + captured.err


def test_help_uses_installed_profile_options_without_providers(
    forbid_effects: list[str], capsys: pytest.CaptureFixture[str]
) -> None:
    """Use forbid_effects (list[str])/capsys (pytest.CaptureFixture[str]) in memory.

    Return None after fixed help/no-call assertions; only captured output changes.
    """
    assert mod.main(("--help",)) == 0
    captured = capsys.readouterr()
    assert "--workspace-root" in captured.out and "--profile" in captured.out
    assert "profile_path" not in captured.out and captured.err == ""
    assert forbid_effects == []


def test_module_entry_returns_installed_exit(monkeypatch: pytest.MonkeyPatch) -> None:
    """Use monkeypatch (pytest.MonkeyPatch) to prove module SystemExit(1).

    Return None after in-process module execution; only the restored module cache
    and patched installed entry change, with no provider or external I/O.
    """

    def installed(command: str, argv: Sequence[str] | None = None) -> int:
        """Require fixed command (str)/default argv; return 1 without I/O."""
        assert command == "profile" and argv is None
        return 1

    monkeypatch.setattr(runtime_cli, "run_installed_cli", installed)
    monkeypatch.delitem(sys.modules, mod.__name__)
    with pytest.raises(SystemExit) as stopped:
        runpy.run_module(mod.__name__, run_name="__main__")
    assert stopped.value.code == 1
