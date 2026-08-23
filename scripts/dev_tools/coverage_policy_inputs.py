"""Pure parsers for coverage policy analysis."""

from __future__ import annotations

import ast
import json
import re
from dataclasses import dataclass
from typing import cast

import tomllib


@dataclass(frozen=True)
class FileCoverage:
    """Store executable/covered lines and branch counts for one source file."""

    executable: frozenset[int]
    covered: frozenset[int]
    branch_covered: int
    branch_total: int


@dataclass(frozen=True)
class CoverageSnapshot:
    """Store normalized per-file and repository aggregate coverage."""

    files: dict[str, FileCoverage]
    line_covered: int
    line_total: int
    branch_covered: int
    branch_total: int


@dataclass(frozen=True)
class SymbolRange:
    """Identify a new module, class, function, or method source range."""

    kind: str
    name: str
    start: int
    end: int


ThresholdMap = dict[str, dict[str, float]]


def object_mapping(value: object, label: str) -> dict[str, object]:
    """Validate and type-narrow a JSON-like object mapping."""

    if not isinstance(value, dict):
        raise ValueError(f"{label} must be an object")
    raw_mapping = cast("dict[object, object]", value)
    if not all(isinstance(key, str) for key in raw_mapping):
        raise ValueError(f"{label} must be an object")
    return cast("dict[str, object]", raw_mapping)


def object_items(value: object, label: str) -> list[object]:
    """Validate and type-narrow a JSON-like array."""

    if not isinstance(value, list):
        raise ValueError(f"{label} must be an array")
    return cast("list[object]", value)


def number(value: object, label: str) -> float:
    """Validate and return a JSON numeric value."""

    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise ValueError(f"{label} must be numeric")
    return float(value)


def _integer(value: object, label: str) -> int:
    parsed = number(value, label)
    if parsed < 0 or not parsed.is_integer():
        raise ValueError(f"{label} must be a non-negative integer")
    return int(parsed)


def normalize_path(path: str, *, prefix: str = "") -> str:
    """Return a stable forward-slash path, optionally rooted below a prefix."""

    normalized = path.replace("\\", "/").removeprefix("./")
    if re.match(r"^[A-Za-z]:/", normalized):
        indexes = [
            normalized.find(marker)
            for marker in ("extensions/", "scripts/", "src/", "packages/", "config/")
        ]
        valid_indexes = [index for index in indexes if index >= 0]
        if valid_indexes:
            normalized = normalized[min(valid_indexes) :]
    clean_prefix = prefix.strip("/")
    if clean_prefix and not normalized.startswith(f"{clean_prefix}/"):
        normalized = f"{clean_prefix}/{normalized}"
    return normalized


def parse_coverage_py_json(text: str) -> CoverageSnapshot:
    """Parse coverage.py JSON without reading a file."""

    root = object_mapping(json.loads(text), "coverage.py root")
    raw_files = object_mapping(root.get("files"), "coverage.py files")
    files: dict[str, FileCoverage] = {}
    for raw_path, raw_entry in raw_files.items():
        entry = object_mapping(raw_entry, raw_path)
        executed = frozenset(
            _integer(item, "executed line")
            for item in object_items(entry.get("executed_lines", []), "executed_lines")
        )
        missing = frozenset(
            _integer(item, "missing line")
            for item in object_items(entry.get("missing_lines", []), "missing_lines")
        )
        summary = object_mapping(entry.get("summary", {}), "file summary")
        files[normalize_path(raw_path)] = FileCoverage(
            executed | missing,
            executed,
            _integer(summary.get("covered_branches", 0), "covered_branches"),
            _integer(summary.get("num_branches", 0), "num_branches"),
        )
    totals = object_mapping(root.get("totals", {}), "coverage.py totals")
    return CoverageSnapshot(
        files,
        _integer(
            totals.get(
                "covered_lines",
                sum(len(coverage.covered) for coverage in files.values()),
            ),
            "covered lines",
        ),
        _integer(
            totals.get(
                "num_statements",
                sum(len(coverage.executable) for coverage in files.values()),
            ),
            "statements",
        ),
        _integer(
            totals.get(
                "covered_branches",
                sum(coverage.branch_covered for coverage in files.values()),
            ),
            "covered branches",
        ),
        _integer(
            totals.get(
                "num_branches",
                sum(coverage.branch_total for coverage in files.values()),
            ),
            "branches",
        ),
    )


