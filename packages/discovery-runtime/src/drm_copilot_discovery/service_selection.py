"""Select captured source identities and exact generated platform projections."""

from __future__ import annotations

from typing import TYPE_CHECKING

from drm_copilot_discovery.acceptance_generation_context import generation_preflight
from drm_copilot_discovery.acceptance_models import AcceptanceGeneration
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError
from drm_copilot_discovery.service_contracts import ServiceRequestError
from drm_copilot_discovery.snapshot import DiscoverySnapshot, repository_pins

if TYPE_CHECKING:
    from drm_copilot_discovery.references import ArtifactRecord


def _invalid(pointer: str) -> ServiceRequestError:
    """Return a fixed selector error for pointer (str), without I/O or input text.

    The known operation is retained; request mode belongs to the caller. The
    resulting error grants no authority and does not relabel graph failures.
    """
    return ServiceRequestError(
        (
            Finding(
                code="SERVICE_SELECTOR",
                pointer=pointer,
                message="Selection requires unique captured source coordinates.",
                next_action="Use explicit existing source identities and coordinates.",
            ),
        ),
        operation="generate-acceptance",
    )


def _selectors(
    values: tuple[str, ...], budget: ReportBudget, pointer: str
) -> tuple[str, ...]:
    """Return sorted exact values under budget, without normalizing identifiers.

    values is an immutable str tuple, budget is call-local ReportBudget, and
    pointer (str) names the request field. ServiceRequestError rejects malformed
    or duplicate selectors; ReportLimitError rejects prospective work/bytes.
    Only local containers and counters change; no I/O or graph assessment occurs.
    """
    if type(values) is not tuple:
        raise _invalid(pointer)
    if len(values) > budget.limits.artifact_records:
        raise ReportLimitError()
    budget.work(8 * len(values))
    maximum = 0
    # Validate exact types before hashing or invoking comparison methods.
    for value in values:
        if type(value) is not str or not value:
            raise _invalid(pointer)
        budget.work(4 * len(value))
        budget.check(value)
        maximum = max(maximum, len(value))
    budget.work(2 * len(values) * max(1, len(values).bit_length()) * maximum)
    if len(set(values)) != len(values):
        raise _invalid(pointer)
    return tuple(sorted(values))


def _feature_id(record: ArtifactRecord, budget: ReportBudget) -> str:
    """Read one retained feature ID with prepaid immutable lookup work.

    record is ArtifactRecord and budget is local ReportBudget. Return str or
    raise ServiceRequestError for a missing/untyped ID; capacity raises
    ReportLimitError. No copy, source mutation, I/O or semantic proof occurs.
    """
    budget.work(16 * len(record.document))
    identifier = record.document.get("feature_id")
    if type(identifier) is not str or not identifier:
        raise _invalid("/inputs/feature_ids")
    budget.work(4 * len(identifier))
    budget.check(identifier)
    return identifier


