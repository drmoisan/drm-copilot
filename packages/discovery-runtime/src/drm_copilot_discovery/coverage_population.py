"""Collect source coverage identities through existing scope and proof services."""

from __future__ import annotations

from collections import Counter
from typing import TYPE_CHECKING, TypeAlias

from drm_copilot_discovery.claim_rules import ClaimContext
from drm_copilot_discovery.coverage_scope_rules import (
    object_rows,
    select_coverage_scope,
)
from drm_copilot_discovery.report_models import ReportBudget
from drm_copilot_discovery.snapshot import repository_pins

if TYPE_CHECKING:
    from drm_copilot_discovery.claim_rules import ClaimValidation
    from drm_copilot_discovery.evidence_rules import EvidenceValidation
    from drm_copilot_discovery.findings import Finding
    from drm_copilot_discovery.models import JsonObject
    from drm_copilot_discovery.references import ArtifactRecord, ReferenceIndex
    from drm_copilot_discovery.repository_reader import RepositoryIdentity
    from drm_copilot_discovery.snapshot import DiscoverySnapshot

Identity: TypeAlias = tuple[str, str | None, str]
LedgerRow: TypeAlias = tuple["ArtifactRecord", int, "JsonObject"]


def record_identity(record: ArtifactRecord, identifier: str | None = None) -> Identity:
    """Return repository/pin/ID for record (ArtifactRecord) and optional str override.

    Uses captured ownership, not authored identity text. No I/O or mutation.
    """
    return (
        record.repository,
        record.artifact.repository.revision,
        identifier or record.id,
    )


