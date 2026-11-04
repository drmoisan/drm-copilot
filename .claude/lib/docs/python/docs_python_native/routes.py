"""The python-http analyzer: FastAPI and Flask routes with composed prefixes.

Reproduces DocsPythonHttpSites.psm1 and DocsAnalyzerPythonHttp.psm1 of issue 1022: pass
1 collects receivers, route sites and mounts per file; pass 2 resolves mounts through
the import tables and composes each template (FastAPI verbatim, Flask joined).
"""

from __future__ import annotations

import ast
from dataclasses import dataclass, field

from docs_python_native.cli_argparse import keyword, site_span, statement_index
from docs_python_native.cli_click import (
    decorator_call,
    function_header_nodes,
    leading_chain,
)
from docs_python_native.imports import (
    AnalyzedFile,
    AnalyzerOutput,
    module_dotted_name,
    module_package,
    resolve_relative,
)
from docs_python_native.source import (
    decorator_line,
    dotted_name,
    header_end_line,
    literal_string,
    walk_with_context,
)

ANALYZER_ID = "python-http"
DEPTH_LIMIT = 16
DYNAMIC_SEGMENT = "<dynamic>"


@dataclass(frozen=True)
class _Framework:
    constructors: dict[str, str]
    prefix_key: str
    methods: frozenset[str]
    call: str
    mount: str
    mount_key: str


FRAMEWORKS: dict[str, _Framework] = {
    "fastapi": _Framework(
        {"fastapi.FastAPI": "app", "fastapi.APIRouter": "router"},
        "prefix",
        frozenset(
            {
                "get",
                "post",
                "put",
                "patch",
                "delete",
                "options",
                "head",
                "trace",
                "api_route",
                "websocket",
            }
        ),
        "add_api_route",
        "include_router",
        "prefix",
    ),
    "flask": _Framework(
        {"flask.Flask": "app", "flask.Blueprint": "blueprint"},
        "url_prefix",
        frozenset({"get", "post", "put", "patch", "delete", "route"}),
        "add_url_rule",
        "register_blueprint",
        "url_prefix",
    ),
}
_GENERIC = {"fastapi": "api_route", "flask": "route"}


@dataclass(frozen=True)
class _Receiver:
    name: str
    kind: str
    framework: str
    prefix: str
    dynamic: bool
    line: int


@dataclass(frozen=True)
class _Route:
    receiver: str
    methods: tuple[str, ...]
    path: str
    name: str
    span: tuple[int, int]
    protocol: str
    framework: str


@dataclass(frozen=True)
class _Mount:
    parent: str
    child: str
    prefix: str
    dynamic: bool
    given: bool
    line: int


@dataclass
class _File:
    analyzed: AnalyzedFile
    module: str | None
    package: str | None
    receivers: dict[str, _Receiver] = field(default_factory=lambda: {})
    routes: list[_Route] = field(default_factory=lambda: [])
    mounts: list[_Mount] = field(default_factory=lambda: [])


@dataclass(frozen=True)
class _Segment:
    text: str
    dynamic: bool
    path: str
    line: int


@dataclass(frozen=True)
class _Edge:
    parent_key: str
    segment: _Segment | None


def compose_template(framework: str, prefixes: list[str], path: str) -> str:
    """Compose a template: FastAPI concatenates; Flask joins prefixes with '/'."""
    if framework == "fastapi":
        return "".join(prefixes) + path
    combined = ""
    for segment in prefixes:
        if not segment:
            continue
        combined = (
            segment
            if not combined
            else combined.rstrip("/") + "/" + segment.lstrip("/")
        )
    if not combined:
        return path
    return combined.rstrip("/") + "/" + path.lstrip("/")


def method_list(call: ast.Call) -> tuple[str, ...] | None:
    """Return the upper-case literal methods= list, ('GET',) when absent, else None."""
    node = keyword(call, "methods")
    if node is None:
        return ("GET",)
    if not isinstance(node, (ast.List, ast.Tuple)) or not node.elts:
        return None
    methods: list[str] = []
    for item in node.elts:
        value = literal_string(item)
        if value is None:
            return None
        if value.upper() not in methods:
            methods.append(value.upper())
    return tuple(methods)


