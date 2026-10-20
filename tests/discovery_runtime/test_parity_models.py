"""Check retained parity outcomes without relying on bounded finding absence."""

from __future__ import annotations

from dataclasses import FrozenInstanceError, replace
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery import parity_entry_rules, parity_rules
from drm_copilot_discovery.claim_rules import ClaimContext
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.parity_models import ParityValidation
from drm_copilot_discovery.parity_rules import (
    ParityValidation as ExportedParityValidation,
)
from drm_copilot_discovery.parity_rules import validate_parity
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError

from tests.discovery_runtime.parity_test_support import (
    implementation,
    parity_row,
    parity_snapshot,
    source_contract,
)
from tests.discovery_runtime.test_coverage_scope import profile_with
from tests.discovery_runtime.test_dimension_rules import (
    obligation_profile as obligation_profile,
)
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.evidence_rules import EvidenceValidation
    from drm_copilot_discovery.models import ParseLimits
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.references import ReferenceIndex


def test_existing_findings_constructor_and_reexport_preserve_identity() -> None:
    """Keep first-positional findings and default entries; return None, no I/O."""
    result = ParityValidation(())
    assert ExportedParityValidation is ParityValidation
    assert result.findings == () and result.entries == ()
    with pytest.raises(FrozenInstanceError):
        result.__setattr__("entries", ())


