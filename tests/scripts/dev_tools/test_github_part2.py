"""Unit tests for scripts.dev_tools.pr_context.github module.

Focused on driving coverage of key uncovered paths.
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING
from unittest.mock import Mock

import pytest

from scripts.dev_tools.pr_context.git import CommandRunner
from scripts.dev_tools.pr_context.github import GhClient
from scripts.dev_tools.pr_context.models import CommandResult

if TYPE_CHECKING:
    from pathlib import Path


@pytest.fixture
def mem_path(tmp_path: Path) -> Path:
    """Alias fixture for cosmetic tmp_path->mem_path test parameter rename."""
    return tmp_path


class TestGhClientCurrentPrExtended:
    """Extended tests for current_pr."""

    def test_current_pr_success(self, mem_path: Path) -> None:
        """current_pr returns PR number when active."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(json.dumps({"number": 42}), "", 0),
        ]

        client = GhClient(runner, mem_path, gh_path="/usr/bin/gh")
        pr = client.current_pr()

        assert pr is not None
        assert pr.number == "#42"

    def test_current_pr_invalid_json(self, mem_path: Path) -> None:
        """current_pr returns None on invalid JSON."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult("invalid", "", 0),
        ]

        client = GhClient(runner, mem_path, gh_path="/usr/bin/gh")
        pr = client.current_pr()

        assert pr is None

    def test_current_pr_with_labels_and_assignees(self, mem_path: Path) -> None:
        """current_pr extracts labels and assignees."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 42,
                        "title": "Current PR",
                        "labels": [{"name": "feature"}],
                        "assignees": [{"login": "dev1"}],
                    }
                ),
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_path, gh_path="/usr/bin/gh")
        pr = client.current_pr()

        assert pr is not None
        assert pr.labels == ["feature"]
        assert pr.assignees == ["dev1"]

    def test_current_pr_with_closing_issues(self, mem_path: Path) -> None:
        """current_pr extracts closing issues."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 42,
                        "closingIssuesReferences": [{"number": 10}],
                    }
                ),
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_path, gh_path="/usr/bin/gh")
        pr = client.current_pr()

        assert pr is not None
        assert pr.closing_issues == ["#10"]

    def test_current_pr_with_author(self, mem_path: Path) -> None:
        """current_pr extracts author."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 42,
                        "author": {"login": "contributor1"},
                    }
                ),
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_path, gh_path="/usr/bin/gh")
        pr = client.current_pr()

        assert pr is not None
        assert pr.author == "contributor1"

    def test_current_pr_malformed_data(self, mem_path: Path) -> None:
        """current_pr handles malformed lists gracefully."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 42,
                        "labels": ["not a dict", {"name": "bug"}],
                        "assignees": ["not a dict", {"login": "dev2"}],
                        "closingIssuesReferences": ["not a dict", {"number": 5}],
                    }
                ),
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_path, gh_path="/usr/bin/gh")
        pr = client.current_pr()

        assert pr is not None
        assert pr.labels == ["bug"]
        assert pr.assignees == ["dev2"]
        assert pr.closing_issues == ["#5"]


class TestGhClientUserStory:
    """Test user story fetching in issue_details."""

    def test_issue_details_with_user_story_link(self, mem_path: Path) -> None:
        """issue_details extracts user story link from body."""
        # Create a local user story file
        story_path = (
            mem_path / "docs" / "features" / "active" / "test" / "user-story.md"
        )
        story_path.parent.mkdir(parents=True)
        story_path.write_text("# User Story Content", encoding="utf-8")

        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 1,
                        "title": "Feature request",
                        "body": (
                            "## User Story\n"
                            "[user-story.md](docs/features/active/test/user-story.md)"
                        ),
                    }
                ),
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_path, gh_path="/usr/bin/gh")
        details = client.issue_details("1")

        assert details.user_story_path == "docs/features/active/test/user-story.md"
        assert details.user_story_content == "# User Story Content"

    def test_issue_details_user_story_remote_fetch(self, mem_path: Path) -> None:
        """issue_details fetches user story from remote when not local."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 1,
                        "title": "Feature",
                        "body": (
                            "[user-story.md](docs/features/active/test/user-story.md)"
                        ),
                    }
                ),
                "",
                0,
            ),
            CommandResult(
                json.dumps(
                    {"content": "IyBSZW1vdGUgVXNlciBTdG9yeQ=="}
                ),  # base64 "# Remote User Story"
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_path, gh_path="/usr/bin/gh")
        details = client.issue_details("1")

        assert details.user_story_path == "docs/features/active/test/user-story.md"
        assert details.user_story_content == "# Remote User Story"


class TestGhClientPrDetailsError:
    """Test error handling in pr_details."""

    def test_pr_details_raises_on_no_repo(self, mem_path: Path) -> None:
        """pr_details raises when repo unavailable."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult("invalid", "", 0),  # Bad JSON
        ]

        client = GhClient(runner, mem_path, gh_path="/usr/bin/gh")

        with pytest.raises(RuntimeError, match="failed to resolve repository"):
            client.pr_details("1")

    def test_pr_details_raises_on_bad_payload(self, mem_path: Path) -> None:
        """pr_details raises on non-dict payload."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult("[]", "", 0),  # Array instead of object
        ]

        client = GhClient(runner, mem_path, gh_path="/usr/bin/gh")

        with pytest.raises(RuntimeError, match="Unexpected pull request payload"):
            client.pr_details("1")


class TestGhClientFilesChanged:
    """Test files_changed extraction in pr_details."""

    def test_pr_details_extracts_files(self, mem_path: Path) -> None:
        """pr_details extracts files changed list."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 1,
                        "files": [
                            {"path": "src/main.py"},
                            {"path": "tests/test_main.py"},
                        ],
                    }
                ),
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_path, gh_path="/usr/bin/gh")
        details = client.pr_details("1")

        assert details.files_changed == ["src/main.py", "tests/test_main.py"]


class TestGhClientCommentEdgeCases:
    """Test edge cases in comment extraction."""

    def test_issue_details_comment_without_user(self, mem_path: Path) -> None:
        """issue_details handles comments without user field."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 1,
                        "comments_url": "https://api.github.com/repos/owner/repo/issues/1/comments",
                    }
                ),
                "",
                0,
            ),
            CommandResult(
                json.dumps(
                    [
                        {
                            "body": "Comment without user",
                            "created_at": "2024-01-01T00:00:00Z",
                        }
                    ]
                ),
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_path, gh_path="/usr/bin/gh")
        details = client.issue_details("1")

        assert len(details.comments) == 1
        assert "(unknown)" in details.comments[0]

    def test_issue_details_comment_malformed_entries(self, mem_path: Path) -> None:
        """issue_details skips malformed comment entries."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 1,
                        "comments_url": "https://api.github.com/repos/owner/repo/issues/1/comments",
                    }
                ),
                "",
                0,
            ),
            CommandResult(
                json.dumps(
                    [
                        "not a dict",  # Should be skipped
                        {"body": "Good comment", "user": {"login": "user1"}},
                    ]
                ),
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_path, gh_path="/usr/bin/gh")
        details = client.issue_details("1")

        assert len(details.comments) == 1
        assert "user1" in details.comments[0]
