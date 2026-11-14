# Phase Gate: Phase 1 (remediation cycle 1)

Timestamp: 2026-11-14T13-44
Command: sh SCRATCH/issue-1158-phase-gate.sh r1-p1gate, which runs in sequence: sh SCRATCH/issue-1158-gate-static.sh; sh SCRATCH/issue-1158-ps-gate-static.sh; sh SCRATCH/issue-1158-gate-pytest.sh (env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest with the seven --cov modules, --cov-branch, --cov-report=term-missing, JSON report to SCRATCH); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
EXIT_CODE: 0
Output Summary: one clean pass of stages 1 to 6 covering the Phase 1 changes to scripts/powershell/PoshQC/PoshQC.Parallel.psm1. Static: black (1070 files unchanged), ruff, pyright (0 errors), Codex generator --check, shell-qc check, root and extension Prettier, ESLint, and tsc all exit 0; PowerShell format 0 Formatted lines over 1742 files, PSScriptAnalyzer 0 findings over 1742 files, leak scan 0 failures; tree unchanged. pytest: 16927 passed, 6 skipped, 0 failed. Jest (jest-extension): 340 suites, 5616 tests passed, 0 failed. Pester (pester, 8 shards, all exit 0, wall clock 913.58 s): 26400 tests, 0 failures, 0 errors, 18 skipped; repo-wide line coverage 95.95% (43560 covered, 1839 missed); PoshQC.Parallel.psm1 97.74% (173 covered, 4 missed).

## Stage Results

| Stage | Command | EXIT_CODE | Result |
|---|---|---|---|
| 1 format | poetry run black --check .; Invoke-PoshQCFormat check form; root and extension Prettier --check | 0 | 0 findings |
| 2 lint | poetry run ruff check --no-fix; Invoke-ScriptAnalyzer (1742 files); npx eslint (extension); shell-qc.sh check; Invoke-PoshQCLeakScan -Root . | 0 | 0 findings |
| 3 type check | poetry run pyright; npm run typecheck (extension) | 0 | 0 errors |
| 4 architecture | not applicable: the repository has no architecture-boundary tooling | n/a | n/a |
| 5 unit (pytest) | launcher pytest suite | 0 | 16927 passed, 6 skipped |
| 5 unit (Jest) | launcher jest-extension suite | 0 | 5616 passed |
| 5 unit (Pester) | launcher pester suite | 0 | 26382 passed, 18 skipped |
| 6 contract | the mirror, pack-manifest, bundle-parity, ledger, and wording contract tests inside the pytest and Pester stages, and the Codex generator --check | 0 | 0 failures |

## Named Suites (merged JUnit)

| File | Tests | Failures |
|---|---|---|
| tests/scripts/powershell/PoshQC/PoshQC.ParallelScoped.Tests.ps1 | 12 | 0 |
| tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 | 5 | 0 |
| tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1 | 15 | 0 |
