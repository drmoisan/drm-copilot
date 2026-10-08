"""Tests for the Python rewrite of potential-to-issue tooling."""

from __future__ import annotations

from pathlib import Path

import pytest

from scripts.dev_tools import potential_to_issue as mod
from tests.scripts.dev_tools.potential_to_issue_test_support import (
    FakeFileSystem,
    FakeGhClient,
    build_feature_potential_content,
)


def test_promote_potential_success_updates_metadata_and_moves_file() -> None:
    """Verify successful promotion updates metadata and archives the source file."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/sample.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Feature Title",
            "## Problem / Why",
            "why",
            "## Proposed Behavior",
            "behave",
            "## Acceptance Criteria (early draft)",
            "criteria",
            "## Constraints & Risks",
            "risk",
            "## Test Conditions to Consider",
            "tests",
        ]
    )

    create_result = mod.GhResult(["Created: https://example.com/issues/123"], 0)
    view_result = mod.GhResult(
        [
            '{"number":123,"title":"t","url":"https://example.com/issues/123","author":{"login":"me"},"updatedAt":"2024-01-02T00:00:00Z"}',
        ],
        0,
    )
    gh = FakeGhClient(create_result, view_result)
    messages: list[str] = []

    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
        emit=messages.append,
    )

    assert outcome.exit_code == 0
    assert outcome.destination is not None
    assert (
        outcome.destination == workspace / "docs/features/potential/promoted/sample.md"
    )
    assert len(gh.calls) == 2
    assert (potential, outcome.destination) in fs.moves

    promoted_content = fs.files[outcome.destination]
    lines = promoted_content.splitlines()
    assert lines[0] == "# Feature Title (Issue #123)"
    assert "- Issue: #123" in lines
    assert "- Issue URL: https://example.com/issues/123" in lines
    assert "- Last Updated: 2024-01-02" in lines
    assert (
        "- Status: Promoted -> docs/features/active/Feature_Title/ (Issue #123)"
        in lines
    )
    assert any(line.startswith("Moved potential file") for line in messages)


def test_promote_potential_failure_does_not_move_file() -> None:
    """Verify failed issue creation leaves source content and path unchanged."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/sample.md"
    fs = FakeFileSystem()
    original_content = "# Feature Title\n## Problem / Why\nwhy"
    fs.files[potential] = original_content

    create_result = mod.GhResult(["line1", "line2"], 1)
    gh = FakeGhClient(create_result)
    messages: list[str] = []

    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
        emit=messages.append,
    )

    assert outcome.exit_code == 1
    assert fs.moves == []
    assert fs.files[potential] == original_content
    assert gh.calls
    verb, (title, body, label) = gh.calls[0]
    assert verb == "create"
    assert title == "Feature: Feature Title"
    assert label == "feature"
    assert "## Problem / Why\nwhy" in body
    assert "## Proposed Behavior\n(not provided in potential file)" in body
    assert "## Acceptance Criteria\n(not provided in potential file)" in body
    assert "## Constraints & Risks\n(not provided in potential file)" in body
    assert "## Test Conditions\n(not provided in potential file)" in body
    assert potential.relative_to(workspace).as_posix() in body
    assert "line1" in messages and "line2" in messages


