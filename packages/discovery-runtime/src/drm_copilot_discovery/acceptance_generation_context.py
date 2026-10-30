"""Bound call-local acceptance assessments and immutable prospective batches."""

from __future__ import annotations

import re
from dataclasses import replace
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.acceptance_models import AcceptanceGeneration
from drm_copilot_discovery.acceptance_rules import (
    acceptance_source_digest,
    validate_acceptance,
)
from drm_copilot_discovery.agent_output import REPORT_KINDS
from drm_copilot_discovery.claim_rules import ClaimContext, validate_claims
from drm_copilot_discovery.coverage_scope_rules import object_rows
from drm_copilot_discovery.decision_rules import validate_decisions
from drm_copilot_discovery.dimension_rules import validate_dimensions
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.findings import Finding, FindingCollector
from drm_copilot_discovery.models import JsonObject, JsonValue, canonical_json
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.report_models import (
    ReportBudget,
    ReportLimitError,
    bounded_object,
)
from drm_copilot_discovery.revision_rules import validate_revisions
from drm_copilot_discovery.schema_validation import validate_document
from drm_copilot_discovery.snapshot import (
    ArtifactSnapshot,
    DiscoverySnapshot,
    SnapshotFile,
    repository_pins,
)
from drm_copilot_discovery.validation_inputs import validate_inputs

if TYPE_CHECKING:
    from drm_copilot_discovery.acceptance_models import AcceptanceSpecification
    from drm_copilot_discovery.acceptance_rules import AcceptanceValidation
    from drm_copilot_discovery.references import ArtifactRecord


def generation_preflight(snapshot: DiscoverySnapshot) -> ReportBudget:
    """Reserve snapshot metadata and retained bytes before assessment.

    snapshot must be a captured DiscoverySnapshot. Return a call-local work
    budget; ValueError rejects types and ReportLimitError rejects excess. Raw
    input and pin bytes each have an independent document_bytes aggregate cap.
    No bytes are encoded, copied or read externally.
    """
    if type(snapshot) is not DiscoverySnapshot:
        raise ValueError("Acceptance generation requires a captured snapshot")
    limits = snapshot.profile.limits.parse_limits()
    work, documents = ReportBudget(limits), ReportBudget(limits)
    count = len(snapshot.manifest.files) + len(snapshot.repository_files)
    work.work(count + len(snapshot.artifacts))
    if count > snapshot.profile.limits.source_files:
        raise ReportLimitError()
    # Check both retained byte populations independently before hashing or parsing.
    for population in (snapshot.manifest.files, snapshot.repository_files):
        remaining = limits.document_bytes
        # Reserve original-byte hashing and repeated accepted parser visits first.
        for item in population:
            if len(item.content) > remaining:
                raise ReportLimitError()
            remaining -= len(item.content)
        work.work(8 * (limits.document_bytes - remaining))
    documents.check(snapshot.profile.document)
    # Existing output views have no authored graph semantics.
    for artifact in snapshot.artifacts:
        if artifact.expected_kind not in REPORT_KINDS:
            documents.check(artifact.document)
    nodes = limits.expanded_nodes - documents.nodes_left
    records = limits.artifact_records - documents.records_left
    # Bound accepted pairwise/link walks by visited values and mapping populations.
    work.work(8 * max(1, records) * (nodes + count))
    return work


