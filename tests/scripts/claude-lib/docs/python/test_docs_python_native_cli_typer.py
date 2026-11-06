"""Tests for docs_python_native.cli_typer: roots, commands, callbacks, parameters."""

import ast

import pytest
from docs_python_native.call_sites import CliResult, CliSite
from docs_python_native.cli_typer import plain_default, recognize_typer
from docs_python_native.imports import build_tables
from docs_python_native.source import parse_module


def _recognize(text: str) -> CliResult:
    parsed = parse_module(text)
    return recognize_typer(parsed, build_tables(parsed))


def _site(result: CliResult, site_id: str) -> CliSite:
    return next(site for site in result.sites if site.site_id == site_id)


def _options(result: CliResult, parent: str) -> dict[str, CliSite]:
    return {
        s.name or "": s
        for s in result.sites
        if s.kind == "option" and s.parent_id == parent
    }


def _codes(result: CliResult) -> list[str]:
    return sorted(d.code for d in result.diagnostics)


TREE = """import typer
from typing import Annotated

app = typer.Typer(name="typ")
sub = typer.Typer()
app.add_typer(sub, name="sub")


@app.callback()
def main_callback(verbose: bool = False):
    pass


@app.command()
def run_task(
    name: str,
    count: int = 3,
    flag: bool = typer.Option(False, "--flag", "-f", help="Flag it"),
    tag: Annotated[str, typer.Option()] = "x",
    req: str = typer.Option(..., "-r"),
    *args,
    level: int = -1,
    **kwargs,
):
    pass


@app.command("explicit-name")
def other():
    pass


@sub.command()
def inner_thing(item: Annotated[str, typer.Argument()]):
    pass


def standalone(value: int = 1):
    pass


typer.run(standalone)
"""


class TestPlainDefault:
    @pytest.mark.parametrize(
        ("text", "expected"),
        [
            ("1", True),
            ("'s'", True),
            ("f'{x}'", True),
            ("None", True),
            ("name", True),
            ("-1", True),
            ("-x", False),
            ("-True", False),
            ("[1]", True),
            ("{}", True),
            ("(1, 2)", True),
            ("[x for x in y]", True),
            ("make()", False),
            ("a.b", False),
            ("a + b", False),
        ],
    )
    def test_classifies_default_forms(self, text: str, expected: bool) -> None:
        expression = ast.parse(text, mode="eval").body
        assert plain_default(expression) is expected


class TestTree:
    def test_root_and_add_typer_subgroup(self) -> None:
        result = _recognize(TREE)
        root = _site(result, "app")
        assert (root.kind, root.name, root.span, root.attach) == (
            "root",
            "typ",
            (4, 4),
            "app",
        )
        child = _site(result, "sub")
        assert (child.kind, child.parent_id, child.name, child.span, child.attach) == (
            "command",
            "app",
            "sub",
            (6, 6),
            None,
        )

    def test_callback_parameters_become_root_options(self) -> None:
        result = _recognize(TREE)
        (verbose,) = _options(result, "app").values()
        assert verbose.name == "--verbose" and verbose.properties["has_default"] is True
        assert result.diagnostics == []

    def test_command_parameters(self) -> None:
        result = _recognize(TREE)
        command = _site(result, "run_task")
        assert (command.parent_id, command.default_name, command.span) == (
            "app",
            "run-task",
            (14, 24),
        )
        options = _options(result, "run_task")
        assert sorted(options) == [
            "--count",
            "--flag",
            "--level",
            "--tag",
            "-r",
            "name",
        ]
        assert options["name"].properties == {
            "framework": "typer",
            "positional": True,
            "has_default": False,
        }
        assert options["--flag"].properties["short"] == "-f"
        assert options["--flag"].properties["help"] == "Flag it"
        assert options["--tag"].properties["has_default"] is True
        assert options["-r"].properties["has_default"] is False
        assert options["--count"].span == (17, 17)

    def test_explicit_name_argument_and_run_root(self) -> None:
        result = _recognize(TREE)
        assert _site(result, "other").name == "explicit-name"
        (item,) = _options(result, "inner_thing").values()
        assert item.name == "item" and item.properties["positional"] is True
        root = _site(result, "standalone")
        assert (root.kind, root.name, root.span, root.attach) == (
            "root",
            None,
            (38, 38),
            "standalone",
        )
        assert sorted(_options(result, "standalone")) == ["--value"]


class TestDiagnostics:
    def test_typer_diagnostic_classes(self) -> None:
        text = (
            "import typer\n"
            "custom = typer.Typer(name='c', cls=K)\n"
            "dyn = typer.Typer(name=NAME)\n"
            "app = typer.Typer(name='tdiag')\n"
            "good = typer.Typer()\n"
            "for i in x:\n    looped = typer.Typer()\n"
            "@app.command()\n"
            "def unresolved(value: dict = make(), other: str = 's'):\n    pass\n"
            "@app.command(cls=K)\ndef classed():\n    pass\n"
            "@app.command(NAME)\ndef named():\n    pass\n"
            "@ghost.command()\ndef orphan():\n    pass\n"
            "for i in x:\n    @app.command()\n    def inside():\n        pass\n"
            "def f(): pass\n"
            "for i in x:\n    typer.run(f)\n    app.add_typer(dyn)\n"
            "app.add_typer(good, name=NAME)\n"
            "ghost.add_typer(dyn)\n"
            "app.add_typer(unknown)\n"
            "typer.run(missing)\n"
            "@f.command()\ndef silent():\n    pass\n"
        )
        result = _recognize(text)
        assert _codes(result) == sorted(
            ["CLI_CUSTOM_CLASS"] * 2
            + ["CLI_DYNAMIC_REGISTRATION"] * 3
            + ["CLI_REGISTRATION_IN_LOOP"] * 4
            + ["CLI_UNBOUND_REGISTRATION"] * 2
            + ["CLI_TYPER_PARAMETER_UNRESOLVED"]
        )
        assert sorted(_options(result, "unresolved")) == ["--other"]

    def test_unparsed_input_yields_nothing(self) -> None:
        assert _recognize("x = (\n").sites == []
