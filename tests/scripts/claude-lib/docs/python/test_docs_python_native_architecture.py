"""Tests for docs_python_native.architecture: components, edges, diagnostics."""

from docs_python_native.architecture import analyze_architecture, known_prefix
from docs_python_native.facts import AnalyzerOutput
from docs_python_native.imports import AnalyzedFile, build_tables
from docs_python_native.source import parse_module

ROOTS = ["src"]


def _file(path: str, text: str) -> AnalyzedFile:
    parsed = parse_module(text)
    return AnalyzedFile(path, parsed, build_tables(parsed))


def _components(output: AnalyzerOutput) -> dict[str, dict[str, object]]:
    return {
        f.declaration: {
            "name": f.name,
            "range": (f.line_start, f.line_end),
            **dict(f.properties),
        }
        for facts in output.facts.values()
        for f in facts
    }


def _codes(output: AnalyzerOutput) -> list[tuple[str, str]]:
    return sorted((path, d.code) for path, ds in output.diagnostics.items() for d in ds)


ARCH = (
    "import pkg.util\n"
    "import importlib\n"
    "from . import config\n"
    "from .util import helper as h\n"
    "from ..outside import thing\n"
    "from pkg import *\n"
    "from typing import TYPE_CHECKING\n"
    "if TYPE_CHECKING:\n    from pkg.naming import Klass\n"
    "def load(name):\n"
    "    import json\n"
    "    from pkg import util\n"
    "    from pkg.arch import load as again\n"
    "    return (\n"
    "        importlib.import_module(name),\n"
    "        __import__('os'),\n"
    "        importlib.util.spec_from_file_location('m', 'p'),\n"
    "    )\n"
)


class TestComponents:
    def test_edges_and_diagnostics(self) -> None:
        files = [
            _file("src/pkg/__init__.py", "from . import util\n"),
            _file("src/pkg/util.py", "x = 1\n"),
            _file("src/pkg/config.py", "x = 1\n"),
            _file("src/pkg/naming.py", "x = 1\n"),
            _file("src/pkg/arch.py", ARCH),
            _file("src/top.py", "from . import sibling\nimport pkg\n"),
            _file("src/pkg/bad-name.py", "x = 1\n"),
            _file("other/x.py", "x = 1\n"),
        ]
        output = analyze_architecture(files, ROOTS)
        components = _components(output)
        assert sorted(components) == [
            "pkg",
            "pkg.arch",
            "pkg.config",
            "pkg.naming",
            "pkg.util",
            "top",
        ]
        arch = components["pkg.arch"]
        assert arch == {
            "name": "arch",
            "range": (None, None),
            "component_kind": "module",
            "import_count": 4,
            "import-0001": "pkg",
            "import-0002": "pkg.config",
            "import-0003": "pkg.naming",
            "import-0004": "pkg.util",
        }
        assert components["pkg"]["component_kind"] == "package"
        assert components["pkg"]["import-0001"] == "pkg.util"
        assert components["top"]["import_count"] == 1
        assert _codes(output) == [
            ("src/pkg/arch.py", "ARCHITECTURE_DYNAMIC_IMPORT"),
            ("src/pkg/arch.py", "ARCHITECTURE_DYNAMIC_IMPORT"),
            ("src/pkg/arch.py", "ARCHITECTURE_DYNAMIC_IMPORT"),
            ("src/pkg/arch.py", "ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED"),
            ("src/pkg/bad-name.py", "ARCHITECTURE_MODULE_NAME_INVALID"),
            ("src/top.py", "ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED"),
        ]

    def test_edge_limit_drops_edge_properties_but_keeps_the_count(self) -> None:
        modules = [_file(f"src/m{i:04d}.py", "x = 1\n") for i in range(1001)]
        hub = "\n".join(f"import m{i:04d}" for i in range(1001)) + "\n"
        output = analyze_architecture([*modules, _file("src/hub.py", hub)], ROOTS)
        hub_component = _components(output)["hub"]
        assert hub_component["import_count"] == 1001
        assert "import-0001" not in hub_component
        assert output.diagnostics["src/hub.py"][0].code == "ARCHITECTURE_EDGE_LIMIT"

    def test_known_prefix_is_the_longest_match(self) -> None:
        known = {"pkg", "pkg.util"}
        assert known_prefix("pkg.util.helper", known) == "pkg.util"
        assert known_prefix("pkg.other", known) == "pkg"
        assert known_prefix("os.path", known) is None
