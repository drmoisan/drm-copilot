"""In-memory coverage policy analyzer tests."""

from __future__ import annotations

import json

import pytest

from scripts.dev_tools.analyze_coverage_policy import (
    analyze_snapshot,
    build_parser,
    compare_analyses,
)
from scripts.dev_tools.coverage_policy_inputs import (
    FileCoverage,
    normalize_path,
    parse_coverage_py_json,
    parse_jest_coverage,
    parse_jest_thresholds,
    parse_python_symbols,
    parse_python_thresholds,
    parse_typescript_symbols,
    parse_unified_diff,
)
from tests.scripts.dev_tools.coverage_policy_test_support import (
    analyze as _analyze,
)
from tests.scripts.dev_tools.coverage_policy_test_support import (
    coverage_py_text as _coverage_py_text,
)
from tests.scripts.dev_tools.coverage_policy_test_support import (
    snapshot as _snapshot,
)


def test_parse_coverage_py_json_reads_lines_and_branches() -> None:
    """Coverage.py JSON supplies exact repository and per-file totals."""

    snapshot = parse_coverage_py_json(_coverage_py_text())

    assert snapshot.line_covered == 85
    assert snapshot.line_total == 100
    assert snapshot.branch_covered == 75
    assert snapshot.branch_total == 100
    assert len(snapshot.files["scripts/dev_tools/example.py"].covered) == 85


def test_parse_jest_coverage_uses_all_three_in_memory_reports() -> None:
    """Jest final JSON, summary JSON, and LCOV form one normalized snapshot."""

    final = json.dumps(
        {
            "src/fallback.ts": {
                "statementMap": {"0": {"start": {"line": 1}}},
                "s": {"0": 1},
            }
        }
    )
    summary = json.dumps(
        {
            "total": {
                "lines": {"covered": 85, "total": 100},
                "branches": {"covered": 75, "total": 100},
            }
        }
    )
    lcov = "\n".join(
        [
            "SF:src/example.ts",
            "DA:1,1",
            "DA:2,0",
            "BRDA:1,0,0,1",
            "BRDA:2,0,0,-",
            "end_of_record",
        ]
    )

    snapshot = parse_jest_coverage(final, summary, lcov)

    assert snapshot.line_covered == 85
    assert snapshot.branch_covered == 75
    assert snapshot.files["extensions/drm-copilot/src/example.ts"] == FileCoverage(
        frozenset({1, 2}), frozenset({1}), 1, 2
    )
    assert "extensions/drm-copilot/src/fallback.ts" in snapshot.files


@pytest.mark.parametrize(
    ("raw_path", "prefix", "expected"),
    [
        (
            "./src/example.ts",
            "extensions/drm-copilot",
            "extensions/drm-copilot/src/example.ts",
        ),
        ("scripts\\dev_tools\\example.py", "", "scripts/dev_tools/example.py"),
    ],
)
def test_normalize_path_is_stable(raw_path: str, prefix: str, expected: str) -> None:
    """Path normalization produces stable workspace-relative identifiers."""

    assert normalize_path(raw_path, prefix=prefix) == expected


def test_symbol_parsers_find_modules_classes_functions_and_methods() -> None:
    """Both source parsers identify the policy-governed symbol kinds."""

    python_symbols = parse_python_symbols(
        "class Worker:\n    def run(self):\n        return 1\n\n"
        "def helper():\n    return 2\n"
    )
    typescript_symbols = parse_typescript_symbols(
        "export class Worker {\n  run(): number {\n    return 1;\n  }\n}\n"
        "export function helper(): number {\n  return 2;\n}\n"
    )

    assert [(item.kind, item.name) for item in python_symbols] == [
        ("module", "<module>"),
        ("class", "Worker"),
        ("method", "run"),
        ("function", "helper"),
    ]
    assert {(item.kind, item.name) for item in typescript_symbols} == {
        ("module", "<module>"),
        ("class", "Worker"),
        ("method", "run"),
        ("function", "helper"),
    }


def test_unified_diff_returns_changed_lines_and_new_files() -> None:
    """Unified hunks expose exact destination lines and new-file identity."""

    diff = "\n".join(
        [
            "diff --git a/scripts/dev_tools/new.py b/scripts/dev_tools/new.py",
            "new file mode 100644",
            "+++ b/scripts/dev_tools/new.py",
            "@@ -0,0 +3,2 @@",
            "+first",
            "+second",
        ]
    )

    changed, new_files = parse_unified_diff(diff)

    assert changed == {"scripts/dev_tools/new.py": {3, 4}}
    assert new_files == {"scripts/dev_tools/new.py"}


