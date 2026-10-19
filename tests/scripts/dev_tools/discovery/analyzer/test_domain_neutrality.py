"""Domain-neutrality contract test over the analyzer production modules (scenario 8).

The analyzer framework and inventory analyzer are epic-wide domain-neutral: no
application- or optional-domain identifier may appear in their production source
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

# Consumer and optional-domain identifiers remain banned in the reusable core.
_BANNED_SUBSTRINGS = (
    "taskmaster",
    "tmw",
    "outlook",
    "vsto",
    "email",
    "task-management",
)

# Optional stack adapters retain their separate consumer-neutrality contract in
# test_stack_neutrality.py. This scan includes both legacy adapters and canonical
# reusable core modules; generic build filename markers are permitted structural data.
_STACK_SPECIFIC_MODULES = frozenset(
    {
        "source_text.py",
        "dotnet_inventory.py",
        "dotnet_patterns.py",
        "vsto_office.py",
        "vsto_patterns.py",
        "stack_cli.py",
    }
)


def _production_modules() -> list[Path]:
    """Return every #363 framework ``.py`` module under the analyzer package.

    Stack-specific #369 modules are excluded because the framework's stricter
    banned list does not apply to them; see ``_STACK_SPECIFIC_MODULES``.
    """
    runtime = (
        Path(__file__).resolve().parents[5]
        / "packages/discovery-runtime/src/drm_copilot_discovery/analyzer"
    )
    return sorted(
        path
        for directory in (_ANALYZER_DIR, runtime)
        for path in directory.glob("*.py")
        if path.name not in _STACK_SPECIFIC_MODULES
    )


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
