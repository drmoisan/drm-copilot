"""Python reference lane of the parallel remove parity corpus (issue #791).

Why this test exists:
    ``.claude/lib/bash/remove-parallel-item.sh`` is the bundled destination-runtime
    port of ``decide_removal``, ``recolor_unstarted``, and ``build_remove_entry``
    from ``scripts/dev_tools/parallel_mutation_protocol.py``. The committed corpus
    ``tests/fixtures/parallel_mutation_remove/*.json`` is the single artifact that
    pins the two implementations together: this lane runs every fixture through
    the Python functions, and ``tests/shell/parallel_mutation_remove_parity.bats``
    runs the same fixtures through the bash port. Neither lane may relax an
    expectation without the other observing the change.

How it runs the reference:
    Each fixture's ``argv`` is paired into ``--option value`` arguments and mapped
    onto a direct call of the matching Python function. A success is rendered as
    compact JSON in the field order of the corpus literals; a rejection is
    compared through the exception message. No process is started, no file other
    than the committed corpus is read, and no temporary file is created. The
    ``at`` timestamp comes from a fixed clock and is replaced in the rendering by
    the fixture's ``--at`` string.

Declared divergences (also listed in the script header and in the bats lane):
    1. A `--removal-disposition` value outside `detach abandon` is a usage error
       (exit 2) instead of the Python `UnknownEnumMemberError` text, which lists
       merge-status members (`_parallel_mutation_errors.py:192`, spec D5).
    2. `at` is a caller-supplied string instead of a `datetime`.
    3. Option abbreviations are rejected.

No corpus fixture exercises a usage error; usage errors are covered by the bats
unit suite only.
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import cast

import pytest

from scripts.dev_tools._parallel_mutation_models import (
    ItemRecord,
    ParallelMutationError,
    RemovalDecision,
)
from scripts.dev_tools.parallel_cohort_computation import ParallelCohortInputError
from scripts.dev_tools.parallel_mutation_protocol import (
    build_remove_entry,
    decide_removal,
    recolor_unstarted,
)

# Repo root, resolved from this module: tests/scripts/dev_tools/<file> is three
# levels below it.
REPO_ROOT = Path(__file__).resolve().parents[3]
CORPUS_DIR = REPO_ROOT / "tests/fixtures/parallel_mutation_remove"

# Floor on corpus size, so a broken glob cannot make the parametrized lane assert
# nothing.
MINIMUM_FIXTURE_COUNT = 15

# Every remove case the plan's parity corpus declares, by file stem.
REQUIRED_CASES = frozenset(
    {
        "decide-scheduled",
        "decide-in-flight-detach",
        "decide-in-flight-abandon",
        "decide-in-flight-no-disposition",
        "decide-merged",
        "decide-unknown-item",
        "recolor-no-pinned-edge",
        "recolor-pinned-edge-offset",
        "recolor-empty-unstarted",
        "recolor-overlap",
        "recolor-negative-current-cohort",
        "entry-unstarted-recompute",
        "entry-in-flight-detach",
        "entry-negative-generation",
        "entry-disposition-on-unstarted",
    }
)

# The three subcommands of the bash entry point.
SUBCOMMANDS = ("decide", "recolor", "entry")


def _fixed_clock() -> datetime:
    """Return the fixed instant used as the reference clock seam.

    Returns:
        datetime: 2026-10-08T14:00 UTC; its value is replaced in the rendering by
        the fixture's ``--at`` string, so it only has to be deterministic.
    """

    return datetime(2026, 10, 8, 14, 0, tzinfo=timezone.utc)


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


def _expected(fixture: dict[str, object]) -> dict[str, object]:
    """Return a fixture's ``expected`` block.

    Args:
        fixture (dict[str, object]): The parsed fixture.

    Returns:
        dict[str, object]: The expected exit code, stdout, and stderr.
    """

    return cast("dict[str, object]", fixture["expected"])


def _options(argv: list[str]) -> dict[str, str]:
    """Pair the arguments after the subcommand into an option mapping.

    Args:
        argv (list[str]): The fixture's argument vector, subcommand first.

    Returns:
        dict[str, str]: Each ``--option`` name mapped to the value that follows.
    """

    rest = argv[1:]
    assert len(rest) % 2 == 0, f"argv must pair options with values: {argv}"
    return {rest[index]: rest[index + 1] for index in range(0, len(rest), 2)}


def _keys(text: str) -> list[int]:
    """Parse a whitespace-separated key list.

    Args:
        text (str): The option value, possibly empty.

    Returns:
        list[int]: The keys in the supplied order.
    """

    return [int(token) for token in text.split()]


def _edges(text: str) -> list[tuple[int, int]]:
    """Parse a whitespace-separated ``a:b`` edge list.

    Args:
        text (str): The option value, possibly empty.

    Returns:
        list[tuple[int, int]]: The edges in the supplied order.
    """

    pairs = (token.split(":") for token in text.split())
    return [(int(first), int(second)) for first, second in pairs]


def _compact(document: dict[str, object]) -> str:
    """Render a mapping as compact JSON, preserving insertion order.

    Args:
        document (dict[str, object]): The mapping to render.

    Returns:
        str: The JSON text with no insignificant whitespace.
    """

    return json.dumps(document, separators=(",", ":"))


def _run_decide(options: dict[str, str]) -> str:
    """Run ``decide_removal`` for one fixture and render the decision.

    Args:
        options (dict[str, str]): The fixture's paired options.

    Returns:
        str: The compact JSON decision.
    """

    item = int(options["--item"])
    state = options.get("--state")
    items = {} if state is None else {item: ItemRecord(issue_num=item, state=state)}
    decision = decide_removal(item, items, options.get("--removal-disposition"))
    return _compact(
        {
            "item_key": decision.item_key,
            "prior_state": decision.prior_state,
            "new_state": decision.new_state,
            "disposition": decision.disposition,
            "triggers_recompute": decision.triggers_recompute,
        }
    )


def _run_recolor(options: dict[str, str]) -> str:
    """Run ``recolor_unstarted`` for one fixture and render the result.

    Args:
        options (dict[str, str]): The fixture's paired options.

    Returns:
        str: The compact JSON result, assignment keys ascending numerically.
    """

    result = recolor_unstarted(
        _keys(options["--unstarted"]),
        _edges(options.get("--edges", "")),
        frozenset(_keys(options["--pinned"])),
        int(options["--generation"]),
        current_cohort=int(options["--current-cohort"]),
        highest_pinned_cohort=int(options["--highest-pinned-cohort"]),
    )
    assignments = {
        str(key): result.cohort_assignments[key]
        for key in sorted(result.cohort_assignments)
    }
    return _compact(
        {"cohort_assignments": assignments, "generation": result.generation}
    )


def _run_entry(options: dict[str, str]) -> str:
    """Run ``build_remove_entry`` for one fixture and render the record.

    Args:
        options (dict[str, str]): The fixture's paired options.

    Returns:
        str: The compact JSON record in F3 field order, ``at`` taken from the
        fixture's ``--at`` string.
    """

    decision = RemovalDecision(
        int(options["--item"]),
        options["--prior-state"],
        "withdrawn",
        options.get("--removal-disposition"),
        options["--recompute"] == "true",
    )
    entry = build_remove_entry(
        decision,
        current_generation=int(options["--generation"]),
        clock=_fixed_clock,
    )
    return _compact(
        {
            "op": entry.op,
            "item_key": entry.item_key,
            "at": options["--at"],
            "prior_state": entry.prior_state,
            "new_state": entry.new_state,
            "disposition": entry.disposition,
            "recolor_generation": entry.recolor_generation,
        }
    )


def _run_reference(fixture: dict[str, object]) -> tuple[int, str | None, str | None]:
    """Run the Python reference over one fixture.

    Args:
        fixture (dict[str, object]): The parsed fixture.

    Returns:
        tuple[int, str | None, str | None]: The exit code (0 on success, 1 on a
        rejection), the stdout literal or None, and the stderr literal or None.
    """

    argv = cast("list[str]", fixture["argv"])
    options = _options(argv)
    runners = {"decide": _run_decide, "recolor": _run_recolor, "entry": _run_entry}
    try:
        stdout = runners[argv[0]](options)
    except (ParallelMutationError, ParallelCohortInputError) as rejection:
        return 1, None, str(rejection)
    return 0, stdout, None


def test_corpus_meets_fixture_floor() -> None:
    """The committed corpus holds at least the declared number of fixtures."""

    # Arrange / Act
    count = len(_fixture_paths())

    # Assert: an empty corpus fails here rather than passing vacuously.
    assert (
        count >= MINIMUM_FIXTURE_COUNT
    ), f"Expected at least {MINIMUM_FIXTURE_COUNT} remove fixtures, found {count}"


def test_corpus_matches_required_cases() -> None:
    """The corpus stem set equals the declared case set exactly."""

    # Arrange / Act
    names = frozenset(path.stem for path in _fixture_paths())

    # Assert
    assert names == REQUIRED_CASES, (
        f"missing: {sorted(REQUIRED_CASES - names)}; "
        f"unexpected: {sorted(names - REQUIRED_CASES)}"
    )


def test_corpus_has_success_and_rejection_per_subcommand() -> None:
    """Each subcommand has at least one exit-0 and one exit-1 fixture."""

    # Arrange
    seen: set[tuple[str, object]] = set()

    # Act
    for path in _fixture_paths():
        fixture = _load_fixture(path)
        seen.add((cast("str", fixture["subcommand"]), _expected(fixture)["exit_code"]))

    # Assert
    for subcommand in SUBCOMMANDS:
        for exit_code in (0, 1):
            assert (
                subcommand,
                exit_code,
            ) in seen, f"no {subcommand} fixture with exit code {exit_code}"


@pytest.mark.parametrize(
    "fixture_path", _fixture_paths(), ids=lambda path: cast("Path", path).stem
)
def test_python_reference_reproduces_fixture(fixture_path: Path) -> None:
    """The Python reference reproduces one fixture's exit, stdout, and stderr."""

    # Arrange
    fixture = _load_fixture(fixture_path)
    assert fixture["case"] == fixture_path.stem, "fixture case must equal its stem"
    expected = _expected(fixture)

    # Act
    exit_code, stdout, stderr = _run_reference(fixture)

    # Assert
    assert exit_code == expected["exit_code"], f"{fixture_path.stem}: exit {exit_code}"
    assert stdout == expected["stdout"], f"{fixture_path.stem}: stdout {stdout!r}"
    assert stderr == expected["stderr"], f"{fixture_path.stem}: stderr {stderr!r}"
