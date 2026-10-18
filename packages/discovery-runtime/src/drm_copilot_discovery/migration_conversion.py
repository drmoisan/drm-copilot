"""Project validated legacy records into honest drafts without I/O or approvals."""

from __future__ import annotations

import re
from hashlib import sha256
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.draft_contracts import (
    ContractDraft,
    contract_changes,
    draft_header,
    draft_object,
    draft_reference,
    open_question,
)
from drm_copilot_discovery.draft_scenarios import ScenarioDraft, scenario_changes
from drm_copilot_discovery.migration_models import (
    MIGRATION_EXTENSION,
    ConvertedArtifact,
    MigrationBinding,
)
from drm_copilot_discovery.models import JsonObject, JsonValue
from drm_copilot_discovery.mutation_plan import MutationError
from drm_copilot_discovery.parsing import parse_document

if TYPE_CHECKING:
    from collections.abc import Mapping

    from drm_copilot_discovery.migration_models import MigrationSource
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationChange


def migrated_id(identifier: str) -> str:
    """Preserve v2-compatible legacy IDs, otherwise derive a stable explicit mapping."""
    if re.fullmatch(r"[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*", identifier):
        return identifier
    return "migrated-" + sha256(identifier.encode("utf-8")).hexdigest()


def legacy_features(document: JsonObject) -> tuple[str, ...]:
    """Collect declared v1 feature selectors without interpreting behavior prose."""
    selected = list(cast("tuple[str, ...]", document.get("feature_ids", ())))
    if isinstance(document.get("feature_id"), str):
        selected.append(cast("str", document["feature_id"]))
    # Coverage and parity embed declarations; neither implies a verified claim.
    for row in cast(
        "tuple[JsonObject, ...]", document.get("entries", document.get("rows", ()))
    ):
        selected.extend(legacy_features(row))
    return tuple(sorted(set(selected)))


def _parsed(change: MutationChange) -> JsonObject:
    """Read accepted draft-builder bytes without loading schemas or external state."""
    value = parse_document(change.content, format="json").value
    if value is None:
        raise MutationError("MIGRATION_DRAFT", "Draft builder returned invalid JSON")
    return value


def _draft_changes(
    changes: tuple[MutationChange, ...],
) -> tuple[JsonObject, tuple[JsonObject, ...]]:
    """Separate a new artifact from its builder-created unresolved collection."""
    records = cast("tuple[JsonObject, ...]", _parsed(changes[1])["records"])
    return _parsed(changes[0]), records[-1:]


def _scenario(
    baseline: CapturedWorkspace,
    document: JsonObject,
    identifier: str,
    features: tuple[str, ...],
    binding: MigrationBinding,
) -> tuple[JsonObject, tuple[JsonObject, ...]]:
    """Retain stimulus and require an explicitly selected environment."""
    if binding.environment is None:
        raise MutationError(
            "MIGRATION_REQUIRED_CONTEXT", f"Supply environment for {document['id']}"
        )
    stimulus = cast("JsonObject", document["stimulus"])
    inputs = cast("JsonObject", stimulus.get("inputs", JsonObject(())))
    fields = draft_object(
        environment=binding.environment,
        fixture=draft_object(
            description="Determine the legacy fixture before executing this draft.",
            setup_steps=(),
            teardown_steps=(),
            evidence_refs=(),
        ),
        preconditions=document["preconditions"]
        or ("Determine legacy preconditions before execution.",),
        action=draft_object(
            description=stimulus["description"],
            inputs=tuple(
                draft_object(name=name, value=value)
                for name, value in sorted(inputs.items())
            ),
        ),
        observation_plan=(
            draft_object(
                id="observe-" + identifier,
                dimension="observable_outputs",
                description="Capture pre-state, apply the legacy stimulus, "
                "and record post-state and outputs.",
            ),
        ),
    )
    return _draft_changes(
        scenario_changes(
            baseline,
            ScenarioDraft(scenario_id=identifier, feature_ids=features, fields=fields),
        )
    )


def _decision(
    document: JsonObject,
    identifier: str,
    features: tuple[str, ...],
    question: JsonObject,
) -> JsonObject:
    """Preserve proposed text but require a new explicit target approval and scope."""
    fields = draft_header("product-decision", identifier)
    fields.update(
        decision_id=identifier,
        feature_refs=tuple(
            draft_reference("feature-contract", value) for value in features
        ),
        unspecified_behavior_refs=(
            draft_reference("unspecified-behavior", cast("str", question["id"])),
        ),
        decision_key=identifier,
        scope=draft_object(
            feature_ids=features, client_ids=(), platforms=(), modes=(), dimensions=()
        ),
        status="proposed",
        decision=document["decision"],
        rationale=document["rationale"],
        alternatives=(),
        affected_platforms=(),
        required_migration_behavior=None,
        approval=None,
        resulting_acceptance_criteria=(),
        supersedes=(),
    )
    return JsonObject(tuple(fields.items()))


