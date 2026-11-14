# Phase Gate: Phase 2 (remediation cycle 1)

Timestamp: 2026-11-14T15-00
Command: sh SCRATCH/issue-1158-phase-gate.sh r1-p2gate, which runs in sequence: sh SCRATCH/issue-1158-gate-static.sh (black --check, ruff, pyright, scripts/dev_tools/generate_codex_agent_variants.py in --check mode, shell-qc check, root and extension Prettier --check, ESLint, tsc); sh SCRATCH/issue-1158-ps-gate-static.sh; sh SCRATCH/issue-1158-gate-pytest.sh (env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest with the seven --cov modules); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
EXIT_CODE: 0
Output Summary: one clean pass of stages 1 to 6 after the Phase 2 policy-text, wording-row, ledger, and requirement-document changes. Static: black (1070 files unchanged), ruff, pyright (0 errors), Codex generator --check, shell-qc check, root and extension Prettier, ESLint, and tsc all exit 0; PowerShell format 0 Formatted lines over 1742 files, PSScriptAnalyzer 0 findings over 1742 files, leak scan 0 failures; tree unchanged. pytest: 16927 passed, 6 skipped, 0 failed (it includes the push-down resource contracts, the pack-manifest completeness and closure tests, and test_execution_environment_brief_contracts.py). Jest (jest-extension): 340 suites, 5616 tests passed. Pester (pester, 8 shards, all exit 0, wall clock 781.94 s): 26420 tests, 0 failures, 0 errors, 18 skipped; repo-wide line coverage 95.95% (43560 covered, 1839 missed).

## Stage Results

| Stage | Command | EXIT_CODE | Result |
|---|---|---|---|
| 1 format | poetry run black --check .; Invoke-PoshQCFormat check form; root and extension Prettier --check | 0 | 0 findings |
| 2 lint | poetry run ruff check --no-fix; Invoke-ScriptAnalyzer (1742 files); npx eslint (extension); shell-qc.sh check; Invoke-PoshQCLeakScan -Root . | 0 | 0 findings |
| 3 type check | poetry run pyright; npm run typecheck (extension) | 0 | 0 errors |
| 4 architecture | not applicable: the repository has no architecture-boundary tooling | n/a | n/a |
| 5 unit (pytest) | launcher pytest suite | 0 | 16927 passed, 6 skipped |
| 5 unit (Jest) | launcher jest-extension suite | 0 | 5616 passed |
| 5 unit (Pester) | launcher pester suite | 0 | 26402 passed, 18 skipped |
| 6 contract | Codex generator --check; the push-down, pack-manifest, brief, ledger, and wording contract tests inside the pytest and Pester stages | 0 | 0 failures |

## Named Suites (merged JUnit)

| File | Tests | Failures |
|---|---|---|
| tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 | 5 | 0 |
| tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1 | 15 | 0 |
| tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 | 108 | 0 |
| tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 | 136 | 0 |
| tests/scripts/powershell/PoshQC/PoshQC.ParallelScoped.Tests.ps1 | 12 | 0 |
