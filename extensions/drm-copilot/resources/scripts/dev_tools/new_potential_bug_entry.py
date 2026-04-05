"""Create a potential bug entry and optionally open it in VS Code."""

from __future__ import annotations

import argparse
import os
import re
import shutil
import subprocess
from dataclasses import dataclass
from datetime import date
from pathlib import Path
from typing import TYPE_CHECKING, Protocol

if TYPE_CHECKING:
    from collections.abc import Callable, Iterable

SHORT_NAME_PATTERN = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
_INSIDERS_SIGNAL_NAMES = (
    "TERM_PROGRAM_VERSION",
    "VSCODE_GIT_ASKPASS_MAIN",
    "TERM_PROGRAM",
    "VSCODE_IPC_HOOK_CLI",
)


def _resolve_workspace() -> Path:
    return Path.cwd()


def validate_short_name(short_name: str) -> None:
    """Validate that a short name matches the repository kebab-case contract.

    Purpose:
        Reject invalid bug-entry short names before filesystem or template work begins.

    Args:
        short_name (str): Candidate short name that must use lowercase
            kebab-case tokens.

    Returns:
        None: This validator returns no value when the short name satisfies
            the contract.

    Raises:
        ValueError: Raised when the supplied short name is blank or
            violates the kebab-case pattern.

    Side Effects:
        None.
    """
    if not short_name or not SHORT_NAME_PATTERN.fullmatch(short_name):
        raise ValueError(
            f"Aborted: '{short_name}' is invalid. Use kebab-case letters/numbers only "
            "(e.g., api-timeout)."
        )


def default_git_config_lookup(key: str) -> str | None:
    """Resolve a Git configuration value without failing when Git is unavailable.

    Purpose:
        Query Git configuration opportunistically so author discovery can
            prefer repository settings.

    Args:
        key (str): Git configuration key to read, such as `user.name`.

    Returns:
        str | None: The trimmed configuration value when Git is available
            and returns a non-blank value; otherwise `None`.

    Raises:
        None.

    Side Effects:
        Invokes the `git config` subprocess when Git is available on PATH.
    """
    git_cmd = shutil.which("git")
    if not git_cmd:
        return None
    result = subprocess.run(  # noqa: S603
        [git_cmd, "config", key],
        check=False,
        capture_output=True,
        text=True,
    )
    value = result.stdout.strip()
    return value or None


def default_env_lookup(name: str) -> str | None:
    """Return a non-blank environment variable value when one is defined.

    Purpose:
        Provide a lightweight fallback lookup for author resolution
            without accepting blank environment values.

    Args:
        name (str): Environment variable name to read from the current process.

    Returns:
        str | None: The environment variable value when present and
            non-blank; otherwise `None`.

    Raises:
        None.

    Side Effects:
        Reads process environment state.
    """
    value = os.getenv(name)
    return value if value and value.strip() else None


def get_author(
    git_lookup: Callable[[str], str | None] = default_git_config_lookup,
    env_lookup: Callable[[str], str | None] = default_env_lookup,
) -> str:
    """Resolve the author name from Git configuration before falling back to USERNAME.

    Purpose:
        Produce the best available author label for the generated
            bug-entry markdown metadata.

    Args:
        git_lookup (Callable[[str], str | None]): Git-backed lookup
            function for configuration values.
        env_lookup (Callable[[str], str | None]): Environment-backed
            lookup function for fallback variables.

    Returns:
        str: The resolved author name, or `Unknown` when neither lookup yields a value.

    Raises:
        None.

    Side Effects:
        May read Git configuration and process environment state through
            the injected lookup callables.
    """
    author = git_lookup("user.name")
    if not author:
        author = env_lookup("USERNAME")
    if not author:
        return "Unknown"
    return author


def render_content(template: str, short_name: str, entry_date: str, author: str) -> str:
    """Apply bug-entry placeholder substitutions to the copied markdown template.

    Purpose:
        Replace the template placeholders with the concrete bug name,
            entry date, and author metadata.

    Args:
        template (str): Raw markdown template content copied from the
            selected source template.
        short_name (str): Validated short name used to replace the
            bug-name placeholder.
        entry_date (str): ISO date string inserted into the generated markdown.
        author (str): Author name inserted into the metadata block.

    Returns:
        str: Markdown content with all supported bug-entry placeholders replaced.

    Raises:
        None.

    Side Effects:
        None.
    """
    updated = template.replace("<bug-name>", short_name)
    updated = updated.replace("YYYY-MM-DD", entry_date)
    updated = updated.replace("- Author: name", f"- Author: {author}")
    return updated


class FileSystem(Protocol):
    def ensure_dir(self, path: Path) -> None: ...

    def copy_file(self, src: Path, dest: Path) -> None: ...

    def read_text(self, path: Path) -> str: ...

    def write_text(self, path: Path, content: str) -> None: ...


