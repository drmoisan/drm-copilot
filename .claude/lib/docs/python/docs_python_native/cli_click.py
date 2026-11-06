"""Click command-tree recognizer: commands, groups, add_command and parameters.

Reproduces DocsPythonCliClick.psm1 of issue 1022 over the syntax tree.
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
    decorator_call,
    function_header_nodes,
    has_keyword,
    has_star,
    keyword,
    leading_chain,
    literal_bool,
)
from docs_python_native.facts import RawDiagnostic
from docs_python_native.source import (
    ParsedModule,
    decorator_span,
    dotted_name,
    header_span,
    literal_string,
)
from docs_python_native.walk import Context, walk_with_context

if TYPE_CHECKING:
    from docs_python_native.imports import ModuleTables

DECORATORS = frozenset({"click.command", "click.group"})
PARAMETERS = frozenset({"click.option", "click.argument"})
CUSTOM_CLASSES = frozenset({"click.Group", "click.Command", "click.CommandCollection"})
SUFFIXES = ("-command", "-cmd", "-group", "-grp")
CUSTOM_CLASS = "CLI_CUSTOM_CLASS"
INDIRECT = "CLI_DECORATOR_INDIRECT"
FunctionNode = ast.FunctionDef | ast.AsyncFunctionDef


def click_default_name(function_name: str) -> str:
    """Apply the Click default command-name rule to a function name.

    Args:
        function_name: The decorated function's name.

    Returns:
        The name lower-cased with "_" as "-" and one of the suffixes -command, -cmd,
        -group or -grp removed when the name is longer than the suffix.
    """
    name = function_name.lower().replace("_", "-")
    # Only the first matching suffix is removed, as Click does.
    for suffix in SUFFIXES:
        if name.endswith(suffix) and len(name) > len(suffix):
            return name[: -len(suffix)]
    return name


def _parameter(
    call: ast.Call | None, is_argument: bool
) -> tuple[str, dict[str, PropertyValue]] | None:
    """Read the name and properties of a click.option or click.argument decorator.

    Args:
        call: The decorator call, or None for a bare decorator.
        is_argument: True for click.argument (positional).

    Returns:
        (name, properties), where an option name is the first long flag, else the first
        short flag, else the first declared name; None when the call is absent, has a
        star argument, no arguments, or a non-literal declaration.
    """
    if call is None or has_star(call) or not call.args:
        return None
    strings: list[str] = []
    # Collect every declared name; "--flag/--no-flag" declares two names.
    for argument in call.args:
        value = literal_string(argument)
        if value is None:
            return None
        strings.extend(piece for piece in value.split("/") if piece)
    if not strings:
        return None
    properties: dict[str, PropertyValue] = {
        "framework": "click",
        "has_default": has_keyword(call, "default"),
    }
    # An argument is named by its first declaration; an option prefers flags.
    if is_argument:
        name = strings[0]
        properties["positional"] = True
    else:
        # Split the declared names into long (--x) and short (-x) flags.
        longs = [s for s in strings if s.startswith("--")]
        shorts = [s for s in strings if s.startswith("-") and not s.startswith("--")]
        name = longs[0] if longs else shorts[0] if shorts else strings[0]
        properties["positional"] = False
        if longs and shorts:
            properties["short"] = shorts[0]
    required = literal_bool(keyword(call, "required"))
    if required is not None:
        properties["required"] = required
    help_text = literal_string(keyword(call, "help"))
    if help_text is not None:
        properties["help"] = help_text
    return name, properties


def literal_name(call: ast.Call | None) -> tuple[str | None, bool]:
    """Return the literal command name of a decorator or registration call.

    Args:
        call: The call, or None for a bare decorator.

    Returns:
        (name, dynamic) from name= or the first positional argument: (literal, False),
        (None, False) when no name is given, or (None, True) when the name is not a
        literal (or only a star argument could supply it).
    """
    if call is None:
        return None, False
    argument = keyword(call, "name")
    if argument is None and call.args:
        argument = call.args[0]
    if argument is None:
        return None, has_star(call)
    value = literal_string(argument)
    return value, value is None


@dataclass
class _Pending:
    """A decorated function that may become a Click command site.

    Attributes:
        node: The decorated function.
        context: Its enclosing-block context.
        group: The group receiver of a group.command/group.group decorator, or None
            for click.command/click.group.
        is_group: True for a group decorator.
        call: The command decorator call, or None for a bare decorator.
        indirect: True when a decorator goes through a name derived from click.
        options: (decorator, is_argument) pairs of the parameter decorators.
    """

    node: FunctionNode
    context: Context
    group: str | None
    is_group: bool
    call: ast.Call | None
    indirect: bool
    options: list[tuple[ast.expr, bool]]


def _indirect_names(tree: ast.Module, tables: ModuleTables) -> set[str]:
    """Return names assigned from an expression that mentions click.

    A decorator through such a name (for example cmd = click.command) cannot be read
    statically and is reported as CLI_DECORATOR_INDIRECT.

    Args:
        tree: The module to scan.
        tables: The file's binding tables, used to qualify names.

    Returns:
        The first assignment target names whose value or later targets mention click.
    """
    names: set[str] = set()
    # Check every single-name assignment at any depth.
    for node in ast.walk(tree):
        if not isinstance(node, ast.Assign) or not isinstance(
            node.targets[0], ast.Name
        ):
            continue
        parts: list[ast.AST] = [*node.targets[1:], node.value]
        # Any Name inside the remaining targets or the value that qualifies to click
        # marks the first target as indirect.
        for part in parts:
            # Inspect every name node within this part.
            for inner in ast.walk(part):
                if isinstance(inner, ast.Name):
                    qualified = tables.qualify(inner.id)
                    if qualified is not None and (
                        qualified == "click" or qualified.startswith("click.")
                    ):
                        names.add(node.targets[0].id)
    return names


def _pending(
    node: FunctionNode, context: Context, tables: ModuleTables, indirect: set[str]
) -> _Pending | None:
    """Classify the decorators of one function.

    Args:
        node: The function definition.
        context: Its enclosing-block context.
        tables: The file's binding tables.
        indirect: The indirect decorator names of the file.

    Returns:
        A _Pending for a command or group (the last command decorator wins), an
        indirect _Pending when a decorator goes through an indirect name, or None.
    """
    found: _Pending | None = None
    options: list[tuple[ast.expr, bool]] = []
    # Decorators are read top to bottom; parameters collect into the shared list.
    for decorator in node.decorator_list:
        callee = leading_chain(decorator)
        if callee is None:
            continue
        parts = callee.split(".")
        if parts[0] in indirect:
            return _Pending(node, context, None, False, None, True, [])
        qualified = tables.qualify(callee)
        if qualified is None:
            continue
        call = decorator_call(decorator)
        # Routing: click.command/group is a root candidate, click.option/argument a
        # parameter, and <name>.command/group a subcommand of a group receiver.
        if qualified in DECORATORS:
            found = _Pending(
                node, context, None, qualified == "click.group", call, False, options
            )
        elif qualified in PARAMETERS:
            options.append((decorator, qualified == "click.argument"))
        elif len(parts) == 2 and parts[1] in ("command", "group"):
            found = _Pending(
                node, context, parts[0], parts[1] == "group", call, False, options
            )
    return found


def recognize_click(parsed: ParsedModule, tables: ModuleTables) -> CliResult:
    """Return the Click sites and diagnostics of one parsed input.

    Args:
        parsed: The parsed module.
        tables: Its binding tables.

    Returns:
        Command, group and parameter sites, re-parented by add_command, with the 1022
        diagnostics for custom classes, indirect decorators and dynamic, looped or
        unbound registrations.
    """
    result = CliResult()
    tree = parsed.tree
    if tree is None:
        return result
    indirect = _indirect_names(tree, tables)
    header_nodes = function_header_nodes(tree)
    pending: list[_Pending] = []
    adds: list[tuple[ast.Call, Context, str]] = []
    # Collect decorated functions and calls in one walk; decorator calls are skipped.
    for node, context in walk_with_context(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            item = _pending(node, context, tables, indirect)
            if item is not None:
                pending.append(item)
            continue
        if not isinstance(node, ast.Call) or node in header_nodes:
            continue
        qualified = tables.qualify(dotted_name(node.func))
        inner = node.func
        # Routing: a custom command class, a click decorator called indirectly, or a
        # group.add_command registration that is applied after all sites exist.
        if qualified is not None and qualified in CUSTOM_CLASSES:
            result.diagnostics.append(RawDiagnostic(CUSTOM_CLASS, node.lineno))
        elif (
            isinstance(inner, ast.Call)
            and tables.qualify(dotted_name(inner.func)) in DECORATORS
        ):
            result.diagnostics.append(RawDiagnostic(INDIRECT, node.lineno))
        else:
            callee = dotted_name(node.func)
            parts = callee.split(".") if callee is not None else []
            if len(parts) == 2 and parts[1] == "add_command":
                adds.append((node, context, parts[0]))
    # Root groups are the click.group functions; nested group decorators extend the
    # set until no new group is found (a fixed point, so declaration order is free).
    groups = {
        p.node.name
        for p in pending
        if p.is_group and p.group is None and not p.indirect
    }
    changed = True
    # Repeat until a full pass adds no group.
    while changed:
        changed = False
        # Promote a nested group whose parent group is already known.
        for item in pending:
            if item.group is not None and item.is_group and item.group in groups:
                if item.node.name not in groups:
                    groups.add(item.node.name)
                    changed = True
    by_id: dict[str, CliSite] = {}
    option_index = 0
    # Emit each command site followed by the sites of its parameter decorators.
    for item in pending:
        site = _command_site(parsed, item, groups, tables, result)
        if site is None:
            continue
        result.sites.append(site)
        by_id[site.site_id] = site
        # A parameter with a dynamic declaration is reported instead of emitted.
        for decorator, is_argument in item.options:
            span = decorator_span(parsed, decorator)
            parameter = _parameter(decorator_call(decorator), is_argument)
            if parameter is None:
                result.diagnostics.append(RawDiagnostic(DYNAMIC, span[0]))
                continue
            option_index += 1
            result.sites.append(
                CliSite(
                    "option",
                    "click",
                    f"#option-{option_index}",
                    site.site_id,
                    parameter[0],
                    span,
                    parameter[1],
                )
            )
    # Apply add_command after every site exists, so order in the file does not matter.
    for call, context, group in adds:
        _apply_add(call, context, group, groups, by_id, tables, result)
    return result


def _command_site(
    parsed: ParsedModule,
    item: _Pending,
    groups: set[str],
    tables: ModuleTables,
    result: CliResult,
) -> CliSite | None:
    """Build the command or root site of a pending function, or report why not.

    Args:
        parsed: The parsed module.
        item: The pending function.
        groups: The known group function names.
        tables: The file's binding tables.
        result: Receives the diagnostics.

    Returns:
        The site, or None for an indirect decorator, an unknown group, a looped
        definition, a custom cls= or a dynamic name (each reported, except a group
        receiver that is bound but not a Click group).
    """
    span = header_span(parsed, item.node)
    line = span[0]
    if item.indirect:
        result.diagnostics.append(RawDiagnostic(INDIRECT, line))
        return None
    group = item.group
    if group is not None and group not in groups:
        if not tables.is_known_name(group):
            result.diagnostics.append(RawDiagnostic(UNBOUND, line))
        return None
    if item.context.in_loop:
        result.diagnostics.append(RawDiagnostic(IN_LOOP, line))
        return None
    if item.call is not None and has_keyword(item.call, "cls"):
        result.diagnostics.append(RawDiagnostic(CUSTOM_CLASS, line))
        return None
    name, dynamic = literal_name(item.call)
    if dynamic:
        result.diagnostics.append(RawDiagnostic(DYNAMIC, line))
        return None
    return CliSite(
        "root" if group is None else "command",
        "click",
        item.node.name,
        group,
        name,
        span,
        {"framework": "click"},
        default_name=click_default_name(item.node.name),
        attach=item.node.name if group is None else None,
        is_group=item.is_group,
    )


def _apply_add(
    call: ast.Call,
    context: Context,
    group: str,
    groups: set[str],
    by_id: dict[str, CliSite],
    tables: ModuleTables,
    result: CliResult,
) -> None:
    """Re-parent a command under a group for group.add_command(command[, name=]).

    Args:
        call: The add_command call.
        context: Its enclosing-block context.
        group: The receiver name the call is made on.
        groups: The known group function names.
        by_id: Command sites by identifier; the target site is mutated.
        tables: The file's binding tables.
        result: Receives the diagnostics.

    Returns:
        None. The target becomes a command of the group, optionally renamed.
    """
    if context.in_loop:
        result.diagnostics.append(RawDiagnostic(IN_LOOP, call.lineno))
        return
    if group not in groups:
        if not tables.is_known_name(group):
            result.diagnostics.append(RawDiagnostic(UNBOUND, call.lineno))
        return
    first = call.args[0] if call.args else None
    if not isinstance(first, ast.Name):
        return
    target = by_id.get(first.id)
    if target is None or target.kind == "option":
        return
    if has_keyword(call, "name"):
        value = literal_string(keyword(call, "name"))
        if value is None:
            result.diagnostics.append(RawDiagnostic(DYNAMIC, call.lineno))
            return
        target.name = value
    target.kind = "command"
    target.parent_id = group
    target.attach = None
