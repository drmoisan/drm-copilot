"""Additional unit tests for `scripts.dev_tools.atomic_executor.prompt_builder`.

This module exists to increase coverage without growing existing large test files.
All tests avoid real filesystem I/O by using in-memory fakes or monkeypatching.
"""

from __future__ import annotations

import logging
from pathlib import Path
from typing import TYPE_CHECKING

import pytest  # noqa: TCH002 - pytest required at runtime for fixtures

if TYPE_CHECKING:
    from collections.abc import Callable

from scripts.dev_tools.atomic_executor.plan_discovery import ResolvedPlan
from scripts.dev_tools.atomic_executor.plan_parser import PlanTask
from scripts.dev_tools.atomic_executor.prompt_builder import (
    PromptBuilder,
    RealPromptBuilderFileSystem,
)


class _InMemoryPromptBuilderFileSystem:
    """Minimal in-memory filesystem compatible with PromptBuilder."""

    def __init__(self, *, files: dict[str, str]) -> None:
        self._files = dict(files)

    def is_file(self, path: Path) -> bool:
        return path.as_posix() in self._files

    def is_dir(self, path: Path) -> bool:
        # Directories are not needed for these tests.
        return False

    def read_text(self, path: Path) -> str:
        key = path.as_posix()
        if key not in self._files:
            raise FileNotFoundError(key)
        return self._files[key]

    def glob(self, directory: Path, pattern: str) -> list[Path]:
        return []


def _make_plan_resolver(plan_name: str = "plan.md") -> Callable[[Path], ResolvedPlan]:
    """Create a deterministic plan resolver for PromptBuilder tests."""

    def resolve(feature_dir: Path) -> ResolvedPlan:
        return ResolvedPlan(
            path=feature_dir / plan_name,
            display_label=plan_name,
            update_filename=plan_name,
        )

    return resolve


