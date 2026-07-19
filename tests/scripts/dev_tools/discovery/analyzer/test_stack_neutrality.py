"""Feature-scoped domain-neutrality contract test for the #369 stack analyzers.

These analyzer modules are stack-specific by charter, so the stricter #363
framework banned list (which bans ``vsto``, ``.csproj``, ``.sln`` in the
language-neutral framework modules) intentionally does NOT apply here. This
feature-scoped test bans only consumer identifiers (``taskmaster``, ``tmw``) and
consumer-specific or per-Office-application hardcoding (for example a literal
``Microsoft.Office.Interop.Outlook`` special case or any branch on a specific
Office application name), while permitting the generic stack literals (``csharp``,
``vsto``, the ``Microsoft.Office.*`` pattern prefix, ``.csproj``, ``.sln``, and the
customUI namespace URIs) that are this feature's legitimate subject matter. The
fixtures are also scanned for consumer identifiers.
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
_FIXTURE_DIR = (
    Path(__file__).resolve().parents[5] / "tests" / "fixtures" / "discovery_dotnet_vsto"
)

# Stack-specific production modules delivered by #369 (contingent pattern modules
# included when present).
_STACK_MODULE_NAMES = (
    "source_text.py",
    "dotnet_inventory.py",
    "dotnet_patterns.py",
    "vsto_office.py",
    "vsto_patterns.py",
    "stack_cli.py",
)

# Consumer identifiers are banned everywhere (production and fixtures).
_BANNED_CONSUMER_IDENTIFIERS = ("taskmaster", "tmw")

# Per-Office-application hardcoding is banned: a specific interop-app-qualified
# literal indicates a consumer-specific special case rather than capture-as-data.
_BANNED_APP_HARDCODING = (
    "microsoft.office.interop.outlook",
    "microsoft.office.interop.excel",
    "microsoft.office.interop.word",
    "microsoft.office.interop.powerpoint",
    "microsoft.office.interop.access",
)

# Generic stack literals that ARE permitted here (this list intentionally differs
# from the stricter #363 framework list). Used by the permit assertion below.
_PERMITTED_STACK_LITERALS = ("csharp", "vsto", "microsoft.office.interop.", ".csproj")


def _existing_stack_modules() -> list[Path]:
    """Return the delivered stack-specific modules that exist on disk."""
    return sorted(
        _ANALYZER_DIR / name
        for name in _STACK_MODULE_NAMES
        if (_ANALYZER_DIR / name).exists()
    )


def _fixture_files() -> list[Path]:
    """Return the raw fixture files for the stack analyzers."""
    return sorted(_FIXTURE_DIR.glob("*.txt"))


def test_stack_modules_present() -> None:
    """The feature-scoped scan finds the delivered stack modules."""
    # Assert: the four mandatory modules exist (pattern modules are contingent).
    names = {path.name for path in _existing_stack_modules()}
    assert {
        "source_text.py",
        "dotnet_inventory.py",
        "vsto_office.py",
        "stack_cli.py",
    } <= names


@pytest.mark.parametrize("module_path", _existing_stack_modules(), ids=lambda p: p.name)
def test_module_has_no_consumer_identifier_or_app_hardcoding(
    module_path: Path,
) -> None:
    """No stack module contains a consumer identifier or per-app hardcoding."""
    # Arrange
    text = module_path.read_text(encoding="utf-8").lower()

    # Act
    banned_consumer = [b for b in _BANNED_CONSUMER_IDENTIFIERS if b in text]
    banned_app = [b for b in _BANNED_APP_HARDCODING if b in text]

    # Assert
    assert not banned_consumer, f"{module_path.name}: consumer id {banned_consumer}"
    assert not banned_app, f"{module_path.name}: app hardcoding {banned_app}"


@pytest.mark.parametrize("fixture_path", _fixture_files(), ids=lambda p: p.name)
def test_fixture_has_no_consumer_identifier(fixture_path: Path) -> None:
    """No fixture file contains a consumer identifier."""
    # Arrange
    text = fixture_path.read_text(encoding="utf-8").lower()

    # Act
    found = [b for b in _BANNED_CONSUMER_IDENTIFIERS if b in text]

    # Assert
    assert not found, f"{fixture_path.name}: consumer id {found}"


def test_permitted_stack_literals_do_not_trip_the_ban() -> None:
    """Generic stack literals are permitted (unlike the #363 framework list)."""
    # Arrange: the VSTO modules legitimately carry the permitted stack literals.
    combined = "".join(
        (_ANALYZER_DIR / name).read_text(encoding="utf-8").lower()
        for name in ("vsto_office.py", "vsto_patterns.py")
        if (_ANALYZER_DIR / name).exists()
    )

    # Assert: at least one permitted literal is present and is not banned.
    present = [lit for lit in _PERMITTED_STACK_LITERALS if lit in combined]
    assert present
    assert all(lit not in _BANNED_APP_HARDCODING for lit in present)
