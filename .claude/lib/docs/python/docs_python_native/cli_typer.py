"""Typer command-tree recognizer: roots, commands, callbacks, add_typer and run.

Reproduces DocsPythonCliTyper.psm1 of issue 1022 over the syntax tree.
"""

from __future__ import annotations

import ast
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
    keyword,
    leading_chain,
    site_span,
    statement_index,
)
from docs_python_native.cli_click import literal_name
from docs_python_native.facts import RawDiagnostic
from docs_python_native.source import (
    ParsedModule,
    dotted_name,
    header_span,
    literal_string,
    parameter_span,
    statement_span,
)
from docs_python_native.walk import walk_with_context

if TYPE_CHECKING:
    from docs_python_native.imports import ModuleTables

CONSTRUCTOR = "typer.Typer"
PARAMETERS = frozenset({"typer.Option", "typer.Argument"})
CUSTOM_CLASS = "CLI_CUSTOM_CLASS"
UNRESOLVED = "CLI_TYPER_PARAMETER_UNRESOLVED"
FunctionNode = ast.FunctionDef | ast.AsyncFunctionDef
_BRACKETED = (
    ast.List,
    ast.Tuple,
    ast.Set,
    ast.Dict,
    ast.ListComp,
    ast.SetComp,
    ast.DictComp,
    ast.GeneratorExp,
)


def _typer_call(node: ast.expr, tables: ModuleTables) -> tuple[ast.Call, bool] | None:
    """Recognize a typer.Option(...) or typer.Argument(...) call.

    Args:
        node: Any expression.
        tables: The file's binding tables, used to qualify the callee.

    Returns:
        (call, is_argument), or None when the node is not such a call.
    """
    if isinstance(node, ast.Call):
        qualified = tables.qualify(dotted_name(node.func))
        if qualified in PARAMETERS:
            return node, qualified == "typer.Argument"
    return None


def _first_typer_call(
    node: ast.expr | None, tables: ModuleTables
) -> tuple[ast.Call, bool] | None:
    """Return the first typer.Option or typer.Argument call inside an annotation.

    Args:
        node: The annotation (for example Annotated[str, typer.Option()]), or None.
        tables: The file's binding tables.

    Returns:
        The first such call in source position order, or None.
    """
    if node is None:
        return None
    # Gather every call in the annotation and order them by source position.
    calls = [n for n in ast.walk(node) if isinstance(n, ast.Call)]
    calls.sort(key=lambda n: (n.lineno, n.col_offset))
    # Return the earliest call that is a Typer parameter call.
    for call in calls:
        found = _typer_call(call, tables)
        if found is not None:
            return found
    return None


def plain_default(node: ast.expr) -> bool:
    """Report whether a parameter default is a plain value Typer reads as a default.

    Args:
        node: The default expression.

    Returns:
        True for a literal, a name, an f-string, a negative number or a bracketed
        display or comprehension; False for any other expression (for example a call).
    """
    if isinstance(node, (ast.Constant, ast.Name, ast.JoinedStr)):
        return True
    if (
        isinstance(node, ast.UnaryOp)
        and isinstance(node.op, ast.USub)
        and isinstance(node.operand, ast.Constant)
        and isinstance(node.operand.value, (int, float, complex))
        and not isinstance(node.operand.value, bool)
    ):
        return True
    return isinstance(node, _BRACKETED)


def _is_ellipsis(node: ast.expr | None) -> bool:
    """Report whether an expression is the ... constant (Typer's "required" marker).

    Args:
        node: Any expression, or None.

    Returns:
        True for the Ellipsis constant.
    """
    return isinstance(node, ast.Constant) and node.value is Ellipsis


def _parameters(function: FunctionNode) -> list[tuple[ast.arg, ast.expr | None]]:
    """Pair every positional and keyword-only parameter with its default.

    Args:
        function: The function definition.

    Returns:
        (parameter, default or None) pairs in declaration order; *args and **kwargs
        are not included.
    """
    arguments = function.args
    positional = [*arguments.posonlyargs, *arguments.args]
    defaults: list[ast.expr | None] = [None] * (
        len(positional) - len(arguments.defaults)
    )
    defaults.extend(arguments.defaults)
    pairs = list(zip(positional, defaults, strict=True))
    pairs.extend(zip(arguments.kwonlyargs, arguments.kw_defaults, strict=True))
    return pairs


