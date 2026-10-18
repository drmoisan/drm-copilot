"""Verify honest runtime summaries and execution history using in-memory captures."""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.claim_rules import validate_claims

from tests.discovery_runtime.test_evidence_rules import evidence
from tests.discovery_runtime.test_observation_claims import (
    claim_snapshot,
    contract,
    dimension,
)
from tests.discovery_runtime.test_references import artifact, reference
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.snapshot import ArtifactSnapshot, DiscoverySnapshot


def environment(**changes: object) -> dict[str, object]:
    """Return a fresh explicit runtime context matching the synthetic capture."""
    return {
        "id": "environment",
        "platform": "generic",
        "operating_mode": "online",
        "client_id": None,
        **changes,
    }


def capture(state: str | None) -> dict[str, object]:
    """Keep planned captures distinct from supplied observed-state evidence."""
    return {
        "plan": "Record state.",
        "observed_state": state,
        "evidence_refs": (
            [] if state is None else [reference("evidence-reference", "capture")]
        ),
    }


def execution(
    status: str = "observed", expected: str | None = None, **changes: object
) -> dict[str, object]:
    """Create a fresh run with captures only when execution is actually claimed."""
    executed = status in ("observed", "passed", "failed")
    return {
        "id": "run",
        "timestamp": "2026-01-01T00:00:00Z",
        "environment": environment(),
        "pre_state_capture": capture("before" if executed else None),
        "post_state_capture": capture("after" if executed else None),
        "observed_result": "Recorded behavior." if executed else None,
        "expected_result": expected,
        "result_status": status,
        "evidence_refs": (
            [reference("evidence-reference", "capture")] if executed else []
        ),
        "deviations": (
            [] if executed or status == "not-run" else ["No execution available."]
        ),
        **changes,
    }


def scenario(
    profile: ProfileV2,
    *,
    status: str = "observed",
    expected: str | None = None,
    runs: list[dict[str, object]] | None = None,
    overrides: dict[str, object] | None = None,
    **changes: object,
) -> ArtifactSnapshot:
    """Retain a scenario summary independently from its supplied historical runs."""
    run = execution(status, expected)
    fields = {
        key: value
        for key, value in run.items()
        if key not in ("id", "timestamp", "observed_result")
    }
    fields.update(
        {
            "scenario_id": "scenario",
            "observation_plan": [
                {
                    "id": "plan",
                    "dimension": "trigger",
                    "description": "Observe trigger.",
                }
            ],
            "feature_refs": [reference("feature-contract", "feature")],
            "expected_result_basis": (
                "unknown" if expected is None else "source-contract"
            ),
            "unresolved_findings": [],
            "confidence": "high",
            "runs": (
                runs
                if runs is not None
                else [run] if status in ("observed", "passed", "failed") else []
            ),
            **changes,
            **(overrides or {}),
        }
    )
    return artifact(
        "runtime-characterization-scenario",
        "scenario",
        repository=profile.repository.id,
        fields=fields,
    )


def runtime_snapshot(
    profile: ProfileV2, catalog: SchemaCatalog, *records: ArtifactSnapshot
) -> DiscoverySnapshot:
    """Supply known source context only when a scenario declares that basis."""
    document = records[0].document
    known = (
        document is not None
        and document.get("expected_result_basis") == "source-contract"
    )
    feature = (
        contract(profile, trigger=dimension("verified")) if known else contract(profile)
    )
    return claim_snapshot(profile, catalog, *records, feature)


@pytest.mark.parametrize(
    "status,expected",
    [
        ("observed", None),
        ("observed", "Known behavior."),
        ("passed", "Known behavior."),
        ("failed", "Known behavior."),
    ],
)
def test_execution_claims_use_local_runtime_proof_and_explicit_expectation_semantics(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    status: str,
    expected: str | None,
) -> None:
    """First observations and comparisons remain distinct and structurally valid."""
    record = scenario(snapshot_profile, status=status, expected=expected)
    snapshot = runtime_snapshot(
        snapshot_profile,
        snapshot_catalog,
        record,
        evidence(snapshot_profile),
    )
    assert validate_claims(snapshot).findings == ()


@pytest.mark.parametrize("status", ["not-run", "blocked", "not-applicable"])
def test_unexecuted_plans_remain_valid_without_manufacturing_captures(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, status: str
) -> None:
    """Manual or unavailable execution can honestly stop at a draft or blocked plan."""
    record = scenario(snapshot_profile, status=status)
    snapshot = runtime_snapshot(snapshot_profile, snapshot_catalog, record)
    assert validate_claims(snapshot).findings == ()


