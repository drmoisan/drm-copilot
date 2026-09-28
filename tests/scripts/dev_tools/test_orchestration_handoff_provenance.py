"""Raw-byte provenance and append-only history tests for portable handoff."""

from __future__ import annotations

import json
from dataclasses import replace
from pathlib import Path
from typing import Any, cast

import pytest

from scripts.dev_tools.orchestration_handoff_contract import (
    HandoffContractError,
    HistoryEntry,
    Provider,
    ProviderProvenance,
    ReceiptReference,
    history_entry_digest,
    raw_sha256,
    validate_history_chain,
    validate_provenance_bytes,
)

ROOT = Path(__file__).parents[3]
FIXTURES = ROOT / "tests" / "fixtures" / "orchestration-handoff" / "contract"


def _provenance(
    source_bytes: bytes, references: tuple[ReceiptReference, ...] = ()
) -> ProviderProvenance:
    digest = raw_sha256(source_bytes)
    return ProviderProvenance(
        "claude",
        "artifacts/orchestration/orchestrator-state.json",
        digest,
        f"artifacts/orchestration/handoffs/sources/sha256/{digest}.json",
        "claude.orchestrator-state",
        "legacy-v1",
        references,
    )


def _history_entry(
    sequence: int,
    *,
    source: Provider,
    destination: Provider,
    previous: str | None,
) -> HistoryEntry:
    placeholder = "0" * 64
    entry = HistoryEntry(
        sequence,
        source,
        destination,
        placeholder,
        placeholder,
        f"2026-08-31T08:0{sequence}:00Z",
        previous,
        placeholder,
        "requested",
        f"{source}-to-{destination}-v1",
        "1.0.0",
    )
    return replace(entry, entry_sha256=history_entry_digest(entry))


def test_raw_hashing_preserves_newline_identity() -> None:
    source_bytes = b'{"status":"prepared"}\r\n'
    normalized_bytes = b'{"status":"prepared"}\n'
    assert raw_sha256(source_bytes) != raw_sha256(normalized_bytes)


def test_archive_path_is_bound_to_raw_source_digest() -> None:
    source_bytes = b'{"status":"prepared"}\r\n'
    provenance = _provenance(source_bytes)
    assert provenance.checkpoint_sha256 in provenance.archive_path
    wrong_archive = (
        "artifacts/orchestration/handoffs/sources/sha256/" + "f" * 64 + ".json"
    )

    with pytest.raises(HandoffContractError) as error:
        replace(provenance, archive_path=wrong_archive)
    assert error.value.field == "source.checkpoint.archive_path"


def test_opaque_receipts_validate_without_normalization() -> None:
    source_bytes = b'{"status":"prepared"}\r\n'
    receipt_bytes = b'{"provider":"claude","spacing":  true}\r\n'
    reference = ReceiptReference(
        "artifacts/orchestration/receipts/claude.json",
        raw_sha256(receipt_bytes),
    )
    before_source = bytes(source_bytes)
    before_receipt = bytes(receipt_bytes)

    validate_provenance_bytes(
        _provenance(source_bytes, (reference,)), source_bytes, (receipt_bytes,)
    )

    assert source_bytes == before_source
    assert receipt_bytes == before_receipt


def test_history_is_monotonic_and_digest_linked() -> None:
    first = _history_entry(1, source="claude", destination="codex", previous=None)
    second = _history_entry(
        2,
        source="codex",
        destination="claude",
        previous=first.entry_sha256,
    )
    validate_history_chain((first, second))


def test_history_tampering_fails_without_rewriting_original_chain() -> None:
    first = _history_entry(1, source="claude", destination="codex", previous=None)
    original = (first,)
    tampered = (replace(first, adapter_version="9.9.9"),)

    with pytest.raises(HandoffContractError) as error:
        validate_history_chain(tampered)

    assert error.value.field == "handoff_history.entry_sha256"
    assert original[0].adapter_version == "1.0.0"
    validate_history_chain(original)


def test_shared_history_fixture_detects_broken_link() -> None:
    cases = cast(
        "list[dict[str, object]]",
        json.loads((FIXTURES / "invalid-contract-cases.json").read_text()),
    )
    case = next(item for item in cases if item["id"] == "history-link")
    envelope = cast(
        "dict[str, Any]",
        json.loads((FIXTURES / cast("str", case["base"])).read_text()),
    )
    history = cast("list[dict[str, Any]]", envelope["handoff_history"])
    history[0]["previous_entry_sha256"] = case["value"]

    with pytest.raises(HandoffContractError) as error:
        validate_history_chain((HistoryEntry(**history[0]),))

    assert error.value.field == "handoff_history.previous_entry_sha256"


def test_failed_receipt_validation_preserves_source_for_rollback() -> None:
    source_bytes = b'{"status":"prepared"}\r\n'
    receipt_bytes = b'{"receipt":"original"}\r\n'
    reference = ReceiptReference(
        "artifacts/orchestration/receipts/claude.json",
        raw_sha256(receipt_bytes),
    )
    before = bytes(source_bytes)

    with pytest.raises(HandoffContractError):
        validate_provenance_bytes(
            _provenance(source_bytes, (reference,)),
            source_bytes,
            (b'{"receipt":"tampered"}\n',),
        )

    assert source_bytes == before