class CoveragePopulation:
    """Collect source selection and proof queries without granting authority.

    The validation composer supplies accepted typed assessments. Call collect once,
    then read local populations and query proof. Scope, links and evidence remain
    governed by existing validators. Counters reserve work before repeated queries;
    overflow aborts the report. Only local containers/counters mutate, with no I/O.
    This helper is not a caller-supplied completion or validation token.
    """

    def __init__(
        self,
        snapshot: DiscoverySnapshot,
        index: ReferenceIndex,
        evidence: EvidenceValidation,
        claims: ClaimValidation,
        findings: tuple[Finding, ...],
    ) -> None:
        """Retain accepted assessments and initialize local counters; return None.

        snapshot (DiscoverySnapshot) holds captured inputs; index (ReferenceIndex)
        holds resolved records/links. evidence (EvidenceValidation) supplies
        usable proof; claims (ClaimValidation) supplies observation failures.
        findings (tuple[Finding]) supplies the complete discovery diagnostics.
        These assessments come from the validator, not a caller authority token.
        Reserves indexing work before allocation; raises ReportLimitError on
        excess. Inputs remain unchanged and no external operations occur.
        """
        self.snapshot, self.index = snapshot, index
        self.budget = ReportBudget(snapshot.profile.limits.parse_limits())
        self.budget.work(
            2 * len(index.records)
            + len(index.links)
            + len(evidence.assessments)
            + 2 * len(findings)
            + len(claims.findings)
            + len(index.findings)
        )
        self.context = ClaimContext(
            index, evidence, snapshot.profile.limits.parse_limits().findings
        )
        self.sources = frozenset(repository_pins(snapshot.profile)[0])
        self.errors: dict[str, list[str]] = {}
        self.claim_errors: set[str] = set()
        # Physical paths preserve ownership/reference diagnostics without aliases.
        for finding in findings:
            if finding.severity == "error" and finding.artifact_path is not None:
                self.errors.setdefault(finding.artifact_path, []).append(
                    finding.pointer
                )
        # Verification cannot hide an invalid observation or ambiguous reference.
        for finding in (*claims.findings, *index.findings):
            if finding.severity == "error" and finding.artifact_path is not None:
                self.claim_errors.add(finding.artifact_path)
        self.truncated = any(f.code == "FINDINGS_LIMIT" for f in findings)
        self.component_rows = self.selector_rows = self.inventory_rows = 0
        self.inventory_count = 0
        # Count every repeated selector/query population before calling accepted rules.
        for record in index.records:
            rows = record.document.get("components")
            if record.kind in {"coverage-ledger", "inventory-snapshot"} and isinstance(
                rows, tuple
            ):
                self.component_rows += len(rows)
            if record.kind == "scope":
                # Direct immutable pairs avoid repeated linear Mapping lookups.
                self.selector_rows += sum(
                    len(value)
                    for key, value in record.document.members
                    if key
                    in {
                        "included_roots",
                        "included_components",
                        "included_features",
                        "exclusions",
                    }
                    and isinstance(value, tuple)
                )
            elif record.kind == "inventory-snapshot":
                self.inventory_count += 1
                # File diagnostics and exclusions repeat root/component membership.
                self.inventory_rows += sum(
                    len(value)
                    for key, value in record.document.members
                    if key in {"files", "diagnostics", "exclusions"}
                    and isinstance(value, tuple)
                )
        self.accounted_sources: set[RepositoryIdentity] = set()
        self.available = bool(self.sources)
        self.selected: set[Identity] = set()
        self.inventoried: set[Identity] = set()
        self.rows: dict[Identity, list[LedgerRow]] = {}
        self.exclusion_valid: set[tuple[str, int]] = set()
        self.features: dict[Identity, ArtifactRecord] = {}
        self.scenarios: dict[Identity, ArtifactRecord] = {}
        self.questions: set[Identity] = set()

    def targets(
        self, record: ArtifactRecord, pointer: str
    ) -> tuple[ArtifactRecord, ...]:
        """Resolve record/pointer (ArtifactRecord/str); return accepted target tuple.

        Reserves local link visits; raises ReportLimitError on excess. Only local
        work counters change, with no I/O or alternative resolution semantics.
        """
        self.budget.work(
            len(self.context.by_source.get((record.artifact.path, record.pointer), ()))
        )
        return self.context.targets(record, pointer)

    def clean(self, record: ArtifactRecord, pointer: str = "") -> bool:
        """Check findings for record and relative pointer (str); return bool.

        Parent/root errors invalidate descendants. Reserves pointer comparisons
        before scanning; raises ReportLimitError on excess, with no I/O.
        """
        absolute = record.pointer + pointer
        errors = self.errors.get(record.artifact.path, ())
        self.budget.work(len(errors))
        # Either direction identifies failure of a field or its enclosing record.
        return not self.truncated and not any(
            not error
            or not absolute
            or error == absolute
            or error.startswith(absolute + "/")
            or absolute.startswith(error + "/")
            for error in errors
        )

    def proof(
        self, record: ArtifactRecord, pointer: str, *, runtime: bool = False
    ) -> bool:
        """Return usable proof for record/pointer and optional runtime (bool).

        Exact source pin/environment checks belong to ClaimContext. Prospective
        link/assessment reservations raise ReportLimitError on excess. No I/O,
        approval, confidence promotion or input mutation occurs.
        """
        links = self.context.by_source.get((record.artifact.path, record.pointer), ())
        self.budget.work(len(links) * (1 + len(self.context.evidence.assessments)))
        return self.clean(record, pointer) and self.context.proof(
            record,
            pointer,
            runtime=runtime,
            environment=record.document.get("environment") if runtime else None,
        )

    def ledger(self, ledger: ArtifactRecord) -> None:
        """Reconcile ledger (ArtifactRecord) scope and authored rows; return None.

        Accepted selection retains inventory identities absent from the ledger.
        Reserves root/component/diagnostic/exclusion comparisons before selection;
        each work unit is an upper-bound predicate or row visit. ReportLimitError
        aborts excess. Missing selection marks counts unavailable, never zero.
        Only local aggregation sets mutate.
        """
        self.budget.work(
            (
                1
                + self.component_rows
                + self.inventory_rows
                + len(self.snapshot.manifest.files)
                + len(self.snapshot.excluded_paths)
            )
            * (
                1
                + self.component_rows
                + self.selector_rows
                + self.inventory_rows
                + len(self.index.records)
                + len(self.index.links)
                + len(self.context.evidence.assessments)
            )
            + self.inventory_count
            * (
                1
                + len(self.snapshot.manifest.files)
                + len(self.snapshot.excluded_paths) * (1 + self.inventory_rows)
            )
        )
        selection = select_coverage_scope(
            self.snapshot, ledger, self.context, complete=True
        )
        if selection is None or not selection.inventories:
            self.available = False
            return
        self.accounted_sources.add(ledger.artifact.repository)
        # Inventory membership never implies completed inspection or disposition.
        for identifier in selection.components:
            self.inventoried.add(record_identity(ledger, identifier))
        # Scope-selected omissions remain part of the component denominator.
        for identifier in selection.selected:
            self.selected.add(record_identity(ledger, identifier))
        # Duplicate rows remain visible instead of selecting the first authored status.
        for position, row in object_rows(ledger.document.get("components")):
            identifier = row.get("component_id")
            if not isinstance(identifier, str):
                continue
            key = record_identity(ledger, identifier)
            self.rows.setdefault(key, []).append((ledger, position, row))
            if (
                row.get("disposition") == "excluded"
                and self.clean(ledger, f"/components/{position}")
                and self.clean(selection.scope)
            ):
                self.exclusion_valid.add((ledger.artifact.path, position))

    def collect(self) -> None:
        """Index source-owned records once; return None with local population changes.

        Semantic authority remains in validators. ReportLimitError aborts before
        excess work, and duplicate identities cannot contribute verified claims.
        """
        # Target-local records cannot enlarge source discovery proof populations.
        for record in self.index.records:
            if record.artifact.repository not in self.sources:
                continue
            if record.kind == "coverage-ledger":
                self.ledger(record)
            elif record.kind in {
                "feature-contract",
                "runtime-characterization-scenario",
            }:
                identifier = (
                    record.document.get("feature_id")
                    if record.kind == "feature-contract"
                    else None
                )
                key = record_identity(
                    record, identifier if isinstance(identifier, str) else None
                )
                records = (
                    self.features
                    if record.kind == "feature-contract"
                    else self.scenarios
                )
                if key in records:
                    self.claim_errors.update(
                        (record.artifact.path, records[key].artifact.path)
                    )
                else:
                    records[key] = record
            elif record.kind == "unspecified-behavior" and record.document.get(
                "status"
            ) in ("open", "under-review"):
                self.questions.add(record_identity(record))
        self.available = self.available and self.sources <= self.accounted_sources

    def runtime(
        self,
    ) -> tuple[set[Identity], set[Identity], int, int, dict[str, int]]:
        """Return observed/verified feature sets, scenario counts and authored statuses.

        Count scenarios/features once, never runs or target tests. Claim validity,
        source ownership and exact runtime evidence are required for observations.
        Verified additionally requires a valid passed claim with its supported
        expected-result basis. Only local sets/work counters mutate;
        ReportLimitError rejects excess without output.
        """
        supported: set[Identity] = set()
        verified: set[Identity] = set()
        count = verified_count = 0
        statuses: Counter[str] = Counter()
        self.budget.work(len(self.scenarios))
        # Multiple repeatability runs never multiply source coverage numerators.
        for scenario in self.scenarios.values():
            status = str(scenario.document.get("result_status"))
            statuses[status] += 1
            if (
                status not in ("observed", "passed")
                or scenario.artifact.path in self.claim_errors
                or not self.clean(scenario)
                or not self.proof(scenario, "/evidence_refs", runtime=True)
            ):
                continue
            count += 1
            verified_count += status == "passed"
            # Exact ownership prevents target scenarios from proving source facts.
            for feature in self.targets(scenario, "/feature_refs"):
                if (
                    feature.kind == "feature-contract"
                    and feature.artifact.repository == scenario.artifact.repository
                ):
                    identifier = feature.document.get("feature_id")
                    identity = record_identity(
                        feature, identifier if isinstance(identifier, str) else None
                    )
                    supported.add(identity)
                    if status == "passed":
                        verified.add(identity)
        return (
            supported,
            verified,
            count,
            verified_count,
            dict(sorted(statuses.items())),
        )
