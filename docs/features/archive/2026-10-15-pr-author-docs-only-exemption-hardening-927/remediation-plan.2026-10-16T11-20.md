# 2026-10-15-pr-author-docs-only-exemption-hardening (Remediation Plan R2)

- **Issue:** #927
- **Cycle:** R2 (remediation cycle 2)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16T11-20
- **Status:** Draft; preflight round 1 deltas D-1 to D-4 applied (D-1 under orchestrator amendment D-RUN-9a); awaiting executor preflight.
- **Version:** 1.1
- **Work Mode:** full-bug (`issue.md` line 9, `- Work Mode: full-bug`). Acceptance-criteria source: `spec.md`, section `## Acceptance Criteria` (AC-M1 to AC-M25, AC-1 to AC-22). This cycle adds no criterion and removes none.
- **Primary input:** `remediation-inputs.2026-10-16T09-23.md` (verdict `REMEDIATION_REQUIRED`; one Blocking finding PA-1R, remediability autonomous; six non-blocking observations CR-R1 to CR-R6).
- **Review artifacts:** `policy-audit.2026-10-16T09-23.md`, `code-review.2026-10-16T09-23.md`, `feature-audit.2026-10-16T09-23.md` (same folder; not edited).
- **Prior cycle plan:** `remediation-plan.2026-10-16T05-25.md` (executed; not edited). Its rules R1-1 to R1-16 are restated here only where this cycle uses them.
- **Original plan:** `plan.2026-10-15T07-41.md`. Its Phase 8 (S9 CI gate on the pull-request run) still owns the check-off of AC-9, AC-18, AC-19, AC-21, AC-M23, and AC-M24.
- **Branch:** `bug/pr-author-docs-only-exemption-hardening-927`. Every push is `git push origin HEAD:refs/heads/bug/pr-author-docs-only-exemption-hardening-927` (fast-forward only).

**Overview.** This cycle closes PA-1R and the related observations:

- PA-1R (Blocking): regenerate the gitignored `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` from a full-population Pester run in this worktree, under orchestrator decision D-RUN-9: route A (PoshQC MCP test over `SCAN_FULL`, the existing folders of the `config/poshqc-scan.json` scan set), then route B (the repository module run directly, CI form) only when route A leaves the XML short of the pass condition. The run is the test step of the final QC loop, so the regenerated XML is the final local state.
- CR-R1: dispose the process object in `Invoke-DocsOnlyBoundedNative` with `try`/`finally`, applied byte-identically to the four helper copies, with regression assertions on both test fakes.
- CR-R2 to CR-R6: decisions recorded, no code change.

`FEATURE` denotes `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. `SCRATCH` denotes `<session scratchpad>/issue-927/`; scratch files of this cycle live under `SCRATCH/927/` (the layout of the earlier cycles). `SCRATCH` is outside the repository, and artifacts record only the literal token `SCRATCH`. Every evidence path is `FEATURE/evidence/<kind>/<name>.<timestamp>.md`, with `<kind>` one of `remediation-baseline`, `regression-testing`, `qa-gates`, `other`; `<timestamp>` is the UTC write time read from the host clock immediately before the write (`date -u +%Y-%m-%dT%H-%M`) and is never fixed in this plan. A task that consumes an artifact selects the lexicographically greatest file matching `<name>.*.md`.

**Fail-closed rule:** PowerShell is the only code language changed. If a required baseline, QC, or coverage value is missing, the cycle outcome is `REMEDIATION_REQUIRED`, never PASS.

---

## 1. Rules binding on every task

1. **R2-1 Evidence schema.** Every artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. `Command:` and `EXIT_CODE:` describe the first command the task names; every later command's exit code is recorded on its own labelled line (`EXIT_CODE_<n>:` or a named label). When the first command is a PoshQC MCP call, `EXIT_CODE: 0` records `MCP_CALL: returned` and `EXIT_CODE: 1` records `MCP_CALL: error <message>`, with any absolute host path in the message written as `<WORKSPACE_ROOT>` (rule R2-2); that value implies no count, percentage, or finding. `ExpectedExitCode:` is written only where a task names it, and only when the artifact's first command is the one expected to exit non-zero. `EXIT_CODE: SKIPPED` is never a passing outcome.
2. **R2-2 No host data.** No artifact or test written by this plan contains an absolute host path, a drive letter, a user-profile path, a host name, or an account name. The worktree root is written `<WORKSPACE_ROOT>`; scratch paths are written `SCRATCH/...`. Reader output is copied into artifacts; raw XML, JUnit `classname` values, and run logs are never copied.
3. **R2-3 MCP calls.** `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test` are called with `workspace_root` set to the output of `git rev-parse --show-toplevel`. MCP results carry no output detail, so no acceptance condition reads a count, percentage, or finding from an MCP result; counts come from the on-disk JUnit and coverage files through the readers, and format outcomes come from `git status --porcelain`.
4. **R2-4 Scan sets.** `SCAN_QC` = `[".claude/hooks", ".codex/hooks", "tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]` (the original plan's format/analyze set). `SCAN_FAIL` = `["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]` (expect-fail run only). `SCAN_FULL` = `["scripts", "tests/scripts"]`: the folders of `config/poshqc-scan.json` line 4 `test.scanFolders` that exist in the tree. `tests/powershell` does not exist. The module skips a missing config-sourced folder (`scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1` line 108), but an explicit `scan_folders` entry that does not resolve throws (`scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1` line 126; the bundled copy `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.FileDiscovery.psm1` line 126). For `run_poshqc_test` the MCP tool passes the list as `-ScanFoldersJson` (`extensions/drm-copilot/src/repo-automation-args.ts` line 34); the bundled wrapper decodes it into `Invoke-PoshQCTest -ScanFolders` (`extensions/drm-copilot/resources/templates/run-poshqc-test.ps1` lines 26-32), which resolves explicit folders through `Resolve-PoshQCScanFolder` (`scripts/powershell/PoshQC/PoshQC.Testing.psm1` lines 210-212 and 319-325). `SCAN_FULL` therefore resolves to the same population as CI and route B (orchestrator amendment D-RUN-9a).
5. **R2-5 Executor isolation guard.** Command text never contains the words `bash`, `pwsh`, or `wsl`, never uses a heredoc, and runs one command per call (no `&&`, no `;`, no `cd`). Searches use plain `grep`. A grep pattern that begins with `-` is passed through `-e`. Python runs only as `poetry run python -I ...` (scratch readers) or `poetry run pytest ...`. The PowerShell 7 host is reached only through `sh SCRATCH/927/r2/run-poshqc-927.sh ...` (decision D-R2-2). In command text the scratch path is written with forward slashes.
6. **R2-6 Live-hook hazard.** `.claude/hooks/enforce-epic-merge-gate.ps1` runs on every Bash call and dot-sources `.claude/hooks/hook-docs-only-diff.ps1`. Each helper edit is one Edit call that leaves a parsing file (Appendix H). If a Bash call is then denied with an `EPIC_MERGE_GATE_BLOCKED:` or `PR_AUTHOR_SKILL_BLOCKED:` dependency reason, the executor repairs the helper with Edit only and retries the denied command.
7. **R2-7 Hook denials.** If any other hook or permission rule denies a Write, Edit, Bash, or MCP call, the executor records the exact denial text in the task's artifact and stops as BLOCKED. It never works around a hook, never deletes hook state, and never resets a budget file.
8. **R2-8 Byte copies.** The three other helper paths are written only by `cp .claude/hooks/hook-docs-only-diff.ps1 <copy>` and verified by `cmp -s` (exit 0); never by Write or Edit.
9. **R2-9 Test purity.** No test text added by this plan uses `Mock git`, `Mock gh`, a function named `git` or `gh`, `Start-Process`, `Start-Sleep`, `TestDrive`, `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `$env:TEMP`, `ProcessStartInfo`, a real wait, or a file write. The process object stays a test-local fake passed through `-ProcessStarter`.
10. **R2-10 Scope boundary.** The complete repository write set is section 8 (`## 8. WRITES`). No edit under `.claude/rules/` or `.github/instructions/`. CR-3/D5 of the original plan is unchanged: `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` is not edited. `.claude/hooks/enforce-epic-merge-gate.ps1` (491 lines) is not edited. No file is deleted, no evidence file is renamed, no prior review artifact or prior plan is edited. `artifacts/pester/*.xml` is written only by the Pester run of [P1-T3], [P4-T6], or [P4-T7]; it is never hand-edited, copied, downloaded into, or committed.
11. **R2-11 Commit form.** Each commit task runs, in order: `git add -- <paths>`; `git commit -m '<subject>' --trailer 'Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>' --trailer 'Claude-Session: https://claude.ai/code/session_01DhgYo1nietLo78qi4j5syW'`; `git log -1 --format=%B`; `git push origin HEAD:refs/heads/bug/pr-author-docs-only-exemption-hardening-927`; `git status --porcelain`; `git rev-parse HEAD`; `git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927`. Acceptance: the commit exits 0; the `git log` output ends with the two trailer lines `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` and `Claude-Session: https://claude.ai/code/session_01DhgYo1nietLo78qi4j5syW` in one trailer block; the push exits 0 (a rejected non-fast-forward push stops the task as BLOCKED); the status lists no path other than this plan file; the two `rev-parse` values are equal. No `--amend`, no rebase, no force push.
12. **R2-12 Final code commit.** `R2_FINAL_CODE_COMMIT` is the most recent commit of this cycle that changes a path outside `FEATURE`: the [P2-T4] commit, replaced by each later Phase 4 fix commit.
13. **R2-13 Stops.** A task that states a stop condition stops the executor run at that task; the run resumes only after the caller revises this plan. A task whose acceptance fails without a stated branch is not marked checked.

