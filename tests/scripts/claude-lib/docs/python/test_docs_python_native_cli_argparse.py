"""Tests for docs_python_native.cli_argparse: roots, subcommands, options."""

from docs_python_native.call_sites import CliResult, CliSite
from docs_python_native.cli_argparse import recognize_argparse
from docs_python_native.imports import build_tables
from docs_python_native.source import parse_module


def _recognize(text: str) -> CliResult:
    parsed = parse_module(text)
    return recognize_argparse(parsed, build_tables(parsed))


def _site(result: CliResult, name: str) -> CliSite:
    return next(site for site in result.sites if site.name == name)


def _codes(result: CliResult) -> list[str]:
    return sorted(d.code for d in result.diagnostics)


TREE = """import argparse as ap


def build():
    parser = ap.ArgumentParser(
        prog="tool", description="d"
    )
    parser.add_argument("--verbose", "-v", action="store_true", help="Verbose")
    parser.add_argument("path")
    parser.add_argument("-q")
    sub = parser.add_subparsers()
    run = sub.add_parser("run", help="Run")
    group = run.add_argument_group()
    group.add_argument("--count", default=1, required=True)
    nested = run.add_subparsers()
    deep = nested.add_parser("deep")
    deep.add_argument("--level", required=False)
    return parser
"""


class TestTree:
    def test_root_spans_its_whole_statement_and_attaches_to_the_function(self) -> None:
        result = _recognize(TREE)
        root = _site(result, "tool")
        assert (root.kind, root.span, root.attach, root.parent_id) == (
            "root",
            (5, 7),
            "build",
            None,
        )

    def test_options_carry_names_and_shapes(self) -> None:
        result = _recognize(TREE)
        verbose = _site(result, "--verbose")
        assert verbose.properties == {
            "framework": "argparse",
            "positional": False,
            "has_default": False,
            "short": "-v",
            "action": "store_true",
            "help": "Verbose",
        }
        assert verbose.parent_id == "parser"
        assert _site(result, "path").properties["positional"] is True
        assert "short" not in _site(result, "-q").properties
        count = _site(result, "--count")
        assert count.parent_id == "run"
        assert (
            count.properties["has_default"] is True
            and count.properties["required"] is True
        )
        assert _site(result, "--level").properties["required"] is False

    def test_nested_subcommands_link_to_their_parser(self) -> None:
        result = _recognize(TREE)
        run = _site(result, "run")
        assert (run.kind, run.parent_id, run.properties) == (
            "command",
            "parser",
            {"framework": "argparse", "help": "Run"},
        )
        assert _site(result, "deep").parent_id == "run"


class TestDiagnostics:
    def test_each_diagnostic_removes_only_its_site(self) -> None:
        text = (
            "from argparse import ArgumentParser\n"
            "NAME = 'x'\n"
            "def build(arg):\n"
            "    parser = ArgumentParser(prog='diag')\n"
            "    parser.add_argument(NAME)\n"
            "    parser.add_argument(f'--{NAME}')\n"
            "    parser.add_argument(*NAMES)\n"
            "    for i in range(2):\n"
            "        parser.add_argument('--loop')\n"
            "    [parser.add_argument('--comp') for i in x]\n"
            "    arg.add_argument('--unbound')\n"
            "    self.parser.add_argument('--attr')\n"
            "    make().add_argument('--call')\n"
            "    child = ArgumentParser(prog='child', parents=[parser])\n"
            "    child.add_argument('--own')\n"
            "    other = ArgumentParser(prog=NAME)\n"
            "    sub = child.add_subparsers()\n"
            "    sub.add_parser(NAME)\n"
            "    sub.add_parser('kept')\n"
            "    return parser\n"
        )
        result = _recognize(text)
        assert _codes(result) == sorted(
            ["CLI_DYNAMIC_REGISTRATION"] * 5
            + ["CLI_REGISTRATION_IN_LOOP"] * 2
            + ["CLI_UNBOUND_REGISTRATION"] * 3
            + ["CLI_PARENTS_UNRESOLVED"]
        )
        names = sorted(site.name or "" for site in result.sites)
        assert names == ["--own", "child", "diag", "kept"]
        kept = _site(result, "kept")
        assert kept.site_id.startswith("#argparse-") and kept.parent_id == "child"

    def test_methods_on_a_tracked_non_argparse_receiver_are_silent(self) -> None:
        result = _recognize(
            "import typer\napp = typer.Typer()\napp.add_argument('--x')\n"
        )
        assert result.sites == [] and result.diagnostics == []

    def test_unassigned_constructor_and_unparsed_input_yield_nothing(self) -> None:
        assert (
            _recognize("import argparse\nargparse.ArgumentParser(prog='x')\n").sites
            == []
        )
        assert _recognize("x = (\n").sites == []

    def test_root_outside_a_function_attaches_to_its_receiver(self) -> None:
        result = _recognize(
            "import argparse\nclass K:\n    p = argparse.ArgumentParser()\n"
            "q = argparse.ArgumentParser()\n"
        )
        assert sorted(site.attach or "" for site in result.sites) == ["p", "q"]
        assert all(site.name is None for site in result.sites)

    def test_add_argument_on_a_broken_receiver_chain_is_unbound(self) -> None:
        result = _recognize(
            "import argparse\np = argparse.ArgumentParser()\ng = p.add_parser('x')\n"
            "g.add_argument('--y')\n"
        )
        assert _codes(result) == ["CLI_UNBOUND_REGISTRATION"]
