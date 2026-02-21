"""Contract tests for persisted minor-audit work-mode documentation behavior."""

from __future__ import annotations

from pathlib import Path


def _read_text(path: Path) -> str:
    """Read UTF-8 text from a repository file path."""
    return path.read_text(encoding="utf-8")


def test_feature_review_branching_contract() -> None:
    """Verify feature review agent defines marker-driven AC source branching."""
    path = Path(".github/agents/feature-review.agent.md")
    content = _read_text(path)

    assert "Work Mode: minor-audit" in content
    assert "issue.md" in content
    assert "spec.md" in content and "user-story.md" in content


def test_epic_review_minor_audit_doc_completeness_contract() -> None:
    """Verify epic review agent defines minor-audit doc completeness contract."""
    path = Path(".github/agents/epic-review.agent.md")
    content = _read_text(path)

    assert "Work Mode: minor-audit" in content
    assert "doc completeness" in content
    assert "issue.md" in content
    assert "spec.md" in content and "user-story.md" in content
    assert "fallback to full" in content


def test_status_updater_branching_contract() -> None:
    """Verify status updater defines marker-driven Delivered and evidence branching."""
    path = Path(".github/agents/status_updater.agent.md")
    content = _read_text(path)

    assert "Work Mode: minor-audit" in content
    assert "Delivered" in content
    assert "issue.md" in content
    assert "spec.md" in content and "user-story.md" in content
    assert "evidence" in content


def test_feature_promotion_lifecycle_work_mode_contract() -> None:
    """Verify feature promotion lifecycle includes work-mode command semantics."""
    path = Path(".github/skills/feature-promotion-lifecycle/SKILL.md")
    content = _read_text(path)

    assert "--work-mode" in content
    assert "minor-audit" in content
    assert "issue.md" in content
    assert "spec.md" in content and "user-story.md" in content
