"""Verify fixed installed init forwarding and inert historical parsing in memory."""

from __future__ import annotations

import json
import runpy
import sys
from pathlib import Path
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery import cli as runtime_cli

from scripts.dev_tools.discovery import domain_profile, init_flow, init_models
from scripts.dev_tools.discovery import init_cli as mod
from tests.discovery_runtime.gateway_test_support import (
    installed_schema as installed_schema,
)
from tests.discovery_runtime.test_configuration import config_catalog as config_catalog

if TYPE_CHECKING:
    from collections.abc import Sequence
    from typing import NoReturn


@pytest.fixture
def forbid_effects(monkeypatch: pytest.MonkeyPatch) -> list[str]:
    """Block installed providers and legacy fallbacks with monkeypatch.

    monkeypatch (pytest.MonkeyPatch) restores each fixed callback after the test.
    Return list[str] recording attempted effects; each attempt raises AssertionError
    before external I/O. Only test-local patches and that list can change.
    """
    calls: list[str] = []

    def refuse(*_args: object, **_kwargs: object) -> NoReturn:
        """Record object arguments as an attempted effect, then raise AssertionError.

        No argument is inspected or invoked; only the memory call list changes.
        """
        calls.append("unexpected-effect")
        raise AssertionError("Argument refusal must precede runtime effects")

    # Every trusted installed port must remain unused for help or invalid syntax.
    for name in (
        "_resolve_workspace",
        "_repository",
        "_create_io",
        "_clock",
        "_execute",
    ):
        monkeypatch.setattr(runtime_cli, name, refuse)
    # Legacy readers/templates/writers must never become a fallback authority.
    for owner, name in (
        (domain_profile, "load_domain_profile"),
        (init_flow, "create_discovery_workspace"),
        (init_models, "resolve_default_template_root"),
        (init_models, "RealFileSystem"),
    ):
        monkeypatch.setattr(owner, name, refuse)
    return calls


def test_parse_args_requires_target_dir() -> None:
    """Return None after asserting legacy missing target raises SystemExit(2).

    No parameters or filesystem effects; argparse may emit its usage diagnostic.
    """
    with pytest.raises(SystemExit) as stopped:
        mod.parse_args([])
    assert stopped.value.code == 2


def test_parse_args_defaults_template_root_and_force() -> None:
    """Return None after checking historical defaults; no I/O or authority grant."""
    namespace = mod.parse_args(["x"])
    assert namespace.target_dir == Path("x")
    assert namespace.template_root is None
    assert namespace.force is False


def test_parse_args_parses_template_root_and_force(forbid_effects: list[str]) -> None:
    """Use forbid_effects (list[str]) to prove parsed legacy flags remain inert.

    Return None after namespace/no-call assertions; no filesystem access occurs.
    """
    namespace = mod.parse_args(["x", "--template-root", "y", "--force"])
    assert namespace.target_dir == Path("x")
    assert namespace.template_root == Path("y")
    assert namespace.force is True
    assert forbid_effects == []


@pytest.mark.parametrize("exit_code", [0, 1, 2, 3])
def test_main_forwards_explicit_context_and_typed_exit(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    exit_code: int,
) -> None:
    """Preserve fixed command, vector identity and exit_code (int) with no effects.

    monkeypatch (pytest.MonkeyPatch) installs a memory entry; capsys
    (pytest.CaptureFixture[str]) observes extra output. Return None after assertions.
    """
    argv = (
        "--workspace-root",
        "/consumer",
        "--repository-id",
        "consumer",
        "--system-id",
        "legacy",
        "--system-name",
        "Legacy",
        "--role",
        "legacy-source",
        "--production-root",
        "src",
        "--dry-run",
    )
    calls: list[tuple[str, Sequence[str] | None]] = []

    def installed(command: str, arguments: Sequence[str] | None = None) -> int:
        """Record command (str)/arguments (Sequence[str] | None); return int exit.

        Only calls changes; no parsing, I/O or argument mutation occurs.
        """
        calls.append((command, arguments))
        return exit_code

    monkeypatch.setattr(runtime_cli, "run_installed_cli", installed)
    assert mod.main(argv) == exit_code
    assert calls == [("init", argv)] and calls[0][1] is argv
    assert capsys.readouterr() == ("", "")


@pytest.mark.parametrize("argv", [None, ()], ids=["process", "explicit-empty"])
def test_main_retains_installed_argument_selection(
    monkeypatch: pytest.MonkeyPatch, argv: tuple[str, ...] | None
) -> None:
    """Preserve argv (tuple[str, ...] | None) without copying or cwd inference.

    monkeypatch (pytest.MonkeyPatch) supplies a recording entry. Return None after
    exact argument/exit assertions; only test memory changes.
    """
    calls: list[tuple[str, Sequence[str] | None]] = []

    def installed(command: str, arguments: Sequence[str] | None = None) -> int:
        """Record command/arguments (str/Sequence[str] | None); return 3, no I/O."""
        calls.append((command, arguments))
        return 3

    monkeypatch.setattr(runtime_cli, "run_installed_cli", installed)
    assert mod.main(argv) == 3
    assert calls == [("init", argv)] and calls[0][1] is argv


