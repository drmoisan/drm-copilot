"""Unit tests for the compatibility proxies and shutdown handler of the executor CLI.

The proxies forward to optional helpers captured from the Copilot runtime module
at import time; the shutdown handler sets a module flag and releases the active
executor lock. Module state is replaced through ``monkeypatch`` so each test
restores it on teardown.
"""

from __future__ import annotations

import signal
from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools.atomic_executor import cli

if TYPE_CHECKING:
    from collections.abc import Callable

    import pytest

# Private proxies are read through the module namespace so the tests call the
# real functions without a type-checker suppression.
_clean_session_file: Callable[..., None] = vars(cli)["_clean_session_file"]
_supports_continue_sessions: Callable[[], bool] = vars(cli)[
    "_supports_continue_sessions"
]
_handle_shutdown_signal: Callable[[int, object], None] = vars(cli)[
    "_handle_shutdown_signal"
]


def test_clean_session_file_is_noop_without_original(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Without a captured cleanup helper the proxy returns without error."""
    monkeypatch.setattr(cli, "_ORIGINAL_CLEAN_FN", None)

    assert _clean_session_file("session.json", force=True) is None


def test_clean_session_file_forwards_arguments_to_original(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The proxy forwards positional and keyword arguments unchanged."""
    calls: list[tuple[tuple[object, ...], dict[str, object]]] = []

    def fake_clean(*args: object, **kwargs: object) -> None:
        calls.append((args, kwargs))

    monkeypatch.setattr(cli, "_ORIGINAL_CLEAN_FN", fake_clean)

    _clean_session_file("session.json", force=True)

    assert calls == [(("session.json",), {"force": True})]


def test_supports_continue_sessions_is_false_without_original(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Without a captured capability check the proxy reports no support."""
    monkeypatch.setattr(cli, "_ORIGINAL_SUPPORTS_FN", None)

    assert _supports_continue_sessions() is False


def test_supports_continue_sessions_returns_original_result(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The proxy coerces the captured check's result to a boolean."""
    monkeypatch.setattr(cli, "_ORIGINAL_SUPPORTS_FN", lambda: 1)

    assert _supports_continue_sessions() is True


def test_handle_shutdown_signal_sets_flag_without_lock(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """A signal with no active lock sets the flag and releases nothing."""
    # Arrange: start from a clean flag and record any lock release.
    released: list[Path] = []
    monkeypatch.setattr(cli, "_shutdown_requested", False)
    monkeypatch.setattr(cli, "_active_lock_path", None)
    monkeypatch.setattr(cli, "release_executor_lock", released.append)

    # Act
    _handle_shutdown_signal(signal.SIGINT.value, None)

    # Assert
    assert cli.is_shutdown_requested() is True
    assert released == []
    assert "Received SIGINT, shutting down gracefully" in capsys.readouterr().out


def test_handle_shutdown_signal_releases_active_lock(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A signal with an active lock releases that lock immediately."""
    released: list[Path] = []
    lock_path = Path("workspace/.agent_logs/executor.lock")
    monkeypatch.setattr(cli, "_shutdown_requested", False)
    monkeypatch.setattr(cli, "_active_lock_path", lock_path)
    monkeypatch.setattr(cli, "release_executor_lock", released.append)

    _handle_shutdown_signal(signal.SIGTERM.value, None)

    assert cli.is_shutdown_requested() is True
    assert released == [lock_path]
