"""I/O and template materialization helpers for active feature folder creation."""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
from typing import TYPE_CHECKING

from scripts.dev_tools.new_active_feature_folder_markdown import set_header_placeholder
from scripts.dev_tools.new_active_feature_folder_models import (
    EXCLUDED_POTENTIAL_NAMES,
    NAME_PATTERN,
    PLAN_TIMESTAMP_TEMPLATE_NAME,
    IssueMeta,
)

if TYPE_CHECKING:
    from collections.abc import Callable, Iterable
    from pathlib import Path

    from scripts.dev_tools.new_active_feature_folder_models import FileSystem


_INSIDERS_SIGNAL_NAMES = (
    "TERM_PROGRAM_VERSION",
    "VSCODE_GIT_ASKPASS_MAIN",
    "TERM_PROGRAM",
    "VSCODE_IPC_HOOK_CLI",
)


def find_potential_file(
    feature_name: str, workspace: Path, fs: FileSystem
) -> Path | None:
    """Find the best matching potential file for a feature name."""
    normalized = feature_name.replace("_", "-")
    potential_dirs = [
        workspace / "docs" / "features" / "potential",
        workspace / "docs" / "features" / "potential" / "promoted",
    ]

    for directory in potential_dirs:
        candidates = [
            file
            for file in fs.list_files(directory)
            if file.suffix == ".md"
            and normalized in file.name
            and file.name not in EXCLUDED_POTENTIAL_NAMES
        ]
        if candidates:
            return sorted(candidates, key=lambda path: path.name, reverse=True)[0]
    return None


def parse_issue_number(content: str) -> str | None:
    """Parse an issue number from markdown metadata lines."""
    match = re.search(r"^\s*-\s*Issue\s*:\s*#?(\d+)", content, flags=re.MULTILINE)
    if match:
        return match.group(1)
    return None


def build_folder_slug(
    feature_name: str,
    potential_file: Path | None,
    issue_number: str | None,
) -> str:
    """Build canonical active-folder slug."""
    slug = feature_name.replace("_", "-")
    if potential_file:
        slug = potential_file.stem
    if issue_number and not slug.endswith(str(issue_number)):
        slug = f"{slug}-{issue_number}"
    if not NAME_PATTERN.fullmatch(slug):
        raise ValueError(
            f"Aborted: '{slug}' is invalid. Use kebab/underscore-case letters/numbers "
            "(e.g., notes-feature or notes_feature)."
        )
    return slug


def copy_template(
    feature_type: str,
    template_dir: Path,
    target_dir: Path,
    fs: FileSystem,
) -> None:
    """Copy template files for the selected feature type.

    For ``bug``, iterate ``(spec.md, <timestamped-plan>, plan.md)`` copying each
    that exists and break immediately after copying the timestamped plan
    template. For ``epic``, copy only the single-home file set (``epic.md`` +
    ``epic-status.md``). For all other types, recursively copy the template tree.
    """
    # Route by feature type. Bug and epic copy a curated file set; every other
    # type recursively copies the whole template tree.
    if feature_type == "bug":
        for name in ("spec.md", PLAN_TIMESTAMP_TEMPLATE_NAME, "plan.md"):
            src = template_dir / name
            if fs.exists(src):
                fs.copy_file(src, target_dir / name)
                if name == PLAN_TIMESTAMP_TEMPLATE_NAME:
                    break
    elif feature_type == "epic":
        # Epic scaffolding copies only the single-home file set; it never
        # recursively copies a legacy initiative.md tree.
        for name in ("epic.md", "epic-status.md"):
            src = template_dir / name
            if fs.exists(src):
                fs.copy_file(src, target_dir / name)
    else:
        fs.copy_tree(template_dir, target_dir)


def copy_feature_template_for_minor_audit(
    template_dir: Path,
    target_dir: Path,
    fs: FileSystem,
) -> None:
    """Copy only the plan template for minor-audit feature flows."""
    timestamped_plan = template_dir / PLAN_TIMESTAMP_TEMPLATE_NAME
    if fs.exists(timestamped_plan):
        fs.copy_file(timestamped_plan, target_dir / PLAN_TIMESTAMP_TEMPLATE_NAME)
        return

    legacy_plan = template_dir / "plan.md"
    if fs.exists(legacy_plan):
        fs.copy_file(legacy_plan, target_dir / "plan.md")


