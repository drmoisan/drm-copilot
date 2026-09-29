"""Static and behavioral parity tests for the Python and TypeScript Claude push-down.

Purpose:
    Pin the payload contract that the two push-down implementations express in
    two places (issue #507). The TypeScript declarations are read as text with
    comments stripped; the Python declarations are read with ``ast``. Root
    folders are compared in order, and the merged-path and derived-path
    registries are compared as sets. A shared committed fixture pins the
    routing-merge output byte-for-byte on both sides.

    The module imports none of the new production modules at top level so it
    collects before they exist; the behavioral case imports them inside the
    test body.
"""

from __future__ import annotations

import ast
import importlib
import json
import re
from pathlib import Path
from typing import TYPE_CHECKING, Any, cast

import pytest

from tests.scripts.dev_tools.push_down_customizations_test_support import (
    MemoryFile,
    RecordingFileSystem,
)

if TYPE_CHECKING:
    from collections.abc import Mapping

REPO_ROOT = Path(__file__).resolve().parents[3]
TS_CUSTOMIZATIONS = "extensions/drm-copilot/src/lib/push-down/claude-customizations.ts"
TS_DERIVE_CORE = (
    "extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts"
)
PY_CUSTOMIZATIONS = "scripts/dev_tools/push_down_claude_customizations.py"
PY_DESTINATION_WRITES = "scripts/dev_tools/push_down_claude_destination_writes.py"
PY_DERIVE_CORE = "scripts/dev_tools/push_down_claude_blast_radius_derive_core.py"
FIXTURE_PATH = Path("tests/fixtures/push_down/routing-merge-parity.json")

# Matches the TypeScript merged-path declaration names other than the registry.
_MERGE_NAME = re.compile(r"^[A-Z_]*MERGE[A-Z_]*_RELATIVE_PATHS?$")
_EXPORT_CONST = re.compile(r"export\s+const\s+([A-Za-z_][A-Za-z0-9_]*)\b")
_STRING_LITERAL = re.compile(r"^(?:\"([^\"\\]*)\"|'([^'\\]*)')$")
_OBJECT_KEY = re.compile(r"(?:\"([^\"\\]*)\"|'([^'\\]*)')\s*:")
_MAP_ENTRY_KEY = re.compile(r"\[\s*(?:\"([^\"\\]*)\"|'([^'\\]*)')\s*,")
_ANY_STRING = re.compile(r"\"([^\"\\]*)\"|'([^'\\]*)'")


def _read_repo_text(relative_path: str) -> str:
    """Return the committed text of a repository file."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def _strip_ts_comments(text: str) -> str:
    """Remove ``/* ... */`` and ``//`` comments while preserving string literals."""

    output: list[str] = []
    index = 0
    length = len(text)
    while index < length:
        char = text[index]
        pair = text[index : index + 2]
        if char in "\"'`":
            # Copy a string literal verbatim so "//" inside it is not a comment.
            end = index + 1
            while end < length and text[end] != char:
                end += 2 if text[end] == "\\" else 1
            output.append(text[index : end + 1])
            index = end + 1
        elif pair == "/*":
            close = text.find("*/", index + 2)
            index = length if close == -1 else close + 2
        elif pair == "//":
            newline = text.find("\n", index)
            index = length if newline == -1 else newline
        else:
            output.append(char)
            index += 1
    return "".join(output)


def _literal_value(token: str, label: str, name: str) -> str:
    """Return the value of one string-literal token or fail naming the file."""

    match = _STRING_LITERAL.match(token.strip())
    if match is None:
        raise AssertionError(f"{label}: {name} has a non-literal element {token!r}")
    return match.group(1) if match.group(1) is not None else match.group(2)


def _initializer(text: str, start: int) -> str:
    """Return the initializer text that follows the declaration at ``start``."""

    index = start
    # Skip the type annotation; "=>" inside a function type is not assignment.
    while index < len(text):
        if text[index] == "=" and text[index + 1 : index + 2] != ">":
            break
        index += 1
    end = text.find(";", index)
    return text[index + 1 : len(text) if end == -1 else end].strip()


def _ts_declarations(text: str) -> dict[str, str]:
    """Return every ``export const`` name mapped to its initializer text."""

    stripped = _strip_ts_comments(text)
    return {
        match.group(1): _initializer(stripped, match.end())
        for match in _EXPORT_CONST.finditer(stripped)
    }


