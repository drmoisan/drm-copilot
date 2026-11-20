# Phase Gate P1 ([P1-T7], stage B)

Timestamp: 2026-11-20T13-28
Command: sh SCRATCH/issue-1016-static2.sh (extensions/drm-copilot: npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"; npm run lint; npm run typecheck); sh SCRATCH/issue-1016-pystatic.sh (env -u VIRTUAL_ENV poetry run black --check .; ruff check .; pyright); sh SCRATCH/issue-1016-psstatic.sh (Invoke-PoshQCFormat with a non-writing -WriteFile seam; Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file); sh SCRATCH/issue-1016-g-jest.sh (run-test-suite.sh jest-extension --coverage); sh SCRATCH/issue-1016-g-pytest.sh (env -u VIRTUAL_ENV run-test-suite.sh pytest -n auto --cov=scripts --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1016-coverage-p1g.json); sh SCRATCH/issue-1016-g-pester.sh (run-test-suite.sh pester, Invoke-PoshQCParallelTest); pwsh -WorkingDirectory <worktree> -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface all -Check; env -u VIRTUAL_ENV poetry -C <worktree> run python -m scripts.dev_tools.generate_codex_agent_variants --check; the same with scripts.dev_tools.build_discovery_runtime --check
EXIT_CODE: 0
Output Summary: One clean pass of stages 1 to 6, no auto-fix and no restart. Jest 6684 passed, 0 failed; pytest 17101 passed, 6 skipped, 0 failed; Pester 29146 tests, 29128 passed, 0 failed, 0 errors, 18 skipped (ExitCode 0, 703.54 s), including ProcessReductionChain.Ledger.Tests.ps1 (PRC-LEDGER-CHAIN-HOLDS Passed) and HarnessGeneration.RepoGate.Tests.ps1 ("reports no drift for any generated target in the working tree" Passed), and the three PRC-READ-FALLBACK cases of [P1-T5] Passed. Generator checks: harness-generation: no drift; Codex variants exit 0; build_discovery_runtime exit 0.

| Stage | Command | Exit | Findings |
| --- | --- | --- | --- |
| 1 Format (TypeScript) | npx prettier --check | 0 | 0; observed `All matched files use Prettier code style!` |
| 1 Format (Python) | poetry run black --check . | 0 | 0; `1071 files would be left unchanged.` |
| 1 Format (PowerShell) | Invoke-PoshQCFormat, non-writing seam | 0 | 1864 files, 0 `Formatted:` lines |
| 2 Lint (TypeScript) | npm run lint | 0 | 0 ESLint findings |
| 2 Lint (Python) | poetry run ruff check . | 0 | `All checks passed!` |
| 2 Lint (PowerShell) | Invoke-ScriptAnalyzer per file | 0 | 1864 files, 0 findings |
| 3 Type check (TypeScript) | npm run typecheck | 0 | 0 `error TS` lines |
| 3 Type check (Python) | poetry run pyright | 0 | `0 errors, 0 warnings, 0 informations` |
| 4 Architecture boundaries | dependency-cruiser has no configuration in the repository (recorded as not configured, as in [P0-T4]); the boundary suites run inside stage 5 | 0 | 0 |
| 5 Unit (Jest, launcher jest-extension) | normal parallel workers | 0 | `Test Suites: 412 passed, 412 total`; `Tests: 6684 passed, 6684 total`; lines 97.58%, branches 94.95% |
| 5 Unit (pytest, launcher, -n auto) | coverage run | 0 | 17101 passed, 6 skipped, 0 failed; TOTAL 96% |
| 5 Unit (Pester, launcher, Invoke-PoshQCParallelTest) | 8 workers | 0 | 29146 tests, 0 failed, 0 errors; line coverage 47286/48827 = 96.84% over 482 files |
| 6 Contract | contract suites inside stage 5; Invoke-HarnessGeneration.ps1 -Surface all -Check; generate_codex_agent_variants --check; build_discovery_runtime --check | 0 | `harness-generation: no drift`; Codex exit 0; discovery exit 0 |

Integration and golden lanes: excluded locally by the launcher; they run in CI.