def _parse_lcov(text: str, prefix: str) -> dict[str, FileCoverage]:
    files: dict[str, FileCoverage] = {}
    path: str | None = None
    executable: set[int] = set()
    covered: set[int] = set()
    branch_covered = branch_total = 0

    def finish() -> None:
        nonlocal executable, covered, branch_covered, branch_total
        if path is not None:
            files[path] = FileCoverage(
                frozenset(executable),
                frozenset(covered),
                branch_covered,
                branch_total,
            )
        executable, covered = set[int](), set[int]()
        branch_covered = branch_total = 0

    for line in text.splitlines():
        if line.startswith("SF:"):
            finish()
            path = normalize_path(line[3:].strip(), prefix=prefix)
        elif line.startswith("DA:"):
            line_text, count_text, *_ = line[3:].split(",")
            line_number = int(line_text)
            executable.add(line_number)
            if int(count_text) > 0:
                covered.add(line_number)
        elif line.startswith("BRDA:"):
            branch_total += 1
            branch_covered += line[5:].rsplit(",", 1)[-1] not in {"-", "0"}
        elif line == "end_of_record":
            finish()
            path = None
    finish()
    return files


def parse_jest_coverage(
    final_text: str,
    summary_text: str,
    lcov_text: str,
    *,
    prefix: str = "extensions/drm-copilot",
) -> CoverageSnapshot:
    """Parse Jest coverage-final, coverage-summary, and LCOV text together."""

    final = object_mapping(json.loads(final_text), "Jest coverage-final")
    files = _parse_lcov(lcov_text, prefix)
    for raw_path, raw_entry in final.items():
        path = normalize_path(raw_path, prefix=prefix)
        if path in files:
            continue
        entry = object_mapping(raw_entry, raw_path)
        locations = object_mapping(entry.get("statementMap", {}), "statementMap")
        counts = object_mapping(entry.get("s", {}), "statement counts")
        executable: set[int] = set()
        covered: set[int] = set()
        for statement_id, raw_location in locations.items():
            location = object_mapping(raw_location, "statement location")
            start = object_mapping(location.get("start"), "statement start")
            line = _integer(start.get("line"), "statement line")
            executable.add(line)
            if _integer(counts.get(statement_id, 0), "statement count") > 0:
                covered.add(line)
        files[path] = FileCoverage(frozenset(executable), frozenset(covered), 0, 0)
    total = object_mapping(
        object_mapping(json.loads(summary_text), "Jest coverage-summary").get("total"),
        "Jest total",
    )
    lines = object_mapping(total.get("lines"), "Jest total lines")
    branches = object_mapping(total.get("branches"), "Jest total branches")
    return CoverageSnapshot(
        files,
        _integer(lines.get("covered"), "Jest covered lines"),
        _integer(lines.get("total"), "Jest total lines"),
        _integer(branches.get("covered"), "Jest covered branches"),
        _integer(branches.get("total"), "Jest total branches"),
    )


def parse_python_symbols(source_text: str) -> list[SymbolRange]:
    """Return module, class, function, and method ranges from Python source."""

    tree = ast.parse(source_text)
    symbols = [
        SymbolRange("module", "<module>", 1, max(1, len(source_text.splitlines())))
    ]
    parents: dict[ast.AST, ast.AST] = {}
    for node in ast.walk(tree):
        for child in ast.iter_child_nodes(node):
            parents[child] = node
    supported = (ast.ClassDef, ast.FunctionDef, ast.AsyncFunctionDef)
    for node in sorted(
        (item for item in ast.walk(tree) if isinstance(item, supported)),
        key=lambda item: item.lineno,
    ):
        kind = (
            "class"
            if isinstance(node, ast.ClassDef)
            else "method" if isinstance(parents.get(node), ast.ClassDef) else "function"
        )
        symbols.append(
            SymbolRange(kind, node.name, node.lineno, node.end_lineno or node.lineno)
        )
    return symbols


