"""Tests for docs_python_native.route_sites: method lists and pass-1 site collection."""

import ast

import pytest
from docs_python_native.facts import AnalyzerOutput
from docs_python_native.imports import AnalyzedFile, build_tables
from docs_python_native.route_model import RouteFile
from docs_python_native.route_sites import collect_sites, method_list
from docs_python_native.source import parse_module


def _collect(text: str) -> tuple[RouteFile, AnalyzerOutput]:
    """Run pass-1 site collection over one in-memory file."""
    parsed = parse_module(text)
    entry = RouteFile(
        AnalyzedFile("src/app.py", parsed, build_tables(parsed)), "app", ""
    )
    output = AnalyzerOutput("python-http")
    collect_sites(entry, output)
    return entry, output


def _codes(output: AnalyzerOutput) -> list[str]:
    """Return the sorted raw diagnostic codes of an analyzer output."""
    return sorted(d.code for ds in output.diagnostics.values() for d in ds)


class TestMethodList:
    """Scenarios for method list in docs_python_native.route_sites."""

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
        """Scenario: literal method lists are read; other forms give None."""
        call = ast.parse(text, mode="eval").body
        assert isinstance(call, ast.Call)
        assert method_list(call) == expected


class TestCollectSites:
    """Scenarios for collect sites in docs_python_native.route_sites."""

    def test_decorator_route_is_collected_with_its_header_span(self) -> None:
        """Scenario: decorator route is collected with its header span."""
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
        """Scenario: add api route call is collected with its methods."""
        entry, _output = _collect(
            "from fastapi import FastAPI\napp = FastAPI()\n"
            "app.add_api_route('/health', handler, methods=['HEAD'])\n"
        )
        assert [(r.methods, r.path, r.protocol) for r in entry.routes] == [
            (("HEAD",), "/health", "http")
        ]

    def test_mount_records_the_child_and_its_literal_prefix(self) -> None:
        """Scenario: mount records the child and its literal prefix."""
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
        """Scenario: route in a loop reports the diagnostic and collects nothing."""
        entry, output = _collect(
            "from flask import Flask\napp = Flask(__name__)\n"
            "for rule in rules:\n    app.add_url_rule(rule, view_func=v)\n"
        )
        assert entry.routes == []
        assert _codes(output) == ["HTTP_ROUTE_IN_LOOP"]
