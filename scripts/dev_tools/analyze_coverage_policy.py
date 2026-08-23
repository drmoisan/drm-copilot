"""Evaluate Python and TypeScript coverage artifacts against repository policy."""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
from pathlib import Path
from typing import cast

from scripts.dev_tools.coverage_policy_inputs import (
    CoverageSnapshot,
    FileCoverage,
    ThresholdMap,
    normalize_path,
    number,
    object_items,
    object_mapping,
    parse_coverage_py_json,
    parse_jest_coverage,
    parse_jest_thresholds,
    parse_python_symbols,
    parse_python_thresholds,
    parse_typescript_symbols,
    parse_unified_diff,
)


def _percent(covered: int, total: int) -> float:
    return 100.0 if total == 0 else round(covered * 100.0 / total, 6)


def _file_percent(coverage: FileCoverage, metric: str) -> float:
    if metric == "lines":
        return _percent(len(coverage.covered), len(coverage.executable))
    return _percent(coverage.branch_covered, coverage.branch_total)


def _baseline_changed_lines(
    baseline: dict[str, object] | None,
) -> dict[str, float]:
    if baseline is None:
        return {}
    result: dict[str, float] = {}
    for raw_item in object_items(
        baseline.get("changed_files", []), "baseline changed_files"
    ):
        item = object_mapping(raw_item, "baseline changed file")
        result[str(item["path"])] = number(
            item["changed_line_percent"], "baseline changed-line percent"
        )
    return result


def _changed_line_results(
    snapshot: CoverageSnapshot,
    changed_lines: dict[str, set[int]],
    baseline: dict[str, float],
) -> list[dict[str, object]]:
    results: list[dict[str, object]] = []
    for path in sorted(changed_lines):
        coverage = snapshot.files.get(path)
        executable = (
            changed_lines[path] & set(coverage.executable) if coverage else set[int]()
        )
        covered = executable & set(coverage.covered) if coverage else set[int]()
        current = _percent(len(covered), len(executable))
        previous = baseline.get(path, current)
        results.append(
            {
                "path": path,
                "executable_changed_lines": len(executable),
                "covered_changed_lines": len(covered),
                "changed_line_percent": current,
                "baseline_changed_line_percent": previous,
                "delta": round(current - previous, 6),
                "pass": current >= previous,
            }
        )
    return results


def _configured_results(
    snapshot: CoverageSnapshot,
    changed_lines: dict[str, set[int]],
    thresholds: ThresholdMap,
) -> list[dict[str, object]]:
    results: list[dict[str, object]] = []
    for path in sorted(set(changed_lines) & set(thresholds)):
        coverage = snapshot.files.get(path)
        required = thresholds[path]
        actual = {
            metric: _file_percent(coverage, metric) if coverage else 0.0
            for metric in required
        }
        results.append(
            {
                "path": path,
                "required": required,
                "actual": actual,
                "pass": all(actual[name] >= value for name, value in required.items()),
            }
        )
    return results


def _new_symbol_results(
    snapshot: CoverageSnapshot,
    *,
    language: str,
    changed_lines: dict[str, set[int]],
    new_files: set[str],
    sources: dict[str, str],
    minimum: float,
) -> list[dict[str, object]]:
    results: list[dict[str, object]] = []
    for path, source in sorted(sources.items()):
        coverage = snapshot.files.get(path)
        symbols = (
            parse_python_symbols(source)
            if language == "python"
            else parse_typescript_symbols(source)
        )
        for symbol in symbols:
            selected = (
                symbol.kind == "module"
                and path in new_files
                or symbol.kind != "module"
                and (
                    path in new_files or symbol.start in changed_lines.get(path, set())
                )
            )
            if not selected:
                continue
            executable = (
                set(coverage.executable) & set(range(symbol.start, symbol.end + 1))
                if coverage
                else set[int]()
            )
            covered = executable & set(coverage.covered) if coverage else set[int]()
            percent = _percent(len(covered), len(executable))
            results.append(
                {
                    "path": path,
                    "kind": symbol.kind,
                    "name": symbol.name,
                    "coverage_percent": percent,
                    "pass": percent >= minimum,
                }
            )
    return results


