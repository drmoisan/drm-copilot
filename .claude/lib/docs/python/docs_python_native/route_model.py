"""Framework table and per-file records of the python-http analyzer.

FRAMEWORKS describes FastAPI and Flask (constructors, prefix keyword, route methods,
call and mount names); the Route* records hold what pass 1 collects from one file.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from docs_python_native.imports import AnalyzedFile


@dataclass(frozen=True)
class Framework:
    """The 1022 recognition rules of one web framework.

    Attributes:
        constructors: Qualified constructor name to receiver kind ("app", "router" or
            "blueprint").
        prefix_key: The constructor keyword that carries a receiver prefix.
        methods: The receiver attributes that declare a decorator route.
        call: The receiver method that registers a route by call.
        mount: The receiver method that mounts a child receiver.
        mount_key: The mount keyword that carries the mount prefix.
    """

    constructors: dict[str, str]
    prefix_key: str
    methods: frozenset[str]
    call: str
    mount: str
    mount_key: str


FRAMEWORKS: dict[str, Framework] = {
    "fastapi": Framework(
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
    "flask": Framework(
        {"flask.Flask": "app", "flask.Blueprint": "blueprint"},
        "url_prefix",
        frozenset({"get", "post", "put", "patch", "delete", "route"}),
        "add_url_rule",
        "register_blueprint",
        "url_prefix",
    ),
}
GENERIC_METHODS = {"fastapi": "api_route", "flask": "route"}


@dataclass(frozen=True)
class RouteReceiver:
    """A tracked FastAPI or Flask receiver of one file.

    Attributes:
        name: The bound receiver name.
        kind: "app", "router" or "blueprint".
        framework: "fastapi" or "flask".
        prefix: The literal constructor prefix ("" when absent or dynamic).
        dynamic: True when the constructor prefix is not a literal.
        line: The binding line, used for prefix diagnostics.
    """

    name: str
    kind: str
    framework: str
    prefix: str
    dynamic: bool
    line: int


@dataclass(frozen=True)
class RouteSite:
    """One route declared on a receiver, before prefixes are composed.

    Attributes:
        receiver: The receiver name the route is declared on.
        methods: The upper-case HTTP methods (or WEBSOCKET).
        path: The literal route path.
        name: The element name (the view function name, or the path for a call route).
        span: (first line, last line) of the declaration.
        protocol: "http" or "websocket".
        framework: "fastapi" or "flask".
    """

    receiver: str
    methods: tuple[str, ...]
    path: str
    name: str
    span: tuple[int, int]
    protocol: str
    framework: str


@dataclass(frozen=True)
class RouteMount:
    """One include_router or register_blueprint call.

    Attributes:
        parent: The receiver that mounts.
        child: The mounted expression as dotted text (resolved in pass 2).
        prefix: The literal mount prefix ("" when absent or dynamic).
        dynamic: True when the mount prefix is not a literal.
        given: True when the mount passes the prefix keyword at all.
        line: The mount line.
    """

    parent: str
    child: str
    prefix: str
    dynamic: bool
    given: bool
    line: int


@dataclass
class RouteFile:
    """The pass-1 state of one parsed file: its receivers, routes and mounts.

    Created by analyze_http per file and filled by collect_sites; pass 2 reads it to
    resolve mounts across files.

    Attributes:
        analyzed: The parsed file and its binding tables.
        module: The file's dotted module name, or None.
        package: The package relative mounts resolve against, or None.
        receivers: Receiver name to its RouteReceiver.
        routes: The routes declared in the file.
        mounts: The mounts declared in the file.
    """

    analyzed: AnalyzedFile
    module: str | None
    package: str | None
    receivers: dict[str, RouteReceiver] = field(default_factory=lambda: {})
    routes: list[RouteSite] = field(default_factory=lambda: [])
    mounts: list[RouteMount] = field(default_factory=lambda: [])