def _ts_root_folders(text: str, label: str) -> tuple[str, ...]:
    """Extract the ordered TypeScript ``ROOT_FOLDERS`` literals."""

    initializer = _ts_declarations(text).get("ROOT_FOLDERS")
    if initializer is None:
        raise AssertionError(f"{label}: found zero ROOT_FOLDERS declarations")
    if not (initializer.startswith("[") and initializer.endswith("]")):
        raise AssertionError(f"{label}: ROOT_FOLDERS is not a bracketed literal")
    tokens = [token for token in initializer[1:-1].split(",") if token.strip()]
    return tuple(_literal_value(token, label, "ROOT_FOLDERS") for token in tokens)


def _registry_keys(initializer: str, label: str) -> set[str]:
    """Extract the string-literal keys or elements of a registry initializer."""

    if initializer.startswith("{"):
        pattern = _OBJECT_KEY
    elif initializer.startswith("new Map"):
        pattern = _MAP_ENTRY_KEY
    elif initializer.startswith("["):
        pattern = _ANY_STRING
    else:
        raise AssertionError(f"{label}: MERGED_RELATIVE_PATHS is not a literal")
    return {a if a is not None else b for a, b in pattern.findall(initializer)}


def _ts_merged_paths(sources: Mapping[str, str]) -> set[str]:
    """Extract the union of TypeScript merged-path declarations."""

    found = False
    paths: set[str] = set()
    for label, text in sources.items():
        for name, initializer in _ts_declarations(text).items():
            if name == "MERGED_RELATIVE_PATHS":
                found = True
                paths |= _registry_keys(initializer, label)
            elif _MERGE_NAME.match(name):
                found = True
                paths.add(_literal_value(initializer, label, name))
    if not found:
        raise AssertionError(
            f"{', '.join(sources)}: found zero merged-path declarations"
        )
    return paths


def _ts_derived_paths(sources: Mapping[str, str]) -> set[str]:
    """Extract the TypeScript ``BLAST_RADIUS_RELATIVE_PATH`` literals."""

    paths: set[str] = set()
    for label, text in sources.items():
        initializer = _ts_declarations(text).get("BLAST_RADIUS_RELATIVE_PATH")
        if initializer is not None:
            paths.add(_literal_value(initializer, label, "BLAST_RADIUS_RELATIVE_PATH"))
    if not paths:
        raise AssertionError(
            f"{', '.join(sources)}: found zero BLAST_RADIUS_RELATIVE_PATH declarations"
        )
    return paths


def _py_assignment(source: str, label: str, name: str) -> ast.expr:
    """Return the value of the module-level assignment to ``name``."""

    for node in ast.parse(source).body:
        if isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name):
            if node.target.id == name and node.value is not None:
                return node.value
        if isinstance(node, ast.Assign):
            for target in node.targets:
                if isinstance(target, ast.Name) and target.id == name:
                    return node.value
    raise AssertionError(f"{label}: found zero {name} declarations")


def _py_string(node: ast.expr, label: str, name: str) -> str:
    """Return a string constant or fail naming the file."""

    if isinstance(node, ast.Constant) and isinstance(node.value, str):
        return node.value
    raise AssertionError(f"{label}: {name} has a non-literal element")


def _py_root_folders(source: str, label: str) -> tuple[str, ...]:
    """Extract the ordered Python ``ROOT_FOLDERS`` ``Path`` literals."""

    value = _py_assignment(source, label, "ROOT_FOLDERS")
    if not isinstance(value, ast.Tuple):
        raise AssertionError(f"{label}: ROOT_FOLDERS is not a tuple literal")
    folders: list[str] = []
    for element in value.elts:
        if not (
            isinstance(element, ast.Call)
            and isinstance(element.func, ast.Name)
            and element.func.id == "Path"
            and len(element.args) == 1
        ):
            raise AssertionError(f"{label}: ROOT_FOLDERS has a non-literal element")
        folders.append(_py_string(element.args[0], label, "ROOT_FOLDERS"))
    return tuple(folders)


def _py_merged_paths(source: str, label: str) -> set[str]:
    """Extract the Python ``MERGED_RELATIVE_PATHS`` dict-literal keys."""

    value = _py_assignment(source, label, "MERGED_RELATIVE_PATHS")
    if not isinstance(value, ast.Dict):
        raise AssertionError(f"{label}: MERGED_RELATIVE_PATHS is not a dict literal")
    keys: set[str] = set()
    for key in value.keys:
        if key is None:
            raise AssertionError(
                f"{label}: MERGED_RELATIVE_PATHS has a non-literal key"
            )
        keys.add(_py_string(key, label, "MERGED_RELATIVE_PATHS"))
    return keys


def _py_derived_paths(source: str, label: str) -> set[str]:
    """Extract the Python ``BLAST_RADIUS_RELATIVE_PATH`` constant."""

    value = _py_assignment(source, label, "BLAST_RADIUS_RELATIVE_PATH")
    return {_py_string(value, label, "BLAST_RADIUS_RELATIVE_PATH")}