def test_real_filesystem_delegates_to_path_methods(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """RealPromptBuilderFileSystem should delegate to Path methods."""
    fs = RealPromptBuilderFileSystem()

    def fake_is_file(self: Path) -> bool:
        return True

    def fake_is_dir(self: Path) -> bool:
        return False

    def fake_read_text(
        self: Path, *, encoding: str = "utf-8", errors: str | None = None
    ) -> str:
        _ = self
        _ = encoding
        _ = errors
        return "hi"

    def fake_glob(self: Path, pattern: str) -> list[Path]:
        _ = self
        _ = pattern
        return [Path("/x"), Path("/y")]

    monkeypatch.setattr(Path, "is_file", fake_is_file)
    monkeypatch.setattr(Path, "is_dir", fake_is_dir)
    monkeypatch.setattr(Path, "read_text", fake_read_text)
    monkeypatch.setattr(Path, "glob", fake_glob)

    p = Path("/anything")
    assert fs.is_file(p) is True
    assert fs.is_dir(p) is False
    assert fs.read_text(p) == "hi"
    assert fs.glob(Path("/"), "*.md") == [Path("/x"), Path("/y")]


def test_build_includes_phase0_reads_and_adjusts_check_instructions() -> None:
    """include_phase0_reads should inject unread Phase 0 read tasks."""
    workspace = Path("/workspace")
    template_path = Path("/workspace/template.md")
    feature_dir = Path("/workspace/docs/features/active/my-feature")
    plan_path = feature_dir / "plan.md"
    spec_path = feature_dir / "spec.md"

    plan_text = "\n".join(
        [
            "- [ ] [P0-T1] Read docs/features/active/my-feature/spec.md",
            "- [x] [P0-T2] Read already-done.md",
            "- [ ] [P0-T3] Implement something",
            "- [ ] [P1-T1] Do work",
        ]
    )

    fs = _InMemoryPromptBuilderFileSystem(
        files={
            template_path.as_posix(): "<agent> / <feature>\n",
            plan_path.as_posix(): plan_text,
            spec_path.as_posix(): "# spec\n",
        }
    )

    builder = PromptBuilder(
        workspace,
        template_path,
        fs=fs,
        plan_resolver=_make_plan_resolver(),
    )

    current = PlanTask(
        task_id="P1-T1",
        phase=1,
        task_num=1,
        title="Do work",
        checked=False,
        line_index=3,
    )
    prompt = builder.build(feature_dir, current, include_phase0_reads=True)

    assert "PHASE 0 READ TASKS" in prompt
    assert "- [P0-T1] Read docs/features/active/my-feature/spec.md" in prompt
    assert "P0-T2" not in prompt
    assert "P0-T3" not in prompt
    assert "checking the\nPhase 0 read tasks above" in prompt


def test_build_includes_retry_context_and_preferred_model_sections() -> None:
    """retry_context and preferred_model should add their respective sections."""
    workspace = Path("/workspace")
    template_path = Path("/workspace/template.md")
    feature_dir = Path("/workspace/docs/features/active/my-feature")
    plan_path = feature_dir / "plan.md"
    spec_path = feature_dir / "spec.md"

    fs = _InMemoryPromptBuilderFileSystem(
        files={
            template_path.as_posix(): "BASE\n",
            plan_path.as_posix(): "- [ ] [P1-T1] Do work\n",
            spec_path.as_posix(): "# spec\n",
        }
    )

    builder = PromptBuilder(
        workspace,
        template_path,
        preferred_model="gpt-5.2",
        fs=fs,
        plan_resolver=_make_plan_resolver(),
    )
    task = PlanTask(
        task_id="P1-T1",
        phase=1,
        task_num=1,
        title="Do work",
        checked=False,
        line_index=0,
    )

    prompt = builder.build(feature_dir, task, retry_context="failed: ruff")

    assert "!!! RETRY ATTEMPT !!!" in prompt
    assert "failed: ruff" in prompt
    assert "Preferred Model: gpt-5.2" in prompt


def test_build_feature_placeholder_falls_back_when_feature_not_under_active_root() -> (
    None
):
    """When feature_dir is outside workspace/docs/features/active, fallback applies."""
    workspace = Path("/workspace")
    template_path = Path("/workspace/template.md")
    feature_dir = Path("/other/location/feature-x")
    plan_path = feature_dir / "plan.md"
    spec_path = feature_dir / "spec.md"

    fs = _InMemoryPromptBuilderFileSystem(
        files={
            template_path.as_posix(): "Feature: <feature>\nAgent: <agent>\n",
            plan_path.as_posix(): "- [ ] [P1-T1] Do work\n",
            spec_path.as_posix(): "# spec\n",
        }
    )

    builder = PromptBuilder(
        workspace,
        template_path,
        fs=fs,
        plan_resolver=_make_plan_resolver(),
    )
    task = PlanTask(
        task_id="P1-T1",
        phase=1,
        task_num=1,
        title="Do work",
        checked=False,
        line_index=0,
    )

    prompt = builder.build(feature_dir, task)

    assert "Feature: feature-x" in prompt


def test_extract_task_block_includes_indented_continuations_and_one_blank() -> None:
    """Continuation capture should include indented lines and a single blank."""
    workspace = Path("/workspace")
    template_path = Path("/workspace/template.md")

    fs = _InMemoryPromptBuilderFileSystem(files={template_path.as_posix(): "BASE\n"})
    builder = PromptBuilder(workspace, template_path, fs=fs)

    plan_text = "\n".join(
        [
            "- [ ] [P1-T1] Parent",
            "  child 1",
            "",
            "  child 2",
            "not indented",
            "- [ ] [P1-T2] Next",
        ]
    )

    task = PlanTask(
        task_id="P1-T1",
        phase=1,
        task_num=1,
        title="Parent",
        checked=False,
        line_index=0,
    )

    block = builder._extract_task_block(  # pyright: ignore[reportPrivateUsage]
        plan_text, task
    )

    assert "- [ ] [P1-T1] Parent" in block
    assert "  child 1" in block
    assert "\n\n" in block
    assert "  child 2" in block
    assert "not indented" not in block


def test_extract_task_block_returns_not_found_message() -> None:
    """When task_id is not present, a not-found string should be returned."""
    workspace = Path("/workspace")
    template_path = Path("/workspace/template.md")

    fs = _InMemoryPromptBuilderFileSystem(files={template_path.as_posix(): "BASE\n"})
    builder = PromptBuilder(workspace, template_path, fs=fs)

    task = PlanTask(
        task_id="P9-T9",
        phase=9,
        task_num=9,
        title="Missing",
        checked=False,
        line_index=0,
    )

    assert (
        builder._extract_task_block(  # pyright: ignore[reportPrivateUsage]
            "- [ ] [P1-T1] Exists",
            task,
        )
        == "(task P9-T9 not found in plan)"
    )


def test_build_logs_warning_when_prompt_exceeds_threshold(
    caplog: pytest.LogCaptureFixture,
) -> None:
    """A warning should be logged when the prompt exceeds 15KB."""
    caplog.set_level(logging.WARNING)

    workspace = Path("/workspace")
    template_path = Path("/workspace/template.md")
    feature_dir = Path("/workspace/docs/features/active/my-feature")
    plan_path = feature_dir / "plan.md"
    spec_path = feature_dir / "spec.md"

    fs = _InMemoryPromptBuilderFileSystem(
        files={
            template_path.as_posix(): "x" * 16_000,
            plan_path.as_posix(): "- [ ] [P1-T1] Do work\n",
            spec_path.as_posix(): "# spec\n",
        }
    )

    builder = PromptBuilder(
        workspace,
        template_path,
        fs=fs,
        plan_resolver=_make_plan_resolver(),
    )
    task = PlanTask(
        task_id="P1-T1",
        phase=1,
        task_num=1,
        title="Do work",
        checked=False,
        line_index=0,
    )

    _ = builder.build(feature_dir, task)

    assert any("Prompt exceeds target threshold" in r.message for r in caplog.records)
