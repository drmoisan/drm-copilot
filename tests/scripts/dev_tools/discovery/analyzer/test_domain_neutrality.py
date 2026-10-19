"""Domain-neutrality contract test over the analyzer production modules (scenario 8).

The analyzer framework and inventory analyzer are epic-wide domain-neutral: no
application- or optional-domain identifier may appear in their production source
(code, field names, defaults, error messages, or docstrings).
"""

from __future__ import annotations

import ast
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


def _registry_without_routing_metadata(text: str) -> str:
    """Remove only the exact approved selector/import/constructor AST locations.

    text (str) is registry source. Returns source with those bounded spans blanked;
    comments, docstrings and all unrelated behavior remain inspected. Raises
    AssertionError if dispatch structure differs. Pure and input-preserving.
    """
    tree = ast.parse(text)
    allowed: list[ast.AST] = []
    # Locate the one selector function; no other function receives an exemption.
    functions = [
        node
        for node in tree.body
        if isinstance(node, ast.FunctionDef) and node.name == "select_analyzers"
    ]
    assert len(functions) == 1
    function = functions[0]
    # Permit only the optional ID within the exact complete reserved metadata tuple.
    declarations = [
        node
        for node in tree.body
        if isinstance(node, ast.Assign)
        and len(node.targets) == 1
        and isinstance(node.targets[0], ast.Name)
        and node.targets[0].id == "_BUILTIN_IDENTIFIERS"
    ]
    assert len(declarations) == 1
    identifiers = declarations[0].value
    expected_ids = (
        "com-interop",
        "configuration",
        "csharp-symbols",
        "dependencies",
        "dotnet",
        "event-subscriptions",
        "filesystem-access",
        "office-vsto",
        "registry-access",
        "repository",
        "test-references",
        "ui-callbacks",
    )
    assert ast.dump(identifiers) == ast.dump(
        ast.parse(repr(expected_ids), mode="eval").body
    )
    assert isinstance(identifiers, ast.Tuple)
    allowed.append(identifiers.elts[7])
    # Match the complete optional branch, so business logic cannot hide in dispatch.
    branches = [
        node
        for node in ast.walk(function)
        if isinstance(node, ast.If) and isinstance(node.test, ast.Compare)
    ]
    assert len(branches) == 1
    branch = branches[0]
    expected = ast.parse("""if identifier == "office-vsto":
    from drm_copilot_discovery.analyzer.optional.vsto_office import VstoOfficeAnalyzer
    selected.append(VstoOfficeAnalyzer())
else:
    selected.append(_generic_analyzer(identifier))
""").body[0]
    assert ast.dump(branch) == ast.dump(
        expected
    ), "Only fixed lazy routing metadata is allowed"
    assert isinstance(branch.test, ast.Compare)
    allowed.extend((branch.test.comparators[0], branch.body[0]))
    call = branch.body[1]
    assert isinstance(call, ast.Expr) and isinstance(call.value, ast.Call)
    constructor = call.value.args[0]
    assert isinstance(constructor, ast.Call)
    allowed.append(constructor.func)
    encoded = text.encode("utf-8")
    lines = encoded.splitlines(keepends=True)
    offsets = [0]
    # AST column offsets count UTF-8 bytes; retain that exact coordinate system.
    for line in lines:
        offsets.append(offsets[-1] + len(line))
    masked = bytearray(encoded)
    # Blank only verified routing nodes, leaving optional literals elsewhere visible.
    for node in allowed:
        assert isinstance(node, (ast.expr, ast.stmt))
        assert node.end_lineno is not None and node.end_col_offset is not None
        start = offsets[node.lineno - 1] + node.col_offset
        end = offsets[node.end_lineno - 1] + node.end_col_offset
        masked[start:end] = b" " * (end - start)
    return masked.decode("utf-8")


def _production_modules() -> list[Path]:
    """Return every #363 framework ``.py`` module under the analyzer package.

    No parameters. Returns list[Path] from repository existence scans; no writes.
    OSError propagates on unreadable repository paths. Stack-specific modules are
    checked by the separate stack contract.
    """
    runtime = (
        Path(__file__).resolve().parents[5]
        / "packages/discovery-runtime/src/drm_copilot_discovery/analyzer"
    )
    # Include both runtime implementations and compatibility adapters in core checks.
    return sorted(
        path
        for directory in (_ANALYZER_DIR, runtime)
        for path in directory.glob("*.py")
        if path.name not in _STACK_SPECIFIC_MODULES
    )


def test_production_modules_exist() -> None:
    """Verify required modules remain in the scan; no parameters, returns None.

    Raises AssertionError on missing modules; reads repository paths only.
    """
    # Required names prevent an empty or narrowed scan from appearing successful.
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
    """Inspect module_path (Path) for banned core identifiers outside fixed routing.

    Returns None; AssertionError identifies a leaked literal. Reads repository
    source only and never changes it.
    """
    # Arrange
    text = module_path.read_text(encoding="utf-8")
    # Only the canonical registry receives the exact audited AST metadata allowance.
    if module_path.as_posix().endswith("drm_copilot_discovery/analyzer/registry.py"):
        text = _registry_without_routing_metadata(text)
    text = text.lower()

    # Scan every remaining byte, including comments and unrelated registry logic.
    found = [banned for banned in _BANNED_SUBSTRINGS if banned in text]

    # Assert
    assert not found, f"{module_path.name} contains banned identifiers: {found}"


@pytest.mark.parametrize(
    "suffix", ["\n# vsto product behavior\n", '\nUNRELATED = "outlook"\n']
)
def test_registry_allowance_preserves_unrelated_source(suffix: str) -> None:
    """Keep unauthorized comment/data literals visible outside exact routing spans.

    suffix (str) supplies synthetic forbidden source. Returns None; AssertionError
    signals an overly broad exemption. Reads immutable registry text only.
    """
    # Select only the canonical registry; legacy modules receive no such allowance.
    registry = next(
        path
        for path in _production_modules()
        if path.as_posix().endswith("drm_copilot_discovery/analyzer/registry.py")
    )
    remaining = _registry_without_routing_metadata(
        registry.read_text(encoding="utf-8") + suffix
    )
    assert suffix in remaining


def test_registry_allowance_rejects_business_logic_inside_optional_branch() -> None:
    """Reject additions inside the fixed optional dispatch branch.

    No parameters. Returns None; AssertionError signals a broad branch exemption.
    Reads immutable source, then mutates only an in-memory copy.
    """
    # Keep the negative probe tied to the exact dispatch source under contract.
    registry = next(
        path
        for path in _production_modules()
        if path.as_posix().endswith("drm_copilot_discovery/analyzer/registry.py")
    )
    text = registry.read_text(encoding="utf-8").replace(
        "selected.append(VstoOfficeAnalyzer())",
        'selected.append(VstoOfficeAnalyzer())\n            product = "outlook"',
    )
    with pytest.raises(AssertionError, match="Only fixed lazy routing"):
        _registry_without_routing_metadata(text)
