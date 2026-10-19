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
    """Map identifier (str) to a v2-compatible str without I/O or mutation.

    Compatible IDs remain unchanged; other spellings use their UTF-8 SHA-256.
    """
    # Preserve identity when valid; hashing makes incompatible spellings explicit.
    if re.fullmatch(r"[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*", identifier):
        return identifier
    return "migrated-" + sha256(identifier.encode("utf-8")).hexdigest()


def legacy_features(document: JsonObject) -> tuple[str, ...]:
    """Return sorted tuple[str, ...] selectors from document (JsonObject).

    Only validated direct/nested declarations contribute; no I/O or mutation occurs.
    """
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
    """Parse change (MutationChange) bytes into JsonObject without I/O.

    Raise MutationError when an accepted builder returns malformed JSON.
    """
    value = parse_document(change.content, format="json").value
    if value is None:
        raise MutationError("MIGRATION_DRAFT", "Draft builder returned invalid JSON")
    return value


def _draft_changes(
    changes: tuple[MutationChange, ...],
) -> tuple[JsonObject, tuple[JsonObject, ...]]:
    """Split changes (tuple[MutationChange, ...]) from the accepted draft builder.

    Return (JsonObject artifact, tuple[JsonObject, ...] new questions) without I/O.
    Only the appended question is selected; malformed bytes raise MutationError.
    """
    records = cast("tuple[JsonObject, ...]", _parsed(changes[1])["records"])
    return _parsed(changes[0]), records[-1:]


def _scenario(
    baseline: CapturedWorkspace,
    document: JsonObject,
    identifier: str,
    features: tuple[str, ...],
    binding: MigrationBinding,
) -> tuple[JsonObject, tuple[JsonObject, ...]]:
    """Retain legacy stimulus using an explicit environment, without I/O.

    Args:
        baseline (CapturedWorkspace): Immutable draft-builder context.
        document (JsonObject): Validated v1 scenario.
        identifier (str): Mapped v2 scenario identity.
        features (tuple[str, ...]): Mapped feature IDs.
        binding (MigrationBinding): Caller-selected environment.

    Return (JsonObject scenario, tuple[JsonObject, ...] questions). Missing
    environment or malformed draft bytes raise MutationError; inputs are unchanged.
    """
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
            # Preserve named input values in deterministic order without inference.
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
    """Return a proposed JsonObject decision without approving legacy claims.

    document (JsonObject) supplies validated text, identifier (str) its mapped ID,
    features (tuple[str, ...]) its scope and question (JsonObject) its open finding.
    No I/O or input mutation occurs; caller validates the complete draft graph.
    """
    fields = draft_header("product-decision", identifier)
    fields.update(
        decision_id=identifier,
        # Translate caller-selected scope without manufacturing target approval.
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
    """Return JsonObject evidence of record bytes, not its claimed payload.

    source (MigrationSource) supplies captured bytes/path, document (JsonObject)
    the original timestamp, and identifier/repository (str) explicit local IDs.
    No I/O or input mutation occurs; provenance remains unverified metadata.
    """
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

    Args:
        baseline (CapturedWorkspace): Immutable configured builder context.
        source (MigrationSource): Exact validated original bytes, path and kind.
        document (JsonObject): Parsed and schema-validated v1 record.
        binding (MigrationBinding): Caller feature/environment context, if needed.
        feature_ids (Mapping[str, str]): Original-to-mapped feature input IDs.
        template (JsonObject | None): Required empty ledger/parity draft template.

    Return ConvertedArtifact containing a draft, originals and open obligations.
    Missing context/templates or malformed builder output raise MutationError;
    invalid required draft fields raise ValueError. No I/O or input mutation occurs.
    Caller validates the complete graph; originals cannot supply verified state.
    """
    old_id = cast("str", document["id"])
    identifier = migrated_id(old_id)
    # Contracts bind themselves; other records prefer explicit caller selectors.
    selected = (
        (old_id,)
        if source.kind == "feature-contract"
        else binding.feature_ids or legacy_features(document)
    )
    # Every selection must resolve to a real feature input in this migration.
    if not selected or any(value not in feature_ids for value in selected):
        raise MutationError(
            "MIGRATION_REQUIRED_CONTEXT",
            f"Supply feature_ids for {old_id} referencing feature-contract "
            "inputs in this migration",
        )
    # Resolve only declared selectors and sort references for deterministic output.
    features = tuple(sorted(feature_ids[value] for value in selected))
    question = open_question(
        "unknown-migration-" + identifier,
        features=features,
        dimensions=(),
        question="Reconcile missing behavior dimensions, revisions, evidence, "
        f"environment, approvals and expectations retained from v1 record {old_id}.",
    )
    questions = (question,)
    # Route contracts/scenarios through builders, decisions to proposals, unknowns
    # to open records, evidence to byte proofs, and ledger/parity to empty drafts.
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
        # Legacy rows cannot prove v2 pins/evidence; retain them only in metadata.
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
        # Keep missing semantics explicitly linked instead of supplying defaults.
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
