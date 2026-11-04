"""argparse command-tree recognizer: parser roots, subcommands and options.

Reproduces DocsPythonCliArgparse.psm1 of issue 1022 over the syntax tree. Group
receivers (add_argument_group, add_mutually_exclusive_group) map to their parser;
aliases= is not read.
"""

from __future__ import annotations

import ast
from dataclasses import dataclass, field

from docs_python_native.imports import ModuleTables, RawDiagnostic
from docs_python_native.source import (
    Context,
    ParsedModule,
    dotted_name,
    literal_string,
    walk_with_context,
)

PropertyValue = str | bool | int
CONSTRUCTOR = "argparse.ArgumentParser"
METHODS = frozenset(
    {
        "add_argument",
        "add_parser",
        "add_subparsers",
        "add_argument_group",
        "add_mutually_exclusive_group",
    }
)
GROUP_METHODS = frozenset({"add_argument_group", "add_mutually_exclusive_group"})
DYNAMIC = "CLI_DYNAMIC_REGISTRATION"
IN_LOOP = "CLI_REGISTRATION_IN_LOOP"
UNBOUND = "CLI_UNBOUND_REGISTRATION"
PARENTS = "CLI_PARENTS_UNRESOLVED"


@dataclass
class CliSite:
    """One command-tree site of a recognizer (root, command or option)."""

    kind: str
    framework: str
    site_id: str
    parent_id: str | None
    name: str | None
    span: tuple[int, int]
    properties: dict[str, PropertyValue]
    default_name: str | None = None
    attach: str | None = None
    is_group: bool = False


@dataclass
class CliResult:
    """The sites and raw diagnostics of one recognizer over one input."""

    sites: list[CliSite] = field(default_factory=lambda: [])
    diagnostics: list[RawDiagnostic] = field(default_factory=lambda: [])


def has_star(call: ast.Call) -> bool:
    """True when a call passes *args or **kwargs."""
    return any(isinstance(a, ast.Starred) for a in call.args) or any(
        k.arg is None for k in call.keywords
    )


def keyword(call: ast.Call, name: str) -> ast.expr | None:
    """Return the value of a named keyword argument, or None."""
    for item in call.keywords:
        if item.arg == name:
            return item.value
    return None


def has_keyword(call: ast.Call, name: str) -> bool:
    """True when a call passes the named keyword argument."""
    return any(item.arg == name for item in call.keywords)


def literal_bool(node: ast.expr | None) -> bool | None:
    """Return True or False for a literal boolean constant, else None."""
    if isinstance(node, ast.Constant) and isinstance(node.value, bool):
        return node.value
    return None


def statement_index(tree: ast.Module) -> dict[ast.AST, ast.stmt]:
    """Map every node to its innermost enclosing statement."""
    owner: dict[ast.AST, ast.stmt] = {}
    stack: list[tuple[ast.AST, ast.stmt | None]] = [(tree, None)]
    while stack:
        node, statement = stack.pop()
        current = node if isinstance(node, ast.stmt) else statement
        if current is not None:
            owner[node] = current
        for child in ast.iter_child_nodes(node):
            stack.append((child, current))
    return owner


def site_span(node: ast.expr, statement: ast.stmt | None) -> tuple[int, int]:
    """Return the logical-line span of a call: its simple statement, else the call."""
    if statement is not None and not hasattr(statement, "body"):
        end = (
            statement.end_lineno
            if statement.end_lineno is not None
            else statement.lineno
        )
        return (statement.lineno, end)
    end = node.end_lineno if node.end_lineno is not None else node.lineno
    return (node.lineno, end)


def binding_name(tables: ModuleTables, statement: ast.stmt | None) -> str | None:
    """Return the receiver name that a statement binds, else None."""
    if not isinstance(statement, (ast.Assign, ast.AnnAssign)):
        return None
    target = (
        statement.targets[0] if isinstance(statement, ast.Assign) else statement.target
    )
    if not isinstance(target, ast.Name):
        return None
    receiver = tables.receivers.get(target.id)
    if receiver is None or receiver.statement is not statement:
        return None
    return target.id


@dataclass(frozen=True)
class _Node:
    kind: str
    parser: str


def _resolve(
    name: str, tables: ModuleTables, memo: dict[str, _Node | None], visiting: set[str]
) -> _Node | None:
    if name in memo:
        return memo[name]
    receiver = tables.receivers.get(name)
    if receiver is None or name in visiting:
        return None
    visiting.add(name)
    parts = receiver.callee.split(".")
    node: _Node | None = None
    if tables.qualify(receiver.callee) == CONSTRUCTOR:
        node = _Node("root", name)
    elif len(parts) == 2 and parts[1] in METHODS:
        parent = _resolve(parts[0], tables, memo, visiting)
        if parent is not None:
            method = parts[1]
            if method == "add_subparsers" and parent.kind in ("root", "command"):
                node = _Node("subparsers", parent.parser)
            elif method == "add_parser" and parent.kind == "subparsers":
                node = _Node("command", name)
            elif method in GROUP_METHODS and parent.kind in ("root", "command"):
                node = _Node("group", parent.parser)
    visiting.discard(name)
    memo[name] = node
    return node


