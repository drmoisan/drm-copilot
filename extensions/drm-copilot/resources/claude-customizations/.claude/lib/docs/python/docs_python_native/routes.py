"""The python-http analyzer: FastAPI and Flask routes with composed prefixes.

Reproduces DocsPythonHttpSites.psm1 and DocsAnalyzerPythonHttp.psm1 of issue 1022: pass
1 (route_sites.collect_sites) collects receivers, route sites and mounts per file; pass
2 (this module) resolves mounts through the import tables and composes each template
(FastAPI verbatim, Flask joined).
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
    """One prefix segment of a mount chain.

    Attributes:
        text: The literal prefix text ("" when dynamic).
        dynamic: True when the prefix is not a literal.
        path: The file that declares the prefix, for its diagnostic.
        line: The declaring line, for its diagnostic.
    """

    text: str
    dynamic: bool
    path: str
    line: int


@dataclass(frozen=True)
class _Edge:
    """A mount edge from a child receiver to the receiver that includes it.

    Attributes:
        parent_key: The "path|name" key of the including receiver.
        segment: The mount prefix segment, or None when the mount gives no prefix.
    """

    parent_key: str
    segment: _Segment | None


def compose_template(framework: str, prefixes: list[str], path: str) -> str:
    """Compose a route template from its prefix chain and its path.

    Args:
        framework: "fastapi" concatenates prefixes verbatim; "flask" joins non-empty
            prefixes and the path with single slashes.
        prefixes: The prefixes from the outermost receiver inwards.
        path: The route path.

    Returns:
        The composed template.
    """
    if framework == "fastapi":
        return "".join(prefixes) + path
    combined = ""
    # Join the non-empty Flask prefixes with exactly one slash between neighbours.
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
    """Resolve a mounted expression to the key of a receiver.

    Args:
        entry: The mounting file.
        child: The mounted dotted text.
        by_key: Every receiver of the request by "path|name" key.
        by_module: Request file by dotted module name.

    Returns:
        The "path|name" key of a local receiver, or of a receiver in another request
        file reached through the import table; None when it cannot be resolved.
    """
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
    """Return every prefix chain from an app down to a receiver.

    The recursion is bounded by DEPTH_LIMIT and a stack of the keys on the current path,
    which is discarded on return, so sibling mounts that share an ancestor are not
    reported as cycles.

    Args:
        key: The receiver key whose chains are wanted.
        by_key: Every receiver by key.
        included_by: Receiver key to the edges of the receivers that include it.
        stack: The keys on the current recursion path; mutated and restored.
        depth: The current recursion depth.

    Returns:
        (chains, cycle): one segment list per path to an app (an app gives one empty
        chain; an unmounted router gives none), and True when a cycle or the depth
        limit cut a path.
    """
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
    # Extend every parent chain with this receiver's own segments.
    for edge in included_by.get(key, []):
        own: list[_Segment] = []
        # FastAPI applies the mount prefix and then the router prefix; Flask uses the
        # mount prefix instead of the blueprint prefix when one is given.
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
        # Append this receiver's segments to every chain that reaches its parent.
        chains.extend(parent + own for parent in parents)
    stack.discard(key)
    return chains, cycle


def analyze_http(files: list[AnalyzedFile], source_roots: list[str]) -> AnalyzerOutput:
    """Return the python-http facts and diagnostics of the parsed request files.

    Args:
        files: The parsed request files.
        source_roots: The configured source roots for module names.

    Returns:
        The analyzer output with one http-route fact per method and composed template.
    """
    output = AnalyzerOutput(ANALYZER_ID)
    entries: list[RouteFile] = []
    by_key: dict[str, tuple[RouteFile, RouteReceiver]] = {}
    by_module: dict[str, RouteFile] = {}
    # Pass 1: collect every file's sites in path order and index receivers and modules.
    for analyzed in sorted(files, key=lambda f: f.path):
        module = module_dotted_name(
            analyzed.path, source_roots, require_identifiers=False
        )
        entry = RouteFile(analyzed, module, module_package(analyzed.path, module))
        collect_sites(entry, output)
        entries.append(entry)
        # Index the file's receivers under their request-wide "path|name" keys.
        for name, receiver in entry.receivers.items():
            by_key[analyzed.path + "|" + name] = (entry, receiver)
        if module is not None and module not in by_module:
            by_module[module] = entry
    included_by: dict[str, list[_Edge]] = {}
    # Pass 2a: resolve every mount to an edge; an app or unknown child is unresolved.
    for entry in entries:
        path = entry.analyzed.path
        # Each mount of the file adds one edge under its resolved child key.
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
    # Pass 2b: emit every route through every chain that reaches it.
    for entry in entries:
        # Emit the routes of this file.
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
    """Emit the facts of one route, one per method and prefix chain.

    An unmounted router is emitted with its own prefix only (mounted false); a dynamic
    segment becomes DYNAMIC_SEGMENT and reports HTTP_PREFIX_DYNAMIC; a cycle reports
    HTTP_INCLUDE_UNRESOLVED.

    Args:
        entry: The file that declares the route.
        route: The route.
        by_key: Every receiver by key.
        included_by: The mount edges by child key.
        output: Receives the facts and diagnostics.

    Returns:
        None.
    """
    path = entry.analyzed.path
    key = path + "|" + route.receiver
    receiver = by_key[key][1]
    chains, cycle = _chains(key, by_key, included_by, set())
    if cycle:
        output.add_diagnostic(path, "HTTP_INCLUDE_UNRESOLVED", route.span[0])
    mounted = bool(chains)
    if not chains:
        chains = [[_Segment(receiver.prefix, receiver.dynamic, path, receiver.line)]]
    # Compose one template per chain and emit it for each method.
    for chain in chains:
        prefixes: list[str] = []
        resolved = True
        # A dynamic segment is kept as a placeholder so the template stays stable.
        for segment in chain:
            if segment.dynamic:
                resolved = False
                prefixes.append(DYNAMIC_SEGMENT)
                output.add_diagnostic(segment.path, "HTTP_PREFIX_DYNAMIC", segment.line)
            else:
                prefixes.append(segment.text)
        template = compose_template(route.framework, prefixes, route.path)
        # Methods are emitted in sorted order for deterministic output.
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
