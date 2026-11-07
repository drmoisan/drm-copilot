# Preflight Fixes — Issue #1106

Timestamp: 2026-11-07T14-45
Plan: docs/features/active/2026-11-07-policy-file-consistency-mstest-pester6-1106/plan.2026-11-07T09-01.md

## Fix 1 — `## Terms`, `PY` definition (route correctness; validator-blind)

- Defect: under the stated `PY` route, `PY -m pyright` over the six P0-T2 Python files, run from the worktree, reported 51 errors, all following from `Import "pytest" could not be resolved` in `tests/scripts/dev_tools/atomic_executor/test_qc_runner.py`. `[tool.pyright]` in `pyproject.toml` sets `venvPath = "."` and `venv = ".venv"`, which resolves to the worktree's empty `.venv`. The same files report 0 errors from the main checkout. P5-T1 requires the `0 errors` summary, which the route as written could not produce.
- Probe: adding `--pythonpath` to the interpreter did not change the result (51 errors); adding `--venvpath` set to the main checkout root produced `0 errors, 0 warnings, 0 informations`.
- Change: the `PY` term now states that pyright receives `--venvpath` set to the main checkout root, with the reason. The asserted value (`0 errors`) is unchanged.

## Fix 2 — `[P0-T4]` (read location on a red baseline; validator-blind)

- Defect: `Invoke-PoshQCParallelMerge` in `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` writes no merged `artifacts/pester/pester-junit.xml` or `powershell-coverage.xml` when any shard exits non-zero, and the worktree has no `artifacts/pester/` directory yet. A red baseline would therefore leave P0-T4 with nothing to copy and no coverage total.
- Change: P0-T4 now states that, on a non-zero shard exit, the counts and failing-test names are summed from the per-shard JUnit files, those shard files are the copies under `SCRATCH/baseline/`, and the coverage total is recorded as `not written (shard exited non-zero)`. A green baseline is read exactly as before. The baseline's purpose (record pre-change counts and failures for the P5-T5 comparison) is unchanged.

## Checks performed without a fix (for the record)

- `mcp__drm-copilot__validate_orchestration_artifacts` (plan) and the branch Python CLI `validate_orchestration_artifacts plan`: pass, no warnings.
- `generate_codex_agent_variants --check` on the unmodified worktree: exit 0.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` and `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` (previously state-sensitive) run in the worktree with its checkpoint present: 55 passed, 0 failed (Pester 6.2.0, debugging probe only).
- Black and Ruff on the six P0-T2 files under the `PY` route: `6 files would be left unchanged.` and `All checks passed!`.
