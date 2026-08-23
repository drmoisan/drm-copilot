"""In-memory builders for coverage policy analyzer tests."""

from __future__ import annotations

import json

from scripts.dev_tools.analyze_coverage_policy import analyze_snapshot
from scripts.dev_tools.coverage_policy_inputs import CoverageSnapshot, FileCoverage


def coverage_py_text(*, covered_lines: int = 85, total_lines: int = 100) -> str:
    """Return a minimal coverage.py JSON report for one Python source."""

    executed = list(range(1, covered_lines + 1))
    missing = list(range(covered_lines + 1, total_lines + 1))
    return json.dumps(
        {
            "files": {
                "scripts/dev_tools/example.py": {
                    "executed_lines": executed,
                    "missing_lines": missing,
                    "summary": {
                        "covered_branches": 75,
                        "num_branches": 100,
                    },
                }
            },
            "totals": {
                "covered_lines": covered_lines,
                "num_statements": total_lines,
                "covered_branches": 75,
                "num_branches": 100,
            },
        }
    )


def snapshot(
    *,
    path: str,
    executable: set[int],
    covered: set[int],
    line_covered: int = 85,
    branch_covered: int = 75,
    file_branch_covered: int | None = None,
) -> CoverageSnapshot:
    """Return a policy-boundary snapshot with one source file."""

    return CoverageSnapshot(
        files={
            path: FileCoverage(
                frozenset(executable),
                frozenset(covered),
                branch_covered if file_branch_covered is None else file_branch_covered,
                100,
            )
        },
        line_covered=line_covered,
        line_total=100,
        branch_covered=branch_covered,
        branch_total=100,
    )


def analyze(
    snapshot_value: CoverageSnapshot,
    *,
    language: str,
    path: str,
    source: str,
    new_file: bool = True,
    thresholds: dict[str, dict[str, float]] | None = None,
    baseline: dict[str, object] | None = None,
) -> dict[str, object]:
    """Evaluate a single in-memory source at the canonical policy floors."""

    lines = set(range(1, len(source.splitlines()) + 1))
    return analyze_snapshot(
        snapshot_value,
        language=language,
        mode="baseline" if baseline is None else "final",
        changed_lines={path: lines},
        new_files={path} if new_file else set(),
        sources={path: source},
        configured_thresholds=thresholds or {},
        repo_line_min=85,
        repo_branch_min=75,
        new_symbol_min=90,
        baseline_analysis=baseline,
    )
