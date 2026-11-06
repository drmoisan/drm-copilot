"""The python-public-api analyzer: literal __all__ lists, else the naming rule.

Reproduces DocsAnalyzerPythonApi.psm1 of issue 1022 over the syntax tree.
"""

from __future__ import annotations

import ast
from dataclasses import dataclass, field
from typing import TYPE_CHECKING

from docs_python_native.facts import AnalyzerOutput
from docs_python_native.module_names import module_dotted_name
from docs_python_native.source import (
    ParsedModule,
    header_span,
    literal_string,
    node_span,
    statement_span,
)
from docs_python_native.walk import walk_with_context

if TYPE_CHECKING:
    from docs_python_native.imports import AnalyzedFile

ANALYZER_ID = "python-public-api"
_ALL = "__all__"


@dataclass(frozen=True)
class _Binding:
    kind: str
    span: tuple[int, int]
    branch: bool


@dataclass
class AllNames:
    """The literal __all__ forms of one input: found, dynamic, names, string spans."""

    found: bool = False
    dynamic: bool = False
    names: list[str] = field(default_factory=lambda: [])
    sites: dict[str, tuple[int, int]] = field(default_factory=lambda: {})


def _literal_items(node: ast.expr | None) -> list[tuple[str, tuple[int, int]]] | None:
    if not isinstance(node, (ast.List, ast.Tuple)):
        return None
    items: list[tuple[str, tuple[int, int]]] = []
    for element in node.elts:
        value = literal_string(element)
        if value is None:
            return None
        items.append((value, node_span(element)))
    return items


def _starts_with_all(parsed: ParsedModule, statement: ast.stmt) -> bool:
    if isinstance(statement, ast.Expr) and isinstance(statement.value, ast.Name):
        return False
    line = (
        parsed.lines[statement.lineno - 1]
        if statement.lineno <= len(parsed.lines)
        else ""
    )
    start = statement.col_offset
    following = line[start + len(_ALL) : start + len(_ALL) + 1]
    return line.startswith(_ALL, start) and not (
        following.isalnum() or following == "_"
    )


def _all_form(
    statement: ast.stmt,
) -> tuple[bool, list[tuple[str, tuple[int, int]]] | None]:
    if isinstance(statement, ast.Assign):
        return True, (
            _literal_items(statement.value) if len(statement.targets) == 1 else None
        )
    if isinstance(statement, ast.AnnAssign):
        return True, _literal_items(statement.value)
    if isinstance(statement, ast.AugAssign):
        return False, (
            _literal_items(statement.value)
            if isinstance(statement.op, ast.Add)
            else None
        )
    call = statement.value if isinstance(statement, ast.Expr) else None
    if not isinstance(call, ast.Call) or not isinstance(call.func, ast.Attribute):
        return False, None
    if (
        call.keywords
        or len(call.args) != 1
        or not isinstance(call.func.value, ast.Name)
    ):
        return False, None
    if call.func.attr == "extend":
        return False, _literal_items(call.args[0])
    value = literal_string(call.args[0]) if call.func.attr == "append" else None
    return False, None if value is None else [(value, node_span(call.args[0]))]


def read_all(parsed: ParsedModule) -> AllNames:
    """Read the literal __all__ forms of a parsed input in statement order."""
    result = AllNames()
    if parsed.tree is None:
        return result
    for node, context in walk_with_context(parsed.tree):
        if not isinstance(node, ast.stmt) or not _starts_with_all(parsed, node):
            continue
        result.found = True
        if context.blocks:
            result.dynamic = True
            continue
        replace, items = _all_form(node)
        if items is None:
            result.dynamic = True
            continue
        if replace:
            result.names.clear()
            result.sites.clear()
        for name, span in items:
            if name not in result.sites:
                result.names.append(name)
                result.sites[name] = span
    return result


