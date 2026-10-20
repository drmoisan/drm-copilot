"""Exercise source-qualified selection and exact acceptance-result projections."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import service_selection
from drm_copilot_discovery.acceptance_generation import generate_acceptance
from drm_copilot_discovery.acceptance_models import AcceptanceGeneration
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError
from drm_copilot_discovery.repository_reader import RepositoryIdentity
from drm_copilot_discovery.service_contracts import ServiceRequestError
from drm_copilot_discovery.service_selection import (
    resolve_feature_ids,
    select_acceptance_platforms,
)

from tests.discovery_runtime.test_acceptance_generation import (
    generation_snapshot,
    imported_snapshot,
)
from tests.discovery_runtime.test_acceptance_properties import (
    generation,
    identity,
    specification,
)
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.schemas.discovery.v2_schema_test_support import load_fixture

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


def two_sources(catalog: SchemaCatalog) -> DiscoverySnapshot:
    """Return captured duplicate feature names in two configured source owners.

    catalog is an immutable SchemaCatalog. Distinct original paths, bytes and
    full pins remain bound; only new local fixture containers are created.
    Invalid fixture construction raises ValueError; no writes or external I/O.
    """
    foreign = load_fixture("feature-contract")
    foreign["id"] = "foreign-feature"
    owner = RepositoryIdentity(id="other-source", revision="c" * 40)
    snapshot = generation_snapshot(
        catalog,
        extras=(foreign,),
        profile_changes={
            "repositories": [
                {
                    "id": owner.id,
                    "role": "legacy-source",
                    "revision": owner.revision,
                    "snapshot_manifest": None,
                    "clients": [],
                }
            ]
        },
    )
    path = "docs/migration/discovery/foreign-feature.json"
    # Bind the foreign artifact and its retained original bytes to the same pin.
    artifacts = tuple(
        replace(item, repository=owner) if item.path == path else item
        for item in snapshot.artifacts
    )
    # Pin metadata changes together; no content or source path is synthesized.
    files = tuple(
        replace(item, repository=owner) if item.path == path else item
        for item in snapshot.repository_files
    )
    return replace(snapshot, artifacts=artifacts, repository_files=files)


def test_default_selection_preserves_generator_all_source_semantics(
    snapshot_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Use catalog/monkeypatch fixtures; assert no index construction; return None."""
    snapshot = generation_snapshot(snapshot_catalog)

    def unexpected_index(snapshot: DiscoverySnapshot) -> None:
        """Reject snapshot indexing with AssertionError; never return or perform I/O."""
        raise AssertionError("Omitted selectors must not construct an index")

    monkeypatch.setattr(service_selection, "index_references", unexpected_index)
    assert resolve_feature_ids(snapshot) == ()


@pytest.mark.parametrize("repository_only", [False, True])
def test_imported_source_resolves_without_local_owner_preference(
    snapshot_catalog: SchemaCatalog, repository_only: bool
) -> None:
    """Resolve captured import under bool filter form; return None without I/O."""
    snapshot = imported_snapshot(snapshot_catalog)
    before = snapshot.manifest
    assert resolve_feature_ids(
        snapshot,
        feature_ids=() if repository_only else ("feature-alpha",),
        repository_id="imported-source" if repository_only else None,
    ) == (("imported-source", "feature-alpha"),)
    assert snapshot.manifest is before
    with pytest.raises(ServiceRequestError):
        resolve_feature_ids(
            snapshot,
            feature_ids=("feature-alpha",),
            repository_id=snapshot.profile.repository.id,
        )


