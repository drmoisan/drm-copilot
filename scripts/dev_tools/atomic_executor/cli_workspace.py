"""Workspace, argument parsing, and clipboard helpers for atomic executor CLI."""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

DEFAULT_PROMPT_TEMPLATE = ".github/prompts/execute-plan-template.md"
PROTECTED_BRANCHES = {"main", "master", "development"}
EXECUTOR_LOCK_FILE = ".agent_logs/executor.lock"
EXECUTOR_LOCK_BYPASS_ENV = "ATOMIC_EXECUTOR_SKIP_LOCK"


def parse_args(argv: list[str]) -> argparse.Namespace:
    """Parse CLI arguments."""
    p = argparse.ArgumentParser(description="Atomic task-by-task executor.")
    sub = p.add_subparsers(dest="cmd", required=True)

    def add_common(sp: argparse.ArgumentParser) -> None:
        sp.add_argument("path", help="Feature folder path OR a plan.md path.")
        sp.add_argument(
            "--workspace",
            default=None,
            help="Repo root (defaults to auto-detect).",
        )
        sp.add_argument(
            "--feature",
            default=None,
            help="Feature folder name under docs/features/active (optional).",
        )
        sp.add_argument(
            "--prompt-template",
            default=DEFAULT_PROMPT_TEMPLATE,
            help="Prompt template path.",
        )
        sp.add_argument(
            "--start",
            default=None,
            help="Start at a specific task id like P2-T3.",
        )
        sp.add_argument(
            "--max-fix-attempts",
            type=int,
            default=2,
            help="Retries for current task if QC fails.",
        )
        sp.add_argument(
            "--print-prompt",
            action="store_true",
            help="Print resolved prompt for current task and exit.",
        )
        sp.add_argument(
            "--copy-prompt",
            action="store_true",
            help="Copy resolved prompt to clipboard (and exit).",
        )
        sp.add_argument(
            "--preferred-model",
            default=None,
            help=(
                "Preferred AI model (Copilot CLI --model value or display name), "
                "e.g. 'gpt-5.1-codex-max' or 'Claude Sonnet 4.5'."
            ),
        )

        sp.add_argument(
            "--copilot-cli-max-calls-per-window",
            type=int,
            default=6,
            help=(
                "Max Copilot CLI calls per time window "
                "(call-rate based; not token based)."
            ),
        )
        sp.add_argument(
            "--copilot-cli-window-seconds",
            type=float,
            default=60.0,
            help="Window size in seconds for call-rate limiting.",
        )
        sp.add_argument(
            "--copilot-cli-backoff-base-seconds",
            type=float,
            default=2.0,
            help="Base seconds for exponential backoff after throttling.",
        )
        sp.add_argument(
            "--copilot-cli-backoff-max-seconds",
            type=float,
            default=60.0,
            help="Maximum seconds for exponential backoff cap after throttling.",
        )
        sp.add_argument(
            "--copilot-cli-output-tail-bytes",
            type=int,
            default=4096,
            help=(
                "Number of Copilot output bytes to retain as an in-memory tail for "
                "throttling classification and error messages."
            ),
        )
        sp.add_argument(
            "--copilot-cli-max-retries",
            type=int,
            default=8,
            help="Max throttle-triggered retries per atomic task (bounded by default).",
        )

        sp.add_argument(
            "--copilot-allow-shell",
            action=argparse.BooleanOptionalAction,
            default=True,
            help=(
                "Allow all shell commands without approval (adds --allow-tool shell)."
            ),
        )
        sp.add_argument(
            "--copilot-allow-all-paths",
            action=argparse.BooleanOptionalAction,
            default=True,
            help=("Allow Copilot CLI to access any path without per-path approvals."),
        )
        sp.add_argument(
            "--copilot-allow-all-urls",
            action=argparse.BooleanOptionalAction,
            default=False,
            help=("Allow Copilot CLI to access any URL without per-URL approvals."),
        )
        sp.add_argument(
            "--copilot-trust-workspace",
            action=argparse.BooleanOptionalAction,
            default=True,
            help=("Ensure the workspace is listed in Copilot CLI trusted_folders."),
        )
        sp.add_argument(
            "--skip-preflight-qc",
            action="store_true",
            default=False,
            help=(
                "Skip the pre-flight QC check that runs before task execution. "
                "By default, execute-all runs a full QC and invokes Copilot to fix "
                "any baseline failures before proceeding."
            ),
        )

    sp_exec = sub.add_parser("execute", help="Execute from first unchecked or --start.")
    add_common(sp_exec)

    sp_resume = sub.add_parser("resume", help="Resume from first unchecked task.")
    add_common(sp_resume)

    sp_all = sub.add_parser("execute-all", help="Execute all remaining tasks.")
    add_common(sp_all)

    return p.parse_args(argv)


