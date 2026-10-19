"""Preserve legacy uncertainty and reject unsupported migration context in memory."""

from __future__ import annotations

import json
from dataclasses import replace
from hashlib import sha256
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import migration_conversion, migration_v1
from drm_copilot_discovery.catalog import V1_KINDS
from drm_copilot_discovery.migration_conversion import convert_artifact, legacy_features
from drm_copilot_discovery.migration_models import (
    MIGRATION_EXTENSION,
    ConvertedArtifact,
    MigrationBinding,
    MigrationPlan,
    MigrationSource,
)
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.mutation_plan import MutationError
from drm_copilot_discovery.profile_v2 import parse_profile_v2
from drm_copilot_discovery.schema_validation import validate_document

from tests.discovery_runtime.initialization_test_support import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.initialization_test_support import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.mutation_test_support import constant
from tests.discovery_runtime.test_migration_v1 import (
    ENVIRONMENT,
    migration_request,
    project_sources,
    source_for,
    unit_commit_case,
)
from tests.discovery_runtime.test_migration_v1 import migration_plan as migration_plan
from tests.discovery_runtime.test_references import immutable

if TYPE_CHECKING:
    from _pytest.monkeypatch import MonkeyPatch


def converted(plan: MigrationPlan, kind: str, **changes: object) -> ConvertedArtifact:
    """Return ConvertedArtifact using MigrationPlan, str kind and object changes.
    Read committed fixtures and transform detached values; no writes occur.
    """
    source = source_for(kind, **changes)
    document = immutable(cast("dict[str, object]", json.loads(source.content)))
    # Select only the matching projected singleton template, if this kind uses one.
    template = next(
        (
            item.document
            for item in plan.mutation.prospective.artifacts
            if item.expected_kind == kind
        ),
        None,
    )
    return convert_artifact(
        plan.mutation.baseline,
        source,
        document,
        binding=MigrationBinding(
            source_id=str(document["id"]),
            feature_ids=("feature-alpha",),
            environment=ENVIRONMENT,
        ),
        feature_ids={"feature-alpha": "feature-alpha"},
        template=template,
    )


@pytest.mark.parametrize("kind", V1_KINDS)
def test_every_original_field_remains_untrusted_metadata(
    migration_plan: MigrationPlan,
    kind: str,
) -> None:
    """Check MigrationPlan fixture and str kind preserve metadata; return None."""
    result = converted(migration_plan, kind)
    extension = cast("JsonObject", result.document["extensions"])[MIGRATION_EXTENSION]
    metadata = cast("JsonObject", extension)
    assert metadata["original_document"] == result.original
    assert metadata["source_sha256"] == sha256(result.source.content).hexdigest()
    assert metadata["source_path"] == result.source.path
    assert metadata["disposition"] == "draft-reconciliation-required"
    assert result.questions or kind == "unspecified-behavior"
    # Every projected obligation must retain an unresolved lifecycle.
    assert all(item["status"] == "open" for item in result.questions)


@pytest.mark.parametrize(
    "kind,fields",
    [
        (
            "feature-contract",
            {
                "lifecycle": "draft",
                "confidence": "unknown",
                "observation_state": "unknown",
                "acceptance_criteria": (),
            },
        ),
        (
            "runtime-characterization-scenario",
            {
                "result_status": "not-run",
                "expected_result": None,
                "expected_result_basis": "unknown",
                "runs": (),
            },
        ),
        (
            "product-decision",
            {
                "status": "proposed",
                "approval": None,
                "resulting_acceptance_criteria": (),
            },
        ),
        (
            "unspecified-behavior",
            {"status": "open", "decision_ref": None, "approved_target_behavior": None},
        ),
        ("coverage-ledger", {"revision": None, "components": ()}),
        (
            "parity-matrix",
            {"entries": (), "source_repositories": (), "target_repositories": ()},
        ),
        (
            "evidence-reference",
            {
                "evidence_type": "documentation",
                "revision": None,
                "confidence": "unknown",
                "runtime_artifact": None,
            },
        ),
    ],
)
def test_legacy_claims_do_not_become_verified_target_state(
    migration_plan: MigrationPlan,
    kind: str,
    fields: dict[str, object],
) -> None:
    """Check MigrationPlan/str kind/dict fields retain draft state; return None."""
    result = converted(migration_plan, kind)
    # Compare each kind's selected authority-bearing fields, not incidental metadata.
    assert {key: result.document[key] for key in fields} == fields
    if kind == "evidence-reference":
        assert result.document["path"] == result.source.path
        checksum = cast("JsonObject", result.document["checksum"])
        assert checksum["value"] == sha256(result.source.content).hexdigest()


