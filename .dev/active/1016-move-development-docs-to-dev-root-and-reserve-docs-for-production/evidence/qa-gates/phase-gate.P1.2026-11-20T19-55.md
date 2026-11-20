# Phase Gate P1 [P1-T8] — remediation cycle 1

Timestamp: 2026-11-20T19-55
Command: sh SCRATCH/issue-1016-c1-gate.sh SCRATCH/c1g1 all (stages 1 to 3: npx prettier --check, npm run lint and npm run typecheck in extensions/drm-copilot; npm --prefix <worktree> run format:check, lint and typecheck at the root; black --check ., ruff check ., pyright through env -u VIRTUAL_ENV poetry run; Invoke-PoshQCFormat with a non-writing seam and Invoke-ScriptAnalyzer per file with pssa.settings.psd1; stage 6 generators: Invoke-HarnessGeneration.ps1 -Surface all -Check, python -m scripts.dev_tools.generate_codex_agent_variants --check, python -m scripts.dev_tools.build_discovery_runtime --check; stage 5: launcher jest-extension --coverage, launcher jest (root) --coverage, env -u VIRTUAL_ENV launcher pytest -n auto --cov=scripts --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/c1g1.pycov.json, launcher pester)
EXIT_CODE: 0
Output Summary: One clean pass of stages 1 to 6 for TypeScript, Python and PowerShell at head 5cc3abfc8 with the [P0-T3] clean layout in place, with no auto-fix and no restart. Jest extension 412 suites, 6706 passed, 0 failed; root Jest 415 suites, 6723 passed, 0 failed; pytest 17104 passed, 6 skipped, 0 failed, 0 errors; Pester 29157 tests, 0 failures, 0 errors, 22 disabled (Invoke-PoshQCParallelTest workers=8, exit code 0), including `STR-ENTRY-PRINTS-LABELS-AND-FIXTURE-MEDIANS` (Passed). The moved-root directories are absent before and after the pass.

| Stage | Command | Exit | Findings |
| --- | --- | --- | --- |
| 1 Format (TypeScript, extension) | npx prettier --check | 0 | `All matched files use Prettier code style!`; 0 `[warn]` lines |
| 1 Format (TypeScript, root) | npm run format:check | 0 | `All matched files use Prettier code style!` |
| 1 Format (Python) | black --check . | 0 | `1071 files would be left unchanged.` |
| 1 Format (PowerShell) | Invoke-PoshQCFormat, non-writing seam | 0 | 1866 files, 0 drift |
| 2 Lint (TypeScript, extension) | npm run lint | 0 | 0 |
| 2 Lint (TypeScript, root) | npm run lint | 0 | 0 |
| 2 Lint (Python) | ruff check . | 0 | `All checks passed!` |
| 2 Lint (PowerShell) | Invoke-ScriptAnalyzer per file | 0 | 1866 files, 0 findings, 0 retries |
| 3 Type check (TypeScript, extension) | npm run typecheck | 0 | 0 `error TS` lines |
| 3 Type check (TypeScript, root) | npm run typecheck | 0 | 0 `error TS` lines |
| 3 Type check (Python) | pyright | 0 | `0 errors, 0 warnings, 0 informations` |
| 4 Architecture boundaries | dependency-cruiser is not configured in this repository; the boundary suites (for example `no-vscode-import.test.ts`) run inside stage 5 | 0 | 0 |
| 5 Unit (Jest extension) | launcher jest-extension --coverage | 0 | 412 suites, 6706 passed; lines 97.59% (74531/76371), branches 94.95% (11908/12541) |
| 5 Unit (Jest root) | launcher jest --coverage | 0 | 415 suites, 6723 passed; lines 98.44% (81575/82866), branches 94.62% (12705/13426) |
| 5 Unit (pytest) | launcher pytest -n auto with coverage | 0 | 17104 passed, 6 skipped; lines 96.66% (17720/18332), branches 92.53% (6194/6694) |
| 5 Unit (Pester) | launcher pester | 0 | 29157 tests, 0 failures, 0 errors; line coverage 96.84% (47286/48827) |
| 6 Contract | contract suites inside stage 5; harness, Codex variant and discovery checks | 0, 0, 0 | `harness-generation: no drift`; Codex exit 0; discovery exit 0 |

Sweep: none. No test failed because of a read of a moved root from the real checkout; the only such test, `STR-ENTRY-PRINTS-LABELS-AND-FIXTURE-MEDIANS`, was fixed in [P1-T6] and passes here.
Other failures: none.

Absence check: before the pass, `docs/features`, `docs/research`, `docs/engineering` and `docs/discovery` were absent; after the pass all four were still absent. No run recreated one. Tracked porcelain output was unchanged across the run.

Integration and golden lanes: excluded locally by the launcher; they run in CI.
