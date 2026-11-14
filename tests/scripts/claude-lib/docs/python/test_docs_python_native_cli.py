"""Tests for docs_python_native.cli: root names, script attachment, parents."""

from docs_python_native.call_sites import CliSite
from docs_python_native.cli import ConsoleScript, analyze_cli, root_name
from docs_python_native.facts import Fact
from docs_python_native.imports import AnalyzedFile, build_tables
from docs_python_native.source import parse_module

ROOTS = ["src"]


def _file(path: str, text: str) -> AnalyzedFile:
    """Build an AnalyzedFile from an in-memory path and source text."""
    parsed = parse_module(text)
    return AnalyzedFile(path, parsed, build_tables(parsed))


def _facts(files: list[AnalyzedFile], scripts: list[ConsoleScript]) -> dict[str, Fact]:
    """Run analyze_cli and map each fact declaration to its fact."""
    output = analyze_cli(files, ROOTS, scripts)
    return {fact.declaration: fact for facts in output.facts.values() for fact in facts}


ARGPARSE = (
    "import argparse\n"
    "def build():\n"
    "    parser = argparse.ArgumentParser(prog='argtool')\n"
    "    parser.add_argument('--verbose')\n"
    "    sub = parser.add_subparsers()\n"
    "    run = sub.add_parser('run')\n"
    "    return parser\n"
)
TYPER = (
    "import typer\napp = typer.Typer()\n@app.command()\ndef go(x: int = 1):\n    pass\n"
)


class TestRootName:
    """Scenarios for root name in docs_python_native.cli."""

    def test_order_is_script_then_literal_then_module(self) -> None:
        """Scenario: order is script then literal then module."""
        site = CliSite("root", "click", "f", None, "lit", (1, 1), {})
        assert root_name(site, "script", "mod") == ("script", "console-script")
        assert root_name(site, None, "mod") == ("lit", "literal")
        site.name = None
        assert root_name(site, None, "mod") == ("mod", "module")
        assert root_name(site, None, None) is None


class TestAttachment:
    """Scenarios for attachment in docs_python_native.cli."""

    def test_attached_root_is_replaced_by_the_script(self) -> None:
        """Scenario: attached root is replaced by the script."""
        files = [_file("src/pkg/cli.py", ARGPARSE)]
        scripts = [
            ConsoleScript("tool", "project.scripts", "pyproject.toml", "pkg.cli:build")
        ]
        facts = _facts(files, scripts)
        assert "argtool" not in facts
        verbose = facts["tool --verbose"]
        assert verbose.parent == ("cli-command", "tool", "pyproject.toml")
        assert (verbose.kind, verbose.name) == ("cli-option", "--verbose")
        run = facts["tool run"]
        assert run.parent == ("cli-command", "tool", "pyproject.toml")
        assert dict(run.properties) == {"framework": "argparse"}

    def test_unattached_root_keeps_its_literal_name(self) -> None:
        """Scenario: unattached root keeps its literal name."""
        files = [_file("src/pkg/cli.py", ARGPARSE)]
        scripts = [
            ConsoleScript("a", "project.scripts", "pyproject.toml", "pkg.cli:other"),
            ConsoleScript("b", "project.scripts", "pyproject.toml", "pkg.none:build"),
            ConsoleScript("c", "project.scripts", "pyproject.toml", "nocolon"),
            ConsoleScript("d", "project.scripts", "pyproject.toml", ":build"),
        ]
        facts = _facts(files, scripts)
        root = facts["argtool"]
        assert dict(root.properties)["name_source"] == "literal"
        assert root.parent is None and (root.line_start, root.line_end) == (3, 3)
        assert facts["argtool run"].parent == (
            "cli-command",
            "argtool",
            "src/pkg/cli.py",
        )

    def test_module_named_root_and_ambiguous_module_target(self) -> None:
        """Scenario: module named root and ambiguous module target."""
        files = [_file("src/pkg/t.py", TYPER), _file("lib/pkg/t.py", TYPER)]
        scripts = [ConsoleScript("t", "project.scripts", "pyproject.toml", "pkg.t:app")]
        output = analyze_cli(files, ["src", "lib"], scripts)
        declarations = sorted(
            f.declaration for facts in output.facts.values() for f in facts
        )
        assert declarations == [
            "pkg.t",
            "pkg.t",
            "pkg.t go",
            "pkg.t go",
            "pkg.t go --x",
            "pkg.t go --x",
        ]

    def test_root_without_any_name_is_dropped_with_its_children(self) -> None:
        """Scenario: root without any name is dropped with its children."""
        facts = _facts([_file("elsewhere/t.py", TYPER)], [])
        assert facts == {}

    def test_recognizer_diagnostics_are_reported_per_path(self) -> None:
        """Scenario: recognizer diagnostics are reported per path."""
        output = analyze_cli(
            [
                _file(
                    "src/x.py",
                    "import argparse\ndef f(p):\n    p.add_argument('--x')\n",
                )
            ],
            ROOTS,
            [],
        )
        assert [(d.code, d.line) for d in output.diagnostics["src/x.py"]] == [
            ("CLI_UNBOUND_REGISTRATION", 3)
        ]