@pytest.mark.parametrize(
    "kind,selector,environment",
    [
        ("product-decision", (), None),
        ("evidence-reference", (), None),
        ("runtime-characterization-scenario", ("feature-alpha",), None),
        ("runtime-characterization-scenario", ("missing",), ENVIRONMENT),
    ],
)
def test_missing_context_is_actionable_and_never_fabricated(
    migration_plan: MigrationPlan,
    kind: str,
    selector: tuple[str, ...],
    environment: JsonObject | None,
) -> None:
    """Use MigrationPlan, str kind, tuple selector and optional JsonObject context.
    Return None after required-context rejection; no external state changes.
    """
    source = source_for(kind)
    document = immutable(cast("dict[str, object]", json.loads(source.content)))
    with pytest.raises(MutationError, match="MIGRATION_REQUIRED_CONTEXT: Supply"):
        convert_artifact(
            migration_plan.mutation.baseline,
            source,
            document,
            binding=MigrationBinding(
                source_id=str(document["id"]),
                feature_ids=selector,
                environment=environment,
            ),
            feature_ids={"feature-alpha": "feature-alpha"},
        )


def test_explicit_binding_and_empty_preconditions_stay_observation_plans(
    migration_plan: MigrationPlan,
) -> None:
    """Check MigrationPlan fixture keeps caller context unverified; return None."""
    result = converted(
        migration_plan,
        "runtime-characterization-scenario",
        feature_id="unresolved-original",
        preconditions=[],
    )
    assert result.document["expected_result"] is None
    assert result.original["feature_id"] == "unresolved-original"
    assert result.document["preconditions"] == (
        "Determine legacy preconditions before execution.",
    )


@pytest.mark.parametrize(
    "kind,fields",
    [
        ("feature-contract", {"title": ""}),
        ("feature-contract", {"description": ""}),
        ("product-decision", {"decision": ""}),
        ("product-decision", {"rationale": ""}),
        ("unspecified-behavior", {"description": ""}),
        ("runtime-characterization-scenario", {"stimulus": {"description": ""}}),
        ("runtime-characterization-scenario", {"preconditions": [""]}),
    ],
)
def test_empty_v1_mechanical_fields_cannot_invent_replacement_text(
    migration_plan: MigrationPlan,
    kind: str,
    fields: dict[str, object],
) -> None:
    """Check MigrationPlan/str kind/dict fields reject empty semantics; return None."""
    source = source_for(kind, **fields)
    catalog = migration_plan.mutation.baseline.snapshot.catalog
    legacy = validate_document(
        source.content, expected_kind=kind, expected_version="1.0.0", catalog=catalog
    )
    assert legacy.ok, legacy.findings
    # Names fail in the draft builder; other empty v1 fields fail v2 validation.
    if fields == {"title": ""}:
        with pytest.raises(ValueError, match="contract draft requires a name"):
            converted(migration_plan, kind, **fields)
        return
    result = converted(migration_plan, kind, **fields)
    check = validate_document(
        canonical_json(result.document),
        expected_kind=kind,
        expected_version="2.0.0",
        catalog=catalog,
    )
    assert not check.ok and check.findings
    assert (
        cast(
            "JsonObject",
            cast("JsonObject", result.document["extensions"])[MIGRATION_EXTENSION],
        )["original_document"]
        == legacy.document
    )


