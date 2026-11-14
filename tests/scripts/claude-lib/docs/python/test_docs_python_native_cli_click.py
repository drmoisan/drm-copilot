"""Tests for docs_python_native.cli_click: commands, groups, parameters."""

import pytest
from docs_python_native.call_sites import CliResult, CliSite
from docs_python_native.cli_click import click_default_name, recognize_click
from docs_python_native.imports import build_tables
from docs_python_native.source import parse_module


def _recognize(text: str) -> CliResult:
    """Parse a source text and run the Click recognizer over it."""
    parsed = parse_module(text)
    return recognize_click(parsed, build_tables(parsed))


def _site(result: CliResult, site_id: str) -> CliSite:
    """Return the recognized site with the given identifier."""
    return next(site for site in result.sites if site.site_id == site_id)


def _options(result: CliResult, parent: str) -> list[CliSite]:
    """Return the option sites whose parent is the given site."""
    return [s for s in result.sites if s.kind == "option" and s.parent_id == parent]


def _codes(result: CliResult) -> list[str]:
    """Return the raw diagnostic codes of a recognizer result."""
    return sorted(d.code for d in result.diagnostics)


TREE = """import click as c
from click import command, option as opt


@c.group(name="main")
@c.option("--debug/--no-debug", default=False, help="Debug")
def cli_group():
    pass


@cli_group.command()
@opt("-n", "--name", required=True)
@c.argument("target")
def sync_command(name, target):
    pass


@cli_group.group("nested")
def nested_grp():
    pass


@nested_grp.command(
    name="deep",
)
def deep_cmd():
    pass


@command
def plain_cmd():
    pass


@c.command()
def extra_command():
    pass


cli_group.add_command(plain_cmd)
cli_group.add_command(extra_command, name="extra")
cli_group.add_command(other.module_cmd)
"""


class TestDefaultName:
    """Scenarios for default name in docs_python_native.cli_click."""

    @pytest.mark.parametrize(
        ("function_name", "expected"),
        [
            ("sync_command", "sync"),
            ("plain_cmd", "plain"),
            ("nested_grp", "nested"),
            ("My_Group", "my"),
            ("cmd", "cmd"),
            ("deploy", "deploy"),
        ],
    )
    def test_lower_cases_replaces_underscores_and_strips_one_suffix(
        self, function_name: str, expected: str
    ) -> None:
        """Scenario: lower cases replaces underscores and strips one suffix."""
        assert click_default_name(function_name) == expected


class TestTree:
    """Scenarios for tree in docs_python_native.cli_click."""

    def test_root_group_with_literal_name_and_option(self) -> None:
        """Scenario: root group with literal name and option."""
        result = _recognize(TREE)
        root = _site(result, "cli_group")
        assert (root.kind, root.name, root.span, root.attach, root.is_group) == (
            "root",
            "main",
            (5, 7),
            "cli_group",
            True,
        )
        (debug,) = _options(result, "cli_group")
        assert (debug.name, debug.span) == ("--debug", (6, 6))
        assert debug.properties == {
            "framework": "click",
            "has_default": True,
            "positional": False,
            "help": "Debug",
        }

    def test_commands_and_parameters_under_tracked_groups(self) -> None:
        """Scenario: commands and parameters under tracked groups."""
        result = _recognize(TREE)
        sync = _site(result, "sync_command")
        assert (sync.parent_id, sync.default_name, sync.span) == (
            "cli_group",
            "sync",
            (11, 14),
        )
        name, target = _options(result, "sync_command")
        assert name.name == "--name" and name.properties["short"] == "-n"
        assert name.properties["required"] is True
        assert target.name == "target" and target.properties["positional"] is True
        deep = _site(result, "deep_cmd")
        assert (deep.parent_id, deep.name, deep.span) == (
            "nested_grp",
            "deep",
            (23, 26),
        )

    def test_add_command_reparents_with_and_without_name(self) -> None:
        """Scenario: add command reparents with and without name."""
        result = _recognize(TREE)
        plain = _site(result, "plain_cmd")
        extra = _site(result, "extra_command")
        assert (plain.kind, plain.parent_id, plain.attach, plain.name) == (
            "command",
            "cli_group",
            None,
            None,
        )
        assert (extra.parent_id, extra.name) == ("cli_group", "extra")
        assert result.diagnostics == []


class TestDiagnostics:
    """Scenarios for diagnostics in docs_python_native.cli_click."""

    def test_click_diagnostic_classes(self) -> None:
        """Scenario: each Click diagnostic is reported and drops only its site."""
        text = (
            "import click\n"
            "class G(click.Group):\n    pass\n"
            "@click.group(cls=G)\ndef custom():\n    pass\n"
            "collection = click.CommandCollection(sources=[custom])\n"
            "shortcut = click.command\n"
            "@shortcut()\ndef indirect():\n    pass\n"
            "def wrapped():\n    pass\n"
            "wrapped = click.command()(wrapped)\n"
            "@click.group(name='ok')\ndef ok_group():\n    pass\n"
            "@click.command(name='fine')\ndef fine():\n    pass\n"
            "for alias in ('a', 'b'):\n    ok_group.add_command(fine, name=alias)\n"
            "def attach(group):\n    group.add_command(fine)\n"
            "@ghost.command()\ndef orphan():\n    pass\n"
            "@click.command(NAME)\ndef dynamic():\n    pass\n"
            "@click.command(*names)\ndef starred():\n    pass\n"
            "@click.command()\n@click.option(NAME)\n@click.option('/')\n@click.option\n"
            "def options():\n    pass\n"
            "ok_group.add_command(fine, name=NAME)\n"
            "for i in x:\n    @click.command()\n    def looped():\n        pass\n"
        )
        result = _recognize(text)
        assert _codes(result) == sorted(
            ["CLI_CUSTOM_CLASS"] * 2
            + ["CLI_DECORATOR_INDIRECT"] * 2
            + ["CLI_REGISTRATION_IN_LOOP"] * 2
            + ["CLI_UNBOUND_REGISTRATION"] * 2
            + ["CLI_DYNAMIC_REGISTRATION"] * 6
        )
        roots = sorted(s.site_id for s in result.sites if s.kind == "root")
        assert roots == ["fine", "ok_group", "options"]

    def test_unparsed_input_yields_nothing(self) -> None:
        """Scenario: unparsed input yields no sites."""
        assert _recognize("x = (\n").sites == []

    def test_group_closure_tracks_nested_groups_declared_before_their_parent(
        self,
    ) -> None:
        """Scenario: group closure tracks nested groups declared before their parent."""
        text = (
            "import click\n"
            "@outer.group()\ndef inner():\n    pass\n"
            "@click.group()\ndef outer():\n    pass\n"
            "@inner.command()\ndef leaf():\n    pass\n"
        )
        result = _recognize(text)
        assert _site(result, "leaf").parent_id == "inner"
        assert _site(result, "inner").parent_id == "outer"
