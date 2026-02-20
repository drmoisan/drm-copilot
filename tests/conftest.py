"""Pytest collection bootstrap helpers for repository-local imports.

Purpose:
    Ensure repository-local modules are importable during test collection.

Usage:
    Imported automatically by pytest before test module collection.

Flow:
    Resolve repository root from this file location, then conditionally insert it
    into ``sys.path``.

Invariants / Constraints:
    The repository root path must be the parent of the ``tests`` directory.

Side Effects:
    Mutates ``sys.path`` when the repository root path is missing.

Attributes:
    None.
"""

from __future__ import annotations

import sys
from pathlib import Path


def _ensure_repo_root_on_sys_path() -> None:
    """Insert repository root into ``sys.path`` when not already present.

    Purpose:
        Keep test imports deterministic across local and CI execution environments.

    Args:
        None.

    Returns:
        None: The function updates interpreter import state in place.

    Raises:
        None.

    Side Effects:
        Prepends the resolved repository root to ``sys.path`` when missing.
    """
    repo_root = Path(__file__).resolve().parents[1]

    # Guard duplicate path insertion so import ordering stays stable.
    if str(repo_root) not in sys.path:
        sys.path.insert(0, str(repo_root))


_ensure_repo_root_on_sys_path()
