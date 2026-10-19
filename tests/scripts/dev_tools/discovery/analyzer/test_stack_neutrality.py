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
_RUNTIME_ANALYZER_DIR = (
    Path(__file__).resolve().parents[5]
    / "packages/discovery-runtime/src/drm_copilot_discovery/analyzer"
)

# Stack-specific production modules delivered by #369 (contingent pattern modules
# included when present).
_STACK_MODULE_NAMES = (
    "source_text.py",
    "dotnet_inventory.py",
    "dotnet_patterns.py",
    "vsto_office.py",
    "vsto_patterns.py",
    "vsto_syntax.py",
    "stack_cli.py",
    "csharp_tokens.py",
    "csharp_declarations.py",
    "event_subscriptions.py",
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
    """Return sorted list[Path] for legacy and moved runtime stack modules.

    Takes no arguments; performs only existence checks on repository files.
    Including both surfaces prevents a thin adapter from hiding implementation.
    """
    # Scan actual implementations as well as compatibility adapters after relocation.
    return sorted(
        directory / name
        for directory in (
            _ANALYZER_DIR,
            _RUNTIME_ANALYZER_DIR,
            _RUNTIME_ANALYZER_DIR / "optional",
        )
        for name in _STACK_MODULE_NAMES
        if (directory / name).exists()
    )


def _fixture_files() -> list[Path]:
    """Return list[Path] of committed fixture text; no parameters or writes.

    OSError propagates on repository access failures; consumer roots are unused.
    """
    return sorted(_FIXTURE_DIR.glob("*.txt"))


def test_stack_modules_present() -> None:
    """Verify delivered stack modules are scanned; no parameters, returns None.

    Raises AssertionError on missing paths; reads repository metadata only.
    """
    # Assert: the four mandatory modules exist (pattern modules are contingent).
    names = {path.name for path in _existing_stack_modules()}
    assert {
        "source_text.py",
        "dotnet_inventory.py",
        "vsto_office.py",
        "stack_cli.py",
    } <= names
    assert (
        _RUNTIME_ANALYZER_DIR / "optional" / "vsto_office.py"
        in _existing_stack_modules()
    )
    assert (
        _RUNTIME_ANALYZER_DIR / "optional" / "vsto_patterns.py"
        in _existing_stack_modules()
    )


@pytest.mark.parametrize("module_path", _existing_stack_modules(), ids=lambda p: p.name)
def test_module_has_no_consumer_identifier_or_app_hardcoding(
    module_path: Path,
) -> None:
    """Scan module_path (Path) for consumer literals and per-application branches.

    Returns None; AssertionError identifies a forbidden literal. Reads only
    committed/working source files; no writes or source execution.
    """
    # Arrange
    text = module_path.read_text(encoding="utf-8").lower()

    # Consumer names are forbidden even inside otherwise allowed optional modules.
    banned_consumer = [b for b in _BANNED_CONSUMER_IDENTIFIERS if b in text]
    # Application-qualified constants indicate hardcoding rather than captured data.
    banned_app = [b for b in _BANNED_APP_HARDCODING if b in text]

    # Assert
    assert not banned_consumer, f"{module_path.name}: consumer id {banned_consumer}"
    assert not banned_app, f"{module_path.name}: app hardcoding {banned_app}"


@pytest.mark.parametrize("fixture_path", _fixture_files(), ids=lambda p: p.name)
def test_fixture_has_no_consumer_identifier(fixture_path: Path) -> None:
    """Scan fixture_path (Path) for consumer identifiers; return None.

    Raises AssertionError on leaked identifiers; reads immutable fixtures only.
    """
    # Arrange
    text = fixture_path.read_text(encoding="utf-8").lower()

    # Synthetic fixtures must not introduce consuming-repository data.
    found = [b for b in _BANNED_CONSUMER_IDENTIFIERS if b in text]

    # Assert
    assert not found, f"{fixture_path.name}: consumer id {found}"


def test_permitted_stack_literals_do_not_trip_the_ban() -> None:
    """Confirm generic literals remain permitted; no parameters, returns None.

    Raises AssertionError for a narrowed allowed vocabulary. Reads repository
    source without executing or mutating it.
    """
    # Arrange: the VSTO modules legitimately carry the permitted stack literals.
    combined = "".join(
        path.read_text(encoding="utf-8").lower()
        for path in _existing_stack_modules()
        if path.name in {"vsto_office.py", "vsto_patterns.py"}
    )

    # Retain explicit evidence that generic optional syntax is in the scanned scope.
    present = [lit for lit in _PERMITTED_STACK_LITERALS if lit in combined]
    assert present
    # Allowed generic terms must not overlap the per-application hardcoding ban.
    assert all(lit not in _BANNED_APP_HARDCODING for lit in present)
