"""Tests for docs_python_native.routes: FastAPI and Flask sites, mounts, prefixes."""

import pytest
from docs_python_native.facts import AnalyzerOutput
from docs_python_native.imports import AnalyzedFile, build_tables
from docs_python_native.routes import analyze_http, compose_template
from docs_python_native.source import parse_module

ROOTS = ["src"]


def _file(path: str, text: str) -> AnalyzedFile:
    """Build an AnalyzedFile from an in-memory path and source text."""
    parsed = parse_module(text)
    return AnalyzedFile(path, parsed, build_tables(parsed))


def _run(*files: tuple[str, str]) -> AnalyzerOutput:
    """Run the http analyzer over in-memory (path, text) files."""
    return analyze_http([_file(p, t) for p, t in files], ROOTS)


def _routes(output: AnalyzerOutput) -> dict[str, dict[str, object]]:
    """Map each route declaration to its path, span, name and properties."""
    return {
        f.declaration: {
            "path": path,
            "span": (f.line_start, f.line_end),
            "name": f.name,
            **dict(f.properties),
        }
        for path, facts in output.facts.items()
        for f in facts
    }


def _codes(output: AnalyzerOutput) -> list[tuple[str, str]]:
    """Return the sorted (path, code) pairs of every raw diagnostic."""
    return sorted((path, d.code) for path, ds in output.diagnostics.items() for d in ds)


class TestComposeTemplate:
    """Scenarios for compose template in docs_python_native.routes."""

    @pytest.mark.parametrize(
        ("framework", "prefixes", "path", "expected"),
        [
            ("fastapi", ["/v2", "/items"], "/", "/v2/items/"),
            ("fastapi", [], "/x", "/x"),
            ("flask", ["/bp"], "/items", "/bp/items"),
            ("flask", ["/other/", ""], "items", "/other/items"),
            ("flask", ["", ""], "/rule", "/rule"),
            ("flask", ["/a/", "/b"], "/c", "/a/b/c"),
        ],
    )
    def test_composition_rules(
        self, framework: str, prefixes: list[str], path: str, expected: str
    ) -> None:
        """Scenario: FastAPI concatenates prefixes and Flask joins them with a slash."""
        assert compose_template(framework, prefixes, path) == expected


FASTAPI = (
    "from fastapi import FastAPI, APIRouter\n"
    "from . import routers\n"
    "from pkg.routers import users as people\n"
    "app = FastAPI()\n"
    "items = APIRouter(prefix='/items')\n"
    "@app.get('/')\ndef root():\n    pass\n"
    "@app.api_route('/ping', methods=['GET', 'POST'])\nasync def ping():\n    pass\n"
    "@app.websocket('/ws')\nasync def socket():\n    pass\n"
    "@items.post('/')\ndef create():\n    pass\n"
    "app.include_router(items)\n"
    "app.include_router(items, prefix='/v2')\n"
    "app.include_router(routers.users, prefix='/users')\n"
    "app.include_router(people)\n"
    "app.add_api_route('/health', root, methods=['HEAD'])\n"
    "dynamic = APIRouter(prefix=settings.prefix)\n"
    "@dynamic.get('/d')\ndef d():\n    pass\n"
    "app.include_router(dynamic, prefix=PREFIX)\n"
    "orphan = APIRouter(prefix='/orphan')\n"
    "@orphan.get('/x')\ndef x():\n    pass\n"
)
ROUTERS = (
    "from fastapi import APIRouter\nusers = APIRouter(prefix='/u')\n"
    "@users.get('/{id}')\ndef get(id):\n    pass\n"
)


