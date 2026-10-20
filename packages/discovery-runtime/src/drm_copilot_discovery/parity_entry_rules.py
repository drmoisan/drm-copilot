"""Retain exact parity entry decisions without relying on truncated diagnostics."""

from __future__ import annotations

from collections import Counter
from dataclasses import replace
from itertools import product
from typing import TYPE_CHECKING

from drm_copilot_discovery.coverage_scope_rules import object_rows
from drm_copilot_discovery.dimension_rules import decision_scope
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.parity_models import ParityEntryOutcome
from drm_copilot_discovery.reference_links import string_value
from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError
from drm_copilot_discovery.revision_rules import is_full_revision

if TYPE_CHECKING:
    from collections.abc import Callable

    from drm_copilot_discovery.claim_rules import ClaimContext
    from drm_copilot_discovery.decision_rules import DecisionValidation
    from drm_copilot_discovery.dimension_rules import (
        DimensionValidation,
        FeatureObligation,
    )
    from drm_copilot_discovery.parity_models import ParityDimensionOutcome
    from drm_copilot_discovery.parity_target_rules import TargetProof
    from drm_copilot_discovery.references import ArtifactRecord
    from drm_copilot_discovery.repository_reader import RepositoryIdentity
    from drm_copilot_discovery.snapshot import DiscoverySnapshot

    Classification = Callable[
        [
            ArtifactRecord,
            JsonObject,
            str,
            FeatureObligation,
            RepositoryIdentity,
            bool,
        ],
        tuple[frozenset[str], tuple[ParityDimensionOutcome, ...], bool],
    ]


def _declares(matrix: ArtifactRecord, name: str, identity: RepositoryIdentity) -> bool:
    """Match identity (RepositoryIdentity) in matrix's named role header.

    matrix (ArtifactRecord) and name (str) identify captured declarations.
    Returns bool without I/O or mutation; the caller reserves header traversal.
    """
    # Only explicitly declared immutable role identities authorize a row.
    return any(
        row.get("id") == identity.id and row.get("revision") == identity.revision
        for _, row in object_rows(matrix.document.get(name))
    )


