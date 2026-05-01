"""Tests for intermediate-state artifact writing in the v2 converter pipeline."""

from __future__ import annotations

import json
from pathlib import Path
from unittest.mock import patch

from scripts.dev_tools.codex_native_converter.engine import run_review_mode
from scripts.dev_tools.codex_native_converter.intermediate_state import (
    IntermediateState,
    write_intermediate_state_artifacts,
)
from scripts.dev_tools.codex_native_converter.models import (
    RunOptions,
    SourceArtifact,
    SourceEcosystem,
    SourceKind,
)
from scripts.dev_tools.codex_native_converter.models_intermediate import (
    PlannedEmission,
    SectionIntent,
    SectionIntentKind,
    TargetRole,
    TranslationTrace,
)


def _fixture_root(fixture_name: str) -> Path:
    """Resolve one committed converter fixture root used across multiple tests.

    Args:
        fixture_name (str): Subdirectory name under the test fixtures root.

    Returns:
        Path: Absolute path to the named fixture directory.

    Side Effects:
        None.
    """

    return (
        Path(__file__).resolve().parents[4]
        / "tests"
        / "fixtures"
        / "codex_native_converter"
        / fixture_name
    )


class _RecordingFileSystem:
    """Capture converter report writes without touching the local filesystem.

    Purpose:
        Allow engine calls to complete without real I/O by recording writes
        through the ConverterFileSystem protocol.

    Usage:
        Pass an instance as ``fs`` to ``run_review_mode``. After the call,
        inspect ``files`` to see which paths were written.

    Invariants / Constraints:
        Paths are stored by POSIX string representation.

    Side Effects:
        None.
    """

    def __init__(self) -> None:
        """Initialize with empty directory and file stores."""

        self.directories: set[str] = set()
        self.files: dict[str, str] = {}

    def mkdir(self, path: Path) -> None:
        """Record a created directory path without touching the filesystem."""

        self.directories.add(path.as_posix())

    def write_text(self, path: Path, content: str) -> None:
        """Record a written file path and its text content."""

        self.files[path.as_posix()] = content


def test_write_intermediate_state_artifacts_produces_all_four_required_files_when_enabled(  # noqa: E501
    mem_fs_path: Path,
) -> None:
    """write_intermediate_state_artifacts writes exactly four JSON files
    for an empty state.

    Scenario:
        Call ``write_intermediate_state_artifacts`` with an ``IntermediateState``
        whose collections are all empty and an in-memory artifact root provided
        by the ``mem_fs_path`` fixture.

    Expected outcome:
        The function returns a 4-tuple of paths; each path is readable and
        contains valid JSON; file names match the required artifact naming
        convention.
    """

    # Arrange: minimal state with empty collections.
    state = IntermediateState(
        source_artifacts=(),
        section_intents=(),
        planned_emissions=(),
        translation_traces=(),
    )

    # Act: write intermediate state to the in-memory artifact root.
    result = write_intermediate_state_artifacts(state, mem_fs_path)

    # Assert: exactly four paths are returned.
    assert len(result) == 4, f"Expected 4 paths, got {len(result)}"

    (
        source_artifacts_path,
        section_intents_path,
        planned_emissions_path,
        translation_traces_path,
    ) = result

    # Assert: required file names match the v2 intermediate state convention.
    assert source_artifacts_path.name == "source-artifacts.json"
    assert section_intents_path.name == "section-intents.json"
    assert planned_emissions_path.name == "planned-emissions.json"
    assert translation_traces_path.name == "translation-traces.json"

    # Assert: each file is readable and contains valid JSON (parse must not raise).
    parsed_source = json.loads(source_artifacts_path.read_text(encoding="utf-8"))
    parsed_intents = json.loads(section_intents_path.read_text(encoding="utf-8"))
    parsed_emissions = json.loads(planned_emissions_path.read_text(encoding="utf-8"))
    parsed_traces = json.loads(translation_traces_path.read_text(encoding="utf-8"))

    # Assert: empty state produces empty JSON arrays for all four collections.
    assert parsed_source == []
    assert parsed_intents == []
    assert parsed_emissions == []
    assert parsed_traces == []