def analyze_snapshot(
    snapshot: CoverageSnapshot,
    *,
    language: str,
    mode: str,
    changed_lines: dict[str, set[int]],
    new_files: set[str],
    sources: dict[str, str],
    configured_thresholds: ThresholdMap,
    repo_line_min: float,
    repo_branch_min: float,
    new_symbol_min: float,
    baseline_analysis: dict[str, object] | None = None,
) -> dict[str, object]:
    """Evaluate one language snapshot against repository and change policy."""

    line_percent = _percent(snapshot.line_covered, snapshot.line_total)
    branch_percent = _percent(snapshot.branch_covered, snapshot.branch_total)
    changed = _changed_line_results(
        snapshot, changed_lines, _baseline_changed_lines(baseline_analysis)
    )
    configured = _configured_results(snapshot, changed_lines, configured_thresholds)
    symbols = _new_symbol_results(
        snapshot,
        language=language,
        changed_lines=changed_lines,
        new_files=new_files,
        sources=sources,
        minimum=new_symbol_min,
    )
    verdicts = {
        "repository_line": line_percent >= repo_line_min,
        "repository_branch": branch_percent >= repo_branch_min,
        "new_symbols": all(bool(item["pass"]) for item in symbols),
        "configured_changed_files": all(bool(item["pass"]) for item in configured),
        "changed_line_no_regression": all(bool(item["pass"]) for item in changed),
    }
    return {
        "schema_version": 1,
        "mode": mode,
        "language": language,
        "thresholds": {
            "repository_line": repo_line_min,
            "repository_branch": repo_branch_min,
            "new_symbol": new_symbol_min,
        },
        "repository": {
            "line_covered": snapshot.line_covered,
            "line_total": snapshot.line_total,
            "line_percent": line_percent,
            "branch_covered": snapshot.branch_covered,
            "branch_total": snapshot.branch_total,
            "branch_percent": branch_percent,
        },
        "changed_files": changed,
        "configured_changed_files": configured,
        "new_symbols": symbols,
        "verdicts": verdicts,
        "overall_verdict": "PASS" if all(verdicts.values()) else "FAIL",
    }


def compare_analyses(
    analysis: dict[str, object],
    baselines: list[dict[str, object]],
    *,
    repo_line_min: float,
    repo_branch_min: float,
    new_symbol_min: float,
) -> dict[str, object]:
    """Compare final analysis to numeric Python and TypeScript baselines."""

    raw_languages = analysis.get("languages")
    current_languages = (
        object_mapping(raw_languages, "analysis languages")
        if raw_languages is not None
        else {str(analysis.get("language")): analysis}
    )
    baseline_by_language = {
        str(baseline.get("language")): baseline for baseline in baselines
    }
    deltas: dict[str, object] = {}
    passes = True
    for language, raw_current in current_languages.items():
        current = object_mapping(raw_current, f"current {language}")
        baseline = baseline_by_language.get(language)
        if baseline is None:
            raise ValueError(f"missing baseline analysis for {language}")
        current_repo = object_mapping(current.get("repository"), "current repository")
        baseline_repo = object_mapping(
            baseline.get("repository"), "baseline repository"
        )
        line_now = number(current_repo.get("line_percent"), "current line percent")
        branch_now = number(
            current_repo.get("branch_percent"), "current branch percent"
        )
        line_before = number(baseline_repo.get("line_percent"), "baseline line percent")
        branch_before = number(
            baseline_repo.get("branch_percent"), "baseline branch percent"
        )
        symbol_pass = all(
            number(
                object_mapping(item, "new symbol").get("coverage_percent"),
                "new symbol coverage",
            )
            >= new_symbol_min
            for item in object_items(current.get("new_symbols", []), "new_symbols")
        )
        language_pass = (
            line_now >= repo_line_min
            and branch_now >= repo_branch_min
            and symbol_pass
            and str(current.get("overall_verdict")) == "PASS"
        )
        passes = passes and language_pass
        deltas[language] = {
            "baseline_line_percent": line_before,
            "post_line_percent": line_now,
            "line_delta": round(line_now - line_before, 6),
            "baseline_branch_percent": branch_before,
            "post_branch_percent": branch_now,
            "branch_delta": round(branch_now - branch_before, 6),
            "pass": language_pass,
        }
    return {
        "schema_version": 1,
        "mode": "compare",
        "thresholds": {
            "repository_line": repo_line_min,
            "repository_branch": repo_branch_min,
            "new_symbol": new_symbol_min,
        },
        "languages": deltas,
        "overall_verdict": "PASS" if passes else "FAIL",
    }


