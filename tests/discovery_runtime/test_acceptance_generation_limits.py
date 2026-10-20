"""Verify prospective generation limits with immutable in-memory inputs."""

from __future__ import annotations

from dataclasses import replace
from types import SimpleNamespace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import acceptance_generation as generation_module
from drm_copilot_discovery import acceptance_generation_context as context_module
from drm_copilot_discovery.acceptance_generation import generate_acceptance
from drm_copilot_discovery.acceptance_generation_context import (
    GenerationContext,
    generation_preflight,
)
from drm_copilot_discovery.acceptance_rules import validate_acceptance
from drm_copilot_discovery.dimension_rules import FeatureObligation
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.profile_models import ProfileRequirements
from drm_copilot_discovery.profile_v2 import ProfileError
from drm_copilot_discovery.references import ArtifactRecord, ReferenceIndex
from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError
from drm_copilot_discovery.repository_reader import RepositoryIdentity
from drm_copilot_discovery.snapshot import ArtifactSnapshot

from tests.discovery_runtime.test_acceptance_generation import (
    amended,
    generation_snapshot,
    source_criterion,
)
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)

if TYPE_CHECKING:
    from typing import Protocol

    from drm_copilot_discovery.acceptance_models import (
        AcceptanceKind,
        AcceptanceSpecification,
    )
    from drm_copilot_discovery.acceptance_rules import AcceptanceValidation
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.decision_rules import DecisionValidation
    from drm_copilot_discovery.dimension_rules import DimensionValidation
    from drm_copilot_discovery.evidence_rules import EvidenceValidation
    from drm_copilot_discovery.findings import Finding
    from drm_copilot_discovery.snapshot import DiscoverySnapshot

    class Expansion(Protocol):
        """Describe only the expansion seam inspected by the counted regression."""

        values: dict[str, AcceptanceSpecification]

        def expand(self, source: ArtifactRecord) -> None:
            """Expand source (ArtifactRecord); return None or raise ReportLimitError.

            Only call-local candidates and budget counters change.
            """


class CountedIdentifier(str):
    """Retain ordinary string semantics and observe local comparison/hash work.

    Construct with text and a two-element counter list; no I/O or input rewrite
    occurs. Counters measure characters presented to equality and hashing.
    """

    counts: list[int]

    def __new__(cls, value: str, counts: list[int]) -> CountedIdentifier:
        """Return unchanged value (str), retaining counts (list[int]); no I/O."""
        result = super().__new__(cls, value)
        result.counts = counts
        return result

    def __eq__(self, value: object) -> bool:
        """Return bool equality for value (object), updating only local counters."""
        equal = super().__eq__(value)
        # Unequal identities do not establish the repeated positive-comparison cost.
        if equal:
            self.counts[0] += len(self)
        return equal

    def __hash__(self) -> int:
        """Return int hash, adding input length to the local counter; no I/O."""
        self.counts[1] += len(self)
        return super().__hash__()


