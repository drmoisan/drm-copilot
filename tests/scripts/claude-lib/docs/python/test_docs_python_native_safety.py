"""Safety tests (S7, S12, S15): the helper never runs, imports or hashes sources."""

import ast
import io
import json
import os
import sys
from pathlib import Path

import docs_python_native
from docs_python_native.protocol import main

PYLIB = Path(docs_python_native.__file__).resolve().parents[1]
FORBIDDEN_CALLS = frozenset({"exec", "eval", "compile", "__import__", "literal_eval"})
FORBIDDEN_MODULES = frozenset({"importlib", "runpy", "subprocess", "hashlib"})
FORBIDDEN_CONSTANTS = frozenset({"element_id", "parent_id", "source_sha256"})


def _helper_trees() -> list[tuple[str, ast.Module]]:
    """Parse every helper file and pin the helper file count."""
    files = sorted(PYLIB.rglob("*.py"))
    assert len(files) == 18
    return [
        (p.relative_to(PYLIB).as_posix(), ast.parse(p.read_text(encoding="utf-8")))
        for p in files
    ]


def _call_name(node: ast.Call) -> str | None:
    """Return the dotted name of a call's callee, or None."""
    if isinstance(node.func, ast.Name):
        return node.func.id
    if isinstance(node.func, ast.Attribute):
        return node.func.attr
    return None


class TestStaticSafety:
    """Scenarios for static safety of every helper file."""

    def test_no_execution_import_or_hashing_primitive(self) -> None:
        """Scenario: no helper file calls or imports an execution or hashing API."""
        # Inspect every helper file.
        for name, tree in _helper_trees():
            # Check every node of the file's syntax tree.
            for node in ast.walk(tree):
                if isinstance(node, ast.Call):
                    assert _call_name(node) not in FORBIDDEN_CALLS, name
                if isinstance(node, ast.Import):
                    assert (
                        not {a.name.split(".")[0] for a in node.names}
                        & FORBIDDEN_MODULES
                    ), name
                if isinstance(node, ast.ImportFrom):
                    assert (node.module or "").split(".")[
                        0
                    ] not in FORBIDDEN_MODULES, name

    def test_ast_parse_is_the_only_parse_call(self) -> None:
        """Scenario: ast.parse in source.py is the only parse call."""
        parse_calls: list[str] = []
        # Inspect every helper file.
        for name, tree in _helper_trees():
            # Check every node of the file's syntax tree.
            for node in ast.walk(tree):
                if isinstance(node, ast.Attribute) and node.attr == "parse":
                    assert (
                        isinstance(node.value, ast.Name) and node.value.id == "ast"
                    ), name
                    parse_calls.append(name)
        assert parse_calls == ["docs_python_native/source.py"]

    def test_no_identity_or_digest_field_name(self) -> None:
        """Scenario: no helper constant names an identity or digest field."""
        # Inspect every helper file.
        for name, tree in _helper_trees():
            # Check every node of the file's syntax tree.
            for node in ast.walk(tree):
                if isinstance(node, ast.Constant) and isinstance(node.value, str):
                    assert node.value not in FORBIDDEN_CONSTANTS, name


class TestBehavioralSafety:
    """Scenarios for behavioral safety of the helper."""

    def test_analyzing_hostile_source_has_no_side_effect(self) -> None:
        """Scenario: analyzing hostile source has no side effect."""
        # Arrange: a module whose execution would exit, set an environment key and
        # replace a module.
        marker = "DOCS_NATIVE_SAFETY_MARKER"
        source = (
            "import os, sys\n"
            f"os.environ['{marker}'] = '1'\n"
            "sys.modules['json'] = None\n"
            "raise SystemExit(3)\n"
        )
        request = {
            "protocol_version": 1,
            "analyzers": [
                "python-architecture",
                "python-cli",
                "python-http",
                "python-public-api",
            ],
            "source_roots": ["."],
            "console_scripts": [],
            "files": [{"path": "hostile.py", "text": source}],
            "limits": {"max_files": 50000, "max_file_bytes": 1048576},
        }
        modules_before = dict(sys.modules)
        stdout = io.BytesIO()
        # Act
        code = main(io.BytesIO(json.dumps(request).encode()), stdout)
        # Assert
        assert code == 0
        assert json.loads(stdout.getvalue())["files"][0]["status"] == "ok"
        assert marker not in os.environ
        assert sys.modules["json"] is modules_before["json"]

    def test_bytecode_writing_is_disabled(self) -> None:
        """Scenario: the test process runs with bytecode writing disabled."""
        assert sys.dont_write_bytecode is True