def test_ambiguous_source_names_require_explicit_repository(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Use catalog fixture; assert ambiguity and both explicit resolutions; no I/O."""
    snapshot = two_sources(snapshot_catalog)
    with pytest.raises(ServiceRequestError) as caught:
        resolve_feature_ids(snapshot, feature_ids=("feature-alpha",))
    assert caught.value.operation == "generate-acceptance"
    assert caught.value.findings[0].code == "SERVICE_SELECTOR"
    assert resolve_feature_ids(
        snapshot, feature_ids=("feature-alpha",), repository_id="other-source"
    ) == (("other-source", "feature-alpha"),)
    assert resolve_feature_ids(
        snapshot, repository_id=snapshot.profile.repository.id
    ) == ((snapshot.profile.repository.id, "feature-alpha"),)


@pytest.mark.parametrize(
    "reason", ["missing", "duplicate", "target", "revision", "empty", "untyped"]
)
def test_invalid_feature_membership_never_selects_a_fallback(
    snapshot_catalog: SchemaCatalog, reason: str
) -> None:
    """Vary reason (str); require ServiceRequestError and no fallback; return None."""
    snapshot = generation_snapshot(snapshot_catalog)
    repository = snapshot.profile.repository.id
    selected = ("missing",) if reason == "missing" else ("feature-alpha",)
    # Each case isolates one unavailable or nonunique authoritative coordinate.
    if reason == "duplicate":
        duplicate = load_fixture("feature-contract")
        duplicate["id"] = "duplicate-feature"
        snapshot = generation_snapshot(snapshot_catalog, extras=(duplicate,))
    elif reason in ("target", "revision"):
        owner = RepositoryIdentity(
            id="unconfigured-target" if reason == "target" else repository,
            revision="d" * 40,
        )
        # This negative deliberately disconnects retained records from source pins.
        snapshot = replace(
            snapshot,
            artifacts=tuple(
                replace(item, repository=owner) for item in snapshot.artifacts
            ),
        )
    elif reason == "empty":
        snapshot = replace(snapshot, artifacts=())
        selected = ()
    elif reason == "untyped":
        snapshot = generation_snapshot(
            snapshot_catalog, source_changes={"feature_id": None}
        )
    with pytest.raises(ServiceRequestError):
        resolve_feature_ids(snapshot, feature_ids=selected, repository_id=repository)


@pytest.mark.parametrize(
    "selectors", [[], ("",), (1,), ("feature-alpha", "feature-alpha")]
)
def test_invalid_feature_selector_types_are_rejected(
    snapshot_catalog: SchemaCatalog, selectors: object
) -> None:
    """Pass selectors (object) through typed boundary; expect fixed error; no I/O."""
    with pytest.raises(ServiceRequestError):
        resolve_feature_ids(
            generation_snapshot(snapshot_catalog),
            feature_ids=cast("tuple[str, ...]", selectors),
        )


def test_malformed_public_values_are_rejected(snapshot_catalog: SchemaCatalog) -> None:
    """Use catalog fixture to reject wrong public value types; return None."""
    with pytest.raises(ServiceRequestError):
        resolve_feature_ids(cast("DiscoverySnapshot", object()))
    with pytest.raises(ServiceRequestError):
        resolve_feature_ids(
            generation_snapshot(snapshot_catalog), repository_id=cast("str", 3)
        )
    with pytest.raises(ServiceRequestError):
        select_acceptance_platforms(cast("AcceptanceGeneration", object()))


def test_selector_work_is_reserved_before_index_construction(
    snapshot_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Use typed fixtures to count index calls under exhausted work; return None."""
    snapshot = generation_snapshot(snapshot_catalog)
    budget = ReportBudget(ParseLimits())
    budget.work(budget.work_left - 8)
    calls: list[str] = []

    def prepaid(snapshot: DiscoverySnapshot) -> ReportBudget:
        """Return the exhausted local budget for snapshot, with no I/O."""
        return budget

    def forbidden(snapshot: DiscoverySnapshot) -> None:
        """Record forbidden index traversal for snapshot and raise AssertionError."""
        calls.append("index")
        raise AssertionError("Capacity must reject before index traversal")

    monkeypatch.setattr(service_selection, "generation_preflight", prepaid)
    monkeypatch.setattr(service_selection, "index_references", forbidden)
    with pytest.raises(ReportLimitError):
        resolve_feature_ids(snapshot, feature_ids=("feature-alpha",))
    assert calls == []
    assert budget.work_left == 0


def test_platform_projection_reuses_candidates_and_exact_ready_membership() -> None:
    """Assert structural projection invariants; return None without semantic proof."""
    ready = specification(key=identity(criterion_id="ready"))
    withheld = specification(key=identity(criterion_id="withheld"))
    pending = specification(key=identity(criterion_id="pending"), readiness="pending")
    foreign = specification(key=identity(platform_id="native", criterion_id="native"))
    warning = Finding(
        code="SOURCE_WARNING",
        severity="warning",
        message="Retained.",
        next_action="Inspect.",
    )
    original = generation(
        (ready, withheld, pending, foreign), (ready, foreign), (warning,)
    )
    result = select_acceptance_platforms(original, platform_ids=("web",))
    assert result.ready == (ready,)
    assert result.findings == original.findings
    assert result.limits is original.limits
    assert len(result.specifications) == 3
    # Identity checks establish that tags, original refs and pinned owners were reused.
    for item in result.specifications:
        assert any(item is source for source in original.specifications)
        assert item.identity.platform_id == "web"
    assert select_acceptance_platforms(original) is original
    # Selection must leave original ready membership intact.
    assert original.ready == tuple(
        item for item in original.specifications if item in (ready, foreign)
    )


@pytest.mark.parametrize("blocked", [False, True])
def test_unknown_platform_preserves_existing_failure_semantics(blocked: bool) -> None:
    """Vary blocked (bool); assert error or exact failed result, returning None."""
    finding = Finding(
        code="SOURCE_INVALID", message="Retained blocker.", next_action="Repair."
    )
    item = specification()
    original = generation((item,), findings=(finding,) if blocked else ())
    # Existing integrity blockers must not be relabeled as an invocation failure.
    if blocked:
        assert (
            select_acceptance_platforms(original, platform_ids=("absent",)) is original
        )
        matched = select_acceptance_platforms(original, platform_ids=("web",))
        assert matched.findings == original.findings and matched.ready == ()
    else:
        with pytest.raises(ServiceRequestError) as caught:
            select_acceptance_platforms(original, platform_ids=("absent",))
        assert caught.value.findings[0].pointer == "/inputs/platform_ids"


def test_null_platform_is_never_synthesized_as_requested_coordinate() -> None:
    """Use consistent unscoped legacy model; expect selector error without I/O."""
    item = specification(
        key=identity(kind="legacy-characterization", client_id=None, platform_id=None)
    )
    original = generation((item,), (item,))
    with pytest.raises(ServiceRequestError):
        select_acceptance_platforms(original, platform_ids=("web",))


@pytest.mark.parametrize("selectors", [[], ("",), (1,), ("web", "web")])
def test_platform_selectors_reject_invalid_types_and_duplicates(
    selectors: object,
) -> None:
    """Require typed failure for selectors (object); return None without mutation."""
    with pytest.raises(ServiceRequestError):
        select_acceptance_platforms(
            generation(), platform_ids=cast("tuple[str, ...]", selectors)
        )


@pytest.mark.parametrize("kind", ["count", "bytes", "unicode", "work"])
def test_platform_selector_limits_precede_model_reconstruction(
    monkeypatch: pytest.MonkeyPatch, kind: str
) -> None:
    """Count constructor calls under kind (str) capacity failure; return None."""
    limits = ParseLimits(artifact_records=1, document_bytes=64)
    original = generation(limits=limits)
    selectors = {
        "count": ("a", "b"),
        "bytes": ("a" * 64,),
        "unicode": ("\ud800",),
        "work": ("a" * 20,),
    }[kind]
    calls: list[str] = []
    prior = AcceptanceGeneration.__post_init__

    def counted(self: AcceptanceGeneration) -> None:
        """Count reconstruction of self and delegate; return None or ValueError."""
        calls.append("model")
        prior(self)

    monkeypatch.setattr(AcceptanceGeneration, "__post_init__", counted)
    with pytest.raises(ValueError):
        select_acceptance_platforms(original, platform_ids=selectors)
    assert calls == []


def test_public_generation_composes_with_source_and_platform_selection(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Compose actual generator and selectors with catalog; return None without I/O."""
    snapshot = generation_snapshot(snapshot_catalog)
    selected = resolve_feature_ids(snapshot, feature_ids=("feature-alpha",))
    original = generate_acceptance(
        snapshot, kind="legacy-characterization", feature_ids=selected
    )
    assert original.ready and not original.findings
    result = select_acceptance_platforms(original, platform_ids=("generic",))
    assert result.ready == original.ready
    # Public composition retains the producer's actual verified scenario objects.
    assert all(
        item is source
        for item, source in zip(result.ready, original.ready, strict=True)
    )
