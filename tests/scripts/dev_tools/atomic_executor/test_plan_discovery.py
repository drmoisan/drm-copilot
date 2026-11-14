"""Tests for plan discovery utilities and the real PromptBuilder file system.

These tests avoid filesystem temp paths by monkeypatching Path methods.
TestRealPromptBuilderFileSystem covers the sorted glob result of the real
file system adapter, which the PromptBuilder cases in test_prompt_builder.py
do not assert.
"""

from __future__ import annotations

from pathlib import Path
from unittest.mock import Mock

import pytest

from scripts.dev_tools.atomic_executor.plan_discovery import (
    parse_timestamped_plan_filename,
    resolve_feature_plan,
)
from scripts.dev_tools.atomic_executor.prompt_builder import (
    RealPromptBuilderFileSystem,
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


class TestRealPromptBuilderFileSystem:
    """Coverage of the real file system adapter that main's cases do not assert."""

    def test_real_file_system_glob_sorts_matches(self) -> None:
        """RealPromptBuilderFileSystem.glob returns the matches in sorted order."""
        directory = Mock(spec=Path)
        directory.glob.return_value = iter([Path("b.md"), Path("a.md")])

        assert RealPromptBuilderFileSystem().glob(directory, "*.md") == [
            Path("a.md"),
            Path("b.md"),
        ]
        directory.glob.assert_called_once_with("*.md")