def test_disabling_intermediate_state_exposure_does_not_change_emitted_outputs() -> (
    None
):
    """Engine produces identical report-path sets regardless of emit_intermediate_state.

    Scenario:
        Run the converter engine twice against the committed GitHub Copilot
        fixture: once with ``emit_intermediate_state=False`` and once with
        ``emit_intermediate_state=True``. Patch ``write_intermediate_state_artifacts``
        so it does not touch the filesystem. Use a separate ``_RecordingFileSystem``
        for each run to capture only the native report writes.

    Expected outcome:
        The set of paths written to the ``_RecordingFileSystem`` (i.e., the
        native report artifacts) is identical in both runs. The patched writer
        is called exactly once — for the run where the flag is enabled.
    """

    fixture_source_root = _fixture_root("github_copilot")
    # Use a virtual artifact root; the patched writer will not actually use it.
    virtual_artifact_root = Path("virtual/test/intermediate-state-exposure")

    _mock_paths = (
        Path("virtual/test/intermediate/source-artifacts.json"),
        Path("virtual/test/intermediate/section-intents.json"),
        Path("virtual/test/intermediate/planned-emissions.json"),
        Path("virtual/test/intermediate/translation-traces.json"),
    )

    # Patch write_intermediate_state_artifacts at the engine import site so the
    # engine's conditional call is intercepted without touching the filesystem.
    with patch(
        "scripts.dev_tools.codex_native_converter.engine.write_intermediate_state_artifacts",
        return_value=_mock_paths,
    ) as mock_writer:
        # Run 1: intermediate state disabled — writer must not be called.
        recording_disabled = _RecordingFileSystem()
        run_review_mode(
            RunOptions(
                mode="review",
                source_root=fixture_source_root,
                source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
                selected_paths=(),
                destination_root=None,
                artifact_root=virtual_artifact_root,
                emit_intermediate_state=False,
            ),
            fs=recording_disabled,
        )

        # Run 2: intermediate state enabled — writer must be called exactly once.
        recording_enabled = _RecordingFileSystem()
        run_review_mode(
            RunOptions(
                mode="review",
                source_root=fixture_source_root,
                source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
                selected_paths=(),
                destination_root=None,
                artifact_root=virtual_artifact_root,
                emit_intermediate_state=True,
            ),
            fs=recording_enabled,
        )

    # Assert: native report output sets are identical; emit_intermediate_state
    # must not alter which report artifacts the engine writes.
    assert set(recording_disabled.files) == set(recording_enabled.files), (
        "Report output paths differed between emit_intermediate_state=False "
        "and emit_intermediate_state=True."
    )

    # Assert: the writer was called exactly once (for the enabled run only).
    assert mock_writer.call_count == 1, (
        f"Expected write_intermediate_state_artifacts to be called once, "
        f"got {mock_writer.call_count}"
    )


def test_write_intermediate_state_artifacts_serializes_non_empty_collections(
    mem_fs_path: Path,
) -> None:
    """write_intermediate_state_artifacts correctly serializes non-empty collections.

    Scenario:
        Call ``write_intermediate_state_artifacts`` with an ``IntermediateState``
        that has one populated entry in each of the four collections.

    Expected outcome:
        Each of the four output JSON files contains exactly one entry with
        the expected serialized field values, confirming the serializer helpers
        are invoked with non-empty data.
    """

    # Arrange: one entry per collection to exercise the serializer helpers.
    # SectionIntent requires source_path, section_id, heading, intent_kind.
    intent = SectionIntent(
        source_path="test.md",
        section_id="test.md#overview-1",
        heading="Overview",
        intent_kind=SectionIntentKind.IDENTITY,
        notes=("Heading matches identity pattern.",),
    )

    # PlannedEmission extends SectionIntent fields with target_role and target_path.
    emission = PlannedEmission(
        source_path="test.md",
        section_id="test.md#overview-1",
        heading="Overview",
        intent_kind=SectionIntentKind.IDENTITY,
        target_role=TargetRole.STANDING_GUIDANCE,
        target_path="instructions/overview.md",
    )

    # TranslationTrace mirrors PlannedEmission fields for report-level tracing.
    trace = TranslationTrace(
        source_path="test.md",
        section_id="test.md#overview-1",
        heading="Overview",
        intent_kind=SectionIntentKind.IDENTITY,
        target_role=TargetRole.STANDING_GUIDANCE,
        target_path="instructions/overview.md",
        notes=("Trace from identity section to standing-guidance target.",),
    )

    artifact = SourceArtifact(
        source_path="test.md",
        source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
        source_kind=SourceKind.STANDING_INSTRUCTION,
        frontmatter={},
        raw_text="",
        sections=(),
    )

    state = IntermediateState(
        source_artifacts=(artifact,),
        section_intents=(intent,),
        planned_emissions=(emission,),
        translation_traces=(trace,),
    )

    # Act: write intermediate state to the in-memory artifact root.
    (
        source_artifacts_path,
        section_intents_path,
        planned_emissions_path,
        translation_traces_path,
    ) = write_intermediate_state_artifacts(state, mem_fs_path)

    # Assert: each file contains exactly one entry.
    parsed_source = json.loads(source_artifacts_path.read_text(encoding="utf-8"))
    parsed_intents = json.loads(section_intents_path.read_text(encoding="utf-8"))
    parsed_emissions = json.loads(planned_emissions_path.read_text(encoding="utf-8"))
    parsed_traces = json.loads(translation_traces_path.read_text(encoding="utf-8"))

    assert len(parsed_source) == 1
    assert len(parsed_intents) == 1
    assert len(parsed_emissions) == 1
    assert len(parsed_traces) == 1

    # Assert: serialized fields match expected values for each collection type.
    assert parsed_source[0]["source_path"] == "test.md"
    assert parsed_intents[0]["intent_kind"] == "identity"
    assert parsed_emissions[0]["target_role"] == "standing-guidance"
    assert parsed_traces[0]["target_path"] == "instructions/overview.md"