@pytest.mark.parametrize("width,size", [(32, 16), (4096, 16), (4096, 32)])
def test_coordinate_comparisons_reserve_text_work_before_matching(
    width: int, size: int
) -> None:
    """Count actual repeated applicability work for finite integer coordinates.

    Returns None; a short remaining budget must raise ReportLimitError before
    equality/hash operations. A sufficient budget executes the real public
    matcher with no candidate. Only call-local fake assessments/counters mutate.
    """
    counts = [0, 0]
    text = "c" * width
    repository = RepositoryIdentity(id="source", revision="a" * 40)
    document = JsonObject((("id", "feature"), ("feature_id", "feature")))
    artifact = ArtifactSnapshot(
        path="docs/feature.json",
        expected_kind="feature-contract",
        repository=repository,
        document=document,
    )
    record = ArtifactRecord(
        artifact=artifact, kind="feature-contract", document=document
    )
    criterion = JsonObject(
        (
            ("id", "criterion"),
            ("client_ids", (CountedIdentifier(text, counts),)),
            ("platforms", ("absent-platform",)),
            ("modes", ("online",)),
        )
    )
    # A matching long client precedes a negative platform, so no output masks work.
    requirements = ProfileRequirements(
        # Enumerate fixed platforms independently of the criterion's unmatched name.
        platforms=tuple(f"platform-{i:02}" for i in range(size)),
        # Every mode produces another real repeated applicability comparison.
        modes=tuple(f"mode-{i:02}" for i in range(size)),
        dimensions=(),
    )
    obligation = FeatureObligation(
        feature=record,
        client_id=text,
        requirements=requirements,
        required=True,
        waived=frozenset(),
    )
    budget = ReportBudget(ParseLimits(artifact_records=1_000_000))
    client = SimpleNamespace(id=text, target_repository=repository.id)

    def criteria(
        source: ArtifactRecord, *, target: bool
    ) -> tuple[tuple[ArtifactRecord, int, JsonObject], ...]:
        """Return one (ArtifactRecord, int, JsonObject) tuple for known inputs.

        source is ArtifactRecord and target is bool. Assert the fixture identity;
        no expected exception, I/O or mutation occurs.
        """
        assert source is record and target
        return ((record, 0, criterion),)

    context = cast(
        "GenerationContext",
        SimpleNamespace(
            budget=budget,
            index=ReferenceIndex(records=(record,)),
            snapshot=SimpleNamespace(profile=SimpleNamespace(clients=(client,))),
            targets=(repository,),
            decisions=SimpleNamespace(approved=()),
            dimensions=SimpleNamespace(obligations=(obligation,)),
            criteria=criteria,
        ),
    )
    # The retained review probe targets this actual private stage, not copied logic.
    generation = cast(
        "Expansion",
        vars(generation_module)["_Generation"](
            context, "target-acceptance", (), (), ()
        ),
    )
    counts[:] = [0, 0]
    budget.work_left = 7000
    with pytest.raises(ReportLimitError):
        generation.expand(record)
    assert counts == [0, 0] and not generation.values
    budget.work_left = budget.limits.expanded_nodes
    before = budget.work_left
    generation.expand(record)
    assert counts[0] == width * size * size and counts[1] > 0
    assert sum(counts) <= before - budget.work_left
    assert not generation.values


@pytest.mark.parametrize("change", ["no-criteria", "no-modes", "no-platforms"])
def test_empty_actual_population_does_not_create_fallback_scenarios(
    snapshot_catalog: SchemaCatalog,
    change: str,
) -> None:
    """Preserve empty actual configuration; typed fixture inputs return None.

    No I/O occurs. ProfileError rejects an invalid empty configured mode set;
    valid empty criteria/platform choices never invent a replacement coordinate.
    """
    profile_changes: dict[str, object] = {}
    source_changes: dict[str, object] = {}
    # Empty configured modes are invalid; other valid empty inputs remain literal.
    if change == "no-modes":
        with pytest.raises(ProfileError, match="required_modes"):
            generation_snapshot(
                snapshot_catalog, profile_changes={"required_modes": []}
            )
        return
    if change == "no-criteria":
        source_changes["acceptance_criteria"] = []
    else:
        profile_changes[
            "required_modes" if change == "no-modes" else "required_platforms"
        ] = []
    snapshot = generation_snapshot(
        snapshot_catalog, source_changes=source_changes, profile_changes=profile_changes
    )
    result = generate_acceptance(snapshot, kind="legacy-characterization")
    assert len(result.specifications) == (1 if change == "no-platforms" else 0)
    if result.specifications:
        assert result.specifications[0].identity.platform_id is None