@pytest.mark.parametrize("status", ["passed", "failed"])
def test_unknown_expectation_cannot_be_recorded_as_a_comparison_result(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, status: str
) -> None:
    """Runtime evidence establishes observation, not an invented expected result."""
    record = scenario(snapshot_profile, status=status)
    result = validate_claims(
        runtime_snapshot(
            snapshot_profile, snapshot_catalog, record, evidence(snapshot_profile)
        )
    )
    assert {finding.code for finding in result.findings} == {"RUNTIME_EXPECTATION"}
    assert {finding.pointer for finding in result.findings} == {
        "",
        "/expected_result",
        "/runs/0",
    }


@pytest.mark.parametrize("kind", ["source", "test", "documentation", "decision"])
def test_source_or_decision_evidence_cannot_prove_runtime_execution(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, kind: str
) -> None:
    """A valid local checksum does not turn source facts into runtime captures."""
    record = scenario(snapshot_profile)
    result = validate_claims(
        runtime_snapshot(
            snapshot_profile,
            snapshot_catalog,
            record,
            evidence(snapshot_profile, kind=kind),
        )
    )
    assert {finding.code for finding in result.findings} == {
        "RUNTIME_EVIDENCE",
        "RUNTIME_CAPTURE",
    }


@pytest.mark.parametrize("location", ["summary", "run"])
@pytest.mark.parametrize("name", ["pre_state_capture", "post_state_capture"])
@pytest.mark.parametrize("change", ["state", "proof"])
def test_every_executed_level_requires_both_observed_capture_states_and_evidence(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    location: str,
    name: str,
    change: str,
) -> None:
    """A scenario summary cannot supply a missing capture for an individual run."""
    value: dict[str, object] = (
        capture(None)
        if change == "state"
        else {
            "plan": "Record state.",
            "observed_state": "before" if name == "pre_state_capture" else "after",
            "evidence_refs": [],
        }
    )
    run = execution()
    if location == "run":
        run[name] = value
    record = scenario(
        snapshot_profile,
        runs=[run],
        overrides={name: value} if location == "summary" else None,
    )
    result = validate_claims(
        runtime_snapshot(
            snapshot_profile, snapshot_catalog, record, evidence(snapshot_profile)
        )
    )
    pointer = ("" if location == "summary" else "/runs/0") + "/" + name
    assert ("RUNTIME_CAPTURE", pointer) in {
        (finding.code, finding.pointer) for finding in result.findings
    }


@pytest.mark.parametrize(
    "change", ["status", "expectation", "environment", "pre", "post", "absent"]
)
def test_passed_summary_requires_a_run_with_matching_current_claim_values(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, change: str
) -> None:
    """A passed run cannot support another expectation or capture context."""
    run = execution(
        "failed" if change == "status" else "passed",
        "Other expectation." if change == "expectation" else "Known behavior.",
    )
    if change == "environment":
        run["environment"] = environment(id="other")
    if change in ("pre", "post"):
        run[change + "_state_capture"] = capture("different")
    record = scenario(
        snapshot_profile,
        status="passed",
        expected="Known behavior.",
        runs=[] if change == "absent" else [run],
    )
    result = validate_claims(
        runtime_snapshot(
            snapshot_profile, snapshot_catalog, record, evidence(snapshot_profile)
        )
    )
    assert ("RUNTIME_SUMMARY", "/runs") in {
        (item.code, item.pointer) for item in result.findings
    }


@pytest.mark.parametrize("historical", ["failed", "observed", "different-expectation"])
@pytest.mark.parametrize("reverse", [True, False])
def test_mixed_historical_results_do_not_have_to_equal_the_supported_summary(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    historical: str,
    reverse: bool,
) -> None:
    """History is preserved; matching support does not assume array chronology."""
    previous = execution(
        "observed" if historical == "observed" else "failed",
        (
            None
            if historical == "observed"
            else (
                "Old expectation."
                if historical == "different-expectation"
                else "Known behavior."
            )
        ),
        id="previous",
    )
    current = execution("passed", "Known behavior.")
    runs = [current, previous] if reverse else [previous, current]
    record = scenario(
        snapshot_profile, status="passed", expected="Known behavior.", runs=runs
    )
    result = validate_claims(
        runtime_snapshot(
            snapshot_profile, snapshot_catalog, record, evidence(snapshot_profile)
        )
    )
    assert result.findings == ()
    assert record.document is not None
    retained = record.document["runs"]
    assert isinstance(retained, tuple) and len(retained) == 2