def test_completed_outcome_keeps_authored_state_and_actual_proof_distinct(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Keep authored and proven values separate in a complete target result.

    obligation_profile (ProfileV2) and snapshot_catalog (SchemaCatalog) build the
    real captured graph. Returns None; no external effects occur.
    """
    snapshot = parity_snapshot(obligation_profile, snapshot_catalog)
    result = validate_parity(snapshot, complete=True)
    entry = result.entries[0]
    # Fixed optional axes remain not-required rather than invented passing proof.
    dimensions = {item.name: item for item in entry.dimensions}

    assert result.findings == () and len(result.entries) == 1
    assert entry.authored_state == "full" and entry.required is True
    assert entry.valid and entry.complete and not entry.duplicate
    assert entry.approval_valid is None
    assert entry.implementation_valid is True and entry.evidence_valid is True
    assert entry.verification_valid is True
    assert dimensions["online"].required and dimensions["online"].proof_valid
    assert dimensions["offline"].applicability == "not-required"
    assert dimensions["mobile"].verification is None
    assert entry.source is not None and entry.target is not None
    assert entry.client_id == "browser" and entry.pointer == "/entries/0"
    with pytest.raises(FrozenInstanceError):
        entry.__setattr__("complete", False)
    with pytest.raises(FrozenInstanceError):
        dimensions["online"].__setattr__("proof_valid", False)


@pytest.mark.parametrize("state", ["missing", "unassessed", "partial", "conflicting"])
def test_incomplete_authored_states_never_become_complete(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog, state: str
) -> None:
    """Retain an incomplete authored state without inventing complete proof.

    obligation_profile (ProfileV2), snapshot_catalog (SchemaCatalog) and state
    (str) build the captured case. Returns None without I/O.
    """
    source = source_contract(obligation_profile)
    target = implementation(obligation_profile, source)
    row = parity_row(
        obligation_profile,
        source,
        target,
        parity_state=state,
        dimensions={},
        validation_status="not-run",
    )
    snapshot = parity_snapshot(
        obligation_profile, snapshot_catalog, source=source, target=target, row=row
    )
    result = validate_parity(snapshot, complete=True)

    assert result.entries[0].authored_state == state
    assert not result.entries[0].complete
    assert result.entries[0].verification_valid is None
    # Completion diagnostics remain independent from the authored state label.
    assert any(item.code == "PARITY_INCOMPLETE" for item in result.findings)


def test_every_duplicate_row_is_excluded_from_validated_completion(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Reject both competing rows rather than retaining the first as complete.

    obligation_profile (ProfileV2) and snapshot_catalog (SchemaCatalog) supply
    captured graph authority. Returns None without I/O.
    """
    source = source_contract(obligation_profile)
    target = implementation(obligation_profile, source)
    row = parity_row(obligation_profile, source, target)
    snapshot = parity_snapshot(
        obligation_profile,
        snapshot_catalog,
        source=source,
        target=target,
        matrix_fields={"entries": [row, {**row, "id": "second"}]},
    )
    result = validate_parity(snapshot, complete=True)

    assert len(result.entries) == 2
    # A later duplicate cannot leave the first row counted as verified.
    assert all(
        item.duplicate and not item.valid and not item.complete
        for item in result.entries
    )
    # Retained duplicate flags supplement the existing actionable finding.
    assert any(item.code == "PARITY_DUPLICATE" for item in result.findings)


def test_invalid_source_preserves_an_invalid_authored_row(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Retain the authored row when its source ownership cannot be resolved.

    obligation_profile (ProfileV2) and snapshot_catalog (SchemaCatalog) build the
    captured graph. Returns None; neither inputs nor external state are changed.
    """
    source = source_contract(obligation_profile)
    target = implementation(obligation_profile, source)
    row = parity_row(obligation_profile, source, target, feature_id="absent")
    result = validate_parity(
        parity_snapshot(
            obligation_profile, snapshot_catalog, source=source, target=target, row=row
        ),
        complete=True,
    )

    assert len(result.entries) == 1
    entry = result.entries[0]
    assert entry.source is None and entry.required is None
    assert entry.authored_state == "full" and not entry.valid and not entry.complete


def test_upstream_findings_truncation_cannot_certify_complete_parity(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Prevent truncated upstream diagnostics from certifying target parity.

    obligation_profile (ProfileV2) and snapshot_catalog (SchemaCatalog) supply
    the captured graph. Returns None without I/O or shared-input mutation.
    """
    snapshot = parity_snapshot(obligation_profile, snapshot_catalog)
    index = replace(
        index_references(snapshot),
        findings=(
            Finding(
                code="FINDINGS_LIMIT",
                message="Diagnostics were truncated.",
                next_action="Resolve earlier defects and repeat validation.",
            ),
        ),
    )

    result = validate_parity(snapshot, complete=True, index=index)

    assert len(result.entries) == 1
    assert result.entries[0].authored_state == "full"
    assert not result.entries[0].valid and not result.entries[0].complete


def test_missing_target_proof_is_retained_even_when_authored_state_is_full(
    obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Retain evidence failure even when the authored state claims full parity.

    obligation_profile (ProfileV2) and snapshot_catalog (SchemaCatalog) supply
    the captured graph. Returns None without I/O or shared-input mutation.
    """
    result = validate_parity(
        parity_snapshot(
            obligation_profile, snapshot_catalog, proof_fields={"path": None}
        ),
        complete=True,
    )
    entry = result.entries[0]
    assert entry.authored_state == "full" and entry.evidence_valid is False
    assert not entry.valid and not entry.complete
    # Dimension result booleans retain the same independent evidence rejection.
    assert any(item.proof_valid is False for item in entry.dimensions)


def test_own_diagnostic_truncation_invalidates_an_otherwise_completed_row(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Cap a real collector without replacing any semantic proof assessment.

    obligation_profile (ProfileV2) and snapshot_catalog (SchemaCatalog) construct
    captured inputs. monkeypatch (pytest.MonkeyPatch) restores the local factory
    replacement. Returns None; no external effects occur.
    """
    source = source_contract(obligation_profile)
    target = implementation(obligation_profile, source)
    row = parity_row(obligation_profile, source, target)
    snapshot = parity_snapshot(
        obligation_profile,
        snapshot_catalog,
        source=source,
        target=target,
        matrix_fields={
            "entries": [
                row,
                {**row, "id": "invalid", "feature_id": "absent", "client_id": "absent"},
            ]
        },
    )

    def limited_context(
        index: ReferenceIndex, evidence: EvidenceValidation, limit: int
    ) -> ClaimContext:
        """Return a fresh ClaimContext capped at one finding.

        index (ReferenceIndex) and evidence (EvidenceValidation) retain actual
        assessments; limit (int) is the caller's positive diagnostic capacity.
        Only the returned local context is initialized; no I/O occurs.
        """
        assert limit >= 1
        return ClaimContext(index, evidence, 1)

    monkeypatch.setattr(parity_rules, "ClaimContext", limited_context)
    result = validate_parity(snapshot, complete=True)

    assert len(result.entries) == 2
    assert result.entries[0].evidence_valid is True
    # Truncated diagnostics cannot certify even the independently passing row.
    assert all(not item.valid and not item.complete for item in result.entries)
    assert result.findings[0].code == "FINDINGS_LIMIT"


@pytest.mark.parametrize("limit_name", ["artifact_records", "document_bytes"])
def test_retained_input_budget_rejects_before_target_proof_construction(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
    limit_name: str,
) -> None:
    """Bound profile/catalog matrix retention before proof construction.

    obligation_profile (ProfileV2) and snapshot_catalog (SchemaCatalog) provide
    captured inputs. limit_name (str) selects a root-configured capacity of one;
    monkeypatch (pytest.MonkeyPatch) records attempted proof allocation and
    restores the local patch. Returns None; no external effects occur.
    """
    profile = profile_with(obligation_profile, snapshot_catalog, limits={limit_name: 1})
    snapshot = parity_snapshot(profile, snapshot_catalog)
    calls: list[tuple[object, ...]] = []

    def prohibited_proof(*arguments: object) -> None:
        """Record object arguments; raise pytest failure instead of returning None."""
        calls.append(arguments)
        pytest.fail("Target proof must not be allocated before retention bounds")

    monkeypatch.setattr(parity_rules, "TargetProof", prohibited_proof)
    with pytest.raises(ReportLimitError, match="^REPORT_LIMIT:"):
        validate_parity(snapshot, complete=True)
    assert calls == []


def test_aggregate_entry_work_is_reserved_before_source_resolution(
    obligation_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Bound entry scans on a real profile/catalog graph using a local budget.

    obligation_profile (ProfileV2) and snapshot_catalog (SchemaCatalog) provide
    captured inputs. monkeypatch (pytest.MonkeyPatch) narrows only the entry work
    budget, records forbidden source resolution and restores its local patches.
    Returns None; all semantic inputs stay real and no I/O occurs.
    """
    snapshot = parity_snapshot(obligation_profile, snapshot_catalog)
    calls: list[tuple[object, ...]] = []

    def bounded_work(limits: ParseLimits) -> ReportBudget:
        """Return a fresh ReportBudget with its local work counter set to 64.

        limits (ParseLimits) retains the byte/record policy. Only the returned
        budget's work_left counter is initialized; no I/O or input mutation occurs.
        """
        result = ReportBudget(limits)
        result.work_left = 64
        return result

    def prohibited_source(*arguments: object) -> None:
        """Record object arguments; raise pytest failure instead of returning None."""
        calls.append(arguments)
        pytest.fail("Entry work must be reserved before resolving source ownership")

    monkeypatch.setattr(parity_entry_rules, "ReportBudget", bounded_work)
    monkeypatch.setattr(
        parity_entry_rules.ParityEntryRules, "source", prohibited_source
    )
    with pytest.raises(ReportLimitError, match="^REPORT_LIMIT:"):
        validate_parity(snapshot, complete=True)
    assert calls == []
