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

from docs_python_native.source import (
    Context,
    ParsedModule,
    dotted_name,
    walk_with_context,
)

FRAMEWORKS = frozenset({"argparse", "click", "typer", "fastapi", "flask"})
STAR_FRAMEWORK = "PYTHON_IMPORT_STAR_FRAMEWORK"
NESTED_FRAMEWORK = "PYTHON_IMPORT_NESTED_FRAMEWORK"
BINDING_AMBIGUOUS = "PYTHON_BINDING_AMBIGUOUS"


@dataclass(frozen=True)
class RawDiagnostic:
    """A site or input diagnostic before it is reported under an analyzer identifier."""

    code: str
    line: int


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


FactValue = str | bool | int


@dataclass(frozen=True)
class Fact:
    """One raw element fact; PowerShell computes its identifiers and digest."""

    analyzer_id: str
    kind: str
    declaration: str
    name: str
    parent: tuple[str, str, str] | None
    line_start: int | None
    line_end: int | None
    properties: tuple[tuple[str, FactValue], ...]

    def to_json(self) -> dict[str, object]:
        """Return the protocol object of the fact."""
        parent: dict[str, str] | None = None
        if self.parent is not None:
            parent = {
                "kind": self.parent[0],
                "declaration": self.parent[1],
                "path": self.parent[2],
            }
        return {
            "analyzer_id": self.analyzer_id,
            "kind": self.kind,
            "declaration": self.declaration,
            "name": self.name,
            "parent": parent,
            "line_start": self.line_start,
            "line_end": self.line_end,
            "properties": dict(self.properties),
        }


@dataclass
class AnalyzerOutput:
    """Facts and raw diagnostics of one analyzer, keyed by request path."""

    analyzer_id: str
    facts: dict[str, list[Fact]] = field(default_factory=lambda: {})
    diagnostics: dict[str, list[RawDiagnostic]] = field(default_factory=lambda: {})

    def add_fact(
        self,
        path: str,
        kind: str,
        declaration: str,
        name: str,
        span: tuple[int, int] | None,
        properties: dict[str, FactValue],
        parent: tuple[str, str, str] | None = None,
    ) -> None:
        """Record one fact for a path; a None span records null line bounds."""
        start, end = (None, None) if span is None else span
        fact = Fact(
            self.analyzer_id,
            kind,
            declaration,
            name,
            parent,
            start,
            end,
            tuple(sorted(properties.items())),
        )
        self.facts.setdefault(path, []).append(fact)

    def add_diagnostic(self, path: str, code: str, line: int) -> None:
        """Record one raw diagnostic for a path."""
        self.diagnostics.setdefault(path, []).append(RawDiagnostic(code, line))


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


def _identifier(segment: str) -> bool:
    return segment.isidentifier()


def module_dotted_name(
    path: str, source_roots: list[str], *, require_identifiers: bool = True
) -> str | None:
    """Return the dotted module name of a .py path under its longest containing root.

    __init__.py gives the package name. None for a path under no root, a non-.py path, a
    root-level __init__.py, or (when require_identifiers) a segment that is not an
    identifier.
    """
    if not path.endswith(".py"):
        return None
    relative: str | None = None
    best = -1
    for root in source_roots:
        trimmed = root.rstrip("/")
        if trimmed in (".", ""):
            if best < 0:
                best, relative = 0, path
            continue
        if path.startswith(trimmed + "/") and len(trimmed) > best:
            best, relative = len(trimmed), path[len(trimmed) + 1 :]
    if relative is None:
        return None
    stem = relative[:-3]
    if stem.endswith("/__init__"):
        stem = stem[: -len("/__init__")]
    elif stem == "__init__":
        return None
    if stem == "":
        return None
    dotted = stem.replace("/", ".")
    if require_identifiers and not all(_identifier(part) for part in dotted.split(".")):
        return None
    return dotted


def module_package(path: str, module: str | None) -> str | None:
    """Return a module's package: itself for __init__.py, its parent, or '' at top."""
    if module is None:
        return None
    if path.endswith("/__init__.py"):
        return module
    if "." in module:
        return module[: module.rindex(".")]
    return ""


def resolve_relative(module: str, package: str | None) -> str | None:
    """Resolve a possibly relative dotted module against a package, or return None."""
    level = len(module) - len(module.lstrip("."))
    if level == 0:
        return module
    if not package:
        return None
    parts = package.split(".")
    if level - 1 > len(parts):
        return None
    kept = parts[: len(parts) - (level - 1)]
    rest = module[level:]
    if rest:
        kept.append(rest)
    if not kept:
        return None
    return ".".join(kept)
