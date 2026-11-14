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
    """The first top-level binding of a name.

    Attributes:
        kind: "function", "async-function", "class", "variable" or "import".
        span: The binding's span (a definition header, or the statement).
        branch: True when the binding lies inside a top-level if or try body.
    """

    kind: str
    span: tuple[int, int]
    branch: bool


@dataclass
class AllNames:
    """The literal __all__ forms of one input, read in statement order.

    Attributes:
        found: True when any statement starts with __all__.
        dynamic: True when a form cannot be read literally (a non-literal value, an
            unsupported form, or __all__ inside a block).
        names: The exported names in first-occurrence order.
        sites: Exported name to the span of its string literal.
    """

    found: bool = False
    dynamic: bool = False
    names: list[str] = field(default_factory=lambda: [])
    sites: dict[str, tuple[int, int]] = field(default_factory=lambda: {})


def _literal_items(node: ast.expr | None) -> list[tuple[str, tuple[int, int]]] | None:
    """Read a literal list or tuple of strings with the span of each string.

    Args:
        node: The value expression, or None.

    Returns:
        (name, span) pairs, or None when the node is not a list or tuple of literals.
    """
    if not isinstance(node, (ast.List, ast.Tuple)):
        return None
    items: list[tuple[str, tuple[int, int]]] = []
    # Every element must be a literal string; one non-literal rejects the whole form.
    for element in node.elts:
        value = literal_string(element)
        if value is None:
            return None
        items.append((value, node_span(element)))
    return items


def _starts_with_all(parsed: ParsedModule, statement: ast.stmt) -> bool:
    """Report whether a statement begins with the token __all__.

    The check is textual on the canonical line, as the 1022 scanner's is, so a bare
    expression statement __all__ is excluded and __all__x is not matched.

    Args:
        parsed: The parsed module (its canonical lines are read).
        statement: Any statement.

    Returns:
        True when the statement text starts with __all__ followed by a non-identifier
        character.
    """
    if isinstance(statement, ast.Expr) and isinstance(statement.value, ast.Name):
        return False
    # The name must start the statement text and end at a non-identifier character.
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
    """Classify one __all__ statement.

    Args:
        statement: A statement that starts with __all__.

    Returns:
        (replace, items): replace is True for an assignment or annotated assignment,
        which resets the list; items are the literal names, or None for a dynamic form.
        Supported forms are =, : T =, += a literal list, .extend(literal list) and
        .append(literal string).
    """
    # Routing: assignments replace, += and the extend/append calls add, and any other
    # statement is a dynamic form.
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
    """Read the literal __all__ forms of a parsed input in statement order.

    Args:
        parsed: The parsed module.

    Returns:
        The AllNames of the module; any form inside a block, or any dynamic form,
        marks the list dynamic.
    """
    result = AllNames()
    if parsed.tree is None:
        return result
    # Apply each __all__ statement in order; only module-level literal forms count.
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
        # Keep the first site of each name.
        for name, span in items:
            if name not in result.sites:
                result.names.append(name)
                result.sites[name] = span
    return result


def _candidates(
    parsed: ParsedModule, node: ast.stmt, output: AnalyzerOutput, path: str
) -> list[tuple[str, str, tuple[int, int]]]:
    """Return the (name, kind, span) bindings one top-level statement introduces.

    Args:
        parsed: The parsed module.
        node: A top-level statement (module level or a top-level if or try body).
        output: Receives PUBLIC_API_UNPACKING_TARGET for a tuple or list target.
        path: The request path.

    Returns:
        The bindings of a definition, an import, an annotated assignment or a plain
        assignment; an assignment stops at a non-name target.
    """
    # Routing by statement type: definitions use their header span, imports and
    # assignments the statement span.
    if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
        # The element kind separates classes, functions and async functions.
        kind = "class"
        if isinstance(node, ast.FunctionDef):
            kind = "function"
        elif isinstance(node, ast.AsyncFunctionDef):
            kind = "async-function"
        return [(node.name, kind, header_span(parsed, node))]
    span = statement_span(node)
    if isinstance(node, ast.Import):
        # An import binds its alias, or the top package of a dotted import.
        return [(a.asname or a.name.split(".")[0], "import", span) for a in node.names]
    if isinstance(node, ast.ImportFrom):
        # A from-import binds each alias or name; a star import binds nothing here.
        return [
            (a.asname or a.name, "import", span) for a in node.names if a.name != "*"
        ]
    if isinstance(node, ast.AnnAssign):
        if isinstance(node.target, ast.Name) and node.target.id != "__all__":
            return [(node.target.id, "variable", span)]
        return []
    found: list[tuple[str, str, tuple[int, int]]] = []
    if isinstance(node, ast.Assign):
        # Chained targets each bind; unpacking is reported and other targets stop.
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
    """Return the first top-level binding per name.

    Args:
        parsed: The parsed module.
        output: Receives PUBLIC_API_CONDITIONAL_DEFINITION when a name is rebound and
            either binding lies in a branch, and the unpacking diagnostics.
        path: The request path.

    Returns:
        Name to its first binding.
    """
    bindings: dict[str, _Binding] = {}
    if parsed.tree is None:
        return bindings
    # Consider only statements at module level or in top-level if and try bodies.
    for node, context in walk_with_context(parsed.tree):
        if not isinstance(node, ast.stmt) or not context.top_level_only:
            continue
        branch = bool(context.blocks)
        # The first binding wins; a later one is reported when a branch is involved.
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
    """Emit the public-symbol facts of one file.

    Args:
        analyzed: The parsed file.
        source_roots: The configured source roots.
        output: Receives the facts and diagnostics.

    Returns:
        None. A file under no root, or in a private module or package, emits nothing;
        a module with a non-identifier segment reports
        PUBLIC_API_MODULE_NOT_IMPORTABLE.
    """
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
    # A literal __all__ decides the public names; otherwise the naming rule applies
    # (and a dynamic __all__ is reported first).
    if names.found and not names.dynamic:
        # A module-level star import can add names __all__ does not show.
        for statement in analyzed.tables.statements:
            if statement.star and statement.module_level:
                output.add_diagnostic(path, "PUBLIC_API_STAR_IMPORT", statement.line)
        # Each listed name resolves to its binding, or is reported and kept unresolved.
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
        # The naming rule: every non-underscore binding that is not an import.
        for name, binding in bindings.items():
            if not name.startswith("_") and binding.kind != "import":
                symbols.append((name, binding.kind, binding.span, "naming"))
    # Emit one public-symbol fact per selected name.
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
    """Return the python-public-api facts and diagnostics of the parsed files.

    Args:
        files: The parsed request files.
        source_roots: The configured source roots.

    Returns:
        The analyzer output, files processed in path order.
    """
    output = AnalyzerOutput(ANALYZER_ID)
    # Analyze files in path order for deterministic output.
    for analyzed in sorted(files, key=lambda f: f.path):
        _analyze_file(analyzed, source_roots, output)
    return output