def test_threshold_parsers_read_python_toml_and_jest_source() -> None:
    """Configured changed-file thresholds remain language-config driven."""

    python = parse_python_thresholds(
        '[tool.coverage.changed_files."scripts/dev_tools/example.py"]\n'
        "lines = 91\nbranches = 81\n"
    )
    typescript = parse_jest_thresholds(
        'coverageThreshold: {\n  "./src/example.ts": {\n'
        "    lines: 92,\n    branches: 82,\n  },\n},\n"
    )

    assert python == {"scripts/dev_tools/example.py": {"lines": 91.0, "branches": 81.0}}
    assert typescript == {
        "extensions/drm-copilot/src/example.ts": {
            "lines": 92.0,
            "branches": 82.0,
        }
    }


@pytest.mark.parametrize(
    ("line_covered", "branch_covered", "expected"),
    [
        (85, 75, "PASS"),
        (84, 75, "FAIL"),
        (85, 74, "FAIL"),
    ],
)
def test_repository_threshold_boundaries(
    line_covered: int, branch_covered: int, expected: str
) -> None:
    """Repository line 85 and branch 75 boundaries are inclusive."""

    snapshot = _snapshot(
        path="scripts/dev_tools/example.py",
        executable=set(range(1, 101)),
        covered=set(range(1, line_covered + 1)),
        line_covered=line_covered,
        branch_covered=branch_covered,
    )

    result = analyze_snapshot(
        snapshot,
        language="python",
        mode="baseline",
        changed_lines={},
        new_files=set(),
        sources={},
        configured_thresholds={},
        repo_line_min=85,
        repo_branch_min=75,
        new_symbol_min=90,
    )

    assert result["overall_verdict"] == expected


@pytest.mark.parametrize(
    ("language", "path", "source", "expected_kinds"),
    [
        (
            "python",
            "scripts/dev_tools/new_module.py",
            "\n".join(f"value_{index} = {index}" for index in range(1, 11)),
            {"module"},
        ),
        (
            "python",
            "scripts/dev_tools/new_function.py",
            "\n".join(
                [
                    "def calculate():",
                    *[f"    value_{index} = {index}" for index in range(1, 9)],
                    "    return value_8",
                ]
            ),
            {"module", "function"},
        ),
        (
            "python",
            "scripts/dev_tools/new_method.py",
            "\n".join(
                [
                    "class Worker:",
                    "    def run(self):",
                    *[f"        value_{index} = {index}" for index in range(1, 8)],
                    "        value_8 = 8",
                    "        return value_8",
                ]
            ),
            {"module", "class", "method"},
        ),
        (
            "typescript",
            "extensions/drm-copilot/src/new-function.ts",
            "\n".join(
                [
                    "export function calculate(): number {",
                    *[f"  const value{index} = {index};" for index in range(1, 8)],
                    "  return value7;",
                    "}",
                ]
            ),
            {"module", "function"},
        ),
        (
            "typescript",
            "extensions/drm-copilot/src/new-method.ts",
            "\n".join(
                [
                    "export class Worker {",
                    "  run(): number {",
                    *[f"    const value{index} = {index};" for index in range(1, 7)],
                    "    const value7 = 7;",
                    "    return value7;",
                    "  }",
                    "}",
                ]
            ),
            {"module", "class", "method"},
        ),
    ],
)
def test_new_symbols_pass_at_exact_ninety_percent(
    language: str, path: str, source: str, expected_kinds: set[str]
) -> None:
    """Every new module, class, function, and method meets the 90% boundary."""

    executable = set(range(1, len(source.splitlines()) + 1))
    covered = set(sorted(executable)[:-1])
    snapshot = _snapshot(path=path, executable=executable, covered=covered)

    result = _analyze(snapshot, language=language, path=path, source=source)
    symbols = result["new_symbols"]

    assert isinstance(symbols, list)
    assert {item["kind"] for item in symbols} == expected_kinds
    assert all(item["coverage_percent"] >= 90 for item in symbols)
    assert all(item["pass"] is True for item in symbols)