def build_parser() -> argparse.ArgumentParser:
    """Build the CLI parser with explicit policy-threshold inputs."""

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--mode", required=True, choices=("baseline", "final", "compare")
    )
    parser.add_argument("--language", choices=("python", "typescript", "all"))
    for name in (
        "coverage-json",
        "coverage-summary",
        "lcov",
        "python-coverage-json",
        "typescript-coverage-json",
        "typescript-coverage-summary",
        "typescript-lcov",
        "coverage-config",
        "python-coverage-config",
        "typescript-coverage-config",
        "analysis-json",
        "baseline-python-analysis",
        "baseline-typescript-analysis",
    ):
        parser.add_argument(f"--{name}")
    parser.add_argument("--base-ref", default="HEAD")
    parser.add_argument("--working-tree", action="store_true")
    parser.add_argument("--repo-line-min", required=True, type=float)
    parser.add_argument("--repo-branch-min", required=True, type=float)
    parser.add_argument("--new-symbol-min", required=True, type=float)
    parser.add_argument("--require-configured-changed-files", action="store_true")
    parser.add_argument("--require-no-changed-line-regression", action="store_true")
    parser.add_argument("--output", required=True)
    return parser


def _read_json(path: str) -> dict[str, object]:
    return object_mapping(json.loads(Path(path).read_text(encoding="utf-8")), path)


def _working_tree_changes(base_ref: str) -> tuple[dict[str, set[int]], set[str]]:
    git = shutil.which("git")
    if git is None:
        raise RuntimeError("git executable is required")
    diff = (
        subprocess.run(  # noqa: S603 - static analysis can't verify runtime validation
            [git, "diff", "--unified=0", base_ref, "--"],
            check=False,
            capture_output=True,
            text=True,
            encoding="utf-8",
        )
    )
    if diff.returncode:
        raise RuntimeError(diff.stderr.strip() or "git diff failed")
    changed, new_files = parse_unified_diff(diff.stdout)
    untracked = (
        subprocess.run(  # noqa: S603 - static analysis can't verify runtime validation
            [git, "ls-files", "--others", "--exclude-standard"],
            check=False,
            capture_output=True,
            text=True,
            encoding="utf-8",
        )
    )
    if untracked.returncode:
        raise RuntimeError(untracked.stderr.strip() or "git ls-files failed")
    for raw_path in untracked.stdout.splitlines():
        path = normalize_path(raw_path)
        source = Path(path)
        if source.suffix in {".py", ".ts"} and source.is_file():
            changed[path] = set(
                range(1, len(source.read_text(encoding="utf-8").splitlines()) + 1)
            )
            new_files.add(path)
    return changed, new_files


