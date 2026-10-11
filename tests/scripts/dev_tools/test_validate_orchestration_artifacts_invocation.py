"""Invocation-contract tests for the orchestration-artifact dispatcher (issue #798).

Purpose:
    Pin the two supported invocation forms of
    ``scripts/dev_tools/validate_orchestration_artifacts.py``: the module form
    (``python -m scripts.dev_tools.validate_orchestration_artifacts``) and the
    file-path form (``python scripts/dev_tools/validate_orchestration_artifacts.py``).

    ``runpy.run_path`` reproduces the file-path form in process: it executes the
    file with no package context, as the interpreter does for a script path.
    Before each file-path run, every ``sys.path`` entry that names the
    repository root or can supply a regular ``scripts`` package is removed, and
    ``scripts`` plus every ``scripts.*`` module is evicted from ``sys.modules``,
    so the run can import the first-party package only through the dispatcher's
    own bootstrap. The second filter covers a shared virtual environment whose
    editable-install entry names another checkout of this repository. Without
    the bootstrap the run raises ``ModuleNotFoundError``.

Invariants / Constraints:
    No child process and no temporary file is used. ``sys.path`` and the
    original ``scripts.*`` module objects are restored after every isolated run.
"""

from __future__ import annotations

import os
import runpy
import sys
from contextlib import contextmanager
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

import scripts.dev_tools.validate_orchestration_artifacts as dispatcher

if TYPE_CHECKING:
    from collections.abc import Generator
    from types import ModuleType

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
REPO_ROOT = Path(__file__).resolve().parents[3]
SCRIPT = REPO_ROOT / "scripts" / "dev_tools" / "validate_orchestration_artifacts.py"
MODULE_NAME = "scripts.dev_tools.validate_orchestration_artifacts"
FIXTURE = (
    REPO_ROOT
    / "tests"
    / "fixtures"
    / "orchestrator_state_remediation_loop_backcompat"
    / "no_remediation_loop.json"
)


def resolves_to_repo_root(entry: str) -> bool:
    """Return whether a ``sys.path`` entry names the repository root.

    An empty entry names the working directory, as the import system reads it.
    """

    resolved = Path(entry or ".").resolve()
    return os.path.normcase(str(resolved)) == os.path.normcase(str(REPO_ROOT))


def is_scripts_module(name: str) -> bool:
    """Return whether a ``sys.modules`` key belongs to the ``scripts`` package."""

    return name == "scripts" or name.startswith("scripts.")


def provides_scripts_package(entry: str) -> bool:
    """Return whether a ``sys.path`` entry can supply a regular ``scripts`` package.

    A shared virtual environment can carry an editable-install entry that names
    another checkout of this repository; that entry would satisfy the import.
    """

    return (Path(entry or ".") / "scripts" / "__init__.py").is_file()


def repo_root_entry_count() -> int:
    """Return how many ``sys.path`` entries name the repository root."""

    return sum(1 for entry in sys.path if resolves_to_repo_root(entry))


@contextmanager
def isolated_import_state() -> Generator[None, None, None]:
    """Remove every route to the ``scripts`` package, then restore it on exit.

    ``sys.path`` is rebound to a copy that omits each entry naming the
    repository root and each entry that can supply a regular ``scripts``
    package, and ``scripts`` plus every ``scripts.*`` module is removed from
    ``sys.modules``. On exit the original ``sys.path`` list object is
    rebound, every ``scripts.*`` module imported inside the block is discarded,
    and the original module objects are put back.
    """

    original_path = sys.path
    saved_modules: dict[str, ModuleType] = {
        name: module for name, module in sys.modules.items() if is_scripts_module(name)
    }
    sys.path = [
        entry
        for entry in original_path
        if not resolves_to_repo_root(entry) and not provides_scripts_package(entry)
    ]
    for name in saved_modules:
        del sys.modules[name]
    try:
        yield
    finally:
        sys.path = original_path
        for name in [name for name in sys.modules if is_scripts_module(name)]:
            del sys.modules[name]
        sys.modules.update(saved_modules)


def run_file_path_form(monkeypatch: pytest.MonkeyPatch, arguments: list[str]) -> object:
    """Run the dispatcher by file path as ``__main__`` and return its exit code."""

    monkeypatch.setattr(sys, "argv", [str(SCRIPT), *arguments])
    with pytest.raises(SystemExit) as exit_info:
        runpy.run_path(str(SCRIPT), run_name="__main__")
    return exit_info.value.code


def test_file_path_invocation_help_exits_zero(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """File-path invocation prints usage and exits 0 without a package context.

    Before the bootstrap existed, this run raised ModuleNotFoundError.
    """

    # Arrange / Act
    with isolated_import_state():
        exit_code = run_file_path_form(monkeypatch, ["--help"])

    # Assert
    captured = capsys.readouterr()
    assert exit_code == 0, f"--help must exit 0, got {exit_code!r}"
    assert "orchestrator-state" in captured.out, "usage must list orchestrator-state"


def test_file_path_invocation_validates_committed_fixture(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """File-path invocation matches main() in exit code, stdout, and stderr."""

    # Arrange
    arguments = ["orchestrator-state", str(FIXTURE)]
    expected_code = dispatcher.main(arguments)
    expected = capsys.readouterr()

    # Act
    with isolated_import_state():
        exit_code = run_file_path_form(monkeypatch, arguments)

    # Assert
    actual = capsys.readouterr()
    assert exit_code == expected_code, "both forms must return the same exit code"
    assert actual.out == expected.out, "both forms must write the same stdout"
    assert actual.err == expected.err, "both forms must write the same stderr"


@pytest.mark.filterwarnings("ignore:.*found in sys.modules.*:RuntimeWarning")
def test_module_invocation_leaves_sys_path_unchanged(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    """Module invocation exits 0 on --help and leaves sys.path as it found it."""

    # Arrange
    monkeypatch.setattr(sys, "argv", [MODULE_NAME, "--help"])
    snapshot = list(sys.path)

    # Act
    with pytest.raises(SystemExit) as exit_info:
        runpy.run_module(MODULE_NAME, run_name="__main__")

    # Assert
    captured = capsys.readouterr()
    assert exit_info.value.code == 0, "module-form --help must exit 0"
    assert "orchestrator-state" in captured.out, "usage must list orchestrator-state"
    assert sys.path == snapshot, "module invocation must not modify sys.path"


def test_file_path_bootstrap_appends_repo_root_once(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The bootstrap appends the repository root exactly once, at the end."""

    # Arrange / Act
    with isolated_import_state():
        entries_before = repo_root_entry_count()
        exit_code = run_file_path_form(monkeypatch, ["--help"])
        entries_after = repo_root_entry_count()
        last_entry = sys.path[-1]

    # Assert
    assert entries_before == 0, "isolation must remove the repository root first"
    assert exit_code == 0, f"--help must exit 0, got {exit_code!r}"
    assert entries_after == 1, f"expected one root entry, found {entries_after}"
    assert resolves_to_repo_root(last_entry), "the root must be appended last"
