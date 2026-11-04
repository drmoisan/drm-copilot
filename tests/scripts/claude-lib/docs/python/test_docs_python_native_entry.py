"""Tests for run_docs_python_native: the interpreter floor, path and delegation."""

import ast
import io
import json
from pathlib import Path

import run_docs_python_native
from run_docs_python_native import FLOOR_ERROR, ensure_package_path, entry

REQUEST = {
    "protocol_version": 1,
    "analyzers": ["python-architecture"],
    "source_roots": ["."],
    "console_scripts": [],
    "files": [{"path": "m.py", "text": "x = 1\n"}],
    "limits": {"max_files": 50000, "max_file_bytes": 1048576},
}


class TestEntry:
    def test_interpreter_below_floor_writes_one_error_object_and_exits_4(self) -> None:
        stdout = io.BytesIO()
        code = entry(io.BytesIO(b""), stdout, version_info=(3, 10, 14))
        assert code == 4
        assert stdout.getvalue() == FLOOR_ERROR
        assert json.loads(stdout.getvalue())["error"]["code"] == "version-below-floor"

    def test_supported_interpreter_delegates_to_the_protocol(self) -> None:
        stdout = io.BytesIO()
        code = entry(
            io.BytesIO(json.dumps(REQUEST).encode()), stdout, version_info=(3, 11, 0)
        )
        assert code == 0
        assert json.loads(stdout.getvalue())["files"][0]["status"] == "ok"


class TestPackagePath:
    def test_inserts_the_directory_at_the_front_when_absent(self) -> None:
        path_list = ["a", "b"]
        ensure_package_path(path_list, "dir")
        assert path_list == ["dir", "a", "b"]

    def test_leaves_the_list_unchanged_when_present(self) -> None:
        path_list = ["a", "dir"]
        ensure_package_path(path_list, "dir")
        assert path_list == ["a", "dir"]


class TestOldInterpreterSyntax:
    def test_entry_script_parses_with_python_3_6_grammar(self) -> None:
        text = Path(run_docs_python_native.__file__).read_text(encoding="utf-8")
        tree = ast.parse(text, feature_version=(3, 6))
        assert any(
            isinstance(node, ast.FunctionDef) and node.name == "entry"
            for node in tree.body
        )
