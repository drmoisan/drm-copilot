"""Tests for plan discovery utilities and PromptBuilder context assembly.

These tests avoid filesystem temp paths by monkeypatching Path methods.
TestPromptBuilderContext covers the PromptBuilder paths that resolve the plan
context (retry text, feature naming, the size warning, Phase 0 read tasks, the
task block) and the real file system adapter, through the in-memory helpers of
test_prompt_builder.py.
"""

from __future__ import annotations

import logging
from pathlib import Path
from unittest.mock import Mock

import pytest

from scripts.dev_tools.atomic_executor.plan_discovery import (
    parse_timestamped_plan_filename,
    resolve_feature_plan,
)
from scripts.dev_tools.atomic_executor.plan_parser import PlanTask
from scripts.dev_tools.atomic_executor.prompt_builder import (
    PromptBuilder,
    RealPromptBuilderFileSystem,
)
from tests.scripts.dev_tools.atomic_executor.test_prompt_builder import (
    InMemoryPromptBuilderFileSystem,
    make_default_plan_resolver,
)


class TestParseTimestampedPlanFilename:
    """Unit tests for timestamp parsing."""

    @pytest.mark.parametrize(
        ("filename", "expected"),
        [
            ("plan.2026-01-09T22-27.md", True),
            ("plan.1999-12-31T23-59.md", True),
            ("plan.md", False),
            ("plan.2026-01-09T22-27.txt", False),
            ("plan.2026-01-09 22-27.md", False),
            ("not-a-plan.2026-01-09T22-27.md", False),
        ],
    )
    def test_parses_only_valid_timestamped_names(
        self, filename: str, expected: bool
    ) -> None:
        """Valid `plan.<timestamp>.md` names parse; others return None."""

        parsed = parse_timestamped_plan_filename(filename)
        assert (parsed is not None) is expected


