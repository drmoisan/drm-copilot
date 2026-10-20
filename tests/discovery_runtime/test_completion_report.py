"""Verify pure completion projection and explicit legacy-only helpers in memory."""

from __future__ import annotations

import json
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import completion_report
from drm_copilot_discovery.completion_report import (
    build_completion_report,
    build_completion_summary,
    completion_preflight,
    completion_summary,
    render_completion_report,
)
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError

from tests.discovery_runtime.test_coverage_scope import profile_with
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.discovery_runtime.validation_test_support import captured, mode_profile
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.findings import Severity
    from drm_copilot_discovery.models import JsonObject, ParseLimits
    from drm_copilot_discovery.snapshot import DiscoverySnapshot
    from drm_copilot_discovery.validation import ValidationMode
    from pytest import MonkeyPatch


@pytest.fixture
def completion_snapshot(snapshot_catalog: SchemaCatalog) -> DiscoverySnapshot:
    """Return a fresh captured draft using immutable schemas (SchemaCatalog).

    The pure summary receives validity separately; this fixture performs no
    semantic evaluation, mutation of shared data or runtime filesystem access.
    """
    return captured(mode_profile(snapshot_catalog, draft=True), snapshot_catalog)


def diagnostic(
    code: str,
    *,
    action: str = "Inspect the referenced behavior.",
    severity: Severity = "error",
) -> Finding:
    """Return a local Finding from code/action (str) and severity (Severity).

    Fixed path/context makes index preservation observable. Invalid arguments
    raise the existing Finding ValueError; no I/O or external mutation occurs.
    """
    return Finding(
        code=code,
        next_action=action,
        severity=severity,
        message="Retain the original diagnostic.",
        artifact_path="docs/behavior.json",
        pointer="/criteria/0",
        related_ids=("feature",),
        related_paths=("src/behavior.cs",),
    )


@pytest.mark.parametrize(
    "mode,label",
    [
        ("structural", "Structural validation"),
        ("discovery-complete", "Discovery completion"),
        ("parity-complete", "Parity completion"),
        ("planning", "Planning prerequisite"),
    ],
)
@pytest.mark.parametrize("available", [False, True])
def test_mode_and_availability_do_not_invent_readiness(
    completion_snapshot: DiscoverySnapshot,
    mode: ValidationMode,
    label: str,
    available: bool,
) -> None:
    """Return None after checking fixed labels against a captured snapshot.

    completion_snapshot (DiscoverySnapshot) supplies bounds. mode (ValidationMode)
    and label (str) select presentation; available (bool) controls availability
    independently of retained error severity. All state is local.
    """
    finding = diagnostic("UNKNOWN_CODE")
    result = as_object(
        to_plain_value(
            completion_summary(
                completion_snapshot,
                mode=mode,
                findings=(finding,),
                structural_valid=available,
            )
        )
    )
    assert result["assessment_state"] == ("available" if available else "unavailable")
    assert result["mode_label"] == label
    assert result["retained_finding_counts"] == {"error": 1, "warning": 0, "info": 0}
    assert result["planning_prerequisite"] == (
        "discovery-complete" if available and mode == "planning" else None
    )
    assert result["blocking_findings"] == [0]
    assert (
        not {"readiness", "counts", "output_valid", "validation_result"} & result.keys()
    )


@pytest.mark.parametrize(
    "prerequisite", ["none", "discovery-complete", "parity-complete"]
)
def test_planning_exposes_only_configured_prerequisite(
    snapshot_catalog: SchemaCatalog, prerequisite: str
) -> None:
    """Return None after projecting an exact str prerequisite with SchemaCatalog.

    No planning evaluation or other mode is invoked; fixtures remain in memory.
    """
    snapshot = captured(
        mode_profile(snapshot_catalog, planning=prerequisite), snapshot_catalog
    )
    result = completion_summary(
        snapshot, mode="planning", findings=(), structural_valid=True
    )
    assert result["planning_prerequisite"] == prerequisite
    assert to_plain_value(result["retained_finding_counts"]) == {
        "error": 0,
        "warning": 0,
        "info": 0,
    }
    assert result["next_actions"] == ()