@dataclass
class RealFileSystem(FileSystem):
    def ensure_dir(self, path: Path) -> None:
        path.mkdir(parents=True, exist_ok=True)

    def copy_file(self, src: Path, dest: Path) -> None:
        shutil.copyfile(src, dest)

    def read_text(self, path: Path) -> str:
        return path.read_text(encoding="utf-8")

    def write_text(self, path: Path, content: str) -> None:
        path.write_text(content, encoding="utf-8")


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
    lookup = env_lookup or default_env_lookup
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
    """Open created files in the matching VS Code session when possible.

    Purpose:
        Reuse the current VS Code or VS Code Insiders window for generated
            files while preserving the existing boolean success contract.

    Args:
        files (Iterable[Path]): Files to open in the editor session.

    Returns:
        bool: `True` when a supported VS Code CLI executable was resolved and
            invoked; otherwise `False`.

    Raises:
        None.

    Side Effects:
        Resolves editor CLI executables on PATH and invokes a subprocess when
            an appropriate command is available.
    """
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


def create_bug_entry(
    short_name: str,
    workspace: Path | None = None,
    fs: FileSystem | None = None,
    author_provider: Callable[[], str] = get_author,
    code_launcher: Callable[[Iterable[Path]], bool] = default_code_launcher,
    entry_date: str | None = None,
    template_root: Path | None = None,
) -> Path:
    """Create a potential bug markdown file from the selected template root.

    Purpose:
        Materialize a new potential bug entry by copying a template,
            filling in metadata, and optionally opening the result in
            VS Code.

    Args:
        short_name (str): Validated kebab-case suffix for the generated
            bug-entry filename and content.
        workspace (Path | None): Workspace root that receives the
            generated file; defaults to the resolved repository or
            bundle workspace.
        fs (FileSystem | None): Filesystem adapter used for directory
            creation, file copy, and text I/O.
        author_provider (Callable[[], str]): Callable that resolves the
            author name inserted into the template.
        code_launcher (Callable[[Iterable[Path]], bool]): Callable that
            attempts to open the generated file in VS Code.
        entry_date (str | None): Optional ISO date override for
            deterministic generation.
        template_root (Path | None): Optional bundled feature-template
            root that overrides workspace-local templates.

    Returns:
        Path: Absolute path to the generated potential bug markdown file.

    Raises:
        ValueError: Raised when `short_name` violates the kebab-case contract.
        FileNotFoundError: Raised when the selected template cannot be
            copied from the resolved template path.

    Side Effects:
        Creates directories, copies and rewrites markdown files, and may
            invoke the VS Code launcher or print a warning.
    """
    validate_short_name(short_name)

    workspace_path = workspace or _resolve_workspace()
    filesystem = fs or RealFileSystem()
    date_str = entry_date or date.today().strftime("%Y-%m-%d")

    target_dir = workspace_path / "docs" / "features" / "potential"
    target = target_dir / f"{date_str}-{short_name}.md"
    if template_root is not None:
        template = template_root / "bug" / "potential_bug.md"
    else:
        template = (
            workspace_path
            / "docs"
            / "features"
            / "templates"
            / "bug"
            / "potential_bug.md"
        )

    filesystem.ensure_dir(target_dir)
    filesystem.copy_file(template, target)

    author = author_provider()
    content = filesystem.read_text(target)
    updated = render_content(content, short_name, date_str, author)
    filesystem.write_text(target, updated)

    if not code_launcher([target]):
        print("WARNING: VS Code 'code' command not found. Open file manually:")
        print(f"  {target}")

    return target


def parse_args() -> argparse.Namespace:
    """Parse CLI arguments for the potential bug entry workflow.

    Purpose:
        Define and read the command-line interface for creating a
            potential bug entry from a bundled or workspace template.

    Args:
        None.

    Returns:
        argparse.Namespace: Parsed CLI arguments containing the required
            short name and optional template root.

    Raises:
        SystemExit: Raised by `argparse` when required arguments are missing or invalid.

    Side Effects:
        Reads process command-line arguments and may emit argparse help or error text.
    """
    parser = argparse.ArgumentParser(
        description="Create a potential bug entry from the template."
    )
    parser.add_argument(
        "--short-name", required=True, help="Bug name in kebab-case (e.g., api-timeout)"
    )
    parser.add_argument(
        "--template-root",
        default=None,
        help="Bundled feature-templates dir (overrides workspace).",
    )
    return parser.parse_args()


def main() -> None:
    """Execute the CLI boundary for potential bug entry creation.

    Purpose:
        Bridge parsed CLI arguments into the bug-entry creation workflow
            and convert user-facing failures into exit codes.

    Args:
        None.

    Returns:
        None: The CLI exits by returning normally on success or raising
            `SystemExit` on handled failures.

    Raises:
        SystemExit: Raised with exit code 1 when validation or file lookup fails.

    Side Effects:
        Reads CLI arguments, may create bug-entry files, may launch VS
            Code, and prints user-facing error messages on handled
            failures.
    """
    args = parse_args()
    resolved_root = Path(args.template_root) if args.template_root else None
    try:
        create_bug_entry(short_name=args.short_name, template_root=resolved_root)
    except ValueError as exc:
        print(str(exc))
        raise SystemExit(1) from exc
    except FileNotFoundError as exc:
        print(f"Aborted: required file not found: {exc}")
        raise SystemExit(1) from exc


if __name__ == "__main__":
    main()
