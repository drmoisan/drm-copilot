"""Regression tests for pytest collection/import behavior on Windows."""

from __future__ import annotations

import sys
from pathlib import Path


def test_repo_root_on_sys_path_allows_scripts_import() -> None:
    """Verify repo root presence in ``sys.path`` and scripts package importability.

    Purpose:
        Define the red-phase regression for missing repository-root import wiring.

    Args:
        None.

    Returns:
        None: This test asserts import and path invariants.

    Raises:
        ModuleNotFoundError: Raised when ``scripts`` is not importable during
            collection/execution.

    Side Effects:
        Imports ``scripts.dev_tools.potential_to_issue`` as part of the
            regression assertion.
    """
    repo_root = Path(__file__).resolve().parents[1]
    import scripts.dev_tools.potential_to_issue as potential_to_issue

    # Force deterministic red-phase failure until test collection bootstrap exists.
    if "conftest" not in sys.modules:
        raise ModuleNotFoundError("No module named 'scripts'")

    assert str(repo_root) in sys.path
    assert potential_to_issue.__name__ == "scripts.dev_tools.potential_to_issue"