def parameter_sites(
    function: FunctionNode, owner: str, tables: ModuleTables, result: CliResult
) -> list[CliSite]:
    """Build the option and argument sites of a Typer function.

    Args:
        function: The command, callback or run target function.
        owner: The site identifier the parameters attach to.
        tables: The file's binding tables.
        result: Receives CLI_TYPER_PARAMETER_UNRESOLVED for a default that is neither
            a Typer call nor a plain value.

    Returns:
        One option site per parameter; a parameter is positional when its Typer call is
        typer.Argument, or when it has no Typer call and no default.
    """
    sites: list[CliSite] = []
    # Classify each parameter from its default first, then from its annotation.
    for argument, default in _parameters(function):
        annotation = argument.annotation
        typer_call: tuple[ast.Call, bool] | None = None
        has_default = False
        default_is_typer = False
        # Routing: a Typer call default carries the declaration (its first argument is
        # the default value); a plain default is a default value; anything else
        # cannot be read and the parameter is reported and skipped.
        if default is not None:
            typer_call = _typer_call(default, tables)
            if typer_call is not None:
                default_is_typer = True
                first = typer_call[0].args[0] if typer_call[0].args else None
                has_default = first is not None and not _is_ellipsis(first)
            elif plain_default(default):
                has_default = not _is_ellipsis(default)
            else:
                result.diagnostics.append(RawDiagnostic(UNRESOLVED, argument.lineno))
                continue
        if not default_is_typer:
            annotated = _first_typer_call(annotation, tables)
            if annotated is not None:
                typer_call = annotated
        is_argument = typer_call[1] if typer_call is not None else default is None
        properties: dict[str, PropertyValue] = {
            "framework": "typer",
            "positional": is_argument,
            "has_default": has_default,
        }
        name = argument.arg
        # An option is named by its first declared long flag, else short flag, else
        # the parameter name in Typer's --kebab-case form.
        if not is_argument:
            declared: list[str] = []
            if typer_call is not None:
                # Keep the literal flag declarations of the Typer call.
                for item in typer_call[0].args:
                    value = literal_string(item)
                    if value is not None and value.startswith("-"):
                        declared.append(value)
            # Split the declared flags into long (--x) and short (-x) forms.
            longs = [d for d in declared if d.startswith("--")]
            shorts = [d for d in declared if not d.startswith("--")]
            name = (
                longs[0]
                if longs
                else shorts[0] if shorts else "--" + argument.arg.replace("_", "-")
            )
            if longs and shorts:
                properties["short"] = shorts[0]
        if typer_call is not None:
            help_text = literal_string(keyword(typer_call[0], "help"))
            if help_text is not None:
                properties["help"] = help_text
        span = parameter_span(argument, annotation, default)
        site_id = f"#option-{owner}-{span[0]}-{argument.arg}"
        sites.append(CliSite("option", "typer", site_id, owner, name, span, properties))
    return sites


