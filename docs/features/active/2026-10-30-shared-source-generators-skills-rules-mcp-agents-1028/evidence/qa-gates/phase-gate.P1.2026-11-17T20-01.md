# Phase 1 Gate ([P1-T6])

Timestamp: 2026-11-17T20-01
Command: sh SCRATCH/issue-1028-gatestatic.sh p1gate (stages 1, 2, 3 and 6); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester; env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension
EXIT_CODE: 0
Output Summary: One clean pass of stages 1 to 6 with zero failures in all three parallel gates. No step failed and no step changed a file: `git status --porcelain` was empty after the static stages and after the unit stage, so no restart was needed.

## Stage 1 — Format
- PowerShell (`Invoke-PoshQCFormat` with a non-writing seam over `scripts` and `tests/scripts`): exit 0; 958 files, 0 would change.
- Black `--check scripts tests`: exit 0; "895 files would be left unchanged."
- Prettier `--check` in `extensions/drm-copilot/`: exit 0; "All matched files use Prettier code style!"

## Stage 2 — Lint
- PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `scripts` and `tests/scripts`: exit 0; 958 files, 0 findings, 0 errors. One same-file retry followed a transient engine `NullReferenceException`, the host-level condition recorded in `evidence/other/task-check.P1-T2.2026-11-17T19-20.md`.
- Ruff `check scripts tests`: exit 0; "All checks passed!"
- ESLint (`npm run lint` in `extensions/drm-copilot/`): exit 0; 0 errors, 0 warnings.

## Stage 3 — Type check
- Pyright (project configuration): exit 0; "0 errors, 0 warnings, 0 informations".
- tsc (`npm run typecheck`): exit 0; 0 `error TS` diagnostics.

## Stage 4 — Architecture boundaries
- Not applicable: no `.dependency-cruiser.cjs` exists at the repository root or in `extensions/drm-copilot/`, no .NET architecture test project exists, and no package script runs a boundary check. Search: `ls .dependency-cruiser.cjs extensions/drm-copilot/.dependency-cruiser.cjs` (both absent), and a search of both `package.json` files for `depcruise`, `dependency-cruiser` or `arch` (no match).

## Stage 5 — Unit (parallel gates)
- Pester (`Invoke-PoshQCParallelTest`, 8 shards, 1294.08 s): exit 0; 840 suites, 28225 tests, 28207 passed, 0 failures, 0 errors, 18 skipped. Repo line coverage is 96.69% at the Phase 0 baseline and 96.71% here (46142 covered, 1572 missed). New files: `HarnessGeneration.psm1` 98.57%, `HarnessInstructions.psm1` 100.00%, `HarnessMcpConfig.psm1` 100.00%, `Invoke-HarnessGeneration.ps1` 86.67%. This run includes the feature-review coverage hook suites (spec S-IN-3), `Invoke-FullRelease.Tests.ps1`, `test-cadence-wording.Tests.ps1`, `ProcessReductionChain.Ledger.Tests.ps1` and `HarnessParityMatrix.RepoGate.Tests.ps1`.
- pytest (`pytest -n auto` over `tests`): exit 0; 17111 passed, 0 failed, 6 skipped. This includes the `## Contract Test Set` Python suites.
- Jest (`jest-extension` suite, normal parallel workers): exit 0; 351 of 351 suites passed, 5881 of 5881 tests passed.

## Stage 6 — Contract checks
- Codex generator check (`scripts.dev_tools.generate_codex_agent_variants --check`): exit 0, no drift.
- Quality tiers: exit 0; "quality-tiers: OK (38 entries, 38 discovered projects)".
- `Invoke-HarnessGeneration.ps1 -Surface instructions -Check`: exit 0; "harness-generation: no drift".
- `Invoke-HarnessGeneration.ps1 -Surface mcp -Check`: exit 0; "harness-generation: no drift".