class GenerationContext:
    """Reuse source assessments and reserve two whole-batch validation passes.

    Construct once after preflight, inspect input findings, then select immutable
    records and call assess at most twice. Findings and counters are call-local;
    no files, source records, pins, grants or implementation state are changed.
    Existing public rule functions remain the only readiness authority.
    """

    def __init__(self, snapshot: DiscoverySnapshot, budget: ReportBudget) -> None:
        """Retain snapshot/work budget and assess its inputs; return None.

        snapshot (DiscoverySnapshot) and budget (ReportBudget) come from the
        generator preflight. Resource exhaustion raises ValueError subclasses.
        Input failures remain findings; only private buffers are mutated.
        """
        self.snapshot, self.budget = snapshot, budget
        self.limits = snapshot.profile.limits.parse_limits()
        self.output = ReportBudget(self.limits)
        self.collector = FindingCollector(limit=self.limits.findings)
        self.passes = 0
        self.digests: dict[tuple[str, str, str, str], str] = {}
        self.add_all(validate_inputs(snapshot))
        if snapshot.profile.profile_state != "configured":
            self.problem("ACCEPTANCE_INPUT", "Generation requires configured pins.")
        self.structural_ok = not self.blocked
        # Invalid documents remain findings and are never interpreted as criteria.
        core = replace(
            snapshot,
            artifacts=tuple(
                item
                for item in snapshot.artifacts
                if self.structural_ok and item.expected_kind not in REPORT_KINDS
            ),
        )
        self.index = index_references(core)
        self.evidence = validate_evidence(snapshot, index=self.index)
        self.decisions = validate_decisions(
            snapshot, index=self.index, evidence=self.evidence
        )
        self.dimensions = validate_dimensions(
            snapshot, index=self.index, evidence=self.evidence, decisions=self.decisions
        )
        # Preserve every independent integrity family before considering readiness.
        for result in (
            self.index,
            self.evidence,
            validate_revisions(snapshot, index=self.index),
            validate_claims(snapshot, index=self.index, evidence=self.evidence),
            self.decisions,
            self.dimensions,
        ):
            self.add_all(result.findings)
        budget.work(len(snapshot.manifest.files) + len(self.index.links))
        # Hash original captured streams once, including imported storage paths.
        self.hashes = {file.path: file.sha256 for file in snapshot.manifest.files}
        self.claims = ClaimContext(self.index, self.evidence, self.limits.findings)
        self.sources, self.targets = repository_pins(snapshot.profile)

    @property
    def blocked(self) -> bool:
        """Return bool authority denial, consuming local work without I/O.

        Raises ReportLimitError before scanning more findings than permitted.
        """
        self.budget.work(len(self.collector.findings))
        return any(item.severity == "error" for item in self.collector.findings)

    def selectors(
        self, value: object, *, qualified: bool = False
    ) -> tuple[object, ...]:
        """Validate API selector tuples and return their exact immutable members.

        value is an object; qualified (bool) selects repository/feature pairs.
        ValueError rejects malformed selectors; ReportLimitError denies excess
        before scans. Only local counters change, without I/O.
        """
        if type(value) is not tuple:
            raise ValueError("Acceptance selectors require immutable tuples")
        sequence = cast("tuple[object, ...]", value)
        self.budget.work(len(sequence))
        self.output.check(sequence)
        # Check every member before creating selection indexes.
        for item in sequence:
            parts = item if qualified else (item,)
            if type(parts) is not tuple or len(cast("tuple[object, ...]", parts)) != (
                2 if qualified else 1
            ):
                raise ValueError("Acceptance selectors require qualified feature pairs")
            # Identifier components have a disjoint, linear spelling grammar.
            for part in cast("tuple[object, ...]", parts):
                if type(part) is not str:
                    raise ValueError("Acceptance selectors require identifiers")
                self.budget.work(len(part))
                if re.fullmatch(r"[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*", part) is None:
                    raise ValueError("Acceptance selectors require valid identifiers")
        return sequence

    def add_all(self, findings: tuple[Finding, ...]) -> None:
        """Retain bounded findings (tuple[Finding]); return None, without I/O.

        Reserve collector comparison/sort work first; excess raises
        ReportLimitError. Existing severity and truncation markers are preserved.
        """
        self.budget.work(
            len(findings)
            * (self.limits.findings + 1).bit_length()
            * (self.limits.findings + 1)
        )
        # Feed the accepted collector without discarding upstream blockers.
        for finding in findings:
            self.collector.add(finding)

    def problem(
        self, code: str, message: str, record: ArtifactRecord | None = None
    ) -> None:
        """Retain a fixed domain diagnostic; return None with no external effects.

        code/message are fixed str literals; optional record supplies its safe
        captured path. Raises ReportLimitError if diagnostic work is exhausted.
        """
        self.add_all(
            (
                Finding(
                    code=code,
                    message=message,
                    artifact_path=record.artifact.path if record else None,
                    next_action="Correct inputs and selection, then generate again.",
                ),
            )
        )

    def linked(
        self, record: ArtifactRecord, pointer: str
    ) -> tuple[ArtifactRecord, ...]:
        """Return resolved targets for record/field pointer using the cached index.

        record is ArtifactRecord; pointer is a fixed field str. Returns an
        ArtifactRecord tuple; failed links remain findings. Consumes local work,
        raising ReportLimitError before excess lookup. No I/O or input mutation.
        """
        self.budget.work(
            len(self.claims.by_source.get((record.artifact.path, record.pointer), ()))
        )
        return self.claims.targets(record, pointer)

    def links_to(
        self, record: ArtifactRecord, pointer: str, source: ArtifactRecord
    ) -> bool:
        """Return whether the resolved field points at source's physical record.

        record/source are ArtifactRecord and pointer is a fixed field string.
        Reserve equality comparisons before lookup; resource excess raises
        ReportLimitError. No recursive document equality or external effect occurs.
        """
        targets = self.linked(record, pointer)
        self.budget.work(len(targets) * 2)
        # Physical record identity avoids recursive artifact-document comparisons.
        return any(
            item.artifact.path == source.artifact.path
            and item.pointer == source.pointer
            for item in targets
        )

    def criteria(
        self, source: ArtifactRecord, *, target: bool
    ) -> tuple[tuple[ArtifactRecord, int, JsonObject], ...]:
        """Return explicit source or linked decision criteria with exact ordinals.

        source is ArtifactRecord; target (bool) enables policy candidates.
        Scans and rows are reserved before retention. Resource excess raises
        ValueError; no private approval rules, I/O or input mutation occur.
        """
        origins = [source]
        if target:
            self.budget.work(len(self.index.records))
            # Only resolved feature links associate decision criteria with a source.
            for item in self.index.records:
                if item.kind == "product-decision" and self.links_to(
                    item, "/feature_refs", source
                ):
                    origins.append(item)
        result: list[tuple[ArtifactRecord, int, JsonObject]] = []
        # Preserve authored row ordinals for exact evidence-reference pointers.
        for origin in origins:
            field = (
                "acceptance_criteria"
                if origin is source
                else "resulting_acceptance_criteria"
            )
            rows = origin.document.get(field)
            self.budget.work(len(rows) if isinstance(rows, tuple) else 0)
            # Public row projection preserves the existing record, index and content.
            result.extend(
                (origin, position, row) for position, row in object_rows(rows)
            )
        return tuple(result)

    def reference(self, record: ArtifactRecord, *, source: bool = False) -> JsonObject:
        """Return an original-byte immutable reference to record (ArtifactRecord).

        source (bool) selects feature-contract wire fields. Caller already
        checked captured ownership. Bounds precede retaining the small object;
        invalid pins raise ValueError, capacity raises ReportLimitError. No I/O.
        """
        if record.artifact.repository.revision is None:
            raise ValueError("Acceptance references require a captured revision")
        # Source contracts use their explicit provenance shape; other refs stay generic.
        if source:
            value = {
                "artifact_kind": "feature-contract",
                "repository_id": record.repository,
                "revision": record.artifact.repository.revision,
                "artifact_path": record.path,
                "artifact_sha256": self.hashes[record.artifact.path],
                "feature_id": record.document["feature_id"],
                "schema_version": "2.0.0",
            }
        else:
            value = {
                "artifact_kind": record.kind,
                "id": record.id,
                "repository": record.repository,
                "revision": record.artifact.repository.revision,
                "path": record.path,
                "sha256": self.hashes[record.artifact.path],
            }
        self.output.check(value)
        return JsonObject(tuple(cast("dict[str, JsonValue]", value).items()))

    def digest(self, source: ArtifactRecord, origin: ArtifactRecord) -> str:
        """Return the accepted digest for the exact source/decision pair.

        Both arguments are ArtifactRecord. Reserve canonical bytes before
        encoding; cache subsequent coordinates. ValueError rejects resource
        excess. No source bytes or external state change.
        """
        key = source.artifact.path, source.pointer, origin.artifact.path, origin.pointer
        if key not in self.digests:
            budget = ReportBudget(self.limits)
            records = (source,) if origin is source else (source, origin)
            # Hash only the documents included by the accepted readiness contract.
            for record in records:
                budget.check(
                    {
                        "repository": record.repository,
                        "revision": record.artifact.repository.revision,
                        "document": record.document,
                    }
                )
            self.budget.work(self.limits.document_bytes - budget.bytes_left)
            self.digests[key] = acceptance_source_digest(
                (source,), () if origin is source else (origin,)
            )
        return self.digests[key]

    def assess(
        self, values: tuple[AcceptanceSpecification, ...]
    ) -> AcceptanceValidation:
        """Validate one complete prospective tuple and return AcceptanceValidation.

        values contains immutable generated specifications. At most two calls
        are allowed. All overlay bytes, sorts and rule walks are reserved before
        allocation. ValueError denies path collisions or resource excess. Core
        bytes/assessments remain unchanged; no publication or filesystem access.
        """
        if self.passes >= 2:
            raise ValueError("Acceptance generation permits two batch assessments")
        self.passes += 1
        size = len(self.index.records) + len(values)
        self.budget.work(
            8
            * max(1, size)
            * (
                len(self.index.links)
                + self.limits.expanded_nodes
                - self.output.nodes_left
                + len(self.snapshot.manifest.files)
                + size
            )
        )
        encoded = ReportBudget(self.limits)
        self.budget.work(len(self.snapshot.manifest.files))
        # An overlay includes original captured bytes as well as generated members.
        for file in self.snapshot.manifest.files:
            encoded.spend(len(file.content))
        # Reserve the complete batch's serialized content before encoding any member.
        for value in values:
            encoded.check(value.document)
            encoded.spend(1)
        files: list[SnapshotFile] = []
        artifacts: list[ArtifactSnapshot] = []
        root = self.snapshot.profile.artifacts["acceptance"]
        self.budget.work(
            len(self.snapshot.manifest.files) + size * max(1, size.bit_length())
        )
        # Captured authored paths remain immutable across repeated generation.
        existing = {file.path for file in self.snapshot.manifest.files}
        # A temporary in-memory namespace prevents overwriting captured authored rows.
        for value in values:
            path = f"{root}/generated-{value.document['id']}.json"
            if path in existing:
                raise ValueError("Acceptance candidate collides with captured input")
            raw = canonical_json(value.document)
            checked = validate_document(
                raw,
                expected_kind="acceptance-specification",
                expected_version="2.0.0",
                artifact_path=path,
                catalog=self.snapshot.catalog,
                limits=self.limits,
            )
            self.add_all(checked.findings)
            files.append(SnapshotFile(path=path, content=raw, category="artifact"))
            artifacts.append(
                ArtifactSnapshot(
                    path=path,
                    expected_kind="acceptance-specification",
                    document=value.document,
                    repository=value.repository,
                )
            )
        overlay = replace(
            self.snapshot,
            manifest=replace(
                self.snapshot.manifest,
                files=self.snapshot.manifest.files + tuple(files),
            ),
            artifacts=self.snapshot.artifacts + tuple(artifacts),
        )
        # Derived report views cannot create authored prospective reference targets.
        index = index_references(
            replace(
                overlay,
                artifacts=tuple(
                    item
                    for item in overlay.artifacts
                    if item.expected_kind not in REPORT_KINDS
                ),
            )
        )
        self.add_all(index.findings)
        self.add_all(validate_revisions(overlay, index=index).findings)
        result = validate_acceptance(
            overlay,
            index=index,
            evidence=self.evidence,
            decisions=self.decisions,
            dimensions=self.dimensions,
            complete=False,
        )
        self.add_all(result.findings)
        return result

    def finalize(
        self, values: tuple[AcceptanceSpecification, ...]
    ) -> AcceptanceGeneration:
        """Assess values twice and return only final rule-authorized ready members.

        values is the complete immutable candidate tuple. Unsupported ready
        expectations become pending; prior integrity findings remain. Capacity
        failures raise ValueError without partial output. Only local state changes.
        """
        first = self.assess(values)
        self.budget.work(len(first.ready) + len(values))
        # Qualified final-rule membership never relies on authored readiness alone.
        ready = {(item.repository, item.id) for item in first.ready}
        amended: list[AcceptanceSpecification] = []
        # Preserve uncertainty instead of inventing a replacement expectation.
        for value in values:
            if (
                value.document["readiness"] == "ready"
                and (value.repository.id, str(value.document["id"])) not in ready
            ):
                self.output.check(value.document)
                document = dict(value.document.members)
                document.update(
                    readiness="pending",
                    then=None,
                    expectation_basis="unresolved",
                    pending_reasons=(
                        "The captured rules do not support this expectation.",
                    ),
                )
                self.output.check(document)
                value = replace(
                    value, document=bounded_object(document, limits=self.limits)
                )
            amended.append(value)
        values = tuple(amended)
        final = self.assess(values)
        self.budget.work(len(final.ready) + len(values))
        # Retained blockers deny authority even when an individual row validates.
        accepted = {(item.repository, item.id) for item in final.ready}
        blocked = self.blocked
        # Only final accepted membership without retained blockers grants readiness.
        selected = tuple(
            value
            for value in values
            if not blocked
            and (value.repository.id, str(value.document["id"])) in accepted
        )
        return AcceptanceGeneration(
            specifications=values,
            ready=selected,
            findings=self.collector.findings,
            limits=self.limits,
        )