class ParityEntryRules:
    """Evaluate entries once and retain outcomes independently from diagnostics.

    Construct with existing typed assessments and a classification callback,
    call entry for captured rows, then finish. Existing TargetProof owns proof
    semantics. Local counts mark every duplicate invalid. ReportBudget reserves
    added traversal and retained records before allocation; exhaustion raises.
    Inputs remain immutable and no external operations or approval occur.
    """

    def __init__(
        self,
        snapshot: DiscoverySnapshot,
        context: ClaimContext,
        proof: TargetProof,
        decisions: DecisionValidation,
        dimensions: DimensionValidation,
        classify: Classification,
        *,
        complete: bool,
        truncated: bool,
    ) -> None:
        """Retain accepted assessments and initialize counters; return None.

        snapshot (DiscoverySnapshot) supplies configured clients and limits;
        context (ClaimContext) supplies resolved links and bounded findings.
        proof (TargetProof), decisions (DecisionValidation) and dimensions
        (DimensionValidation) retain prior semantic checks. classify (Callable)
        returns dimension waivers/outcomes/validity. complete/truncated (bool)
        control required checks and unavailable proof. Raises ReportLimitError
        before excess indexing. Only private state changes; no I/O occurs.
        """
        self.snapshot, self.context, self.proof = snapshot, context, proof
        self.decisions, self.dimensions = decisions, dimensions
        self.classify, self.complete, self.truncated = classify, complete, truncated
        self.budget = ReportBudget(snapshot.profile.limits.parse_limits())
        self.budget.work(len(dimensions.obligations))
        # A resolved obligation is indexed once rather than searched for each row.
        self.obligations: dict[tuple[ArtifactRecord, str | None], FeatureObligation] = (
            {}
        )
        # Preserve the original first-match rule if upstream context is ambiguous.
        for item in dimensions.obligations:
            self.obligations.setdefault((item.feature, item.client_id), item)
        self.counts: Counter[tuple[ArtifactRecord, str]] = Counter()
        self.outcomes: list[ParityEntryOutcome] = []

    def source(
        self, matrix: ArtifactRecord, row: JsonObject, pointer: str
    ) -> ArtifactRecord | None:
        """Resolve matrix/row/pointer (ArtifactRecord/JsonObject/str) ownership.

        Returns one pinned source ArtifactRecord or None and emits the established
        PARITY_SOURCE finding. No I/O; traversal is reserved by entry.
        """
        field = pointer + "/source_contract_ref"
        targets = self.context.targets(matrix, field)
        source = targets[0] if len(targets) == 1 else None
        if (
            source is None
            or source.kind != "feature-contract"
            or source.document.get("feature_id") != row.get("feature_id")
            or self.proof.blocked(matrix, field)
            or not _declares(matrix, "source_repositories", source.artifact.repository)
        ):
            self.context.add(
                "PARITY_SOURCE",
                matrix,
                field,
                "Parity requires one source contract at its exact pin/hash.",
            )
            return None
        return source

    def target(
        self, matrix: ArtifactRecord, row: JsonObject, pointer: str
    ) -> RepositoryIdentity | None:
        """Resolve matrix/row/pointer (ArtifactRecord/JsonObject/str) target.

        Returns its configured RepositoryIdentity or None with PARITY_TARGET.
        Reads retained declarations only; entry reserves traversal beforehand.
        """
        value = row.get("target_repository")
        # Client ownership must agree with an actual configured target-role pin.
        client = next(
            (
                item
                for item in self.snapshot.profile.clients
                if item.id == row.get("client_id")
            ),
            None,
        )
        if (
            isinstance(value, JsonObject)
            and client is not None
            and is_full_revision(value.get("revision"))
        ):
            # Require both matrix declaration and client-to-repository assignment.
            for target in self.proof.targets:
                if (
                    target.id == client.target_repository == value.get("id")
                    and target.revision == value.get("revision")
                    and _declares(matrix, "target_repositories", target)
                ):
                    return target
        self.context.add(
            "PARITY_TARGET",
            matrix,
            pointer + "/target_repository",
            "Parity target must match its configured client and pin.",
        )
        return None

    def approval(
        self,
        matrix: ArtifactRecord,
        row: JsonObject,
        pointer: str,
        obligation: FeatureObligation,
    ) -> bool:
        """Check current approval for one source feature/client obligation.

        matrix (ArtifactRecord) owns row (JsonObject); pointer (str) locates that
        authored row. obligation (FeatureObligation) supplies the required scope.
        Returns bool and preserves PARITY_DECISION on failure. Scope policy stays
        in accepted decision services. Work was reserved by entry; no I/O occurs.
        """
        retired = row.get("parity_state") == "retired"
        field = pointer + (
            "/retirement_decision_ref" if retired else "/intentional_deviation_refs"
        )
        linked = self.context.targets(matrix, field)
        selected: list[ArtifactRecord] = []
        # Changes may cover a subset; retirement must cover every required axis.
        for item in self.decisions.approved:
            request = decision_scope(
                obligation.feature,
                client_id=obligation.client_id,
                platforms=(
                    obligation.requirements.platforms
                    if retired
                    else tuple(item.scope.selectors[1])
                ),
                modes=(
                    obligation.requirements.modes
                    if retired
                    else tuple(item.scope.selectors[2])
                ),
                dimensions=() if retired else tuple(item.scope.selectors[3]),
            )
            applicable = item.scope.covers(request)
            if not retired:
                # Reject changes scoped exclusively to unrelated target contexts.
                for selected_values, required_values in (
                    (item.scope.selectors[1], obligation.requirements.platforms),
                    (item.scope.selectors[2], obligation.requirements.modes),
                ):
                    applicable = applicable and (
                        not selected_values
                        or bool(selected_values.intersection(required_values))
                    )
            if item.record in linked and applicable:
                selected.append(item.record)
        valid = bool(selected) and len(selected) == len(
            self.context.links(matrix, field)
        )
        if not valid:
            self.context.add(
                "PARITY_DECISION",
                matrix,
                field,
                "Changed/retired parity needs current scoped approval.",
            )
        return valid

    def entry(self, matrix: ArtifactRecord, position: int, row: JsonObject) -> None:
        """Evaluate captured matrix/position/row (ArtifactRecord/int/JsonObject).

        Retain one outcome and established findings; return None. Prospective
        work/record checks raise ReportLimitError before excess allocation.
        All checks retain booleans rather than inspecting diagnostic absence.
        """
        headers = matrix.document.get("source_repositories"), matrix.document.get(
            "target_repositories"
        )
        # Role-header scans depend on declaration rows, not only envelope keys.
        header_count = sum(len(value) for value in headers if isinstance(value, tuple))
        self.budget.work(
            8 * len(matrix.document)
            + header_count * (1 + len(self.proof.targets))
            + len(self.snapshot.profile.clients) * max(1, len(row))
            + len(self.proof.targets) * max(1, len(matrix.document))
            + 4 * len(self.context.index.links)
            + len(self.proof.upstream)
            + len(self.decisions.approved) * (1 + len(self.context.index.links))
        )
        local_links = len(
            self.context.by_source.get((matrix.artifact.path, matrix.pointer), ())
        )
        self.budget.work(
            (1 + local_links)
            * (
                len(self.context.index.links)
                + len(self.context.evidence.assessments)
                + len(self.proof.upstream)
                + len(self.proof.implementations)
            )
        )
        if len(self.outcomes) >= self.budget.limits.artifact_records:
            raise ReportLimitError()
        pointer = f"/entries/{position}"
        source = self.source(matrix, row, pointer)
        target = self.target(matrix, row, pointer)
        client = string_value(row.get("client_id"))
        result = ParityEntryOutcome(
            matrix=matrix,
            pointer=pointer,
            source=source,
            target=target,
            client_id=client,
            authored_state=string_value(row.get("parity_state")),
        )
        if source is None or target is None or client is None:
            self.outcomes.append(result)
            return
        key = source, client
        if self.counts[key]:
            self.context.add(
                "PARITY_DUPLICATE",
                matrix,
                pointer,
                "A source feature/client has multiple parity entries.",
            )
        self.counts[key] += 1
        obligation = self.obligations.get(key)
        if obligation is None:
            self.context.add(
                "PARITY_REQUIREMENTS",
                matrix,
                pointer,
                "The source feature/client lacks resolved requirement context.",
            )
            self.outcomes.append(result)
            return
        self.outcomes.append(self.assess(result, row, obligation))

    def assess(
        self,
        result: ParityEntryOutcome,
        row: JsonObject,
        obligation: FeatureObligation,
    ) -> ParityEntryOutcome:
        """Retain checked result/row/obligation decisions without diagnostic inference.

        Parameters are ParityEntryOutcome, JsonObject and FeatureObligation.
        Returns a new immutable outcome. Requires resolved source/target/client.
        Raises ValueError for unresolved ownership or ReportLimitError before
        excess coordinate traversal; no I/O occurs.
        """
        matrix, pointer = result.matrix, result.pointer
        source, target, client = result.source, result.target, result.client_id
        if source is None or target is None or client is None:
            raise ValueError("Parity entry assessment requires resolved ownership")
        state = result.authored_state
        approved = (
            self.approval(matrix, row, pointer, obligation)
            if state in ("intentionally-changed", "retired")
            else None
        )
        required = state == "full" or (
            self.complete and obligation.required and state == "intentionally-changed"
        )
        waived, classifications, dimension_valid = self.classify(
            matrix, row, pointer, obligation, target, required
        )
        implementations = self.proof.links(matrix, pointer, source, target, client)
        implementation_valid = len(implementations) == len(
            self.context.links(matrix, pointer + "/target_implementation_refs")
        ) and not self.proof.blocked(matrix, pointer + "/target_implementation_refs")
        valid = (
            not self.truncated
            and dimension_valid
            and implementation_valid
            and approved is not False
            and not self.proof.blocked(matrix, pointer)
        )
        base = replace(
            result,
            required=obligation.required,
            approval_valid=approved,
            implementation_valid=implementation_valid,
            dimensions=classifications,
        )
        if state == "retired" and approved:
            return replace(base, valid=valid, complete=valid)
        evidenced: bool | None = None
        if state in ("full", "partial") or required:
            evidenced = bool(implementations) and self.proof.evidence(
                matrix,
                pointer + "/evidence_refs",
                target,
                client,
                sources=(source,),
                execution=required,
            )
            valid = valid and evidenced
            if not evidenced:
                self.context.add(
                    "PARITY_PROOF",
                    matrix,
                    pointer,
                    "Parity claims need independently evidenced target implementation.",
                )
        verified: bool | None = None
        if required:
            # Every linked implementation contributes to a full parity claim.
            verified = all(
                record.document.get("verification_state") == "passed"
                for record in implementations
            )
            if not verified:
                self.context.add(
                    "PARITY_VERIFICATION",
                    matrix,
                    pointer,
                    "Every linked implementation needs passing verification.",
                )
            if row.get("blockers") or row.get("validation_status") != "pass":
                valid = False
                self.context.add(
                    "PARITY_STATE",
                    matrix,
                    pointer,
                    "Completed parity needs no blockers and passing validation.",
                )
            platforms = set(obligation.requirements.platforms) - waived
            modes = set(obligation.requirements.modes) - waived
            self.budget.work(
                max(1, len(platforms))
                * len(modes)
                * max(1, len(implementations))
                * max(1, len(self.context.index.links))
            )
            # Components may divide coordinates but cannot omit any required axis.
            for platform, mode in product(sorted(platforms) or (None,), sorted(modes)):
                # Existing target proof owns evidence and test applicability.
                supported = any(
                    self.proof.coordinate(record, platform, mode)
                    for record in implementations
                )
                verified = verified and supported
                if not supported:
                    self.context.add(
                        "PARITY_VERIFICATION",
                        matrix,
                        pointer,
                        f"Missing target proof: {client}/{platform}/{mode}.",
                    )
            valid = valid and verified
        incomplete = (
            self.complete
            and obligation.required
            and state not in ("full", "intentionally-changed", "retired")
        )
        if incomplete:
            self.context.add(
                "PARITY_INCOMPLETE",
                matrix,
                pointer,
                "Required parity remains unassessed, partial, missing or conflicting.",
            )
        return replace(
            base,
            evidence_valid=evidenced,
            verification_valid=verified,
            valid=valid,
            complete=valid and required and evidenced is True and verified is True,
        )

    def finish(self) -> tuple[ParityEntryOutcome, ...]:
        """Return immutable outcomes, invalidating every duplicate; perform no I/O.

        Adds established missing-required findings in complete mode. Reserves
        scans before constructing the result; raises ReportLimitError on excess.
        """
        self.budget.work(len(self.dimensions.obligations) + len(self.outcomes))
        if self.complete:
            # Optional requirements never become mandatory through mere presence.
            for obligation in self.dimensions.obligations:
                if (
                    obligation.required
                    and obligation.client_id is not None
                    and (obligation.feature, obligation.client_id) not in self.counts
                ):
                    self.context.add(
                        "PARITY_MISSING",
                        obligation.feature,
                        "",
                        "Required feature lacks parity for client "
                        f"{obligation.client_id}.",
                    )
        outcomes: list[ParityEntryOutcome] = []
        # Competing rows invalidate the first row as well as later duplicates.
        for item in self.outcomes:
            duplicate = (
                item.source is not None
                and item.client_id is not None
                and self.counts[(item.source, item.client_id)] > 1
            )
            outcomes.append(
                replace(item, duplicate=True, valid=False, complete=False)
                if duplicate
                else item
            )
        return tuple(outcomes)
