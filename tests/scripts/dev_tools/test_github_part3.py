"""Unit tests for scripts.dev_tools.pr_context.github module.

Focused on driving coverage of key uncovered paths.
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING
from unittest.mock import Mock

from scripts.dev_tools.pr_context.git import CommandRunner
from scripts.dev_tools.pr_context.github import GhClient
from scripts.dev_tools.pr_context.models import CommandResult

if TYPE_CHECKING:
    from pathlib import Path


class TestGhClientLabelAssigneeEdgeCases:
    """Test edge cases in label/assignee extraction."""

    def test_pr_details_malformed_labels(self, mem_fs_path: Path) -> None:
        """pr_details handles malformed label entries."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 1,
                        "labels": [
                            "not a dict",  # Should be skipped
                            {"name": "bug"},
                            {"no_name_field": "value"},  # Should be skipped
                        ],
                    }
                ),
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        details = client.pr_details("1")

        assert details.labels == ["bug"]

    def test_pr_details_malformed_assignees(self, mem_fs_path: Path) -> None:
        """pr_details handles malformed assignee entries."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 1,
                        "assignees": [
                            "not a dict",
                            {"login": "dev1"},
                            {"no_login_field": "value"},
                        ],
                    }
                ),
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        details = client.pr_details("1")

        assert details.assignees == ["dev1"]

    def test_pr_details_closing_issues_malformed(self, mem_fs_path: Path) -> None:
        """pr_details handles malformed closing issues."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 1,
                        "closingIssuesReferences": [
                            "not a dict",
                            {"number": 5},
                            {"no_number": "value"},
                        ],
                    }
                ),
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        details = client.pr_details("1")

        assert details.closing_issues == ["#5"]

    def test_pr_details_author_extraction(self, mem_fs_path: Path) -> None:
        """pr_details extracts author login."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 1,
                        "author": {"login": "contributor1"},
                    }
                ),
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        details = client.pr_details("1")

        assert details.author == "contributor1"

    def test_issue_details_malformed_labels(self, mem_fs_path: Path) -> None:
        """issue_details handles malformed label entries."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 1,
                        "labels": [
                            "not a dict",
                            {"name": "bug"},
                        ],
                    }
                ),
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        details = client.issue_details("1")

        assert details.labels == ["bug"]

    def test_issue_details_malformed_assignees(self, mem_fs_path: Path) -> None:
        """issue_details handles malformed assignee entries."""
        runner = Mock(spec=CommandRunner)
        runner.run.side_effect = [
            CommandResult("Logged in", "", 0),
            CommandResult('{"nameWithOwner": "owner/repo"}', "", 0),
            CommandResult(
                json.dumps(
                    {
                        "number": 1,
                        "assignees": [
                            "not a dict",
                            {"login": "assignee1"},
                        ],
                    }
                ),
                "",
                0,
            ),
        ]

        client = GhClient(runner, mem_fs_path, gh_path="/usr/bin/gh")
        details = client.issue_details("1")

        assert details.assignees == ["assignee1"]
