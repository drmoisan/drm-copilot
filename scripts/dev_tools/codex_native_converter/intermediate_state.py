"""Write compiler-like intermediate state artifacts for the converter pipeline.

Purpose:
    Expose the parsed and classified intermediate state as machine-readable JSON
    files in the artifact root so downstream tools and reviewers can audit the
    full conversion pipeline decisions.

Usage:
    The converter engine calls `write_intermediate_state_artifacts` when
    `RunOptions.emit_intermediate_state` is `True`. Callers provide a populated
    `IntermediateState` object and an artifact root path.

Flow:
    Four deterministically ordered JSON files are written under
    ``artifact_root/intermediate/``: one for source artifacts, one for section
    intents, one for planned emissions, and one for translation traces.

Invariants / Constraints:
    All JSON output uses sorted keys and stable ordering so successive calls
    with the same state produce byte-identical output.

Side Effects:
    Creates the ``intermediate/`` subdirectory under the artifact root if it
    does not already exist. Writes or overwrites four JSON files.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.codex_native_converter.models import (
        PlannedEmission,
        SectionIntent,
        SourceArtifact,
        TranslationTrace,
    )


@dataclass(frozen=True, slots=True)
class IntermediateState:
    """Hold the four compiler-like intermediate state collections.

    Purpose:
        Bundle all four intermediate state collections so engine stages can
        pass the full pipeline state to the intermediate-state writer without
        using mutable shared state.

    Usage:
        The engine populates one instance per run after parsing, classification,
        and planning are complete, then passes it to
        `write_intermediate_state_artifacts` when `emit_intermediate_state` is
        enabled.

    Invariants / Constraints:
        Collections use tuples for immutability; ordering must be deterministic
        (i.e., insertion order reflects stable pipeline processing order).

    Side Effects:
        None.

    Attributes:
        source_artifacts (tuple[SourceArtifact, ...]): All parsed artifacts
            from the source tree.
        section_intents (tuple[SectionIntent, ...]): All classified section
            intents produced by the section-intent classifier.
        planned_emissions (tuple[PlannedEmission, ...]): All planned emissions
            produced by the emission planner.
        translation_traces (tuple[TranslationTrace, ...]): All translation
            traces linking source sections to native targets.
    """

    source_artifacts: tuple[SourceArtifact, ...]
    section_intents: tuple[SectionIntent, ...]
    planned_emissions: tuple[PlannedEmission, ...]
    translation_traces: tuple[TranslationTrace, ...]


def _serialize_source_artifact(artifact: SourceArtifact) -> dict[str, object]:
    """Serialize one SourceArtifact to a JSON-safe dict.

    Args:
        artifact (SourceArtifact): The artifact to serialize.

    Returns:
        dict[str, object]: JSON-safe representation.

    Side Effects:
        None.
    """

    return {
        "source_path": artifact.source_path,
        "source_ecosystem": artifact.source_ecosystem.value,
        "source_kind": artifact.source_kind.value,
        "frontmatter": dict(sorted(artifact.frontmatter.items())),
        "sections": [
            {
                "section_id": s.section_id,
                "heading": s.heading,
                "level": s.level,
                "start_line": s.start_line,
                "end_line": s.end_line,
                "cues": [{"kind": c.kind.value, "value": c.value} for c in s.cues],
            }
            for s in artifact.sections
        ],
    }


def _serialize_section_intent(intent: SectionIntent) -> dict[str, object]:
    """Serialize one SectionIntent to a JSON-safe dict.

    Args:
        intent (SectionIntent): The intent to serialize.

    Returns:
        dict[str, object]: JSON-safe representation.

    Side Effects:
        None.
    """

    return {
        "source_path": intent.source_path,
        "section_id": intent.section_id,
        "heading": intent.heading,
        "intent_kind": intent.intent_kind.value,
        "notes": list(intent.notes),
    }


def _serialize_planned_emission(emission: PlannedEmission) -> dict[str, object]:
    """Serialize one PlannedEmission to a JSON-safe dict.

    Args:
        emission (PlannedEmission): The emission to serialize.

    Returns:
        dict[str, object]: JSON-safe representation.

    Side Effects:
        None.
    """

    return {
        "source_path": emission.source_path,
        "section_id": emission.section_id,
        "heading": emission.heading,
        "intent_kind": emission.intent_kind.value,
        "target_role": emission.target_role.value,
        "target_path": emission.target_path,
        "notes": list(emission.notes),
    }


def _serialize_translation_trace(trace: TranslationTrace) -> dict[str, object]:
    """Serialize one TranslationTrace to a JSON-safe dict.

    Args:
        trace (TranslationTrace): The trace to serialize.

    Returns:
        dict[str, object]: JSON-safe representation.

    Side Effects:
        None.
    """

    return {
        "source_path": trace.source_path,
        "section_id": trace.section_id,
        "heading": trace.heading,
        "intent_kind": trace.intent_kind.value,
        "target_role": trace.target_role.value,
        "target_path": trace.target_path,
        "notes": list(trace.notes),
    }


def write_intermediate_state_artifacts(
    state: IntermediateState,
    artifact_root: Path,
) -> tuple[Path, Path, Path, Path]:
    """Write the four intermediate state JSON files under the artifact root.

    Files are written under ``artifact_root/intermediate/``.

    Purpose:
        Expose the full pipeline intermediate state as deterministic, auditable
        JSON so downstream tools can inspect parsed sections, classified intents,
        planned emissions, and translation traces without re-running the pipeline.

    Args:
        state (IntermediateState): The populated intermediate state produced by
            the converter pipeline after parsing, classification, and planning.
        artifact_root (Path): The artifact root directory. The function creates
            an ``intermediate/`` subdirectory under this path.

    Returns:
        tuple[Path, Path, Path, Path]: The four written file paths in order:
            source-artifacts.json, section-intents.json,
            planned-emissions.json, translation-traces.json.

    Raises:
        OSError: If the artifact root or the intermediate subdirectory cannot be
            created, or if any output file cannot be written.

    Side Effects:
        Creates ``artifact_root/intermediate/`` and writes or overwrites four
        JSON files inside it.
    """

    intermediate_dir = artifact_root / "intermediate"
    intermediate_dir.mkdir(parents=True, exist_ok=True)

    # Write source artifacts in stable insertion order using sorted keys so
    # the output is byte-identical across successive calls with the same state.
    source_artifacts_path = intermediate_dir / "source-artifacts.json"
    source_artifacts_path.write_text(
        json.dumps(
            [_serialize_source_artifact(a) for a in state.source_artifacts],
            indent=2,
            sort_keys=True,
        ),
        encoding="utf-8",
    )

    # Write section intents in pipeline insertion order.
    section_intents_path = intermediate_dir / "section-intents.json"
    section_intents_path.write_text(
        json.dumps(
            [_serialize_section_intent(i) for i in state.section_intents],
            indent=2,
            sort_keys=True,
        ),
        encoding="utf-8",
    )

    # Write planned emissions in pipeline insertion order.
    planned_emissions_path = intermediate_dir / "planned-emissions.json"
    planned_emissions_path.write_text(
        json.dumps(
            [_serialize_planned_emission(e) for e in state.planned_emissions],
            indent=2,
            sort_keys=True,
        ),
        encoding="utf-8",
    )

    # Write translation traces in pipeline insertion order.
    translation_traces_path = intermediate_dir / "translation-traces.json"
    translation_traces_path.write_text(
        json.dumps(
            [_serialize_translation_trace(t) for t in state.translation_traces],
            indent=2,
            sort_keys=True,
        ),
        encoding="utf-8",
    )

    return (
        source_artifacts_path,
        section_intents_path,
        planned_emissions_path,
        translation_traces_path,
    )