def resolve_feature_ids(
    snapshot: DiscoverySnapshot,
    *,
    feature_ids: tuple[str, ...] = (),
    repository_id: str | None = None,
) -> tuple[tuple[str, str], ...]:
    """Return source-qualified identities from an authoritative captured index.

    snapshot is DiscoverySnapshot; feature_ids is an exact str tuple and
    repository_id is an optional str namespace. Omitted filters return () to
    preserve generator all-source behavior. Repository-only selection must have
    a nonempty unique source set, so it cannot accidentally widen that default.
    Invalid/ambiguous selection raises ServiceRequestError; bounds raise
    ReportLimitError. No validation verdict, I/O, pin or source value is changed.
    """
    if (
        type(snapshot) is not DiscoverySnapshot
        or type(feature_ids) is not tuple
        or (repository_id is not None and type(repository_id) is not str)
    ):
        raise _invalid("/inputs/feature_ids")
    budget = ReportBudget(snapshot.profile.limits.parse_limits())
    # The accepted aggregate preflight remains the same budget used by selection.
    if feature_ids or repository_id is not None:
        budget = generation_preflight(snapshot)
    requested = _selectors(feature_ids, budget, "/inputs/feature_ids")
    if repository_id is not None:
        _selectors((repository_id,), budget, "/inputs/repository_id")
    if not requested and repository_id is None:
        return ()
    budget.work(8 * (1 + len(snapshot.profile.repositories)))
    sources, _ = repository_pins(snapshot.profile)
    owners: set[tuple[str, str | None]] = set()
    source_names: set[str] = set()
    # Full role pins prevent local or target ownership from being guessed.
    for owner in sources:
        budget.work(4 * (len(owner.id) + len(owner.revision or "")))
        budget.check((owner.id, owner.revision))
        owners.add((owner.id, owner.revision))
        source_names.add(owner.id)
    if repository_id is not None and repository_id not in source_names:
        raise _invalid("/inputs/repository_id")
    index = index_references(snapshot)
    budget.work(8 * len(index.records))
    maximum_owner = 0
    names: set[str] = set()
    # Record text work precedes each hash/comparison and repository-only ID copy.
    for record in index.records:
        owner = record.artifact.repository
        owner_size = len(owner.id) + len(owner.revision or "")
        budget.work(4 * owner_size)
        maximum_owner = max(maximum_owner, owner_size)
        if (
            record.kind == "feature-contract"
            and (owner.id, owner.revision) in owners
            and (repository_id is None or owner.id == repository_id)
        ):
            names.add(_feature_id(record, budget))
    if not requested:
        requested = _selectors(tuple(names), budget, "/inputs/feature_ids")
    if not requested:
        raise _invalid("/inputs/feature_ids")
    # The public candidate lookup may inspect every record for each requested ID.
    budget.work(len(requested) * (len(index.records) + 1) * (8 + 4 * maximum_owner))
    budget.spend(16 * len(requested))
    selected: list[tuple[str, str]] = []
    # Keep only unique source-owned matches; equal local names confer no priority.
    for identifier in requested:
        candidates = index.candidates(
            "feature-contract",
            identifier,
            repository=repository_id,
            identity_field="feature_id",
        )
        # The accepted index supplies records; ownership is the configured full pin.
        matches = tuple(
            record
            for record in candidates
            if (
                record.artifact.repository.id,
                record.artifact.repository.revision,
            )
            in owners
        )
        if len(matches) != 1:
            raise _invalid("/inputs/feature_ids")
        owner = matches[0].repository
        budget.check((owner, identifier))
        selected.append((owner, identifier))
    budget.work(
        2
        * len(selected)
        * max(1, len(selected).bit_length())
        * (maximum_owner + max(map(len, requested)))
    )
    return tuple(sorted(selected))


def select_acceptance_platforms(
    generation: AcceptanceGeneration, *, platform_ids: tuple[str, ...] = ()
) -> AcceptanceGeneration:
    """Project actual generation onto platform_ids while preserving all evidence.

    generation must be the trusted producer's AcceptanceGeneration; this function
    cannot establish its origin or readiness. platform_ids is an exact str tuple.
    Return the original result for omitted selectors or unmatched blocked input;
    otherwise reuse exact candidate objects and original ready membership.
    Missing nonblocking coordinates raise ServiceRequestError. Prospective
    count/text/output work raises ReportLimitError. No I/O or rule evaluation.
    """
    if type(generation) is not AcceptanceGeneration:
        raise _invalid("/inputs/platform_ids")
    budget = ReportBudget(generation.limits)
    requested = _selectors(platform_ids, budget, "/inputs/platform_ids")
    if not requested:
        return generation
    count = len(generation.specifications) + len(generation.ready)
    count += len(generation.findings)
    if count > generation.limits.artifact_records:
        raise ReportLimitError()
    budget.work(16 * count)
    present: set[str] = set()
    # Exact retained coordinates supply availability; None never matches a name.
    for item in generation.specifications:
        platform = item.identity.platform_id
        if platform is not None:
            budget.work(8 * len(platform))
            budget.check(platform)
            present.add(platform)
    # Blocking graph findings retain exit-1 semantics when availability is unknown.
    blocked = any(finding.severity == "error" for finding in generation.findings)
    if any(platform not in present for platform in requested):
        if blocked:
            return generation
        raise _invalid("/inputs/platform_ids")
    selected_names = set(requested)
    budget.spend(16 * count)
    # Object identities avoid recursive document equality or synthesized readiness.
    ready_objects = {id(item) for item in generation.ready}
    # The prospective pass reserved coordinate hashing and tuple allocation first.
    specifications = tuple(
        item
        for item in generation.specifications
        if item.identity.platform_id in selected_names
    )
    # Pending candidates stay pending; ready-looking unvalidated rows stay withheld.
    ready = tuple(item for item in specifications if id(item) in ready_objects)
    return AcceptanceGeneration(
        specifications=specifications,
        ready=ready,
        findings=generation.findings,
        limits=generation.limits,
    )
