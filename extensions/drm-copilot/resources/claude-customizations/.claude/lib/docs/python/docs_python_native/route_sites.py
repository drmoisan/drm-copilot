"""Pass 1 of the python-http analyzer: receivers, route sites and mounts of one file.

Reproduces the site collection of DocsPythonHttpSites.psm1 of issue 1022: decorator
routes, add_api_route and add_url_rule calls, and include_router or
register_blueprint mounts on tracked FastAPI and Flask receivers.
"""

from __future__ import annotations

import ast
from typing import TYPE_CHECKING

from docs_python_native.call_sites import (
    decorator_call,
    function_header_nodes,
    keyword,
    leading_chain,
    site_span,
    statement_index,
)
from docs_python_native.route_model import (
    FRAMEWORKS,
    GENERIC_METHODS,
    Framework,
    RouteFile,
    RouteMount,
    RouteReceiver,
    RouteSite,
)
from docs_python_native.source import (
    decorator_line,
    dotted_name,
    header_end_line,
    literal_string,
)
from docs_python_native.walk import walk_with_context

if TYPE_CHECKING:
    from docs_python_native.facts import AnalyzerOutput


def method_list(call: ast.Call) -> tuple[str, ...] | None:
    """Return the HTTP methods of a generic route or route call.

    Args:
        call: The api_route, route, add_api_route or add_url_rule call.

    Returns:
        ("GET",) when methods= is absent; the unique upper-case literal methods in
        source order; None when methods= is not a non-empty literal list or tuple of
        literal strings.
    """
    node = keyword(call, "methods")
    if node is None:
        return ("GET",)
    if not isinstance(node, (ast.List, ast.Tuple)) or not node.elts:
        return None
    methods: list[str] = []
    # Upper-case each literal and keep first occurrences; a non-literal gives None.
    for item in node.elts:
        value = literal_string(item)
        if value is None:
            return None
        if value.upper() not in methods:
            methods.append(value.upper())
    return tuple(methods)


def _receivers(entry: RouteFile, name: str) -> dict[str, RouteReceiver]:
    """Return the receivers of one framework in a file.

    Args:
        entry: The file's pass-1 state.
        name: The framework key ("fastapi" or "flask").

    Returns:
        Receiver name to RouteReceiver for every receiver whose qualified constructor
        belongs to the framework; an app never carries a prefix.
    """
    tables = entry.analyzed.tables
    definition = FRAMEWORKS[name]
    found: dict[str, RouteReceiver] = {}
    # Keep only receivers built by one of the framework's constructors.
    for receiver in tables.receivers.values():
        kind = definition.constructors.get(tables.qualify(receiver.callee) or "")
        if kind is None:
            continue
        prefix, dynamic = "", False
        node = keyword(receiver.call, definition.prefix_key)
        if kind != "app" and node is not None:
            value = literal_string(node)
            prefix, dynamic = (value, False) if value is not None else ("", True)
        found[receiver.name] = RouteReceiver(
            receiver.name, kind, name, prefix, dynamic, receiver.statement.lineno
        )
    return found


def _first_literal(call: ast.Call | None) -> str | None:
    """Return the literal first positional argument of a call.

    Args:
        call: A call node, or None.

    Returns:
        The literal string of the first argument, or None when absent or not literal.
    """
    if call is None or not call.args:
        return None
    return literal_string(call.args[0])