def _candidates(
    parsed: ParsedModule, node: ast.stmt, output: AnalyzerOutput, path: str
) -> list[tuple[str, str, tuple[int, int]]]:
    if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
        kind = "class"
        if isinstance(node, ast.FunctionDef):
            kind = "function"
        elif isinstance(node, ast.AsyncFunctionDef):
            kind = "async-function"
        return [(node.name, kind, header_span(parsed, node))]
    span = statement_span(node)
    if isinstance(node, ast.Import):
        return [(a.asname or a.name.split(".")[0], "import", span) for a in node.names]
    if isinstance(node, ast.ImportFrom):
        return [
            (a.asname or a.name, "import", span) for a in node.names if a.name != "*"
        ]
    if isinstance(node, ast.AnnAssign):
        if isinstance(node.target, ast.Name) and node.target.id != "__all__":
            return [(node.target.id, "variable", span)]
        return []
    found: list[tuple[str, str, tuple[int, int]]] = []
    if isinstance(node, ast.Assign):
        for target in node.targets:
            if isinstance(target, (ast.Tuple, ast.List)):
                output.add_diagnostic(path, "PUBLIC_API_UNPACKING_TARGET", node.lineno)
                continue
            if not isinstance(target, ast.Name) or target.id == "__all__":
                break
            found.append((target.id, "variable", span))
    return found


def top_level_bindings(
    parsed: ParsedModule, output: AnalyzerOutput, path: str
) -> dict[str, _Binding]:
    """Return the first top-level binding per name; report conditional and unpacking."""
    bindings: dict[str, _Binding] = {}
    if parsed.tree is None:
        return bindings
    for node, context in walk_with_context(parsed.tree):
        if not isinstance(node, ast.stmt) or not context.top_level_only:
            continue
        branch = bool(context.blocks)
        for name, kind, span in _candidates(parsed, node, output, path):
            existing = bindings.get(name)
            if existing is not None:
                if branch or existing.branch:
                    output.add_diagnostic(
                        path, "PUBLIC_API_CONDITIONAL_DEFINITION", span[0]
                    )
                continue
            bindings[name] = _Binding(kind, span, branch)
    return bindings


def _analyze_file(
    analyzed: AnalyzedFile, source_roots: list[str], output: AnalyzerOutput
) -> None:
    path = analyzed.path
    module = module_dotted_name(path, source_roots, require_identifiers=False)
    if module is None:
        return
    segments = module.split(".")
    if not all(segment.isidentifier() for segment in segments):
        output.add_diagnostic(path, "PUBLIC_API_MODULE_NOT_IMPORTABLE", 1)
        return
    if any(segment.startswith("_") for segment in segments):
        return
    parsed = analyzed.parsed
    names = read_all(parsed)
    bindings = top_level_bindings(parsed, output, path)
    symbols: list[tuple[str, str, tuple[int, int], str]] = []
    if names.found and not names.dynamic:
        for statement in analyzed.tables.statements:
            if statement.star and statement.module_level:
                output.add_diagnostic(path, "PUBLIC_API_STAR_IMPORT", statement.line)
        for name in names.names:
            binding = bindings.get(name)
            if binding is not None:
                symbols.append((name, binding.kind, binding.span, "all"))
                continue
            site = names.sites[name]
            output.add_diagnostic(path, "PUBLIC_API_NAME_UNRESOLVED", site[0])
            symbols.append((name, "unresolved", site, "all"))
    else:
        if names.found:
            output.add_diagnostic(path, "PUBLIC_API_DYNAMIC_ALL", 1)
        for name, binding in bindings.items():
            if not name.startswith("_") and binding.kind != "import":
                symbols.append((name, binding.kind, binding.span, "naming"))
    for name, kind, span, basis in symbols:
        output.add_fact(
            path,
            "public-symbol",
            module + "." + name,
            name,
            span,
            {"basis": basis, "symbol_kind": kind},
        )


def analyze_public_api(
    files: list[AnalyzedFile], source_roots: list[str]
) -> AnalyzerOutput:
    """Return the python-public-api facts and diagnostics of the parsed files."""
    output = AnalyzerOutput(ANALYZER_ID)
    for analyzed in sorted(files, key=lambda f: f.path):
        _analyze_file(analyzed, source_roots, output)
    return output
