"""Tests for docs_python_native.imports: aliases, receivers, definitions, names."""

import pytest
from docs_python_native.imports import (
    BINDING_AMBIGUOUS,
    NESTED_FRAMEWORK,
    STAR_FRAMEWORK,
    AnalyzerOutput,
    ModuleTables,
    build_tables,
    module_dotted_name,
    module_package,
    resolve_relative,
)
from docs_python_native.source import parse_module


def _tables(text: str) -> ModuleTables:
    return build_tables(parse_module(text))


class TestAliasTable:
    @pytest.mark.parametrize(
        ("text", "name", "expected"),
        [
            ("import click\n", "click.command", "click.command"),
            ("import click as c\n", "c.command", "click.command"),
            ("import os.path\n", "os.path.join", "os.path.join"),
            ("from click import command\n", "command", "click.command"),
            ("from click import command as cmd\n", "cmd", "click.command"),
            ("from . import util\n", "util.f", ".util.f"),
            ("from .pkg import mod\n", "mod", ".pkg.mod"),
            ("if x:\n    import typer\n", "typer.Typer", "typer.Typer"),
            ("try:\n    import typer\nexcept E:\n    pass\n", "typer.run", "typer.run"),
            ("unbound\n", "unbound.x", "unbound.x"),
        ],
    )
    def test_qualify_resolves_each_import_form(
        self, text: str, name: str, expected: str
    ) -> None:
        assert _tables(text).qualify(name) == expected

    def test_qualify_of_none_is_none(self) -> None:
        assert _tables("").qualify(None) is None

    def test_import_inside_with_block_binds_nothing(self) -> None:
        tables = _tables("with x:\n    import typer as t\n")
        assert tables.qualify("t.Typer") == "t.Typer"
        assert tables.diagnostics == []

    def test_nested_framework_import_is_reported_and_not_bound(self) -> None:
        tables = _tables("def f():\n    import typer\n    from click import command\n")
        codes = [d.code for d in tables.diagnostics]
        assert codes == [NESTED_FRAMEWORK, NESTED_FRAMEWORK]
        assert tables.qualify("typer.Typer") == "typer.Typer"
        assert "typer" not in tables.alias

    def test_nested_non_framework_import_is_silent(self) -> None:
        assert _tables("class K:\n    import json\n").diagnostics == []

    def test_star_import_of_framework_is_reported(self) -> None:
        tables = _tables("from click import *\nfrom os import *\n")
        assert [d.code for d in tables.diagnostics] == [STAR_FRAMEWORK]
        assert tables.statements[0].star and tables.statements[0].module_level

    def test_two_targets_make_the_name_ambiguous(self) -> None:
        tables = _tables(
            "from a import helper\nfrom b import helper\nfrom c import helper\n"
        )
        assert [(d.code, d.line) for d in tables.diagnostics] == [
            (BINDING_AMBIGUOUS, 2)
        ]
        assert tables.qualify("helper.x") is None

    def test_same_target_twice_is_not_ambiguous(self) -> None:
        tables = _tables("import click\nimport click\n")
        assert tables.diagnostics == []
        assert tables.qualify("click") == "click"


class TestReceivers:
    def test_tracks_assignment_and_annotated_assignment_at_any_depth(self) -> None:
        tables = _tables(
            "app = typer.Typer()\nr: R = fastapi.APIRouter(prefix='/x')\n"
            "def f():\n    p = argparse.ArgumentParser()\n"
            "x = y = make()\nz = g()()\nw = 1\n"
        )
        assert list(tables.receivers) == ["app", "r", "p"]
        assert tables.receivers["p"].context.nested
        assert tables.receivers["app"].callee == "typer.Typer"

    def test_rebinding_to_another_call_is_ambiguous(self) -> None:
        tables = _tables(
            "a = make(1)\na = make(2)\na = make(3)\nb = make()\nb = make()\n"
        )
        assert "a" not in tables.receivers
        assert [d.code for d in tables.diagnostics] == [BINDING_AMBIGUOUS]
        assert "b" in tables.receivers


class TestDefinitions:
    def test_definitions_keep_the_first_function_and_note_classes(self) -> None:
        tables = _tables("def f(): pass\nasync def f(): pass\nclass K: pass\n")
        assert tables.definitions["f"].lineno == 1
        assert tables.is_known_name("f")
        assert not tables.is_known_name("K")
        assert tables.is_known_name("K", include_classes=True)

    def test_unparsed_module_has_empty_tables(self) -> None:
        tables = build_tables(parse_module("x = (\n"))
        assert tables.statements == [] and tables.receivers == {}


class TestModuleNames:
    @pytest.mark.parametrize(
        ("path", "roots", "expected"),
        [
            ("src/pkg/mod.py", ["src"], "pkg.mod"),
            ("src/pkg/__init__.py", ["src/"], "pkg"),
            ("src/pkg/sub/mod.py", ["src", "src/pkg"], "sub.mod"),
            ("mod.py", ["."], "mod"),
            ("other/mod.py", ["src"], None),
            ("src/pkg/data.txt", ["src"], None),
            ("src/__init__.py", ["src"], None),
            ("__init__.py", [""], None),
            ("src/pkg/bad-name.py", ["src"], None),
        ],
    )
    def test_module_dotted_name(
        self, path: str, roots: list[str], expected: str | None
    ) -> None:
        assert module_dotted_name(path, roots) == expected

    def test_unvalidated_name_keeps_a_non_identifier_segment(self) -> None:
        assert module_dotted_name(
            "src/pkg/bad-name.py", ["src"], require_identifiers=False
        ) == ("pkg.bad-name")

    @pytest.mark.parametrize(
        ("path", "module", "expected"),
        [
            ("src/pkg/__init__.py", "pkg", "pkg"),
            ("src/pkg/mod.py", "pkg.mod", "pkg"),
            ("src/top.py", "top", ""),
            ("x.py", None, None),
        ],
    )
    def test_module_package(
        self, path: str, module: str | None, expected: str | None
    ) -> None:
        assert module_package(path, module) == expected

    @pytest.mark.parametrize(
        ("module", "package", "expected"),
        [
            ("pkg.mod", "x", "pkg.mod"),
            (".mod", "pkg.sub", "pkg.sub.mod"),
            ("..mod", "pkg.sub", "pkg.mod"),
            ("...mod", "pkg.sub", "mod"),
            ("....mod", "pkg.sub", None),
            (".", "pkg", "pkg"),
            ("..", "pkg", None),
            (".mod", "", None),
            (".mod", None, None),
        ],
    )
    def test_resolve_relative_climbs_and_stops_above_the_root(
        self, module: str, package: str | None, expected: str | None
    ) -> None:
        assert resolve_relative(module, package) == expected


class TestAnalyzerOutput:
    def test_facts_sort_properties_and_serialize_parents(self) -> None:
        output = AnalyzerOutput("python-cli")
        output.add_fact(
            "a.py",
            "cli-option",
            "r --x",
            "--x",
            (1, 2),
            {"b": True, "a": "v"},
            ("cli-command", "r", "a.py"),
        )
        output.add_fact("a.py", "architecture-component", "a", "a", None, {})
        first, second = output.facts["a.py"]
        assert first.to_json()["parent"] == {
            "kind": "cli-command",
            "declaration": "r",
            "path": "a.py",
        }
        assert first.to_json()["properties"] == {"a": "v", "b": True}
        assert (
            second.to_json()["line_start"] is None
            and second.to_json()["parent"] is None
        )
