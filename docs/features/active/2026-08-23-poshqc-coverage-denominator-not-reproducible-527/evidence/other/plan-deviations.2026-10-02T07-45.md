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

## Segment 2 entries (2026-10-02T08-05)

## DEV-BR — Rule BR resets R2 to R5 not performed

- Task: P2-T1, P3-T1, P3-T5, P4-T3.
- Plan mechanism: Rule BR deletes `.claude/state/powershell-batch-budget.*.json` before each batch.
- Replacement: not performed. `.claude/hooks/enforce-powershell-batch-budget.ps1` on the current base exempts the orchestrated large route at lines 293-296 (`if ($LargePathRoute) { ... allow ... }`), the orchestrator checkpoint carries `route_id` `large`, and test files are never counted (line 299). `.claude/state/` was inspected with `ls -la` and held no `powershell-batch-budget.*.json` file. One line per reset ID is appended to the batch-budget-resets file stating that no state file was deleted.
- Evidence: `evidence/other/batch-budget-resets.2026-10-02T07-55.md`.

## DEV-P2-T2 — rule LL and title check by git grep

- Task: P2-T2.
- Plan mechanism: rule LL (`(Get-Content -LiteralPath $file).Count` in a `pwsh` child) and a verbatim-title check.
- Replacement: `git grep --untracked -c '' -- tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1` printed 405 (at or under 500); `git grep --untracked -c -F` with the thirteen `It` titles and the two `Describe` titles as fixed-string patterns printed 15 (one line per title); `git grep --untracked -n -i -E 'TestDrive|New-TemporaryFile|GetTempFileName|GetTempPath|env:TEMP|env:TMP'` exited 1 (no D13 token present).
- Evidence: this entry (command output recorded above).

## DEV-P2-T3 — rule LL and title check by git grep

- Task: P2-T3.
- Plan mechanism: rule LL and a verbatim-title check.
- Replacement: `git grep --untracked -c '' -- tests/scripts/powershell/PoshQC/PoshQC.CoverageConfig.Tests.ps1` printed 253; `git grep --untracked -c -F` with the ten `It` titles (C3 as its unexpanded template title) and the two `Describe` titles printed 12; `git grep --untracked -c -E` over the eight `@{ Case = '<name>';` rows printed 8; the D13 token scan exited 1.
- Evidence: this entry.

## DEV-TOOLCHAIN-P2 — MCP format and analyze before the Phase 2 commit

- Task: Phase 2 commit point (no plan task; micro-action).
- Plan mechanism: the MCP route-compliance calls are scheduled at P5-T11 to P5-T13.
- Replacement: the CI `poshqc / PowerShell QC` job runs Format, then Analyze, then Test, and stops at the first failing step, so a formatter rewrite or analyzer finding on the Phase 2 head would prevent the P2-T4/P2-T5 CI evidence. `mcp__drm-copilot__run_poshqc_format` and `mcp__drm-copilot__run_poshqc_analyze` were called with `workspace_root` = the worktree root and `scan_folders` `["tests/scripts/powershell/PoshQC"]` before the commit. Both returned `ok: true` with only the fixed summary string. The formatter changed no file: `git status --porcelain --untracked-files=all` listed only the two new test files and two feature-folder files, and the modification times of the two new test files equal their Write times. These calls ran the installed extension copy and are not acceptance evidence (D10); the CI Format and Analyze steps on the pushed head are the gates.
- Evidence: this entry.

## DEV-P3-T2 — parse check left to CI

- Task: P3-T2.
- Plan mechanism: `[System.Management.Automation.Language.Parser]::ParseFile(...)` in a `pwsh` child printing `PARSE_ERRORS=0`.
- Replacement: CI-evidence deviation (classification row P3-T2). `PoshQC.psm1` throws on any sub-module parse error at import, so a CI run in which the PoshQC suites pass proves `PARSE_ERRORS=0`. P3-T2 stays unchecked until the orchestrator records that run. The file was written in full; it contains only the four D1 function definitions with comment-based help, `[CmdletBinding()]`, and `[OutputType()]`.
- Evidence: pending (orchestrator CI run on PHASE3_SHA or later).

## DEV-P3-T3 — Select-String count by git grep

- Task: P3-T3.
- Plan mechanism: `@(Select-String -LiteralPath scripts/powershell/PoshQC/PoshQC.psm1 -SimpleMatch -Pattern "'PoshQC.Coverage.psm1',").Count`.
- Replacement: `git grep --untracked -c -F -e "'PoshQC.Coverage.psm1'," -- scripts/powershell/PoshQC/PoshQC.psm1` printed 1.
- Evidence: this entry.

## DEV-P3-T4 — rule LL and Select-String counts by git grep