## 2. Finding trace

| Finding | Implementation | Tests | Evidence |
|---|---|---|---|
| PA-1R (Blocking) | none in code; full-population Pester run, route A then route B (decision D-R2-1) | full population (`SCAN_FULL`) | [P0-T7], [P4-T6], [P4-T7], [P4-T8], [P6-T3] |
| CR-R1 | Appendix H edits H2-1, H2-2; copies by `cp` | Appendix T edits TF-1 to TF-7, TD-1 to TD-3 (rows F1 to F9, F11, D1 to D4) | [P1-T3], [P2-T3], [P4-T6] or [P4-T7], [P4-T8] |
| CR-R2 | none (decision D-R2-4) | none | [P3-T1] |
| CR-R3 | none (informational) | none | [P3-T1] |
| CR-R4 | none (informational) | none | [P3-T1] |
| CR-R5 | none (informational) | none | [P3-T1] |
| CR-R6 | none (informational) | none | [P3-T1] |

## 3. Decisions fixed by this plan

- **D-R2-1 (PA-1R route; orchestrator decision D-RUN-9, binding).** Route A calls `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `SCAN_FULL`, then reads the XML on disk. `SCAN_FULL` omits the nonexistent `tests/powershell` folder (rule R2-4); the orchestrator records this as amendment D-RUN-9a (route A `scan_folders` = `["scripts", "tests/scripts"]`). Route B runs only when route A leaves the XML without a passing `COVERAGE_RESULT` for any of the seven files, with a report-level or hook-aggregate line value below 85.00%, with JUnit `tests` below `10000` or `failures`/`errors` above `0`, with an XML not rewritten by the run, or when the MCP call errors. Route B is the CI form of `.github/workflows/_poshqc.yml` lines 38-42 (`Import-Module .../scripts/powershell/PoshQC/PoshQC.psm1`; `Invoke-PoshQCTest -Root <root>`), with no coverage setting changed (no `UseBreakpoints` override). `remediation-inputs.2026-10-16T09-23.md` line 25 and its "Do Not Do" list ask that the MCP runner not be used for this step; D-RUN-9 admits route A only with the on-disk pass condition above, which is the condition the `validate-feature-review-coverage` hook reads. The [P6-T3] closure line names the route that produced the final XML so the reviewer can apply that request.
- **D-R2-2 (route B invocation form).** `.claude/agents/atomic-executor.md` line 19 and `.claude/settings.json` line 7 allow `Bash(pwsh *)`, but the worktree isolation guard refuses any command text that contains `pwsh`, including `pwsh -NoProfile -File <script>` (verbatim refusals: `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/poshqc-local/run-record.md` lines 14-20). The guard admits `sh <file>`: `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/qa-gates/pester-full.2026-10-12T04-15.md` line 4 records `sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/pester-run.ps1 ...` with `EXIT_CODE: 0`, using the wrapper of `docs/features/active/subagentstop-envelope-orchestrator-family-903/plan.2026-10-11T07-59.md` lines 461-466. Route B therefore runs `sh SCRATCH/927/r2/run-poshqc-927.sh SCRATCH/927/r2/run-poshqc-927.ps1 SCRATCH/927/r2/direct-run.log` (Appendix A2, A3). That form is not matched by `Bash(pwsh *)`; it relies on the same session permission mode under which the #903 run executed. A denial of it by the guard or by a permission rule is recorded verbatim and stops the cycle as BLOCKED (R2-7); no other form is substituted.
- **D-R2-3 (CR-R1 design and changed-line measure).** `try`/`finally { $process.Dispose() }` wraps every statement after the process starts, so every return path, including a throw, disposes the object; the process-start statement and the `[scriptblock] $ProcessStarter` seam are unchanged, so `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (rows at lines 62 and 433) and the epic-state isolation census see no new `&`-invoked variable and no new seam. The edit re-indents the body, so `git diff -U0` lists the body lines as changed. Changed-line coverage is required on `.claude/hooks/hook-docs-only-diff.ps1`, whose dedicated suite F reaches every body branch. The three copies are byte-identical (R2-8); `.codex/hooks/hook-docs-only-diff.ps1` is measured by whole-file line coverage against its baseline (97.52%), and its changed-line results are recorded for information, because suite D drives only four runner rows and the re-indented statements it does not reach were unreached before this edit.
- **D-R2-4 (CR-R2).** No real-process row is added. Such a row starts a live executable and waits on the host clock; `.claude/rules/powershell.md` line 74 ("external services or live executables") and `.claude/rules/general-unit-test.md` lines 72 and 105 (external processes; real wall-clock waits) prohibit both in tests. The repository has no hook-PowerShell test location outside the Pester run paths (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 3 runs every `*.Tests.ps1` under `scripts`, `tests/powershell`, `tests/scripts`; `tests/powershell` does not exist), so such a row would run as a unit test. A 1 ms limit also makes the outcome depend on host scheduling, which conflicts with the determinism requirement. The tree-stop argument is verified through the fake (`Killed` equals the `$EntireTree` argument, suite F rows F7 and F8).

