# Phase Gate P1 (remediation cycle 2, P1-T5)

Timestamp: 2026-11-13T15-12
Command: sh SCRATCH/issue-1164-gate-static.sh (stages 1 to 3 and 6); sh SCRATCH/issue-1164-rootfmt.sh (root format:check re-run); sh SCRATCH/issue-1164-pyright.sh; sh SCRATCH/issue-1164-pester-gate.sh; sh SCRATCH/issue-1164-pytest-gate.sh issue-1164-cov-r2-p1gate; sh SCRATCH/issue-1164-jest-gate.sh ext; sh SCRATCH/issue-1164-jest-gate.sh root
EXIT_CODE: 1
Output Summary:
- Run on head a152b14ba (after P1-T4), 2026-11-13T15-12 to 15-37 UTC, starting from a clean tree.
- Result: NOT CLEAN. Stage 1 fails on one step: the root `npm run format:check` exits 1 for three files outside the branch, listed below. Every other step and every unit-stage suite passes. P1-T5 stays unchecked and execution stops for the caller under the plan's Execution Terms and the delegation brief's rule for a finding outside the plan.

## Stage 1 - format
- PowerShell: Invoke-PoshQCFormat -Root (branch PoshQC.psd1), exit 0; 1545 files "Already formatted"; git status --porcelain empty before and after, so no file changed.
- Python: poetry run black --check ., exit 0, "1062 files would be left unchanged."
- TypeScript (extension): npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs", exit 0, "All matched files use Prettier code style!"
- TypeScript (root): npm run format:check, EXIT 1, "Code style issues found in 3 files": tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json, tests/scripts/claude-lib/docs/fixtures/python-native-corpus.json, tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json (re-run gives the same three).
- Classification of the root format finding: outside the branch. None of the three files is in the diff of the merge base of origin/main and HEAD (217 files; merge base equals origin/main at the run). Their blob ids are identical at the merge base and at HEAD, and they were last changed on main by the issue 1022 corpus commit. The plan's Phase 0 captured no root format baseline (P0-T2 is scoped to the extension), and no workflow under .github/workflows runs Prettier. The files are golden-vector corpora, and the plan's scope excludes them, so they were not reformatted.

## Stage 2 - lint
- PowerShell: Invoke-PoshQCAnalyze -Root, exit 0, "PSScriptAnalyzer passed: no findings". Invoke-PoshQCLeakScan -Root, exit 0, "Leak scan: 747 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures."
- Python: poetry run ruff check ., exit 0, "All checks passed!"
- TypeScript: npm run lint at the root and in extensions/drm-copilot, both exit 0 with no diagnostics.

## Stage 3 - type check
- Python: poetry run pyright, exit 0, "0 errors, 0 warnings, 0 informations".
- TypeScript: npm run typecheck at the root and in extensions/drm-copilot, both exit 0.

## Stage 4 - architecture boundaries
- No architecture-boundary tool or configuration exists in this repository (no dependency-cruiser or equivalent configuration at the root); nothing to run.

## Stage 5 - unit tests (parallel gates, one at a time)
- Pester: Invoke-PoshQCParallelTest, returned ExitCode 0, "workers=8; wall-clock=737.09s; exit code=0", 15-19-09 to 15-31-26 UTC. pester-junit.xml: 21740 tests, 0 failures, 0 errors, 10 disabled (21730 passed; P0-T3 21724). BlastRadiusAccess.Tests.ps1 41, 0 (write-form rows 21 of 21, six new); PrecedenceGate suite 5, 0; parallel-scheduling-rule-wording.Tests.ps1 228, 0; FileSizePolicy.RepoGate.Tests.ps1 5, 0. Coverage: repo 37704 / 39350 = 95.82% (P0-T3 95.82%); BlastRadiusAccess.psm1 66 / 66 = 100.00% (P0-T3 64 / 64).
- pytest: tests/ -n auto with coverage, exit 0, "16676 passed, 6 skipped in 234.00s" (P0-T4 16670 passed); repo line 34525 / 35546 = 97.13%, branch 12758 / 13514 = 94.41% (P0-T4 equal); _parallel_state_records.py 191 / 191 line, 96 / 96 branch.
- Jest (extension): exit 0; Test Suites 341 passed; Tests 5508 passed (P0-T5 5502); parallel-state-shared.ts line 525 / 538 = 97.58%, branch 116 / 119 = 97.48% (P0-T5 97.36%, 97.17%).
- Jest (root): exit 0; Test Suites 344 passed; Tests 5525 passed (P0-T6 5519); repo line 70015 / 71235 = 98.29%, branch 10445 / 11153 = 93.65% (P0-T6 98.29%, 93.64%).

## Stage 6 - contract checks
- poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check, exit 0. The mirror contract suites (test_push_down_claude_resource_contracts.py and the pack-manifest suites) ran inside the pytest gate and passed.

## Tree state
- git status --porcelain at the end of every stage: empty. No file was auto-fixed.
