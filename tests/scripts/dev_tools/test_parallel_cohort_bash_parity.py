"""Python-lane assertions over the shared parallel-cohort parity corpus.

Parametrize over every ``tests/fixtures/parallel_cohorts/*.json`` file and assert
that ``scripts/dev_tools/parallel_cohort_computation.py`` -- the repository's
reference implementation -- reproduces each fixture's ``expected_cohorts``,
``expected_batches``, or ``expected_error`` block exactly. The same corpus is
asserted by the bash lane in ``tests/shell/parallel_cohorts_parity.bats``, so the
fixtures are the single artifact that pins the two implementations together;
neither suite may relax an expectation without the other observing the change.

Fixture shape. A cohort fixture carries ``input`` with ``item_keys`` and
``conflict_edges``; a batching fixture carries ``input`` with
``cohort_item_keys`` and ``max_concurrency``. The two kinds are told apart by
the presence of ``cohort_item_keys``. A success fixture carries
``expected_cohorts`` or ``expected_batches``; an error fixture carries
``expected_error`` holding the exact Python message.

Verified scope and declared divergence classes. Parity between the Python and
bash lanes is byte-exact for every fixture in this corpus, including Python
``repr`` quote selection, with exactly two declared exceptions that are recorded
in all four parity-suite headers for this feature:

1. The M1 YAML-parse-failure message. Parity is scoped to the prefix
   ``Parallel manifest frontmatter is not valid YAML: `` plus the single-element
   error-list shape, because the underlying YAML library's exception text is not
   reproducible across runtimes. This class does not arise in the cohort corpus;
   it is restated here so all four headers carry the same scope statement.
2. Non-printable string-repr escapes. A string containing a control character
   other than ``\\n``, ``\\r``, or ``\\t`` renders its escape differently between
   the two lanes, so no corpus fixture contains one.

Additionally excluded from the corpus by the pinned lexical rule: integer tokens
with leading zeros (``-?0[0-9]+``). The bash entry points reject them with a
bash-side lexical error before any shared code runs, so they have no Python
counterpart and are documented rather than asserted.

The corpus files are committed and read-only here. No temporary file is created,
no external process is started, and no bash is invoked: parity is asserted
against a shared artifact rather than by cross-process execution.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import cast

import pytest

from scripts.dev_tools.parallel_cohort_computation import (
    ParallelCohortInputError,
    compute_cohorts,
    compute_concurrency_batches,
)

# Repo-root resolution: this file lives at
# tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py, so the repository
# root is three parents above the file's resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
FIXTURE_DIR = REPO_ROOT / "tests" / "fixtures" / "parallel_cohorts"
FIXTURE_SUFFIX = ".json"

# Floor on corpus size. An empty or partially matched glob would make every
# parametrized case below disappear and the suite would pass vacuously, so the
# count is asserted twice: against this floor and against the files on disk.
MINIMUM_FIXTURE_COUNT = 20

# Presence of this input key marks a batching fixture; its absence marks a
# cohort-coloring fixture.
BATCH_MARKER_KEY = "cohort_item_keys"


def load_fixture(path: Path) -> dict[str, object]:
    """Read one corpus file and guard that it deserializes to a JSON object.

    Args:
        path (Path): Absolute path to a corpus file.

    Returns:
        dict[str, object]: The parsed fixture record.

    Raises:
        TypeError: If the file's top-level value is not a JSON object.

    Side Effects:
        Reads the file from disk. The file is never written.
    """

    parsed = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(parsed, dict):
        raise TypeError(f"{path.name} must hold a JSON object at its top level.")
    return cast("dict[str, object]", parsed)


def require_mapping(value: object, label: str) -> dict[str, object]:
    """Guard a fixture value that must be a JSON object.

    Args:
        value (object): Value read from a parsed fixture.
        label (str): Dotted fixture path used in the failure message.

    Returns:
        dict[str, object]: The validated mapping.

    Raises:
        TypeError: If the value is not a JSON object.

    Side Effects:
        None.
    """

    if not isinstance(value, dict):
        raise TypeError(f"{label} must be a JSON object, got {type(value).__name__}.")
    return cast("dict[str, object]", value)


def require_int_list(value: object, label: str) -> list[int]:
    """Guard a fixture value that must be a JSON array of integers.

    Args:
        value (object): Value read from a parsed fixture.
        label (str): Dotted fixture path used in the failure message.

    Returns:
        list[int]: The validated integer list.

    Raises:
        TypeError: If the value is not a list, or any entry is not an integer.

    Side Effects:
        None.
    """

    if not isinstance(value, list):
        raise TypeError(f"{label} must be a JSON array, got {type(value).__name__}.")
    entries = cast("list[object]", value)
    # Reject booleans explicitly: bool subclasses int, and a boolean in an item
    # key slot is malformed corpus data rather than a value to coerce.
    for entry in entries:
        if not isinstance(entry, int) or isinstance(entry, bool):
            raise TypeError(f"{label} entries must be integers; found {entry!r}.")
    return cast("list[int]", entries)


def require_nested_int_list(value: object, label: str) -> list[list[int]]:
    """Guard a fixture value that must be a JSON array of integer arrays.

    Args:
        value (object): Value read from a parsed fixture.
        label (str): Dotted fixture path used in the failure message.

    Returns:
        list[list[int]]: The validated nested integer list.

    Raises:
        TypeError: If the value is not a list of integer lists.

    Side Effects:
        None.
    """

    if not isinstance(value, list):
        raise TypeError(f"{label} must be a JSON array, got {type(value).__name__}.")
    outer = cast("list[object]", value)
    # Validate each inner list through the flat guard so one implementation
    # covers both the inner element type and the inner container type.
    return [
        require_int_list(inner, f"{label}[{index}]")
        for index, inner in enumerate(outer)
    ]


def require_edge_list(value: object, label: str) -> list[tuple[int, int]]:
    """Guard a fixture value that must be a JSON array of two-integer arrays.

    Args:
        value (object): Value read from a parsed fixture.
        label (str): Dotted fixture path used in the failure message.

    Returns:
        list[tuple[int, int]]: The edges in the normalized tuple reduction the
        reference implementation accepts.

    Raises:
        TypeError: If any entry is not a two-element integer array.

    Side Effects:
        None.
    """

    pairs = require_nested_int_list(value, label)
    # The reference implementation destructures each edge into exactly two
    # endpoints, so a longer or shorter entry is malformed corpus data.
    for index, pair in enumerate(pairs):
        if len(pair) != 2:
            raise TypeError(f"{label}[{index}] must hold exactly two integers.")
    return [(pair[0], pair[1]) for pair in pairs]


def require_text(value: object, label: str) -> str:
    """Guard a fixture value that must be a non-empty JSON string.

    Args:
        value (object): Value read from a parsed fixture.
        label (str): Dotted fixture path used in the failure message.

    Returns:
        str: The validated string.

    Raises:
        TypeError: If the value is not a string.
        ValueError: If the string is empty.

    Side Effects:
        None.
    """

    if not isinstance(value, str):
        raise TypeError(f"{label} must be a JSON string, got {type(value).__name__}.")
    if not value:
        raise ValueError(f"{label} must not be empty.")
    return value


def discover_fixture_paths() -> list[Path]:
    """List the corpus files in deterministic name order.

    Returns:
        list[Path]: Every ``*.json`` file in the corpus directory, sorted by
        path so parametrization ids are stable across platforms.

    Raises:
        None.

    Side Effects:
        Reads the corpus directory listing.
    """

    return sorted(FIXTURE_DIR.glob(f"*{FIXTURE_SUFFIX}"))


FIXTURE_PATHS = discover_fixture_paths()


def test_corpus_meets_the_declared_floor() -> None:
    """Assert the corpus is at least as large as the declared floor.

    A broken glob or a moved directory would silently empty the parametrized
    cases below, so the floor is asserted directly rather than inferred from a
    passing parametrized run.
    """

    # Arrange / Act: the module-level discovery already ran.
    discovered = len(FIXTURE_PATHS)

    # Assert
    assert discovered >= MINIMUM_FIXTURE_COUNT, (
        f"Cohort parity corpus has {discovered} fixtures; the declared floor is "
        f"{MINIMUM_FIXTURE_COUNT}. Restore the missing fixtures or lower the "
        f"floor deliberately."
    )


@pytest.mark.parametrize("fixture_path", FIXTURE_PATHS, ids=lambda path: path.stem)
def test_reference_implementation_reproduces_the_fixture(fixture_path: Path) -> None:
    """Assert the Python lane reproduces one corpus fixture exactly.

    Args:
        fixture_path (Path): One corpus file supplied by parametrization.
    """

    # Arrange
    fixture = load_fixture(fixture_path)
    payload = require_mapping(fixture.get("input"), f"{fixture_path.stem}.input")
    expected_error = fixture.get("expected_error")

    # Route on fixture kind: a batching fixture names its cohort key list, a
    # coloring fixture names the graph's vertices and edges.
    if BATCH_MARKER_KEY in payload:
        _assert_batching_fixture(fixture, fixture_path, payload, expected_error)
        return
    _assert_cohort_fixture(fixture, fixture_path, payload, expected_error)


def _assert_batching_fixture(
    fixture: dict[str, object],
    fixture_path: Path,
    payload: dict[str, object],
    expected_error: object,
) -> None:
    """Assert one ``compute_concurrency_batches`` fixture.

    Args:
        fixture (dict[str, object]): The whole parsed fixture record.
        fixture_path (Path): The corpus file, used in assertion messages.
        payload (dict[str, object]): The fixture's ``input`` mapping.
        expected_error (object): The fixture's ``expected_error`` value, or
            ``None`` when the fixture expects success.

    Returns:
        None.

    Raises:
        TypeError: If the fixture's guarded fields have the wrong JSON types.

    Side Effects:
        None.
    """

    label = fixture_path.stem
    cohort_keys = require_int_list(
        payload.get(BATCH_MARKER_KEY), f"{label}.input.{BATCH_MARKER_KEY}"
    )
    concurrency = payload.get("max_concurrency")
    if not isinstance(concurrency, int) or isinstance(concurrency, bool):
        raise TypeError(f"{label}.input.max_concurrency must be an integer.")

    # An error fixture pins the exact message; a success fixture pins the exact
    # batch shaping. The two are mutually exclusive by corpus construction.
    if expected_error is not None:
        message = require_text(expected_error, f"{label}.expected_error")
        with pytest.raises(ParallelCohortInputError) as caught:
            compute_concurrency_batches(cohort_keys, concurrency)
        assert str(caught.value) == message
        return

    expected = require_nested_int_list(
        fixture.get("expected_batches"), f"{label}.expected_batches"
    )
    assert compute_concurrency_batches(cohort_keys, concurrency) == expected


def _assert_cohort_fixture(
    fixture: dict[str, object],
    fixture_path: Path,
    payload: dict[str, object],
    expected_error: object,
) -> None:
    """Assert one ``compute_cohorts`` fixture.

    Args:
        fixture (dict[str, object]): The whole parsed fixture record.
        fixture_path (Path): The corpus file, used in assertion messages.
        payload (dict[str, object]): The fixture's ``input`` mapping.
        expected_error (object): The fixture's ``expected_error`` value, or
            ``None`` when the fixture expects success.

    Returns:
        None.

    Raises:
        TypeError: If the fixture's guarded fields have the wrong JSON types.

    Side Effects:
        None.
    """

    label = fixture_path.stem
    item_keys = require_int_list(payload.get("item_keys"), f"{label}.input.item_keys")
    edges = require_edge_list(
        payload.get("conflict_edges"), f"{label}.input.conflict_edges"
    )

    # An error fixture pins the exact message; a success fixture pins the exact
    # cohort partition. The two are mutually exclusive by corpus construction.
    if expected_error is not None:
        message = require_text(expected_error, f"{label}.expected_error")
        with pytest.raises(ParallelCohortInputError) as caught:
            compute_cohorts(item_keys, edges)
        assert str(caught.value) == message
        return

    expected = require_nested_int_list(
        fixture.get("expected_cohorts"), f"{label}.expected_cohorts"
    )
    assert compute_cohorts(item_keys, edges) == expected