def _assert_same(
    expected: object, actual: object, ts_label: str, py_label: str
) -> None:
    """Fail with a message naming both source files when the values differ."""

    if expected != actual:
        raise AssertionError(
            f"Python/TypeScript push-down divergence: {ts_label} declares "
            f"{expected!r} but {py_label} declares {actual!r}"
        )


def test_root_folders_match_typescript_in_order() -> None:
    """Python ROOT_FOLDERS equals TypeScript ROOT_FOLDERS in the same order."""

    ts_folders = _ts_root_folders(_read_repo_text(TS_CUSTOMIZATIONS), TS_CUSTOMIZATIONS)
    py_folders = _py_root_folders(_read_repo_text(PY_CUSTOMIZATIONS), PY_CUSTOMIZATIONS)

    _assert_same(ts_folders, py_folders, TS_CUSTOMIZATIONS, PY_CUSTOMIZATIONS)


def test_merged_relative_paths_match_typescript() -> None:
    """Python MERGED_RELATIVE_PATHS keys equal the TypeScript merged paths."""

    ts_sources = {
        TS_CUSTOMIZATIONS: _read_repo_text(TS_CUSTOMIZATIONS),
        TS_DERIVE_CORE: _read_repo_text(TS_DERIVE_CORE),
    }
    ts_paths = _ts_merged_paths(ts_sources)
    py_paths = _py_merged_paths(
        _read_repo_text(PY_DESTINATION_WRITES), PY_DESTINATION_WRITES
    )

    _assert_same(ts_paths, py_paths, TS_CUSTOMIZATIONS, PY_DESTINATION_WRITES)
    assert len(ts_paths) == 1, f"{TS_CUSTOMIZATIONS} merged paths: {ts_paths!r}"
    assert len(py_paths) == 1, f"{PY_DESTINATION_WRITES} merged paths: {py_paths!r}"


def test_derived_relative_paths_match_typescript() -> None:
    """Python BLAST_RADIUS_RELATIVE_PATH equals the TypeScript derived path."""

    ts_sources = {
        TS_CUSTOMIZATIONS: _read_repo_text(TS_CUSTOMIZATIONS),
        TS_DERIVE_CORE: _read_repo_text(TS_DERIVE_CORE),
    }
    ts_paths = _ts_derived_paths(ts_sources)
    py_paths = _py_derived_paths(_read_repo_text(PY_DERIVE_CORE), PY_DERIVE_CORE)

    _assert_same(ts_paths, py_paths, TS_DERIVE_CORE, PY_DERIVE_CORE)
    assert len(ts_paths) == 1, f"{TS_DERIVE_CORE} derived paths: {ts_paths!r}"
    assert len(py_paths) == 1, f"{PY_DERIVE_CORE} derived paths: {py_paths!r}"


def test_typescript_root_folder_extraction_detects_divergence() -> None:
    """A TypeScript declaration lacking config fails the ordered comparison."""

    ts_text = 'export const ROOT_FOLDERS: ReadonlyArray<string> = [".claude"];\n'
    py_text = 'ROOT_FOLDERS = (Path(".claude"), Path("config"))\n'

    ts_folders = _ts_root_folders(ts_text, "synthetic.ts")
    py_folders = _py_root_folders(py_text, "synthetic.py")

    assert ts_folders == (".claude",)
    with pytest.raises(AssertionError, match=r"synthetic\.ts.*synthetic\.py"):
        _assert_same(ts_folders, py_folders, "synthetic.ts", "synthetic.py")


def test_python_root_folder_extraction_detects_divergence() -> None:
    """A Python declaration in a different order fails the ordered comparison."""

    ts_text = 'export const ROOT_FOLDERS = [".claude", "config"];\n'
    py_text = 'ROOT_FOLDERS: tuple[Path, ...] = (Path("config"), Path(".claude"))\n'

    ts_folders = _ts_root_folders(ts_text, "synthetic.ts")
    py_folders = _py_root_folders(py_text, "synthetic.py")

    assert py_folders == ("config", ".claude")
    with pytest.raises(AssertionError, match=r"synthetic\.ts.*synthetic\.py"):
        _assert_same(ts_folders, py_folders, "synthetic.ts", "synthetic.py")


