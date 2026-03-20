"""Resolve the execute-hard-lock prompt with the plan file path.

Purpose:
    This helper resolves the active plan file path from the target file,
    substitutes the ${plan-path} variable into the execute-hard-lock.prompt.md
    template, prints the result, and attempts to copy it to the clipboard for
    pasting into Copilot Chat.

Supported variables:
    - ${plan-path}: Workspace-relative path to the target plan file (forward
      slashes).

Usage:
    python resolve_hard_lock_prompt.py --target <path_to_plan_file>
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

from scripts.dev_tools.prompt_mode_contract import (
    build_fallback_reason,
    resolve_selected_work_mode,
)


def _resolve_template_name(template_kind: str) -> str:
    """Map the CLI template-kind flag to a concrete template filename.

    Purpose:
        Keeps filename selection centralized so both root and bundled callers
        resolve the same prompt asset names for `execute` and `resume` flows.

    Args:
        template_kind: CLI selector constrained to `execute` or `resume`.

    Returns:
        str: The prompt filename associated with the requested template kind.

    Side Effects:
        None.
    """
    return (
        "execute-hard-lock.prompt.md"
        if template_kind == "execute"
        else "resume-hard-lock.prompt.md"
    )


def _resolve_template_path(
    template_name: str,
    workspace_root: Path,
    template_root: Path | None,
) -> tuple[Path | None, tuple[Path, ...]]:
    """Resolve the first available prompt template path in deterministic order.

    Purpose:
        Supports bundled extension resources by checking an explicit template
        root first while preserving the existing workspace `.github/codex`
        fallback for repo-root usage.

    Args:
        template_name: Prompt filename to resolve.
        workspace_root: Workspace root used for repo-local fallback lookup.
        template_root: Optional explicit template directory to probe first.

    Returns:
        tuple[Path | None, tuple[Path, ...]]: The selected template path when
        found, plus the ordered list of checked candidate paths.

    Side Effects:
        None.
    """
    candidates: list[Path] = []
    if template_root is not None:
        candidates.append(template_root / template_name)
    candidates.append(workspace_root / ".github" / "codex" / template_name)

    # Probe the explicit template root before the workspace fallback so bundled
    # extension resources stay authoritative when they are intentionally passed.
    for candidate in candidates:
        if candidate.exists():
            return candidate, tuple(candidates)

    return None, tuple(candidates)


def copy_to_clipboard(text: str) -> bool:
    """Attempt to copy text to the clipboard using common tools.

    Purpose:
        Provides cross-platform clipboard support using either pyperclip
        (if installed) or native system clipboard commands.

    Args:
        text: The text to copy to the clipboard.

    Returns:
        True on success, False if no supported clipboard mechanism is found.

    Side Effects:
        Writes to the system clipboard.
        Prints error to stderr if pyperclip fails.
    """
    try:
        import pyperclip  # type: ignore[import-untyped]
    except ImportError:
        pyperclip = None  # type: ignore[assignment]

    pyperclip_error: Exception | None = None
    if pyperclip is not None:
        try:
            pyperclip.copy(text)
            return True
        except Exception as error:  # noqa: BLE001 - CLI top-level error handling
            pyperclip_error = error

    # Fallback chain: try common clipboard commands across platforms
    commands: tuple[list[str], ...] = (
        ["pbcopy"],  # macOS
        ["wl-copy"],  # Wayland
        ["xclip", "-selection", "clipboard"],  # X11
        ["xsel", "--clipboard", "--input"],  # X11 alternative
        ["clip"],  # Windows
        ["clip.exe"],  # WSL
    )

    for command in commands:
        executable = shutil.which(command[0])
        if executable is None:
            continue
        try:
            # S603: validated above via shutil.which
            subprocess.run(  # noqa: S603 - static analysis can't verify runtime validation
                [executable, *command[1:]],
                input=text,
                text=True,
                check=True,
            )
            return True
        except subprocess.CalledProcessError:
            continue

    if pyperclip_error is not None:
        print(f"pyperclip copy failed: {pyperclip_error}", file=sys.stderr)

    return False


def _try_relative_to_workspace(path: Path, workspace_root: Path) -> Path:
    """Return path relative to workspace_root when possible.

    Args:
        path: The path to make relative.
        workspace_root: The workspace root directory.

    Returns:
        The relative path if possible, otherwise the original path.
    """
    try:
        return path.resolve().relative_to(workspace_root.resolve())
    except ValueError:
        return path


def _normalize_prompt_path_value(path: Path) -> str:
    """Convert a resolved prompt path into forward-slash form.

    Purpose:
        `Path.as_posix()` only normalizes native separators for the active
        platform. When a Windows-style path string is parsed on POSIX, the
        embedded backslashes remain literal characters and leak into prompt
        templates. This helper normalizes any remaining backslashes so the
        emitted `${plan-path}` value is stable across CI platforms.

    Args:
        path: Relative or absolute prompt path value to normalize.

    Returns:
        str: Forward-slash-only path text suitable for prompt substitution.

    Side Effects:
        None.
    """
    return str(path).replace("\\", "/")


def _resolve_issue_file_for_target(target_path: Path, workspace_root: Path) -> Path:
    """Resolve the most likely issue.md path for a target plan file.

    Purpose:
        Hard-lock prompts are usually generated from a plan file located in a
        feature folder (or a version subfolder like `v2`). This helper selects
        the nearest deterministic `issue.md` candidate.

    Args:
        target_path: Path to the target plan file.
        workspace_root: Workspace root for normalization.

    Returns:
        Path: Candidate issue.md path to parse for work-mode marker.
    """
    relative_target = _try_relative_to_workspace(target_path, workspace_root)
    plan_dir = relative_target.parent
    direct_issue = workspace_root / plan_dir / "issue.md"
    if direct_issue.exists():
        return direct_issue

    if plan_dir.name.startswith("v") and len(plan_dir.parts) >= 2:
        parent_issue = workspace_root / plan_dir.parent / "issue.md"
        if parent_issue.exists():
            return parent_issue

    return direct_issue


def _resolve_work_mode_from_issue(
    target_path: Path, workspace_root: Path
) -> tuple[str, str]:
    """Resolve selected work mode from issue.md with fail-closed behavior.

    Purpose:
        Enforce deterministic mode selection for prompt templates by reading the
        persisted issue marker first and failing closed to `full-feature` on
        missing or malformed data.

    Args:
        target_path: Target plan file path.
        workspace_root: Workspace root for path resolution.

    Returns:
        tuple[str, str]: Selected mode and fallback reason text.
    """
    issue_path = _resolve_issue_file_for_target(target_path, workspace_root)
    if not issue_path.exists():
        return resolve_selected_work_mode(None), build_fallback_reason(None)

    try:
        issue_content = issue_path.read_text(encoding="utf-8")
    except OSError:
        return (
            resolve_selected_work_mode(None),
            "issue.md unreadable; fail closed to full-feature",
        )

    return resolve_selected_work_mode(issue_content), build_fallback_reason(
        issue_content
    )


def resolve_prompt(
    template_content: str,
    target_path: Path,
    workspace_root: Path,
    *,
    work_mode: str | None = None,
    fallback_reason: str | None = None,
) -> str:
    """Resolve ${plan-path} in the template with the target file path.

    Purpose:
        Substitutes the ${plan-path} variable with the workspace-relative path
        to the target file, using forward slashes for consistency.

    Args:
        template_content: The raw template content containing ${plan-path}.
        target_path: The path to the plan file.
        workspace_root: The workspace root directory.

    Returns:
        The resolved template with ${plan-path} replaced.

    Side Effects:
        None. Pure function.
    """
    # Resolve target path relative to workspace
    relative_target = _try_relative_to_workspace(target_path, workspace_root)

    # Convert to forward slashes for cross-platform consistency, including
    # Windows-style paths that may be parsed on non-Windows runners.
    plan_path_value = _normalize_prompt_path_value(relative_target)

    selected_mode, resolved_fallback_reason = _resolve_work_mode_from_issue(
        target_path,
        workspace_root,
    )
    mode_value = work_mode if work_mode is not None else selected_mode
    fallback_value = (
        fallback_reason if fallback_reason is not None else resolved_fallback_reason
    )

    # Substitute variables.
    resolved = template_content.replace("${plan-path}", plan_path_value)
    resolved = resolved.replace("${work-mode}", mode_value)
    resolved = resolved.replace("${fallback-reason}", fallback_value)

    return resolved


def main() -> int:
    """Main CLI entry point.

    Returns:
        Exit code: 0 on success, 1 on error.

    Side Effects:
        Reads files, writes to clipboard, prints to stdout/stderr.
    """
    parser = argparse.ArgumentParser(
        description="Resolve execute-hard-lock prompt with plan file path"
    )
    parser.add_argument(
        "--target",
        type=Path,
        required=True,
        help="Path to the plan file",
    )
    parser.add_argument(
        "--workspace",
        type=Path,
        default=None,
        help="Workspace root directory (default: current working directory)",
    )
    parser.add_argument(
        "--template-kind",
        choices=("execute", "resume"),
        default="execute",
        help="Hard-lock template kind to resolve.",
    )
    parser.add_argument(
        "--template-root",
        type=Path,
        default=None,
        help="Optional directory containing hard-lock prompt templates.",
    )

    args = parser.parse_args()

    # Determine workspace root
    workspace_root = args.workspace if args.workspace else Path.cwd()

    # Locate the template file selected by --template-kind.
    template_name = _resolve_template_name(args.template_kind)
    template_path, checked_paths = _resolve_template_path(
        template_name,
        workspace_root,
        args.template_root,
    )

    if template_path is None:
        checked_paths_text = "\n".join(f"- {candidate}" for candidate in checked_paths)
        print(
            "Error: Template "
            f"'{template_name}' not found. Checked locations:\n{checked_paths_text}",
            file=sys.stderr,
        )
        return 1

    if not args.target.exists():
        print(f"Error: Target file not found at {args.target}", file=sys.stderr)
        return 1

    # Read template
    try:
        template_content = template_path.read_text(encoding="utf-8")
    except OSError as error:
        print(f"Error reading template: {error}", file=sys.stderr)
        return 1

    # Resolve the prompt
    resolved_prompt = resolve_prompt(template_content, args.target, workspace_root)

    # Print the resolved prompt
    print(resolved_prompt)

    # Attempt to copy to clipboard
    if copy_to_clipboard(resolved_prompt):
        print("\n✓ Copied to clipboard", file=sys.stderr)
    else:
        print(
            "\n✗ Could not copy to clipboard (no supported mechanism found)",
            file=sys.stderr,
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
