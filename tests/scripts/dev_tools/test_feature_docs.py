"""Unit tests for scripts/dev_tools/pr_context/feature_docs.py module."""

from pathlib import Path

import pytest

from scripts.dev_tools.pr_context.feature_docs import (
    _resolve_feature_dir,  # pyright: ignore[reportPrivateUsage]
    completed_plan_tasks,
    extract_issue_references,
    gather_feature_excerpts,
    parse_section,
)
from scripts.dev_tools.pr_context.render_feature_excerpts import extract_plan_sections


@pytest.fixture
def mem_path(tmp_path: Path) -> Path:
    """Alias fixture for cosmetic tmp_path->mem_path test parameter rename."""
    return tmp_path


class TestParseSection:
    def test_parse_section_found(self) -> None:
        markdown = "## Introduction\nHello\n## Details\nMore info\n## End\nFinal"
        result = parse_section(markdown, "Details")
        assert result == "More info"

    def test_parse_section_not_found(self) -> None:
        markdown = "## Introduction\nContent"
        result = parse_section(markdown, "Missing")
        assert result == ""

    def test_parse_section_last_heading(self) -> None:
        markdown = "## First\nOne\n## Last\nTwo"
        result = parse_section(markdown, "Last")
        assert result == "Two"

    def test_parse_section_empty_content(self) -> None:
        markdown = "## Empty\n## Next\nContent"
        result = parse_section(markdown, "Empty")
        assert result == ""

    def test_parse_section_special_chars(self) -> None:
        markdown = "## Details (v2.0)\nContent here"
        result = parse_section(markdown, "Details (v2.0)")
        assert result == "Content here"


class TestCompletedPlanTasks:
    def test_completed_plan_tasks_lowercase_x(self) -> None:
        markdown = "- [x] Task 1\n- [ ] Task 2\n- [x] Task 3"
        result = completed_plan_tasks(markdown)
        assert result == ["Task 1", "Task 3"]

    def test_completed_plan_tasks_uppercase_x(self) -> None:
        markdown = "- [X] Done\n- [ ] Todo"
        result = completed_plan_tasks(markdown)
        assert result == ["Done"]

    def test_completed_plan_tasks_limit(self) -> None:
        markdown = "- [x] A\n- [x] B\n- [x] C"
        result = completed_plan_tasks(markdown, limit=2)
        assert result == ["A", "B"]

    def test_completed_plan_tasks_asterisk_bullets(self) -> None:
        markdown = "* [x] Task A\n* [ ] Task B"
        result = completed_plan_tasks(markdown)
        assert result == ["Task A"]

    def test_completed_plan_tasks_no_completed(self) -> None:
        markdown = "- [ ] Todo 1\n- [ ] Todo 2"
        result = completed_plan_tasks(markdown)
        assert result == []


class TestExtractIssueReferences:
    def test_extract_issue_references_github(self) -> None:
        text = "Relates to #123 and #456"
        result = extract_issue_references(text)
        assert result == ["#123", "#456"]

    def test_extract_issue_references_jira(self) -> None:
        text = "See ABC-123 and XYZ-456"
        result = extract_issue_references(text)
        assert result == ["ABC-123", "XYZ-456"]

    def test_extract_issue_references_mixed(self) -> None:
        text = "Fix #42 for PROJECT-100"
        result = extract_issue_references(text)
        assert result == ["#42", "PROJECT-100"]

    def test_extract_issue_references_deduplication(self) -> None:
        text = "#10 again #10 and #10"
        result = extract_issue_references(text)
        assert result == ["#10"]

    def test_extract_issue_references_empty(self) -> None:
        result = extract_issue_references("")
        assert result == []

    def test_extract_issue_references_no_matches(self) -> None:
        text = "Just plain text"
        result = extract_issue_references(text)
        assert result == []


