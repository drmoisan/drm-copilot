"""Import alias table, tracked receivers and definitions of one input.

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
    """One import statement at any depth, as the architecture analyzer reads it.

    Attributes:
        line: The statement line.
        kind: "import" for import m, "from" for from m import n.
        module: The from-module text without leading dots ("" for import m).
        level: The relative-import level (number of leading dots).
        names: (name, alias or None) pairs, star excluded.
        star: True for a star import.
        nested: True inside a def or class body.
        module_level: True when no block encloses the statement.
    """

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
    """A name bound by NAME = <dotted callee>(...) at any depth.

    Receivers are the flow-insensitive objects (parsers, groups, apps, routers) that
    the recognizers resolve method calls against.

    Attributes:
        name: The bound name.
        callee: The dotted callee text as written (not alias-qualified).
        call: The constructor call node.
        statement: The binding statement.
        context: The enclosing-block context of the statement.
    """

    name: str
    callee: str
    call: ast.Call
    statement: ast.stmt
    context: Context


@dataclass
class ModuleTables:
    """The import alias table, receivers and definitions of one parsed input.

    Built once per file by build_tables and shared read-only by every analyzer.

    Attributes:
        alias: Bound name to its fully qualified import target.
        ambiguous: Names bound to two different import targets (never resolved).
        statements: Every import statement at any depth, in walk order.
        receivers: Receiver name to its first binding.
        receiver_ambiguous: Receiver names bound to two different calls.
        definitions: Function name to its first def or async def.
        definition_names: Every def, async def and class name.
        diagnostics: The binding diagnostics of the file.
    """

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
        """Resolve a dotted name through the alias table.

        Args:
            name: A dotted name, or None.

        Returns:
            The name with its first segment replaced by its import target; the name
            unchanged when the first segment is not an alias; None for None or an
            ambiguous first segment.
        """
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
        """Report whether a name is bound in the file at all.

        Args:
            name: A plain name.
            include_classes: When True, class names also count as definitions.

        Returns:
            True when the name is a receiver, a def (or class) name, or an import alias.
        """
        defined = self.definition_names if include_classes else self.definitions
        return name in self.receivers or name in defined or name in self.alias


@dataclass(frozen=True)
class AnalyzedFile:
    """One request file that parsed, with its parse result and binding tables.

    Attributes:
        path: The request path.
        parsed: The ParsedModule of the file (status PARSE_OK).
        tables: The ModuleTables built from it.
    """

    path: str
    parsed: ParsedModule
    tables: ModuleTables


def _import_statement(
    node: ast.Import | ast.ImportFrom, context: Context
) -> ImportStatement:
    """Convert an import node into an ImportStatement.

    Args:
        node: An import or from-import node.
        context: The node's enclosing-block context.

    Returns:
        The ImportStatement; a from-import drops "*" from names and sets star.
    """
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
    """Bind an alias, demoting it to ambiguous when it is rebound to another target.

    Args:
        tables: The tables being built; mutated.
        bound: The bound name.
        full: The fully qualified target.
        line: The import line, used for the ambiguity diagnostic.

    Returns:
        None. A conflicting rebind removes the alias, records the name as ambiguous
        and appends PYTHON_BINDING_AMBIGUOUS.
    """
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
    """Record an import statement and bind its names under the 1022 rules.

    Args:
        tables: The tables being built; mutated.
        statement: The import statement.
        context: The statement's enclosing-block context.

    Returns:
        None. A framework star import or a nested framework import adds its
        diagnostic; only top-level imports bind aliases.
    """
    tables.statements.append(statement)
    is_from = statement.kind == "from"
    root = statement.module.split(".")[0] if is_from else ""
    if statement.star:
        if statement.level == 0 and root in FRAMEWORKS:
            tables.diagnostics.append(RawDiagnostic(STAR_FRAMEWORK, statement.line))
        return
    # Bind each imported name. A from-import binds name (or alias) to module.name; a
    # plain import binds the top package, or the alias to the full dotted module.
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
        # A nested import never binds; it only reports when it names a framework.
        if statement.nested:
            if statement.level == 0 and top_root in FRAMEWORKS:
                tables.diagnostics.append(
                    RawDiagnostic(NESTED_FRAMEWORK, statement.line)
                )
            continue
        if context.top_level_only:
            _bind(tables, bound, full, statement.line)


def _receiver_call(node: ast.stmt) -> tuple[str, ast.Call] | None:
    """Return (name, call) for NAME = callee(...) or NAME: T = callee(...).

    Args:
        node: Any statement.

    Returns:
        The bound name and the call, or None when the statement is not a single-name
        assignment of a call whose callee is a dotted name.
    """
    target: ast.expr | None = None
    value: ast.expr | None = None
    # Only plain single-target and annotated assignments can bind a receiver.
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
    """Record a receiver binding, demoting a name bound to two different calls.

    Args:
        tables: The tables being built; mutated.
        node: Any statement.
        context: The statement's enclosing-block context.

    Returns:
        None. A rebind to an equal call is ignored; a rebind to a different call
        removes the receiver and appends PYTHON_BINDING_AMBIGUOUS.
    """
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
    """Build the import alias table, receivers and definitions of a parsed input.

    Args:
        parsed: A parsed module; a module without a tree gives empty tables.

    Returns:
        The ModuleTables of the file.
    """
    tables = ModuleTables()
    if parsed.tree is None:
        return tables
    # One walk feeds all three tables: imports, definitions, and receivers (any
    # statement can bind a receiver, including definitions' bodies).
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