@pytest.mark.parametrize(
    "path",
    [
        "../old.json",
        "C:/old.json",
        "old\\a.json",
        "old/CON.json",
        "old/a.txt",
        "old/a.json:stream",
    ],
)
def test_source_paths_reject_escape_and_nonportable_spellings(path: str) -> None:
    """Check str path violates the portable boundary without I/O; return None."""
    with pytest.raises(ValueError):
        MigrationSource(path=path, kind="feature-contract", content=b"{}")


@pytest.mark.parametrize(
    "kind,content", [("unknown", b"{}"), ("feature-contract", bytearray(b"{}"))]
)
def test_source_requires_known_kind_and_immutable_bytes(
    kind: str, content: object
) -> None:
    """Check str kind/object content fail before capture or writes; return None."""
    with pytest.raises(ValueError, match="supported v1 kind and immutable bytes"):
        MigrationSource(path="old/a.json", kind=kind, content=cast("bytes", content))


@pytest.mark.parametrize(
    "features,environment",
    [
        (("a", "a"), None),
        (("",), None),
        ((3,), None),
        (("a",), {}),
    ],
)
def test_bindings_reject_ambiguous_or_mutable_context(
    features: tuple[object, ...],
    environment: object,
) -> None:
    """Check tuple[object, ...] features/object environment rejection; return None."""
    with pytest.raises(ValueError, match="unique feature IDs and immutable context"):
        MigrationBinding(
            source_id="record",
            feature_ids=cast("tuple[str, ...]", features),
            environment=cast("JsonObject | None", environment),
        )
    with pytest.raises(ValueError, match="unique feature IDs"):
        MigrationBinding(source_id=" ")


@pytest.mark.parametrize(
    "from_version,to_version", [(0, 2), (1, 3), (True, 2), (1, True)]
)
def test_only_explicit_supported_version_pair_is_accepted(
    from_version: int,
    to_version: int,
) -> None:
    """Check int from_version/to_version reject unknown or bool pairs; return None."""
    with pytest.raises(ValueError, match="Unsupported migration"):
        replace(migration_request(), from_version=from_version, to_version=to_version)


@pytest.mark.parametrize(
    "case",
    ["empty", "case-collision", "root-overlap", "custom-overlap", "duplicate-binding"],
)
def test_request_rejects_ambiguous_selection_and_overlapping_destinations(
    case: str,
) -> None:
    """Check str case rejects ambiguous inputs and unsafe outputs; return None."""
    request = migration_request(source_for("feature-contract"))
    source = request.sources[0]
    with pytest.raises(ValueError):
        # Route selection, spelling, root/override overlap and duplicate-context cases.
        if case == "empty":
            replace(request, sources=())
        elif case == "case-collision":
            replace(
                request,
                sources=(
                    source,
                    replace(source, path=source.path.replace("legacy", "LEGACY")),
                ),
            )
        elif case == "root-overlap":
            replace(
                request,
                initialization=replace(request.initialization, artifact_root="legacy"),
            )
        elif case == "custom-overlap":
            replace(
                request,
                initialization=replace(
                    request.initialization, artifact_overrides=(("evidence", "legacy"),)
                ),
            )
        else:
            replace(request, bindings=request.bindings + request.bindings)


def test_declared_legacy_feature_selection_is_sorted_without_inference() -> None:
    """Check local declared IDs exclude prose inference; return None without I/O."""
    value = immutable(
        {
            "feature_ids": ["b", "a"],
            "feature_id": "a",
            "entries": [{"feature_id": "c"}],
            "description": "feature-d",
        }
    )
    assert legacy_features(value) == ("a", "b", "c")


