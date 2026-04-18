"""Resolve bundled atomic-plan prompt templates against a target plan file.

Purpose:
    Provide a destination-workspace-safe copy of the repository prompt resolver
    so the extension can resolve `${...}` placeholders from bundled assets
    without depending on repo-local scripts.

Supported variables:
    - `${file}`
    - `${folderpath}`
    - `${name}`
    - `${spec}`
    - `${user-story}`
    - `${research}`
    - `${work-mode}`
    - `${fallback-reason}`
"""

from __future__ import annotations

import argparse
import importlib
import importlib.util
import re
import shutil
import subprocess
import sys
import types
from pathlib import Path

from dev_tools.prompt_mode_contract import (
    build_fallback_reason,
    resolve_selected_work_mode,
)


def _missing_pyperclip_copy(_text: str) -> None:
    """Raise a clear error when optional clipboard support is unavailable."""
    raise RuntimeError(
        "Clipboard support requires the optional 'pyperclip' dependency."
    )


_pyperclip_spec = importlib.util.find_spec("pyperclip")
if _pyperclip_spec is None:
    pyperclip = types.SimpleNamespace(copy=_missing_pyperclip_copy)
else:
    pyperclip = importlib.import_module("pyperclip")


def copy_to_clipboard(text: str) -> bool:
    """Attempt to copy text to the clipboard.

    Purpose:
        Prefer `pyperclip` when available, then fall back to validated native
        clipboard commands so bundled prompt resolution works across common
        desktop environments.

    Args:
        text (str): The text to copy.

    Returns:
        bool: `True` when any clipboard mechanism succeeded; otherwise `False`.

    Raises:
        None directly. Exceptions from clipboard mechanisms are handled as
        fallback signals.

    Side Effects:
        May invoke a validated clipboard executable via `subprocess.run`.
    """
    pyperclip_exception_type = getattr(pyperclip, "PyperclipException", None)
    exception_types: list[type[BaseException]] = [OSError, RuntimeError]
    if isinstance(pyperclip_exception_type, type) and issubclass(
        pyperclip_exception_type, Exception
    ):
        exception_types.append(pyperclip_exception_type)
    handled_copy_errors = tuple(exception_types)

    try:
        pyperclip.copy(text)
        return True
    except handled_copy_errors as error:
        pyperclip_error = error

    commands: tuple[list[str], ...] = (
        ["pbcopy"],
        ["wl-copy"],
        ["xclip", "-selection", "clipboard"],
        ["xsel", "--clipboard", "--input"],
        ["clip"],
        ["clip.exe"],
    )

    # Try validated clipboard executables in a deterministic order.
    for command in commands:
        executable = shutil.which(command[0])
        if executable is None:
            continue
        try:
            subprocess.run(  # noqa: S603 - static analysis can't verify runtime validation
                [executable, *command[1:]],
                input=text,
                text=True,
                check=True,
            )
            return True
        except subprocess.CalledProcessError:
            continue

    print(f"pyperclip copy failed: {pyperclip_error}", file=sys.stderr)
    return False


def strip_front_matter(content: str) -> str:
    """Remove YAML front matter when the template begins with a front-matter block."""
    lines = content.split("\n")
    if not lines or lines[0].strip() != "---":
        return content

    for index, line in enumerate(lines[1:], start=1):
        if line.strip() == "---":
            return "\n".join(lines[index + 1 :]).lstrip()

    return content


def _split_path_platform_agnostic(path_str: str) -> list[str]:
    """Split a path string on either Windows or POSIX separators."""
    return [part for part in re.split(r"[\\/]+", path_str) if part]


def _try_relative_to_workspace(path: Path, workspace_root: Path) -> Path:
    """Return a workspace-relative path when possible, else the original path."""
    try:
        return path.resolve().relative_to(workspace_root.resolve())
    except ValueError:
        return path


def _resolve_folderpath(target_path: Path, workspace_root: Path) -> str:
    """Resolve `${folderpath}` from the target path."""
    return str(_try_relative_to_workspace(target_path, workspace_root).parent)


def _resolve_feature_foldername(folderpath: str) -> str:
    """Resolve the logical feature folder name from `${folderpath}`."""
    parts = _split_path_platform_agnostic(folderpath)
    if not parts:
        raise ValueError("folderpath is empty")

    leaf = parts[-1]
    if leaf.startswith("v") and len(parts) >= 2:
        return parts[-2]
    return leaf


