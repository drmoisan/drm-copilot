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
    name: str
    kind: str
    framework: str
    prefix: str
    dynamic: bool
    line: int


@dataclass(frozen=True)
class RouteSite:
    receiver: str
    methods: tuple[str, ...]
    path: str
    name: str
    span: tuple[int, int]
    protocol: str
    framework: str


@dataclass(frozen=True)
class RouteMount:
    parent: str
    child: str
    prefix: str
    dynamic: bool
    given: bool
    line: int


@dataclass
class RouteFile:
    analyzed: AnalyzedFile
    module: str | None
    package: str | None
    receivers: dict[str, RouteReceiver] = field(default_factory=lambda: {})
    routes: list[RouteSite] = field(default_factory=lambda: [])
    mounts: list[RouteMount] = field(default_factory=lambda: [])
