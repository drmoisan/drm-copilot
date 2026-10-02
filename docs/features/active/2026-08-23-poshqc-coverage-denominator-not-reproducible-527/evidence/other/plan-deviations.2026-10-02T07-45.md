# Plan Deviations Register

Timestamp: 2026-10-02T07-45
Command: git diff --stat 43e403a1 HEAD -- <plan-cited files>; git diff 43e403a1 HEAD -- scripts/powershell/PoshQC/settings/pester.runsettings.psd1; git diff -U0 43e403a1 HEAD -- .claude/hooks/enforce-powershell-batch-budget.ps1; Read tool on .gitignore lines 1-10; plus the per-entry commands below
EXIT_CODE: 0
Output Summary: named deviations from plan.2026-09-29T15-32.md recorded per task under the operator decision of 2026-10-01 (Option A) and the classification in `evidence/other/pwsh-task-classification.2026-10-02T07-50.md`. Of the plan-cited files checked for drift since plan commit 43e403a1, two changed (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `.claude/hooks/enforce-powershell-batch-budget.ps1`); all others are unchanged. Later execution segments append entries to this file.

## DEV-MERGE — origin/main merged before execution

- Task: all (execution base).
- Plan mechanism: the plan was authored and preflighted against plan commit 43e403a1.
- Replacement: origin/main 71f8dcb4 was merged into the branch as 8f0483ec before execution; the orchestrator's classification commit 589b51a3 sits on top (BASE_SHA, `evidence/baseline/base-ref.2026-10-02T07-45.md`). Issues #623, #743, and #744 had merged on main before 71f8dcb4.
- Line-citation drift check (`git diff --stat 43e403a1 HEAD -- <file>`; empty output = unchanged):