def _resolve_name_from_feature_foldername(feature_foldername: str) -> str:
    """Extract `${name}` from a dated feature-folder naming convention."""
    parts = feature_foldername.split("-")
    if (
        len(parts) >= 5
        and len(parts[0]) == 4
        and len(parts[1]) == 2
        and len(parts[2]) == 2
        and parts[0].isdigit()
        and parts[1].isdigit()
        and parts[2].isdigit()
        and parts[-1].isdigit()
    ):
        name_parts = parts[3:-1]
        if name_parts:
            return "-".join(name_parts)
    return feature_foldername


def _resolve_spec_path(folderpath: str) -> str:
    """Resolve `${spec}` to `${folderpath}/spec.md`."""
    return str(Path(folderpath) / "spec.md")


def _resolve_user_story_value(folderpath: str, workspace_root: Path) -> str:
    """Resolve `${user-story}` and annotate it when the file is missing."""
    relative_story = Path(folderpath) / "user-story.md"
    full_story = workspace_root / relative_story
    if full_story.exists():
        return str(relative_story)
    return f"{relative_story} (missing)"


def _resolve_research_value(folderpath: str, workspace_root: Path) -> str | None:
    """Resolve `${research}` when `research.md` exists; otherwise return `None`."""
    relative_research = Path(folderpath) / "research.md"
    if (workspace_root / relative_research).exists():
        return str(relative_research)
    return None


def _remove_user_story_clause_when_missing(template: str) -> str:
    """Remove the specific user-story clause used by the planner template."""
    return template.replace(" and the `${user-story}`", "")


def _remove_lines_referencing_variable(template: str, variable_name: str) -> str:
    """Remove any line that references an optional `${variable}` token."""
    token = f"${{{variable_name}}}"
    kept_lines: list[str] = []

    # Keep only lines that do not reference the optional variable.
    for line in template.splitlines(keepends=True):
        if token in line:
            continue
        kept_lines.append(line)

    return "".join(kept_lines)


def _insert_after_heading(template: str, heading: str, block: str) -> str:
    """Insert a block immediately after the first exact markdown heading match."""
    lines = template.splitlines(keepends=True)

    # Insert after the first exact heading match to keep behavior deterministic.
    for index, line in enumerate(lines):
        if line.strip() != heading:
            continue
        insertion = block if block.endswith("\n") else f"{block}\n"
        lines.insert(index + 1, insertion)
        return "".join(lines)

    return template


def _apply_minor_audit_overrides(template: str) -> str:
    """Apply deterministic minor-audit prompt adjustments."""
    updated = template
    for variable_name in ("spec", "user-story", "research"):
        updated = _remove_lines_referencing_variable(updated, variable_name)

    mode_block = (
        "\n"
        "### Minor-Audit Mode Overrides (Mandatory)\n"
        "\n"
        "- Use `${folderpath}/issue.md` as the sole requirements source.\n"
        "- Do not require or reference `${spec}`, `${user-story}`, or `${research}`.\n"
        "- Output exactly 3 phases in this order:\n"
        "  - Phase 0 — Baseline Capture\n"
        "  - Phase 1 — Handoff to small-path planning/development agent\n"
        "  - Phase 2 — Final QC loop\n"
    )
    return _insert_after_heading(updated, "## Core Requirements", mode_block)


def _extract_template_variables(template: str) -> set[str]:
    """Extract `${...}` placeholder names from a template string."""
    return {match.group(1) for match in re.finditer(r"\$\{([^}]+)\}", template)}


def _resolve_work_mode_from_issue(
    folderpath: str, workspace_root: Path
) -> tuple[str, str]:
    """Resolve `${work-mode}` and `${fallback-reason}` from `issue.md`."""
    issue_path = workspace_root / Path(folderpath) / "issue.md"
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


def _resolve_workspace_root(workspace_argument: str | None) -> Path:
    """Resolve the workspace root used for path substitutions and file lookups.

    Purpose:
        Honor the extension-provided `--workspace` argument when present so the
        bundled resolver behaves deterministically even when the current process
        directory does not match the intended workspace root.

    Args:
        workspace_argument (str | None): Optional CLI-provided workspace root.

    Returns:
        Path: Absolute workspace root path.

    Raises:
        None.

    Side Effects:
        None.
    """
    if workspace_argument is None:
        return Path.cwd()

    return Path(workspace_argument).resolve()