def collect_sites(entry: RouteFile, output: AnalyzerOutput) -> None:
    """Collect the receivers, routes and mounts of one file (pass 1).

    Args:
        entry: The file's pass-1 state; its receivers, routes and mounts are filled.
        output: The analyzer output that receives the pass-1 diagnostics.

    Returns:
        None. Mutates entry and output.
    """
    analyzed = entry.analyzed
    tree = analyzed.parsed.tree
    if tree is None:
        return
    path = analyzed.path
    owner = statement_index(tree)
    header_nodes = function_header_nodes(tree)
    tracked: dict[str, str] = {}
    # Register the receivers of both frameworks and remember which framework owns each.
    for name in FRAMEWORKS:
        receivers = _receivers(entry, name)
        entry.receivers.update(receivers)
        # Map each receiver name to the framework that owns it.
        tracked.update({key: name for key in receivers})
    # Visit definitions for decorator routes and calls for route, mount and
    # unsupported mount registrations; decorator calls are skipped as calls.
    for node, context in walk_with_context(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            # Each decorator is tried against each framework; the receiver decides.
            for name in FRAMEWORKS:
                # Check every decorator of the definition against this framework.
                for decorator in node.decorator_list:
                    _decorator_route(
                        entry, node, decorator, name, tracked, context.in_loop, output
                    )
            continue
        if not isinstance(node, ast.Call) or node in header_nodes:
            continue
        callee = dotted_name(node.func)
        parts = callee.split(".") if callee is not None else []
        if len(parts) != 2 or parts[0] not in tracked:
            continue
        span = site_span(node, owner.get(node))
        framework = tracked[parts[0]]
        definition = FRAMEWORKS[framework]
        # Routing: the route call registers a route (not inside a loop); a mount()
        # call is never resolved; include_router or register_blueprint mounts a child.
        if parts[1] == definition.call:
            if context.in_loop:
                output.add_diagnostic(path, "HTTP_ROUTE_IN_LOOP", span[0])
                continue
            _call_route(entry, node, parts[0], framework, span, output)
        elif parts[1] == "mount":
            output.add_diagnostic(path, "HTTP_MOUNT_UNRESOLVED", span[0])
        elif parts[1] == definition.mount:
            _mount(entry, node, parts[0], definition, span[0], output)


def _decorator_route(
    entry: RouteFile,
    function: ast.FunctionDef | ast.AsyncFunctionDef,
    decorator: ast.expr,
    framework: str,
    tracked: dict[str, str],
    in_loop: bool,
    output: AnalyzerOutput,
) -> None:
    """Record a decorator route, or the diagnostic that replaces it.

    Args:
        entry: The file's pass-1 state; a route is appended to entry.routes.
        function: The decorated function.
        decorator: One decorator of the function.
        framework: The framework the decorator is checked against.
        tracked: Receiver name to its framework.
        in_loop: True when the definition lies in a loop body.
        output: Receives HTTP_UNBOUND_ROUTE, HTTP_ROUTE_IN_LOOP or HTTP_DYNAMIC_ROUTE.

    Returns:
        None.
    """
    callee = leading_chain(decorator)
    parts = callee.split(".") if callee is not None else []
    definition = FRAMEWORKS[framework]
    if len(parts) != 2 or parts[1] not in definition.methods:
        return
    call = decorator_call(decorator)
    literal = _first_literal(call)
    path = entry.analyzed.path
    line = decorator_line(entry.analyzed.parsed, decorator)
    # An untracked receiver is reported only when the name is unbound in the file and
    # the path looks like a route, as the 1022 scanner does.
    if tracked.get(parts[0]) != framework:
        tables = entry.analyzed.tables
        if (
            not tables.is_known_name(parts[0], include_classes=True)
            and literal is not None
            and literal.startswith("/")
        ):
            output.add_diagnostic(path, "HTTP_UNBOUND_ROUTE", line)
        return
    if in_loop:
        output.add_diagnostic(path, "HTTP_ROUTE_IN_LOOP", line)
        return
    # Routing: the generic route reads methods=, websocket is its own method, and any
    # other attribute is the method name itself.
    if parts[1] == GENERIC_METHODS[framework]:
        methods = method_list(call) if call is not None else None
    elif parts[1] == "websocket":
        methods = ("WEBSOCKET",)
    else:
        methods = (parts[1].upper(),)
    if literal is None or methods is None:
        output.add_diagnostic(path, "HTTP_DYNAMIC_ROUTE", line)
        return
    span = (line, header_end_line(entry.analyzed.parsed, function))
    protocol = "websocket" if parts[1] == "websocket" else "http"
    entry.routes.append(
        RouteSite(parts[0], methods, literal, function.name, span, protocol, framework)
    )


def _call_route(
    entry: RouteFile,
    call: ast.Call,
    receiver: str,
    framework: str,
    span: tuple[int, int],
    output: AnalyzerOutput,
) -> None:
    """Record an add_api_route or add_url_rule route, or its diagnostic.

    Args:
        entry: The file's pass-1 state; a route is appended to entry.routes.
        call: The route call.
        receiver: The receiver name the call is made on.
        framework: "fastapi" or "flask".
        span: The logical-line span of the call.
        output: Receives HTTP_METHOD_VIEW_UNRESOLVED or HTTP_DYNAMIC_ROUTE.

    Returns:
        None.
    """
    path = entry.analyzed.path
    methods = method_list(call)
    view = keyword(call, "view_func")
    # A Flask class-based view registered without a literal methods= list has methods
    # that only the view class defines, so the route cannot be enumerated.
    if (
        framework == "flask"
        and not (keyword(call, "methods") is not None and methods is not None)
        and isinstance(view, ast.Call)
        and (dotted_name(view.func) or "").endswith(".as_view")
    ):
        output.add_diagnostic(path, "HTTP_METHOD_VIEW_UNRESOLVED", span[0])
        return
    literal = _first_literal(call)
    if literal is None or methods is None:
        output.add_diagnostic(path, "HTTP_DYNAMIC_ROUTE", span[0])
        return
    entry.routes.append(
        RouteSite(receiver, methods, literal, literal, span, "http", framework)
    )


def _mount(
    entry: RouteFile,
    call: ast.Call,
    parent: str,
    definition: Framework,
    line: int,
    output: AnalyzerOutput,
) -> None:
    """Record an include_router or register_blueprint mount.

    Args:
        entry: The file's pass-1 state; a mount is appended to entry.mounts.
        call: The mount call.
        parent: The mounting receiver name.
        definition: The framework rules of the receiver.
        line: The mount line.
        output: Receives HTTP_MOUNT_UNRESOLVED when the child is not a dotted name.

    Returns:
        None.
    """
    child = dotted_name(call.args[0]) if call.args else None
    if child is None:
        output.add_diagnostic(entry.analyzed.path, "HTTP_MOUNT_UNRESOLVED", line)
        return
    node = keyword(call, definition.mount_key)
    prefix, dynamic = "", False
    if node is not None:
        value = literal_string(node)
        prefix, dynamic = (value, False) if value is not None else ("", True)
    entry.mounts.append(
        RouteMount(parent, child, prefix, dynamic, node is not None, line)
    )
