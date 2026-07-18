"""Domain-neutrality contract test over the analyzer production modules (scenario 8).

The analyzer framework and inventory analyzer are epic-wide domain-neutral: no
application- or stack-specific identifier may appear in their production source
(code, field names, defaults, error messages, or docstrings).
"""

from __future__ import annotations

from pathlib import Path

import pytest

_ANALYZER_DIR = (
    Path(__file__).resolve().parents[5]
    / "scripts"
    / "dev_tools"
    / "discovery"
    / "analyzer"
)

# Case-insensitive banned identifiers plus stack literals.
_BANNED_SUBSTRINGS = (
    "taskmaster",
    "tmw",
    "outlook",
    "vsto",
    "email",
    "task-management",
    ".csproj",
    ".sln",
)


def _production_modules() -> list[Path]:
    """Return every production ``.py`` module under the analyzer package."""
    return sorted(_ANALYZER_DIR.glob("*.py"))


def test_production_modules_exist() -> None:
    """The scan finds the delivered production modules."""
    # Assert
    names = {path.name for path in _production_modules()}
    assert {
        "__init__.py",
        "__main__.py",
        "cli.py",
        "emitter.py",
        "inventory.py",
        "models.py",
        "pipeline.py",
    } <= names


@pytest.mark.parametrize("module_path", _production_modules(), ids=lambda p: p.name)
def test_module_contains_no_banned_identifier(module_path: Path) -> None:
    """No production analyzer module contains a banned identifier or stack literal."""
    # Arrange
    text = module_path.read_text(encoding="utf-8").lower()

    # Act
    found = [banned for banned in _BANNED_SUBSTRINGS if banned in text]

    # Assert
    assert not found, f"{module_path.name} contains banned identifiers: {found}"
