# Phase Gate: Phase 5

Timestamp: 2026-11-14T07-24
Command: sh SCRATCH/issue-1158-gate-static.sh; sh SCRATCH/issue-1158-ps-gate-static.sh; sh SCRATCH/issue-1158-gate-pytest.sh (launcher `pytest` suite with the seven `--cov` modules, `--cov-branch`, `--cov-report=term-missing`, JSON report to SCRATCH); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester
EXIT_CODE: 1
Output Summary: final pass of stages 1 to 6 after five restarts. Static: black, ruff, pyright, Codex generator `--check`, shell-qc check, extension Prettier, ESLint, and tsc all exit 0; PowerShell format 0 `Formatted:` lines over 1642 files, PSScriptAnalyzer 0 findings over 1642 files, leak scan exit 0; tree unchanged. pytest: 16815 passed, 5 failed, 6 skipped; the 5 failures are the planned-ordering failures listed below. Jest (`jest-extension`): 338 suites, 5538 tests passed, 0 failed. Pester (`pester`, 8 shards): 24716 tests, 0 failures, 0 errors, 10 skipped; repo-wide line coverage 95.91%.

Gate rule applied: `## Test Cadence (Mandatory)` of the `atomic-plan-contract` skill (orchestrator decision ORCH-D4; the plan predates #1167).

## Stage Results (final pass)

| Stage | Command | EXIT_CODE | Result |
|---|---|---|---|
| 1 format | `poetry run black --check .`; Invoke-PoshQCFormat check form; `npx prettier --check` (extension) | 0 | 1068 Python files unchanged; 0 `Formatted:` of 1642; 0 Prettier findings |
| 2 lint | `poetry run ruff check --no-fix`; Invoke-ScriptAnalyzer (1642 files); `npx eslint` (extension); `shell-qc.sh check`; `Invoke-PoshQCLeakScan -Root .` | 0 | `All checks passed!`; 0 findings; 0 findings; 0 findings; exit 0 |
| 3 type check | `poetry run pyright`; `npm run typecheck` (extension) | 0 | 0 errors |
| 4 architecture | not applicable: the repository has no architecture-boundary tooling | n/a | n/a |
| 5 unit (pytest) | launcher `pytest` suite | 1 | 16815 passed, 5 failed (planned ordering), 6 skipped |
| 5 unit (Jest) | launcher `jest-extension` suite | 0 | 338 suites, 5538 tests passed |
| 5 unit (Pester) | launcher `pester` suite | 0 | 24716 tests, 0 failures |
| 6 contract | the mirror contract tests run inside the pytest and Pester stages | see stage 5 | same 5 planned-ordering failures |

## Planned-Ordering Failures (not defects)

The `test-execution-policy` skill folder and its three scripts are bundled and manifested by P6-T1 and P6-T2, which run after this gate. Until then these five tests fail, each naming only `test-execution-policy` paths:

- `tests/scripts/dev_tools/test_codex_full_migration_inventory.py::test_all_repo_agent_skills_are_bundled_and_identical`
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`
- `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_every_skill_folder_file_is_carried_by_skill_packs`
- `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled`

The Phase 6 gate must pass with none of them.

## Restarts (fix, then restart from stage 1)

1. pytest collected 0 items: through `pwsh -File`, PowerShell split `--cov-report=json:<path>` into two `$args` elements. Fixed in `Invoke-TestSuite.ps1` (`Get-TestSuiteScriptArgument`, commit subject `fix(launcher): keep colon-bearing extras intact under pwsh -File (#1158)`); this also affected the `--cov-report=lcov:` argument of the VS Code coverage task.
2. `test_every_psscriptroot_occurrence_is_recognized` flagged the hook's root chain; rewritten in the recognized form in both hooks, their bundle copies, and the launcher.
3. `cli_task_runtime.py` (30.64% line) and `qc_runner_expectations.py` (79.10% line) were below thresholds; their Phase 5 test files were extended.
4. Pester: `Invoke-TestSuite.Tests.ps1` and `Invoke-PesterSuite.Tests.ps1` dot-sourced before a forced PoshQC import (functions lost in PoshQC-hosted shards); `test-execution-command-form.Tests.ps1` had a case-folded name collision; `hook-command-consumers.Issue824.Tests.ps1` was order dependent (victim fixed with `Reset-EpicStateProbeModuleBinding`; the stranding comes from production hooks force-importing `WorktreeRunResolution`). One fix commit.
5. `scripts/dev-tools/run-poshqc-suite.ps1` measured 83.93% line; a busy-lock holder case was added (87.50%).

One PowerShell static run reported a PSScriptAnalyzer NullReferenceException on the first analyzed file (a tool error, no finding); the run was repeated with an analyzer warm-up call and reported 0 findings.

## Coverage (final pass)

Python (JSON report of the pytest stage):

| Module | Line | Branch |
|---|---|---|
| scripts/dev_tools/fix_all_runtime.py | 98.80% (82/83) | 95.45% (21/22) |
| scripts/dev_tools/fix_all_branches.py | 100.00% (111/111) | 100.00% (34/34) |
| scripts/dev_tools/fix_all_branches_extra.py | 100.00% (86/86) | 100.00% (24/24) |
| scripts/dev_tools/atomic_executor/qc_runner.py | 93.58% (102/109) | 81.82% (18/22) |
| scripts/dev_tools/atomic_executor/qc_runner_expectations.py | 100.00% (134/134) | 97.14% (68/70) |
| scripts/dev_tools/atomic_executor/cli_preflight.py | 100.00% (160/160) | 98.78% (81/82) |
| scripts/dev_tools/atomic_executor/cli_task_runtime.py | 98.84% (171/173) | 94.23% (49/52) |
| Total | 98.83% | 96.41% |

PowerShell (line, `artifacts/pester/powershell-coverage.xml`): repo-wide 95.91%; `.claude/hooks/test-execution-policy.ps1` 100.00%; `test-execution-lock-decision.ps1` 100.00%; `test-execution-lock.ps1` 86.96%; `test-execution-command-form.ps1` 96.74%; `enforce-test-execution-policy.ps1` 87.88%; `.codex/hooks` twins 100.00%, 100.00%, 95.65%, 96.74%, 98.54%; `Invoke-TestSuite.ps1` 89.90%; `Invoke-PesterSuite.ps1` 94.74%; `PoshQC.Testing.psm1` 94.17%; `PoshQC.Parallel.psm1` 97.40%; `scripts/dev-tools/run-poshqc-suite.ps1` 87.50%.

Lane exclusion reach: the four integration-named Pester files are absent from the merged JUnit; Jest ran 338 suites against 340 at the Phase 0 baseline.