CALLER = (
    "import argparse\n"
    "from pkg import cli_daily\n"
    "def build():\n"
    "    parser = argparse.ArgumentParser(prog='tool')\n"
    "    subparsers = parser.add_subparsers()\n"
    "    cli_daily.register(subparsers)\n"
    "    return parser\n"
)
REGISTER = (
    "def register(subparsers):\n"
    "    daily = subparsers.add_parser('daily', help='Daily')\n"
    "    daily.add_argument('--date')\n"
)


class TestCrossModuleRegistration:
    """Scenarios for the cross-module subparsers bind of issue 1173 B9."""

    def test_registration_through_a_parameter_binds_to_the_caller_parser(
        self,
    ) -> None:
        """Scenario: commands and options attach under the caller's command."""
        # Arrange
        files = [
            _file("src/pkg/cli.py", CALLER),
            _file("src/pkg/cli_daily.py", REGISTER),
        ]

        # Act
        output = analyze_cli(files, ROOTS, [])
        facts = {f.declaration: f for fs in output.facts.values() for f in fs}
        paths = {f.declaration: p for p, fs in output.facts.items() for f in fs}

        # Assert
        daily = facts["tool daily"]
        assert (paths["tool daily"], daily.kind, daily.name) == (
            "src/pkg/cli_daily.py",
            "cli-command",
            "daily",
        )
        assert daily.parent == ("cli-command", "tool", "src/pkg/cli.py")
        assert dict(daily.properties) == {"framework": "argparse", "help": "Daily"}
        date = facts["tool daily --date"]
        assert date.parent == ("cli-command", "tool daily", "src/pkg/cli_daily.py")
        assert (date.line_start, date.line_end) == (3, 3)
        assert all(not codes for codes in output.diagnostics.values())

    def test_a_console_script_root_carries_into_the_bound_registration(
        self,
    ) -> None:
        """Scenario: an attached root names the commands of the other module."""
        # Arrange
        files = [
            _file("src/pkg/cli.py", CALLER),
            _file("src/pkg/cli_daily.py", REGISTER),
        ]
        scripts = [
            ConsoleScript(
                "daily-tool", "project.scripts", "pyproject.toml", "pkg.cli:build"
            )
        ]

        # Act
        facts = _facts(files, scripts)

        # Assert
        assert facts["daily-tool daily"].parent == (
            "cli-command",
            "daily-tool",
            "pyproject.toml",
        )

    def test_registration_without_a_resolvable_caller_is_unbound(self) -> None:
        """Scenario: no caller keeps CLI_UNBOUND_REGISTRATION for each registration."""
        # Arrange
        other = CALLER.replace("cli_daily.register", "cli_other.register").replace(
            "from pkg import cli_daily", "from pkg import cli_other"
        )
        files = [
            _file("src/pkg/cli.py", other),
            _file("src/pkg/cli_daily.py", REGISTER),
        ]

        # Act
        output = analyze_cli(files, ROOTS, [])

        # Assert
        assert [
            (d.code, d.line) for d in output.diagnostics["src/pkg/cli_daily.py"]
        ] == [
            ("CLI_UNBOUND_REGISTRATION", 2),
            ("CLI_UNBOUND_REGISTRATION", 3),
        ]
        declarations = {f.declaration for fs in output.facts.values() for f in fs}
        assert declarations == {"tool"}

    def test_unbound_role_keeps_the_sites_that_are_not_beneath_it(self) -> None:
        """Scenario: only registrations under the unbound parameter are reported."""
        # Arrange
        text = (
            "import argparse\n"
            "parser = argparse.ArgumentParser(prog='solo')\n"
            "def register(subparsers):\n"
            "    subparsers.add_parser('lost')\n"
        )

        # Act
        output = analyze_cli([_file("src/tool/solo.py", text)], ROOTS, [])

        # Assert
        declarations = {f.declaration for fs in output.facts.values() for f in fs}
        assert declarations == {"solo"}
        assert [(d.code, d.line) for d in output.diagnostics["src/tool/solo.py"]] == [
            ("CLI_UNBOUND_REGISTRATION", 4)
        ]

    def test_keyword_handoff_binds_a_keyword_only_parameter(self) -> None:
        """Scenario: subparsers passed by keyword bind a keyword-only parameter."""
        # Arrange
        caller = CALLER.replace(
            "cli_daily.register(subparsers)",
            "cli_daily.register(subparsers=subparsers)",
        )
        register = REGISTER.replace(
            "def register(subparsers)", "def register(*, subparsers)"
        )
        files = [
            _file("src/pkg/cli.py", caller),
            _file("src/pkg/cli_daily.py", register),
        ]

        # Act
        facts = _facts(files, [])

        # Assert
        assert facts["tool daily"].parent == ("cli-command", "tool", "src/pkg/cli.py")
