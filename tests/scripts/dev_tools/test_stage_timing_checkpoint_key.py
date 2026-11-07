"""Pin the tolerated, unvalidated ``stage_timing`` checkpoint key (issue #1097).

The orchestrator main session writes ``stage_timing`` into the checkpoint as a list
of timing entries. No validator reads the key, so these tests drive three shapes (a
valid list, JSON null, and a string) through the Python validator in each mode and
require the error list to equal the list for the same checkpoint without the key. A
control removes a required key, which proves the validator ran. The portable-handoff
tests pin that the archived source bytes keep the key and stay bound by their
SHA-256, and that the destination projection starts without it.

The base checkpoint is a committed back-compat fixture read in place; the key is
added in memory. No temporary file is created and no external process is started.
"""

from __future__ import annotations

import json
from dataclasses import replace
from pathlib import Path
from typing import cast

import pytest

import scripts.dev_tools.validate_orchestrator_state as state_validator
from scripts.dev_tools.orchestration_handoff_contract import (
    HandoffContractError,
    ProviderProvenance,
    raw_sha256,
    validate_provenance_bytes,
)
from tests.scripts.dev_tools.orchestration_handoff_taskmaster_469_test_support import (
    CASES,
    FixtureCase,
    build_envelope,
    fixture_bytes,
    load_fixture,
    projection_facts,
)

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
REPO_ROOT = Path(__file__).resolve().parents[3]
BASE_CHECKPOINT = (
    REPO_ROOT
    / "tests"
    / "fixtures"
    / "orchestrator_state_blocked_reason_backcompat"
    / "none.json"
)
KEY = "stage_timing"

VALID_LIST: object = [
    {
        "stage": "S4_atomic_planning",
        "attempt": 1,
        "started_at": "2026-01-02T01:00:00Z",
        "ended_at": "2026-01-02T01:10:00Z",
    },
    {
        "stage": "S5_atomic_execution",
        "attempt": 1,
        "started_at": "2026-01-02T01:10:00Z",
        "ended_at": None,
    },
]
SHAPES: tuple[tuple[str, object], ...] = (
    ("valid-list", VALID_LIST),
    ("null", None),
    ("string", "not-a-list"),
)
# Parametrize ids for the shapes, in the same order as SHAPES.
SHAPE_IDS: tuple[str, ...] = ("valid-list", "null", "string")
MODE_FLAGS: dict[str, dict[str, bool]] = {
    "require_complete": {"require_complete": True},
    "require_pr_creation_ready": {"require_pr_creation_ready": True},
}


def _base_checkpoint() -> dict[str, object]:
    """Read the committed back-compat checkpoint.

    Returns:
        dict[str, object]: A fresh parsed copy that the caller may mutate.
    """
    parsed = cast("object", json.loads(BASE_CHECKPOINT.read_text(encoding="utf-8")))
    return cast("dict[str, object]", parsed)


def _text_with(value: object, *, present: bool) -> str:
    """Serialize the base checkpoint, adding ``stage_timing`` only when requested.

    Args:
        value (object): The value stored under ``stage_timing`` when it is added.
        present (bool): Whether the key is added at all.

    Returns:
        str: The checkpoint as JSON text.
    """
    checkpoint = _base_checkpoint()
    if present:
        checkpoint[KEY] = value
    return json.dumps(checkpoint, indent=2)


def _names_key(lines: list[str]) -> bool:
    """Report whether any validation error line mentions the ``stage_timing`` key.

    Args:
        lines (list[str]): The validator error lines.

    Returns:
        bool: True when at least one line contains the key name.
    """
    # Scan every error line; the key is tolerated, so no line may name it.
    for line in lines:
        if KEY in line:
            return True
    return False


@pytest.mark.parametrize(("shape", "value"), SHAPES, ids=SHAPE_IDS)
def test_python_plain_validation_ignores_stage_timing(
    shape: str, value: object
) -> None:
    """Plain validation returns the same error list with and without the key."""
    # Arrange: the same checkpoint with and without the key.
    without_key = _text_with(value, present=False)
    with_key = _text_with(value, present=True)

    # Act: validate both in plain mode.
    expected = state_validator.validate_orchestrator_state_text(without_key)
    observed = state_validator.validate_orchestrator_state_text(with_key)

    # Assert: the key changes nothing, and no error names it.
    assert observed == expected, f"stage_timing shape {shape} changed the error list."
    assert not _names_key(observed)


