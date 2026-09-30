"""Cross-runtime parity assertions over the committed promotion-type corpus.

Parametrize over every ``tests/fixtures/orchestrator_state_promotion_type/*.json``
file and assert that the Python routing-contract validator emits exactly the
errors the fixture records in ``expected_errors``, in that order. The same corpus
files are asserted by
``extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-type-parity.test.ts``
and by
``tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1``,
so the corpus is the single artifact that pins the three runtimes together.

Fixture shape. Each file carries ``name`` (identifier equal to the file stem),
``notes`` (one sentence naming the behavior class), ``checkpoint`` (the object
handed to the routing-contract validator), and ``expected_errors`` (the ordered
error list every runtime must emit, empty when the checkpoint is accepted).

The corpus files are committed and read-only here. No temporary file is created,
no external process is started, and no other runtime is invoked.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import TYPE_CHECKING, Any, cast

import pytest

from scripts.dev_tools._orchestrator_state_routing import validate_routing_contract

if TYPE_CHECKING:
    from collections.abc import Mapping

# Repo-root resolution: this file lives at
# tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py, so the
# repository root is three parents above the file's resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
CORPUS_DIR = REPO_ROOT / "tests" / "fixtures" / "orchestrator_state_promotion_type"
CORPUS_SUFFIX = ".json"

# Floor on corpus size. An empty or partially matched glob would make every
# parametrized case below disappear and the suite would pass vacuously, so the
# count is asserted twice: against this floor and against the files on disk.
MINIMUM_CORPUS_COUNT = 12

# The four keys every corpus file must carry.
REQUIRED_FIXTURE_KEYS = ("name", "notes", "checkpoint", "expected_errors")


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


def require_error_list(value: object, label: str) -> list[str]:
    """Guard a corpus value that must be a JSON array of error strings.

    Args:
        value (object): Value read from a parsed corpus file.
        label (str): Dotted corpus path used in the failure message.

    Returns:
        list[str]: The expected errors in corpus order; an empty list is valid.

    Raises:
        TypeError: If the value is not a list or holds a non-string entry.
        ValueError: If an entry is blank.
    """
    if not isinstance(value, list):
        raise TypeError(f"{label} must be a JSON array, got {type(value).__name__}.")
    return [
        require_text(entry, f"{label}[{index}]")
        for index, entry in enumerate(cast("list[object]", value))
    ]


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
            file stem.

    Side Effects:
        Reads the committed corpus file. The corpus is read-only for this suite.
    """
    parsed = cast("object", json.loads(path.read_text(encoding="utf-8")))
    fixture = require_mapping(parsed, path.name)

    for key in REQUIRED_FIXTURE_KEYS:
        if key not in fixture:
            raise ValueError(f"{path.name} must carry the key {key}.")

    name = require_text(fixture["name"], f"{path.name}.name")
    if name != path.stem:
        raise ValueError(f"{path.name}.name must equal the file stem {path.stem}.")
    require_text(fixture["notes"], f"{path.name}.notes")
    require_mapping(fixture["checkpoint"], f"{path.name}.checkpoint")
    require_error_list(fixture["expected_errors"], f"{path.name}.expected_errors")
    return fixture


CORPUS_PATHS: tuple[Path, ...] = tuple(sorted(CORPUS_DIR.glob(f"*{CORPUS_SUFFIX}")))
CORPUS_CASES: tuple[tuple[str, Mapping[str, object]], ...] = tuple(
    (path.stem, load_fixture(path)) for path in CORPUS_PATHS
)
CORPUS_IDS: list[str] = [name for name, _ in CORPUS_CASES]


def test_corpus_meets_the_documented_minimum_size() -> None:
    """Guard every parametrized case below against an empty corpus glob."""
    # Arrange: the corpus is discovered at import.
    # Act: measure the discovered set.
    discovered = len(CORPUS_PATHS)

    # Assert: a short corpus would silently drop behavior classes.
    assert discovered >= MINIMUM_CORPUS_COUNT, (
        f"Expected at least {MINIMUM_CORPUS_COUNT} corpus files under "
        f"{CORPUS_DIR}, discovered {discovered}."
    )


def test_discovered_corpus_count_equals_the_json_file_count() -> None:
    """Require the discovery glob to reach every JSON file in the corpus."""
    # Arrange: enumerate the directory without the glob.
    on_disk = tuple(
        entry
        for entry in CORPUS_DIR.iterdir()
        if entry.is_file() and entry.suffix == CORPUS_SUFFIX
    )

    # Act / Assert: the two counts must agree.
    assert len(CORPUS_PATHS) == len(on_disk), (
        f"Discovered {len(CORPUS_PATHS)} corpus files but {len(on_disk)} "
        f"{CORPUS_SUFFIX} files exist under {CORPUS_DIR}."
    )


def test_corpus_exercises_both_verdicts() -> None:
    """Require the corpus to pin accepted and rejected checkpoints alike."""
    # Arrange / Act: read each case's expectation length.
    rejected = [
        name
        for name, fixture in CORPUS_CASES
        if require_error_list(fixture["expected_errors"], f"{name}.expected_errors")
    ]
    accepted = [
        name
        for name, fixture in CORPUS_CASES
        if not require_error_list(fixture["expected_errors"], f"{name}.expected_errors")
    ]

    # Assert: an all-accepted corpus never exercises the message-emitting path.
    assert rejected, "The corpus declares no rejected checkpoint."
    assert accepted, "The corpus declares no accepted checkpoint."


@pytest.mark.parametrize(("name", "fixture"), CORPUS_CASES, ids=CORPUS_IDS)
def test_corpus_document_reproduces_the_expected_routing_errors(
    name: str, fixture: Mapping[str, object]
) -> None:
    """Assert the validator emits exactly the fixture's routing errors."""
    # Arrange: the corpus checkpoint and its ordered expectation.
    checkpoint = cast(
        "dict[str, Any]", require_mapping(fixture["checkpoint"], f"{name}.checkpoint")
    )
    expected = require_error_list(fixture["expected_errors"], f"{name}.expected_errors")

    # Act: drive the checkpoint through the public validator entry point.
    observed = validate_routing_contract(checkpoint)

    # Assert: element for element and in order.
    assert observed == expected, (
        f"Corpus case {name} produced routing errors that differ from its "
        f"expected_errors block."
    )