def _evidence(
    source: MigrationSource, document: JsonObject, identifier: str, repository: str
) -> JsonObject:
    """Prove legacy record bytes without verifying its claimed payload."""
    fields = draft_header("evidence-reference", identifier)
    fields.update(
        evidence_id=identifier,
        evidence_type="documentation",
        repository=repository,
        revision=None,
        path=source.path,
        runtime_artifact=None,
        timestamp=document["captured_at"],
        environment=None,
        checksum=draft_object(
            algorithm="sha256", value=sha256(source.content).hexdigest()
        ),
        author_or_agent=draft_object(kind="tool", id="legacy-artifact-migration"),
        confidence="unknown",
        notes="This reference proves only the original v1 record bytes. Its claimed "
        "payload and provenance remain unverified migration metadata.",
    )
    return JsonObject(tuple(fields.items()))


def convert_artifact(
    baseline: CapturedWorkspace,
    source: MigrationSource,
    document: JsonObject,
    *,
    binding: MigrationBinding,
    feature_ids: Mapping[str, str],
    template: JsonObject | None = None,
) -> ConvertedArtifact:
    """Convert a validated v1 record using explicit context and accepted draft builders.

    Missing feature/environment context raises MutationError. The caller validates
    the complete projected graph. Original values remain namespaced and cannot
    supply verified observations, approval, coverage or parity. No I/O occurs.
    """
    old_id = cast("str", document["id"])
    identifier = migrated_id(old_id)
    selected = (
        (old_id,)
        if source.kind == "feature-contract"
        else binding.feature_ids or legacy_features(document)
    )
    if not selected or any(value not in feature_ids for value in selected):
        raise MutationError(
            "MIGRATION_REQUIRED_CONTEXT",
            f"Supply feature_ids for {old_id} referencing feature-contract "
            "inputs in this migration",
        )
    features = tuple(sorted(feature_ids[value] for value in selected))
    question = open_question(
        "unknown-migration-" + identifier,
        features=features,
        dimensions=(),
        question="Reconcile missing behavior dimensions, revisions, evidence, "
        f"environment, approvals and expectations retained from v1 record {old_id}.",
    )
    questions = (question,)
    if source.kind == "feature-contract":
        converted, questions = _draft_changes(
            contract_changes(
                baseline,
                ContractDraft(
                    feature_id=identifier,
                    name=cast("str", document["title"]),
                    fields=draft_object(summary=document["description"]),
                ),
            )
        )
    elif source.kind == "runtime-characterization-scenario":
        converted, questions = _scenario(
            baseline, document, identifier, features, binding
        )
    elif source.kind == "product-decision":
        converted = _decision(document, identifier, features, question)
    elif source.kind == "unspecified-behavior":
        converted = open_question(
            identifier,
            features=features,
            dimensions=(),
            question=cast("str", document["description"]),
        )
        questions = ()
    elif source.kind == "evidence-reference":
        converted = _evidence(
            source, document, identifier, baseline.snapshot.profile.repository.id
        )
    else:
        if template is None or source.kind not in {"coverage-ledger", "parity-matrix"}:
            raise MutationError(
                "MIGRATION_TEMPLATE", "Supply the matching draft collection template"
            )
        fields = dict(template)
        fields["id"] = identifier
        if source.kind == "coverage-ledger":
            fields.update(revision=None, components=(), inventory_snapshot_refs=())
        else:
            fields.update(entries=(), source_repositories=(), target_repositories=())
        converted = JsonObject(tuple(fields.items()))
    fields = dict(converted)
    metadata: dict[str, JsonValue] = {
        "original_document": document,
        "source_path": source.path,
        "source_sha256": sha256(source.content).hexdigest(),
        "disposition": "draft-reconciliation-required",
        "unresolved_behavior_refs": tuple(
            draft_reference("unspecified-behavior", cast("str", value["id"]))
            for value in questions
        ),
    }
    fields["extensions"] = JsonObject(
        ((MIGRATION_EXTENSION, JsonObject(tuple(metadata.items()))),)
    )
    return ConvertedArtifact(
        source=source,
        original=document,
        document=JsonObject(tuple(fields.items())),
        questions=questions,
    )
