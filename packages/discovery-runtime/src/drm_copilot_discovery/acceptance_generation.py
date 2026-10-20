"""Generate traceable acceptance specifications without inventing expectations."""

from __future__ import annotations

from itertools import product
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.acceptance_generation_context import (
    GenerationContext,
    generation_preflight,
)
from drm_copilot_discovery.acceptance_models import (
    AcceptanceGeneration,
    AcceptanceIdentity,
    AcceptanceKind,
    AcceptanceSpecification,
    acceptance_tags,
)
from drm_copilot_discovery.dimension_rules import criterion_applies, decision_scope
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.report_models import bounded_object
from drm_copilot_discovery.runtime_claim_rules import has_text

if TYPE_CHECKING:
    from drm_copilot_discovery.decision_rules import ApprovedDecision
    from drm_copilot_discovery.dimension_rules import FeatureObligation
    from drm_copilot_discovery.profile_models import ClientProfile
    from drm_copilot_discovery.references import ArtifactRecord
    from drm_copilot_discovery.repository_reader import RepositoryIdentity
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


class _Generation:
    """Project selected criteria through configured coordinates and exact links.

    One generator owns transient indexes, candidate and digest caches. Its source
    context supplies validated graph assessments; it never reimplements approval
    or readiness rules. Construction and finish are pure, preserve input bytes,
    and abort resource exhaustion without returning partial authority.
    """

    def __init__(
        self,
        context: GenerationContext,
        kind: AcceptanceKind,
        features: tuple[tuple[str, str], ...],
        clients: tuple[str, ...],
        modes: tuple[str, ...],
    ) -> None:
        """Retain context/kind and typed selector tuples; return None.

        Reserve indexing before allocation; ValueError rejects exhausted bounds.
        Only call-local dictionaries change; no I/O or caller mutation occurs.
        """
        self.context = context
        self.kind: AcceptanceKind = kind
        context.budget.work(len(features) + len(clients) + len(modes))
        self.features, self.clients, self.modes = (
            set(features),
            set(clients),
            set(modes),
        )
        context.budget.work(
            3 * len(context.index.records) + len(context.snapshot.profile.clients)
        )
        # Index each configured owner and approved record once by immutable identity.
        self.client_map = {item.id: item for item in context.snapshot.profile.clients}
        self.target_map = {item.id: item for item in context.targets}
        self.approvals = {
            (item.record.artifact.path, item.record.pointer): item
            for item in context.decisions.approved
        }
        self.values: dict[str, AcceptanceSpecification] = {}
        self.keys: dict[str, tuple[bytes, bytes]] = {}
        self.collisions: set[str] = set()
        self.seen_features: set[tuple[str, str]] = set()
        self.seen_modes: set[str] = set()

    def scenarios(
        self, source: ArtifactRecord, platform: str | None, mode: str
    ) -> tuple[ArtifactRecord | None, ...]:
        """Return distinct linked observations matching the actual coordinate.

        source is ArtifactRecord; platform/mode are validated identifiers.
        Reserve comparisons before scans. Ownership ambiguity retains a blocker;
        absent matches permit retained contract actions, never a fabricated one.
        No external effects; resource exhaustion raises ValueError.
        """
        ctx = self.context
        ctx.budget.work(len(ctx.index.records))
        result: dict[tuple[str, str], ArtifactRecord] = {}
        # Runtime scenario identity is input traceability, independent of output IDs.
        for record in ctx.index.records:
            if record.kind != "runtime-characterization-scenario" or not ctx.links_to(
                record, "/feature_refs", source
            ):
                continue
            if record.artifact.repository != source.artifact.repository:
                ctx.problem(
                    "ACCEPTANCE_SCENARIO",
                    "Linked scenario ownership differs from its source.",
                    record,
                )
                continue
            environment = record.document.get("environment")
            if (
                not isinstance(environment, JsonObject)
                or environment.get("platform") != platform
                or environment.get("operating_mode") != mode
            ):
                continue
            key = record.repository, str(record.document.get("scenario_id"))
            if key in result:
                ctx.problem(
                    "ACCEPTANCE_SCENARIO",
                    "Linked scenario identity is ambiguous.",
                    record,
                )
            result[key] = record
        return tuple(result.values()) or (None,)

    def candidate(
        self,
        source: ArtifactRecord,
        origin: ArtifactRecord,
        position: int,
        criterion: JsonObject,
        obligation: FeatureObligation | None,
        client: ClientProfile | None,
        owner: RepositoryIdentity,
        platform: str | None,
        mode: str,
        scenario: ArtifactRecord | None,
    ) -> None:
        """Retain one bounded candidate from explicit typed source coordinates.

        ArtifactRecords supply source/origin/optional scenario; criterion is
        JsonObject at position (int). obligation/client are optional
        FeatureObligation/ClientProfile; owner is RepositoryIdentity, platform is
        str | None and mode is str. Returns None, changing local candidates,
        collisions and budgets only. No I/O; ValueError aborts invalid bounds.
        """
        ctx = self.context
        client_id = client.id if client else None
        identity = AcceptanceIdentity(
            source_repository_id=source.repository,
            kind=self.kind,
            feature_id=str(source.document["feature_id"]),
            criterion_id=str(criterion["id"]),
            client_id=client_id,
            platform_id=platform,
            mode_id=mode,
            linked_scenario=(
                (scenario.repository, str(scenario.document["scenario_id"]))
                if scenario
                else None
            ),
        )
        ctx.output.check(identity.key(limits=ctx.limits))
        key = canonical_json(identity.key(limits=ctx.limits))
        identifier = identity.scenario_id(limits=ctx.limits)
        field = (
            "acceptance_criteria"
            if source is origin
            else "resulting_acceptance_criteria"
        )
        proof = ctx.linked(origin, f"/{field}/{position}/evidence_refs")
        # A linked observation supplies its action; otherwise retain contract facts.
        if scenario is not None:
            proof += ctx.linked(scenario, "/evidence_refs")
            action = scenario.document.get("action")
            action = (
                action.get("description") if isinstance(action, JsonObject) else None
            )
            given = scenario.document.get("preconditions", ())
        else:
            trigger, conditions = source.document.get("trigger"), source.document.get(
                "preconditions"
            )
            action = (
                trigger.get("statement")
                if isinstance(trigger, JsonObject)
                and trigger.get("observation_state") not in {"unknown", "contradictory"}
                else None
            )
            given = (
                (conditions["statement"],)
                if isinstance(conditions, JsonObject)
                and has_text(conditions.get("statement"))
                else ()
            )
        approval: ApprovedDecision | None = self.approvals.get(
            (origin.artifact.path, origin.pointer)
        )
        # Public approval scope is the only source of target-policy authority.
        approved = approval is not None and approval.scope.covers(
            decision_scope(
                source,
                client_id=client_id,
                platforms=(platform,) if platform else (),
                modes=(mode,),
                dimensions=tuple(approval.scope.selectors[3]),
            )
        )
        ready = (
            criterion.get("readiness") == "ready"
            and has_text(criterion.get("expected_result"))
            and has_text(action)
            and (origin is source or approved)
        )
        mobile = source.document.get("mobile")
        classification = (
            mobile.get("applicability") if isinstance(mobile, JsonObject) else None
        )
        # Only absent source classification permits an explicit client default.
        if classification is None and client is not None:
            default = client.applicability_defaults.get("mobile")
            classification = (
                default.get("applicability")
                if isinstance(default, JsonObject)
                else None
            )
        mobile_applicable = (
            classification == "applicable"
            and (
                platform == "mobile"
                or mode == "mobile"
                or obligation is not None
                and "mobile" in obligation.requirements.dimensions
            )
            and (obligation is None or "mobile" not in obligation.waived)
        )
        ctx.budget.work(
            len(proof) + len(key) + len(given)
            if isinstance(given, tuple)
            else len(proof) + len(key)
        )
        # Immutable references are deduplicated by exact identity before retention.
        evidence = tuple(dict.fromkeys(ctx.reference(item) for item in proof))
        document = {
            "$schema": "urn:drm-copilot:discovery:2.0.0:acceptance-specification",
            "schema_version": "2.0.0",
            "artifact_kind": "acceptance-specification",
            "id": identifier,
            "scenario_id": identifier,
            "kind": self.kind,
            "feature_id": identity.feature_id,
            "criterion_id": identity.criterion_id,
            "client_id": client_id,
            "platform_id": platform,
            "mode_id": mode,
            "readiness": "ready" if ready else "pending",
            "given": given,
            "when": action,
            "then": (criterion["expected_result"],) if ready else None,
            "pending_reasons": (
                ()
                if ready
                else (
                    (
                        criterion.get("pending_reason")
                        if has_text(criterion.get("pending_reason"))
                        else "A supported expectation and explicit action are required."
                    ),
                )
            ),
            "expectation_basis": (
                ("verified-source" if origin is source else "approved-decision")
                if ready
                else "unresolved"
            ),
            "source_contract_refs": (ctx.reference(source, source=True),),
            "evidence_refs": evidence,
            "product_decision_refs": (
                () if source is origin else (ctx.reference(origin),)
            ),
            "tags": acceptance_tags(
                identity, limits=ctx.limits, mobile_applicable=mobile_applicable
            ),
            "source_content_sha256": ctx.digest(source, origin),
            "extensions": {
                "drm-copilot.generation": {
                    "scenario": ctx.reference(scenario) if scenario else None
                }
            },
        }
        before = ctx.output.bytes_left
        ctx.output.check(document)
        ctx.budget.work(4 * (before - ctx.output.bytes_left) + len(key))
        value = AcceptanceSpecification(
            repository=owner,
            identity=identity,
            document=bounded_object(document, limits=ctx.limits),
            limits=ctx.limits,
        )
        binding = key, canonical_json(value.document)
        if identifier in self.collisions:
            return
        # Reject every competing value instead of selecting one conflicting identity.
        if identifier in self.values and (
            self.keys[identifier] != binding
            or self.values[identifier].repository != owner
        ):
            ctx.problem(
                "ACCEPTANCE_COLLISION",
                "Generated identities have conflicting content.",
                source,
            )
            del self.values[identifier]
            self.collisions.add(identifier)
        else:
            self.values[identifier], self.keys[identifier] = value, binding

    def expand(self, source: ArtifactRecord) -> None:
        """Project source ArtifactRecord into bounded actual coordinates; return None.

        Candidate products and selector comparisons are reserved before loops.
        Missing coordinates create no fallback. Only private buffers change;
        ValueError aborts excess without partial output.
        """
        ctx = self.context
        ctx.budget.work(len(ctx.dimensions.obligations))
        # Target expansion uses inherited public obligations; legacy has no client.
        obligations = (
            tuple(item for item in ctx.dimensions.obligations if item.feature is source)
            if self.kind == "target-acceptance"
            else (None,)
        )
        criteria = ctx.criteria(source, target=self.kind == "target-acceptance")
        ctx.budget.work(4 * len(criteria) * len(obligations))
        # Retain target ownership separately from source-feature identity.
        for obligation in obligations:
            client = (
                self.client_map.get(obligation.client_id)
                if obligation and obligation.client_id is not None
                else None
            )
            if self.kind == "target-acceptance" and (
                client is None or self.clients and client.id not in self.clients
            ):
                continue
            owner = (
                self.target_map.get(client.target_repository)
                if client
                else source.artifact.repository
            )
            if owner is None or owner.revision is None:
                ctx.problem(
                    "ACCEPTANCE_OWNER",
                    "The selected owner has no captured pin.",
                    source,
                )
                continue
            requirements = (
                obligation.requirements
                if obligation
                else ctx.snapshot.profile.requirements()
            )
            ctx.budget.work(len(requirements.platforms) + len(requirements.modes))
            # Approved waivers remove coordinates without inventing alternatives.
            platforms = tuple(
                p
                for p in requirements.platforms
                if obligation is None or p not in obligation.waived
            ) or ((None,) if client is None else ())
            # Mode waivers likewise restrict the configured coordinate product.
            modes = tuple(
                m
                for m in requirements.modes
                if obligation is None or m not in obligation.waived
            )
            self.seen_modes.update(modes)
            # Reserve probe-label hashing conservatively for every product member.
            coordinate_text = sum(len(p or "") for p in platforms)
            coordinate_text += sum(map(len, modes)) + (len(client.id) if client else 0)
            ctx.budget.work(len(platforms) * len(modes) * max(1, len(criteria)))
            # Explicit criterion selectors intersect configured coordinates.
            for origin, position, criterion in criteria:
                # Fixed-axis lookups are prepaid; reserve member visits before lengths.
                selector_size = sum(
                    len(selected)
                    for name in ("client_ids", "platforms", "modes")
                    if isinstance(selected := criterion.get(name, ()), tuple)
                )
                ctx.budget.work(selector_size)
                # Each coordinate may hash and compare every selected identifier.
                selector_text = sum(
                    len(value)
                    for name in ("client_ids", "platforms", "modes")
                    if isinstance(selected := criterion.get(name, ()), tuple)
                    for value in selected
                    if isinstance(value, str)
                )
                per_coordinate = 4 + selector_size + 2 * selector_text + coordinate_text
                ctx.budget.work(len(platforms) * len(modes) * per_coordinate)
                # The product reservation precedes coordinate enumeration.
                for platform, mode in product(platforms, modes):
                    if (
                        self.modes
                        and mode not in self.modes
                        or not criterion_applies(
                            criterion, client.id if client else None, platform, mode
                        )
                    ):
                        continue
                    scenarios = self.scenarios(source, platform, mode)
                    ctx.budget.work(len(scenarios))
                    # Linked observations distinguish equal criterion coordinates.
                    for scenario in scenarios:
                        self.candidate(
                            source,
                            origin,
                            position,
                            criterion,
                            obligation,
                            client,
                            owner,
                            platform,
                            mode,
                            scenario,
                        )

    def finish(self) -> AcceptanceGeneration:
        """Return final immutable specifications with authority from public rules.

        At most two complete assessments run. Unsupported candidates become
        pending without losing prior findings. Resource failures raise ValueError;
        no input, implementation state or filesystem is modified.
        """
        ctx = self.context
        ctx.budget.work(len(ctx.index.records) + len(self.features) + len(self.clients))
        # Qualified feature identities preserve equal feature names across repositories.
        for source in ctx.index.records:
            if (
                source.kind != "feature-contract"
                or source.artifact.repository not in ctx.sources
            ):
                continue
            key = source.repository, str(source.document["feature_id"])
            self.seen_features.add(key)
            if not self.features or key in self.features:
                self.expand(source)
        if (
            self.features - self.seen_features
            or self.clients - self.client_map.keys()
            or self.modes - self.seen_modes
        ):
            ctx.problem(
                "ACCEPTANCE_SELECTOR", "A selector has no captured configured match."
            )
        return ctx.finalize(tuple(self.values.values()))