def test_exact_actions_preserve_every_original_diagnostic_index(
    completion_snapshot: DiscoverySnapshot, monkeypatch: MonkeyPatch
) -> None:
    """Return None after indexing repeated/exactly different actions.

    completion_snapshot (DiscoverySnapshot) supplies limits; monkeypatch
    (MonkeyPatch) locally forbids projection to prove no validation reentry.
    """
    from drm_copilot_discovery import validation

    def forbidden(*args: object, **kwargs: object) -> None:
        """Reject any projection attempt (object arguments) with AssertionError."""
        raise AssertionError("Pure completion summary must not assess the graph")

    monkeypatch.setattr(validation, "report_projection", forbidden)
    findings = (
        diagnostic("STALE_REFERENCE", action="Inspect."),
        diagnostic("CONFLICTING_REFERENCE", action="Inspect."),
        diagnostic("INCOMPLETE_ARTIFACT", action="inspect.", severity="warning"),
        diagnostic("PENDING_SCENARIO", action=" Inspect.", severity="info"),
        diagnostic("FINDINGS_LIMIT", action="Inspect."),
    )
    # Capture all original fields so action grouping cannot erase finding context.
    before = tuple(item.to_dict() for item in findings)
    result = as_object(
        to_plain_value(
            completion_summary(
                completion_snapshot,
                mode="discovery-complete",
                findings=findings,
                structural_valid=True,
            )
        )
    )
    assert result["retained_finding_counts"] == {"error": 3, "warning": 1, "info": 1}
    assert result["blocking_findings"] == [0, 1, 4]
    assert result["warning_findings"] == [2]
    assert result["findings_complete"] is False
    assert result["next_actions"] == [
        {"action": " Inspect.", "finding_indices": [3]},
        {"action": "Inspect.", "finding_indices": [0, 1, 4]},
        {"action": "inspect.", "finding_indices": [2]},
    ]
    # Every original diagnostic field survives exact action deduplication.
    assert tuple(item.to_dict() for item in findings) == before


@pytest.mark.parametrize("order", [(0, 1, 2), (2, 0, 1), (1, 2, 0)])
def test_action_index_permutation_property(
    completion_snapshot: DiscoverySnapshot, order: tuple[int, ...]
) -> None:
    """Return None after proving index meaning survives finite tuple permutations.

    completion_snapshot (DiscoverySnapshot) supplies limits; order (tuple[int])
    changes only caller positions, never action text, contents or global state.
    """
    originals = (diagnostic("A"), diagnostic("B", action="Other."), diagnostic("C"))
    # Vary only the supplied tuple ordering to check every returned index meaning.
    findings = tuple(originals[index] for index in order)
    projected = completion_summary(
        completion_snapshot, mode="structural", findings=findings, structural_valid=True
    )
    repeated = completion_summary(
        completion_snapshot, mode="structural", findings=findings, structural_valid=True
    )
    assert projected == repeated
    rows = cast("tuple[JsonObject, ...]", projected["next_actions"])
    # Resolve indexed context through the original tuple without inferring findings.
    for row in rows:
        # Every grouped index must still address its original exact action text.
        for index in cast("tuple[int, ...]", row["finding_indices"]):
            assert findings[index].next_action == row["action"]


@pytest.mark.parametrize("mode", ["agent-output", "", "custom", None, True, {}])
def test_unsupported_modes_fail_before_any_preflight(
    completion_snapshot: DiscoverySnapshot, monkeypatch: MonkeyPatch, mode: object
) -> None:
    """Return None after unsupported object modes fail explicitly before traversal.

    completion_snapshot (DiscoverySnapshot) remains unchanged. monkeypatch
    (MonkeyPatch) replaces only local preflight; no authority escapes ValueError.
    """
    calls: list[object] = []
    monkeypatch.setattr(completion_report, "completion_preflight", calls.append)
    with pytest.raises(ValueError, match="root validation mode"):
        completion_summary(
            completion_snapshot,
            mode=cast("ValidationMode", mode),
            findings=(),
            structural_valid=True,
        )
    with pytest.raises(ValueError, match="root validation mode"):
        build_completion_report(completion_snapshot, mode=cast("ValidationMode", mode))
    assert calls == []


@pytest.mark.parametrize("fault", ["list", "member", "validity"])
def test_malformed_summary_arguments_fail_explicitly(
    completion_snapshot: DiscoverySnapshot, fault: str
) -> None:
    """Return None after one str-selected argument defect raises ValueError.

    completion_snapshot (DiscoverySnapshot) stays unchanged; fault (str) selects
    a local invalid argument, with no external effects.
    """
    findings = cast("tuple[Finding, ...]", [] if fault == "list" else (None,))
    validity = cast("bool", 1 if fault == "validity" else True)
    with pytest.raises(ValueError, match="Completion"):
        completion_summary(
            completion_snapshot,
            mode="structural",
            findings=() if fault == "validity" else findings,
            structural_valid=validity,
        )


def test_public_preflight_requires_a_captured_snapshot() -> None:
    """Return None after an invalid object raises ValueError without effects."""
    with pytest.raises(ValueError, match="captured v2"):
        completion_preflight(cast("DiscoverySnapshot", None))