def materialize_plan_file(
    feature_type: str,
    target_dir: Path,
    feature_name: str,
    issue_field: str,
    owner_field: str,
    parent_field: str,
    status_field: str,
    version_field: str,
    plan_timestamp: str,
    fs: FileSystem,
) -> Path | None:
    """Rename and stamp plan templates when timestamped templates exist."""
    template_plan = target_dir / PLAN_TIMESTAMP_TEMPLATE_NAME
    if fs.exists(template_plan):
        target_plan = target_dir / f"plan.{plan_timestamp}.md"
        fs.move(template_plan, target_plan)
        content = fs.read_text(target_plan)
        updated_field = plan_timestamp

        content = set_header_placeholder(
            content,
            feature_name=feature_name,
            issue_field=issue_field,
            owner_field=owner_field,
            updated_field=updated_field,
            status_field=status_field,
            parent_field=parent_field,
            version_field=version_field,
        )
        fs.write_text(target_plan, content)
        return target_plan

    legacy = target_dir / "plan.md"
    if fs.exists(legacy):
        return legacy
    return None


def default_issue_fetcher(issue_number: str) -> IssueMeta | None:
    """Fetch issue metadata from GitHub CLI."""
    gh_cmd = shutil.which("gh")
    if not gh_cmd:
        return None
    result = subprocess.run(  # noqa: S603
        [
            gh_cmd,
            "issue",
            "view",
            issue_number,
            "--json",
            "number,title,url,author,updatedAt",
        ],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0 or not result.stdout.strip():
        return None

    try:
        parsed = json.loads(result.stdout.strip())
    except json.JSONDecodeError:
        return None

    number = str(parsed.get("number", issue_number))
    author = parsed.get("author", {}).get("login") or "name"
    updated_at = parsed.get("updatedAt")
    updated_date = "YYYY-MM-DD"
    if isinstance(updated_at, str) and updated_at.strip():
        updated_date = updated_at.split("T")[0]
    return IssueMeta(number=number, author=author, updated_date=updated_date)


def _env_lookup(name: str) -> str | None:
    """Return a non-blank environment variable value when one is defined.

    Purpose:
        Provide a small environment seam for VS Code session detection without
            treating blank variables as meaningful signals.

    Args:
        name (str): Environment variable name to resolve from the current process.

    Returns:
        str | None: The environment variable value when present and non-blank;
            otherwise `None`.

    Raises:
        None.

    Side Effects:
        Reads process environment state.
    """
    value = os.getenv(name)
    return value if value and value.strip() else None


def _is_insiders_session(
    env_lookup: Callable[[str], str | None] | None = None,
) -> bool:
    """Return whether the current process appears to be running inside VS Code Insiders.

    Purpose:
        Detect the current editor flavor so launcher selection can prefer
            `code-insiders` when the originating session is already Insiders.

    Args:
        env_lookup (Callable[[str], str | None]): Environment lookup used
            to read the known VS Code session signal variables.

    Returns:
        bool: `True` when any supported signal indicates an Insiders session;
            otherwise `False`.

    Raises:
        None.

    Side Effects:
        Reads process environment state through the injected lookup.
    """
    # Check the documented VS Code environment signals in a stable order so
    # the launcher behavior stays deterministic across bundled and root copies.
    lookup = env_lookup or _env_lookup
    for variable_name in _INSIDERS_SIGNAL_NAMES:
        value = lookup(variable_name)
        if value and "insider" in value.lower():
            return True
    return False


def _resolve_code_cli(
    which_lookup: Callable[[str], str | None] | None = None,
    env_lookup: Callable[[str], str | None] | None = None,
) -> str | None:
    """Resolve the best VS Code CLI executable path for the current session.
        [code_cmd, "--reuse-window", *[file_path.as_posix() for file_path in files]],
    Purpose:
        Choose the correct CLI path while preserving fallback to the standard
            `code` command when an Insiders-specific executable is unavailable.

    Args:
        which_lookup (Callable[[str], str | None]): PATH lookup used to
            resolve CLI executables.
        env_lookup (Callable[[str], str | None]): Environment lookup used
            for Insiders-session detection.

    Returns:
        str | None: Resolved CLI executable path when one is available;
            otherwise `None`.

    Raises:
        None.

    Side Effects:
        Reads process environment state and PATH through the injected lookups.
    """
    resolved_which_lookup = which_lookup or shutil.which

    # Prefer the CLI that matches the current session first, then fall back to
    # the other supported executable name to preserve graceful behavior.
    candidate_names = (
        ("code-insiders", "code")
        if _is_insiders_session(env_lookup)
        else ("code", "code-insiders")
    )
    for candidate_name in candidate_names:
        resolved_command = resolved_which_lookup(candidate_name)
        if resolved_command:
            return resolved_command
    return None


def default_code_launcher(files: Iterable[Path]) -> bool:
    """Open created files in VS Code when available."""
    code_cmd = _resolve_code_cli()
    if not code_cmd:
        return False
    subprocess.run(  # noqa: S603
        [
            code_cmd,
            "--reuse-window",
            *[str(file_path).replace("\\", "/") for file_path in files],
        ],
        check=False,
    )
    return True