@pytest.mark.parametrize(
    "change",
    [
        "unknown-basis",
        "known-basis",
        "observed-summary",
        "missing-observation",
        "run-expectation",
        "not-run-history",
        "unresolved",
    ],
)
def test_malformed_or_contradictory_result_metadata_produces_explicit_findings(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, change: str
) -> None:
    """Known-expectation and summary contradictions fail without changing history."""
    values: dict[str, object] = {}
    status, expected = "passed", "Known behavior."
    runs = [execution("passed", expected)]
    if change == "unknown-basis":
        values["expected_result_basis"] = "unknown"
    elif change == "known-basis":
        expected = None
        values["expected_result_basis"] = "source-contract"
    elif change == "observed-summary":
        status, expected = "observed", None
    elif change == "missing-observation":
        runs[0]["observed_result"] = None
    elif change == "run-expectation":
        runs[0]["expected_result"] = None
    elif change == "not-run-history":
        status, expected = "not-run", None
    else:
        values["unresolved_findings"] = [reference("unspecified-behavior", "question")]
    record = scenario(
        snapshot_profile, status=status, expected=expected, runs=runs, overrides=values
    )
    result = validate_claims(
        runtime_snapshot(
            snapshot_profile, snapshot_catalog, record, evidence(snapshot_profile)
        )
    )
    expected_code = {
        "unknown-basis": "RUNTIME_EXPECTATION",
        "known-basis": "RUNTIME_EXPECTATION",
        "observed-summary": "RUNTIME_SUMMARY",
        "missing-observation": "RUNTIME_OBSERVATION",
        "run-expectation": "RUNTIME_EXPECTATION",
        "not-run-history": "RUNTIME_SUMMARY",
        "unresolved": "RUNTIME_UNRESOLVED",
    }[change]
    assert expected_code in {finding.code for finding in result.findings}


@pytest.mark.parametrize(
    "context",
    [
        None,
        {},
        {"id": "environment"},
        {"id": "environment", "platform": "generic", "operating_mode": "online"},
        {
            "id": "environment",
            "platform": "generic",
            "operating_mode": "online",
            "client_id": 1,
        },
        {
            "id": "environment",
            "platform": "generic",
            "operating_mode": "online",
            "client_id": "other",
        },
    ],
)
def test_runtime_environment_is_explicit_and_matches_capture_identity(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, context: object
) -> None:
    """Missing or substituted environment context cannot inherit another capture."""
    record = scenario(snapshot_profile, environment=context)
    result = validate_claims(
        runtime_snapshot(
            snapshot_profile, snapshot_catalog, record, evidence(snapshot_profile)
        )
    )
    assert "RUNTIME_EVIDENCE" in {finding.code for finding in result.findings}


@pytest.mark.parametrize(
    "change",
    ["unknown", "irrelevant", "criterion", "transition", "unsupported-criterion"],
)
def test_source_expectations_require_relevant_known_behavior_or_evidenced_criteria(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, change: str
) -> None:
    """A label or a known unrelated trigger cannot manufacture expected transitions."""
    fields: dict[str, object] = {"trigger": dimension("verified")}
    if change == "unknown":
        fields = {}
    elif change == "transition":
        fields["state_transitions"] = {"behavior": dimension("verified"), "entries": []}
    elif change in ("criterion", "unsupported-criterion"):
        fields["acceptance_criteria"] = [
            {
                "id": "criterion",
                "readiness": "ready",
                "expected_result": "Known behavior.",
                "evidence_refs": (
                    [reference("evidence-reference", "capture")]
                    if change == "criterion"
                    else []
                ),
            }
        ]
    record = scenario(
        snapshot_profile,
        status="passed",
        expected="Known behavior.",
        observation_plan=[{"id": "plan", "dimension": "state_transitions"}],
    )
    result = validate_claims(
        claim_snapshot(
            snapshot_profile,
            snapshot_catalog,
            record,
            contract(snapshot_profile, **fields),
            evidence(snapshot_profile),
        )
    )
    assert ("RUNTIME_EXPECTATION" in {item.code for item in result.findings}) is (
        change not in ("criterion", "transition")
    )


@pytest.mark.parametrize(
    "change", ["none", "current-only", "invalid-prior", "wrong-environment"]
)
def test_prior_runtime_basis_requires_a_separate_evidenced_observation(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, change: str
) -> None:
    """Prior means separate recorded support without inferring chronology."""
    previous = execution(id="previous")
    if change == "invalid-prior":
        previous["evidence_refs"] = []
    elif change == "wrong-environment":
        previous["environment"] = environment(id="other")
    runs = [execution("passed", "Known behavior.")]
    if change != "current-only":
        runs.append(previous)
    record = scenario(
        snapshot_profile,
        status="passed",
        expected="Known behavior.",
        runs=runs,
        expected_result_basis="prior-runtime-observation",
    )
    result = validate_claims(
        runtime_snapshot(
            snapshot_profile, snapshot_catalog, record, evidence(snapshot_profile)
        )
    )
    assert ("RUNTIME_EXPECTATION" in {item.code for item in result.findings}) is (
        change != "none"
    )
