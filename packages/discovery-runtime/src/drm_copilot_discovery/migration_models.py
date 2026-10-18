"""Keep explicit migration inputs and publication outcomes separate from authority."""

from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.catalog import V1_KINDS
from drm_copilot_discovery.draft_contracts import (
    draft_header,
    draft_object,
    draft_reference,
)
from drm_copilot_discovery.models import JsonObject, JsonValue, canonical_json
from drm_copilot_discovery.path_models import check_path_collisions, path_contains

if TYPE_CHECKING:
    from drm_copilot_discovery.init_flow import InitializationPlan
    from drm_copilot_discovery.init_projection import InitializationRequest
    from drm_copilot_discovery.mutation_io import MutationResult
    from drm_copilot_discovery.mutation_plan import MutationPlan

MIGRATION_EXTENSION = "drm-copilot.migration-v1"


@dataclass(frozen=True, kw_only=True)
class MigrationSource:
    """Bind one expected legacy kind to captured immutable bytes and a local path.

    Construction validates spelling only. Planning must verify these bytes against
    the configured workspace capture before interpreting or publishing anything.
    """

    path: str
    kind: str
    content: bytes

    def __post_init__(self) -> None:
        """Reject unsupported kinds, unsafe paths and mutable content without I/O."""
        check_path_collisions((self.path,))
        if self.kind not in V1_KINDS or not isinstance(
            cast("object", self.content), bytes
        ):
            raise ValueError(
                "Migration requires a supported v1 kind and immutable bytes"
            )
        if not self.path.endswith((".json", ".yaml", ".yml")):
            raise ValueError("Migration sources require a JSON or YAML extension")


@dataclass(frozen=True, kw_only=True)
class MigrationBinding:
    """Supply missing feature/environment context for one original v1 identifier.

    Feature IDs refer to feature-contract inputs in the same migration. The
    binding supplies configuration only and cannot approve an observed result.
    """

    source_id: str
    feature_ids: tuple[str, ...] = ()
    environment: JsonObject | None = None

    def __post_init__(self) -> None:
        """Detach selectors and reject ambiguous or malformed explicit context."""
        features = tuple(self.feature_ids)
        if (
            not self.source_id.strip()
            or any(
                not isinstance(cast("object", value), str) or not value.strip()
                for value in features
            )
            or len(set(features)) != len(features)
            or self.environment is not None
            and not isinstance(cast("object", self.environment), JsonObject)
        ):
            raise ValueError(
                "Migration bindings require unique feature IDs and immutable context"
            )
        object.__setattr__(self, "feature_ids", tuple(sorted(features)))


@dataclass(frozen=True, kw_only=True)
class MigrationRequest:
    """Select a new draft root, exact legacy inputs and optional missing context.

    Only the explicit 1-to-2 adapter exists. Root configuration and native I/O are
    supplied separately; this immutable value grants no write or activation rights.
    """

    initialization: InitializationRequest
    sources: tuple[MigrationSource, ...]
    bindings: tuple[MigrationBinding, ...] = ()
    from_version: int = 1
    to_version: int = 2

    def __post_init__(self) -> None:
        """Reject unknown adapters and destination/source overlap before any reads."""
        if (
            type(self.from_version) is not int
            or type(self.to_version) is not int
            or (self.from_version, self.to_version) != (1, 2)
        ):
            raise ValueError(
                "Unsupported migration; request from_version=1 and to_version=2"
            )
        sources = tuple(sorted(self.sources, key=lambda item: item.path))
        if not sources:
            raise ValueError("Migration requires at least one explicit source artifact")
        check_path_collisions(item.path for item in sources)
        destinations = tuple(
            str(path) for path in self.initialization.artifact_paths().values()
        )
        if any(
            path_contains(destination, source.path)
            or path_contains(source.path, destination)
            for source in sources
            for destination in destinations
        ):
            raise ValueError(
                "Migration destinations must not overlap original source artifacts"
            )
        bindings = tuple(sorted(self.bindings, key=lambda item: item.source_id))
        if len({item.source_id for item in bindings}) != len(bindings):
            raise ValueError("Migration binding source IDs must be unique")
        object.__setattr__(self, "sources", sources)
        object.__setattr__(self, "bindings", bindings)


@dataclass(frozen=True, kw_only=True)
class ConvertedArtifact:
    """Retain a pure draft projection and its explicit unresolved obligations."""

    source: MigrationSource
    original: JsonObject
    document: JsonObject
    questions: tuple[JsonObject, ...]


