"""Assess captured evidence bytes without conflating provenance with claim truth."""

from __future__ import annotations

import hashlib
import math
import re
from dataclasses import dataclass
from typing import TYPE_CHECKING

from drm_copilot_discovery.findings import Finding, FindingCollector, ordered_findings
from drm_copilot_discovery.models import JsonObject, JsonValue
from drm_copilot_discovery.reference_links import reference_finding, string_value
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.revision_rules import RevisionInputs, is_full_revision
from drm_copilot_discovery.schema_validation import is_rfc3339_timestamp
from drm_copilot_discovery.snapshot import repository_pins

if TYPE_CHECKING:
    from drm_copilot_discovery.references import ArtifactRecord, ReferenceIndex
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


@dataclass(frozen=True, kw_only=True)
class EvidenceAssessment:
    """Keep local integrity/proof eligibility separate from observed behavior."""

    record: ArtifactRecord
    content: bytes | None
    findings: tuple[Finding, ...]

    @property
    def locally_verified(self) -> bool:
        """URI-only descriptions and any integrity error cannot supply local proof."""
        return self.content is not None and not any(
            item.severity == "error" for item in self.findings
        )

    def can_prove(
        self,
        *,
        repository: str,
        revision: str | None = None,
        evidence_types: tuple[str, ...] = (),
    ) -> bool:
        """Match explicit provenance while keeping source and target tests separate.

        A supplied revision must match the declared evidence revision exactly.
        Callers still assess observation truth, expected results and approval.
        """
        document = self.record.document
        return (
            self.locally_verified
            and document.get("repository") == repository
            and (revision is None or document.get("revision") == revision)
            and (not evidence_types or document.get("evidence_type") in evidence_types)
        )


@dataclass(frozen=True)
class EvidenceValidation:
    """Expose immutable evidence assessments and bounded aggregate findings."""

    assessments: tuple[EvidenceAssessment, ...]
    findings: tuple[Finding, ...]

    def for_record(self, record: ArtifactRecord) -> EvidenceAssessment | None:
        """Find the exact indexed evidence record, returning None for non-evidence."""
        return next((item for item in self.assessments if item.record == record), None)


def _identifier(value: JsonValue) -> bool:
    """Reject malformed capture identities without coercing unknown values."""
    return (
        isinstance(value, str)
        and re.fullmatch(r"[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*", value) is not None
    )


def _metadata(record: ArtifactRecord, findings: list[Finding]) -> None:
    """Require capture time and authorship, plus environment/method for runtime."""
    document = record.document
    timestamp = string_value(document.get("timestamp"))
    valid_time = timestamp is not None and is_rfc3339_timestamp(timestamp)
    if not valid_time:
        findings.append(
            reference_finding(
                "EVIDENCE_TIMESTAMP",
                record,
                "/timestamp",
                "Evidence requires a valid timestamp with an explicit timezone.",
            )
        )
    author = document.get("author_or_agent")
    if (
        not isinstance(author, JsonObject)
        or author.get("kind") not in {"human", "agent", "tool"}
        or not _identifier(author.get("id"))
    ):
        findings.append(
            reference_finding(
                "EVIDENCE_AUTHOR",
                record,
                "/author_or_agent",
                "Evidence requires a declared human, agent or tool capture identity.",
            )
        )
    # Runtime and manual observations require more than a timestamp and checksum.
    if document.get("evidence_type") in {"runtime", "observation"}:
        environment = document.get("environment")
        if (
            not isinstance(environment, JsonObject)
            or not all(
                _identifier(environment.get(name))
                for name in ("id", "platform", "operating_mode")
            )
            or "client_id" not in environment
            or (
                environment.get("client_id") is not None
                and not _identifier(environment.get("client_id"))
            )
        ):
            findings.append(
                reference_finding(
                    "EVIDENCE_ENVIRONMENT",
                    record,
                    "/environment",
                    "Runtime evidence requires platform, mode and client context.",
                )
            )
        runtime = document.get("runtime_artifact")
        if (
            not isinstance(runtime, JsonObject)
            or not isinstance(runtime.get("path"), str)
            or runtime.get("capture_method")
            not in {"manual", "semi-automated", "automated"}
        ):
            findings.append(
                reference_finding(
                    "EVIDENCE_CAPTURE",
                    record,
                    "/runtime_artifact",
                    "Runtime evidence requires a local capture path and method.",
                )
            )