_TS_DECLARATION = re.compile(
    r"^\s*(?:export\s+)?(?:default\s+)?(?:(?:async|abstract)\s+)?"
    r"(?:(class)\s+([A-Za-z_$][\w$]*)|function\s+([A-Za-z_$][\w$]*))"
)
_TS_METHOD = re.compile(
    r"^\s*(?:(?:public|private|protected|static|async|readonly|override)\s+)*"
    r"([A-Za-z_$][\w$]*)\s*\([^)]*\)\s*(?::[^={]+)?\{"
)
_TS_CONTROL = {"if", "for", "while", "switch", "catch", "constructor"}


def _brace_end(lines: list[str], start: int) -> int:
    depth = 0
    opened = False
    for index in range(start, len(lines)):
        for character in lines[index]:
            if character == "{":
                depth += 1
                opened = True
            elif character == "}" and opened:
                depth -= 1
        if opened and depth <= 0:
            return index + 1
    return len(lines)


def parse_typescript_symbols(source_text: str) -> list[SymbolRange]:
    """Return module, class, function, and class-method TypeScript ranges."""

    lines = source_text.splitlines()
    symbols = [SymbolRange("module", "<module>", 1, max(1, len(lines)))]
    classes: list[tuple[int, int]] = []
    for index, line in enumerate(lines):
        match = _TS_DECLARATION.match(line)
        if not match:
            continue
        kind = "class" if match.group(1) else "function"
        end = _brace_end(lines, index)
        symbols.append(
            SymbolRange(kind, match.group(2) or match.group(3), index + 1, end)
        )
        if kind == "class":
            classes.append((index + 1, end))
    for index, line in enumerate(lines):
        match = _TS_METHOD.match(line)
        line_number = index + 1
        if (
            match
            and match.group(1) not in _TS_CONTROL
            and any(start < line_number <= end for start, end in classes)
        ):
            symbols.append(
                SymbolRange(
                    "method", match.group(1), line_number, _brace_end(lines, index)
                )
            )
    return sorted(symbols, key=lambda item: (item.start, item.kind, item.name))


def parse_unified_diff(text: str) -> tuple[dict[str, set[int]], set[str]]:
    """Extract changed destination lines and new paths from unified diff text."""

    changed: dict[str, set[int]] = {}
    new_files: set[str] = set()
    path: str | None = None
    pending_new = False
    for line in text.splitlines():
        if line.startswith("diff --git "):
            path, pending_new = None, False
        elif line == "new file mode 100644":
            pending_new = True
        elif line.startswith("+++ ") and line[4:] != "/dev/null":
            path = normalize_path(line[4:].removeprefix("b/"))
            changed.setdefault(path, set())
            if pending_new:
                new_files.add(path)
        elif line.startswith("@@ ") and path is not None:
            match = re.search(r"\+(\d+)(?:,(\d+))?", line)
            if match:
                start, count = int(match.group(1)), int(match.group(2) or "1")
                changed[path].update(range(start, start + count))
    return changed, new_files


def parse_python_thresholds(text: str) -> ThresholdMap:
    """Parse optional per-changed-file thresholds from coverage TOML."""

    document = object_mapping(tomllib.loads(text), "coverage config")
    tool = object_mapping(document.get("tool", {}), "tool")
    coverage = object_mapping(tool.get("coverage", {}), "tool.coverage")
    configured = object_mapping(coverage.get("changed_files", {}), "changed_files")
    result: ThresholdMap = {}
    for path, raw_metrics in configured.items():
        metrics = object_mapping(raw_metrics, f"thresholds for {path}")
        result[normalize_path(path)] = {
            name: number(value, f"{path} {name}")
            for name, value in metrics.items()
            if name in {"lines", "branches"}
        }
    return result


def parse_jest_thresholds(
    text: str, *, prefix: str = "extensions/drm-copilot"
) -> ThresholdMap:
    """Parse per-file line and branch thresholds from Jest config source."""

    result: ThresholdMap = {}
    path: str | None = None
    path_pattern = re.compile(r'^\s*["\']([^"\']+)["\']\s*:\s*\{')
    metric_pattern = re.compile(r"^\s*(lines|branches)\s*:\s*(\d+(?:\.\d+)?)")
    for line in text.splitlines():
        path_match = path_pattern.match(line)
        if path_match:
            path = normalize_path(path_match.group(1), prefix=prefix)
            result[path] = {}
        metric_match = metric_pattern.match(line)
        if path is not None and metric_match:
            result[path][metric_match.group(1)] = float(metric_match.group(2))
        if path is not None and line.strip() == "},":
            path = None
    return result
