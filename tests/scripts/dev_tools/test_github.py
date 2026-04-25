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


class TestGhClientAvailability:
    """Test GhClient availability checks."""

    def test_gh_not_installed(
        self, mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """GhClient marks unavailable when gh binary not found."""
        monkeypatch.setattr("shutil.which", lambda x: None)  # type: ignore[arg-type]
        runner = Mock(spec=CommandRunner)

        client = GhClient(runner, mem_fs_path, gh_path=None)

        assert not client.available
        # When unavailable, status_message is None
        assert client.status_message is None

    def test_gh_not_authenticated(self, mem_fs_path: Path) -> None:
        """GhClient marks unavailable when auth fails."""
        runner = Mock(spec=CommandRunner)
        runner.run.return_value = CommandResult("", "not logged in", 1)

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")

        assert not client.available
        # When unavailable, status_message is None
        assert client.status_message is None

    def test_gh_available_success(self, mem_fs_path: Path) -> None:
        """GhClient marks available when fully configured."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),  # auth status
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),  # repo view
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")

        assert client.available
        assert client.status_message == "GitHub CLI authenticated for owner/repo"

    def test_ensure_available_raises(
        self, mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """ensure_available raises when not available."""
        monkeypatch.setattr("shutil.which", lambda x: None)  # type: ignore[arg-type]
        runner = Mock(spec=CommandRunner)

        client = GhClient(runner, mem_fs_path, gh_path=None)

        with pytest.raises(RuntimeError):
            client.ensure_available()

    def test_repo_name_caching(self, mem_fs_path: Path) -> None:
        """status_message caches repo name."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")

        # Status message includes repo name
        msg = client.status_message
        assert msg and "owner/repo" in msg

    def test_repo_name_returns_none_on_invalid_json(self, mem_fs_path: Path) -> None:
        """GhClient handles invalid JSON from repo view."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),  # auth status
            CommandResult("invalid", "", 0),  # Invalid JSON from repo view (init)
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")

        # Client should mark unavailable when repo resolution fails
        assert not client.available


class TestGhClientClassifyEntity:
    """Test entity classification."""

    def test_classify_as_issue(self, mem_fs_path: Path) -> None:
        """classify_entity returns 'issue' for issues."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult('{"number": 1}', "", 0),  # classify call
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        result = client.classify_entity("1")

        assert result == "issue"

    def test_classify_as_pull(self, mem_fs_path: Path) -> None:
        """classify_entity returns 'pull' when pull_request key present."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult('{"number": 1, "pull_request": {}}', "", 0),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        result = client.classify_entity("1")

        assert result == "pull"

    def test_classify_not_found(self, mem_fs_path: Path) -> None:
        """classify_entity returns None when entity not found."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult("", "404 Not Found", 1),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        result = client.classify_entity("999")

        assert result is None


class TestGhClientClosingIssues:
    """Test closing_issues method."""

    def test_closing_issues_returns_list(self, mem_fs_path: Path) -> None:
        """closing_issues extracts issue numbers."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps({"closingIssuesReferences": [{"number": 5}]}), "", 0
            ),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        issues = client.closing_issues()

        assert issues == ["#5"]

    def test_closing_issues_empty(self, mem_fs_path: Path) -> None:
        """closing_issues returns empty list when no issues."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(json.dumps({"closingIssuesReferences": []}), "", 0),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        issues = client.closing_issues()

        assert issues == []


class TestGhClientIssueDetails:
    """Test issue_details method."""

    def test_issue_details_minimal(self, mem_fs_path: Path) -> None:
        """issue_details handles minimal payload."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(json.dumps({"number": 1}), "", 0),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        details = client.issue_details("1")

        assert details.number == "#1"
        assert details.title == "(no title)"

    def test_issue_details_with_labels(self, mem_fs_path: Path) -> None:
        """issue_details extracts labels."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps({"number": 1, "labels": [{"name": "bug"}]}), "", 0
            ),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        details = client.issue_details("1")

        assert details.labels == ["bug"]


