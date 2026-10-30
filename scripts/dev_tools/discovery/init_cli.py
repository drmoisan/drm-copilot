"""Forward initialization to the installed CLI without inferring legacy authority.

The named legacy parser remains an inert syntax helper. Only the installed init
command validates context, uses packaged templates and performs guarded writes.
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import TYPE_CHECKING

from drm_copilot_discovery import cli as runtime_cli

if TYPE_CHECKING:
    from collections.abc import Sequence


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    """Describe legacy argv (Sequence[str] | None) without initializing anything.

    Return argparse.Namespace with target_dir/template_root (Path/Path | None)
    and force (bool); these values grant no read or overwrite authority. None
    uses process arguments. Argparse may print help/errors and raise SystemExit;
    no filesystem access occurs. ``main`` does not consume this namespace.
    """
    parser = argparse.ArgumentParser(
        description=(
            "Inspect deprecated initialization syntax without executing it. "
            "Use the installed init command's --help for explicit v2 context."
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
        help="Historical template-root value; cannot select runtime templates.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Historical force value; cannot authorize overwrites.",
    )
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    """Forward argv (Sequence[str] | None) unchanged to the installed init CLI.

    Return its typed int exit (0/1/2/3); None retains bounded process arguments.
    The installed boundary owns streams and guarded effects. Legacy positional,
    template-root and force inputs refuse before providers; this adapter neither
    finds templates nor invents source identity or overwrite permission.
    """
    return runtime_cli.run_installed_cli("init", argv)


if __name__ == "__main__":
    raise SystemExit(main())
