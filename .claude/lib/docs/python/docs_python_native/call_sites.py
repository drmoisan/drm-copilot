"""Call-site helpers and the site model shared by the CLI and HTTP recognizers.

The argparse, Click and Typer recognizers and the python-http analyzer read keyword
arguments, statement ownership, logical-line spans and decorator chains the same way;
this module holds that shared vocabulary and the CliSite and CliResult records.
"""

from __future__ import annotations

import ast
from dataclasses import dataclass, field
from typing import TYPE_CHECKING

from docs_python_native.source import dotted_name

if TYPE_CHECKING:
    from docs_python_native.facts import RawDiagnostic
    from docs_python_native.imports import ModuleTables

PropertyValue = str | bool | int
DYNAMIC = "CLI_DYNAMIC_REGISTRATION"
IN_LOOP = "CLI_REGISTRATION_IN_LOOP"
UNBOUND = "CLI_UNBOUND_REGISTRATION"


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


def leading_chain(node: ast.expr) -> str | None:
    """Return the dotted chain that starts an expression (its first callee)."""
    current: ast.expr = node
    while True:
        chain = dotted_name(current)
        if chain is not None:
            return chain
        if isinstance(current, ast.Call):
            current = current.func
        elif isinstance(current, (ast.Attribute, ast.Subscript)):
            current = current.value
        else:
            return None


def decorator_call(decorator: ast.expr) -> ast.Call | None:
    """Return the decorator call when the decorator is NAME(.NAME)*(...), else None."""
    current: ast.expr = decorator
    while isinstance(current, ast.Call):
        if dotted_name(current.func) is not None:
            return current
        current = current.func
    return None


def function_header_nodes(tree: ast.Module) -> set[ast.AST]:
    """Return every node of a def header (decorators, parameters, return annotation)."""
    nodes: set[ast.AST] = set()
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            for part in [*node.decorator_list, node.args, node.returns]:
                if part is not None:
                    nodes.update(ast.walk(part))
    return nodes