def _receivers(entry: _File, name: str) -> dict[str, _Receiver]:
    tables = entry.analyzed.tables
    definition = FRAMEWORKS[name]
    found: dict[str, _Receiver] = {}
    for receiver in tables.receivers.values():
        kind = definition.constructors.get(tables.qualify(receiver.callee) or "")
        if kind is None:
            continue
        prefix, dynamic = "", False
        node = keyword(receiver.call, definition.prefix_key)
        if kind != "app" and node is not None:
            value = literal_string(node)
            prefix, dynamic = (value, False) if value is not None else ("", True)
        found[receiver.name] = _Receiver(
            receiver.name, kind, name, prefix, dynamic, receiver.statement.lineno
        )
    return found


def _first_literal(call: ast.Call | None) -> str | None:
    if call is None or not call.args:
        return None
    return literal_string(call.args[0])


def _collect(entry: _File, output: AnalyzerOutput) -> None:
    analyzed = entry.analyzed
    tree = analyzed.parsed.tree
    if tree is None:
        return
    path = analyzed.path
    owner = statement_index(tree)
    header_nodes = function_header_nodes(tree)
    tracked: dict[str, str] = {}
    for name in FRAMEWORKS:
        receivers = _receivers(entry, name)
        entry.receivers.update(receivers)
        tracked.update({key: name for key in receivers})
    for node, context in walk_with_context(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            for name in FRAMEWORKS:
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
    entry: _File,
    function: ast.FunctionDef | ast.AsyncFunctionDef,
    decorator: ast.expr,
    framework: str,
    tracked: dict[str, str],
    in_loop: bool,
    output: AnalyzerOutput,
) -> None:
    callee = leading_chain(decorator)
    parts = callee.split(".") if callee is not None else []
    definition = FRAMEWORKS[framework]
    if len(parts) != 2 or parts[1] not in definition.methods:
        return
    call = decorator_call(decorator)
    literal = _first_literal(call)
    path = entry.analyzed.path
    line = decorator_line(entry.analyzed.parsed, decorator)
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
    if parts[1] == _GENERIC[framework]:
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
        _Route(parts[0], methods, literal, function.name, span, protocol, framework)
    )


def _call_route(
    entry: _File,
    call: ast.Call,
    receiver: str,
    framework: str,
    span: tuple[int, int],
    output: AnalyzerOutput,
) -> None:
    path = entry.analyzed.path
    methods = method_list(call)
    view = keyword(call, "view_func")
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
        _Route(receiver, methods, literal, literal, span, "http", framework)
    )


def _mount(
    entry: _File,
    call: ast.Call,
    parent: str,
    definition: _Framework,
    line: int,
    output: AnalyzerOutput,
) -> None:
    child = dotted_name(call.args[0]) if call.args else None
    if child is None:
        output.add_diagnostic(entry.analyzed.path, "HTTP_MOUNT_UNRESOLVED", line)
        return
    node = keyword(call, definition.mount_key)
    prefix, dynamic = "", False
    if node is not None:
        value = literal_string(node)
        prefix, dynamic = (value, False) if value is not None else ("", True)
    entry.mounts.append(_Mount(parent, child, prefix, dynamic, node is not None, line))


def _child_key(
    entry: _File,
    child: str,
    by_key: dict[str, tuple[_File, _Receiver]],
    by_module: dict[str, _File],
) -> str | None:
    if "." not in child and child in entry.receivers:
        return entry.analyzed.path + "|" + child
    qualified = entry.analyzed.tables.qualify(child)
    if qualified is None or qualified == child or "." not in qualified:
        return None
    separator = qualified.rindex(".")
    module = resolve_relative(qualified[:separator], entry.package)
    target = by_module.get(module) if module is not None else None
    if target is None:
        return None
    key = target.analyzed.path + "|" + qualified[separator + 1 :]
    return key if key in by_key else None


