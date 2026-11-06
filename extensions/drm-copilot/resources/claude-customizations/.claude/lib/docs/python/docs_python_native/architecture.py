"""The python-architecture analyzer: module and package components with internal edges.

Reproduces DocsAnalyzerArchitecture.psm1 of issue 1022: imports at any depth, relative
imports resolved against the module's package, longest dotted-prefix match against the
request modules, and edge properties bounded at 1000 per component.
"""

from __future__ import annotations

import ast
from typing import TYPE_CHECKING

from docs_python_native.facts import AnalyzerOutput, FactValue
from docs_python_native.module_names import module_dotted_name, module_package
from docs_python_native.source import dotted_name
from docs_python_native.walk import walk_with_context

if TYPE_CHECKING:
    from docs_python_native.imports import AnalyzedFile, ImportStatement

ANALYZER_ID = "python-architecture"
EDGE_LIMIT = 1000
DYNAMIC_CALLEES = frozenset(
    {"importlib.import_module", "importlib.util.spec_from_file_location", "__import__"}
)
RELATIVE_UNRESOLVED = "ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED"


def known_prefix(candidate: str, known: set[str]) -> str | None:
    """Return the longest dotted prefix of a candidate that is a known module.

    Args:
        candidate: A dotted import target such as pkg.mod.name.
        known: The dotted names of the request modules.

    Returns:
        The longest prefix in known, or None.
    """
    parts = candidate.split(".")
    # Try prefixes from the longest to the shortest; the first hit is the longest.
    for length in range(len(parts), 0, -1):
        prefix = ".".join(parts[:length])
        if prefix in known:
            return prefix
    return None


def import_edges(
    statements: list[ImportStatement],
    module: str,
    package: str,
    known: set[str],
    output: AnalyzerOutput,
    path: str,
) -> list[str]:
    """Return a module's sorted internal import edges.

    Args:
        statements: The module's import statements at any depth.
        module: The module's dotted name (a self-edge is dropped).
        package: The package relative imports resolve against.
        known: The dotted names of the request modules.
        output: Receives ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED.
        path: The request path.

    Returns:
        The sorted unique known modules the statements import.
    """
    edges: set[str] = set()
    package_parts = package.split(".") if package else []
    # Turn each statement into candidate targets, then keep the known prefixes.
    for statement in statements:
        candidates: list[str] = []
        # A plain import names its modules; a from-import names its base module (for
        # a star import or empty list) and base.name for each imported name.
        if statement.kind == "import":
            candidates.extend(name for name, _alias in statement.names)
        else:
            base = statement.module
            if statement.level > 0:
                kept = len(package_parts) - (statement.level - 1)
                if not package_parts or kept <= 0:
                    output.add_diagnostic(path, RELATIVE_UNRESOLVED, statement.line)
                    continue
                root = ".".join(package_parts[:kept])
                base = root + "." + base if base else root
            if statement.star or not statement.names:
                candidates.append(base)
            candidates.extend(base + "." + name for name, _alias in statement.names)
        # Record each candidate's longest known prefix, except the module itself.
        for candidate in candidates:
            target = known_prefix(candidate, known)
            if target is not None and target != module:
                edges.add(target)
    return sorted(edges)


def analyze_architecture(
    files: list[AnalyzedFile], source_roots: list[str]
) -> AnalyzerOutput:
    """Return the python-architecture facts and diagnostics of the parsed files.

    Args:
        files: The parsed request files.
        source_roots: The configured source roots.

    Returns:
        One architecture-component fact per importable module or package, with
        import_count and up to EDGE_LIMIT numbered import edges, and the dynamic-import,
        invalid-name and edge-limit diagnostics.
    """
    output = AnalyzerOutput(ANALYZER_ID)
    components: list[tuple[AnalyzedFile, str]] = []
    # Select the files that map to an importable module name.
    for analyzed in sorted(files, key=lambda f: f.path):
        module = module_dotted_name(
            analyzed.path, source_roots, require_identifiers=False
        )
        if module is None:
            continue
        if not all(segment.isidentifier() for segment in module.split(".")):
            output.add_diagnostic(analyzed.path, "ARCHITECTURE_MODULE_NAME_INVALID", 1)
            continue
        components.append((analyzed, module))
    # The request's module names are the only valid edge targets.
    known = {module for _file, module in components}
    # Build each component: its edges, dynamic-import diagnostics and fact.
    for analyzed, module in components:
        path = analyzed.path
        package = module_package(path, module) or ""
        edges = import_edges(
            analyzed.tables.statements, module, package, known, output, path
        )
        tree = analyzed.parsed.tree
        if tree is not None:
            # Report each call of a dynamic-import function.
            for node, _context in walk_with_context(tree):
                if isinstance(node, ast.Call):
                    qualified = analyzed.tables.qualify(dotted_name(node.func))
                    if qualified in DYNAMIC_CALLEES:
                        output.add_diagnostic(
                            path, "ARCHITECTURE_DYNAMIC_IMPORT", node.lineno
                        )
        is_package = path.endswith("/__init__.py")
        properties: dict[str, FactValue] = {
            "component_kind": "package" if is_package else "module",
            "import_count": len(edges),
        }
        # Above the limit only the count is kept; otherwise each edge is numbered.
        if len(edges) > EDGE_LIMIT:
            output.add_diagnostic(path, "ARCHITECTURE_EDGE_LIMIT", 1)
        else:
            # Number the edges import-0001, import-0002, ... in sorted order.
            for index, edge in enumerate(edges, 1):
                properties[f"import-{index:04d}"] = edge
        output.add_fact(
            path,
            "architecture-component",
            module,
            module.split(".")[-1],
            None,
            properties,
        )
    return output