def _checksum(
    record: ArtifactRecord, content: bytes | None, pointer: str, findings: list[Finding]
) -> None:
    """Bind each actual payload path to the same declared SHA-256 evidence digest."""
    checksum = record.document.get("checksum")
    if content is None:
        findings.append(
            reference_finding(
                "EVIDENCE_CONTENT_UNAVAILABLE",
                record,
                pointer,
                "Evidence bytes are absent from the declared repository/pin context.",
            )
        )
    elif (
        not isinstance(checksum, JsonObject)
        or checksum.get("algorithm") != "sha256"
        or checksum.get("value") != hashlib.sha256(content).hexdigest()
    ):
        findings.append(
            reference_finding(
                "EVIDENCE_CHECKSUM",
                record,
                pointer,
                "The captured payload does not match the declared SHA-256 checksum.",
            )
        )


def _line_number(value: JsonValue) -> int | None:
    """Accept JSON integers, including 1.0; reject booleans and fractions."""
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        return None
    if isinstance(value, int):
        return value if value >= 1 else None
    if not math.isfinite(value) or value < 1 or not value.is_integer():
        return None
    return int(value)


def _span(
    record: ArtifactRecord, content: bytes | None, findings: list[Finding]
) -> None:
    """Check one-based inclusive spans against the same bytes used for hashing."""
    span = record.document.get("line_range")
    if span is None:
        return
    start = _line_number(span.get("start")) if isinstance(span, JsonObject) else None
    end = _line_number(span.get("end")) if isinstance(span, JsonObject) else None
    if (
        content is None
        or start is None
        or end is None
        or end < start
        or end > len(content.splitlines())
    ):
        findings.append(
            reference_finding(
                "EVIDENCE_LINE_RANGE",
                record,
                "/line_range",
                "One-based inclusive line spans must fit the referenced bytes.",
            )
        )


def assess_evidence(
    inputs: RevisionInputs, record: ArtifactRecord
) -> EvidenceAssessment:
    """Verify one evidence record using only supplied immutable bytes and identities.

    Raises ValueError for a non-evidence record. Descriptive URI-only records are
    retained with no local proof; source/test records require captured pinned bytes.
    """
    if record.kind != "evidence-reference":
        raise ValueError("Evidence assessment requires an evidence-reference record")
    document = record.document
    findings: list[Finding] = []
    _metadata(record, findings)
    owner = string_value(document.get("repository"))
    revision = string_value(document.get("revision"))
    kind = document.get("evidence_type")
    sources, targets = repository_pins(inputs.snapshot.profile)
    # Identity must be configured; local filenames cannot impersonate foreign proof.
    if owner not in {item.id for item in sources + targets}:
        findings.append(
            reference_finding(
                "EVIDENCE_REPOSITORY",
                record,
                "/repository",
                "Evidence names an unconfigured source/target repository.",
            )
        )
    if (
        kind in {"source", "test"} or document.get("revision") is not None
    ) and not is_full_revision(document.get("revision")):
        findings.append(
            reference_finding(
                "EVIDENCE_PIN",
                record,
                "/revision",
                "Source and test evidence require a full immutable revision.",
            )
        )
    path = string_value(document.get("path"))
    content = None
    # Only descriptive non-runtime records may omit local capture content.
    if path is None:
        if kind in {"source", "test", "runtime", "observation"} or not isinstance(
            document.get("uri"), str
        ):
            findings.append(
                reference_finding(
                    "EVIDENCE_PATH",
                    record,
                    "/path",
                    "This evidence requires a local payload, not just a URI.",
                )
            )
    else:
        content = inputs.content(
            record,
            repository=owner or "",
            revision=revision,
            path=path,
            immutable=kind in {"source", "test"},
        )
        _checksum(record, content, "/path", findings)
    runtime = document.get("runtime_artifact")
    if isinstance(runtime, JsonObject) and isinstance(runtime.get("path"), str):
        runtime_path = string_value(runtime.get("path")) or ""
        capture = inputs.content(
            record, repository=owner or "", revision=revision, path=runtime_path
        )
        # A second path cannot substitute other bytes for the checksummed evidence.
        _checksum(record, capture, "/runtime_artifact/path", findings)
    _span(record, content, findings)
    return EvidenceAssessment(
        record=record, content=content, findings=ordered_findings(findings)
    )


def validate_evidence(
    snapshot: DiscoverySnapshot, *, index: ReferenceIndex | None = None
) -> EvidenceValidation:
    """Assess every evidence record, reusing a supplied typed graph when available."""
    index = index or index_references(snapshot)
    inputs = RevisionInputs(snapshot)
    collector = FindingCollector(limit=snapshot.profile.limits.parse_limits().findings)
    assessments: list[EvidenceAssessment] = []
    # Unreferenced evidence is checked too; unproven descriptions remain descriptive.
    for record in index.records:
        if record.kind == "evidence-reference":
            assessment = assess_evidence(inputs, record)
            assessments.append(assessment)
            # Apply the profile finding limit only after retaining the full assessment.
            for finding in assessment.findings:
                collector.add(finding)
    return EvidenceValidation(tuple(assessments), collector.findings)