def resolve_workspace(workspace_arg: str | None) -> Path:
    """Resolve workspace root directory."""
    if workspace_arg:
        return Path(workspace_arg).resolve()

    return Path(__file__).resolve().parents[3]


def acquire_executor_lock(workspace: Path) -> Path:
    """Acquire the single-run lock to prevent concurrent executor sessions."""
    lock_path = workspace / EXECUTOR_LOCK_FILE
    lock_path.parent.mkdir(parents=True, exist_ok=True)

    if os.getenv(EXECUTOR_LOCK_BYPASS_ENV) == "1" or os.getenv("PYTEST_CURRENT_TEST"):
        return lock_path

    if lock_path.exists():
        raise RuntimeError(
            f"Atomic executor lock already exists: {lock_path.as_posix()}"
        )

    lock_path.write_text("atomic_executor_lock\n", encoding="utf-8")
    return lock_path


def release_executor_lock(lock_path: Path) -> None:
    """Release the single-run lock file if it exists."""
    if lock_path.exists():
        lock_path.unlink()


def ensure_clean_tree(workspace: Path) -> None:
    """Verify working tree is clean (no uncommitted changes)."""
    git_exe = shutil.which("git")
    if not git_exe:
        raise FileNotFoundError("Required executable not found on PATH: git")

    result = subprocess.run(  # noqa: S603
        [git_exe, "status", "--porcelain"],
        cwd=workspace,
        capture_output=True,
        text=True,
        errors="replace",
        check=True,
    )
    if result.stdout.strip():
        raise RuntimeError("Working tree is not clean. Commit/stash before running.")


def refuse_protected_branch(workspace: Path) -> None:
    """Refuse execution on protected branches."""
    branch = _current_branch(workspace)
    if branch and branch in PROTECTED_BRANCHES:
        raise RuntimeError(f"Refusing to run on protected branch '{branch}'.")


def _current_branch(workspace: Path) -> str | None:
    """Get current git branch name, or None if error."""
    git_exe = shutil.which("git")
    if not git_exe:
        return None

    try:
        result = subprocess.run(  # noqa: S603
            [git_exe, "rev-parse", "--abbrev-ref", "HEAD"],
            cwd=workspace,
            capture_output=True,
            text=True,
            errors="replace",
            check=True,
        )
        b = result.stdout.strip()
        return b or None
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def get_clipboard_command() -> list[str] | None:
    """Detect the correct clipboard command for the current platform."""
    if sys.platform == "win32":
        candidates: list[list[str]] = [["clip"]]
    elif sys.platform == "darwin":
        candidates = [["pbcopy"]]
    else:
        is_wsl = False
        try:
            with open("/proc/version") as f:
                if "microsoft" in f.read().lower():
                    is_wsl = True
        except FileNotFoundError:
            pass

        if is_wsl:
            candidates = [
                ["clip.exe"],
                ["pbcopy"],
                ["wl-copy"],
                ["xclip", "-selection", "clipboard"],
                ["xsel", "--clipboard", "--input"],
            ]
        else:
            candidates = [
                ["wl-copy"],
                ["xclip", "-selection", "clipboard"],
                ["xsel", "--clipboard", "--input"],
            ]

    for cmd in candidates:
        if shutil.which(cmd[0]):
            return cmd

    return None


def copy_to_clipboard(text: str) -> bool:
    """Copy text to system clipboard using platform-appropriate command."""

    def _try_pyperclip_copy() -> bool:
        try:
            import pyperclip  # type: ignore[import-untyped]
        except ImportError:
            return False

        try:
            pyperclip.copy(text)
            return True
        except Exception:
            return False

    if _try_pyperclip_copy():
        return True

    cmd = get_clipboard_command()
    if not cmd:
        return False

    exe = shutil.which(cmd[0])
    if not exe:
        return False

    try:
        subprocess.run(  # noqa: S603
            [exe, *cmd[1:]],
            input=text,
            text=True,
            errors="replace",
            check=True,
        )
        return True
    except subprocess.CalledProcessError:
        return False
