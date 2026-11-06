"""Tests for docs_python_native.public_api: __all__ forms and the naming rule."""

from docs_python_native.facts import AnalyzerOutput
from docs_python_native.imports import AnalyzedFile, build_tables
from docs_python_native.public_api import analyze_public_api, read_all
from docs_python_native.source import parse_module

ROOTS = ["src"]
CAFE = "caf" + chr(0xE9)


def _file(path: str, text: str) -> AnalyzedFile:
    parsed = parse_module(text)
    return AnalyzedFile(path, parsed, build_tables(parsed))


def _run(path: str, text: str) -> AnalyzerOutput:
    return analyze_public_api([_file(path, text)], ROOTS)


def _symbols(
    output: AnalyzerOutput,
) -> dict[str, tuple[str, str, tuple[int | None, int | None]]]:
    return {
        f.declaration: (
            str(dict(f.properties)["symbol_kind"]),
            str(dict(f.properties)["basis"]),
            (f.line_start, f.line_end),
        )
        for facts in output.facts.values()
        for f in facts
    }


def _codes(output: AnalyzerOutput) -> list[str]:
    return sorted(d.code for ds in output.diagnostics.values() for d in ds)


ALL = (
    '"""Doc."""\n'
    "from pkg.util import helper\n"
    "from pkg.util import *\n"
    "__all__ = ['first', 'helper']\n"
    "__all__ += ['second']\n"
    "__all__.extend(('third',))\n"
    "__all__.append('ghost')\n"
    "__all__.append('first')\n"
    "def first():\n    pass\n"
    "class second:\n    pass\n"
    "third: int = 3\n"
)


class TestAllForms:
    def test_literal_all_forms_in_statement_order(self) -> None:
        output = _run("src/pkg/api.py", ALL)
        assert _symbols(output) == {
            "pkg.api.first": ("function", "all", (9, 9)),
            "pkg.api.helper": ("import", "all", (2, 2)),
            "pkg.api.second": ("class", "all", (11, 11)),
            "pkg.api.third": ("variable", "all", (13, 13)),
            "pkg.api.ghost": ("unresolved", "all", (7, 7)),
        }
        assert _codes(output) == [
            "PUBLIC_API_NAME_UNRESOLVED",
            "PUBLIC_API_STAR_IMPORT",
        ]

    def test_annotated_tuple_replaces_and_empty_list_is_literal(self) -> None:
        result = read_all(
            parse_module("__all__ = ['a']\n__all__: list[str] = ('b',)\n")
        )
        assert (result.found, result.dynamic, result.names) == (True, False, ["b"])
        empty = read_all(parse_module("__all__ = []\n"))
        assert (empty.found, empty.dynamic, empty.names) == (True, False, [])

    def test_dynamic_forms_fall_back_to_the_naming_rule(self) -> None:
        dynamic_forms = [
            "__all__ = ['a'] + ['b']\n",
            "__all__ = [n for n in x]\n",
            "__all__ = list(x)\n",
            "__all__ = ['a', *rest]\n",
            "__all__ = [name]\n",
            "__all__ = x = ['a']\n",
            "__all__ -= ['a']\n",
            "__all__: list[str]\n",
            "__all__.extend(x)\n",
            "__all__.append(name)\n",
            "__all__.remove('a')\n",
            "__all__[0] = 'a'\n",
            "if x:\n    __all__ = ['a']\n",
            "def f():\n    __all__.append('a')\n",
        ]
        for text in dynamic_forms:
            result = read_all(parse_module(text))
            assert (result.found, result.dynamic) == (True, True), text

    def test_statements_not_starting_with_all_are_ignored(self) -> None:
        result = read_all(
            parse_module("__all__\nx = __all__\nprint(__all__)\n__all_x = 1\n")
        )
        assert (result.found, result.dynamic) == (False, False)
        assert read_all(parse_module("x = (\n")).found is False

    def test_dynamic_all_reports_and_uses_naming(self) -> None:
        output = _run(
            "src/pkg/dyn.py", "__all__ = ['one'] + ['two']\ndef one():\n    pass\n"
        )
        assert _symbols(output) == {"pkg.dyn.one": ("function", "naming", (2, 2))}
        assert _codes(output) == ["PUBLIC_API_DYNAMIC_ALL"]


NAMING = (
    "import os\nfrom pkg import util\n"
    "if os.name == 'nt':\n    platform_value = 1\nelse:\n    platform_value = 2\n"
    "try:\n    optional = 1\nexcept Exception:\n    optional = None\nfinally:\n"
    "    cleanup = True\n"
    "a = b = 3\ntyped: int\n(x, y) = (1, 2)\nm, n = 1, 2\nobj.attr = 1\n"
    "k = obj.attr = 2\n"
    "q, = r = s = 1\nself.t: int = 1\n"
    "@decorator\ndef decorated():\n    pass\n"
    "class Klass:\n    member = 1\n"
    "def _hidden():\n    pass\n"
    "App = 1\napp = 2\nApp = 3\n"
    f"def {CAFE}():\n    pass\n"
    "for i in range(2):\n    looped = 1\n"
    "with ctx:\n    managed = 1\n"
)


class TestNamingRule:
    def test_top_level_bindings_and_diagnostics(self) -> None:
        output = _run("src/pkg/naming.py", NAMING)
        symbols = _symbols(output)
        assert sorted(symbols) == sorted(
            "pkg.naming." + name
            for name in [
                "platform_value",
                "optional",
                "cleanup",
                "a",
                "b",
                "typed",
                "k",
                "r",
                "s",
                "decorated",
                "Klass",
                "App",
                "app",
                CAFE,
            ]
        )
        assert symbols["pkg.naming.decorated"] == ("function", "naming", (21, 22))
        assert symbols["pkg.naming.platform_value"][2] == (4, 4)
        assert _codes(output) == sorted(
            ["PUBLIC_API_CONDITIONAL_DEFINITION"] * 2
            + ["PUBLIC_API_UNPACKING_TARGET"] * 3
        )


class TestModuleRules:
    def test_private_outside_and_invalid_modules(self) -> None:
        files = [
            _file("src/pkg/_private.py", "x = 1\n"),
            _file("src/_pkg/mod.py", "x = 1\n"),
            _file("other/mod.py", "x = 1\n"),
            _file("src/pkg/bad-name.py", "x = 1\n"),
            _file("src/pkg/__init__.py", "x = 1\n"),
        ]
        output = analyze_public_api(files, ROOTS)
        assert _symbols(output) == {"pkg.x": ("variable", "naming", (1, 1))}
        assert (
            output.diagnostics["src/pkg/bad-name.py"][0].code
            == "PUBLIC_API_MODULE_NOT_IMPORTABLE"
        )