class TestGatherFeatureExcerpts:
    def test_gather_feature_excerpts_direct_match(self, mem_path: Path) -> None:
        feature_dir = mem_path / "docs" / "features" / "active" / "test-feature"
        feature_dir.mkdir(parents=True)
        (mem_path / "docs" / "features" / "potential" / "promoted").mkdir(parents=True)

        user_story = feature_dir / "user-story.md"
        user_story.write_text(
            "## Problem / Why\nAs a user I need this feature...", encoding="utf-8"
        )

        spec = feature_dir / "spec.md"
        spec.write_text(
            "## Overview\nFeature spec.\n## Details\nMore info.", encoding="utf-8"
        )

        plan = feature_dir / "plan.md"
        plan.write_text("## Tasks\n- [x] Task 1\n- [ ] Task 2", encoding="utf-8")

        changed_files = ["docs/features/active/test-feature/user-story.md"]
        excerpts = gather_feature_excerpts(mem_path, changed_files)

        assert len(excerpts) == 1
        assert excerpts[0].feature == "test-feature"
        assert "As a user I need this feature..." in excerpts[0].excerpt
        assert "Feature spec." in excerpts[0].excerpt
        assert "Task 1" in excerpts[0].excerpt

    def test_gather_feature_excerpts_fuzzy_match(self, mem_path: Path) -> None:
        feature_dir = mem_path / "docs" / "features" / "active" / "my-test-feature-impl"
        feature_dir.mkdir(parents=True)
        (mem_path / "docs" / "features" / "potential" / "promoted").mkdir(parents=True)

        spec = feature_dir / "spec.md"
        spec.write_text("## Spec\nData", encoding="utf-8")

        changed_files = ["docs/features/active/my-test-feature-impl/spec.md"]
        excerpts = gather_feature_excerpts(mem_path, changed_files)

        assert len(excerpts) == 1

    def test_gather_feature_excerpts_not_found(self, mem_path: Path) -> None:
        (mem_path / "docs" / "features" / "active").mkdir(parents=True)
        (mem_path / "docs" / "features" / "potential" / "promoted").mkdir(parents=True)

        changed_files = ["docs/features/active/nonexistent/user-story.md"]
        excerpts = gather_feature_excerpts(mem_path, changed_files)

        assert len(excerpts) == 0

    def test_gather_feature_excerpts_promoted(self, mem_path: Path) -> None:
        (mem_path / "docs" / "features" / "active").mkdir(parents=True)

        promoted_dir = mem_path / "docs" / "features" / "potential" / "promoted"
        feature_dir = promoted_dir / "test-feature"
        feature_dir.mkdir(parents=True)

        user_story = feature_dir / "user-story.md"
        user_story.write_text(
            "## Problem / Why\nPromoted story content", encoding="utf-8"
        )

        changed_files = ["docs/features/active/test-feature/plan.md"]
        excerpts = gather_feature_excerpts(mem_path, changed_files)
        assert len(excerpts) == 1
        assert excerpts[0].feature == "test-feature"
        assert "Promoted story content" in excerpts[0].excerpt

    def test_gather_feature_excerpts_extracts_issue_refs(self, mem_path: Path) -> None:
        feature_dir = mem_path / "docs" / "features" / "active" / "test"
        feature_dir.mkdir(parents=True)
        (mem_path / "docs" / "features" / "potential" / "promoted").mkdir(parents=True)

        user_story = feature_dir / "user-story.md"
        user_story.write_text("Relates to #123 and ABC-456", encoding="utf-8")

        changed_files = ["docs/features/active/test/user-story.md"]
        excerpts = gather_feature_excerpts(mem_path, changed_files)

        assert len(excerpts) == 1
        assert "#123" in excerpts[0].issue_refs
        assert "ABC-456" in excerpts[0].issue_refs

    def test_gather_feature_excerpts_multiple_features(self, mem_path: Path) -> None:
        for name in ["feature-a", "feature-b"]:
            feature_dir = mem_path / "docs" / "features" / "active" / name
            feature_dir.mkdir(parents=True)
            (feature_dir / "user-story.md").write_text(
                f"Story for {name}", encoding="utf-8"
            )
        (mem_path / "docs" / "features" / "potential" / "promoted").mkdir(parents=True)

        changed_files = [
            "docs/features/active/feature-a/user-story.md",
            "docs/features/active/feature-b/spec.md",
        ]
        excerpts = gather_feature_excerpts(mem_path, changed_files)

        assert len(excerpts) == 2
        features = {e.feature for e in excerpts}
        assert features == {"feature-a", "feature-b"}