@pytest.mark.parametrize(
    "action", ["x" * 9000, "\U0001f600" * 3000], ids=["ascii", "unicode"]
)
def test_action_encoding_is_bounded_before_a_summary_can_escape(
    completion_snapshot: DiscoverySnapshot,
    snapshot_catalog: SchemaCatalog,
    action: str,
) -> None:
    """Return None after oversized str actions exceed a real profile byte limit.

    completion_snapshot (DiscoverySnapshot) and snapshot_catalog (SchemaCatalog)
    form a local profile; action (str) retains its actual full payload.
    ReportLimitError is required without output or external effects.
    """
    profile = profile_with(
        completion_snapshot.profile,
        snapshot_catalog,
        limits={"document_bytes": 8192},
    )
    snapshot = replace(completion_snapshot, profile=profile)
    with pytest.raises(ReportLimitError):
        completion_summary(
            snapshot,
            mode="structural",
            findings=(diagnostic("LARGE_ACTION", action=action),),
            structural_valid=True,
        )


def test_grouping_reserves_work_before_visiting_supplied_findings(
    completion_snapshot: DiscoverySnapshot, monkeypatch: MonkeyPatch
) -> None:
    """Return None after an insufficient work reservation fails before retention.

    completion_snapshot (DiscoverySnapshot) supplies bounds; monkeypatch
    (MonkeyPatch) installs a local budget with one fewer work unit than needed.
    Counters remain visible; no global state, timing or external effects persist.
    """
    reservations: list[int] = []

    class BoundedBudget(ReportBudget):
        """Keep inherited JSON bounds but expose a test-local work ceiling.

        Construction replaces only the local remaining work. work records each
        attempted reservation then uses the real guard; no caller data mutates.
        """

        def __init__(self, limits: ParseLimits) -> None:
            """Initialize limits (ParseLimits); return None with local work=3."""
            super().__init__(limits)
            self.work_left = 3

        def work(self, count: int) -> None:
            """Record count (int); return None or propagate ReportLimitError."""
            reservations.append(count)
            super().work(count)

    monkeypatch.setattr(completion_report, "ReportBudget", BoundedBudget)
    with pytest.raises(ReportLimitError):
        completion_summary(
            completion_snapshot,
            mode="structural",
            findings=(diagnostic("ONE"),),
            structural_valid=True,
        )
    assert reservations == [4]


@pytest.mark.parametrize("versioned", [False, True])
def test_legacy_summary_counts_actual_rows_without_readiness(versioned: bool) -> None:
    """Return None after checking bool-selected true-v1 or unversioned shapes.

    Legacy-only counts preserve caller objects and never grant graph authority.
    """
    coverage: dict[str, object] = {"entries": [{"unit_id": "a"}, {"unit_id": "b"}]}
    parity: dict[str, object] = {"entries": [{"id": "wrong-placeholder"}]}
    # Explicit v1 parity rows take precedence over the unversioned placeholder.
    if versioned:
        coverage["schema_version"] = "1.0.0"
        parity.update(
            schema_version="1.0.0", rows=[{"feature_id": "one"}, {"feature_id": "two"}]
        )
    before = json.dumps([coverage, parity], sort_keys=True)
    summary = build_completion_summary(coverage, parity)
    assert summary == {
        "coverage_ledger": {"present": True, "entry_count": 2},
        "parity_matrix": {"present": True, "entry_count": 2 if versioned else 1},
        "validation_scope": "legacy-artifact-compatibility-only",
    }
    assert "readiness" not in summary
    assert json.dumps([coverage, parity], sort_keys=True) == before
    assert json.loads(render_completion_report(summary)) == summary
    assert render_completion_report(summary) == render_completion_report(summary)


@pytest.mark.parametrize("side", ["coverage", "parity"])
def test_explicit_v2_cannot_pass_through_legacy_helpers(side: str) -> None:
    """Return None after a str-selected explicit v2 artifact fails without effects."""
    artifact: dict[str, object] = {"schema_version": "2.0.0", "entries": []}
    with pytest.raises(ValueError, match="captured v2"):
        build_completion_summary(
            artifact if side == "coverage" else {},
            artifact if side == "parity" else {},
        )


@pytest.mark.parametrize(
    "field,value", [("schema_version", "2.0.0"), ("artifact_kind", "completion-report")]
)
def test_legacy_render_rejects_versioned_authority_envelopes(
    field: str, value: str
) -> None:
    """Return None after versioned str fields fail before compatibility rendering."""
    with pytest.raises(ValueError, match="captured snapshot"):
        render_completion_report({field: value})


def test_empty_legacy_counts_remain_compatibility_only() -> None:
    """Return None after empty dictionaries produce honest local zero row counts."""
    result = build_completion_summary({}, {})
    assert (
        result["coverage_ledger"]
        == result["parity_matrix"]
        == {"present": True, "entry_count": 0}
    )
    assert result["validation_scope"] == "legacy-artifact-compatibility-only"