| File | Plan citations | Result since 43e403a1 |
| --- | --- | --- |
| `.gitignore` | line 6 (`/artifacts`) | unchanged; Read tool confirms line 6 is `/artifacts` and line 7 is `.agent_logs` |
| `scripts/powershell/PoshQC/PoshQC.Testing.psm1` | lines 211-214, 228-231, 290-292, 296-298, 308-312, 338-381, 394-398 | unchanged |
| `scripts/powershell/PoshQC/PoshQC.psm1` | lines 107-146 | unchanged |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | lines 23-325 (`CodeCoverage.Path` array) | **changed** (+16 lines, 0 removed): the array now spans lines 23-341 (opening `Path = @(` at line 23, closing `)` at line 341); file is 350 lines. Added entries: `.claude/hooks/enforce-batch-budget-route.ps1`, `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`, `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1`, `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`, `.codex/hooks/enforce-batch-budget-route.ps1`, `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, and the three `.claude/lib/parallel-drift/` files, with their comments. D5 removes the whole array, so P3-T6 must remove lines 23-341 (not 23-325). Not edited in this segment. |
| `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1` | lines 60-140 | unchanged |
| `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` | lines 621-622, 745-746 | unchanged |
| `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` | line 14 | unchanged |
| `scripts/powershell/PoshQC/README.md` | lines 68, 80 | unchanged |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | lines 277-297 | **changed** (substantial rewrite of the decision function). Current lines: out-of-root candidates are discarded without consuming a slot at lines 286-291 (plan: 277-282); a new large-path route exempts all files at lines 293-296; test-file classification `(^|/)tests/.*\.ps1$` or `\.Tests\.ps1$` is at line 299 and test files never count (plan: 284); the deny of a production file once the counted set reaches `prodCap` is at lines 309-316 (plan: 293-297, "fourth distinct file of a kind"). Under the current hook only production files count; `tests/fixtures/poshqc-consumer/scripts/Sample.psm1` (`.psm1`, so not matched by the `tests/.*\.ps1$` pattern) still counts as production and the two fixture `.ps1` files under `tests/` are test files. Not edited (outside the write set). |

## DEV-D10 — scratchpad `sh` fallback withdrawn

- Task: every task whose command or acceptance runs `pwsh`.
- Plan mechanism: D10, each rule body saved as a scratchpad `.ps1` and run with `pwsh -NoProfile -File`, with an `sh <scratchpad>/<name>.sh` wrapper where the Bash tool refuses `pwsh`.
- Replacement: none of these routes is used (operator decision 2026-10-01, Option A). Each affected task uses the replacement named in its own entry below.
- Evidence: `evidence/other/pwsh-task-classification.2026-10-02T07-50.md`.

## DEV-P0-T3 — rule LL

- Task: P0-T3.
- Plan mechanism: rule LL, `(Get-Content -LiteralPath $file).Count` in a `pwsh` child.
- Replacement: `git grep --untracked -c '' -- <six files>`.
- Evidence: `evidence/baseline/line-counts.2026-10-02T07-45.md`.

## DEV-P0-T4 — baseline full suite from CI

- Task: P0-T4.
- Plan mechanism: rule FR (args '.', 'baseline-run.log') then rule JX (args '.') locally.
- Replacement: CI run https://github.com/drmoisan/drm-copilot/actions/runs/36978425380, job https://github.com/drmoisan/drm-copilot/actions/runs/36978425380/job/110747263219 (push to main at 71f8dcb4, conclusion success); JUnit reduced with `poetry run python artifacts/ci/ci_evidence.py jx ...` (Python port of JX). The branch tree differs from 71f8dcb4 only under the feature folder.
- Evidence: `evidence/baseline/pwsh-full-suite.2026-10-02T07-45.md`.

## DEV-P0-T5 — baseline coverage from CI

- Task: P0-T5.
- Plan mechanism: rule CX (args '.', 'artifacts/pester/powershell-coverage.xml') on the P0-T4 local output.
- Replacement: the same CI run's powershell-coverage.xml reduced with `poetry run python artifacts/ci/ci_evidence.py cx ... <CI_ROOT>` (Python port of CX). Package-name shape observed from the CI XML (absolute forward-slash names under `<CI_ROOT>`), not from this machine.
- Evidence: `evidence/baseline/pwsh-coverage-baseline.2026-10-02T07-45.md`.

## DEV-P0-T6 — non-writing format baseline from CI; HS replaced

- Task: P0-T6.
- Plan mechanism: `Invoke-PoshQCFormat` with a no-op `-WriteFile` over five files in a `pwsh` child; rule HS before and after.
- Replacement: the CI `Invoke-PoshQCFormat -Root <CI_ROOT>` step of the same run (607 `Already formatted:` lines and 0 `Formatted:` lines in the step; the five files each have an `Already formatted:` line); WOULD_FORMAT=0. Rule HS replaced by `git hash-object` on the five files compared with `git ls-tree 71f8dcb4`; no local formatter ran, so no file could change.
- Evidence: `evidence/baseline/pwsh-format.2026-10-02T07-45.md`.

## DEV-P0-T7 — analyzer baseline from CI

- Task: P0-T7.
- Plan mechanism: `Invoke-PoshQCAnalyze -GetFileList` over four files in a `pwsh` child.
- Replacement: the CI `Invoke-PoshQCAnalyze -Root <CI_ROOT>` step over the whole repository (superset of the four files), which printed `PSScriptAnalyzer passed: no findings under <CI_ROOT>`.
- Evidence: `evidence/baseline/pwsh-analyze.2026-10-02T07-45.md`.

## DEV-P0-T8 — targeted PoshQC baseline from CI JUnit

- Task: P0-T8.
- Plan mechanism: rule TR (args 'tests/scripts/powershell/PoshQC', '') locally.
- Replacement: the same CI run's JUnit filtered to `tests/scripts/powershell/PoshQC` with `poetry run python artifacts/ci/ci_evidence.py tr ...`; FAILED_CONTAINERS (not printed by the filter) derived from the ten `testsuite` elements, each with errors="0" and failures="0".
- Evidence: `evidence/baseline/pwsh-poshqc-targeted.2026-10-02T07-45.md`.

## DEV-P1-T1 — Rule BR reset R1 performed without `pwsh`

- Task: P1-T1.
- Plan mechanism: Rule BR body run per D10 (`Get-ChildItem ... | Remove-Item` in a `pwsh` child).
- Replacement: orchestrator-performed deviation; `.claude/state/` inspected with `ls -la`. The orchestrator reported the directory absent at segment start; at reset time the executor observed it present and empty (created by the hook runtime during this segment). No `powershell-batch-budget.*.json` file existed, so nothing was deleted.
- Evidence: `evidence/other/batch-budget-resets.2026-10-02T07-55.md`.

## DEV-P1-T2 — fixture module acceptance through the MCP fixture test run

- Task: P1-T2.
- Plan mechanism: `pwsh -NoProfile -Command { Import-Module ./tests/fixtures/poshqc-consumer/scripts/Sample.psm1 -Force; Get-SampleGreeting -Name 'Ada' }` printing `Hello, Ada.`.
- Replacement: `mcp__drm-copilot__run_poshqc_test` with workspace_root = the fixture directory and scan_folders ["scripts","tests/scripts"]; the passing test case `returns a greeting for the supplied name` asserts `Get-SampleGreeting -Name 'Ada' | Should -Be 'Hello, Ada.'`.
- Evidence: `evidence/other/fixture-mcp-run.2026-10-02T07-55.md`.

## DEV-P1-T3 — fixture test acceptance through the MCP fixture test run

- Task: P1-T3.
- Plan mechanism: rule TR args 'tests/fixtures/poshqc-consumer/tests/scripts/Sample.Tests.ps1', 'returns a greeting for the supplied name'.
- Replacement: the same MCP run; the fixture JUnit shows the named test case Passed and the single testsuite with tests=1 errors=0 failures=0 skipped=0, giving PASSED=1 FAILED=0 SKIPPED=0 MISSING_REQUIRED=0 FAILED_CONTAINERS=0.
- Evidence: `evidence/other/fixture-mcp-run.2026-10-02T07-55.md`.

## DEV-P1-T4 — stand-in hook acceptance is an operator-run blocker

- Task: P1-T4.
- Plan mechanism: `pwsh -NoProfile -Command { . ./tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1; Test-StandInHookPayload }` printing `True`.
- Replacement: none available without `pwsh`. The file was created as specified; the acceptance command is left for the operator: `pwsh -NoProfile -Command ". ./tests/fixtures/poshqc-consumer/.claude/hooks/validate-bash.ps1; Test-StandInHookPayload"` (expected `True`). P1-T4 stays unchecked. Supporting observation only (not acceptance): the MCP fixture run's coverage XML lists `Test-StandInHookPayload` as a method of validate-bash.ps1 at line 24, so the file parsed and the function is defined.
- Evidence: `evidence/regression-testing/fail-first-fixture-check.2026-10-02T07-55.md` (supporting only).

## DEV-P1-T5 — fixture inventory by git and find; check-ignore form corrected

- Task: P1-T5.
- Plan mechanism: `pwsh` Get-ChildItem inventory plus `Test-Path` for `config`, and `git check-ignore -q <three paths>`.
- Replacement: `git status --porcelain --untracked-files=all -- tests/fixtures/poshqc-consumer`, `git ls-files -- tests/fixtures/poshqc-consumer`, `find tests/fixtures/poshqc-consumer -type f | sort`, `test -e tests/fixtures/poshqc-consumer/config`. The plan's `git check-ignore -q` with three paths exits 128 (`fatal: --quiet is only valid with a single pathname`), so it cannot produce the expected exit 1; the check was run without `-q` and exited 1 with no output.
- Evidence: `evidence/other/fixture-inventory.2026-10-02T07-55.md`.

## DEV-P1-ORDER — P1-T6 edit applied before P1-T5 inventory

- Task: P1-T5, P1-T6.
- Plan mechanism: P1-T5 then P1-T6.
- Replacement: the `.gitignore` edit of P1-T6 was applied immediately after P1-T4 and before the P1-T5 inventory, so that the MCP fixture run (which writes under tests/fixtures/poshqc-consumer/artifacts/) would produce ignored output. Both tasks' acceptance is unaffected: the inventory was captured before the MCP run and lists only the three fixture files.
- Evidence: `evidence/other/fixture-inventory.2026-10-02T07-55.md`, `evidence/other/fixture-ignore.2026-10-02T07-55.md`.

## DEV-P1-T7 — CR scan by `git ls-files --eol`

- Task: P1-T7.
- Plan mechanism: `pwsh` `[IO.File]::ReadAllText(...).Contains("`r")` per file.
- Replacement: `git ls-files --eol -- <three fixture files>` after staging; all report `i/lf w/lf`.
- Evidence: `evidence/other/fixture-eol.2026-10-02T07-55.md`.

## DEV-P2-T6 — pre-fix fixture run through MCP, executed in segment 1

- Task: P2-T6.
- Plan mechanism: rule FR args 'tests/fixtures/poshqc-consumer', 'fixture-run.log', '', 'scripts,tests/scripts' then rule JX, run in Phase 2.
- Replacement: the MCP fixture run (installed pre-fix PoshQC copy with its bundled allow-list, the #623 item 1 configuration); JX values read from the fixture JUnit. Executed during segment 1 (Phase 1) on orchestrator instruction, before Phase 2's other tasks; no Phase 2 production or test change exists yet, so the pre-fix state is the same. No run log is written by the MCP route.
- Evidence: `evidence/regression-testing/fail-first-fixture-run.2026-10-02T07-55.md`.

## DEV-P2-T7 — FX by inspection of the MCP coverage XML

- Task: P2-T7.
- Plan mechanism: rule FX args 'tests/fixtures/poshqc-consumer' in a `pwsh` child.
- Replacement: each FX field computed by reading the fixture `powershell-coverage.xml` with the Read tool; FX exit derived from the FX exit expression. Result SOURCEFILES=1 SAMPLE_PRESENT=0 SAMPLE_LINE_COVERED=0 STANDIN_PRESENT=1 CLAUDE_KEYS=1 OUTSIDE_PACKAGES=0, exit 1 (expected 1).
- Evidence: `evidence/regression-testing/fail-first-fixture-check.2026-10-02T07-55.md`.
