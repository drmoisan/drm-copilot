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
    """Apply the Click default name rule: lower-case, '_' to '-', one suffix removed."""
    name = function_name.lower().replace("_", "-")
    for suffix in SUFFIXES:
        if name.endswith(suffix) and len(name) > len(suffix):
            return name[: -len(suffix)]
    return name


def _parameter(
    call: ast.Call | None, is_argument: bool
) -> tuple[str, dict[str, PropertyValue]] | None:
    if call is None or has_star(call) or not call.args:
        return None
    strings: list[str] = []
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
    if is_argument:
        name = strings[0]
        properties["positional"] = True
    else:
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
    """Return (name, dynamic) from name= or the first positional argument of a call."""
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
    node: FunctionNode
    context: Context
    group: str | None
    is_group: bool
    call: ast.Call | None
    indirect: bool
    options: list[tuple[ast.expr, bool]]


def _indirect_names(tree: ast.Module, tables: ModuleTables) -> set[str]:
    names: set[str] = set()
    for node in ast.walk(tree):
        if not isinstance(node, ast.Assign) or not isinstance(
            node.targets[0], ast.Name
        ):
            continue
        parts: list[ast.AST] = [*node.targets[1:], node.value]
        for part in parts:
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
    found: _Pending | None = None
    options: list[tuple[ast.expr, bool]] = []
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
    """Return the Click sites and diagnostics of one parsed input."""
    result = CliResult()
    tree = parsed.tree
    if tree is None:
        return result
    indirect = _indirect_names(tree, tables)
    header_nodes = function_header_nodes(tree)
    pending: list[_Pending] = []
    adds: list[tuple[ast.Call, Context, str]] = []
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
    groups = {
        p.node.name
        for p in pending
        if p.is_group and p.group is None and not p.indirect
    }
    changed = True
    while changed:
        changed = False
        for item in pending:
            if item.group is not None and item.is_group and item.group in groups:
                if item.node.name not in groups:
                    groups.add(item.node.name)
                    changed = True
    by_id: dict[str, CliSite] = {}
    option_index = 0
    for item in pending:
        site = _command_site(parsed, item, groups, tables, result)
        if site is None:
            continue
        result.sites.append(site)
        by_id[site.site_id] = site
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
