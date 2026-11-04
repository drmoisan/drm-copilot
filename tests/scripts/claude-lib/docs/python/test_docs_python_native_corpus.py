"""Cross-language corpus test (S1, S2): the helper against the 1022 and 1031 corpora.

The request is built from the 1022 corpus .py inputs, the 1031 native inputs and console
scripts, and both corpora's source roots. Facts must equal the 1022 expected elements of
.py paths plus the 1031 native-only rows for every file that parses on the running
interpreter; each retained 1022 diagnostic must be reported, and no resolved or
scanner-only one may be.
"""

import ast
import io
import json
import warnings
from functools import cache
from pathlib import Path
from typing import Any

import pytest
from docs_python_native.protocol import main

FIXTURES = Path(__file__).resolve().parents[1] / "fixtures"
ANALYZERS = ["python-architecture", "python-cli", "python-http", "python-public-api"]
BOM = chr(0xFEFF)
ElementKey = tuple[str, str, str, str, int | None, int | None, str, str | None, str]


def _load(name: str) -> Any:
    return json.loads((FIXTURES / name).read_text(encoding="utf-8"))


@cache
def _fixtures() -> tuple[Any, Any]:
    return _load("python-surface-corpus.json"), _load("python-native-corpus.json")


def _inputs() -> dict[str, str]:
    surface, native = _fixtures()
    inputs = {
        path: text for path, text in surface["inputs"].items() if path.endswith(".py")
    }
    inputs.update(native["native_inputs"])
    return inputs


@cache
def _response() -> Any:
    surface, native = _fixtures()
    request = {
        "protocol_version": 1,
        "analyzers": ANALYZERS,
        "source_roots": surface["source_roots"] + native["native_source_roots"],
        "console_scripts": native["console_scripts"],
        "files": [
            {"path": p, "text": t.removeprefix(BOM)}
            for p, t in sorted(_inputs().items())
        ],
        "limits": {"max_files": 50000, "max_file_bytes": 1048576},
    }
    stdout = io.BytesIO()
    assert main(io.BytesIO(json.dumps(request).encode("utf-8")), stdout) == 0
    return json.loads(stdout.getvalue())


def _parses(text: str) -> bool:
    normalized = text.removeprefix(BOM).replace("\r\n", "\n").replace("\r", "\n")
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        try:
            ast.parse(normalized)
        except (SyntaxError, ValueError, RecursionError, MemoryError):
            return False
    return True


def _key(
    row: Any, path: str, parent: str | None, start: int | None, end: int | None
) -> ElementKey:
    properties = json.dumps(row["properties"], sort_keys=True)
    return (
        row["analyzer_id"],
        row["kind"],
        path,
        row["declaration"],
        start,
        end,
        row["name"],
        parent,
        properties,
    )


def _expected(analyzer: str) -> set[ElementKey]:
    surface, native = _fixtures()
    parsing = {path for path, text in _inputs().items() if _parses(text)}
    expected: set[ElementKey] = set()
    for row in [*surface["expected_elements"], *native["native_only_elements"]]:
        if row["analyzer_id"] != analyzer or row["path"] not in parsing:
            continue
        line_range = row["line_range"]
        start = None if line_range is None else line_range["start"]
        end = None if line_range is None else line_range["end"]
        properties = {p["name"]: p["value"] for p in row["properties"]}
        expected.add(
            _key(
                {**row, "properties": properties},
                row["path"],
                row["parent_declaration"],
                start,
                end,
            )
        )
    return expected


def _emitted(analyzer: str) -> set[ElementKey]:
    emitted: set[ElementKey] = set()
    for entry in _response()["files"]:
        for fact in entry["facts"]:
            if fact["analyzer_id"] != analyzer:
                continue
            parent = None if fact["parent"] is None else fact["parent"]["declaration"]
            emitted.add(
                _key(fact, entry["path"], parent, fact["line_start"], fact["line_end"])
            )
    return emitted


@pytest.mark.parametrize("analyzer", ANALYZERS)
def test_corpus_parity_per_identifier(analyzer: str) -> None:
    # Arrange
    _surface, native = _fixtures()
    statuses = {entry["path"]: entry["status"] for entry in _response()["files"]}
    reported = {
        (d["analyzer_id"], d["code"], entry["path"])
        for entry in _response()["files"]
        for d in entry["diagnostics"]
    }
    # Act / Assert S1: emitted facts equal the expected elements of every parsing file.
    assert _emitted(analyzer) == _expected(analyzer)
    for path, text in _inputs().items():
        assert statuses[path] == ("ok" if _parses(text) else "parse-error"), path
    # Assert S2: retained diagnostics are reported; resolved and scanner-only ones are
    # not.
    for row in native["diagnostic_classes"]:
        if row["analyzer_id"] != analyzer or statuses.get(row["path"]) == "parse-error":
            continue
        key = (row["analyzer_id"], row["code"], row["path"])
        assert (key in reported) == (row["class"] == "retained"), key