def _coverage_inputs(
    args: argparse.Namespace, language: str
) -> tuple[CoverageSnapshot, ThresholdMap]:
    if language == "python":
        coverage_path = args.python_coverage_json or args.coverage_json
        config_path = args.python_coverage_config or args.coverage_config
        if not coverage_path or not config_path:
            raise ValueError("Python requires coverage JSON and coverage config")
        return (
            parse_coverage_py_json(Path(coverage_path).read_text(encoding="utf-8")),
            parse_python_thresholds(Path(config_path).read_text(encoding="utf-8")),
        )
    coverage_path = args.typescript_coverage_json or args.coverage_json
    summary_path = args.typescript_coverage_summary or args.coverage_summary
    lcov_path = args.typescript_lcov or args.lcov
    config_path = args.typescript_coverage_config or args.coverage_config
    if not all((coverage_path, summary_path, lcov_path, config_path)):
        raise ValueError(
            "TypeScript requires final JSON, summary JSON, LCOV, and config"
        )
    return (
        parse_jest_coverage(
            Path(coverage_path).read_text(encoding="utf-8"),
            Path(summary_path).read_text(encoding="utf-8"),
            Path(lcov_path).read_text(encoding="utf-8"),
        ),
        parse_jest_thresholds(Path(config_path).read_text(encoding="utf-8")),
    )


def _baseline(args: argparse.Namespace, language: str) -> dict[str, object] | None:
    path = (
        args.baseline_python_analysis
        if language == "python"
        else args.baseline_typescript_analysis
    )
    return _read_json(path) if path else None


def _run_analysis(args: argparse.Namespace) -> dict[str, object]:
    if not args.require_configured_changed_files:
        raise ValueError("--require-configured-changed-files is required")
    if not args.require_no_changed_line_regression:
        raise ValueError("--require-no-changed-line-regression is required")
    if not args.language:
        raise ValueError("--language is required")
    changed: dict[str, set[int]]
    new_files: set[str]
    changed, new_files = (
        _working_tree_changes(args.base_ref) if args.working_tree else ({}, set())
    )
    languages = (
        ("python", "typescript")
        if args.language == "all"
        else (cast("str", args.language),)
    )
    results: dict[str, object] = {}
    for language in languages:
        suffix = ".py" if language == "python" else ".ts"
        language_changes = {
            path: lines for path, lines in changed.items() if path.endswith(suffix)
        }
        snapshot, thresholds = _coverage_inputs(args, language)
        results[language] = analyze_snapshot(
            snapshot,
            language=language,
            mode=args.mode,
            changed_lines=language_changes,
            new_files={path for path in new_files if path.endswith(suffix)},
            sources={
                path: Path(path).read_text(encoding="utf-8")
                for path in language_changes
                if Path(path).is_file()
            },
            configured_thresholds=thresholds,
            repo_line_min=args.repo_line_min,
            repo_branch_min=args.repo_branch_min,
            new_symbol_min=args.new_symbol_min,
            baseline_analysis=_baseline(args, language),
        )
    if len(results) == 1:
        return cast("dict[str, object]", next(iter(results.values())))
    passed = all(
        object_mapping(value, language).get("overall_verdict") == "PASS"
        for language, value in results.items()
    )
    return {
        "schema_version": 1,
        "mode": args.mode,
        "language": "all",
        "languages": results,
        "overall_verdict": "PASS" if passed else "FAIL",
    }


def main(argv: list[str] | None = None) -> int:
    """Run analysis, persist JSON evidence, and return its policy verdict."""

    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        if args.mode == "compare":
            if not args.analysis_json:
                raise ValueError("compare requires --analysis-json")
            baseline_paths = [
                path
                for path in (
                    args.baseline_python_analysis,
                    args.baseline_typescript_analysis,
                )
                if path
            ]
            if not baseline_paths:
                raise ValueError("compare requires baseline analysis")
            result = compare_analyses(
                _read_json(args.analysis_json),
                [_read_json(path) for path in baseline_paths],
                repo_line_min=args.repo_line_min,
                repo_branch_min=args.repo_branch_min,
                new_symbol_min=args.new_symbol_min,
            )
        else:
            result = _run_analysis(args)
    except (OSError, ValueError, RuntimeError) as error:
        parser.error(str(error))
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    return 0 if result.get("overall_verdict") == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