def generate_acceptance(
    snapshot: DiscoverySnapshot,
    *,
    kind: AcceptanceKind,
    feature_ids: tuple[tuple[str, str], ...] = (),
    client_ids: tuple[str, ...] = (),
    mode_ids: tuple[str, ...] = (),
) -> AcceptanceGeneration:
    """Generate normalized ready/pending specifications from captured inputs only.

    snapshot is DiscoverySnapshot; kind selects legacy or target ownership.
    feature_ids are qualified repository/feature pairs; client_ids/mode_ids are
    explicit identifier tuples. Empty filters select actual eligible coordinates.
    Returns AcceptanceGeneration. ValueError rejects API/resource errors; captured
    integrity failures remain findings. No I/O, publication, AC or test mutation.
    """
    budget = generation_preflight(snapshot)
    if type(kind) is not str or kind not in {
        "legacy-characterization",
        "target-acceptance",
    }:
        raise ValueError("Acceptance generation requires a supported kind")
    context = GenerationContext(snapshot, budget)
    features = cast(
        "tuple[tuple[str, str], ...]", context.selectors(feature_ids, qualified=True)
    )
    clients = cast("tuple[str, ...]", context.selectors(client_ids))
    modes = cast("tuple[str, ...]", context.selectors(mode_ids))
    if kind == "legacy-characterization" and clients:
        context.problem(
            "ACCEPTANCE_SELECTOR",
            "Legacy characterization cannot select target clients.",
        )
    if not context.structural_ok or kind == "legacy-characterization" and clients:
        return AcceptanceGeneration(
            specifications=(),
            ready=(),
            findings=context.collector.findings,
            limits=context.limits,
        )
    return _Generation(context, kind, features, clients, modes).finish()