class TestResolveFeatureDir:
    """Tests for _resolve_feature_dir focusing on directory matching loop."""

    def test_resolve_feature_dir_direct_match(self, mem_path: Path) -> None:
        """Test direct match when feature folder exists exactly."""
        base_dir = mem_path / "active"
        feature_dir = base_dir / "my-feature"
        feature_dir.mkdir(parents=True)

        result = _resolve_feature_dir(base_dir, "my-feature")
        assert result == feature_dir

    def test_resolve_feature_dir_pattern_match_prefix(self, mem_path: Path) -> None:
        """Test pattern matching with feature at start of directory name."""
        base_dir = mem_path / "active"
        (base_dir / "2025-12-01-my-feature-impl").mkdir(parents=True)
        (base_dir / "other-folder").mkdir(parents=True)

        result = _resolve_feature_dir(base_dir, "my-feature")
        assert result is not None
        assert result.name == "2025-12-01-my-feature-impl"

    def test_resolve_feature_dir_pattern_match_suffix(self, mem_path: Path) -> None:
        """Test pattern matching with feature at end of directory name."""
        base_dir = mem_path / "active"
        (base_dir / "impl-my-feature").mkdir(parents=True)

        result = _resolve_feature_dir(base_dir, "my-feature")
        assert result is not None
        assert result.name == "impl-my-feature"

    def test_resolve_feature_dir_pattern_match_middle(self, mem_path: Path) -> None:
        """Test pattern matching with feature in middle of directory name."""
        base_dir = mem_path / "active"
        (base_dir / "prefix-my-feature-suffix").mkdir(parents=True)

        result = _resolve_feature_dir(base_dir, "my-feature")
        assert result is not None
        assert result.name == "prefix-my-feature-suffix"

    def test_resolve_feature_dir_weak_match(self, mem_path: Path) -> None:
        """Test weak substring match when no pattern match found."""
        base_dir = mem_path / "active"
        (base_dir / "somemyfeaturedir").mkdir(parents=True)

        result = _resolve_feature_dir(base_dir, "myfeature")
        assert result is not None
        assert result.name == "somemyfeaturedir"

    def test_resolve_feature_dir_strong_over_weak(self, mem_path: Path) -> None:
        """Test that strong pattern match is preferred over weak substring match."""
        base_dir = mem_path / "active"
        (base_dir / "weak-myfeature-match").mkdir(parents=True)
        (base_dir / "strong-my-feature-match").mkdir(parents=True)

        result = _resolve_feature_dir(base_dir, "my-feature")
        assert result is not None
        # Strong match (with delimiters) should win
        assert result.name == "strong-my-feature-match"

    def test_resolve_feature_dir_skips_files(self, mem_path: Path) -> None:
        """Test that files are skipped during directory iteration."""
        base_dir = mem_path / "active"
        base_dir.mkdir(parents=True)
        # Create a file (not directory) with matching name
        (base_dir / "my-feature.txt").write_text("not a dir", encoding="utf-8")
        # Create actual directory
        (base_dir / "my-feature-dir").mkdir()

        result = _resolve_feature_dir(base_dir, "my-feature")
        assert result is not None
        assert result.name == "my-feature-dir"

    def test_resolve_feature_dir_sorted_order(self, mem_path: Path) -> None:
        """Test first sorted match returned when multiple strong matches exist."""
        base_dir = mem_path / "active"
        (base_dir / "z-my-feature").mkdir(parents=True)
        (base_dir / "a-my-feature").mkdir(parents=True)
        (base_dir / "m-my-feature").mkdir(parents=True)

        result = _resolve_feature_dir(base_dir, "my-feature")
        assert result is not None
        # Should return first in sorted order
        assert result.name == "a-my-feature"

    def test_resolve_feature_dir_no_match(self, mem_path: Path) -> None:
        """Test returns None when no match found."""
        base_dir = mem_path / "active"
        (base_dir / "other-feature").mkdir(parents=True)
        (base_dir / "different-thing").mkdir(parents=True)

        result = _resolve_feature_dir(base_dir, "nonexistent")
        assert result is None

    def test_resolve_feature_dir_empty_directory(self, mem_path: Path) -> None:
        """Test returns None when base directory is empty."""
        base_dir = mem_path / "active"
        base_dir.mkdir()

        result = _resolve_feature_dir(base_dir, "any-feature")
        assert result is None


def test_feature_doc_and_render_helpers_share_verification_then_test_plan_fallback():
    """Assert both helper paths honor the same heading fallback ordering contract."""
    plan_markdown = (
        "## Tasks\n"
        "- [x] done\n\n"
        "## Verification\n"
        "Verification-first notes should win.\n\n"
        "## Test Plan\n"
        "Secondary fallback notes.\n"
    )

    feature_docs_verification = parse_section(plan_markdown, "Verification")
    _plan_section, render_verification_notes = extract_plan_sections(plan_markdown)

    assert feature_docs_verification
    assert render_verification_notes
    assert "Verification-first notes should win." in render_verification_notes


def test_primary_issue_and_pass_readiness(mem_path: Path) -> None:
    """Assert Issue metadata is primary and latest feature-audit PASS is surfaced."""
    feature_dir = (
        mem_path
        / "docs"
        / "features"
        / "active"
        / "2026-02-22-pr-context-verification-contract-gap-46"
    )
    feature_dir.mkdir(parents=True)
    (mem_path / "docs" / "features" / "potential" / "promoted").mkdir(parents=True)

    (feature_dir / "spec.md").write_text(
        "- Issue: #46\n"
        "## Context\n"
        "Narrative mentions #40 #42 #43 should not become primary metadata issue.\n",
        encoding="utf-8",
    )
    (feature_dir / "user-story.md").write_text(
        "## Story Statement\n" "- Keep deterministic issue metadata.\n",
        encoding="utf-8",
    )
    (feature_dir / "plan.md").write_text("## Tasks\n- [x] done\n", encoding="utf-8")

    (feature_dir / "feature-audit.2026-02-22T20-00.md").write_text(
        "Readiness: NEEDS REVISION\n", encoding="utf-8"
    )
    (feature_dir / "feature-audit.2026-02-22T21-00.md").write_text(
        "Readiness: PASS\n", encoding="utf-8"
    )

    excerpts = gather_feature_excerpts(
        mem_path,
        [
            "docs/features/active/2026-02-22-pr-context-verification-contract-gap-46/spec.md"
        ],
    )
    assert len(excerpts) == 1
    assert excerpts[0].primary_issue_ref == "#46"
    assert excerpts[0].readiness_signal == "PASS"
