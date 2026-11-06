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
    """Return the longest dotted prefix of a candidate that is a known module."""
    parts = candidate.split(".")
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
    """Return a module's sorted internal edges; report unresolved relative imports."""
    edges: set[str] = set()
    package_parts = package.split(".") if package else []
    for statement in statements:
        candidates: list[str] = []
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
        for candidate in candidates:
            target = known_prefix(candidate, known)
            if target is not None and target != module:
                edges.add(target)
    return sorted(edges)


def analyze_architecture(
    files: list[AnalyzedFile], source_roots: list[str]
) -> AnalyzerOutput:
    """Return the python-architecture facts and diagnostics of the parsed files."""
    output = AnalyzerOutput(ANALYZER_ID)
    components: list[tuple[AnalyzedFile, str]] = []
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
    known = {module for _file, module in components}
    for analyzed, module in components:
        path = analyzed.path
        package = module_package(path, module) or ""
        edges = import_edges(
            analyzed.tables.statements, module, package, known, output, path
        )
        tree = analyzed.parsed.tree
        if tree is not None:
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
        if len(edges) > EDGE_LIMIT:
            output.add_diagnostic(path, "ARCHITECTURE_EDGE_LIMIT", 1)
        else:
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