class TestResolveFeaturePlan:
    """Unit tests for resolve_feature_plan()."""

    def test_prefers_plan_md_when_present(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """If plan.md exists, it is always selected."""

        feature_dir = Path("/repo/docs/features/active/my-feature")

        def fake_is_file(self: Path) -> bool:
            return self.name == "plan.md"

        def fake_glob(self: Path, pattern: str):
            assert pattern == "plan.*.md"
            return [
                feature_dir / "plan.2026-01-09T00-00.md",
                feature_dir / "plan.2026-01-09T22-27.md",
            ]

        monkeypatch.setattr(Path, "is_file", fake_is_file)
        monkeypatch.setattr(Path, "glob", fake_glob)

        resolved = resolve_feature_plan(feature_dir)
        assert resolved.path.name == "plan.md"
        assert resolved.update_filename == "plan.md"

    def test_selects_latest_timestamp_when_plan_md_missing(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """When plan.md is missing, choose the newest plan.<timestamp>.md."""

        feature_dir = Path("/repo/docs/features/active/my-feature")

        def fake_is_file(self: Path) -> bool:
            return False

        def fake_glob(self: Path, pattern: str):
            assert self == feature_dir
            assert pattern == "plan.*.md"
            return [
                feature_dir / "plan.2026-01-09T00-00.md",
                feature_dir / "plan.2026-01-09T22-27.md",
                feature_dir / "plan.not-a-timestamp.md",
            ]

        monkeypatch.setattr(Path, "is_file", fake_is_file)
        monkeypatch.setattr(Path, "glob", fake_glob)

        resolved = resolve_feature_plan(feature_dir)
        assert resolved.path.name == "plan.2026-01-09T22-27.md"
        assert resolved.update_filename == "plan.2026-01-09T22-27.md"
        # Back-compat markers stay stable for older tooling.
        assert resolved.display_label == "plan.md"

    def test_raises_when_no_plan_files_found(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Raise a clear error when neither plan.md nor timestamped plans exist."""

        feature_dir = Path("/repo/docs/features/active/my-feature")

        def fake_is_file(self: Path) -> bool:
            return False

        def fake_glob(self: Path, pattern: str) -> list[Path]:
            assert pattern == "plan.*.md"
            return []

        monkeypatch.setattr(Path, "is_file", fake_is_file)
        monkeypatch.setattr(Path, "glob", fake_glob)

        with pytest.raises(FileNotFoundError, match="Missing required plan file"):
            resolve_feature_plan(feature_dir)


_WORKSPACE = Path("/workspace")
_TEMPLATE_PATH = Path("/workspace/template.md")
_ACTIVE_FEATURE_DIR = Path("/workspace/docs/features/active/my-feature")


def _make_builder(
    plan_text: str,
    *,
    feature_dir: Path = _ACTIVE_FEATURE_DIR,
    template: str = "BASE TEMPLATE\n",
) -> PromptBuilder:
    """Build a PromptBuilder over an in-memory plan, spec, and template."""
    fs = InMemoryPromptBuilderFileSystem(
        files={
            _TEMPLATE_PATH.as_posix(): template,
            (feature_dir / "plan.md").as_posix(): plan_text,
            (feature_dir / "spec.md").as_posix(): "# Specification\n",
        },
        dirs={feature_dir.as_posix()},
    )
    return PromptBuilder(
        _WORKSPACE, _TEMPLATE_PATH, fs=fs, plan_resolver=make_default_plan_resolver()
    )


def _task(task_id: str, title: str) -> PlanTask:
    """Build an unchecked PlanTask for the given identifier."""
    phase = int(task_id[1 : task_id.index("-")])
    task_num = int(task_id.split("-T")[1])
    return PlanTask(
        task_id=task_id,
        phase=phase,
        task_num=task_num,
        title=title,
        checked=False,
        line_index=0,
    )


def _section(prompt: str, start: str, end: str) -> str:
    """Return the prompt text between two markers."""
    return prompt.split(start, 1)[1].split(end, 1)[0]


class TestPromptBuilderContext:
    """Coverage of PromptBuilder context assembly and the real file system adapter."""

    def test_real_file_system_is_dir_delegates_to_path(self) -> None:
        """RealPromptBuilderFileSystem.is_dir returns Path.is_dir()."""
        path = Mock(spec=Path)
        path.is_dir.return_value = True

        assert RealPromptBuilderFileSystem().is_dir(path) is True
        path.is_dir.assert_called_once_with()

    def test_real_file_system_glob_sorts_matches(self) -> None:
        """RealPromptBuilderFileSystem.glob returns the matches in sorted order."""
        directory = Mock(spec=Path)
        directory.glob.return_value = iter([Path("b.md"), Path("a.md")])

        assert RealPromptBuilderFileSystem().glob(directory, "*.md") == [
            Path("a.md"),
            Path("b.md"),
        ]
        directory.glob.assert_called_once_with("*.md")

    def test_build_includes_retry_context(self) -> None:
        """build() renders the retry section with the previous errors."""
        builder = _make_builder("- [ ] [P1-T1] Task")

        prompt = builder.build(
            _ACTIVE_FEATURE_DIR, _task("P1-T1", "Task"), retry_context="ruff E501"
        )

        assert "!!! RETRY ATTEMPT !!!" in prompt
        assert "ruff E501" in prompt

    def test_build_uses_folder_name_outside_active_root(self) -> None:
        """build() names a feature outside the active root by its folder name."""
        feature_dir = Path("/elsewhere/other-feature")
        builder = _make_builder(
            "- [ ] [P1-T1] Task",
            feature_dir=feature_dir,
            template="Feature: <feature>\n",
        )

        prompt = builder.build(feature_dir, _task("P1-T1", "Task"))

        assert prompt.startswith("Feature: other-feature\n")

    def test_build_warns_when_prompt_exceeds_threshold(
        self, caplog: pytest.LogCaptureFixture
    ) -> None:
        """build() logs a warning when the prompt exceeds 15,000 characters."""
        builder = _make_builder("- [ ] [P1-T1] Task", template="x" * 16_000)

        with caplog.at_level(
            logging.WARNING, logger="scripts.dev_tools.atomic_executor.prompt_builder"
        ):
            builder.build(_ACTIVE_FEATURE_DIR, _task("P1-T1", "Task"))

        assert "exceeds target threshold" in caplog.text

    def test_build_prepends_only_unchecked_phase0_read_tasks(self) -> None:
        """Only unchecked Phase 0 read tasks reach the Phase 0 section."""
        plan_text = "\n".join(
            [
                "# Plan",
                "Prose that is not a task.",
                "- [ ] [P1-T1] Read the phase one notes",
                "- [x] [P0-T1] Read the policy files",
                "- [ ] [P0-T2] Capture the baseline",
                "- [ ] [P0-T3] Read the spec",
            ]
        )
        builder = _make_builder(plan_text)

        prompt = builder.build(
            _ACTIVE_FEATURE_DIR,
            _task("P0-T2", "Capture the baseline"),
            include_phase0_reads=True,
        )

        section = _section(prompt, "PHASE 0 READ TASKS", "Before starting")
        assert "- [P0-T3] Read the spec" in section
        # The checked read, the non-read task, and the later-phase read stay out.
        for excluded in ("P0-T1", "P0-T2", "P1-T1"):
            assert excluded not in section
        assert "Phase 0 read tasks above and the current task" in prompt

    def test_build_task_block_keeps_continuation_and_stops_at_next_task(
        self,
    ) -> None:
        """The task block keeps indented lines and inner blanks and stops at a task."""
        plan_text = "\n".join(
            [
                "- [ ] [P0-T1] Task one",
                "",
                "  first detail",
                "",
                "  second detail",
                "- [ ] [P0-T2] Task two",
            ]
        )
        builder = _make_builder(plan_text)

        prompt = builder.build(_ACTIVE_FEATURE_DIR, _task("P0-T1", "Task one"))

        block = _section(
            prompt, "---- BEGIN plan task ----\n", "\n---- END plan task ----"
        )
        assert block == "- [ ] [P0-T1] Task one\n  first detail\n\n  second detail"