def test_new_symbol_below_ninety_percent_fails() -> None:
    """A new module below 90% makes the analysis fail."""

    path = "scripts/dev_tools/new_module.py"
    source = "\n".join(f"value_{index} = {index}" for index in range(1, 11))
    snapshot = _snapshot(
        path=path,
        executable=set(range(1, 11)),
        covered=set(range(1, 9)),
    )

    result = _analyze(snapshot, language="python", path=path, source=source)

    assert result["overall_verdict"] == "FAIL"
    assert result["verdicts"]["new_symbols"] is False


@pytest.mark.parametrize(
    ("covered_lines", "branch_covered", "expected"),
    [(85, 75, True), (84, 75, False), (85, 74, False)],
)
def test_configured_changed_file_threshold_boundaries(
    covered_lines: int, branch_covered: int, expected: bool
) -> None:
    """Configured per-file line and branch thresholds are both enforced."""

    path = "scripts/dev_tools/example.py"
    source = "\n".join(f"value_{index} = {index}" for index in range(1, 101))
    snapshot = _snapshot(
        path=path,
        executable=set(range(1, 101)),
        covered=set(range(1, covered_lines + 1)),
        line_covered=max(85, covered_lines),
        branch_covered=max(75, branch_covered),
        file_branch_covered=branch_covered,
    )

    result = _analyze(
        snapshot,
        language="python",
        path=path,
        source=source,
        new_file=False,
        thresholds={path: {"lines": 85, "branches": 75}},
    )

    configured = result["configured_changed_files"]
    assert isinstance(configured, list)
    assert configured[0]["pass"] is expected


@pytest.mark.parametrize(
    ("language", "path"),
    [
        ("python", "scripts/dev_tools/example.py"),
        ("typescript", "extensions/drm-copilot/src/example.ts"),
    ],
)
def test_changed_line_coverage_cannot_regress_from_baseline(
    language: str, path: str
) -> None:
    """Python and TypeScript changed-line coverage cannot regress."""

    source = "\n".join(
        (
            f"value_{index} = {index}"
            if language == "python"
            else f"const value_{index} = {index};"
        )
        for index in range(1, 11)
    )
    snapshot = _snapshot(
        path=path,
        executable=set(range(1, 11)),
        covered=set(range(1, 10)),
    )
    baseline: dict[str, object] = {
        "changed_files": [{"path": path, "changed_line_percent": 100.0}]
    }

    result = _analyze(
        snapshot,
        language=language,
        path=path,
        source=source,
        new_file=False,
        baseline=baseline,
    )

    assert result["verdicts"]["changed_line_no_regression"] is False
    assert result["changed_files"][0]["delta"] == -10.0


def test_compare_reports_numeric_python_and_typescript_deltas() -> None:
    """Compare mode retains baseline/post numeric values for both languages."""

    current_language = {
        "repository": {"line_percent": 86.0, "branch_percent": 76.0},
        "new_symbols": [{"coverage_percent": 90.0}],
        "overall_verdict": "PASS",
    }
    current: dict[str, object] = {
        "languages": {
            "python": current_language,
            "typescript": current_language,
        }
    }
    baselines = [
        {
            "language": language,
            "repository": {"line_percent": 85.0, "branch_percent": 75.0},
        }
        for language in ("python", "typescript")
    ]

    result = compare_analyses(
        current,
        baselines,
        repo_line_min=85,
        repo_branch_min=75,
        new_symbol_min=90,
    )

    assert result["overall_verdict"] == "PASS"
    assert result["languages"]["python"]["line_delta"] == 1.0
    assert result["languages"]["typescript"]["branch_delta"] == 1.0


def test_cli_requires_explicit_repository_thresholds() -> None:
    """The CLI rejects analysis without all three explicit policy floors."""

    parser = build_parser()

    with pytest.raises(SystemExit):
        parser.parse_args(["--mode", "baseline", "--output", "unused.json"])


@pytest.mark.parametrize(
    "invalid_text",
    ["[]", '{"files": []}', '{"files": {}, "totals": {"covered_lines": -1}}'],
)
def test_invalid_coverage_py_shapes_fail_closed(invalid_text: str) -> None:
    """Malformed coverage.py inputs raise instead of weakening policy."""

    with pytest.raises(ValueError):
        parse_coverage_py_json(invalid_text)