def test_set_comparison_fails_on_divergent_merged_paths() -> None:
    """A Python registry with an extra key fails the merged-path set comparison."""

    ts_text = (
        "export const ROUTING_MERGE_RELATIVE_PATH = "
        '"config/orchestration-routing.json";\n'
    )
    py_text = (
        "MERGED_RELATIVE_PATHS = {\n"
        '    "config/orchestration-routing.json": merge_routing_documents,\n'
        '    "config/blast-radius.json": merge_blast_radius_documents,\n'
        "}\n"
    )

    ts_paths = _ts_merged_paths({"synthetic.ts": ts_text})
    py_paths = _py_merged_paths(py_text, "synthetic.py")

    assert ts_paths == {"config/orchestration-routing.json"}
    with pytest.raises(AssertionError, match=r"synthetic\.ts.*synthetic\.py"):
        _assert_same(ts_paths, py_paths, "synthetic.ts", "synthetic.py")


def test_typescript_extraction_rejects_zero_declarations() -> None:
    """Every TypeScript extraction fails when it finds zero declarations."""

    ts_text = 'export const ARTIFACT_DIRECTORY = "artifacts/claude-customizations";\n'

    with pytest.raises(AssertionError, match="empty.ts: found zero ROOT_FOLDERS"):
        _ts_root_folders(ts_text, "empty.ts")
    with pytest.raises(AssertionError, match="empty.ts: found zero merged-path"):
        _ts_merged_paths({"empty.ts": ts_text})
    with pytest.raises(AssertionError, match="empty.ts: found zero BLAST_RADIUS"):
        _ts_derived_paths({"empty.ts": ts_text})
    with pytest.raises(AssertionError, match="non-literal element"):
        _ts_root_folders("export const ROOT_FOLDERS = [NAME];\n", "bad.ts")


def test_python_extraction_rejects_zero_declarations() -> None:
    """Every Python extraction fails when it finds zero declarations."""

    py_text = 'ARTIFACT_DIRECTORY = "artifacts/claude-customizations"\n'

    with pytest.raises(AssertionError, match="empty.py: found zero ROOT_FOLDERS"):
        _py_root_folders(py_text, "empty.py")
    with pytest.raises(AssertionError, match="empty.py: found zero MERGED_RELATIVE"):
        _py_merged_paths(py_text, "empty.py")
    with pytest.raises(AssertionError, match="empty.py: found zero BLAST_RADIUS"):
        _py_derived_paths(py_text, "empty.py")
    with pytest.raises(AssertionError, match="non-literal element"):
        _py_root_folders("ROOT_FOLDERS = (Path(NAME),)\n", "bad.py")


def test_typescript_comment_stripping_ignores_commented_declarations() -> None:
    """Commented-out declarations are ignored and string literals survive."""

    commented_only = (
        '// export const ROOT_FOLDERS = [".claude", "config"];\n'
        '/* export const ROOT_FOLDERS = [".claude"]; */\n'
    )
    mixed = (
        '/**\n * export const ROOT_FOLDERS = ["stale"];\n */\n'
        'export const ROOT_FOLDERS = [".claude", "config"]; // trailing\n'
        'const URL = "https://example.invalid/path";\n'
    )

    with pytest.raises(AssertionError, match="found zero ROOT_FOLDERS"):
        _ts_root_folders(commented_only, "commented.ts")
    assert _ts_root_folders(mixed, "mixed.ts") == (".claude", "config")
    assert "https://example.invalid/path" in _strip_ts_comments(mixed)


def test_routing_merge_fixture_parity() -> None:
    """The Python routing merge reproduces every shared fixture case byte-for-byte."""

    # The fixture is heterogeneous JSON (string or null fields per case), so it
    # is typed as a loose mapping at this single test-local boundary.
    fixture = cast(
        "dict[str, Any]",
        json.loads((REPO_ROOT / FIXTURE_PATH).read_text(encoding="utf-8")),
    )
    merge_module = importlib.import_module(
        "scripts.dev_tools.push_down_claude_routing_merge"
    )
    writes_module = importlib.import_module(
        "scripts.dev_tools.push_down_claude_destination_writes"
    )
    fixture_path = Path(fixture["path"])
    destination_root = fixture_path.parent.parent

    for case in fixture["cases"]:
        if case["destination"] is None:
            inner = RecordingFileSystem()
            merging = writes_module.DestinationMergeFileSystem(
                inner, destination_root=destination_root
            )
            merging.write_text(fixture_path, case["source"])
            assert inner.files[fixture_path] == MemoryFile(case["expected"]), case[
                "name"
            ]
        elif "expected" in case:
            merged = merge_module.merge_routing_documents(
                case["destination"], case["source"], fixture_path
            )
            assert merged == case["expected"], case["name"]
        else:
            with pytest.raises(merge_module.RoutingMergeError) as caught:
                merge_module.merge_routing_documents(
                    case["destination"], case["source"], fixture_path
                )
            assert str(caught.value).startswith(case["expectedErrorPrefix"]), case[
                "name"
            ]
            assert caught.value.path == fixture_path, case["name"]