def test_promote_potential_feature_missing_label_recovers_and_moves_file() -> None:
    """Verify feature promotion recovers from a missing-label create failure."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/missing-feature-label.md"
    fs = FakeFileSystem()
    fs.files[potential] = build_feature_potential_content("Missing Feature Label")

    create_results = [
        mod.GhResult(["could not add label: 'feature' not found"], 1),
        mod.GhResult(["Created: https://example.com/issues/321"], 0),
    ]
    view_result = mod.GhResult(
        [
            '{"number":321,"title":"t","url":"https://example.com/issues/321","author":{"login":"me"},"updatedAt":"2024-04-05T00:00:00Z"}',
        ],
        0,
    )
    gh = FakeGhClient(create_results, view_result=view_result)

    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
    )

    assert outcome.exit_code == 0
    assert outcome.destination == (
        workspace / "docs/features/potential/promoted/missing-feature-label.md"
    )
    create_calls = [call for call in gh.calls if call[0] == "create"]
    assert len(create_calls) == 2
    assert gh.ensure_label_calls == ["feature"]
    assert all(call[1][2] == "feature" for call in create_calls)
    assert (potential, outcome.destination) in fs.moves


# fmt: off
def test_promote_potential_feature_existing_label_uses_single_issue_create_attempt(
) -> None:
# fmt: on
    """Verify existing feature labels stay on the single create path."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/existing-feature-label.md"
    fs = FakeFileSystem()
    fs.files[potential] = build_feature_potential_content("Existing Feature Label")

    create_result = mod.GhResult(["Created: https://example.com/issues/322"], 0)
    view_result = mod.GhResult(
        [
            '{"number":322,"title":"t","url":"https://example.com/issues/322","author":{"login":"me"},"updatedAt":"2024-04-05T00:00:00Z"}',
        ],
        0,
    )
    gh = FakeGhClient(create_result, view_result=view_result)

    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
    )

    assert outcome.exit_code == 0
    create_calls = [call for call in gh.calls if call[0] == "create"]
    assert len(create_calls) == 1
    assert create_calls[0][1][2] == "feature"
    assert gh.ensure_label_calls == []


def test_promote_potential_raises_on_missing_file() -> None:
    """Verify promotion raises when potential path cannot be found."""
    fs = FakeFileSystem()
    with pytest.raises(mod.PromotionError):
        mod.promote_potential(
            "/missing.md", fs=fs, gh=FakeGhClient(mod.GhResult([], 0))
        )


def test_promote_potential_rejects_invalid_promotion_type() -> None:
    """Verify invalid promotion types are rejected with a PromotionError."""
    fs = FakeFileSystem()
    invalid_path = Path("/workspace/tmp/file.md")
    fs.files[invalid_path] = "# Title"
    with pytest.raises(mod.PromotionError):
        mod.promote_potential(
            str(invalid_path),
            promotion_type="invalid",
            fs=fs,
            gh=FakeGhClient(mod.GhResult([], 0)),
        )


def test_promote_potential_checks_authentication_before_proceeding() -> None:
    """Verify that promotion succeeds when gh is authenticated."""
    content = (
        "# Test Feature (Potential)\n"
        "- Author: test\n"
        "- Date: 2024-01-01\n"
        "- Status: potential\n"
        "\n"
        "## Problem / Why\n"
        "Test problem\n"
        "\n"
        "## Proposed Behavior\n"
        "Test behavior\n"
        "\n"
        "## Acceptance Criteria (early draft)\n"
        "Test criteria\n"
        "\n"
        "## Constraints & Risks\n"
        "Test constraints\n"
        "\n"
        "## Test Conditions to Consider\n"
        "Test conditions\n"
    )

    fs = FakeFileSystem()
    potential_path = Path("docs/features/potential/test.md")
    fs.files[potential_path] = content

    create_result = mod.GhResult(["Created: https://example.com/issues/123"], 0)
    view_result = mod.GhResult(
        ['{\n  "number": 123,\n  "updatedAt": "2024-01-01T00:00:00Z"\n}'],
        0,
    )
    gh = FakeGhClient(create_result, view_result, authenticated=True)

    outcome = mod.promote_potential(
        str(potential_path),
        fs=fs,
        gh=gh,
        workspace=Path("/fake/workspace"),
    )

    assert outcome.exit_code == 0
    assert gh.calls[0][0] == "create"
    assert "Test problem" in gh.calls[0][1][1]


def test_promote_potential_fails_fast_when_not_authenticated() -> None:
    """Verify that promotion fails with clear message when gh is not authenticated."""
    content = "# Test Feature\n## Problem / Why\nTest problem\n"

    fs = FakeFileSystem()
    potential_path = Path("docs/features/potential/test.md")
    fs.files[potential_path] = content

    create_result = mod.GhResult(["should not be called"], 1)
    gh = FakeGhClient(create_result, authenticated=False)

    with pytest.raises(
        mod.PromotionError,
        match="GitHub CLI is not authenticated. Run 'gh auth login' first.",
    ):
        mod.promote_potential(
            str(potential_path),
            fs=fs,
            gh=gh,
            workspace=Path("/fake/workspace"),
        )

    assert (
        len(gh.calls) == 0
    ), "No gh commands should be executed when not authenticated"
