"""argparse command-tree recognizer: parser roots, subcommands and options.

Reproduces DocsPythonCliArgparse.psm1 of issue 1022 over the syntax tree. Group
receivers (add_argument_group, add_mutually_exclusive_group) map to their parser;
aliases= is not read.
"""

from __future__ import annotations

import ast
from dataclasses import dataclass
from typing import TYPE_CHECKING

from docs_python_native.call_sites import (
    DYNAMIC,
    IN_LOOP,
    UNBOUND,
    CliResult,
    CliSite,
    PropertyValue,
    binding_name,
    has_keyword,
    has_star,
    keyword,
    literal_bool,
    site_span,
    statement_index,
)
from docs_python_native.facts import RawDiagnostic
from docs_python_native.source import ParsedModule, dotted_name, literal_string
from docs_python_native.walk import Context, walk_with_context

if TYPE_CHECKING:
    from docs_python_native.imports import ModuleTables

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
PARENTS = "CLI_PARENTS_UNRESOLVED"


@dataclass(frozen=True)
class _Node:
    """The resolved role of an argparse receiver.

    Attributes:
        kind: "root", "subparsers", "command" or "group".
        parser: The receiver name of the parser that options on this node attach to.
    """

    kind: str
    parser: str


def _resolve(
    name: str, tables: ModuleTables, memo: dict[str, _Node | None], visiting: set[str]
) -> _Node | None:
    """Resolve a receiver name to its argparse role through its constructor chain.

    Args:
        name: The receiver name.
        tables: The file's binding tables.
        memo: Resolved roles by name; filled as names resolve.
        visiting: Names on the current resolution path, to stop on a cycle.

    Returns:
        The role, or None for a name that is not an argparse receiver.
    """
    if name in memo:
        return memo[name]
    receiver = tables.receivers.get(name)
    if receiver is None or name in visiting:
        return None
    visiting.add(name)
    parts = receiver.callee.split(".")
    node: _Node | None = None
    # A qualified ArgumentParser is a root; a method call on a resolved receiver takes
    # a role from the method and the parent's role; anything else stays unresolved.
    if tables.qualify(receiver.callee) == CONSTRUCTOR:
        node = _Node("root", name)
    elif len(parts) == 2 and parts[1] in METHODS:
        parent = _resolve(parts[0], tables, memo, visiting)
        if parent is not None:
            method = parts[1]
            # Routing: add_subparsers on a parser, add_parser on a subparsers object,
            # and a group method on a parser; other combinations give no role.
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
    """Return the name of the innermost function whose body contains a call.

    Args:
        tree: The module to search.
        call: The parser constructor call.

    Returns:
        The function name (the latest-starting enclosing def), or None at module level.
    """
    found: tuple[int, str] | None = None
    # Among the defs whose body contains the call, keep the one that starts last.
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            if any(inner is call for stmt in node.body for inner in ast.walk(stmt)):
                if found is None or node.lineno > found[0]:
                    found = (node.lineno, node.name)
    return None if found is None else found[1]


def _option(call: ast.Call) -> tuple[str, dict[str, PropertyValue]] | None:
    """Read the name and properties of an add_argument call.

    Args:
        call: The add_argument call.

    Returns:
        (name, properties), where the name is the first long flag, else the first short
        flag, else the positional name; None when the call has a star argument, no
        arguments, or a non-literal name.
    """
    if has_star(call) or not call.args:
        return None
    strings: list[str] = []
    # Every positional name must be a literal string.
    for argument in call.args:
        value = literal_string(argument)
        if value is None:
            return None
        strings.append(value)
    # Split the declared names into long (--x) and short (-x) flags.
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
    # Copy the literal action and help keywords when present.
    for key in ("action", "help"):
        value = literal_string(keyword(call, key))
        if value is not None:
            properties[key] = value
    return name, properties


def _unbound_attribute(call: ast.Call) -> bool:
    """Report whether a call invokes an argparse method on a non-name receiver.

    Args:
        call: Any call.

    Returns:
        True for receiver.method(...) where method is an argparse method and the
        receiver is not a dotted name (for example a call or subscript).
    """
    func = call.func
    return (
        isinstance(func, ast.Attribute)
        and func.attr in METHODS
        and dotted_name(func) is None
    )


def recognize_argparse(parsed: ParsedModule, tables: ModuleTables) -> CliResult:
    """Return the argparse sites and diagnostics of one parsed input.

    Args:
        parsed: The parsed module.
        tables: Its binding tables.

    Returns:
        The roots (bound ArgumentParser constructors), commands (add_parser) and
        options (add_argument) with the 1022 diagnostics for unbound, looped and
        dynamic registrations.
    """
    result = CliResult()
    tree = parsed.tree
    if tree is None:
        return result
    owner = statement_index(tree)
    memo: dict[str, _Node | None] = {}
    option_index = 0
    # Each argparse call is classified in order: unbound receiver, constructor or
    # method, loop placement, then command or option site.
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
        # A constructor counts only as the bound receiver's own call; a method call
        # must be on a resolvable receiver, and structural methods produce no site.
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
    """Report whether a registration repeats at run time.

    Args:
        context: The call's enclosing-block context.

    Returns:
        True inside a loop body or a comprehension.
    """
    return context.in_loop or context.in_comprehension


def _tracked_other(tables: ModuleTables, name: str) -> bool:
    """Report whether a name is a receiver of some non-argparse callee.

    Such a receiver (for example a Click group calling add_argument-like methods) is
    silently skipped rather than reported as unbound.

    Args:
        tables: The file's binding tables.
        name: The receiver name.

    Returns:
        True when the name is a receiver whose callee is neither an argparse method
        nor the ArgumentParser constructor.
    """
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
    """Build the root or command site of an ArgumentParser or add_parser call.

    Args:
        call: The constructor or add_parser call.
        constructor: True for an ArgumentParser constructor.
        bound: The receiver name the call is bound to, or None.
        target: The resolved role of the add_parser receiver, or None for a root.
        span: The logical-line span of the call.
        tree: The module, used to find the function a root lives in.
        result: Receives CLI_DYNAMIC_REGISTRATION and CLI_PARENTS_UNRESOLVED.

    Returns:
        The site, or None when the name (prog= or the add_parser name) is dynamic.
    """
    name: str | None = None
    # A root reads an optional literal prog=; a command needs a literal first argument.
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
