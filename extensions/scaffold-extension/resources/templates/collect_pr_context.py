"""Collect substantive PR context artifacts for extension-side execution.

Purpose:
    Generate destination-workspace PR context artifacts that include meaningful
    git comparison details rather than placeholder-only output.

Usage:
    The scaffold extension invokes this bundled script from the destination
    repository root with `--base`, `--out`, and `--appendix-out`.

Flow:
    1. Resolve and validate git executable/runtime inputs.
    2. Resolve base/head SHAs and merge-base range.
    3. Collect repository status, changed files, and diff summaries.
    4. Render summary + appendix artifacts and write both outputs.

Invariants / Constraints:
    - CLI flags `--base`, `--out`, and `--appendix-out` are preserved.
    - Unrecoverable git/data failures return non-zero and emit stderr details.

Side Effects:
    Executes git subprocess commands and writes UTF-8 artifact files.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path


def write_text(path: Path, content: str) -> None:
    """Write UTF-8 text to a destination artifact path.

    Purpose:
        Persist rendered artifact content to a deterministic destination.

    Args:
        path: Filesystem destination for the artifact.
        content: Text content to write.

    Returns:
        None.

    Side Effects:
        Creates parent directories and writes to disk.
    """
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def run_git(args: list[str], allow_error: bool = False) -> str:
    """Run a git command and return normalized stdout.

    Purpose:
        Centralize git execution so all command failures are handled
        consistently and surfaced with actionable context.

    Args:
        args: Git subcommand and arguments.
        allow_error: When True, return empty output for non-zero exits.

    Returns:
        The command stdout stripped of trailing whitespace.

    Raises:
        FileNotFoundError: When git is unavailable on PATH.
        subprocess.CalledProcessError: When command fails and allow_error=False.
    """
    git_exe = shutil.which("git")
    if not git_exe:
        raise FileNotFoundError("git executable not found on PATH")

    try:
        result = subprocess.run(  # noqa: S603 - static analysis can't verify runtime validation
            [git_exe, *args],
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            check=not allow_error,
        )
        return (result.stdout or "").strip()
    except subprocess.CalledProcessError as exc:
        if allow_error:
            return (exc.stdout or "").strip()
        raise


def resolve_range(base_ref: str) -> tuple[str, str, str]:
    """Resolve base SHA, head SHA, and merge-base for PR comparison.

    Purpose:
        Compute a deterministic comparison range used for summary and appendix
        rendering across destination-workspace runs.

    Args:
        base_ref: Caller-selected base branch/ref.

    Returns:
        Tuple of `(base_sha, head_sha, merge_base_sha)`.

    Raises:
        subprocess.CalledProcessError: When refs cannot be resolved.
    """
    base_sha = run_git(["rev-parse", base_ref])
    head_sha = run_git(["rev-parse", "HEAD"])
    merge_base_sha = run_git(["merge-base", base_ref, "HEAD"])
    return base_sha, head_sha, merge_base_sha


def build_summary(base_ref: str, base_sha: str, head_sha: str, merge_base: str) -> str:
    """Render the PR-context summary artifact.

    Purpose:
        Produce concise, multi-section context suitable for review prep.

    Args:
        base_ref: Base branch/ref used for comparison.
        base_sha: Resolved base commit SHA.
        head_sha: Resolved HEAD commit SHA.
        merge_base: Resolved merge-base commit SHA.

    Returns:
        Rendered summary text.
    """
    status_short = run_git(["status", "-sb"], allow_error=True) or "(unavailable)"
    changed_files = (
        run_git(["diff", "--name-status", merge_base, head_sha], allow_error=True)
        or "(no changed files in range)"
    )
    diff_stat = (
        run_git(["diff", "--stat", merge_base, head_sha], allow_error=True)
        or "(no diff stat available)"
    )

    summary_sections = [
        "# PR Context Summary",
        "",
        "## Base/Head",
        f"- Base ref (requested): {base_ref}",
        f"- Base SHA: {base_sha}",
        f"- Head SHA: {head_sha}",
        f"- Merge base: {merge_base}",
        f"- Range: {merge_base}..{head_sha}",
        "",
        "## Repository status",
        status_short,
        "",
        "## Changed files (name-status)",
        changed_files,
        "",
        "## Diff stat",
        diff_stat,
    ]
    return "\n".join(summary_sections).rstrip() + "\n"


def build_appendix(base_ref: str, head_sha: str, merge_base: str) -> str:
    """Render the PR-context appendix artifact.

    Purpose:
        Provide expanded technical details backing the summary artifact.

    Args:
        base_ref: Base branch/ref used for comparison.
        head_sha: Resolved HEAD commit SHA.
        merge_base: Resolved merge-base commit SHA.

    Returns:
        Rendered appendix text.
    """
    numstat = (
        run_git(["diff", "--numstat", merge_base, head_sha], allow_error=True)
        or "(no numstat available)"
    )
    full_diff = (
        run_git(["diff", merge_base, head_sha], allow_error=True)
        or "(no diff available)"
    )
    recent_commits = (
        run_git(["log", "--oneline", "--decorate", "-n", "20"], allow_error=True)
        or "(no commit history available)"
    )

    appendix_sections = [
        "# PR Context Appendix",
        "",
        "## Comparison metadata",
        f"- Base ref: {base_ref}",
        f"- Head SHA: {head_sha}",
        f"- Merge base: {merge_base}",
        "",
        "## Numstat",
        numstat,
        "",
        "## Recent commits",
        recent_commits,
        "",
        "## Full diff",
        full_diff,
    ]
    return "\n".join(appendix_sections).rstrip() + "\n"


def collect_pr_context(base_ref: str, summary_out: Path, appendix_out: Path) -> None:
    """Collect and write summary/appendix PR context artifacts.

    Purpose:
        Orchestrate git collection and artifact rendering for extension calls.

    Args:
        base_ref: Base branch/ref selected by the extension command flow.
        summary_out: Destination summary artifact path.
        appendix_out: Destination appendix artifact path.

    Returns:
        None.

    Raises:
        RuntimeError: When generated artifacts are structurally invalid.
        subprocess.CalledProcessError: When required git commands fail.
    """
    base_sha, head_sha, merge_base = resolve_range(base_ref)
    summary_text = build_summary(base_ref, base_sha, head_sha, merge_base)
    appendix_text = build_appendix(base_ref, head_sha, merge_base)

    if len(summary_text.splitlines()) <= 2 or len(appendix_text.splitlines()) <= 2:
        raise RuntimeError(
            "collector produced insufficient PR context content; "
            "refusing placeholder output"
        )

    write_text(summary_out, summary_text)
    write_text(appendix_out, appendix_text)
    print(f"Wrote context summary to: {summary_out}")
    print(f"Wrote context appendix to: {appendix_out}")


def main(argv: list[str] | None = None) -> int:
    """Parse command args and emit PR context artifacts.

    Purpose:
        Provide a stable CLI for extension-side PR context collection.

    Args:
        argv: Optional command-line argument list for testability.

    Returns:
        Process exit code (0 success, non-zero failure).

    Side Effects:
        Writes output artifacts and prints diagnostics to stdout/stderr.
    """
    parser = argparse.ArgumentParser(description="Collect PR context artifacts")
    parser.add_argument("--base", required=True, help="Base branch")
    parser.add_argument(
        "--out",
        type=Path,
        default=Path("artifacts/pr_context.summary.txt"),
        help="Summary output artifact path",
    )
    parser.add_argument(
        "--appendix-out",
        type=Path,
        default=Path("artifacts/pr_context.appendix.txt"),
        help="Appendix output artifact path",
    )
    args = parser.parse_args(argv)

    try:
        collect_pr_context(args.base, args.out, args.appendix_out)
        return 0
    except FileNotFoundError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1
    except subprocess.CalledProcessError as exc:
        stderr_text = (exc.stderr or "").strip()
        cmd_value = exc.cmd
        if isinstance(cmd_value, list):
            cmd_text = "git command list (unparsed)"
        else:
            cmd_text = str(cmd_value)
        print(
            "Error: git command failed "
            f"`{cmd_text}`" + (f"; stderr: {stderr_text}" if stderr_text else ""),
            file=sys.stderr,
        )
        return 1
    except RuntimeError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
