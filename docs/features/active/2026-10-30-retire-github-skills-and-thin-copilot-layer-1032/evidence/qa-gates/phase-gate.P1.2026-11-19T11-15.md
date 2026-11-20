# Phase Gate P1 ([P1-T18])

Timestamp: 2026-11-19T11-15
Plan: plan.2026-10-30T18-39.md
Command: sh SCRATCH/issue-1032-gate-static.sh p1 (stages 1 to 3 and 6); env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -q; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
EXIT_CODE: 0
Output Summary: one clean pass of stages 1 to 6 across the repository at the head of Phase 1, with zero failures in each gate and the working tree unchanged by the format steps (`git status --porcelain` identical before and after).

| Stage | Step | Command | EXIT_CODE | Result |
| --- | --- | --- | --- | --- |
| 1 Format | Python | `env -u VIRTUAL_ENV poetry run black --check .` | 0 | 1071 files would be left unchanged |
| 1 Format | TypeScript (root) | `npm run format:check` | 0 | All matched files use Prettier code style |
| 1 Format | TypeScript (extension) | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` | 0 | All matched files use Prettier code style |
| 1 Format | PowerShell | `Invoke-PoshQCFormat -Root <worktree>` (as CI), then `git status --porcelain` compared with the pre-run listing | 0 | tree unchanged (0 files reformatted) |
| 2 Lint | Python | `env -u VIRTUAL_ENV poetry run ruff check .` | 0 | All checks passed |
| 2 Lint | TypeScript (root, extension) | `npm run lint` in each | 0 | no diagnostics |
| 2 Lint | PowerShell | `Invoke-PoshQCAnalyze -Root <worktree>` | 0 | PSScriptAnalyzer passed: no findings |
| 3 Type check | Python | `env -u VIRTUAL_ENV poetry run pyright` | 0 | 0 errors, 0 warnings, 0 informations |
| 3 Type check | TypeScript (root, extension) | `npm run typecheck` in each | 0 | no diagnostics |
| 4 Architecture | — | not applicable: the repository has no `.dependency-cruiser.cjs` and no architecture-boundary job | — | no tool configured |
| 5 Unit | pytest | `pytest -n auto` through the launcher | 0 | 17102 passed, 0 failed, 6 skipped (Phase 0: 17122; the difference is the removed Copilot parameter rows); six earlier attempts exited 75 (queue timeout) |
| 5 Unit | Jest (extension) | `jest-extension` through the launcher | 0 | 352 suites, 5898 tests passed |
| 5 Unit | Jest (root) | `jest` through the launcher | 0 | 355 suites, 5915 tests passed |
| 5 Unit | Pester | one `Invoke-PoshQCParallelTest` through the launcher | 0 | ExitCode 0 (workers 8, 711.14s); 29026 tests, 29008 passed, 0 failed, 18 skipped; `copilot-layer-retirement.Tests.ps1` 16/0, `ProcessReductionChain.Ledger.Tests.ps1` 5/0, `HarnessParityMatrix.RepoGate.Tests.ps1` 7/0, `FileSizePolicy.RepoGate.Tests.ps1` 5/0; line coverage 96.77%; one earlier attempt exited 75 |
| 6 Contract | Codex generator | `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | 0 | no drift reported |
| 6 Contract | Shared-source generators | `pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface all -Check` | 0 | harness-generation: no drift |
| 6 Contract | Leak scan | `Invoke-PoshQCLeakScan -Root <worktree>` | 0 | 897 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures |

Integration and golden lanes are CI-only (excluded by the launcher).