def test_missing_collection_template_and_malformed_builder_fail_closed(
    monkeypatch: MonkeyPatch,
    migration_plan: MigrationPlan,
) -> None:
    """Use MonkeyPatch/MigrationPlan fixtures for malformed builders; return None.
    Scoped in-memory substitutions must fail without publishing partial drafts.
    """
    source = source_for("coverage-ledger")
    document = immutable(cast("dict[str, object]", json.loads(source.content)))
    with pytest.raises(MutationError, match="MIGRATION_TEMPLATE"):
        convert_artifact(
            migration_plan.mutation.baseline,
            source,
            document,
            binding=MigrationBinding(
                source_id=str(document["id"]), feature_ids=("feature-alpha",)
            ),
            feature_ids={"feature-alpha": "feature-alpha"},
        )
    write = migration_plan.mutation.writes[0].change
    malformed = replace(write, content=b"{")
    monkeypatch.setattr(
        migration_conversion, "contract_changes", constant((malformed, malformed))
    )
    with pytest.raises(MutationError, match="MIGRATION_DRAFT"):
        converted(migration_plan, "feature-contract")


@pytest.mark.parametrize("kind", ["coverage-ledger", "parity-matrix"])
def test_multiple_singleton_sources_require_separate_roots(
    monkeypatch: MonkeyPatch,
    migration_plan: MigrationPlan,
    kind: str,
) -> None:
    """Use MonkeyPatch/MigrationPlan fixtures and str kind; return None.
    Isolated collection collisions must not replace a configured singleton.
    """
    sources = (
        source_for("feature-contract"),
        source_for(kind),
        replace(source_for(kind, id="another"), path="legacy/another.json"),
    )
    with pytest.raises(MutationError, match="MIGRATION_COLLISION"):
        project_sources(
            monkeypatch, migration_plan, migration_request(*sources), sources
        )


@pytest.mark.parametrize("overlap", [False, True])
def test_effective_profile_limits_and_output_roots_are_rechecked(
    monkeypatch: MonkeyPatch,
    migration_plan: MigrationPlan,
    overlap: bool,
) -> None:
    """Use MonkeyPatch/MigrationPlan fixtures and bool overlap; return None.
    Scoped memory profiles test effective limits and original-preservation guards.
    """
    baseline = migration_plan.mutation.baseline
    data = dict(baseline.snapshot.profile.document)
    # One profile variation targets path containment, the other the source bound.
    section = "artifacts" if overlap else "limits"
    settings = dict(cast("JsonObject", data.get(section, JsonObject(()))))
    settings.update(
        {"feature_contracts": "legacy"} if overlap else {"artifact_records": 1}
    )
    data[section] = JsonObject(tuple(settings.items()))
    profile = parse_profile_v2(
        canonical_json(JsonObject(tuple(data.items()))),
        catalog=baseline.snapshot.catalog,
    )
    plan = replace(
        migration_plan,
        mutation=replace(
            migration_plan.mutation,
            baseline=replace(
                baseline, snapshot=replace(baseline.snapshot, profile=profile)
            ),
        ),
    )
    sources = (
        (replace(source_for("feature-contract"), path="legacy/feature-alpha.json"),)
        if overlap
        else migration_plan.request.sources
    )
    with pytest.raises(
        MutationError, match="MIGRATION_COLLISION" if overlap else "MIGRATION_LIMIT"
    ):
        project_sources(monkeypatch, plan, migration_request(*sources), sources)


def test_dry_run_never_bootstraps_or_revokes(
    monkeypatch: MonkeyPatch, migration_plan: MigrationPlan
) -> None:
    """Use MonkeyPatch/MigrationPlan fixtures to prohibit dry-run I/O; return None."""
    case = unit_commit_case(monkeypatch, migration_plan)

    def forbidden(*args: object, **kwargs: object) -> None:
        """Reject any object arguments via pytest failure; never return None."""
        pytest.fail("dry-run bootstrap")

    monkeypatch.setattr(case.io, "bootstrap", forbidden)
    result = migration_v1.commit_migration(migration_plan, io=case.io, dry_run=True)
    assert result.ok and result.report["dry_run"] is True
    assert not case.disk.store.files and case.revocations == 0
    # Dry-run must leave every prospective publication as an unexecuted plan.
    assert all(
        item["status"] == "planned"
        for item in cast("tuple[JsonObject, ...]", result.report["mappings"])
    )
