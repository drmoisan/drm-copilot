# Code Review: bootstrap-utility-scripts (#40)

**Base:** development  
**Head:** bootstrap-utilities-#40  
**Primary evidence:** `artifacts/pr_context.summary.txt`  
**Diff evidence:** `artifacts/pr_context.appendix.txt`

**Feature folder selection rule:** reviewed `docs/features/active/2026-02-21-bootstrap-utility-scripts-40/` because it matches issue #40 and contains the persisted work-mode marker.

## Executive Summary

This branch introduces substantial new developer tooling across Python and PowerShell plus supporting tests/fixtures. The implementation breadth is high and provides meaningful capability, but two blockers prevent PR readiness.

Top 3 risks:
1. Python type-check gate is red (`pyright` fails in `node_modules`), so CI/type-safety is not stable.
2. Mandatory file-size cap (500 lines) is breached by numerous production and test files.
3. Large monolithic modules (notably `atomic_executor/cli.py`) increase maintenance and review risk.

**Recommendation:** **No-Go** until remediation is complete.

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `pyproject.toml` / Python workspace scope | Pyright run | Python typecheck fails because `node_modules/flatted/python/flatted.py` is analyzed | Constrain pyright include/exclude to repository Python scope and re-run strict typecheck | Required toolchain gate must pass | `poetry run pyright` -> `PYRIGHT_EXIT=1`, 162 errors in node_modules path |
| Blocker | Multiple files | Whole-file | 500-line max policy violated by many files | Split oversized modules/tests into cohesive submodules and focused test files | Repo policy is explicit and mandatory for prod+tests | Line counts: `cli.py` 2327, `new_active_feature_folder.py` 1190, `fix_all.py` 944, etc. |
| Major | `scripts/dev_tools/atomic_executor/cli.py` | Whole file | CLI orchestrates too many concerns in one unit | Decompose into parser/executor/reporting layers with narrow APIs | Improves readability, maintainability, and testability | 2327 lines; concentrated behavior surface |
| Minor | `pyproject.toml` | `[tool.pyright]` | `diagnosticMode` is unrecognized | Remove or replace with supported pyright setting | Reduces config drift/noise | Pyright warning printed on run |

## Typed Python Audit

- **No type-check weakening found in changed source** (no broad `type: ignore` additions observed in sampled diff hunks).
- **Gate status:** fails due scope/config issue rather than local annotation regressions.
- **Risk:** failing type gate masks true regressions and reduces confidence for future merges.

## Test Quality Audit

- Python tests: high execution volume (`765 passed`) and deterministic in this run.
- PowerShell tests: `211 passed, 0 failed, 7 skipped` via direct Pester invocation.
- TypeScript tests: `1 passed`.
- Coverage: reported Python total coverage `81%`; however, several large modules remain under 90% (e.g., `atomic_executor/cli.py` ~68%), which is notable versus policy expectations for new modules.

## Security / Correctness Notes

- No secrets were observed in reviewed diff summaries.
- Several scripts call external CLIs/network (expected for tooling), but this increases boundary risk; typed adapters and clearer seam boundaries would help.

## Go/No-Go

**No-Go (Needs revision).**

Must fix before PR merge:
1. Make Python typecheck pass in repo scope.
2. Bring oversized files into policy-compliant file sizes via decomposition.
