"""Prove the root prepare-agent baseline route over memory stores without writes."""

from __future__ import annotations

from hashlib import sha256

import pytest
from drm_copilot_discovery.models import JsonObject

from tests.discovery_runtime.test_service import MemoryService, invoke
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import service_io as service_io
from tests.discovery_runtime.test_service import service_plan as service_plan

CONTRACTS = "docs/migration/discovery/feature-contracts"
EVIDENCE = "docs/migration/discovery/evidence"
EXISTING = CONTRACTS + "/existing.json"
EXISTING_BYTES = b'{"artifact_kind": "feature-contract", "id": "existing"}\n'


def output_row(
    path: str,
    expected: str | None,
    *,
    kind: str = "feature-contract",
    identifier: str = "existing",
) -> dict[str, object]:
    """Return one schema-shaped expected-output row for path/expected; no I/O."""
    return {
        "artifact_kind": kind,
        "id": identifier,
        "path": path,
        "format": "json",
        "expected_sha256": expected,
    }


def prepare(service_io: MemoryService, rows: list[dict[str, object]], **fields: object):
    """Invoke prepare-agent with rows through the real service; return the result."""
    return invoke(
        service_io,
        "prepare-agent",
        {
            "skill_id": "validate-discovery-artifacts",
            "selected_ids": ["existing"],
            "paths": ["application"],
            "expected_outputs": rows,
            "execution_context": "standalone",
            "complexity": "C1",
        },
        **fields,
    )


def count(result_summary: JsonObject, name: str) -> int:
    """Return the named summary count from result_summary; fail when absent."""
    counts = result_summary["counts"]
    assert isinstance(counts, tuple)
    # The summary lists each count once; the first matching row is the value.
    for row in counts:
        if isinstance(row, JsonObject) and row["name"] == name:
            value = row["value"]
            assert isinstance(value, int)
            return value
    raise AssertionError(name)


def test_valid_rows_pin_existing_content_and_absence_without_writes(
    service_io: MemoryService,
) -> None:
    """Return exit 0, the prior bytes of the existing output and no artifact for
    the absent one; the memory store and writer are untouched.
    """
    service_io.disk.store.put(EXISTING, EXISTING_BYTES)
    before = dict(service_io.disk.store.files)
    digest = sha256(EXISTING_BYTES).hexdigest()
    rows = [
        output_row(EXISTING, digest),
        output_row(CONTRACTS + "/planned.json", None, identifier="planned"),
    ]

    result = prepare(service_io, rows)

    assert result.ok and result.exit_code == 0 and result.findings == ()
    assert [row.path for row in result.artifacts] == [EXISTING]
    row = result.artifacts[0]
    assert row.status == "planned" and row.kind == "feature-contract"
    assert row.sha256 == digest and row.content == EXISTING_BYTES.decode("utf-8")
    assert result.input_manifest is not None
    assert any(file.path == EXISTING for file in result.input_manifest.files)
    assert count(result.summary, "expected_outputs") == 2
    assert count(result.summary, "existing_outputs") == 1
    assert result.summary["receipt_ref"] is None
    assert result.summary["invocation_ref"] is None
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before


@pytest.mark.parametrize(
    "present,expected",
    [(True, None), (True, "0" * 64), (False, "0" * 64)],
)
def test_digest_mismatch_blocks_without_artifact_rows(
    service_io: MemoryService, present: bool, expected: str | None
) -> None:
    """Return exit 1 with PREPARE_OUTPUT_DIGEST when presence and digest disagree."""
    if present:
        service_io.disk.store.put(EXISTING, EXISTING_BYTES)

    result = prepare(service_io, [output_row(EXISTING, expected)])

    assert result.exit_code == 1 and not result.ok
    assert [finding.code for finding in result.findings] == ["PREPARE_OUTPUT_DIGEST"]
    assert result.findings[0].artifact_path == EXISTING
    assert result.artifacts == () and result.input_manifest is not None
    assert service_io.writer_calls == 0