@pytest.mark.parametrize(("shape", "value"), SHAPES, ids=SHAPE_IDS)
@pytest.mark.parametrize("mode", sorted(MODE_FLAGS))
def test_python_completion_and_pr_modes_ignore_stage_timing(
    mode: str, shape: str, value: object
) -> None:
    """The completion and PR modes return the same list with and without the key."""
    # Arrange: the same checkpoint with and without the key.
    without_key = _text_with(value, present=False)
    with_key = _text_with(value, present=True)

    # Act: validate both with only the selected flag set.
    expected = state_validator.validate_orchestrator_state_text(
        without_key, **MODE_FLAGS[mode]
    )
    observed = state_validator.validate_orchestrator_state_text(
        with_key, **MODE_FLAGS[mode]
    )

    # Assert: the key changes nothing in this mode.
    assert observed == expected, f"stage_timing shape {shape} changed {mode} errors."
    assert not _names_key(observed)


def test_control_missing_required_key_is_still_reported() -> None:
    """Removing a required key is reported, which proves the validator ran."""
    # Arrange: a checkpoint with the key present and ``last_updated`` removed.
    checkpoint = _base_checkpoint()
    checkpoint[KEY] = VALID_LIST
    del checkpoint["last_updated"]

    # Act: validate in plain mode.
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(checkpoint, indent=2)
    )

    # Assert: the missing key is named and the stage_timing key is not.
    assert "Checkpoint missing required key: last_updated" in errors
    assert not _names_key(errors)


def _source_with_stage_timing(case: FixtureCase) -> bytes:
    """Build the fixture source checkpoint bytes with ``stage_timing`` added.

    Args:
        case (FixtureCase): The handoff direction whose source fixture is read.

    Returns:
        bytes: The re-serialized source checkpoint that carries the key.
    """
    fixture = load_fixture(case)
    source_bytes, _ = fixture_bytes(case, fixture)
    parsed = cast("dict[str, object]", json.loads(source_bytes.decode("utf-8")))
    parsed[KEY] = VALID_LIST
    return json.dumps(parsed, indent=2).encode("utf-8")


def _provenance_bound_to(case: FixtureCase, source_bytes: bytes) -> ProviderProvenance:
    """Bind the fixture provenance to the SHA-256 of the given source bytes.

    Args:
        case (FixtureCase): The handoff direction whose provenance is reused.
        source_bytes (bytes): The source checkpoint bytes the hash must bind.

    Returns:
        ProviderProvenance: Provenance whose hash and archive path match the bytes
        and that lists no historical receipts.
    """
    digest = raw_sha256(source_bytes)
    return replace(
        build_envelope(case).source,
        checkpoint_sha256=digest,
        archive_path=f"artifacts/orchestration/handoffs/sources/sha256/{digest}.json",
        receipt_references=(),
    )


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.name)
def test_archived_source_bytes_carry_stage_timing_and_stay_hash_bound(
    case: FixtureCase,
) -> None:
    """A source checkpoint with the key keeps it in the archive, hash bound."""
    # Arrange: bind the provenance to source bytes that carry the key.
    archived = _source_with_stage_timing(case)
    provenance = _provenance_bound_to(case, archived)

    # Act: validate the archived bytes against the bound hash.
    validate_provenance_bytes(provenance, archived, ())

    # Assert: the bytes that the hash binds still hold the key.
    assert b'"stage_timing"' in archived
    assert raw_sha256(archived) == provenance.checkpoint_sha256


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.name)
def test_archive_without_stage_timing_fails_the_source_hash(case: FixtureCase) -> None:
    """Dropping the key from the archived bytes breaks the source hash binding."""
    # Arrange: provenance bound to bytes with the key, archive bytes without it.
    fixture = load_fixture(case)
    dropped, _ = fixture_bytes(case, fixture)
    provenance = _provenance_bound_to(case, _source_with_stage_timing(case))

    # Act and assert: the hash of the bytes without the key does not match.
    with pytest.raises(HandoffContractError) as raised:
        validate_provenance_bytes(provenance, dropped, ())
    assert "source.checkpoint.sha256" in str(raised.value)


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.name)
def test_destination_projection_omits_stage_timing(case: FixtureCase) -> None:
    """The destination projection copies no unknown key, so it omits the key."""
    # Arrange: the projection input is the envelope and its facts only, so the
    # source checkpoint text, with or without the key, never reaches the adapter.
    envelope = build_envelope(case)

    # Act: project the destination checkpoint and validate its text.
    projection = case.adapter.project(envelope, projection_facts(envelope))
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(projection.checkpoint, indent=2)
    )

    # Assert: no key anywhere in the projection and no validation error naming it.
    assert KEY not in projection.checkpoint
    assert KEY not in json.dumps(projection.checkpoint)
    assert not _names_key(errors)
