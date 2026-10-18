"""Check runtime execution and expectation support while retaining mixed history."""

from __future__ import annotations

from typing import TYPE_CHECKING

from drm_copilot_discovery.models import JsonObject, JsonValue

if TYPE_CHECKING:
    from drm_copilot_discovery.claim_rules import ClaimContext
    from drm_copilot_discovery.references import ArtifactRecord

_EXECUTED = ("observed", "passed", "failed")


def has_text(value: JsonValue) -> bool:
    """Recognize supplied text without coercion or inference about its truth."""
    return isinstance(value, str) and bool(value.strip())


def environment_identity(value: JsonValue) -> tuple[JsonValue, ...] | None:
    """Identify the four core environment fields without interpreting extensions."""
    if not isinstance(value, JsonObject):
        return None
    # An omitted client differs from an explicitly declared null client.
    if not all(
        has_text(value.get(key)) for key in ("id", "platform", "operating_mode")
    ):
        return None
    if "client_id" not in value or (
        value["client_id"] is not None and not has_text(value["client_id"])
    ):
        return None
    return tuple(
        value.get(key) for key in ("id", "platform", "operating_mode", "client_id")
    )


def _capture_state(document: JsonObject, name: str) -> JsonValue:
    """Read observed pre/post state without treating the capture plan as execution."""
    value = document.get(name)
    return value.get("observed_state") if isinstance(value, JsonObject) else None


def _execution(
    record: ArtifactRecord, value: JsonObject, pointer: str, claims: ClaimContext
) -> bool:
    """Emit execution defects and return whether this row has complete runtime proof."""
    state = value.get("result_status")
    if state not in _EXECUTED:
        return False
    valid = True
    environment = value.get("environment")
    if state in ("passed", "failed") and not has_text(value.get("expected_result")):
        claims.add(
            "RUNTIME_EXPECTATION",
            record,
            pointer,
            "Comparison results require a known expected result.",
        )
        valid = False
    if pointer and not has_text(value.get("observed_result")):
        claims.add(
            "RUNTIME_OBSERVATION",
            record,
            pointer,
            "An executed run requires a recorded observation.",
        )
        valid = False
    if environment_identity(environment) is None or not claims.proof(
        record, pointer + "/evidence_refs", runtime=True, environment=environment
    ):
        claims.add(
            "RUNTIME_EVIDENCE",
            record,
            pointer,
            "Execution requires runtime proof in the recorded environment.",
        )
        valid = False
    # Both captures are required after a scenario/run claims execution.
    for name in ("pre_state_capture", "post_state_capture"):
        if not has_text(_capture_state(value, name)) or not claims.proof(
            record,
            pointer + "/" + name + "/evidence_refs",
            runtime=True,
            environment=environment,
        ):
            claims.add(
                "RUNTIME_CAPTURE",
                record,
                pointer + "/" + name,
                "Execution requires matching pre/post capture evidence.",
            )
            valid = False
    return valid


def _source_basis(record: ArtifactRecord, claims: ClaimContext) -> bool:
    """Require a linked known observation relevant to the stated observation plan."""
    plan = record.document.get("observation_plan")
    # Only explicitly planned dimensions can supply a known behavior expectation.
    dimensions = (
        tuple(row.get("dimension") for row in plan if isinstance(row, JsonObject))
        if isinstance(plan, tuple)
        else ()
    )
    for feature in claims.targets(record, "/feature_refs"):
        if feature.kind != "feature-contract":
            continue
        # Known criteria provide a direct expectation; target decisions alone do not.
        criteria = feature.document.get("acceptance_criteria")
        if isinstance(criteria, tuple):
            for position, criterion in enumerate(criteria):
                if (
                    isinstance(criterion, JsonObject)
                    and criterion.get("readiness") == "ready"
                    and has_text(criterion.get("expected_result"))
                    and claims.proof(
                        feature, f"/acceptance_criteria/{position}/evidence_refs"
                    )
                ):
                    return True
        # A known trigger cannot stand in for an unknown planned state transition.
        for dimension in dimensions:
            if not isinstance(dimension, str):
                continue
            value = feature.document.get(dimension)
            pointer = "/" + dimension
            if dimension == "state_transitions" and isinstance(value, JsonObject):
                value = value.get("behavior")
                pointer += "/behavior"
            if (
                isinstance(value, JsonObject)
                and value.get("observation_state") == "verified"
                and has_text(value.get("statement"))
                and claims.proof(feature, pointer + "/evidence_refs")
            ):
                return True
    return False


def _basis(
    record: ArtifactRecord,
    runs: tuple[tuple[JsonObject, bool], ...],
    claims: ClaimContext,
) -> None:
    """Require recorded support for a declared known basis without ordering history."""
    document = record.document
    basis, expected = document.get("expected_result_basis"), document.get(
        "expected_result"
    )
    if basis == "unknown":
        if expected is not None or document.get("result_status") in (
            "passed",
            "failed",
        ):
            claims.add(
                "RUNTIME_EXPECTATION",
                record,
                "/expected_result",
                "Unknown expectations cannot establish comparison results.",
            )
        return
    supported = False
    # Current pass evidence is not evidence of a separate prior observation.
    if basis == "prior-runtime-observation":
        supported = any(
            valid
            and run.get("result_status") == "observed"
            and run.get("expected_result") is None
            and environment_identity(run.get("environment"))
            == environment_identity(document.get("environment"))
            for run, valid in runs
        )
    elif basis == "source-contract":
        supported = _source_basis(record, claims)
    if not has_text(expected) or not supported:
        claims.add(
            "RUNTIME_EXPECTATION",
            record,
            "/expected_result_basis",
            "Known expectations require recorded supporting provenance.",
        )


def validate_runtime_claim(record: ArtifactRecord, claims: ClaimContext) -> None:
    """Check a summary and every run through an existing pure claim context.

    A summary matches one run on status, expectation, environment and observed
    pre/post states. Other historical runs may differ. Prior-runtime basis uses
    a separate evidenced first observation, without claiming chronological order.
    """
    document = record.document
    state = document.get("result_status")
    _execution(record, document, "", claims)
    raw_runs = document.get("runs")
    runs: list[tuple[JsonObject, bool]] = []
    if isinstance(raw_runs, tuple):
        # Preserve physical array pointers even when earlier rows are malformed.
        for position, run in enumerate(raw_runs):
            if isinstance(run, JsonObject):
                runs.append((run, _execution(record, run, f"/runs/{position}", claims)))
    _basis(record, tuple(runs), claims)
    if state == "not-run" and runs:
        claims.add(
            "RUNTIME_SUMMARY",
            record,
            "/runs",
            "A not-run scenario cannot contain recorded runs.",
        )
    if state in _EXECUTED:
        # Existing values identify support without a latest-run field or ordering rule.
        supported = any(
            run.get("result_status") == state
            and run.get("expected_result") == document.get("expected_result")
            and environment_identity(run.get("environment"))
            == environment_identity(document.get("environment"))
            and _capture_state(run, "pre_state_capture")
            == _capture_state(document, "pre_state_capture")
            and _capture_state(run, "post_state_capture")
            == _capture_state(document, "post_state_capture")
            for run, _ in runs
        )
        if not supported:
            claims.add(
                "RUNTIME_SUMMARY",
                record,
                "/runs",
                "No run supports the scenario result and known expectation.",
            )
    if state == "passed" and document.get("unresolved_findings"):
        claims.add(
            "RUNTIME_UNRESOLVED",
            record,
            "/unresolved_findings",
            "A passed scenario cannot retain unresolved findings.",
        )
