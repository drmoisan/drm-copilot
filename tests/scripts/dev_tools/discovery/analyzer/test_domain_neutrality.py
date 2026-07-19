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

# Stack-specific analyzer modules delivered by feature #369. These modules are
# stack-specific by charter, so the framework's stricter banned list (which bans
# ``vsto``, ``.csproj``, ``.sln`` — legitimate pattern data for a .NET/VSTO
# analyzer) must not be applied to them. Their consumer-neutrality is enforced by
# the feature-scoped contract test ``test_stack_neutrality.py`` instead, per the
# spec's Constraints & Risks scoping nuance. This framework test therefore scans
# only #363's language-neutral modules.
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
    return sorted(
        path
        for path in _ANALYZER_DIR.glob("*.py")
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
