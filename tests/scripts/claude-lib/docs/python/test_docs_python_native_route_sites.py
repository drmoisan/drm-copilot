"""Tests for docs_python_native.route_sites: method lists and pass-1 site collection."""

import ast

import pytest
from docs_python_native.facts import AnalyzerOutput
from docs_python_native.imports import AnalyzedFile, build_tables
from docs_python_native.route_model import RouteFile
from docs_python_native.route_sites import collect_sites, method_list
from docs_python_native.source import parse_module


def _collect(text: str) -> tuple[RouteFile, AnalyzerOutput]:
    parsed = parse_module(text)
    entry = RouteFile(
        AnalyzedFile("src/app.py", parsed, build_tables(parsed)), "app", ""
    )
    output = AnalyzerOutput("python-http")
    collect_sites(entry, output)
    return entry, output


def _codes(output: AnalyzerOutput) -> list[str]:
    return sorted(d.code for ds in output.diagnostics.values() for d in ds)


class TestMethodList:
    @pytest.mark.parametrize(
        ("text", "expected"),
        [
            ("f('/x')", ("GET",)),
            ("f('/x', methods=['get', 'POST', 'GET'])", ("GET", "POST")),
            ("f('/x', methods=('put',))", ("PUT",)),
            ("f('/x', methods=[])", None),
            ("f('/x', methods=METHODS)", None),
            ("f('/x', methods=[m])", None),
        ],
    )
    def test_reads_literal_method_lists(
        self, text: str, expected: tuple[str, ...] | None
    ) -> None:
        call = ast.parse(text, mode="eval").body
        assert isinstance(call, ast.Call)
        assert method_list(call) == expected


class TestCollectSites:
    def test_decorator_route_is_collected_with_its_header_span(self) -> None:
        entry, output = _collect(
            "from fastapi import FastAPI\napp = FastAPI()\n"
            "@app.get('/items')\ndef items():\n    pass\n"
        )
        assert [
            (r.receiver, r.methods, r.path, r.name, r.span) for r in entry.routes
        ] == [("app", ("GET",), "/items", "items", (3, 4))]
        assert entry.receivers["app"].kind == "app"
        assert _codes(output) == []

    def test_add_api_route_call_is_collected_with_its_methods(self) -> None:
        entry, _output = _collect(
            "from fastapi import FastAPI\napp = FastAPI()\n"
            "app.add_api_route('/health', handler, methods=['HEAD'])\n"
        )
        assert [(r.methods, r.path, r.protocol) for r in entry.routes] == [
            (("HEAD",), "/health", "http")
        ]

    def test_mount_records_the_child_and_its_literal_prefix(self) -> None:
        entry, _output = _collect(
            "from fastapi import FastAPI, APIRouter\napp = FastAPI()\n"
            "items = APIRouter(prefix='/items')\n"
            "app.include_router(items, prefix='/v2')\n"
        )
        assert [(m.parent, m.child, m.prefix, m.given) for m in entry.mounts] == [
            ("app", "items", "/v2", True)
        ]
        assert entry.receivers["items"].prefix == "/items"

    def test_route_in_a_loop_reports_the_diagnostic_and_collects_nothing(
        self,
    ) -> None:
        entry, output = _collect(
            "from flask import Flask\napp = Flask(__name__)\n"
            "for rule in rules:\n    app.add_url_rule(rule, view_func=v)\n"
        )
        assert entry.routes == []
        assert _codes(output) == ["HTTP_ROUTE_IN_LOOP"]
