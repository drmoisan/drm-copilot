"""Import alias table, tracked receivers, definitions and module names of one input.

The rules reproduce the 1022 DocsPythonBindings.psm1 front-end: aliases are bound by
imports at module level or inside top-level if and try blocks; a framework import inside
a def or class reports PYTHON_IMPORT_NESTED_FRAMEWORK, a framework star import reports
PYTHON_IMPORT_STAR_FRAMEWORK, and a name bound to two different targets reports
PYTHON_BINDING_AMBIGUOUS and resolves to nothing.
"""

from __future__ import annotations

import ast
from dataclasses import dataclass, field

from docs_python_native.facts import RawDiagnostic
from docs_python_native.source import ParsedModule, dotted_name
from docs_python_native.walk import Context, walk_with_context

FRAMEWORKS = frozenset({"argparse", "click", "typer", "fastapi", "flask"})
STAR_FRAMEWORK = "PYTHON_IMPORT_STAR_FRAMEWORK"
NESTED_FRAMEWORK = "PYTHON_IMPORT_NESTED_FRAMEWORK"
BINDING_AMBIGUOUS = "PYTHON_BINDING_AMBIGUOUS"


@dataclass(frozen=True)
class ImportStatement:
    """One import statement at any depth."""

    line: int
    kind: str
    module: str
    level: int
    names: tuple[tuple[str, str | None], ...]
    star: bool
    nested: bool
    module_level: bool


@dataclass(frozen=True)
class Receiver:
    """A name bound by NAME = <dotted callee>(...) at any depth."""

    name: str
    callee: str
    call: ast.Call
    statement: ast.stmt
    context: Context


@dataclass
class ModuleTables:
    """The import alias table, receivers and definitions of one parsed input."""

    alias: dict[str, str] = field(default_factory=lambda: {})
    ambiguous: set[str] = field(default_factory=lambda: set())
    statements: list[ImportStatement] = field(default_factory=lambda: [])
    receivers: dict[str, Receiver] = field(default_factory=lambda: {})
    receiver_ambiguous: set[str] = field(default_factory=lambda: set())
    definitions: dict[str, ast.FunctionDef | ast.AsyncFunctionDef] = field(
        default_factory=lambda: {}
    )
    definition_names: set[str] = field(default_factory=lambda: set())
    diagnostics: list[RawDiagnostic] = field(default_factory=lambda: [])

    def qualify(self, name: str | None) -> str | None:
        """Resolve a dotted name through the alias table; None when ambiguous."""
        if name is None:
            return None
        parts = name.split(".")
        if parts[0] in self.ambiguous:
            return None
        target = self.alias.get(parts[0])
        if target is None:
            return name
        return target + "".join("." + part for part in parts[1:])

    def is_known_name(self, name: str, *, include_classes: bool = False) -> bool:
        """True when a name is a receiver, a def (or class) name, or an import alias."""
        defined = self.definition_names if include_classes else self.definitions
        return name in self.receivers or name in defined or name in self.alias


@dataclass(frozen=True)
class AnalyzedFile:
    """One request file that parsed: its path, parse result and binding tables."""

    path: str
    parsed: ParsedModule
    tables: ModuleTables


def _import_statement(
    node: ast.Import | ast.ImportFrom, context: Context
) -> ImportStatement:
    if isinstance(node, ast.Import):
        names = tuple((alias.name, alias.asname) for alias in node.names)
        return ImportStatement(
            node.lineno,
            "import",
            "",
            0,
            names,
            False,
            context.nested,
            not context.blocks,
        )
    star = any(alias.name == "*" for alias in node.names)
    names = tuple(
        (alias.name, alias.asname) for alias in node.names if alias.name != "*"
    )
    return ImportStatement(
        node.lineno,
        "from",
        node.module or "",
        node.level,
        names,
        star,
        context.nested,
        not context.blocks,
    )


def _bind(tables: ModuleTables, bound: str, full: str, line: int) -> None:
    if bound in tables.ambiguous:
        return
    existing = tables.alias.get(bound)
    if existing is None:
        tables.alias[bound] = full
        return
    if existing != full:
        del tables.alias[bound]
        tables.ambiguous.add(bound)
        tables.diagnostics.append(RawDiagnostic(BINDING_AMBIGUOUS, line))


def _add_import(
    tables: ModuleTables, statement: ImportStatement, context: Context
) -> None:
    tables.statements.append(statement)
    is_from = statement.kind == "from"
    root = statement.module.split(".")[0] if is_from else ""
    if statement.star:
        if statement.level == 0 and root in FRAMEWORKS:
            tables.diagnostics.append(RawDiagnostic(STAR_FRAMEWORK, statement.line))
        return
    for name, asname in statement.names:
        if is_from:
            joiner = "." if statement.module else ""
            full = "." * statement.level + statement.module + joiner + name
            top_root = root
            bound = asname if asname is not None else name
        else:
            top_root = name.split(".")[0]
            bound = asname if asname is not None else top_root
            full = name if asname is not None else bound
        if statement.nested:
            if statement.level == 0 and top_root in FRAMEWORKS:
                tables.diagnostics.append(
                    RawDiagnostic(NESTED_FRAMEWORK, statement.line)
                )
            continue
        if context.top_level_only:
            _bind(tables, bound, full, statement.line)


def _receiver_call(node: ast.stmt) -> tuple[str, ast.Call] | None:
    target: ast.expr | None = None
    value: ast.expr | None = None
    if isinstance(node, ast.Assign) and len(node.targets) == 1:
        target, value = node.targets[0], node.value
    elif isinstance(node, ast.AnnAssign):
        target, value = node.target, node.value
    if not isinstance(target, ast.Name) or not isinstance(value, ast.Call):
        return None
    if dotted_name(value.func) is None:
        return None
    return target.id, value


def _add_receiver(tables: ModuleTables, node: ast.stmt, context: Context) -> None:
    found = _receiver_call(node)
    if found is None:
        return
    name, call = found
    if name in tables.receiver_ambiguous:
        return
    existing = tables.receivers.get(name)
    if existing is not None:
        if ast.dump(existing.call) != ast.dump(call):
            del tables.receivers[name]
            tables.receiver_ambiguous.add(name)
            tables.diagnostics.append(RawDiagnostic(BINDING_AMBIGUOUS, node.lineno))
        return
    callee = dotted_name(call.func) or ""
    tables.receivers[name] = Receiver(name, callee, call, node, context)


def build_tables(parsed: ParsedModule) -> ModuleTables:
    """Build the import alias table, receivers and definitions of a parsed input."""
    tables = ModuleTables()
    if parsed.tree is None:
        return tables
    for node, context in walk_with_context(parsed.tree):
        if isinstance(node, (ast.Import, ast.ImportFrom)):
            _add_import(tables, _import_statement(node, context), context)
        elif isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
            tables.definition_names.add(node.name)
            if (
                not isinstance(node, ast.ClassDef)
                and node.name not in tables.definitions
            ):
                tables.definitions[node.name] = node
        if isinstance(node, ast.stmt):
            _add_receiver(tables, node, context)
    return tables
