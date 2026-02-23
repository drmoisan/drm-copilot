"""Regression tests for Pyright configuration alignment."""

from __future__ import annotations

from pathlib import Path


def _read_pyproject_text() -> str:
    """Load and return the repository ``pyproject.toml`` text."""
    pyproject_path = Path(__file__).resolve().parents[3] / "pyproject.toml"
    return pyproject_path.read_text(encoding="utf-8")


def test_pyright_does_not_disable_missing_type_argument_reporting() -> None:
    """Pyright strict config should not suppress missing type argument diagnostics."""
    pyproject_text = _read_pyproject_text()
    assert 'reportMissingTypeArgument = "none"' not in pyproject_text
    assert 'reportMissingTypeArgument = "error"' in pyproject_text


def test_pyright_excludes_nested_mirror_workspace_folder() -> None:
    """Pyright config should exclude nested mirror workspace roots."""
    pyproject_text = _read_pyproject_text()
    # Keep this check explicit so duplicate-root regressions are caught quickly.
    assert '  "drm-copilot",' in pyproject_text
