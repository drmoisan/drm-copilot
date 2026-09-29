"""Python reference lane of the parallel abandon parity corpus (issue #763).

Why this test exists:
    ``.claude/lib/bash/abandon-parallel-item.sh`` is the bundled destination-runtime
    port of ``scripts/dev_tools/parallel_mutation_abandon_cli.py``. The committed
    corpus ``tests/fixtures/parallel_abandon/*.json`` is the single artifact that
    pins the two implementations together: this lane runs every fixture through
    the Python reference, and ``tests/shell/parallel_abandon_parity.bats`` runs the
    same fixtures through the bash port. Neither lane may relax an expectation
    without the other observing the change.

How it runs the reference:
    ``parallel_mutation_abandon_cli.main`` is called with an injected runner that
    records each side-effect argument vector and returns the fixture's
    ``shim_exit`` code for the executable. When the fixture names a
    ``missing_executable``, the runner raises ``AbandonSideEffectError`` with exit
    code -1 before recording anything, mirroring ``run_with_subprocess`` when the
    executable is not on PATH. No process is started and no file other than the
    committed corpus is read; no temporary file is created.

Declared divergence classes (also listed in the bats lane header):
    - argparse usage text: a fixture whose ``stderr_mode`` is ``usage`` compares
      the exit code only, because the bash port reports usage errors with its own
      one-line message.
    - option abbreviations: argparse accepts a unique option prefix and the bash
      port rejects it; such a fixture declares ``divergence`` and carries a
      ``python_expected`` block that this lane asserts instead of ``expected``.
    - The bash port additionally accepts only canonical decimal integers for
      ``--item`` and ``--pr``, treats ``-h`` and ``--help`` as unknown options,
      and treats an option value beginning with ``--`` as a missing value. All
      three are usage errors (exit 2) and no corpus fixture exercises them.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools import parallel_mutation_abandon_cli as cli

if TYPE_CHECKING:
    from collections.abc import Sequence

# Repo root, resolved from this module: tests/scripts/dev_tools/<file> is three
# levels below it.
REPO_ROOT = Path(__file__).resolve().parents[3]
CORPUS_DIR = REPO_ROOT / "tests/fixtures/parallel_abandon"

# Floor on corpus size, so a broken glob cannot make the parametrized lane assert
# nothing.
MINIMUM_FIXTURE_COUNT = 9

# Every abandon case the spec's test strategy requires the corpus to cover.
REQUIRED_CASES = frozenset(
    {
        "success",
        "refuse-detach-disposition",
        "refuse-missing-confirmation",
        "gh-close-fails",
        "git-remove-fails",
        "gh-not-on-path",
        "unknown-option",
        "option-abbreviation",
        "joined-option-form",
    }
)


def _fixture_paths() -> list[Path]:
    """Return the committed corpus fixtures in name order.

    Returns:
        list[Path]: Every ``*.json`` file in the corpus directory, sorted so the
        parametrized node IDs are stable.
    """

    return sorted(CORPUS_DIR.glob("*.json"))


def _load_fixture(path: Path) -> dict[str, object]:
    """Read one corpus fixture as a JSON object.

    Args:
        path (Path): The fixture file.

    Returns:
        dict[str, object]: The parsed fixture.

    Raises:
        AssertionError: If the fixture root is not a JSON object.
    """

    document: object = json.loads(path.read_text(encoding="utf-8"))
    assert isinstance(document, dict), f"{path.name} must hold one JSON object"
    return cast("dict[str, object]", document)


class _RecordingRunner:
    """Injected command runner that records side effects instead of running them.

    Purpose:
        Stand in for ``run_with_subprocess`` so the reference CLI's side-effect
        ordering and failure handling are observable without starting a process.

    Usage:
        Construct with the fixture's shim exit codes and missing executable, pass
        the instance as ``runner`` to ``main``, then read ``calls``.

    Side Effects:
        Appends to ``calls`` on each invocation; nothing else.

    Attributes:
        calls (list[list[str]]): The recorded argument vectors, in call order.
    """

    def __init__(
        self, shim_exit: dict[str, int], missing_executable: str | None
    ) -> None:
        """Store the per-executable exit codes and the unresolvable executable.

        Args:
            shim_exit (dict[str, int]): Exit code returned for each executable.
            missing_executable (str | None): Executable treated as absent from
                PATH, or ``None`` when both are present.
        """

        self._shim_exit = shim_exit
        self._missing_executable = missing_executable
        self.calls: list[list[str]] = []

    def __call__(self, argv: Sequence[str]) -> int:
        """Record one command vector and return the fixture's exit code for it.

        Args:
            argv (Sequence[str]): The command vector, executable name first.

        Returns:
            int: The fixture's exit code for that executable.

        Raises:
            AbandonSideEffectError: With exit code -1, before anything is recorded,
                when the executable is the fixture's missing executable.
        """

        if argv[0] == self._missing_executable:
            raise cli.AbandonSideEffectError(argv, -1)
        self.calls.append(list(argv))
        return self._shim_exit[argv[0]]


def _run_reference(fixture: dict[str, object]) -> tuple[int, list[list[str]]]:
    """Run the Python reference over one fixture's argument vector.

    Args:
        fixture (dict[str, object]): The parsed fixture.

    Returns:
        tuple[int, list[list[str]]]: The exit code, taken from ``main`` or from the
        ``SystemExit`` argparse raises on a usage error, and the recorded calls.
    """

    runner = _RecordingRunner(
        cast("dict[str, int]", fixture["shim_exit"]),
        cast("str | None", fixture["missing_executable"]),
    )
    argv = cast("list[str]", fixture["argv"])
    # argparse reports a usage error by raising SystemExit; its code is the exit
    # code the process would have returned.
    try:
        exit_code = cli.main(argv, runner=runner)
    except SystemExit as exit_request:
        exit_code = cast("int", exit_request.code)
    return exit_code, runner.calls


def test_abandon_corpus_meets_floor() -> None:
    """The committed corpus holds at least the declared number of fixtures."""

    # Arrange / Act
    count = len(_fixture_paths())

    # Assert
    assert (
        count >= MINIMUM_FIXTURE_COUNT
    ), f"Expected at least {MINIMUM_FIXTURE_COUNT} abandon fixtures, found {count}"


def test_abandon_corpus_covers_every_named_case() -> None:
    """Every abandon case the spec requires has a fixture of that name."""

    # Arrange / Act
    names = {path.stem for path in _fixture_paths()}

    # Assert
    missing = sorted(REQUIRED_CASES - names)
    assert not missing, f"Abandon corpus lacks the required cases: {missing}"


@pytest.mark.parametrize(
    "fixture_path", _fixture_paths(), ids=lambda path: cast("Path", path).stem
)
def test_reference_matches_abandon_fixture(
    fixture_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    """The Python reference reproduces one fixture's exit code, stderr, and calls."""

    # Arrange: a fixture that declares a divergence is asserted against its
    # Python-specific expectation; every other fixture against the shared one.
    fixture = _load_fixture(fixture_path)
    assert fixture["name"] == fixture_path.stem, "fixture name must equal its stem"
    key = "python_expected" if fixture["divergence"] is not None else "expected"
    expected = cast("dict[str, object]", fixture[key])

    # Act
    exit_code, calls = _run_reference(fixture)
    captured = capsys.readouterr()

    # Assert: exit code, ordered side-effect argv, and an empty stdout always.
    assert exit_code == expected["exit_code"], f"{fixture_path.stem}: exit {exit_code}"
    assert calls == expected["calls"], f"{fixture_path.stem}: calls {calls}"
    assert captured.out == "", f"{fixture_path.stem}: stdout {captured.out!r}"
    # Apply the fixture's stderr mode: none requires an empty stderr, exact
    # compares the single reference line, and usage compares the exit code only.
    mode = expected["stderr_mode"]
    if mode == "none":
        assert captured.err == "", f"{fixture_path.stem}: stderr {captured.err!r}"
    elif mode == "exact":
        assert captured.err.splitlines() == [
            expected["stderr"]
        ], f"{fixture_path.stem}: stderr {captured.err!r}"
    else:
        assert mode == "usage", f"{fixture_path.stem}: unknown stderr_mode {mode!r}"