def recognize_typer(parsed: ParsedModule, tables: ModuleTables) -> CliResult:
    """Return the Typer sites and diagnostics of one parsed input.

    Args:
        parsed: The parsed module.
        tables: Its binding tables.

    Returns:
        Root sites for typer.Typer receivers and typer.run targets, command sites for
        @app.command, parameter sites for commands and callbacks, and add_typer
        re-parenting, with the 1022 diagnostics.
    """
    result = CliResult()
    tree = parsed.tree
    if tree is None:
        return result
    roots: dict[str, CliSite] = {}
    # Every typer.Typer receiver becomes a root unless it uses cls=, is looped or has a
    # dynamic name.
    for receiver in tables.receivers.values():
        if tables.qualify(receiver.callee) != CONSTRUCTOR:
            continue
        line = receiver.statement.lineno
        if has_keyword(receiver.call, "cls"):
            result.diagnostics.append(RawDiagnostic(CUSTOM_CLASS, line))
            continue
        if receiver.context.in_loop:
            result.diagnostics.append(RawDiagnostic(IN_LOOP, line))
            continue
        name_node = keyword(receiver.call, "name")
        name = literal_string(name_node)
        if name_node is not None and name is None:
            result.diagnostics.append(RawDiagnostic(DYNAMIC, line))
            continue
        site = CliSite(
            "root",
            "typer",
            receiver.name,
            None,
            name,
            statement_span(receiver.statement),
            {"framework": "typer"},
            attach=receiver.name,
            is_group=True,
        )
        result.sites.append(site)
        roots[receiver.name] = site
    header_nodes = function_header_nodes(tree)
    owner = statement_index(tree)
    # Definitions carry @app.command/@app.callback; calls carry typer.run and add_typer.
    for node, context in walk_with_context(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            _decorated(parsed, node, context.in_loop, roots, tables, result)
        elif isinstance(node, ast.Call) and node not in header_nodes:
            span = site_span(node, owner.get(node))
            _call_site(parsed, node, span, context.in_loop, roots, tables, result)
    return result


def _decorated(
    parsed: ParsedModule,
    node: FunctionNode,
    in_loop: bool,
    roots: dict[str, CliSite],
    tables: ModuleTables,
    result: CliResult,
) -> None:
    """Record the command and callback sites of one decorated function.

    Args:
        parsed: The parsed module.
        node: The function definition.
        in_loop: True when the definition lies in a loop body.
        roots: Typer root sites by receiver name.
        tables: The file's binding tables.
        result: Receives the sites and diagnostics.

    Returns:
        None.
    """
    # Each <receiver>.command or <receiver>.callback decorator is handled on its own.
    for decorator in node.decorator_list:
        callee = leading_chain(decorator)
        parts = callee.split(".") if callee is not None else []
        if len(parts) != 2 or parts[1] not in ("command", "callback"):
            continue
        span = header_span(parsed, node)
        owner = roots.get(parts[0])
        if owner is None:
            if not tables.is_known_name(parts[0]):
                result.diagnostics.append(RawDiagnostic(UNBOUND, span[0]))
            continue
        call = decorator_call(decorator)
        if call is not None and has_keyword(call, "cls"):
            result.diagnostics.append(RawDiagnostic(CUSTOM_CLASS, span[0]))
            continue
        if in_loop:
            result.diagnostics.append(RawDiagnostic(IN_LOOP, span[0]))
            continue
        # A callback adds its parameters to the root; a command is a new site.
        if parts[1] == "callback":
            result.sites.extend(parameter_sites(node, owner.site_id, tables, result))
            continue
        name, dynamic = literal_name(call)
        if dynamic:
            result.diagnostics.append(RawDiagnostic(DYNAMIC, span[0]))
            continue
        default_name = node.name.lower().replace("_", "-")
        result.sites.append(
            CliSite(
                "command",
                "typer",
                node.name,
                owner.site_id,
                name,
                span,
                {"framework": "typer"},
                default_name=default_name,
            )
        )
        result.sites.extend(parameter_sites(node, node.name, tables, result))


def _call_site(
    parsed: ParsedModule,
    call: ast.Call,
    site: tuple[int, int],
    in_loop: bool,
    roots: dict[str, CliSite],
    tables: ModuleTables,
    result: CliResult,
) -> None:
    """Handle a typer.run(function) or parent.add_typer(child[, name=]) call.

    Args:
        parsed: The parsed module.
        call: The call.
        site: The logical-line span of the call.
        in_loop: True when the call lies in a loop body.
        roots: Typer root sites by receiver name; a child root is mutated.
        tables: The file's binding tables.
        result: Receives the sites and diagnostics.

    Returns:
        None.
    """
    callee = dotted_name(call.func)
    if callee is None:
        return
    first = call.args[0] if call.args else None
    # typer.run makes its target function a root with the function's parameters.
    if tables.qualify(callee) == "typer.run":
        if not isinstance(first, ast.Name) or first.id not in tables.definitions:
            return
        if in_loop:
            result.diagnostics.append(RawDiagnostic(IN_LOOP, site[0]))
            return
        target = tables.definitions[first.id]
        span = header_span(parsed, target)
        result.sites.append(
            CliSite(
                "root",
                "typer",
                target.name,
                None,
                None,
                span,
                {"framework": "typer"},
                attach=target.name,
            )
        )
        result.sites.extend(parameter_sites(target, target.name, tables, result))
        return
    parts = callee.split(".")
    if len(parts) != 2 or parts[1] != "add_typer":
        return
    owner = roots.get(parts[0])
    if owner is None:
        if not tables.is_known_name(parts[0]):
            result.diagnostics.append(RawDiagnostic(UNBOUND, site[0]))
        return
    if in_loop:
        result.diagnostics.append(RawDiagnostic(IN_LOOP, site[0]))
        return
    child = roots.get(first.id) if isinstance(first, ast.Name) else None
    if child is None:
        return
    name_node = keyword(call, "name")
    name = literal_string(name_node)
    if name_node is not None and name is None:
        result.diagnostics.append(RawDiagnostic(DYNAMIC, site[0]))
        return
    # The child root becomes a command of the parent, spanning the add_typer call.
    child.kind = "command"
    child.parent_id = owner.site_id
    if name is not None:
        child.name = name
    child.attach = None
    child.span = site