@dataclass(frozen=True, kw_only=True)
class MigrationPlan:
    """Bind reconstruction inputs, root bootstrap and exact validated artifact bytes.

    The report is an immutable projection, never a completed-publication receipt.
    Commit reconstructs the proposal; serialized user data cannot mint this value.
    """

    request: MigrationRequest
    initialization: InitializationPlan
    mutation: MutationPlan
    report: JsonObject


@dataclass(frozen=True, kw_only=True)
class MigrationResult:
    """Report actual publication separately from the immutable mapping projection.

    Failed bootstrap or mutation retains confirmed creations and uncertain paths.
    The returned report reflects this invocation's outcome; it grants no authority.
    """

    ok: bool
    report: JsonObject
    publication: MutationResult | None = None
    bootstrap_created: tuple[str, ...] = ()
    uncertain_paths: tuple[str, ...] = ()
    authority_invalidated: bool = False
    error: str | None = None


def mapping_report(
    request: MigrationRequest,
    outputs: tuple[tuple[ConvertedArtifact, str], ...],
    documents: dict[str, JsonObject],
) -> JsonObject:
    """Build a deterministic immutable mapping that asserts projection validity only."""
    manifest = tuple(
        draft_object(
            path=item.source.path,
            kind=item.source.kind,
            id=item.original["id"],
            sha256=sha256(item.source.content).hexdigest(),
        )
        for item, _ in outputs
    )
    digest = sha256(canonical_json(manifest)).hexdigest()
    fields = draft_header("migration-report", "migration-" + digest)
    questions: list[JsonObject] = []
    for item, _ in outputs:
        questions.extend(item.questions)
        if item.source.kind == "unspecified-behavior":
            questions.append(item.document)
    fields.update(
        from_version=1,
        to_version=2,
        destination=request.initialization.artifact_root,
        source_manifest_sha256=digest,
        dry_run=False,
        activation_switched=False,
        result="pass",
        mappings=tuple(
            draft_object(
                old_path=item.source.path,
                old_sha256=sha256(item.source.content).hexdigest(),
                old_id=item.original["id"],
                old_kind=item.source.kind
                + (
                    "-record"
                    if item.source.kind in {"product-decision", "unspecified-behavior"}
                    else ""
                ),
                new_path=path,
                new_sha256=sha256(canonical_json(documents[path])).hexdigest(),
                new_id=item.document["id"],
                new_kind=item.document["artifact_kind"],
                status="planned",
            )
            for item, path in outputs
        ),
        unresolved_behavior_refs=tuple(
            draft_reference("unspecified-behavior", str(item["id"]))
            for item in sorted(questions, key=lambda value: str(value["id"]))
        ),
        unmapped_metadata=tuple(
            draft_object(
                old_path=item.source.path,
                pointer="",
                value=item.original,
                reason="Original v1 semantics are retained; only explicitly projected "
                "fields participate in v2 validation.",
            )
            for item, _ in outputs
        ),
        migration_extension=MIGRATION_EXTENSION,
        findings=(),
        extensions=JsonObject(
            (
                (
                    MIGRATION_EXTENSION,
                    draft_object(
                        publication="projection-only",
                        validation="structural-draft-only",
                        next_action="Resolve linked questions and approve target "
                        "decisions before completion.",
                    ),
                ),
            )
        ),
    )
    return JsonObject(tuple(fields.items()))


def publication_report(
    plan: MigrationPlan,
    *,
    ok: bool,
    dry_run: bool,
    statuses: dict[str, str],
    error: str | None,
) -> JsonObject:
    """Return actual dispositions without rewriting the immutable projection."""
    fields = dict(plan.report)
    mappings: list[JsonObject] = []
    for original in cast("tuple[JsonObject, ...]", plan.report["mappings"]):
        mapping = dict(original)
        mapping["status"] = statuses.get(str(original["new_path"]), "planned")
        mappings.append(JsonObject(tuple(mapping.items())))
    findings: tuple[JsonValue, ...] = ()
    if error is not None:
        findings = (
            draft_object(
                code="MIGRATION_FAILED",
                severity="error",
                artifact_path=None,
                pointer="",
                related_ids=(),
                related_paths=(),
                message=error,
                next_action="Inspect partial and uncertain paths, reload originals, "
                "and retry without overwriting conflicts.",
            ),
        )
    fields.update(
        dry_run=dry_run,
        result="pass" if ok else "fail",
        mappings=tuple(mappings),
        findings=findings,
        extensions=JsonObject(
            (
                (
                    MIGRATION_EXTENSION,
                    draft_object(
                        publication="dry-run" if dry_run else "actual-outcome",
                        validation="structural-draft-only",
                    ),
                ),
            )
        ),
    )
    return JsonObject(tuple(fields.items()))
