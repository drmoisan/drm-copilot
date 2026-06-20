"""Shared pytest fixtures for the dev-tools test package.

Purpose:
    Provide deterministic defaults for tests in this directory that exercise the
    ``fix_all`` workflow. ``run_fix_all`` runs the TypeScript branch, which
    resolves the ``npm`` executable from PATH. The unit-test policy forbids
    tests from depending on mutable machine PATH, so the resolver is stubbed to
    a fixed sentinel by default. Tests that need the npm-not-found behavior
    re-patch the resolver explicitly.
"""

from __future__ import annotations

import pytest

from scripts.dev_tools import fix_all_branches_extra


@pytest.fixture(autouse=True)
def stub_npm_resolution(monkeypatch: pytest.MonkeyPatch) -> None:
    """Stub the TypeScript branch npm resolver to a deterministic sentinel.

    Purpose:
        Decouple the fix-all tests from machine PATH by making
        ``fix_all_branches_extra._resolve_npm`` return the literal ``"npm"``
        rather than performing a real PATH lookup. This preserves the historical
        command shape (``["npm", "run", ...]``) the tests assert against.

    Args:
        monkeypatch (pytest.MonkeyPatch): Pytest patching seam.

    Returns:
        None: Applies the patch for the active test; monkeypatch reverts it.

    Side Effects:
        Replaces ``fix_all_branches_extra._resolve_npm`` for the test duration.
    """
    monkeypatch.setattr(fix_all_branches_extra, "_resolve_npm", lambda: "npm")