class TestFastApi:
    """Scenarios for FastAPI in docs_python_native.routes."""

    def test_routes_across_modules(self) -> None:
        """Scenario: FastAPI routes compose prefixes across modules and mounts."""
        output = _run(("src/pkg/app.py", FASTAPI), ("src/pkg/routers.py", ROUTERS))
        routes = _routes(output)
        assert routes["GET /"]["span"] == (6, 7)
        assert {"GET /ping", "POST /ping", "WEBSOCKET /ws"} <= set(routes)
        assert routes["WEBSOCKET /ws"]["protocol"] == "websocket"
        assert {"POST /items/", "POST /v2/items/"} <= set(routes)
        assert routes["GET /users/u/{id}"]["path"] == "src/pkg/routers.py"
        assert routes["GET /u/{id}"]["mounted"] is True
        assert routes["HEAD /health"]["name"] == "/health"
        dynamic = routes["GET <dynamic><dynamic>/d"]
        assert dynamic["prefix_resolved"] is False and dynamic["mounted"] is True
        assert routes["GET /orphan/x"]["mounted"] is False
        assert _codes(output) == [("src/pkg/app.py", "HTTP_PREFIX_DYNAMIC")] * 2

    def test_fastapi_diagnostics(self) -> None:
        """Scenario: each FastAPI diagnostic class is reported for its construct."""
        text = (
            "from fastapi import FastAPI, APIRouter\n"
            "app = FastAPI()\n"
            "@app.get(PATH)\ndef a():\n    pass\n"
            "@app.api_route('/m', methods=METHODS)\ndef b():\n    pass\n"
            "@app.api_route\ndef c():\n    pass\n"
            "for r in x:\n    @app.get(r)\n    def d():\n        pass\n"
            "    app.add_api_route('/loop', d)\n"
            "app.mount('/s', thing)\n"
            "app.include_router(external)\n"
            "app.include_router(make())\n"
            "app.include_router(app)\n"
            "app.add_api_route(PATH, a)\n"
            "def make(router):\n    @router.get('/unbound')\n    def u():\n"
            "        pass\n"
            "    @router.get('relative')\n    def v():\n        pass\n"
            "a1 = APIRouter(prefix='/a')\nb1 = APIRouter(prefix='/b')\n"
            "a1.include_router(b1)\nb1.include_router(a1)\n"
            "@a1.get('/cycle')\ndef cycle():\n    pass\n"
        )
        output = _run(("src/pkg/diag.py", text))
        codes = [code for _path, code in _codes(output)]
        assert codes == sorted(
            ["HTTP_DYNAMIC_ROUTE"] * 4
            + ["HTTP_ROUTE_IN_LOOP"] * 2
            + ["HTTP_MOUNT_UNRESOLVED"] * 4
            + ["HTTP_UNBOUND_ROUTE"] * 2
            + ["HTTP_INCLUDE_UNRESOLVED"] * 1
        )
        routes = _routes(output)
        assert routes["GET /a/cycle"]["mounted"] is False

    def test_depth_above_sixteen_is_unresolved(self) -> None:
        """Scenario: a mount chain above depth sixteen reports include-unresolved."""
        lines = ["from fastapi import FastAPI, APIRouter", "app = FastAPI()"]
        lines += [f"r{i} = APIRouter(prefix='/{i}')" for i in range(18)]
        lines += ["app.include_router(r0)"]
        lines += [f"r{i}.include_router(r{i + 1})" for i in range(17)]
        lines += ["@r17.get('/leaf')", "def leaf():", "    pass", ""]
        output = _run(("src/deep.py", "\n".join(lines)))
        (fact,) = output.facts["src/deep.py"]
        assert fact.declaration == "GET /17/leaf"
        assert dict(fact.properties)["mounted"] is False
        assert _codes(output) == [("src/deep.py", "HTTP_INCLUDE_UNRESOLVED")]


FLASK = (
    "from flask import Flask, Blueprint\n"
    "app = Flask(__name__)\n"
    "bp = Blueprint('bp', __name__, url_prefix='/bp')\n"
    "loose = Blueprint('loose', __name__, url_prefix=P)\n"
    "@app.route('/')\ndef index():\n    pass\n"
    "@app.route('/multi', methods=['GET', 'POST'])\ndef multi():\n    pass\n"
    "@bp.get('/items/<int:item_id>')\ndef item(item_id):\n    pass\n"
    "@loose.get('/l')\ndef lo():\n    pass\n"
    "app.register_blueprint(bp)\n"
    "app.register_blueprint(bp, url_prefix='/other/')\n"
    "app.add_url_rule('/rule', view_func=index, methods=['PUT'])\n"
    "app.add_url_rule('/view', view_func=ItemView.as_view('item'))\n"
    "app.add_url_rule('/view2', view_func=ItemView.as_view('item'), methods=['GET'])\n"
    "@app.trace('/t')\ndef ignored():\n    pass\n"
)


class TestFlask:
    """Scenarios for Flask in docs_python_native.routes."""

    def test_blueprints_and_rules(self) -> None:
        """Scenario: Flask blueprints and rules compose their prefixes and methods."""
        output = _run(("src/web.py", FLASK))
        routes = _routes(output)
        assert {"GET /", "GET /multi", "POST /multi"} <= set(routes)
        assert {"GET /bp/items/<int:item_id>", "GET /other/items/<int:item_id>"} <= set(
            routes
        )
        assert routes["GET <dynamic>/l"]["mounted"] is False
        assert routes["PUT /rule"]["name"] == "/rule"
        assert "GET /view2" in routes and "GET /t" not in routes
        assert sorted(code for _p, code in _codes(output)) == [
            "HTTP_METHOD_VIEW_UNRESOLVED",
            "HTTP_PREFIX_DYNAMIC",
        ]

    def test_unparsed_file_and_unknown_relative_child(self) -> None:
        """Scenario: an unparsed file is skipped; an unknown child is unresolved."""
        output = _run(
            ("src/bad.py", "x = (\n"),
            (
                "top.py",
                (
                    "from flask import Flask\nfrom . import mod\n"
                    "app = Flask(__name__)\napp.register_blueprint(mod.bp)\n"
                ),
            ),
        )
        assert _codes(output) == [("top.py", "HTTP_MOUNT_UNRESOLVED")]
