"""Migrate captured v1 records through root bootstrap and validated exact writes.

The persisted mapping describes a projection only. Actual publication outcomes
are returned separately, including partial failures. No activation is switched.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.init_flow import plan_initialization
from drm_copilot_discovery.migration_conversion import convert_artifact, migrated_id
from drm_copilot_discovery.migration_models import (
    ConvertedArtifact,
    MigrationBinding,
    MigrationPlan,
    MigrationRequest,
    MigrationResult,
    mapping_report,
    publication_report,
)
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.mutation_io import GuardedMutationWriter, commit_mutation
from drm_copilot_discovery.mutation_plan import (
    MutationChange,
    MutationError,
    plan_mutation,
)
from drm_copilot_discovery.parsing import parse_document
from drm_copilot_discovery.path_models import WriteGrant, path_contains
from drm_copilot_discovery.schema_validation import validate_document

if TYPE_CHECKING:
    from drm_copilot_discovery.init_io import InitializationIO
    from drm_copilot_discovery.init_projection import InitializationTemplates
    from drm_copilot_discovery.migration_models import MigrationSource
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.profile_models import ArtifactKey

_LOCATIONS: dict[str, ArtifactKey] = {
    "feature-contract": "feature_contracts",
    "evidence-reference": "evidence",
    "runtime-characterization-scenario": "characterization",
    "coverage-ledger": "coverage_ledger",
    "parity-matrix": "parity_matrix",
    "product-decision": "product_decisions",
    "unspecified-behavior": "unspecified_behaviors",
}


def _sources(
    request: MigrationRequest, baseline: CapturedWorkspace
) -> tuple[tuple[MigrationSource, JsonObject], ...]:
    """Require captured bytes and unique old/new identities before conversion."""
    if len(request.sources) > baseline.snapshot.profile.limits.artifact_records:
        raise MutationError("MIGRATION_LIMIT", "Reduce the number of migration inputs")
    files = {item.path: item for item in baseline.snapshot.manifest.files}
    originals: list[tuple[MigrationSource, JsonObject]] = []
    identities: set[str] = set()
    translated: set[str] = set()
    for source in request.sources:
        captured = files.get(source.path)
        if captured is None or captured.content != source.content:
            raise MutationError(
                "MIGRATION_SOURCE",
                "Capture exact original bytes under configured readable roots: "
                + source.path,
            )
        result = validate_document(
            source.content,
            expected_kind=source.kind,
            expected_version="1.0.0",
            format="json" if source.path.endswith(".json") else "yaml",
            artifact_path=source.path,
            catalog=baseline.snapshot.catalog,
            limits=baseline.snapshot.profile.limits.parse_limits(),
        )
        if not result.ok or result.document is None:
            raise MutationError(
                "MIGRATION_INPUT",
                "Correct the invalid v1 source artifact",
                findings=result.findings,
            )
        identifier = cast("str", result.document["id"])
        mapped = migrated_id(identifier)
        if identifier in identities or mapped in translated:
            raise MutationError(
                "MIGRATION_ID",
                "Source IDs and mapped IDs must be unique across artifact kinds",
            )
        identities.add(identifier)
        translated.add(mapped)
        originals.append((source, result.document))
    if any(binding.source_id not in identities for binding in request.bindings):
        raise MutationError(
            "MIGRATION_BINDING", "Every binding must name an original source ID"
        )
    return tuple(originals)


def _document(content: bytes) -> JsonObject:
    """Decode already validated initialization output without new resource reads."""
    parsed = parse_document(content, format="json")
    if parsed.value is None:
        raise MutationError(
            "MIGRATION_TEMPLATE", "Initialization returned malformed template bytes"
        )
    return parsed.value


def _append(document: JsonObject, records: tuple[JsonObject, ...]) -> JsonObject:
    """Merge exact collection members, rejecting identity reuse with different bytes."""
    combined = {
        str(item["id"]): item
        for item in cast("tuple[JsonObject, ...]", document["records"])
    }
    for item in records:
        identifier = str(item["id"])
        if identifier in combined and combined[identifier] != item:
            raise MutationError(
                "MIGRATION_COLLISION", f"Conflicting destination record: {identifier}"
            )
        combined[identifier] = item
    fields = dict(document)
    fields["records"] = tuple(combined[name] for name in sorted(combined))
    return JsonObject(tuple(fields.items()))


def _project(
    request: MigrationRequest,
    baseline: CapturedWorkspace,
    documents: dict[str, JsonObject],
) -> tuple[tuple[ConvertedArtifact, str], ...]:
    """Project validated inputs while preserving unrelated existing root content."""
    originals = _sources(request, baseline)
    features = {
        str(value["id"]): migrated_id(str(value["id"]))
        for source, value in originals
        if source.kind == "feature-contract"
    }
    bindings = {item.source_id: item for item in request.bindings}
    profile = baseline.snapshot.profile
    outputs: list[tuple[ConvertedArtifact, str]] = []
    singleton_kinds: set[str] = set()
    questions: list[JsonObject] = []
    for source, original in originals:
        kind = source.kind
        location = profile.artifacts[_LOCATIONS[kind]]
        if kind in {"coverage-ledger", "parity-matrix"}:
            if kind in singleton_kinds:
                raise MutationError(
                    "MIGRATION_COLLISION",
                    "Migrate at most one ledger and parity matrix per root",
                )
            singleton_kinds.add(kind)
        converted = convert_artifact(
            baseline,
            source,
            original,
            binding=bindings.get(
                str(original["id"]), MigrationBinding(source_id=str(original["id"]))
            ),
            feature_ids=features,
            template=documents.get(location),
        )
        questions.extend(converted.questions)
        if kind in {"product-decision", "unspecified-behavior"}:
            documents[location] = _append(documents[location], (converted.document,))
        else:
            if kind in {
                "feature-contract",
                "runtime-characterization-scenario",
                "evidence-reference",
            }:
                location += "/" + str(converted.document["id"]) + ".json"
            documents[location] = converted.document
        outputs.append((converted, location))
    unresolved = profile.artifacts["unspecified_behaviors"]
    documents[unresolved] = _append(documents[unresolved], tuple(questions))
    return tuple(outputs)


def plan_migration(
    request: MigrationRequest,
    *,
    io: InitializationIO,
    templates: InitializationTemplates | None = None,
) -> MigrationPlan:
    """Validate captured originals and the complete new draft graph before any writes.

    Root-owned I/O must be authenticated by the host. Invalid inputs, missing
    context, unsafe paths or incompatible destinations raise ValueError/OSError.
    Existing exact bytes are reusable; different destination bytes are conflicts.
    """
    initialization = plan_initialization(
        request.initialization, io=io, templates=templates
    )
    baseline = initialization.capture.proposal_base
    documents = {
        write.change.path: _document(write.change.content)
        for write in initialization.mutation.writes
    }
    outputs = _project(request, baseline, documents)
    report = mapping_report(request, outputs, documents)
    report_path = (
        baseline.snapshot.profile.artifacts["reports"] + "/migration-report.json"
    )
    documents[report_path] = report
    files = {item.path: item for item in baseline.snapshot.manifest.files}
    changes: list[MutationChange] = []
    for path, document in sorted(documents.items()):
        if any(
            path_contains(path, source.path) or path_contains(source.path, path)
            for source in request.sources
        ):
            raise MutationError(
                "MIGRATION_COLLISION", "Output overlaps an original source artifact"
            )
        content = canonical_json(document)
        prior = files.get(path)
        if prior is not None and prior.content != content:
            raise MutationError(
                "MIGRATION_COLLISION",
                f"Choose a new destination; existing bytes differ: {path}",
            )
        changes.append(
            MutationChange(
                artifact_kind=str(document["artifact_kind"]),
                artifact_id=str(document["id"]),
                path=path,
                content=content,
                expected_sha256=prior.sha256 if prior else None,
            )
        )
    mutation = plan_mutation(
        baseline,
        tuple(changes),
        grants=tuple(
            WriteGrant(
                artifact_kind=item.artifact_kind,
                artifact_id=item.artifact_id,
                path=item.path,
            )
            for item in changes
        ),
    )
    return MigrationPlan(
        request=request, initialization=initialization, mutation=mutation, report=report
    )


def commit_migration(
    plan: MigrationPlan, *, io: InitializationIO, dry_run: bool = False
) -> MigrationResult:
    """Reconstruct, bootstrap and publish through the accepted mutation boundary.

    Dry-run does not write directories, artifacts, activation or authority. Real
    failures retain exact partial outcomes; originals are never output targets.
    An immutable projection report on disk cannot claim completed publication.
    """
    created: tuple[str, ...] = ()
    uncertain: tuple[str, ...] = ()
    revoked = False
    try:
        rebuilt = plan_migration(
            plan.request, io=io, templates=plan.initialization.templates
        )
        plan.initialization.capture.require_same(rebuilt.initialization.capture)
        if rebuilt != plan:
            raise MutationError(
                "MIGRATION_PLAN", "Plan differs from its validated reconstruction"
            )
        if dry_run:
            statuses = {
                write.change.path: "skipped" if write.skipped else "planned"
                for write in plan.mutation.writes
            }
            return MigrationResult(
                ok=True,
                report=publication_report(
                    plan, ok=True, dry_run=True, statuses=statuses, error=None
                ),
            )
        bootstrap = io.bootstrap(
            plan.initialization.capture,
            profile_bytes=plan.initialization.profile_bytes,
            directories=plan.initialization.directories,
        )
        created, uncertain, revoked = (
            bootstrap.created,
            bootstrap.uncertain,
            bootstrap.authority_invalidated,
        )
        if not bootstrap.ok:
            raise OSError(bootstrap.error or "Migration bootstrap failed")
        profile_path = plan.mutation.baseline.snapshot.profile.artifacts["profile"]
        physical = io.physical_capture(profile_path)
        if (
            physical != bootstrap.physical
            or physical.snapshot.sha256 != plan.mutation.baseline.snapshot.sha256
        ):
            raise OSError(
                "Physical bootstrap inputs differ from the validated migration"
            )
        current = plan_mutation(
            physical,
            tuple(write.change for write in plan.mutation.writes),
            grants=plan.mutation.grants,
        )
        if current.prospective.sha256 != plan.mutation.prospective.sha256:
            raise OSError(
                "Physical migration graph differs from the validated projection"
            )
        result = commit_mutation(
            current,
            writer=GuardedMutationWriter(
                capture=lambda: io.physical_capture(profile_path),
                invalidate_authority=io.invalidate_authority,
                primitives=io.primitives,
            ),
        )
        error = "; ".join(item.message for item in result.findings) or None
        return MigrationResult(
            ok=result.ok,
            report=publication_report(
                plan,
                ok=result.ok,
                dry_run=False,
                statuses={item.path: item.status for item in result.artifacts},
                error=error,
            ),
            publication=result,
            bootstrap_created=created,
            uncertain_paths=result.uncertain_paths,
            authority_invalidated=revoked or result.authority_invalidated,
            error=error,
        )
    except (OSError, ValueError) as error:
        if not dry_run and not revoked:
            try:
                io.invalidate_authority()
                revoked = True
            except OSError as invalidation_error:
                error = OSError(
                    f"{error}; authority invalidation failed: {invalidation_error}"
                )
        return MigrationResult(
            ok=False,
            report=publication_report(
                plan, ok=False, dry_run=dry_run, statuses={}, error=str(error)
            ),
            bootstrap_created=created,
            uncertain_paths=uncertain,
            authority_invalidated=revoked,
            error=str(error),
        )
