"""Python reference lane of the parallel run-mutation parity corpus (issue #890).

Why this test exists:
    ``.claude/lib/bash/mutate-parallel-run.sh`` is the bundled destination-runtime
    port of ``decide_admission``, ``recolor_unstarted``, ``build_add_entry``,
    ``decide_close``, ``build_close_entry``, and ``build_requeue_entry`` from
    ``scripts/dev_tools/parallel_mutation_protocol.py``. The committed corpus
    ``tests/fixtures/parallel_mutation_run/*.json`` is the single artifact that
    pins the two implementations together: this lane runs every fixture through
    the Python functions, and ``tests/shell/parallel_mutation_run_parity.bats``
    runs the same fixtures through the bash port. Neither lane may relax an
    expectation without the other observing the change.

How it runs the reference:
    Each fixture's ``argv`` is paired into ``--option value`` arguments and mapped
    onto a direct call of the matching Python function. A success is rendered as
    compact JSON in the field order of the corpus literals; a rejection is
    compared through the exception message. ``close`` builds one ``ItemRecord``
    per ``<key>:<state>`` token in argv order and renders a normal return as
    ``{"close_permitted":true}``. No process is started, no file other than the
    committed corpus is read, and no temporary file is created. The ``at``
    timestamp comes from a fixed clock and is replaced in the rendering by the
    fixture's ``--at`` string.

Declared divergences (also listed in the script header and in the bats lane):
    1. A duplicate key in ``close --items`` is a usage error (exit 2); the Python
       mapping would silently keep the last record for that key.
    2. ``at`` is a caller-supplied string instead of a ``datetime``.
    3. Option abbreviations are rejected.
    4. ``admit`` has no rejection branch, in either implementation, so its
       fixtures are success cases only.

No corpus fixture exercises a usage error; usage errors are covered by the bats
unit suite only.
"""

from __future__ import annotations

import json
from datetime import UTC, datetime
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools._parallel_mutation_models import (
    ItemRecord,
    MutationEntry,
    ParallelMutationError,
)
from scripts.dev_tools.parallel_cohort_computation import ParallelCohortInputError
from scripts.dev_tools.parallel_mutation_protocol import (
    build_add_entry,
    build_close_entry,
    build_requeue_entry,
    decide_admission,
    decide_close,
    recolor_unstarted,
)

if TYPE_CHECKING:
    from collections.abc import Callable

# Repo root, resolved from this module: tests/scripts/dev_tools/<file> is three
# levels below it.
REPO_ROOT = Path(__file__).resolve().parents[3]
CORPUS_DIR = REPO_ROOT / "tests/fixtures/parallel_mutation_run"

# Floor on corpus size, so a broken glob cannot make the parametrized lane assert
# nothing.
MINIMUM_FIXTURE_COUNT = 21

# Every run-mutation case the plan's parity corpus declares, by file stem.
REQUIRED_CASES = frozenset(
    {
        "admit-no-conflict",
        "admit-conflict-in-flight",
        "admit-conflict-scheduled-member",
        "admit-conflict-outside-cohort",
        "recolor-pinned-edge-offset",
        "recolor-overlap",
        "add-entry-admit",
        "add-entry-deferred",
        "add-entry-deferred-generation-minus-one",
        "add-entry-negative-generation",
        "add-entry-non-positive-item",
        "close-permitted",
        "close-in-flight",
        "close-unknown-state",
        "close-non-positive-key",
        "close-entry",
        "close-entry-negative-generation",
        "requeue-entry",
        "requeue-entry-generation-minus-one",
        "requeue-entry-negative-generation",
        "requeue-entry-non-positive-item",
    }
)

# The subcommands that have a rejection branch, each needing an exit-0 and an
# exit-1 fixture. ``admit`` has no rejection branch and is checked separately.
REJECTING_SUBCOMMANDS = (
    "recolor",
    "add-entry",
    "close",
    "close-entry",
    "requeue-entry",
)


def _fixed_clock() -> datetime:
    """Return the fixed instant used as the reference clock seam.

    Returns:
        datetime: 2026-10-11T08:29 UTC; its value is replaced in the rendering by
        the fixture's ``--at`` string, so it only has to be deterministic.
    """

    return datetime(2026, 10, 11, 8, 29, tzinfo=UTC)


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


def _render_entry(entry: MutationEntry, at: str) -> str:
    """Render one mutation entry in F3 field order with a caller ``at`` string.

    Args:
        entry (MutationEntry): The constructed entry.
        at (str): The fixture's ``--at`` string, replacing the clock value.

    Returns:
        str: The compact JSON record.
    """

    return _compact(
        {
            "op": entry.op,
            "item_key": entry.item_key,
            "at": at,
            "prior_state": entry.prior_state,
            "new_state": entry.new_state,
            "disposition": entry.disposition,
            "recolor_generation": entry.recolor_generation,
        }
    )