def _innermost_function(tree: ast.Module, call: ast.Call) -> str | None:
    found: tuple[int, str] | None = None
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            if any(inner is call for stmt in node.body for inner in ast.walk(stmt)):
                if found is None or node.lineno > found[0]:
                    found = (node.lineno, node.name)
    return None if found is None else found[1]


def _option(call: ast.Call) -> tuple[str, dict[str, PropertyValue]] | None:
    if has_star(call) or not call.args:
        return None
    strings: list[str] = []
    for argument in call.args:
        value = literal_string(argument)
        if value is None:
            return None
        strings.append(value)
    longs = [s for s in strings if s.startswith("--")]
    shorts = [s for s in strings if s.startswith("-") and not s.startswith("--")]
    name = longs[0] if longs else shorts[0] if shorts else strings[0]
    properties: dict[str, PropertyValue] = {
        "framework": "argparse",
        "positional": not name.startswith("-"),
        "has_default": has_keyword(call, "default"),
    }
    if longs and shorts:
        properties["short"] = shorts[0]
    required = literal_bool(keyword(call, "required"))
    if required is not None:
        properties["required"] = required
    for key in ("action", "help"):
        value = literal_string(keyword(call, key))
        if value is not None:
            properties[key] = value
    return name, properties


def _unbound_attribute(call: ast.Call) -> bool:
    func = call.func
    return (
        isinstance(func, ast.Attribute)
        and func.attr in METHODS
        and dotted_name(func) is None
    )


def recognize_argparse(parsed: ParsedModule, tables: ModuleTables) -> CliResult:
    """Return the argparse sites and diagnostics of one parsed input."""
    result = CliResult()
    tree = parsed.tree
    if tree is None:
        return result
    owner = statement_index(tree)
    memo: dict[str, _Node | None] = {}
    option_index = 0
    for node, context in walk_with_context(tree):
        if not isinstance(node, ast.Call):
            continue
        statement = owner.get(node)
        span = site_span(node, statement)
        if _unbound_attribute(node):
            result.diagnostics.append(RawDiagnostic(UNBOUND, span[0]))
            continue
        callee = dotted_name(node.func)
        if callee is None:
            continue
        parts = callee.split(".")
        constructor = tables.qualify(callee) == CONSTRUCTOR
        method = parts[-1] if len(parts) >= 2 and parts[-1] in METHODS else None
        if not constructor and method is None:
            continue
        bound = binding_name(tables, statement)
        target: _Node | None = None
        if constructor:
            if bound is None or tables.receivers[bound].call is not node:
                continue
        else:
            if len(parts) != 2:
                result.diagnostics.append(RawDiagnostic(UNBOUND, span[0]))
                continue
            target = _resolve(parts[0], tables, memo, set())
            if target is None:
                if not _tracked_other(tables, parts[0]):
                    result.diagnostics.append(RawDiagnostic(UNBOUND, span[0]))
                continue
            if method == "add_subparsers" or method in GROUP_METHODS:
                continue
        if _looped(context):
            result.diagnostics.append(RawDiagnostic(IN_LOOP, span[0]))
            continue
        if constructor or method == "add_parser":
            site = _command_site(node, constructor, bound, target, span, tree, result)
            if site is not None:
                result.sites.append(site)
            continue
        option = _option(node)
        if option is None or target is None:
            result.diagnostics.append(RawDiagnostic(DYNAMIC, span[0]))
            continue
        option_index += 1
        result.sites.append(
            CliSite(
                "option",
                "argparse",
                f"#option-{option_index}",
                target.parser,
                option[0],
                span,
                option[1],
            )
        )
    return result


def _looped(context: Context) -> bool:
    return context.in_loop or context.in_comprehension


def _tracked_other(tables: ModuleTables, name: str) -> bool:
    other = tables.receivers.get(name)
    if other is None:
        return False
    return (
        other.callee.split(".")[-1] not in METHODS
        and tables.qualify(other.callee) != CONSTRUCTOR
    )


def _command_site(
    call: ast.Call,
    constructor: bool,
    bound: str | None,
    target: _Node | None,
    span: tuple[int, int],
    tree: ast.Module,
    result: CliResult,
) -> CliSite | None:
    name: str | None = None
    if constructor:
        if has_keyword(call, "prog"):
            name = literal_string(keyword(call, "prog"))
            if name is None:
                result.diagnostics.append(RawDiagnostic(DYNAMIC, span[0]))
                return None
    else:
        name = (
            literal_string(call.args[0]) if call.args and not has_star(call) else None
        )
        if name is None:
            result.diagnostics.append(RawDiagnostic(DYNAMIC, span[0]))
            return None
    if has_keyword(call, "parents"):
        result.diagnostics.append(RawDiagnostic(PARENTS, span[0]))
    properties: dict[str, PropertyValue] = {"framework": "argparse"}
    help_text = literal_string(keyword(call, "help"))
    if help_text is not None:
        properties["help"] = help_text
    site_id = bound if bound else f"#argparse-{span[0]}-{call.col_offset}"
    if constructor:
        attach = _innermost_function(tree, call) or site_id
        return CliSite(
            "root", "argparse", site_id, None, name, span, properties, attach=attach
        )
    parent = target.parser if target is not None else None
    return CliSite("command", "argparse", site_id, parent, name, span, properties)