- Task: P3-T4.
- Plan mechanism: rule LL and two `Select-String -SimpleMatch` counts.
- Replacement: `git grep --untracked -c '' -- scripts/powershell/PoshQC/PoshQC.Testing.psm1` printed 460 (at or under 500); `git grep --untracked -c -F -e 'ResolveCoveragePopulation'` printed 3 (help entry, parameter, invocation); `git grep --untracked -c -F -e 'Code coverage population: source='` printed 1. The current variable holding the effective scan-folder roots in `Invoke-PoshQCTest` is `$effectiveScanFolders` (unchanged name), so the D3 (c) invocation is used verbatim.
- Evidence: this entry.

## DEV-P3-T6 — Path array span and key-set check by Read

- Task: P3-T6.
- Plan mechanism: delete current lines 23-325 and verify with `Import-PowerShellDataFile` in a `pwsh` child (`HAS_PATH=False`, `KEYS=CoveragePercentTarget,Enabled,OutputFormat,OutputPath`).
- Replacement: the `CodeCoverage.Path` array spans lines 23-341 on the current base (16 entries added on main by #743/#744; see DEV-MERGE); lines 23-341 were removed and the two D5 comment lines added after `OutputPath`. `git diff --stat HEAD -- scripts/powershell/PoshQC/settings/pester.runsettings.psd1` reported `2 insertions(+), 319 deletions(-)`; the trailing bytes of the file are unchanged. The `CodeCoverage` block was read with the Read tool: its keys are `Enabled`, `OutputFormat`, `OutputPath`, `CoveragePercentTarget` (sorted: `CoveragePercentTarget,Enabled,OutputFormat,OutputPath`) and no `Path` key is present. The CI run that loads this settings file is the parse proof.
- Evidence: this entry.

## DEV-P3-T7 — JSON check by Read and Python parse

- Task: P3-T7.
- Plan mechanism: `ConvertFrom-Json` in a `pwsh` child printing `VERSION=1 ROOTS=...`.
- Replacement: the file was read with the Read tool and matches the D6 document (two-space indentation, one root per line, trailing newline); `git ls-files --eol` reports `w/lf`; a single-line `poetry run python -c` JSON parse printed `VERSION=1 ROOTS=.claude/hooks,.claude/lib,.codex/hooks,.codex/scripts,scripts`. `git hash-object config/poshqc-coverage.json` = `71d9bfcc52a93df274d0eb5cf8fcf12b667c78e3`.
- Evidence: this entry.

## DEV-P3-T8 — module surface split into a static half and a CI half

- Task: P3-T8.
- Plan mechanism: import the module in a `pwsh` child and print `EXPORTED=0` and `DEFINED=4`.
- Replacement: `EXPORTED=0` established by `git grep` (no internal name in `PoshQC.psm1` or `PoshQC.psd1`); `DEFINED=4` is a CI-evidence deviation. P3-T8 stays unchecked until the CI half is recorded.
- Evidence: `evidence/other/module-surface.2026-10-02T08-30.md`.

## DEV-TOOLCHAIN-P3 — MCP format and analyze before the Phase 3 commit

- Task: Phase 3 commit point (micro-action; same rationale as DEV-TOOLCHAIN-P2).
- Replacement: `mcp__drm-copilot__run_poshqc_format` and `mcp__drm-copilot__run_poshqc_analyze` with `scan_folders` `["scripts/powershell/PoshQC","tests/scripts/powershell/PoshQC"]`; both returned `ok: true`. `git hash-object` of `PoshQC.Coverage.psm1` (`23cd722f`), `PoshQC.Testing.psm1` (`8a3d6acf`), `PoshQC.psm1` (`2ce1628f`), and `settings/pester.runsettings.psd1` (`b7abb1a7`) was identical before and after the format call. Not acceptance evidence (D10).
- Evidence: this entry.

## DEV-P4-TR — Phase 4 targeted runs from CI

- Task: P4-T1, P4-T2, P4-T4 (TR acceptance), P4-T5 (TR acceptance), P4-T6.
- Plan mechanism: rule TR in a `pwsh` child.
- Replacement: CI-evidence deviation (classification row P4-T1 et al.). P4-T2 uses the CI run on PHASE3_SHA `94853dca5206bf1276ab91a0df958613ff326207` (fix present, no Phase 4 adaptation); P4-T1, P4-T4, P4-T5, and P4-T6 use the CI run on the Phase 4/5 head. All five tasks stay unchecked until the orchestrator records those runs.
- Evidence: pending.

## DEV-P4-T4 — edit location and line count

- Task: P4-T4.
- Plan mechanism: add `-ResolveCoveragePopulation { ... }` to the two D14 calls and set `$fixedMessageCount = 5` with an explanatory comment.
- Replacement: none for the edit; the seam argument was inserted on the existing `-ResolveScanConfig { @() } ... -EnumerateTests {` line of each call (lines 76 and 119), so no continuation line was added. The comment above `$fixedMessageCount` grew by one line, so the file is 142 lines (P0-T3 baseline 141; the plan sets no line-neutral condition for this file). `git diff -U0 HEAD` shows only lines 76, 119, and 136-138 changed.
- Evidence: this entry.

## DEV-P4-T5 — LL by git grep; anchored replacement

- Task: P4-T5.
- Plan mechanism: rule LL compared with the P0-T3 baseline.
- Replacement: `git grep -c '' -- tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` printed 766, equal to the P0-T3 baseline 766. The identical two-line pair also exists at lines 394-395 (test 'Should handle no test files gracefully', which the plan does not name); the replacement was anchored on the preceding `Mock -CommandName New-Item -MockWith { }` line, which precedes only the lines 621-622 and 745-746 occurrences, and `git diff -U0 HEAD` confirms that only lines 621-622 and 745-746 changed.
- Evidence: this entry.

## DEV-TOOLCHAIN-P4 — MCP format and analyze before the Phase 4 commit

- Task: Phase 4 commit point (micro-action; same rationale as DEV-TOOLCHAIN-P2).
- Replacement: `mcp__drm-copilot__run_poshqc_format` and `mcp__drm-copilot__run_poshqc_analyze` with `scan_folders` `["tests/scripts/powershell/PoshQC"]`; both returned `ok: true`; `git hash-object` of `PoshQC.Comprehensive.Tests.ps1` (`c27d726c`) and `PoshQC.TestingInvokeSummary.Tests.ps1` (`bda2eefd`) was identical before and after. Not acceptance evidence (D10).
- Evidence: this entry.

## DEV-P5-T1 — README token counts by git grep

- Task: P5-T1.
- Plan mechanism: `Select-String -SimpleMatch` counts.
- Replacement: `git grep -c -F -e <token> -- scripts/powershell/PoshQC/README.md` printed `poshqc-coverage.json` 3, `fallback` 1, `*.Tests.ps1` 1, `DefaultExcludedDirs` 1, `source=` 1; for `src/**/*.ps1` it printed nothing and exited 1 (count 0).
- Evidence: this entry.

## DEV-P5-MIRROR — mirrors by git blob copy; HS by git hash-object

- Task: P5-T2 to P5-T6.
- Plan mechanism: `Copy-Item` in a `pwsh` child, then rule HS on both paths.
- Replacement: the README source was committed first (commit `9b5aa44e`), so every source was in `HEAD`; each mirror was written with `git -C <ROOT> show HEAD:<source> > <ROOT>/<mirror>` (no Write or Edit on a mirror). `git hash-object` on both paths gave equal values for all five pairs, and `cmp` on each pair reported no difference.
- Evidence: `evidence/other/mirror-copy.2026-10-02T08-50.md`.

## DEV-P5-T7 — literal BASE_SHA

- Task: P5-T7.
- Plan mechanism: `$base` read from the base-ref artifact by a scratchpad PowerShell script.
- Replacement: the literal `589b51a30d856dca973a2ed9988f9443c35339cf` from `evidence/baseline/base-ref.2026-10-02T07-45.md` was substituted into the `git diff --exit-code` command (the BASE rule permits literal substitution for `git` commands run through the Bash tool).
- Evidence: `evidence/other/manifest-unchanged.2026-10-02T08-50.md`.

## DEV-P5-T8 / DEV-P5-T10 — Select-String counts by git grep

- Task: P5-T8, P5-T10.
- Plan mechanism: `Select-String -SimpleMatch` counts.
- Replacement: `git grep -c -F` printed 1 for `"scripts/powershell/PoshQC/PoshQC.Coverage.psm1",` in the parity test, and 1 each for `Superseded by #527` and `## Disposition` in the potential entry.
- Evidence: this entry.

## DEV-P5-T9 — pytest from the worktree without a cd

- Task: P5-T9.
- Plan mechanism: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py` from the repository root.
- Replacement: `poetry -C <ROOT> run pytest <ROOT>/tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (same test, absolute path; the session runs no `cd`). Result `1 passed`.
- Evidence: `evidence/regression-testing/parity-after-mirror.2026-10-02T08-55.md`.

## DEV-P5-HS — rule HS replaced by git hash-object around the MCP format call

- Task: P5-T11.
- Plan mechanism: rule HS (`Get-FileHash` SHA256) over the eleven `CHANGED_PS` paths before and after the call.
- Replacement: `git hash-object` over the same eleven paths before and after; all eleven values were identical.
- Evidence: `evidence/other/mcp-route-compliance.2026-10-02T09-00.md`.
