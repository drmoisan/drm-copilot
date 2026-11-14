"""argparse command-tree recognizer: parser roots, subcommands and options.

Reproduces DocsPythonCliArgparse.psm1 of issue 1022 over the syntax tree. Group
receivers (add_argument_group, add_mutually_exclusive_group) map to their parser;
aliases= is not read. A function parameter used as an add_parser receiver is a
provisional subparsers role, and a call that passes a resolved subparsers receiver to a
function is a handoff; analyze_cli binds the two across modules (issue 1173 B9).
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
    ProvisionalRole,
    RoleHandoff,
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


@dataclass
class _Scope:
    """The function scope of the calls of one input and its provisional roles.

    Built once per input by _scope. Maps every node inside a function body to the
    innermost def that contains it, and every (def, parameter) pair that is an
    add_parser receiver to its ProvisionalRole (issue 1173 B9).

    Attributes:
        owner: Node to the innermost enclosing def.
        roles: (def, parameter name) to the provisional role, in source order.
    """

    owner: dict[ast.AST, ast.FunctionDef | ast.AsyncFunctionDef]
    roles: dict[tuple[ast.AST, str], ProvisionalRole]


def _scope(tree: ast.Module, tables: ModuleTables) -> _Scope:
    """Map nodes to their innermost def and seed the provisional subparsers roles.

    Args:
        tree: The parsed module.
        tables: The file's binding tables.

    Returns:
        The scope. A role is seeded for a parameter of the innermost enclosing def that
        is the receiver of an add_parser call and is not a tracked receiver name.
    """
    defs = [
        node
        for node in ast.walk(tree)
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
    ]
    owner: dict[ast.AST, ast.FunctionDef | ast.AsyncFunctionDef] = {}
    # Map body nodes outermost def first, so an inner def (which starts later)
    # overwrites the owner of its own nodes.
    for function in sorted(defs, key=lambda d: (d.lineno, d.col_offset)):
        # Every node of every body statement belongs to this def until overwritten.
        for statement in function.body:
            for inner in ast.walk(statement):
                owner[inner] = function
    roles: dict[tuple[ast.AST, str], ProvisionalRole] = {}
    # Seed one role per (def, parameter) that receives an add_parser call.
    for node in ast.walk(tree):
        func = node.func if isinstance(node, ast.Call) else None
        if not (
            isinstance(func, ast.Attribute)
            and func.attr == "add_parser"
            and isinstance(func.value, ast.Name)
            and func.value.id not in tables.receivers
            and node in owner
        ):
            continue
        function = owner[node]
        position = _parameter_position(function, func.value.id)
        key = (function, func.value.id)
        if position is not None and key not in roles:
            site_id = f"#param-{function.name}-{func.value.id}"
            roles[key] = ProvisionalRole(
                site_id, function.name, func.value.id, position
            )
    return _Scope(owner, roles)


def _parameter_position(
    function: ast.FunctionDef | ast.AsyncFunctionDef, name: str
) -> int | None:
    """Return the signature position of a parameter of a def.

    Args:
        function: The def.
        name: The parameter name.

    Returns:
        The zero-based position among the positional parameters, -1 for a keyword-only
        parameter (bound by keyword only), or None when the def has no such parameter.
    """
    positional = [*function.args.posonlyargs, *function.args.args]
    # Positional parameters bind by position or keyword; keyword-only ones by keyword.
    for index, argument in enumerate(positional):
        if argument.arg == name:
            return index
    if any(argument.arg == name for argument in function.args.kwonlyargs):
        return -1
    return None


def _role(
    name: str,
    call: ast.AST,
    tables: ModuleTables,
    scope: _Scope,
    memo: dict[str, _Node | None],
    visiting: set[str],
) -> _Node | None:
    """Resolve a receiver name used by a call: a tracked receiver or a provisional role.

    Args:
        name: The receiver name.
        call: The call (or receiver binding call) that uses the name.
        tables: The file's binding tables.
        scope: The function scope and provisional roles of the input.
        memo: Resolved receiver roles by name.
        visiting: Names on the current resolution path.

    Returns:
        The role of a tracked receiver; for an untracked name that is a seeded
        parameter of the call's innermost def, a subparsers role whose parser is the
        placeholder identifier; otherwise None.
    """
    if name in tables.receivers:
        return _resolve(name, tables, scope, memo, visiting)
    function = scope.owner.get(call)
    role = None if function is None else scope.roles.get((function, name))
    return None if role is None else _Node("subparsers", role.site_id)


def _resolve(
    name: str,
    tables: ModuleTables,
    scope: _Scope,
    memo: dict[str, _Node | None],
    visiting: set[str],
) -> _Node | None:
    """Resolve a receiver name to its argparse role through its constructor chain.

    Args:
        name: The receiver name.
        tables: The file's binding tables.
        scope: The function scope and provisional roles of the input.
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
        parent = _role(parts[0], receiver.call, tables, scope, memo, visiting)
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
    scope = _scope(tree, tables)
    result.provisional.extend(scope.roles.values())
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
        result.handoffs.extend(_handoffs(node, callee, tables, scope, memo))
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
            target = _role(parts[0], node, tables, scope, memo, set())
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


def _handoffs(
    call: ast.Call,
    callee: str,
    tables: ModuleTables,
    scope: _Scope,
    memo: dict[str, _Node | None],
) -> list[RoleHandoff]:
    """Return the handoffs of one call: subparsers receivers passed as arguments.

    Args:
        call: Any call with a dotted callee.
        callee: The dotted callee as written.
        tables: The file's binding tables.
        scope: The function scope and provisional roles of the input.
        memo: Resolved receiver roles by name.

    Returns:
        One RoleHandoff per positional or keyword argument that is a name resolving to
        a subparsers role; empty for a call with a star argument or an ambiguous callee.
    """
    qualified = tables.qualify(callee)
    if qualified is None or has_star(call):
        return []
    found: list[RoleHandoff] = []
    # Positional arguments bind by index, keyword arguments by name.
    arguments: list[tuple[int | None, str | None, ast.expr]] = [
        (index, None, value) for index, value in enumerate(call.args)
    ]
    arguments.extend((None, item.arg, item.value) for item in call.keywords)
    # Keep each argument that is a plain name holding a subparsers receiver.
    for position, name, value in arguments:
        if not isinstance(value, ast.Name):
            continue
        role = _role(value.id, call, tables, scope, memo, set())
        if role is not None and role.kind == "subparsers":
            found.append(RoleHandoff(qualified, position, name, role.parser))
    return found


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
