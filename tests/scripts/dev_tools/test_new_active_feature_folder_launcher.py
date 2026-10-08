"""Launcher-seam tests for new_active_feature_folder_io."""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools import new_active_feature_folder_io as io_mod

if TYPE_CHECKING:
    from collections.abc import Callable

resolve_code_cli: Callable[
    [Callable[[str], str | None] | None, Callable[[str], str | None] | None],
    str | None,
] = vars(io_mod)["_resolve_code_cli"]
is_insiders_session: Callable[[Callable[[str], str | None] | None], bool] = vars(
    io_mod
)["_is_insiders_session"]
insiders_signal_names: tuple[str, ...] = vars(io_mod)["_INSIDERS_SIGNAL_NAMES"]
env_lookup: Callable[[str], str | None] = vars(io_mod)["_env_lookup"]


def _clear_signal_variables(monkeypatch: pytest.MonkeyPatch) -> None:
    """Remove every Insiders signal variable so the session reads as non-Insiders."""
    for name in insiders_signal_names:
        monkeypatch.delenv(name, raising=False)


def _patch_launcher_seams(
    monkeypatch: pytest.MonkeyPatch, cli_path: str
) -> list[list[str]]:
    """Patch PATH lookup and subprocess execution; return the recorded commands."""
    launched: list[list[str]] = []

    def fake_run(cmd: list[str], check: bool) -> None:  # noqa: ARG001
        launched.append(cmd)

    def fake_which(_name: str) -> str:
        return cli_path

    monkeypatch.setattr(io_mod.shutil, "which", fake_which)
    monkeypatch.setattr(io_mod.subprocess, "run", fake_run)
    _clear_signal_variables(monkeypatch)
    return launched


def test_launcher_converts_backslashes_to_forward_slashes(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Backslash separators in a file path are passed to the CLI as forward slashes."""
    launched = _patch_launcher_seams(monkeypatch, "/usr/bin/code")

    result = io_mod.default_code_launcher([Path("docs\\a.md")])

    assert result is True
    assert launched == [["/usr/bin/code", "--reuse-window", "docs/a.md"]]


def test_launcher_passes_every_file_after_reuse_window(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Every file argument follows --reuse-window in the supplied order."""
    launched = _patch_launcher_seams(monkeypatch, "/usr/bin/code")

    result = io_mod.default_code_launcher([Path("docs\\a.md"), Path("docs\\b.md")])

    assert result is True
    assert launched == [["/usr/bin/code", "--reuse-window", "docs/a.md", "docs/b.md"]]


def test_launcher_cli_fallback_uses_code_when_insiders_cli_missing() -> None:
    """An Insiders session falls back to code when code-insiders does not resolve."""
    probed: list[str] = []

    def which_lookup(name: str) -> str | None:
        probed.append(name)
        return "/usr/bin/code" if name == "code" else None

    def insiders_env(_name: str) -> str | None:
        return "1.110.0-insider"

    resolved = resolve_code_cli(which_lookup, insiders_env)

    assert resolved == "/usr/bin/code"
    assert probed == ["code-insiders", "code"]


def test_launcher_cli_fallback_uses_insiders_when_code_missing() -> None:
    """A non-Insiders session falls back to code-insiders when code does not resolve."""
    probed: list[str] = []

    def which_lookup(name: str) -> str | None:
        probed.append(name)
        return "/usr/bin/code-insiders" if name == "code-insiders" else None

    def empty_env(_name: str) -> str | None:
        return None

    resolved = resolve_code_cli(which_lookup, empty_env)

    assert resolved == "/usr/bin/code-insiders"
    assert probed == ["code", "code-insiders"]


@pytest.mark.parametrize("signal_name", insiders_signal_names)
def test_launcher_insiders_detected_for_each_signal_variable(signal_name: str) -> None:
    """Each supported signal variable alone marks the session as Insiders."""

    def signal_env(name: str) -> str | None:
        return "1.110.0-insider" if name == signal_name else None

    assert is_insiders_session(signal_env) is True


def test_launcher_insiders_not_detected_without_insider_marker() -> None:
    """Signal values lacking the insider marker do not mark the session as Insiders."""

    def plain_env(_name: str) -> str | None:
        return "vscode"

    assert is_insiders_session(plain_env) is False


def test_launcher_default_env_lookup_returns_value_when_set(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The default environment lookup returns a non-blank value unchanged."""
    monkeypatch.setenv("LAUNCHER_TEST_SIGNAL", "present")

    assert env_lookup("LAUNCHER_TEST_SIGNAL") == "present"


def test_launcher_default_env_lookup_returns_none_when_blank(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The default environment lookup treats a whitespace-only value as unset."""
    monkeypatch.setenv("LAUNCHER_TEST_SIGNAL", "   ")

    assert env_lookup("LAUNCHER_TEST_SIGNAL") is None
