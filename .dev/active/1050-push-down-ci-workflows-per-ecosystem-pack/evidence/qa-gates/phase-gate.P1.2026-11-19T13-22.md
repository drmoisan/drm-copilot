# Phase Gate P1 (advisory-fix plan, P1-T5)

Timestamp: 2026-11-19T13-22
Command: sh SCRATCH/issue-1050-advisory-gate-static.sh ap1gate (stages 1-4 and the harness generator check); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
EXIT_CODE: 0
Output Summary: One clean pass of stages 1-6, no restart. Static: 0 findings in PowerShell, TypeScript, and YAML; `git status --porcelain` identical before and after (16 lines). Jest 374 suites, 6184 passed, 0 failed; lines 97.44%, branches 94.66%. Pester 29242 tests, 0 failures, 0 errors, 18 skipped; repo-wide line 96.77% (47244/48820); `scripts/ci/Set-CiRequiredChecks.ps1` 98.36% (60/61).

## Stages

| Stage | Command | Exit code | Counts |
| --- | --- | --- | --- |
| 1 Format: PowerShell | `Invoke-Formatter` (non-writing comparison, pssa.settings.psd1) over `scripts`, `tests/scripts`, `extensions/drm-copilot/resources/ci-workflows` | 0 | 985 files, 0 differences |
| 1 Format: TypeScript and README | `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs" README.md` (extensions/drm-copilot) | 0 | `All matched files use Prettier code style!` |
| 2 Lint: PowerShell | `Invoke-ScriptAnalyzer` per file, repository settings, same 985 files | 0 | 0 findings |
| 2 Lint: TypeScript | `npm run lint` | 0 | 0 problems |
| 2 Lint: YAML | actionlint 1.7.12 over `harness-python.yml`, `harness-powershell.yml`, `harness-typescript.yml`, `harness-dotnet.yml` | 0 | 0 findings |
| 3 Type check: TypeScript | `npm run typecheck` | 0 | 0 `error TS` |
| 4 Architecture boundaries | no `.dependency-cruiser.cjs` in the repository | n/a | not applicable |
| 5 Unit: Jest | launcher `jest-extension --coverage` | 0 | 374 suites, 6184 passed, 0 failed |
| 5 Unit: Pester | launcher `pester` (one `Invoke-PoshQCParallelTest`, 8 workers, 885.51s) | 0 | 29242 tests, 0 failures, 0 errors, 18 skipped |
| 6 Contract: harness generator | `Invoke-HarnessGeneration.ps1 -Surface all -Check` | 0 | `harness-generation: no drift` |
| 6 Contract: bundle parity | Jest `CI bundle is complete and copies match` inside stage 5 | 0 | passed |

## Notes

- Queue timeouts: Jest exited 75 three times and Pester seven times (`TEST_EXECUTION_QUEUE_TIMEOUT:`, lock held by other worktrees); each was re-run after the holder finished.
- PowerShell analyzer engine exception (not a finding) on the untouched `scripts/ci/CiRequiredGate.psm1` (`Object reference not set to an instance of an object.`), the same engine-exception class recorded at baseline and in earlier gates for an untouched `scripts/ci` module.
- No Python file changed; the plan's gate has no Python stage.
- Pester delta: 29242 tests against 29237 at the prior final gate, the five new `Set-CiRequiredChecks.Tests.ps1` cases.
