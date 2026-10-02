"""GitHub CLI adapter seam for potential-to-issue promotion."""

from __future__ import annotations

import shutil
import subprocess
from dataclasses import dataclass
from typing import Protocol

FEATURE_LABEL_COLOR = "0e8a16"
FEATURE_LABEL_DESCRIPTION = "Feature work"


@dataclass
class GhResult:
    """Capture gh command execution output and exit status.

    Purpose:
        Provide a typed transport object for gh subprocess results used by promotion
        workflows.

    Usage:
        Created by gh client implementations and consumed by promotion logic.

    Flow:
        Store output lines and integer exit code from a single gh invocation.

    Invariants / Constraints:
        `exit_code` is the process return code for the related command.

    Side Effects:
        None.

    Attributes:
        output (list[str]): Combined stdout/stderr lines from gh command execution.
        exit_code (int): Process return code from the gh command.
    """

    output: list[str]
    exit_code: int


class GhClient(Protocol):
    def is_authenticated(self) -> bool: ...

    def issue_create(self, title: str, body: str, promotion_type: str) -> GhResult: ...

    def ensure_label(self, label: str) -> GhResult: ...

    def issue_view(self, issue_number: str) -> GhResult: ...


@dataclass
class RealGhClient(GhClient):
    """Invoke the GitHub CLI and translate results into typed records.

    Purpose:
        Provide the concrete gh-backed implementation for issue creation/view flows.

    Usage:
        Instantiated by `promote_potential` unless a fake client is injected.

    Flow:
        Resolve `gh` path, validate authentication, execute commands, and return
        `GhResult` payloads.

    Invariants / Constraints:
        `gh_path` must resolve to an executable before command execution.

    Side Effects:
        Executes subprocess calls to the local `gh` CLI.

    Attributes:
        gh_path (str | None): Resolved gh executable path.
    """

    gh_path: str | None = None

    def __post_init__(self) -> None:
        if self.gh_path is None:
            self.gh_path = shutil.which("gh")
        if not self.gh_path:
            raise FileNotFoundError(
                "gh CLI not found on PATH. Install gh and authenticate first."
            )

    def is_authenticated(self) -> bool:
        """Check if gh CLI is authenticated by running gh auth status."""
        gh_exe = self.gh_path
        if gh_exe is None:
            return False

        result = subprocess.run(  # noqa: S603 - static analysis can't verify runtime validation
            [gh_exe, "auth", "status"],
            capture_output=True,
            check=False,
        )
        return result.returncode == 0

    def _run(self, args: list[str], body: str | None = None) -> GhResult:
        gh_exe = self.gh_path
        if gh_exe is None:
            raise RuntimeError("gh CLI path was not resolved")

        proc: subprocess.CompletedProcess[str] = (
            subprocess.run(  # noqa: S603 - static analysis can't verify runtime validation
                [gh_exe, *args],
                input=body,
                text=True,
                encoding="utf-8",
                capture_output=True,
                check=False,
            )
        )
        stdout = proc.stdout or ""
        stderr = proc.stderr or ""
        combined = stdout + stderr
        return GhResult(output=combined.splitlines(), exit_code=int(proc.returncode))

    def issue_create(self, title: str, body: str, promotion_type: str) -> GhResult:
        args = [
            "issue",
            "create",
            "--title",
            title,
            "--body-file",
            "-",
            "--label",
            promotion_type,
        ]
        return self._run(args, body)

    def ensure_label(self, label: str) -> GhResult:
        """Ensure a GitHub label exists before retrying issue creation."""
        args = [
            "label",
            "create",
            label,
            "--color",
            FEATURE_LABEL_COLOR,
            "--description",
            FEATURE_LABEL_DESCRIPTION,
        ]
        return self._run(args)

    def issue_view(self, issue_number: str) -> GhResult:
        args = [
            "issue",
            "view",
            issue_number,
            "--json",
            "number,title,url,author,updatedAt",
        ]
        return self._run(args)