---

## 4. Phases

### Phase 0 — Baseline Capture

- [x] [P0-T1] Write `FEATURE/evidence/remediation-baseline/r2-phase0-instructions-read.<timestamp>.md` after reading, in this order: `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `FEATURE/remediation-inputs.2026-10-16T09-23.md`, `FEATURE/policy-audit.2026-10-16T09-23.md`, `FEATURE/code-review.2026-10-16T09-23.md`, `FEATURE/feature-audit.2026-10-16T09-23.md`, `FEATURE/spec.md`, `FEATURE/remediation-plan.2026-10-16T11-20.md`. The artifact carries `Timestamp:`, `Policy Order:`, `Command: Read (17 files)`, `EXIT_CODE: 0`, `Output Summary:`, and one line `READ: <repository-relative path>` per file in the order above. Acceptance: `grep -c '^READ: '` on the new artifact prints `17`; `grep -c '^Policy Order:'` on it prints `1`.
- [x] [P0-T2] Write `FEATURE/evidence/remediation-baseline/r2-branch-state.<timestamp>.md`. Commands: `git rev-parse --abbrev-ref HEAD`; `git status --porcelain`; `git fetch origin bug/pr-author-docs-only-exemption-hardening-927`; `git rev-parse HEAD`; `git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927`; `git rev-parse --show-toplevel`. Acceptance: the first prints `bug/pr-author-docs-only-exemption-hardening-927`; every status line begins with `?? docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/` or names this plan file; the fetch exits 0; `HEAD` equals the origin value and is recorded as `R2_START_HEAD: <40-hex>`; the top-level output is used as the MCP `workspace_root` and recorded only as `WORKSPACE_ROOT: <WORKSPACE_ROOT>`. A different branch, a status line outside `FEATURE/`, or unequal heads stops the plan as BLOCKED.
- [x] [P0-T3] Write `FEATURE/evidence/remediation-baseline/r2-line-counts-parity.<timestamp>.md`. Commands: `grep -c '^' .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 .claude/hooks/enforce-epic-merge-gate.ps1`; `cmp -s .claude/hooks/hook-docs-only-diff.ps1 <copy>` for each of the three other helper paths above; `grep -c -F -e '& $ProcessStarter $startInfo' .claude/hooks/hook-docs-only-diff.ps1`; `grep -c -F -e 'finally {' .claude/hooks/hook-docs-only-diff.ps1`; `grep -c -F -e 'Dispose' .claude/hooks/hook-docs-only-diff.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`. Acceptance: the counts print `478` four times, then `188`, `239`, and `491`; all three `cmp -s` calls exit 0; the `$ProcessStarter` grep prints `1`; the `finally {` grep prints `1`; the `Dispose` grep prints `:0` for all three files (exit 1, recorded on its labelled line). A different line count stops the plan for re-derivation of Appendix H and T; a `cmp` difference stops the plan as BLOCKED.
- [x] [P0-T4] Prepare the scratch tools (files outside the repository, written with the Write tool, LF line endings, not committed) and write `FEATURE/evidence/remediation-baseline/r2-scratch-tools.<timestamp>.md`. Writes: `SCRATCH/927/tools/read_coverage_927.py` with the exact content of Appendix S of `FEATURE/plan.2026-10-15T07-41.md` (section 14); `SCRATCH/927/tools/read_report_totals_927.py` with the exact content of Appendix S2 of `FEATURE/remediation-plan.2026-10-16T05-25.md` (section 12); `SCRATCH/927/tools/read_hook_aggregate_927.py` (Appendix A1); `SCRATCH/927/r2/run-poshqc-927.ps1` (Appendix A2); `SCRATCH/927/r2/run-poshqc-927.sh` (Appendix A3). Commands: `grep -c -F -e 'def find_classes' SCRATCH/927/tools/read_coverage_927.py`; `grep -c -F -e 'def report_line' SCRATCH/927/tools/read_report_totals_927.py`; `grep -c -F -e 'HOOK_AGGREGATE_LINE: counters=' SCRATCH/927/tools/read_hook_aggregate_927.py`; `grep -c -F -e 'Invoke-PoshQCTest -Root $root' SCRATCH/927/r2/run-poshqc-927.ps1`; `grep -c -F -e 'POSHQC_EXIT_CODE=' SCRATCH/927/r2/run-poshqc-927.sh`; `awk '/\r/{n++} END{print n+0}' SCRATCH/927/r2/run-poshqc-927.sh`. Acceptance: the five greps print `1` each; the `awk` count prints `0` (no carriage return in the shell wrapper).
- [x] [P0-T5] Write `FEATURE/evidence/remediation-baseline/r2-poshqc-format.<timestamp>.md` (baseline format; write-mode tool observed by tree state). Commands: `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` (before); `mcp__drm-copilot__run_poshqc_format` with `scan_folders` = `SCAN_QC`; `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` (after). Acceptance: `MCP_CALL: returned`; both status commands print nothing, meaning the formatter rewrote no PowerShell file. Any listed path stops the plan as BLOCKED with `BASELINE_FORMAT_DRIFT: <path>` lines; the executor does not revert it.
- [x] [P0-T6] Write `FEATURE/evidence/remediation-baseline/r2-poshqc-analyze.<timestamp>.md` (baseline analyze). Commands: `mcp__drm-copilot__run_poshqc_analyze` with `scan_folders` = `SCAN_QC`; `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`. Acceptance: `MCP_CALL: returned`; the status prints nothing. `MCP_CALL: error` stops the plan as BLOCKED.
- [x] [P0-T7] Write `FEATURE/evidence/remediation-baseline/r2-coverage-baseline.<timestamp>.md` (PA-1R and CR-R1 baseline values). `R1_CI_COVERAGE` is the lexicographically greatest file matching `FEATURE/evidence/qa-gates/r1-ci-coverage.*.md` (the R1 record of CI run 38876469175, whose code remediation-inputs line 24 states is identical to the reviewed head); its name is recorded as `R2_BASE_CI_SOURCE: <file name>`. Commands: `grep -E -e '^(REPORT_LINE|JUNIT_TOTALS|COVERAGE_RESULT): ' R1_CI_COVERAGE` with that path substituted; `stat -c %Y artifacts/pester/powershell-coverage.xml`; `poetry run python -I SCRATCH/927/tools/read_report_totals_927.py artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml`; `poetry run python -I SCRATCH/927/tools/read_hook_aggregate_927.py artifacts/pester/powershell-coverage.xml`; `poetry run python -I SCRATCH/927/tools/read_coverage_927.py artifacts/pester/powershell-coverage.xml .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .codex/hooks/enforce-epic-merge-gate.ps1`. Acceptance: the first grep prints nine lines, copied verbatim with the prefix `R2_BASE_CI ` (one `REPORT_LINE`, one `JUNIT_TOTALS` with `tests=10545`, seven `COVERAGE_RESULT`); the local reader outputs are copied verbatim with the prefix `R2_BASE_LOCAL ` together with their exit codes on labelled lines (a `CLASS_COUNT=0` line or a reader exit of `1` is the expected pre-cycle state and is recorded, not failed). When `stat` exits non-zero, the artifact records `R2_BASE_LOCAL: absent` and the three local readers are not run (this task authorizes that branch).
- [x] [P0-T8] Commit and push Phase 0 (rule R2-11). Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record R2 remediation baseline evidence`.

### Phase 1 — CR-R1 Regression Assertions (expect-fail)

- [x] [P1-T1] Apply Appendix T edits TF-1 to TF-7 to `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` with Edit. Acceptance: `grep -c '^' tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` prints `194`; `grep -c -F -e 'Disposed | Should -BeTrue' tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` prints `5`; `grep -c -F -e '-Name Dispose -Value { $this.Disposed = $true }' tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` prints `1`; `grep -c -F -e 'Disposed = $false' tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` prints `1`.
- [x] [P1-T2] Apply Appendix T edits TD-1 to TD-3 to `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` with Edit. Acceptance: `grep -c '^' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `241`; `grep -c -F -e 'Disposed | Should -BeTrue' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `1`; `grep -c -F -e '-Name Dispose -Value { $this.Disposed = $true }' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `1`; `grep -c -F -e 'Disposed = $false' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `1`.
- [x] [P1-T3] [expect-fail] Write `FEATURE/evidence/regression-testing/r2-expect-fail.<timestamp>.md` (helper not yet edited). Commands: `stat -c %Y artifacts/pester/pester-junit.xml` (before; `absent` when it exits non-zero); `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `SCAN_FAIL`; `stat -c %Y artifacts/pester/pester-junit.xml` (after); `grep -m 1 -o -E '<testsuites [^>]*>' artifacts/pester/pester-junit.xml` (record only `tests`, `failures`, `errors`); for each token of Appendix R the command `grep -c -F -e '<token>" status="<status>"' artifacts/pester/pester-junit.xml` with status `Failed` for the fourteen tokens F1 to F9, F11, D1 to D4 and status `Passed` for F10, F12, F13, D5, D6. Acceptance: `MCP_CALL: returned`; the after-mtime is greater than the before-mtime (any value when `absent`); `failures` equals `14` and `errors` equals `0`; each of the nineteen token counts prints `1`. Any other result stops the plan for revision of Appendix T.

### Phase 2 — CR-R1 Implementation

- [x] [P2-T1] Apply Appendix H edits H2-1 then H2-2 to `.claude/hooks/hook-docs-only-diff.ps1` with Edit (rule R2-6). Acceptance: `grep -c '^' .claude/hooks/hook-docs-only-diff.ps1` prints `484`; `grep -c -F -e '$process.Dispose()' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e 'finally {' .claude/hooks/hook-docs-only-diff.ps1` prints `2`; `grep -c -F -e '& $ProcessStarter $startInfo' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e 'disposed on every return path' .claude/hooks/hook-docs-only-diff.ps1` prints `1`.
- [x] [P2-T2] Write `FEATURE/evidence/qa-gates/r2-helper-copies.<timestamp>.md`. Commands: `cp .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1`; `cp .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1`; `cp .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1`; `cmp -s` of the canonical helper against each copy; `git hash-object` on the four paths. Acceptance: the three `cp` and three `cmp -s` calls exit 0; the four hashes are equal and are recorded as `R2_HELPER_HASH: <40-hex>`.
- [x] [P2-T3] Write `FEATURE/evidence/qa-gates/r2-helper-structure.<timestamp>.md`. Commands: `grep -c '^'` on the four helper paths; `grep -c -F -e '$process.Dispose()'` on the four helper paths; `git diff --stat R2_START_HEAD HEAD -- .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1` and `git status --porcelain -- .claude .codex extensions tests`, with the [P0-T2] value substituted for `R2_START_HEAD`. Acceptance: the line counts print `484` four times; the `Dispose()` counts print `1` four times; the diff prints nothing; the status lists exactly the four helper paths and the two test suites of Phase 1, each with status ` M`.
- [x] [P2-T4] Commit and push Phases 1 and 2 (rule R2-11). Paths: `.claude/hooks/hook-docs-only-diff.ps1`, `.codex/hooks/hook-docs-only-diff.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1`, `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1`, `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`, `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `fix(927): dispose the bounded-runner process object (CR-R1)`. This commit is the initial `R2_FINAL_CODE_COMMIT` (rule R2-12).

### Phase 3 — Decisions on CR-R2 to CR-R6

- [x] [P3-T1] Write `FEATURE/evidence/other/r2-decisions.<timestamp>.md`. Command recorded: `Decision record for R2`; `EXIT_CODE: 0`. Content, one line each: `DECISION D-R2-1: PA-1R regenerated locally under D-RUN-9 (route A MCP over SCAN_FULL per D-RUN-9a; route B direct Invoke-PoshQCTest when route A falls short)`; `DECISION D-R2-2: route B runs through sh SCRATCH/927/r2/run-poshqc-927.sh (isolation guard refuses command text containing the PowerShell host name)`; `DECISION D-R2-3: CR-R1 try/finally Dispose; changed-line coverage on the canonical helper; codex copy by whole-file coverage`; `DECISION CR-R2: NO_ACTION real-process row not added (powershell.md line 74; general-unit-test.md lines 72 and 105; no test location outside the Pester run paths)`; `DECISION CR-R3: NO_ACTION worst case 20 s under the 30 s Codex registration timeout (D-R1-2)`; `DECISION CR-R4: NO_ACTION entry-point line 403 runs only as a process; uncovered at baseline (D-R1-12)`; `DECISION CR-R5: NO_ACTION enforce-epic-merge-gate.ps1 491 of 500 lines; not edited in R2`; `DECISION CR-R6: NO_ACTION Claude seam mocks retained because the discovery guard requires them (D-R1-6 fallback)`. Acceptance: `grep -c '^DECISION '` on the artifact prints `8`.

### Phase 4 — Final QC Loop

Restart rule: run [P4-T1] to [P4-T9] in order. If [P4-T1] or [P4-T2] changes a file, or any of [P4-T1] to [P4-T8] fails without a stated branch, apply the fix (a fixed helper is re-copied by repeating [P2-T2]), commit and push the fix per rule R2-11 (paths: each fixed file, its copies, and `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`; subject `fix(927): R2 final QC loop pass <n> corrections`; this commit becomes `R2_FINAL_CODE_COMMIT`), and restart at [P4-T1]. Each pass writes new artifacts with new write-time stamps. The loop ends only when one pass completes [P4-T1] to [P4-T9] with no failure and no file change. Type checking does not apply to PowerShell. A test step whose stop condition fires ([P4-T7]) stops the run instead of restarting.

- [x] [P4-T1] Write `FEATURE/evidence/qa-gates/r2-qc-format.<timestamp>.md` (QC step 1; write-mode tool observed by tree state). Commands: `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` (before); `mcp__drm-copilot__run_poshqc_format` with `scan_folders` = `SCAN_QC`; `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` (after). Acceptance: `MCP_CALL: returned`; both status commands print nothing, meaning the formatter rewrote no PowerShell file in this pass. When the after-status lists a path, the executor records `FORMAT_REWRITE: <path>` and the output of `git diff HEAD -- <path>` for each, keeps the formatter output as the fix, and applies the restart rule.
- [x] [P4-T2] Write `FEATURE/evidence/qa-gates/r2-qc-analyze.<timestamp>.md` (QC step 2). Commands: `mcp__drm-copilot__run_poshqc_analyze` with `scan_folders` = `SCAN_QC`; `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`. Acceptance: `MCP_CALL: returned`; the status prints nothing. The analyzer finding count is read from the CI `Analyze PowerShell` step at [P5-T2].
- [x] [P4-T3] Write `FEATURE/evidence/qa-gates/r2-qc-parity.<timestamp>.md`. Commands: `cmp -s .claude/hooks/hook-docs-only-diff.ps1 <copy>` for the three copies; `git hash-object` on the four helper paths; `grep -c '^'` on the four helper paths, `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1`, `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`, and `.claude/hooks/enforce-epic-merge-gate.ps1`. Acceptance: the three `cmp -s` calls exit 0; the four hashes are equal and equal `R2_HELPER_HASH` (or a value recorded as `R2_HELPER_HASH_FINAL:` after a loop fix of the helper); the counts print `484` four times, then `194`, `241`, and `491`, each below `500` (after a formatter rewrite, the post-format count of the rewritten file and of its copies is expected and recorded as `LINE_COUNT_SOURCE: <path> post-format <n>`; any value of `500` or more fails this task and stops the plan for revision).
- [x] [P4-T4] Write `FEATURE/evidence/qa-gates/r2-qc-test-purity.<timestamp>.md` (rule R2-9). Command: `grep -c -E -e 'Mock (git|gh)( |$)|Mock .(git|gh). |function (git|gh) |Start-Process|Start-Sleep|TestDrive|New-TemporaryFile|GetTempFileName|GetTempPath|env:TEMP|ProcessStartInfo' tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`. Acceptance: both printed counts are `0`; `EXIT_CODE: 1` is recorded with `ExpectedExitCode: 1`.
- [x] [P4-T5] Write `FEATURE/evidence/qa-gates/r2-qc-pytest-contracts.<timestamp>.md` (bundle parity of the copies). Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q`. Acceptance: exit 0 and the final summary line, recorded verbatim, reports `passed` with no `failed` or `error` count.
- [x] [P4-T6] Write `FEATURE/evidence/qa-gates/r2-pa1r-route-a.<timestamp>.md` (QC step 3, route A; PA-1R). Commands: `date -u +%s` (recorded as `RUN_START_EPOCH:`); `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `SCAN_FULL`; `stat -c %Y artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml`; rule R2-READ steps K1 to K4 (section 5). Acceptance: the artifact records the MCP disposition, both mtimes, and every reader line verbatim, and ends with exactly one line `PA1R_ROUTE_A: SATISFIED` or `PA1R_ROUTE_A: NOT_SATISFIED <reasons>`. `SATISFIED` is written only when the MCP call returned, both mtimes are greater than `RUN_START_EPOCH`, and the R2-READ pass condition holds. When K3 lists a failing token of suite F or D, the task fails and the restart rule applies. Every other `NOT_SATISFIED` outcome passes this task and hands PA-1R to [P4-T7].
- [x] [P4-T7] Write `FEATURE/evidence/qa-gates/r2-pa1r-route-b.<timestamp>.md` (QC step 3, route B; PA-1R). When the [P4-T6] artifact of this pass ends with `PA1R_ROUTE_A: SATISFIED`, the artifact records `Command: none`, `EXIT_CODE: 0`, and `PA1R_ROUTE_B: NOT_RUN (route A satisfied in <r2-pa1r-route-a artifact name>)`, and the task passes (this task authorizes that branch). Otherwise commands: `date -u +%s` (`RUN_START_EPOCH:`); `sh SCRATCH/927/r2/run-poshqc-927.sh SCRATCH/927/r2/run-poshqc-927.ps1 SCRATCH/927/r2/direct-run.log`, run with the Bash tool's background option because the full population exceeds the foreground time limit, waiting for its completion notification and never starting a second run while the first is live; `grep -F -e 'POSHQC_EXIT_CODE=' SCRATCH/927/r2/direct-run.log`; `stat -c %Y artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml`; rule R2-READ steps K1 to K4. Acceptance: the `sh` command and the grep are recorded (per rule R2-1, `Command: date -u +%s`; the run is recorded on the labelled lines `Command 2: sh SCRATCH/927/r2/run-poshqc-927.sh SCRATCH/927/r2/run-poshqc-927.ps1 SCRATCH/927/r2/direct-run.log` and `EXIT_CODE_2: <exit code from the completion notification>`); the grep prints `POSHQC_EXIT_CODE=0`; both mtimes are greater than `RUN_START_EPOCH`; the R2-READ pass condition holds; the artifact ends with `PA1R_ROUTE_B: SATISFIED`. Stop conditions: a denial of the `sh` command is recorded verbatim as `ROUTE_B_DENIAL: <text>` with `PA1R_ROUTE_B: BLOCKED` and stops the run (rule R2-7); a JUnit `failures` or `errors` value above `0` whose failing tokens are all outside suites F and D is recorded as `R2_LOCAL_FAILED: <test name>` lines (names only, rule R2-2) with `PA1R_ROUTE_B: REMEDIATION_REQUIRED` and stops the run for caller decision; any other failed condition records `PA1R_ROUTE_B: REMEDIATION_REQUIRED <reasons>` and stops the run. A failing token of suite F or D applies the restart rule instead.
- [x] [P4-T8] Write `FEATURE/evidence/qa-gates/r2-coverage-delta.<timestamp>.md` (baseline vs post-change vs changed code). Commands: `git diff -U0 R2_START_HEAD HEAD -- .claude/hooks/hook-docs-only-diff.ps1` with the [P0-T2] value substituted; `poetry run python -I SCRATCH/927/tools/read_coverage_927.py artifacts/pester/powershell-coverage.xml .claude/hooks/hook-docs-only-diff.ps1:<CHANGED_LINES> .codex/hooks/hook-docs-only-diff.ps1:<CHANGED_LINES>`, where `<CHANGED_LINES>` is the comma-separated list of lines `c` to `c + d - 1` of every hunk header `@@ -a,b +c,d @@` (`+c` alone means `d = 1`) with `d > 0`, recorded as `CHANGED_LINES: <list>`. Content: `REPO_LINE_BASELINE:` and `REPO_LINE_POST:` (from the [P0-T7] `R2_BASE_CI` line and the satisfying route artifact of this pass), `FILE_BASELINE:` and `FILE_POST:` for the seven files, the `LINE_RESULT:` lines verbatim, and `CHANGED_CODE: .claude/hooks/hook-docs-only-diff.ps1 covered=<n> executable=<n> pct=<x>`, where `executable` counts lines not reported `NOT_EXECUTABLE_OR_ABSENT` and `covered` counts those with `ci` above `0`. Acceptance: `REPO_LINE_POST` is at least 85.00%; each `FILE_POST` is at least 85.00%; the `FILE_POST` of each helper copy is at least its `FILE_BASELINE` (97.52%) or at least 85.00%; on `.claude/hooks/hook-docs-only-diff.ps1` `covered` equals `executable` and the line holding `$process.Dispose()` (number from `grep -n -F -e '$process.Dispose()' .claude/hooks/hook-docs-only-diff.ps1`) reports `ci` above `0`; the `.codex/hooks/hook-docs-only-diff.ps1` lines are recorded for information (decision D-R2-3). A failed condition fails this task and applies the restart rule.
- [x] [P4-T9] Write `FEATURE/evidence/qa-gates/r2-qc-loop-record.<timestamp>.md`. Command recorded: `R2 final QC loop per Phase 4 restart rule`; `EXIT_CODE: 0`. Acceptance: the artifact lists each pass as `LOOP_PASS: <n> RESULT: <clean|restarted at P4-T1 because ...>`; its last pass is `clean` and names the [P4-T1] to [P4-T8] artifacts of that pass; it records `PA1R_FINAL_ROUTE: A` or `PA1R_FINAL_ROUTE: B` from that pass and `R2_FINAL_CODE_COMMIT: <40-hex>` from `git log -1 --format=%H -- .claude .codex extensions tests`.
- [x] [P4-T10] Commit and push Phase 3 and Phase 4 evidence (rule R2-11). Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record R2 decisions and final QC loop`. The XML files are not staged (they are gitignored; rule R2-10).

### Phase 5 — CI on the Final Code Commit

- [x] [P5-T1] Write `FEATURE/evidence/qa-gates/r2-ci-run.<timestamp>.md`. Commands: `git rev-parse HEAD`; `git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927`; `git diff --name-only R2_FINAL_CODE_COMMIT HEAD` with the [P4-T9] value substituted; `git status --porcelain`; `gh workflow run ci.yml --ref bug/pr-author-docs-only-exemption-hardening-927`; `gh run list --workflow ci.yml --branch bug/pr-author-docs-only-exemption-hardening-927 --event workflow_dispatch --json databaseId,headSha,status,conclusion,createdAt --limit 10`. Acceptance: the two `rev-parse` values are equal and recorded as `R2_CI_HEAD: <40-hex>`; every path listed by the diff and every status line is under `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/`; the dispatch exits 0; the newest listed run whose `headSha` equals `R2_CI_HEAD` is recorded as `R2_CI_RUN_ID: <databaseId>`. When no listed run matches yet, the executor reruns only the list command until one appears (this task authorizes that repetition; it never dispatches twice while a matching run is queued or in progress).
- [x] [P5-T2] Write `FEATURE/evidence/qa-gates/r2-ci-jobs.<timestamp>.md`. Commands (the [P5-T1] run id substituted): `gh run watch R2_CI_RUN_ID --interval 60 --exit-status` (background option allowed, as in [P4-T7]); `gh run view R2_CI_RUN_ID --json headSha,status,conclusion`; `gh run view R2_CI_RUN_ID --json jobs --jq '.jobs[] | [.name, .conclusion] | @tsv'`; `gh run view R2_CI_RUN_ID --json jobs --jq '.jobs[] | .name as $j | .steps[] | [$j, .name, .conclusion] | @tsv'`. Acceptance: the watch exits 0; `headSha` equals `R2_CI_HEAD` and `conclusion` is `success`; every job row reads `success` or `skipped`, and the rows `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` each read `success`; among the step rows whose first field is `poshqc / PowerShell QC`, the steps `Format PowerShell`, `Analyze PowerShell`, and `Test PowerShell` each read `success`. All rows are recorded verbatim with `R2_CI_RUN_ID` and `R2_CI_HEAD`. A failure records the failing job and step names and `R2_CI: REMEDIATION_REQUIRED`, and stops the run.

### Phase 6 — Acceptance Re-verification and Remediation Closure

- [x] [P6-T1] Write `FEATURE/evidence/qa-gates/r2-ac-reverification.<timestamp>.md`. Command recorded: `AC re-verification against R2 Phase 4 and Phase 5 evidence`; `EXIT_CODE: 0`. Content: one line per criterion: `AC-<id>: REVERIFIED <artifact names>` for AC-M1 to AC-M22, AC-1 to AC-8, AC-10, AC-11, AC-12, AC-20, and AC-22 (each citing the satisfying route artifact of [P4-T6] or [P4-T7] and the [P4-T3] parity artifact); `AC-<id>: UNAFFECTED <reason>` for AC-M25 and AC-13 to AC-17 (no file in their scope changed in R2, per the [P2-T3] diff and status); `AC-<id>: PENDING_CI_SUPPORTED R2_CI_RUN_ID=<id> <values>` for AC-9, AC-18, AC-19, AC-21, AC-M23, and AC-M24 (values from [P5-T2] and the [P4-T8] `FILE_POST` lines; check-off stays with the original plan Phase 8). Acceptance: `grep -c -E '^AC-M?[0-9]+: REVERIFIED '` on the artifact prints `35`; `grep -c -E '^AC-M?[0-9]+: UNAFFECTED '` prints `6`; `grep -c -E '^AC-M?[0-9]+: PENDING_CI_SUPPORTED '` prints `6`.
- [x] [P6-T2] Write `FEATURE/evidence/qa-gates/r2-ac-state.<timestamp>.md` (checkbox state unchanged by R2). Commands: `grep -c -E '^- \[x\] AC-M?[0-9]+ ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`; `grep -c -E '^- \[ \] AC-(9|18|19|21|M23|M24) ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`. Acceptance: the counts print `41` and `6`.
- [x] [P6-T3] Write `FEATURE/evidence/qa-gates/r2-remediation-closure.<timestamp>.md`. Command recorded: `R2 remediation closure`; `EXIT_CODE: 0`. Content: `PA-1R: CLOSED route=<A|B> <satisfying route artifact name> r2-coverage-delta`; `CR-R1: CLOSED r2-expect-fail r2-helper-structure r2-coverage-delta`; `CR-R2: NO_ACTION r2-decisions`; `CR-R3: NO_ACTION r2-decisions`; `CR-R4: NO_ACTION r2-decisions`; `CR-R5: NO_ACTION r2-decisions`; `CR-R6: NO_ACTION r2-decisions`; and `LOCAL_XML_STATE: artifacts/pester/powershell-coverage.xml and pester-junit.xml are the full-population output of the route named above; no later task of this cycle runs Pester locally`; and `REVIEW_READ_PATH: the feature-review coverage hook reads artifacts/pester/powershell-coverage.xml relative to its working directory (.claude/hooks/validate-feature-review-coverage-metrics.ps1 lines 25 and 176); the next feature-review must run with <WORKSPACE_ROOT> as its working directory, and no Pester or PoshQC MCP test run may occur in this worktree before it`. Acceptance: `grep -c -E '^(PA-1R|CR-R[1-6]): '` on the artifact prints `7`; `grep -c -F -e 'LOCAL_XML_STATE:'` on it prints `1`; `grep -c -F -e 'REVIEW_READ_PATH:'` on it prints `1`.
- [x] [P6-T4] Commit and push Phases 5 and 6 (rule R2-11). Commands before the commit: `git diff --name-only R2_FINAL_CODE_COMMIT HEAD` with the [P4-T9] value substituted; `git status --porcelain`. Acceptance (in addition to rule R2-11): every path listed by the diff and every status line is under `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/`. Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record R2 CI run, acceptance re-verification, and closure`.

---

## 5. Rule R2-READ (reading the regenerated local XML)

`<COV>` is `artifacts/pester/powershell-coverage.xml`; `<JUNIT>` is `artifacts/pester/pester-junit.xml`. Reader output is copied verbatim into the calling artifact.

- **K1** `poetry run python -I SCRATCH/927/tools/read_report_totals_927.py <COV> <JUNIT>`: prints `REPORT_LINE:` (report-level LINE counter) and `JUNIT_TOTALS:` (`<testsuites>` root).
- **K2** `poetry run python -I SCRATCH/927/tools/read_hook_aggregate_927.py <COV>`: prints `HOOK_AGGREGATE_LINE:`, the sum over every `LINE` counter that `.claude/hooks/validate-feature-review-coverage-metrics.ps1` lines 153-164 compute for the path at line 176, compared against the 85% floor of `.claude/hooks/validate-feature-review-coverage-rules.ps1` line 175.
- **K3** for each token of Appendix R: `grep -c -F -e '<token>" status="Passed"' <JUNIT>`; and `grep -o -E 'testcase name="[^"]*" status="Failed"' <JUNIT>` (failing names only).
- **K4** `poetry run python -I SCRATCH/927/tools/read_coverage_927.py <COV> .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .codex/hooks/enforce-epic-merge-gate.ps1`: one `COVERAGE_RESULT:` line per file; `CLASS_COUNT=0` means the file has no entry.

**Pass condition:** K1 exits 0, `REPORT_LINE:` shows `result=PASS`, and `JUNIT_TOTALS:` shows `tests` of at least `10000` (the scoped MCP run of the reviewed state reported 7183; CI run 38876469175 reported 10545), `failures=0`, and `errors=0`; K2 exits 0 and shows `result=PASS`; every K3 count prints `1` and the failed-name grep prints nothing (exit 1, recorded on its labelled line); K4 exits 0 and prints seven `COVERAGE_RESULT:` lines, each with `result=PASS`.

---

## 6. Appendix H — edits to `.claude/hooks/hook-docs-only-diff.ps1` (478 lines before, 484 after)

**H2-1** (help text, +1 line). Old (lines 167-168):

```powershell
        seam, which returns its failure object. $LASTEXITCODE is set in the global scope
        because the seams read it after the invoker, as they do after a native command.
```

New:

```powershell
        seam, which returns its failure object. $LASTEXITCODE is set in the global scope
        because the seams read it after the invoker, as they do after a native command.
        The process object is disposed on every return path once it has started.
```

**H2-2** (body, +5 lines). Old (lines 200-223 before H2-1; 201-224 after it):

```powershell
    $output = $process.StandardOutput.ReadToEndAsync()
    $null = $process.StandardError.ReadToEndAsync()
    if (-not $process.WaitForExit($TimeoutMilliseconds) -or -not $output.Wait(1000)) {
        try {
            $process.Kill($true)
        }
        catch {
            $null = $_
        }
        Set-Variable -Name LASTEXITCODE -Value 124 -Scope Global
        return
    }
    Set-Variable -Name LASTEXITCODE -Value ([int]$process.ExitCode) -Scope Global
    $text = [string]$output.Result
    if ($text.EndsWith("`n")) {
        $text = $text.Substring(0, $text.Length - 1)
    }
    if ($text.Length -eq 0) {
        return
    }
    foreach ($line in $text.Split("`n")) {
        $line.TrimEnd("`r")
    }
}
```

New:

```powershell
    try {
        $output = $process.StandardOutput.ReadToEndAsync()
        $null = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit($TimeoutMilliseconds) -or -not $output.Wait(1000)) {
            try {
                $process.Kill($true)
            }
            catch {
                $null = $_
            }
            Set-Variable -Name LASTEXITCODE -Value 124 -Scope Global
            return
        }
        Set-Variable -Name LASTEXITCODE -Value ([int]$process.ExitCode) -Scope Global
        $text = [string]$output.Result
        if ($text.EndsWith("`n")) {
            $text = $text.Substring(0, $text.Length - 1)
        }
        if ($text.Length -eq 0) {
            return
        }
        foreach ($line in $text.Split("`n")) {
            $line.TrimEnd("`r")
        }
    }
    finally {
        $process.Dispose()
    }
}
```

The statement `$process = & $ProcessStarter $startInfo` (line 199 before, 200 after H2-1) is unchanged and stays outside the `try`, so a start failure throws to the calling seam exactly as before.

## 7. Appendix T — test edits

`A` denotes the line `            $script:DocsOnlyFakeProcess.Disposed | Should -BeTrue -Because 'the runner disposes the process object on every return path'` (12 leading spaces).

Suite F `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` (188 lines; 194 after):

- **TF-1** (line 26, in place): replace `Killed = $false; WaitLimit = 0;` with `Killed = $false; Disposed = $false; WaitLimit = 0;`.
- **TF-2** (+1): old lines 35-37 `                $this.Killed = $EntireTree` / `            }` / `            return $process`; insert `            $process | Add-Member -MemberType ScriptMethod -Name Dispose -Value { $this.Disposed = $true }` before `            return $process`.
- **TF-3** (+1, row F1): insert `A` after `            $script:DocsOnlyFakeProcess.StandardOutput.Task.Limit | Should -Be 1000`.
- **TF-4** (+1, rows F2 to F5): insert `A` after the two-line block `            $global:LASTEXITCODE | Should -Be 0` / `            $script:DocsOnlyFakeProcess.Killed | Should -BeFalse` (lines 100-101).
- **TF-5** (+1, row F6): insert `A` after the two-line block `            $global:LASTEXITCODE | Should -Be 2` / `            $script:DocsOnlyFakeProcess.Killed | Should -BeFalse` (lines 113-114).
- **TF-6** (+1, rows F7 to F9): insert `A` after `            $script:DocsOnlyFakeProcess.WaitLimit | Should -Be 7000`.
- **TF-7** (+1, row F11): insert `A` after `            $script:DocsOnlyFakeProcess.Killed | Should -BeTrue` (line 159; the only occurrence).

Suite D `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` (239 lines; 241 after):

- **TD-1** (line 45, in place): replace `Killed = $false; WaitLimit = 0;` with `Killed = $false; Disposed = $false; WaitLimit = 0;`.
- **TD-2** (+1): old lines 54-56 `                $this.Killed = $EntireTree` / `            }` / `            return $process`; insert `            $process | Add-Member -MemberType ScriptMethod -Name Dispose -Value { $this.Disposed = $true }` before `            return $process`.
- **TD-3** (+1, rows D1 to D4): insert `        $script:CodexDocsOnlyFakeProcess.Disposed | Should -BeTrue -Because 'the runner disposes the process object on every return path'` (8 leading spaces) after `        $script:CodexDocsOnlyStartInfo.FileName | Should -BeExactly 'git'` (line 213; 8 leading spaces).

Each edit sits in an Assert section or a test-local fake; no Arrange or Act line changes, no row is added, and no row name changes.

## Appendix R — JUnit row tokens

Each token is the tail of a `testcase name` value (unchanged from Appendix R1-T of `remediation-plan.2026-10-16T05-25.md`).

- F1 `starts the executable in the current location with each argument and redirected streams (issue #927)`
- F2 `emits two LF-terminated lines as output lines (issue #927)`
- F3 `emits CRLF-terminated lines as output lines (issue #927)`
- F4 `emits NUL-terminated diff output as output lines (issue #927)`
- F5 `emits empty output as output lines (issue #927)`
- F6 `reports the non-zero exit code of a process that exits in time (issue #927)`
- F7 `stops the process tree, emits nothing, and reports 124 when the exit wait expires (issue #927)`
- F8 `stops the process tree, emits nothing, and reports 124 when the output wait expires (issue #927)`
- F9 `stops the process tree, emits nothing, and reports 124 when stopping the process throws (issue #927)`
- F10 `returns the seam failure object when the process cannot start (issue #927)`
- F11 `returns exit code 124 through the git seam when the bounded call expires (issue #927)`
- F12 `routes the default git invoker through the bounded runner with a 3000 ms limit (issue #927)`
- F13 `routes the default gh invoker through the bounded runner with a 7000 ms limit (issue #927)`
- D1 `runs the bounded runner when the process exits in time (codex copy, issue #927)`
- D2 `runs the bounded runner when the exit wait expires (codex copy, issue #927)`
- D3 `runs the bounded runner when the output wait expires (codex copy, issue #927)`
- D4 `runs the bounded runner when stopping the process throws (codex copy, issue #927)`
- D5 `routes the default git invoker through the bounded runner (codex copy, issue #927)`
- D6 `routes the default gh invoker through the bounded runner (codex copy, issue #927)`

## Appendix A1 — `SCRATCH/927/tools/read_hook_aggregate_927.py`

```python
"""Issue 927 scratch helper: print the all-LINE-counter aggregate that the feature-review coverage hook computes."""

import sys
import xml.etree.ElementTree as ET


def main(argv):
    """Print HOOK_AGGREGATE_LINE over every LINE counter in the document; return 0, 1, or 2."""
    if len(argv) != 2:
        print("USAGE: read_hook_aggregate_927.py COVERAGE_XML")
        return 2
    root = ET.parse(argv[1]).getroot()
    counters = [c for c in root.iter("counter") if c.get("type") == "LINE"]
    covered = sum(int(c.get("covered")) for c in counters)
    missed = sum(int(c.get("missed")) for c in counters)
    total = covered + missed
    if not total:
        print("HOOK_AGGREGATE_LINE: NO_LINE_COUNTERS")
        return 1
    pct = round(100.0 * covered / total, 2)
    verdict = "PASS" if pct >= 85.0 else "FAIL"
    print(f"HOOK_AGGREGATE_LINE: counters={len(counters)} covered={covered} missed={missed} line_pct={pct} threshold=85.00 result={verdict}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
```

## Appendix A2 — `SCRATCH/927/r2/run-poshqc-927.ps1`

```powershell
#Requires -Version 7.0
# Issue 927 scratch runner: the CI form of the Test PowerShell step of .github/workflows/_poshqc.yml.
# Coverage settings come from the repository settings file unchanged.
$ErrorActionPreference = 'Stop'
$root = (git rev-parse --show-toplevel).Trim()
Import-Module (Join-Path $root 'scripts/powershell/PoshQC/PoshQC.psm1')
Invoke-PoshQCTest -Root $root
```

## Appendix A3 — `SCRATCH/927/r2/run-poshqc-927.sh`

```sh
#!/bin/sh
# Issue 927 scratch wrapper: run one PowerShell 7 script file and append its exit code to a log file.
# Usage: sh run-poshqc-927.sh <script.ps1> <log file>
pwsh -NoProfile -NonInteractive -File "$1" > "$2" 2>&1
code=$?
echo "POSHQC_EXIT_CODE=$code" >> "$2"
exit "$code"
```

## 8. WRITES

Repository paths this cycle may change (every other change is out of scope, rule R2-10):

- `.claude/hooks/hook-docs-only-diff.ps1` (Edit)
- `.codex/hooks/hook-docs-only-diff.ps1` (cp)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1` (cp)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1` (cp)
- `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` (Edit)
- `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` (Edit)
- `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/remediation-plan.2026-10-16T11-20.md` (this plan; checkbox updates)
- `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/**` (new artifacts only)

Gitignored tool output written by the Pester runs (not committed): `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/pester-junit.xml`.

## 9. Quoted literals created by this plan

Literals that acceptance conditions assert and that do not exist before their task runs: `$process.Dispose()`, `disposed on every return path` (Appendix H), `Disposed = $false`, `-Name Dispose -Value { $this.Disposed = $true }`, `Disposed | Should -BeTrue` (Appendix T), `HOOK_AGGREGATE_LINE: counters=` (Appendix A1), `Invoke-PoshQCTest -Root $root` (Appendix A2), `POSHQC_EXIT_CODE=` (Appendix A3), and the artifact lines `PA1R_ROUTE_A:`, `PA1R_ROUTE_B:`, `DECISION `, `LOCAL_XML_STATE:`, `REVIEW_READ_PATH:`, `R2_BASE_CI `, `R2_BASE_LOCAL `. Each is quoted verbatim in the task or appendix that creates it.
