"""Publish bundled `.codex` and `.agents` content into a destination workspace.

Purpose:
    Provide a dedicated public entry point for the Codex/agents push-down
    workflow while reusing the shared publisher engine behind the existing
    `.github` customization flow.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from scripts.dev_tools.push_down_copilot_customizations import (
    PushDownFileSystem,
    PushDownSummary,
    RealPushDownFileSystem,
)
from scripts.dev_tools.push_down_copilot_customizations import (
    push_down_customizations as push_down_scoped_customizations,
)

ARTIFACT_DIRECTORY = "artifacts/codex-and-agents-customizations"
MODULE_ENTRY_POINT = "scripts.dev_tools.push_down_codex_and_agents_customizations"
ROOT_FOLDERS: tuple[Path, ...] = (Path(".codex"), Path(".agents"))

__all__ = ["PushDownSummary", "main", "parse_args", "push_down_customizations"]


def _passthrough_rewrite(
    text: str,
) -> tuple[str, int, int, list[str]]:
    """Return unmodified text for payloads that do not need command rewrites."""

    return text, 0, 0, []


def push_down_customizations(
    *,
    repo_root: Path,
    destination_root: Path,
    fs: PushDownFileSystem,
    source_root: Path | None = None,
    artifact_root: Path | None = None,
) -> PushDownSummary:
    """Copy bundled `.codex` and `.agents` trees into the destination workspace."""

    return push_down_scoped_customizations(
        repo_root=repo_root,
        destination_root=destination_root,
        fs=fs,
        source_root=source_root,
        artifact_root=artifact_root,
        root_folders=ROOT_FOLDERS,
        artifact_directory=ARTIFACT_DIRECTORY,
        rewrite_references=_passthrough_rewrite,
    )


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """Parse CLI arguments for the Codex/agents push-down publisher."""

    parser = argparse.ArgumentParser(
        description=(
            "Publish bundled Codex and agents customizations with "
            f"python -m {MODULE_ENTRY_POINT}."
        )
    )
    parser.add_argument(
        "--destination",
        required=True,
        help=(
            "Destination workspace root that will receive the copied .codex "
            "and .agents trees."
        ),
    )
    return parser.parse_args(argv)


def main(
    argv: list[str] | None = None,
    *,
    repo_root: Path | None = None,
    fs: PushDownFileSystem | None = None,
) -> int:
    """Run the Codex/agents push-down publisher CLI."""

    args = parse_args(argv)
    resolved_repo_root = (repo_root or Path.cwd()).expanduser().resolve()
    resolved_destination = Path(args.destination).expanduser().resolve()
    resolved_fs = fs or RealPushDownFileSystem()
    summary = push_down_customizations(
        repo_root=resolved_repo_root,
        destination_root=resolved_destination,
        fs=resolved_fs,
        source_root=resolved_repo_root,
        artifact_root=resolved_repo_root,
    )
    print(f"Wrote push-down summary artifact to: {summary.artifact_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