def _run_admit(options: dict[str, str]) -> str:
    """Run ``decide_admission`` for one fixture and render the decision.

    Args:
        options (dict[str, str]): The fixture's paired options.

    Returns:
        str: The compact JSON decision.
    """

    decision = decide_admission(
        int(options["--candidate"]),
        _edges(options.get("--edges", "")),
        frozenset(_keys(options["--in-flight"])),
        current_cohort_members=frozenset(_keys(options["--current-cohort-members"])),
    )
    return _compact(
        {
            "candidate": decision.candidate,
            "outcome": decision.outcome.value,
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


def _run_add_entry(options: dict[str, str]) -> str:
    """Run ``build_add_entry`` for one fixture and render the record.

    Args:
        options (dict[str, str]): The fixture's paired options.

    Returns:
        str: The compact JSON record.
    """

    entry = build_add_entry(
        int(options["--item"]),
        deferred=options["--deferred"] == "true",
        current_generation=int(options["--generation"]),
        clock=_fixed_clock,
    )
    return _render_entry(entry, options["--at"])


def _run_close(options: dict[str, str]) -> str:
    """Run ``decide_close`` over records built in argv order.

    Args:
        options (dict[str, str]): The fixture's paired options.

    Returns:
        str: ``{"close_permitted":true}`` when the close is permitted.
    """

    items: dict[int, ItemRecord] = {}
    # Construct each record in supplied order, so the first invalid token is the
    # one whose rejection is reported, matching the bash validation order.
    for token in options["--items"].split():
        key_text, state = token.split(":")
        key = int(key_text)
        items[key] = ItemRecord(issue_num=key, state=state)
    decide_close(items)
    return _compact({"close_permitted": True})


def _run_close_entry(options: dict[str, str]) -> str:
    """Run ``build_close_entry`` for one fixture and render the record.

    Args:
        options (dict[str, str]): The fixture's paired options.

    Returns:
        str: The compact JSON record.
    """

    entry = build_close_entry(
        current_generation=int(options["--generation"]), clock=_fixed_clock
    )
    return _render_entry(entry, options["--at"])


def _run_requeue_entry(options: dict[str, str]) -> str:
    """Run ``build_requeue_entry`` for one fixture and render the record.

    Args:
        options (dict[str, str]): The fixture's paired options.

    Returns:
        str: The compact JSON record.
    """

    entry = build_requeue_entry(
        int(options["--item"]),
        current_generation=int(options["--generation"]),
        clock=_fixed_clock,
    )
    return _render_entry(entry, options["--at"])


# Subcommand name to reference runner.
RUNNERS: dict[str, Callable[[dict[str, str]], str]] = {
    "admit": _run_admit,
    "recolor": _run_recolor,
    "add-entry": _run_add_entry,
    "close": _run_close,
    "close-entry": _run_close_entry,
    "requeue-entry": _run_requeue_entry,
}


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
    try:
        stdout = RUNNERS[argv[0]](options)
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
    ), f"Expected at least {MINIMUM_FIXTURE_COUNT} run fixtures, found {count}"


def test_corpus_matches_required_cases() -> None:
    """The corpus stem set equals the declared case set exactly."""

    # Arrange / Act
    names = frozenset(path.stem for path in _fixture_paths())

    # Assert
    assert names == REQUIRED_CASES, (
        f"missing: {sorted(REQUIRED_CASES - names)}; "
        f"unexpected: {sorted(names - REQUIRED_CASES)}"
    )


def test_corpus_has_success_and_rejection_per_rejecting_subcommand() -> None:
    """Each subcommand with a rejection branch has an exit-0 and an exit-1 fixture."""

    # Arrange
    seen: set[tuple[str, object]] = set()

    # Act
    for path in _fixture_paths():
        fixture = _load_fixture(path)
        seen.add((cast("str", fixture["subcommand"]), _expected(fixture)["exit_code"]))

    # Assert
    for subcommand in REJECTING_SUBCOMMANDS:
        for exit_code in (0, 1):
            assert (
                subcommand,
                exit_code,
            ) in seen, f"no {subcommand} fixture with exit code {exit_code}"


def test_admit_fixtures_are_success_only() -> None:
    """Every admit fixture is a success case, since admission never rejects."""

    # Arrange
    admit_exit_codes: list[object] = []

    # Act
    for path in _fixture_paths():
        fixture = _load_fixture(path)
        if fixture["subcommand"] == "admit":
            admit_exit_codes.append(_expected(fixture)["exit_code"])

    # Assert: at least one admit fixture exists and none expects a rejection.
    assert admit_exit_codes, "the corpus holds no admit fixture"
    assert all(
        code == 0 for code in admit_exit_codes
    ), f"admit fixtures must all expect exit 0, found {admit_exit_codes}"


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