def test_two_complete_rule_passes_are_independent_of_candidate_count(
    snapshot_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Count real public batch assessments, then return None with patch restored.

    Catalog and MonkeyPatch are injected fixtures. Wrapper delegates unchanged
    rule behavior and observes complete populations without per-record validation.
    """
    original = validate_acceptance
    calls: list[int] = []

    def counted(
        snapshot: DiscoverySnapshot,
        *,
        complete: bool = False,
        index: ReferenceIndex | None = None,
        evidence: EvidenceValidation | None = None,
        decisions: DecisionValidation | None = None,
        dimensions: DimensionValidation | None = None,
    ) -> AcceptanceValidation:
        """Observe typed public batch arguments; return original assessment.

        Only the test-local calls list changes; rule exceptions propagate intact.
        """
        calls.append(
            sum(
                item.expected_kind == "acceptance-specification"
                for item in snapshot.artifacts
            )
        )
        return original(
            snapshot,
            complete=complete,
            index=index,
            evidence=evidence,
            decisions=decisions,
            dimensions=dimensions,
        )

    monkeypatch.setattr(context_module, "validate_acceptance", counted)
    snapshot = generation_snapshot(
        snapshot_catalog, profile_changes={"required_modes": ["online", "offline"]}
    )
    snapshot = amended(
        snapshot,
        "feature-alpha",
        {
            "acceptance_criteria": [
                source_criterion(snapshot, modes=["online", "offline"])
            ]
        },
    )
    result = generate_acceptance(snapshot, kind="legacy-characterization")
    assert len(result.specifications) == 2 and calls == [2, 2]


@pytest.mark.parametrize("value", [None, [], ("bad/name",), (True,), ("trailing-",)])
def test_invalid_selectors_fail_without_coercion(
    snapshot_catalog: SchemaCatalog,
    value: object,
) -> None:
    """Reject malformed selector objects; return None after expected ValueError.

    Snapshot bytes and external state remain unchanged.
    """
    with pytest.raises(ValueError, match="Acceptance selectors"):
        generate_acceptance(
            generation_snapshot(snapshot_catalog),
            kind="legacy-characterization",
            mode_ids=cast("tuple[str, ...]", value),
        )


@pytest.mark.parametrize(
    "limit", ["source_files", "document_bytes", "artifact_records"]
)
def test_capacity_exhaustion_precedes_public_assessment(
    snapshot_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
    limit: str,
) -> None:
    """Count no input assessment under over-budget captures; return None.

    Catalog/MonkeyPatch/str are fixtures. Only a temporary observer changes;
    ReportLimitError is expected before parsing or partial generation.
    """
    snapshot = generation_snapshot(
        snapshot_catalog, profile_changes={"limits": {limit: 1}}
    )
    calls: list[int] = []

    def forbidden(snapshot: DiscoverySnapshot) -> tuple[Finding, ...]:
        """Count an unexpected typed snapshot assessment and fail locally.

        Returns no value; raises AssertionError, changes only calls, performs no I/O.
        """
        calls.append(len(snapshot.artifacts))
        raise AssertionError("Input assessment must not run before capacity checks")

    monkeypatch.setattr(context_module, "validate_inputs", forbidden)
    with pytest.raises(ReportLimitError):
        generate_acceptance(snapshot, kind="legacy-characterization")
    assert calls == []


def test_batch_pass_limit_and_output_capacity_fail_without_partial_result(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Exercise context lifecycle/output ceiling with a catalog fixture; return None.

    Only local budgets change. ValueError is expected for a third pass and
    ReportLimitError for output bytes reserved before immutable reference allocation.
    """
    snapshot = generation_snapshot(snapshot_catalog)
    context = GenerationContext(snapshot, generation_preflight(snapshot))
    context.assess(())
    context.assess(())
    with pytest.raises(ValueError, match="two batch"):
        context.assess(())
    # Select the actual source record whose reference allocation is under test.
    source = next(
        item for item in context.index.records if item.kind == "feature-contract"
    )
    context.output = ReportBudget(context.limits)
    context.output.bytes_left = 1
    with pytest.raises(ReportLimitError):
        context.reference(source, source=True)


@pytest.mark.parametrize("kind", [None, True, "other"])
def test_unsupported_kinds_cannot_select_an_implicit_generation_mode(
    snapshot_catalog: SchemaCatalog,
    kind: object,
) -> None:
    """Reject malformed kind values with ValueError; return None without effects."""
    with pytest.raises(ValueError, match="supported kind"):
        generate_acceptance(
            generation_snapshot(snapshot_catalog), kind=cast("AcceptanceKind", kind)
        )


def test_legacy_client_selector_is_an_explicit_failure(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Prevent target selection on legacy generation; catalog fixture returns None.

    No I/O, implicit client fallback or expected exception occurs.
    """
    result = generate_acceptance(
        generation_snapshot(snapshot_catalog, target=True),
        kind="legacy-characterization",
        client_ids=("client-alpha",),
    )
    assert not result.specifications and not result.ready
    assert any(item.code == "ACCEPTANCE_SELECTOR" for item in result.findings)


def test_missing_reference_revision_rejects_before_output_reservation(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Reject an unpinned local record before retaining reference output.

    snapshot_catalog is SchemaCatalog. Return None after expected ValueError;
    captured inputs and both output counters remain unchanged, without I/O.
    """
    snapshot = generation_snapshot(snapshot_catalog)
    context = GenerationContext(snapshot, generation_preflight(snapshot))
    # Preserve the valid source while constructing only the invalid call argument.
    source = next(
        item for item in context.index.records if item.kind == "feature-contract"
    )
    unpinned = replace(
        source,
        artifact=replace(
            source.artifact,
            repository=replace(source.artifact.repository, revision=None),
        ),
    )
    before = context.output.bytes_left, context.output.records_left
    with pytest.raises(ValueError, match="captured revision"):
        context.reference(unpinned, source=True)
    assert (context.output.bytes_left, context.output.records_left) == before
    assert source.artifact.repository.revision is not None
