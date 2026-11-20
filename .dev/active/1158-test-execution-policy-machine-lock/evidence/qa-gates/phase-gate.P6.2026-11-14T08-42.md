# Phase Gate: Phase 6

Timestamp: 2026-11-14T08-42
Command: sh SCRATCH/issue-1158-gate-static.sh; sh SCRATCH/issue-1158-ps-gate-static.sh; sh SCRATCH/issue-1158-gate-pytest.sh (launcher `pytest` suite with the seven `--cov` modules, `--cov-branch`, `--cov-report=term-missing`, JSON report to SCRATCH); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
EXIT_CODE: 0
Output Summary: one clean pass of stages 1 to 6 after the P6-T9 merge of `origin/main`. Static: black (1068 files unchanged), ruff, pyright, Codex generator `--check`, shell-qc check, extension Prettier, ESLint, and tsc all exit 0; PowerShell format 0 `Formatted:` lines over 1672 files, PSScriptAnalyzer 0 findings over 1672 files, leak scan exit 0; tree unchanged. pytest: 16826 passed, 0 failed, 6 skipped. Jest (`jest-extension`): 338 suites, 5538 tests passed, 0 failed. Pester (`pester`, 8 shards, all exit 0): 25128 tests, 0 failures, 0 errors, 10 skipped; repo-wide line coverage 95.95%.

Gate rule applied: `## Test Cadence (Mandatory)` of the `atomic-plan-contract` skill (orchestrator decision ORCH-D4; the plan predates #1167). The five planned-ordering failures of the Phase 5 gate are resolved by P6-T1 and P6-T2.

## Stage Results

| Stage | Command | EXIT_CODE | Result |
|---|---|---|---|
| 1 format | `poetry run black --check .`; Invoke-PoshQCFormat check form; `npx prettier --check` (extension) | 0 | 0 findings |
| 2 lint | `poetry run ruff check --no-fix`; Invoke-ScriptAnalyzer (1672 files); `npx eslint` (extension); `shell-qc.sh check`; `Invoke-PoshQCLeakScan -Root .` | 0 | 0 findings |
| 3 type check | `poetry run pyright`; `npm run typecheck` (extension) | 0 | 0 errors |
| 4 architecture | not applicable: the repository has no architecture-boundary tooling | n/a | n/a |
| 5 unit (pytest) | launcher `pytest` suite | 0 | 16826 passed |
| 5 unit (Jest) | launcher `jest-extension` suite | 0 | 5538 passed |
| 5 unit (Pester) | launcher `pester` suite | 0 | 25118 passed, 10 skipped |
| 6 contract | the mirror, pack-manifest, ledger, and wording contract tests inside the pytest and Pester stages | 0 | 0 failures |

## Coverage

- Python (JSON report): every one of the seven modules at or above 93.58% line and 81.82% branch; total 98.83% line, 96.41% branch.
- PowerShell (line): repo-wide 95.95%; `.claude/hooks/test-execution-policy.ps1` 100.00%, `test-execution-lock-decision.ps1` 100.00%, `test-execution-lock.ps1` 86.96%, `test-execution-command-form.ps1` 96.74%, `enforce-test-execution-policy.ps1` 87.88%; `Invoke-TestSuite.ps1` 89.90%; `Invoke-PesterSuite.ps1` 94.74%; `PoshQC.Testing.psm1` 94.17%; `PoshQC.Parallel.psm1` 97.40%; `scripts/dev-tools/run-poshqc-suite.ps1` 87.50%.
- Lane exclusion reach: none of the four integration-named Pester files appears in the merged JUnit.