def test_duplicate_path_is_refused_once_per_repeat(service_io: MemoryService) -> None:
    """Return exit 1 with one PREPARE_OUTPUT_LOCATION finding for the repeated row."""
    rows = [
        output_row(CONTRACTS + "/planned.json", None, identifier="planned"),
        output_row(CONTRACTS + "/planned.json", None, identifier="other"),
    ]

    result = prepare(service_io, rows)

    assert result.exit_code == 1 and result.artifacts == ()
    assert [finding.code for finding in result.findings] == ["PREPARE_OUTPUT_LOCATION"]
    assert service_io.writer_calls == 0


def test_binary_existing_output_is_refused(service_io: MemoryService) -> None:
    """Return exit 1 with PREPARE_OUTPUT_TEXT for a non-UTF-8 existing output."""
    path = EVIDENCE + "/payload.bin"
    content = b"\xff\xfe\x00binary"
    service_io.disk.store.put(path, content)
    row = output_row(
        path, sha256(content).hexdigest(), kind="evidence-payload", identifier="payload"
    )

    result = prepare(service_io, [row])

    assert result.exit_code == 1 and result.artifacts == ()
    assert [finding.code for finding in result.findings] == ["PREPARE_OUTPUT_TEXT"]
    assert service_io.writer_calls == 0


def test_path_outside_the_kind_location_is_refused(service_io: MemoryService) -> None:
    """Return exit 1 with PREPARE_OUTPUT_LOCATION for a contract under reports."""
    row = output_row("docs/migration/discovery/reports/feature.json", None)

    result = prepare(service_io, [row])

    assert result.exit_code == 1 and result.artifacts == ()
    assert [finding.code for finding in result.findings] == ["PREPARE_OUTPUT_LOCATION"]
    assert "PATH_WRITE_DENIED" in result.findings[0].message
    assert service_io.writer_calls == 0


def test_every_defective_row_is_reported_in_one_round_trip(
    service_io: MemoryService,
) -> None:
    """Return one finding per defective row and no artifact for the valid row."""
    service_io.disk.store.put(EXISTING, EXISTING_BYTES)
    rows = [
        output_row(EXISTING, sha256(EXISTING_BYTES).hexdigest()),
        output_row(CONTRACTS + "/missing.json", "1" * 64, identifier="missing"),
        output_row("docs/migration/discovery/reports/x.json", None, identifier="x"),
    ]

    result = prepare(service_io, rows)

    assert result.exit_code == 1 and result.artifacts == ()
    assert sorted(finding.code for finding in result.findings) == [
        "PREPARE_OUTPUT_DIGEST",
        "PREPARE_OUTPUT_LOCATION",
    ]


def test_non_structural_mode_is_inapplicable(service_io: MemoryService) -> None:
    """Return exit 2 with SERVICE_MODE for a root report mode; no artifact or write."""
    result = prepare(service_io, [output_row(EXISTING, None)], mode="planning")

    assert result.exit_code == 2 and result.artifacts == ()
    assert result.findings[0].code == "SERVICE_MODE"
    assert service_io.writer_calls == 0


def test_finalize_agent_remains_refused_under_local_user(
    service_io: MemoryService,
) -> None:
    """Return exit 3 with SERVICE_AUTHORITY before capture for local finalize."""
    result = invoke(
        service_io,
        "finalize-agent",
        mode="agent-output",
        invocation_ref="protected-alpha-00000001",
    )

    assert result.exit_code == 3 and result.findings[0].code == "SERVICE_AUTHORITY"
    assert result.input_manifest is None and service_io.writer_calls == 0


def test_host_markers_on_prepare_are_still_refused(service_io: MemoryService) -> None:
    """Return exit 3 with SERVICE_AUTHORITY when prepare carries an invocation ref."""
    result = prepare(
        service_io,
        [output_row(EXISTING, None)],
        invocation_ref="protected-alpha-00000001",
    )

    assert result.exit_code == 3 and result.findings[0].code == "SERVICE_AUTHORITY"
    assert result.input_manifest is None and service_io.writer_calls == 0