def _chains(
    key: str,
    by_key: dict[str, tuple[_File, _Receiver]],
    included_by: dict[str, list[_Edge]],
    stack: set[str],
    depth: int = 0,
) -> tuple[list[list[_Segment]], bool]:
    entry, receiver = by_key[key]
    if receiver.kind == "app":
        return [[]], False
    if depth > DEPTH_LIMIT or key in stack:
        return [], True
    stack.add(key)
    chains: list[list[_Segment]] = []
    cycle = False
    own_segment = _Segment(
        receiver.prefix, receiver.dynamic, entry.analyzed.path, receiver.line
    )
    for edge in included_by.get(key, []):
        own: list[_Segment] = []
        if receiver.framework == "fastapi":
            if edge.segment is not None:
                own.append(edge.segment)
            own.append(own_segment)
        else:
            own.append(edge.segment if edge.segment is not None else own_segment)
        parents, parent_cycle = _chains(
            edge.parent_key, by_key, included_by, stack, depth + 1
        )
        cycle = cycle or parent_cycle
        chains.extend(parent + own for parent in parents)
    stack.discard(key)
    return chains, cycle


def analyze_http(files: list[AnalyzedFile], source_roots: list[str]) -> AnalyzerOutput:
    """Return the python-http facts and diagnostics of the parsed request files."""
    output = AnalyzerOutput(ANALYZER_ID)
    entries: list[_File] = []
    by_key: dict[str, tuple[_File, _Receiver]] = {}
    by_module: dict[str, _File] = {}
    for analyzed in sorted(files, key=lambda f: f.path):
        module = module_dotted_name(
            analyzed.path, source_roots, require_identifiers=False
        )
        entry = _File(analyzed, module, module_package(analyzed.path, module))
        _collect(entry, output)
        entries.append(entry)
        for name, receiver in entry.receivers.items():
            by_key[analyzed.path + "|" + name] = (entry, receiver)
        if module is not None and module not in by_module:
            by_module[module] = entry
    included_by: dict[str, list[_Edge]] = {}
    for entry in entries:
        path = entry.analyzed.path
        for mount in entry.mounts:
            child = _child_key(entry, mount.child, by_key, by_module)
            if child is None or by_key[child][1].kind == "app":
                output.add_diagnostic(path, "HTTP_MOUNT_UNRESOLVED", mount.line)
                continue
            segment = (
                _Segment(mount.prefix, mount.dynamic, path, mount.line)
                if mount.given
                else None
            )
            included_by.setdefault(child, []).append(
                _Edge(path + "|" + mount.parent, segment)
            )
    for entry in entries:
        for route in entry.routes:
            _emit(entry, route, by_key, included_by, output)
    return output


def _emit(
    entry: _File,
    route: _Route,
    by_key: dict[str, tuple[_File, _Receiver]],
    included_by: dict[str, list[_Edge]],
    output: AnalyzerOutput,
) -> None:
    path = entry.analyzed.path
    key = path + "|" + route.receiver
    receiver = by_key[key][1]
    chains, cycle = _chains(key, by_key, included_by, set())
    if cycle:
        output.add_diagnostic(path, "HTTP_INCLUDE_UNRESOLVED", route.span[0])
    mounted = bool(chains)
    if not chains:
        chains = [[_Segment(receiver.prefix, receiver.dynamic, path, receiver.line)]]
    for chain in chains:
        prefixes: list[str] = []
        resolved = True
        for segment in chain:
            if segment.dynamic:
                resolved = False
                prefixes.append(DYNAMIC_SEGMENT)
                output.add_diagnostic(segment.path, "HTTP_PREFIX_DYNAMIC", segment.line)
            else:
                prefixes.append(segment.text)
        template = compose_template(route.framework, prefixes, route.path)
        for method in sorted(route.methods):
            output.add_fact(
                path,
                "http-route",
                method + " " + template,
                route.name,
                route.span,
                {
                    "framework": route.framework,
                    "mounted": mounted,
                    "prefix_resolved": resolved,
                    "protocol": route.protocol,
                },
            )
