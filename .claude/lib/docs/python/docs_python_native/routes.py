"""The python-http analyzer: FastAPI and Flask routes with composed prefixes.

Reproduces DocsPythonHttpSites.psm1 and DocsAnalyzerPythonHttp.psm1 of issue 1022: pass
1 collects receivers, route sites and mounts per file; pass 2 resolves mounts through
the import tables and composes each template (FastAPI verbatim, Flask joined).
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING

from docs_python_native.facts import AnalyzerOutput
from docs_python_native.module_names import (
    module_dotted_name,
    module_package,
    resolve_relative,
)
from docs_python_native.route_model import RouteFile, RouteReceiver, RouteSite
from docs_python_native.route_sites import collect_sites

if TYPE_CHECKING:
    from docs_python_native.imports import AnalyzedFile

ANALYZER_ID = "python-http"
DEPTH_LIMIT = 16
DYNAMIC_SEGMENT = "<dynamic>"


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


def _child_key(
    entry: RouteFile,
    child: str,
    by_key: dict[str, tuple[RouteFile, RouteReceiver]],
    by_module: dict[str, RouteFile],
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
    by_key: dict[str, tuple[RouteFile, RouteReceiver]],
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
    entries: list[RouteFile] = []
    by_key: dict[str, tuple[RouteFile, RouteReceiver]] = {}
    by_module: dict[str, RouteFile] = {}
    for analyzed in sorted(files, key=lambda f: f.path):
        module = module_dotted_name(
            analyzed.path, source_roots, require_identifiers=False
        )
        entry = RouteFile(analyzed, module, module_package(analyzed.path, module))
        collect_sites(entry, output)
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
    entry: RouteFile,
    route: RouteSite,
    by_key: dict[str, tuple[RouteFile, RouteReceiver]],
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