@pytest.mark.parametrize(
    "argv",
    [
        ("/consumer/discovery",),
        ("/consumer/discovery", "--template-root", "/arbitrary"),
        ("/consumer/discovery", "--force"),
        ("--workspace-root", "/consumer", "--template-root", "/arbitrary"),
        ("--workspace-root", "/consumer", "--force"),
        ("--workspace-root", "/consumer", "--source-id", "invented"),
    ],
    ids=[
        "positional",
        "template",
        "force",
        "canonical-template",
        "canonical-force",
        "identity",
    ],
)
def test_ambiguous_init_inputs_refuse_before_effects(
    argv: tuple[str, ...], forbid_effects: list[str], capsys: pytest.CaptureFixture[str]
) -> None:
    """Reject argv (tuple[str, ...]) through the actual installed parser.

    forbid_effects (list[str]) records forbidden ports; capsys
    (pytest.CaptureFixture[str]) captures the typed result. Return None after
    exit/null-context/no-artifact assertions; no providers or legacy I/O run.
    """
    assert mod.main(argv) == 2
    captured = capsys.readouterr()
    payload = json.loads(captured.out)
    assert payload["exit_code"] == 2 and payload["operation"] == "init"
    assert payload["runtime"] is None and payload["input_manifest"] is None
    assert payload["artifacts"] == [] and forbid_effects == []
    assert payload["findings"][0]["code"] == "CLI_ARGUMENTS"
    assert payload["findings"][1]["code"] == "CLI_REQUEST"
    assert "--help" in payload["findings"][0]["next_action"]
    assert "/arbitrary" not in captured.out + captured.err


def test_help_uses_installed_options_without_providers(
    forbid_effects: list[str], capsys: pytest.CaptureFixture[str]
) -> None:
    """Use forbid_effects (list[str])/capsys (pytest.CaptureFixture[str]) in memory.

    Return None after installed help/no-call assertions; only captured output changes.
    """
    assert mod.main(("--help",)) == 0
    captured = capsys.readouterr()
    assert "--workspace-root" in captured.out and "--system-id" in captured.out
    assert "--template-root" not in captured.out and "--force" not in captured.out
    assert captured.err == "" and forbid_effects == []


def test_module_entry_returns_installed_exit(monkeypatch: pytest.MonkeyPatch) -> None:
    """Use monkeypatch (pytest.MonkeyPatch) to assert module SystemExit(3).

    Return None after an in-process module execution; no provider or external I/O
    is invoked, and the imported module cache is restored after the test.
    """

    def installed(command: str, argv: Sequence[str] | None = None) -> int:
        """Require fixed command (str)/default argv; return 3 without I/O."""
        assert command == "init" and argv is None
        return 3

    monkeypatch.setattr(runtime_cli, "run_installed_cli", installed)
    monkeypatch.delitem(sys.modules, mod.__name__)
    with pytest.raises(SystemExit) as stopped:
        runpy.run_module(mod.__name__, run_name="__main__")
    assert stopped.value.code == 3


def test_console_script_registered_in_pyproject() -> None:
    """The `dev.discovery.init` console script is registered in `pyproject.toml`."""
    workspace_root = Path(__file__).resolve().parents[4]
    pyproject_text = (workspace_root / "pyproject.toml").read_text(encoding="utf-8")
    assert (
        '"dev.discovery.init" = "drm_copilot_discovery.cli:main_init"' in pyproject_text
    )


def test_legacy_cli_reports_explicit_v2_migration_without_writes(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    forbid_effects: list[str],
) -> None:
    """Refuse old template/force argv without overwriting an existing memory file.

    monkeypatch (pytest.MonkeyPatch), capsys (pytest.CaptureFixture[str]) and
    forbid_effects (list[str]) isolate/observe boundaries. Return None after typed
    refusal and unchanged memory assertions; no native filesystem is used.
    """
    from tests.scripts.dev_tools.discovery.test_init_flow import (
        FakeFileSystem,
        seed_templates,
    )

    fs, root, target = FakeFileSystem(), Path("/templates"), Path("/consumer/discovery")
    fs.dirs.update((target.parent, target))
    fs.files[target / "existing.txt"] = "retain"
    seed_templates(fs, root)
    before = (dict(fs.files), set(fs.dirs))
    monkeypatch.setattr(init_models, "RealFileSystem", lambda: fs)

    assert mod.main([str(target), "--template-root", str(root), "--force"]) == 2
    payload = json.loads(capsys.readouterr().out)
    assert payload["findings"][0]["code"] == "CLI_ARGUMENTS"
    assert (fs.files, fs.dirs) == before and forbid_effects == []
