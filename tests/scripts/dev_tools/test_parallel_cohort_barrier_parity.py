"""Cross-runtime parity assertions over the committed cohort-barrier corpus.

Parametrize over every ``tests/fixtures/parallel_cohort_barrier/*.json`` file and
assert that the Python reference implementation emits exactly the barrier
messages the fixture records in ``expected_barrier_errors``, in that order. The
same corpus files are asserted by
``extensions/drm-copilot/test/lib/validate/parallel-cohort-barrier-parity.test.ts``,
so the corpus is the single artifact that pins the Python and TypeScript
implementations together; neither suite may relax an expectation without the
other observing the change.

Why a shared corpus rather than two per-side suites. The parallel-orchestration
epic has shipped the producer/consumer divergence defect three times, each time
with both language surfaces at full per-side coverage. Per-side coverage is
structurally blind to divergence: each suite can be complete and internally
consistent while the two surfaces disagree. Binding both runtimes to one
committed expectation file is what makes a disagreement observable. The pattern
follows ``tests/scripts/dev_tools/test_blast_radius_parity.py`` and its
``tests/fixtures/blast_radius`` corpus.

Fixture shape. Each file carries ``name`` (kebab-case identifier equal to the
file stem), ``notes`` (one sentence naming the behavior class the case pins),
``document`` (a parallel-orchestrator checkpoint object, complete except where
the case deliberately drops a gating key), and ``expected_barrier_errors`` (the
ordered list of ``PARALLEL_COHORT_BARRIER_VIOLATION`` messages both runtimes
must emit, empty when the barrier holds).

Parity claim scope. Only barrier messages are compared: both suites filter
validator output to the strings beginning with the literal violation token
before asserting. Corpus documents are restricted to JSON-representable values
that round-trip through both runtimes' native types, so the three divergence
classes recorded in ``.claude/rules/parallel-orchestration.md`` are avoided
rather than fixed.

The corpus files are committed and read-only here. No temporary file is created,
no external process is started, and no other runtime is invoked: parity is
asserted against a shared artifact rather than by cross-process execution. This
module imports only the public validator entry point and never the barrier
helper module, so every case exercises the wiring between the helper and the
validator that a helper-only test cannot show.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools.validate_parallel_orchestrator_state import (
    validate_parallel_orchestrator_state_text,
)

if TYPE_CHECKING:
    from collections.abc import Mapping

# Repo-root resolution: this file lives at
# tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py, so the
# repository root is three parents above the file's resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
CORPUS_DIR = REPO_ROOT / "tests" / "fixtures" / "parallel_cohort_barrier"
CORPUS_SUFFIX = ".json"

# Floor on corpus size. An empty or partially matched glob would make every
# parametrized case below disappear and the suite would pass vacuously, so the
# count is asserted twice: against this floor and against the files on disk.
MINIMUM_CORPUS_COUNT = 30

# Literal invariant token, restated here from design section 9 rather than
# imported, so the filter is pinned to the specification and not to the
# implementation's own constant.
VIOLATION_LABEL = "PARALLEL_COHORT_BARRIER_VIOLATION"

# The four keys every corpus file must carry.
REQUIRED_FIXTURE_KEYS = ("name", "notes", "document", "expected_barrier_errors")


def require_mapping(value: object, label: str) -> Mapping[str, object]:
    """Guard a corpus value that must be a JSON object.

    Args:
        value (object): Value read from a parsed corpus file.
        label (str): Dotted corpus path used in the failure message.

    Returns:
        Mapping[str, object]: The validated mapping.

    Raises:
        TypeError: If the value is not a JSON object.
    """
    if not isinstance(value, dict):
        raise TypeError(f"{label} must be a JSON object, got {type(value).__name__}.")
    return cast("Mapping[str, object]", value)


def require_text(value: object, label: str) -> str:
    """Guard a corpus value that must be a non-blank JSON string.

    Args:
        value (object): Value read from a parsed corpus file.
        label (str): Dotted corpus path used in the failure message.

    Returns:
        str: The validated string.

    Raises:
        TypeError: If the value is not a string.
        ValueError: If the value is blank.
    """
    if not isinstance(value, str):
        raise TypeError(f"{label} must be a string, got {type(value).__name__}.")
    if not value.strip():
        raise ValueError(f"{label} must not be empty.")
    return value


def require_message_list(value: object, label: str) -> list[str]:
    """Guard a corpus value that must be a JSON array of barrier messages.

    Args:
        value (object): Value read from a parsed corpus file.
        label (str): Dotted corpus path used in the failure message.

    Returns:
        list[str]: The expected messages in corpus order. An empty list is
        valid and means the barrier holds for that document.

    Raises:
        TypeError: If the value is not a list or holds a non-string entry.
        ValueError: If an entry does not begin with the violation token, which
            would put an unrelated expectation inside the barrier comparison.
    """
    if not isinstance(value, list):
        raise TypeError(f"{label} must be a JSON array, got {type(value).__name__}.")

    # Validate every entry as it is read so a malformed corpus fails at load
    # time naming the offending record rather than inside an assertion body.
    messages: list[str] = []
    for index, entry in enumerate(cast("list[object]", value)):
        message = require_text(entry, f"{label}[{index}]")
        if not message.startswith(VIOLATION_LABEL):
            raise ValueError(
                f"{label}[{index}] must begin with {VIOLATION_LABEL}; got {message}."
            )
        messages.append(message)
    return messages


def load_fixture(path: Path) -> Mapping[str, object]:
    """Read, parse, and structurally guard one committed corpus file.

    Args:
        path (Path): Absolute path to a corpus JSON file.

    Returns:
        Mapping[str, object]: The parsed top-level fixture object.

    Raises:
        TypeError: If the file does not parse to a JSON object or a required
            field has the wrong type.
        ValueError: If a required key is absent, or ``name`` does not equal the
            file stem, which would let a case be silently renamed away from the
            file the TypeScript suite reads.

    Side Effects:
        Reads the committed corpus file. The corpus is read-only for this suite.
    """
    parsed = cast("object", json.loads(path.read_text(encoding="utf-8")))
    fixture = require_mapping(parsed, path.name)

    # Guard the whole key set before any field is read, so a partially authored
    # corpus file reports the missing key rather than a confusing type error.
    for key in REQUIRED_FIXTURE_KEYS:
        if key not in fixture:
            raise ValueError(f"{path.name} must carry the key {key}.")

    name = require_text(fixture["name"], f"{path.name}.name")
    if name != path.stem:
        raise ValueError(f"{path.name}.name must equal the file stem {path.stem}.")
    require_text(fixture["notes"], f"{path.name}.notes")
    require_mapping(fixture["document"], f"{path.name}.document")
    require_message_list(
        fixture["expected_barrier_errors"], f"{path.name}.expected_barrier_errors"
    )
    return fixture


CORPUS_PATHS: tuple[Path, ...] = tuple(sorted(CORPUS_DIR.glob(f"*{CORPUS_SUFFIX}")))
CORPUS_CASES: tuple[tuple[str, Mapping[str, object]], ...] = tuple(
    (path.stem, load_fixture(path)) for path in CORPUS_PATHS
)
CORPUS_IDS: list[str] = [name for name, _ in CORPUS_CASES]


def barrier_errors(document: Mapping[str, object]) -> list[str]:
    """Return only the barrier messages the validator emits for one document.

    Args:
        document (Mapping[str, object]): One corpus checkpoint document.

    Returns:
        list[str]: The validator's error strings filtered to those beginning
        with the violation token, in the order the validator produced them.
        Filtering isolates the parity claim from the F3 shape errors a
        deliberately malformed collection also reports.
    """
    errors = validate_parallel_orchestrator_state_text(json.dumps(document))
    return [error for error in errors if error.startswith(VIOLATION_LABEL)]


def test_corpus_meets_the_documented_minimum_size() -> None:
    """Guard every parametrized case below against an empty corpus glob."""
    # Arrange: the corpus is discovered at import.
    # Act: measure the discovered set.
    discovered = len(CORPUS_PATHS)

    # Assert: a short corpus would silently drop behavior classes the parity
    # claim depends on, and an empty one would make the suite pass vacuously.
    assert discovered >= MINIMUM_CORPUS_COUNT, (
        f"Expected at least {MINIMUM_CORPUS_COUNT} corpus files under "
        f"{CORPUS_DIR}, discovered {discovered}."
    )


def test_discovered_corpus_count_equals_the_json_file_count() -> None:
    """Require the discovery glob to reach every JSON file in the corpus."""
    # Arrange: enumerate the directory without the glob, so a pattern that
    # silently skipped files would be caught rather than reproduced.
    on_disk = tuple(
        entry
        for entry in CORPUS_DIR.iterdir()
        if entry.is_file() and entry.suffix == CORPUS_SUFFIX
    )

    # Act / Assert: the two counts must agree, otherwise the TypeScript suite
    # and this one could be iterating different subsets of the same directory.
    assert len(CORPUS_PATHS) == len(on_disk), (
        f"Discovered {len(CORPUS_PATHS)} corpus files but {len(on_disk)} "
        f"{CORPUS_SUFFIX} files exist under {CORPUS_DIR}."
    )


def test_corpus_exercises_both_verdicts() -> None:
    """Require the corpus to pin violating and clean documents alike."""
    # Arrange / Act: read each case's expectation length.
    violating = [
        name
        for name, fixture in CORPUS_CASES
        if require_message_list(
            fixture["expected_barrier_errors"], f"{name}.expected_barrier_errors"
        )
    ]
    clean = [
        name
        for name, fixture in CORPUS_CASES
        if not require_message_list(
            fixture["expected_barrier_errors"], f"{name}.expected_barrier_errors"
        )
    ]

    # Assert: an all-clean corpus would never exercise the message-emitting
    # path, and an all-violating corpus would never exercise the gating paths.
    assert violating, "The corpus declares no violating document."
    assert clean, "The corpus declares no barrier-satisfying document."


@pytest.mark.parametrize(("name", "fixture"), CORPUS_CASES, ids=CORPUS_IDS)
def test_corpus_document_reproduces_the_expected_barrier_errors(
    name: str, fixture: Mapping[str, object]
) -> None:
    """Assert the validator emits exactly the fixture's barrier messages."""
    # Arrange: the corpus document and its ordered expectation.
    document = require_mapping(fixture["document"], f"{name}.document")
    expected = require_message_list(
        fixture["expected_barrier_errors"], f"{name}.expected_barrier_errors"
    )

    # Act: drive the document through the public validator entry point, which is
    # what binds the barrier helper to the validator at run time.
    observed = barrier_errors(document)

    # Assert: element for element and in order, which is the same comparison the
    # TypeScript suite performs against the same file.
    assert observed == expected, (
        f"Corpus case {name} produced barrier messages that differ from its "
        f"expected_barrier_errors block."
    )
