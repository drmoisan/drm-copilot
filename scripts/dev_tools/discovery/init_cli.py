"""CLI wiring for `dev.discovery.init`.

Thin argument parsing and dispatch only; the orchestration logic lives in
`init_flow.create_discovery_workspace`.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools.discovery import init_flow, init_models

if TYPE_CHECKING:
    from collections.abc import Sequence


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    """Parse CLI arguments for discovery-workspace initialization."""
    parser = argparse.ArgumentParser(
        description=(
            "Scaffold a consumer repository's discovery workspace (directory "
            "layout, starter domain-profile config, and starter artifact "
            "instances) at the given target directory."
        )
    )
    parser.add_argument(
        "target_dir",
        type=Path,
        help="Target directory in which to scaffold the discovery workspace.",
    )
    parser.add_argument(
        "--template-root",
        dest="template_root",
        type=Path,
        default=None,
        help="Override the bundled default discovery-templates root.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Scaffold into a non-empty target directory.",
    )
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> None:
    """CLI entry point for discovery-workspace initialization."""
    args = parse_args(argv)
    effective_template_root = (
        args.template_root
        if args.template_root is not None
        else init_models.resolve_default_template_root()
    )
    try:
        init_flow.create_discovery_workspace(
            args.target_dir,
            effective_template_root,
            init_models.RealFileSystem(),
            force=args.force,
        )
    except (ValueError, FileExistsError, FileNotFoundError, NotADirectoryError) as exc:
        print(str(exc), file=sys.stderr)
        raise SystemExit(1) from exc