def _resolve_target_path(target_argument: str, workspace_root: Path) -> Path:
    """Resolve the target path against the workspace root when needed.

    Purpose:
        Preserve workspace-relative target resolution semantics for the bundled
        CLI contract while still supporting absolute target paths emitted by the
        extension service.

    Args:
        target_argument (str): CLI-provided target path.
        workspace_root (Path): Resolved workspace root for relative targets.

    Returns:
        Path: Absolute target path when the target is workspace-relative, or the
            original absolute path unchanged.

    Raises:
        None.

    Side Effects:
        None.
    """
    target_path = Path(target_argument)
    if target_path.is_absolute():
        return target_path

    return workspace_root / target_path


def _replace_all_variables(template: str, variables: dict[str, str]) -> str:
    """Replace every referenced placeholder using the provided mapping."""
    referenced = _extract_template_variables(template)
    missing = sorted(variable for variable in referenced if variable not in variables)
    if missing:
        raise ValueError(f"Unresolved template variables: {', '.join(missing)}")

    resolved = template
    for key in sorted(referenced):
        resolved = resolved.replace(f"${{{key}}}", variables[key])

    if _extract_template_variables(resolved):
        raise ValueError("Template resolution failed: unresolved placeholders remain")

    return resolved


def resolve_prompt(template_content: str, target_path: Path, cwd: Path) -> str:
    """Resolve all supported atomic-plan prompt placeholders.

    Purpose:
        Apply the same prompt substitutions as the repository resolver while
        using the bundled work-mode helper for destination-workspace execution.

    Args:
        template_content (str): Raw prompt-template content.
        target_path (Path): Target plan file used for relative substitutions.
        cwd (Path): Workspace root used for relative resolution and file lookup.

    Returns:
        str: Fully resolved prompt content with no remaining placeholders.

    Raises:
        ValueError: If required placeholders cannot be resolved.

    Side Effects:
        Reads sibling feature documents for optional substitutions and work-mode
        detection.
    """
    content = strip_front_matter(template_content)
    relative_target = _try_relative_to_workspace(target_path, cwd)
    folderpath = _resolve_folderpath(target_path, cwd)
    feature_foldername = _resolve_feature_foldername(folderpath)

    variables: dict[str, str] = {
        "file": str(relative_target).replace("\\", "/"),
        "folderpath": folderpath,
        "name": _resolve_name_from_feature_foldername(feature_foldername),
        "spec": _resolve_spec_path(folderpath),
        "user-story": _resolve_user_story_value(folderpath, cwd),
    }

    selected_work_mode, fallback_reason = _resolve_work_mode_from_issue(folderpath, cwd)
    variables["work-mode"] = selected_work_mode
    variables["fallback-reason"] = fallback_reason

    # Minor-audit mode intentionally removes spec/story/research requirements.
    if selected_work_mode == "minor-audit":
        content = _apply_minor_audit_overrides(content)

    research_value = _resolve_research_value(folderpath, cwd)
    if research_value is None:
        content = _remove_lines_referencing_variable(content, "research")
    else:
        variables["research"] = research_value

    # Remove the template clause that assumes a present user-story file.
    if "(missing)" in variables["user-story"]:
        content = _remove_user_story_clause_when_missing(content)

    return _replace_all_variables(content, variables)


def main() -> int:
    """Run the bundled prompt resolver CLI."""
    parser = argparse.ArgumentParser(description="Resolve atomic-plan prompt variables")
    parser.add_argument("--template", required=True, help="Path to the prompt template")
    parser.add_argument("--target", required=True, help="Path to the target file")
    parser.add_argument(
        "--workspace",
        required=False,
        help="Workspace root used for relative prompt-resolution substitutions",
    )
    args = parser.parse_args()

    template_path = Path(args.template)
    workspace_root = _resolve_workspace_root(args.workspace)
    target_path = _resolve_target_path(args.target, workspace_root)

    if not template_path.exists():
        print(f"Error: Template file not found: {template_path}", file=sys.stderr)
        return 1

    if not target_path.exists():
        print(f"Error: Target file not found: {target_path}", file=sys.stderr)
        return 1

    try:
        template_content = template_path.read_text(encoding="utf-8")
    except OSError as error:
        print(f"Error reading template: {error}", file=sys.stderr)
        return 1

    try:
        resolved_content = resolve_prompt(template_content, target_path, workspace_root)
    except Exception as error:  # noqa: BLE001 - CLI top-level error handling
        print(f"Error processing prompt: {error}", file=sys.stderr)
        return 1

    if copy_to_clipboard(resolved_content):
        print("Successfully resolved prompt and copied to clipboard.")
        print(resolved_content)
        return 0

    print(
        "Could not copy to clipboard; printing resolved prompt to stdout.",
        file=sys.stderr,
    )
    print(resolved_content)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
