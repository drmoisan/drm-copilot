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
    """One command-tree site of a recognizer (root, command or option).

    Recognizers create sites with recognizer-local identifiers; analyze_cli prefixes
    the identifiers with the framework, links parents, attaches console scripts and
    turns each resolvable site into one fact. Mutable, because add_command and
    add_typer re-parent a site after it is created.

    Attributes:
        kind: "root", "command" or "option".
        framework: "argparse", "click" or "typer".
        site_id: The recognizer-local identifier (a receiver or function name, or a
            synthesized "#..." identifier).
        parent_id: The parent site identifier, or None for a root.
        name: The literal command or option name, or None when it is derived.
        span: (first line, last line) of the site.
        properties: The element properties of the site.
        default_name: The framework default command name, used when name is None.
        attach: The attribute name a console script can attach to (roots only).
        is_group: True for a site that can hold subcommands.
    """

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
    """The sites and raw diagnostics of one recognizer over one input.

    Attributes:
        sites: The recognized sites in creation order.
        diagnostics: The raw diagnostics of the recognizer.
    """

    sites: list[CliSite] = field(default_factory=lambda: [])
    diagnostics: list[RawDiagnostic] = field(default_factory=lambda: [])


def has_star(call: ast.Call) -> bool:
    """Report whether a call passes *args or **kwargs.

    Args:
        call: The call node.

    Returns:
        True when any positional argument is starred or any keyword is unnamed.
    """
    return any(isinstance(a, ast.Starred) for a in call.args) or any(
        k.arg is None for k in call.keywords
    )


def keyword(call: ast.Call, name: str) -> ast.expr | None:
    """Return the value of a named keyword argument.

    Args:
        call: The call node.
        name: The keyword name.

    Returns:
        The value of the first keyword with that name, or None when absent.
    """
    # The first matching keyword wins, as Python rejects duplicates at call time.
    for item in call.keywords:
        if item.arg == name:
            return item.value
    return None


def has_keyword(call: ast.Call, name: str) -> bool:
    """Report whether a call passes the named keyword argument.

    Args:
        call: The call node.
        name: The keyword name.

    Returns:
        True when a keyword with that name is present, whatever its value.
    """
    return any(item.arg == name for item in call.keywords)


def literal_bool(node: ast.expr | None) -> bool | None:
    """Return the value of a literal boolean constant.

    Args:
        node: Any expression, or None.

    Returns:
        True or False for a True or False constant, else None.
    """
    if isinstance(node, ast.Constant) and isinstance(node.value, bool):
        return node.value
    return None


def statement_index(tree: ast.Module) -> dict[ast.AST, ast.stmt]:
    """Map every node to its innermost enclosing statement.

    Args:
        tree: The module to index.

    Returns:
        A dict from each node (statements map to themselves) to its innermost
        statement; the module node itself is absent.
    """
    owner: dict[ast.AST, ast.stmt] = {}
    stack: list[tuple[ast.AST, ast.stmt | None]] = [(tree, None)]
    # Iterative walk carrying the nearest statement seen on the way down.
    while stack:
        node, statement = stack.pop()
        current = node if isinstance(node, ast.stmt) else statement
        if current is not None:
            owner[node] = current
        # Every child inherits the current statement as its owner candidate.
        for child in ast.iter_child_nodes(node):
            stack.append((child, current))
    return owner


def site_span(node: ast.expr, statement: ast.stmt | None) -> tuple[int, int]:
    """Return the logical-line span of a call.

    A call inside a simple statement spans that statement (its logical line); a call in
    a compound-statement header, or with no statement, spans the call itself.

    Args:
        node: The call expression.
        statement: The innermost statement that owns the call, or None.

    Returns:
        (first line, last line).
    """
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
    """Return the receiver name that a statement binds.

    Args:
        tables: The file's binding tables.
        statement: The statement to inspect, or None.

    Returns:
        The bound name when the statement is the recorded binding of a receiver, else
        None (not an assignment, a non-name target, or another binding statement).
    """
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
    """Return the dotted chain that starts an expression (its first callee).

    Args:
        node: A decorator or call expression.

    Returns:
        The dotted name reached by peeling calls, attributes and subscripts from the
        outside in, or None when the chain does not start with a name.
    """
    current: ast.expr = node
    # Peel one layer per iteration until a dotted name is found or nothing is left.
    while True:
        chain = dotted_name(current)
        if chain is not None:
            return chain
        # Routing: a call peels to its callee, an attribute or subscript to its value;
        # any other node has no leading chain.
        if isinstance(current, ast.Call):
            current = current.func
        elif isinstance(current, (ast.Attribute, ast.Subscript)):
            current = current.value
        else:
            return None


def decorator_call(decorator: ast.expr) -> ast.Call | None:
    """Return the call of a decorator of the form NAME(.NAME)*(...).

    Args:
        decorator: One element of a decorator_list.

    Returns:
        The innermost call whose callee is a dotted name, or None for a bare
        decorator or a call of a non-name expression.
    """
    current: ast.expr = decorator
    # Descend through calls of calls until the callee is a dotted name.
    while isinstance(current, ast.Call):
        if dotted_name(current.func) is not None:
            return current
        current = current.func
    return None


def function_header_nodes(tree: ast.Module) -> set[ast.AST]:
    """Return every node of a def header (decorators, parameters, return annotation).

    Recognizers skip these nodes when they look for registration calls, so a
    decorator call is not also read as a call statement.

    Args:
        tree: The module to scan.

    Returns:
        The set of header nodes of every function and async function.
    """
    nodes: set[ast.AST] = set()
    # Collect the header parts of every def, at any depth.
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            # Decorators, the argument list and the return annotation form the header.
            for part in [*node.decorator_list, node.args, node.returns]:
                if part is not None:
                    nodes.update(ast.walk(part))
    return nodes