class TestGhClientPrDetails:
    """Test pr_details method."""

    def test_pr_details_basic(self, mem_fs_path: Path) -> None:
        """pr_details returns PullRequestDetails."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(json.dumps({"number": 1, "title": "Test"}), "", 0),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        details = client.pr_details("1")

        assert details.number == "#1"
        assert details.title == "Test"


class TestGhClientCurrentPr:
    """Test current_pr method."""

    def test_current_pr_not_available(
        self, mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """current_pr returns None when gh not available."""
        monkeypatch.setattr("shutil.which", lambda x: None)  # type: ignore[arg-type]
        runner = Mock(spec=CommandRunner)

        client = GhClient(runner, mem_fs_path, gh_path=None)
        pr = client.current_pr()

        assert pr is None

    def test_current_pr_no_pr(self, mem_fs_path: Path) -> None:
        """current_pr returns None when no PR active."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult("", "no pull request", 1),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        pr = client.current_pr()

        assert pr is None


class TestGhClientFetchRepoFile:
    """Test fetch_repo_file method."""

    def test_fetch_repo_file_success(self, mem_fs_path: Path) -> None:
        """fetch_repo_file decodes content."""
        import base64

        content = "test content"
        encoded = base64.b64encode(content.encode()).decode()

        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(json.dumps({"content": encoded}), "", 0),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        result = client.fetch_repo_file("test.txt")

        assert result == content

    def test_fetch_repo_file_not_found(self, mem_fs_path: Path) -> None:
        """fetch_repo_file returns None when file not found."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult("", "404", 1),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        result = client.fetch_repo_file("missing.txt")

        assert result is None


class TestGhClientCiStatus:
    """Test ci_status method."""

    def test_ci_status_returns_status(self, mem_fs_path: Path) -> None:
        """ci_status extracts status from runs."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(json.dumps([{"status": "success"}]), "", 0),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        status, _ = client.ci_status("abc123")

        assert status == "success"

    def test_ci_status_empty_runs(self, mem_fs_path: Path) -> None:
        """ci_status returns None when no runs."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(json.dumps([]), "", 0),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        status, _ = client.ci_status("abc123")

        assert status is None


class TestGhClientIssueDetailsExtended:
    """Extended tests for issue_details covering comments and edge cases."""

    def test_issue_details_with_comments(self, mem_fs_path: Path) -> None:
        """issue_details extracts comments."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 1,
                        "title": "Test",
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
                            "user": {"login": "testuser"},
                            "created_at": "2024-01-01T00:00:00Z",
                            "body": "Test comment",
                        }
                    ]
                ),
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        details = client.issue_details("1")

        assert len(details.comments) == 1
        assert "testuser" in details.comments[0]
        assert "Test comment" in details.comments[0]

    def test_issue_details_with_body(self, mem_fs_path: Path) -> None:
        """issue_details extracts body text."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(json.dumps({"number": 1, "body": "Issue body text"}), "", 0),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        details = client.issue_details("1")

        assert details.body == "Issue body text"

    def test_issue_details_with_assignees(self, mem_fs_path: Path) -> None:
        """issue_details extracts assignees."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps({"number": 1, "assignees": [{"login": "user1"}]}), "", 0
            ),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        details = client.issue_details("1")

        assert details.assignees == ["user1"]


class TestGhClientPrDetailsExtended:
    """Extended tests for pr_details."""

    def test_pr_details_with_all_fields(self, mem_fs_path: Path) -> None:
        """pr_details extracts all available fields."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 1,
                        "title": "Test PR",
                        "body": "PR body",
                        "state": "open",
                        "headRefName": "feature-branch",
                        "baseRefName": "main",
                        "labels": [{"name": "bug"}],
                        "assignees": [{"login": "dev1"}],
                    }
                ),
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        details = client.pr_details("1")

        assert details.number == "#1"
        assert details.title == "Test PR"
        assert details.body == "PR body"
        assert details.state == "open"
        assert details.head_ref == "feature-branch"
        assert details.base_ref == "main"
        assert details.labels == ["bug"]
        assert details.assignees == ["dev1"]
