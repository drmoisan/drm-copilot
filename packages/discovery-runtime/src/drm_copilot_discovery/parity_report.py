"""Project parity from captured assessments while retaining bounded v1 helpers."""

from __future__ import annotations

import re
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.coverage_report import coverage_preflight
from drm_copilot_discovery.models import JsonObject, ParseLimits, to_plain_value
from drm_copilot_discovery.parity_metrics import ParityProjection
from drm_copilot_discovery.parsing import parse_document
from drm_copilot_discovery.rendering import render_pretty_json, sort_rows
from drm_copilot_discovery.report_models import (
    DiscoveryReport,
    ReportBudget,
    bounded_object,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.claim_rules import ClaimValidation
    from drm_copilot_discovery.decision_rules import DecisionValidation
    from drm_copilot_discovery.dimension_rules import DimensionValidation
    from drm_copilot_discovery.evidence_rules import EvidenceValidation
    from drm_copilot_discovery.findings import Finding
    from drm_copilot_discovery.parity_models import ParityValidation
    from drm_copilot_discovery.references import ReferenceIndex
    from drm_copilot_discovery.snapshot import DiscoverySnapshot
    from drm_copilot_discovery.validation import ValidationMode


def parity_preflight(snapshot: DiscoverySnapshot) -> None:
    """Bound captured snapshot before assessment; return None without I/O.

    snapshot must be a DiscoverySnapshot. Reuses accepted semantic-input budgeting;
    ValueError rejects invalid input and ReportLimitError rejects excess. Generated
    reports remain excluded, and this check grants no validation authority.
    """
    coverage_preflight(snapshot)


def unavailable_parity_summary() -> JsonObject:
    """Return explicit unavailable metrics without inventing zero denominators.

    The validator retains failure findings in its envelope. No inputs, effects,
    exceptions or completion claims accompany this fixed immutable JsonObject.
    """
    return JsonObject(
        (
            ("population_state", "unavailable"),
            ("source_features", None),
            ("feature_client_obligations", None),
            ("entries", None),
            ("clients", None),
            ("blockers", None),
            ("unresolved_decisions", None),
            ("metrics", None),
        )
    )


def parity_summary(
    snapshot: DiscoverySnapshot,
    *,
    index: ReferenceIndex,
    evidence: EvidenceValidation,
    claims: ClaimValidation,
    decisions: DecisionValidation,
    dimensions: DimensionValidation,
    parity: ParityValidation,
    findings: tuple[Finding, ...],
) -> JsonObject:
    """Project typed assessments of snapshot into an immutable parity JsonObject.

    snapshot (DiscoverySnapshot), index (ReferenceIndex), evidence
    (EvidenceValidation), claims (ClaimValidation), decisions (DecisionValidation),
    dimensions (DimensionValidation) and parity (ParityValidation) are the
    composer's accepted inputs. findings (tuple[Finding]) retains diagnostics.
    No injected value grants authority. ValueError/ReportLimitError reject invalid
    or excessive input. No I/O, source mutation, approval or publication occurs.
    """
    parity_preflight(snapshot)
    return ParityProjection(
        snapshot, index, evidence, claims, decisions, dimensions, parity, findings
    ).project(unavailable_parity_summary())


def build_parity_report(
    snapshot: DiscoverySnapshot,
    *,
    identifier: str = "parity",
    mode: ValidationMode = "parity-complete",
) -> DiscoveryReport:
    """Return authoritative parity views for captured snapshot and root mode.

    snapshot (DiscoverySnapshot) holds captured inputs. identifier (str) names the
    report; mode (ValidationMode) remains separate from parity completion.
    Lazy composition avoids recursion. Raises ValueError or
    ReportLimitError for invalid/excess input; no I/O or publication occurs.
    """
    from drm_copilot_discovery.validation import report_projection

    parity_preflight(snapshot)
    value = report_projection(
        snapshot, kind="parity-report", identifier=identifier, mode=mode
    )
    return DiscoveryReport(
        document=bounded_object(value, limits=snapshot.profile.limits.parse_limits()),
        limits=snapshot.profile.limits.parse_limits(),
    )


def _legacy_version(value: object) -> bool:
    """Check optional version (object); return whether it explicitly names v1.

    Raises ValueError for non-v1 text or non-string values. Absence supports the
    historical unversioned placeholder only; no graph assurance or I/O occurs.
    """
    if value is None:
        return False
    if not isinstance(value, str) or re.fullmatch(r"1\.\d+\.\d+", value) is None:
        raise ValueError("Use a captured v2 snapshot for discovery parity")
    return True


def parse_parity_matrix(text: str) -> dict[str, object]:
    """Parse compatibility text (str) into a detached bounded dict without I/O.

    Raises ValueError for malformed, duplicate, nonfinite or explicit non-v1
    input. Parsing grants no schema validation or source-to-target assurance.
    """
    parsed = parse_document(text, format="json")
    if not parsed.ok or parsed.value is None:
        raise ValueError("Parity compatibility input requires valid bounded JSON")
    _legacy_version(parsed.value.get("schema_version"))
    return cast("dict[str, object]", to_plain_value(parsed.value))


def build_parity_rows(
    artifact: dict[str, object],
) -> tuple[list[dict[str, object]], dict[str, object]]:
    """Project artifact (dict) into detached sorted rows and total_entries.

    Returns (list[dict], dict). Explicit v1 uses rows and feature_id; the old
    unversioned entries/id shape remains compatibility-only. Raises ValueError
    for invalid shape/version and ReportLimitError for excess. No completion,
    proof, validation, publication, input mutation or external effects occur.
    """
    value = bounded_object(artifact, limits=ParseLimits())
    versioned = _legacy_version(value.get("schema_version"))
    entries = value.get("rows" if versioned else "entries", None if versioned else ())
    if not isinstance(entries, tuple) or any(
        not isinstance(row, JsonObject) for row in entries
    ):
        raise ValueError("Parity rows must be JSON objects")
    # Preserve true v1 row fields while detaching every caller-owned container.
    rows = [cast("dict[str, object]", to_plain_value(row)) for row in entries]
    return sort_rows(rows, id_field="feature_id" if versioned else "id"), {
        "total_entries": len(rows)
    }


def render_parity_report(
    rows: list[dict[str, object]], summary: dict[str, object]
) -> str:
    """Render compatibility rows (list[dict]) and summary (dict) as pretty JSON.

    Returns deterministic LF text. Raises ValueError/ReportLimitError before
    encoding malformed/excess data. No graph authority or external effects.
    """
    value = bounded_object({"entries": rows, "summary": summary}, limits=ParseLimits())
    # Reserve formatting expansion before rendering the unchanged legacy envelope.
    ReportBudget(ParseLimits(), pretty=True).check(value)
    return render_pretty_json(to_plain_value(value))
