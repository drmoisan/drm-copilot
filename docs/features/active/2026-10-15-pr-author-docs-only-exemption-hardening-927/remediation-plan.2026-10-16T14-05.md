# 2026-10-15-pr-author-docs-only-exemption-hardening (Remediation Plan R3)

- **Issue:** #927
- **Cycle:** R3 (remediation cycle 3; last allowed cycle)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16T14-05
- **Status:** Draft; awaiting executor preflight.
- **Version:** 1.0
- **Work Mode:** full-bug (`issue.md` line 9, `- Work Mode: full-bug`). Acceptance-criteria source: `spec.md`, section `## Acceptance Criteria` (AC-M1 to AC-M25, AC-1 to AC-22). This cycle adds no criterion and removes none.
- **Primary input:** `remediation-inputs.2026-10-16T14-05.md` (review verdict PASS; CR-N1 and CR-N2, both Non-blocking, remediability autonomous, carried under the coordinator's related-findings rule; scope fixed by orchestrator decision D-RUN-10).
- **Review artifacts:** `policy-audit.2026-10-16T11-19.md`, `code-review.2026-10-16T11-19.md`, `feature-audit.2026-10-16T11-19.md` (same folder; not edited).
- **Prior cycle plan:** `remediation-plan.2026-10-16T11-20.md` (executed; not edited). This plan reuses its route B wrapper approach (its Appendix A2 and A3) and its reader scripts.
- **Original plan:** `plan.2026-10-15T07-41.md`. Its Phase 8 (S9 CI gate on the pull-request run) still owns the check-off of AC-9, AC-18, AC-19, AC-21, AC-M23, and AC-M24.
- **Branch:** `bug/pr-author-docs-only-exemption-hardening-927`. Every push is `git push origin HEAD:refs/heads/bug/pr-author-docs-only-exemption-hardening-927` (fast-forward only).


**Overview.** This cycle closes two related observations of the PASS review 2026-10-16T11-19 and nothing else:

- CR-N1: in `Invoke-DocsOnlyBoundedNative`, the expiry branch checks each output read once, without waiting, in a fixed order after the stop attempt and before `Dispose()` (decision D-R3-1). The edit is applied to `.claude/hooks/hook-docs-only-diff.ps1` and copied byte-identically to the three other helper paths.
- CR-N2: suite D gains one row whose fake output ends with a line feed, so the Codex copy executes the trailing line-feed trim statement.
- CR-R2 to CR-R6 and CR-N3: recorded by the orchestrator without action (D-RUN-10). No task of this plan addresses them.

`FEATURE` denotes `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. `SCRATCH` denotes `<session scratchpad>/issue-927/`; scratch files of this cycle live under `SCRATCH/r3/`. `SCRATCH` is outside the repository, and artifacts record only the literal token `SCRATCH`. Every evidence path is `FEATURE/evidence/<kind>/<name>.<timestamp>.md`, with `<kind>` one of `remediation-baseline`, `regression-testing`, `qa-gates`; `<timestamp>` is the UTC write time read from the host clock immediately before the write (`date -u +%Y-%m-%dT%H-%M`) and is never fixed in this plan. A task that consumes an artifact selects the lexicographically greatest file matching `<name>.*.md`.

**Fail-closed rule:** PowerShell is the only code language changed. If a required baseline, QC, or coverage value is missing, the cycle outcome is `REMEDIATION_REQUIRED`, never PASS.

---

## 1. Rules binding on every task

1. **R3-1 Evidence schema.** Every artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. `Command:` and `EXIT_CODE:` describe the first command the task names; every later command's exit code is recorded on its own labelled line (`EXIT_CODE_<n>:` or a named label). When the first command is a PoshQC MCP call, `EXIT_CODE: 0` records `MCP_CALL: returned` and `EXIT_CODE: 1` records `MCP_CALL: error <message>`, with any absolute host path in the message written as `<WORKSPACE_ROOT>` (rule R3-2); that value implies no count, percentage, or finding. `ExpectedExitCode:` is written only where a task names it, and only when the artifact's first command is the one expected to exit non-zero. `EXIT_CODE: SKIPPED` is never a passing outcome.
2. **R3-2 No host data.** No artifact or test written by this plan contains an absolute host path, a drive letter, a user-profile path, a host name, or an account name. The worktree root is written `<WORKSPACE_ROOT>`; scratch paths are written `SCRATCH/...`. Reader output is copied into artifacts; raw XML, JUnit `classname` values, and run logs are never copied.
3. **R3-3 MCP calls.** `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test` are called with `workspace_root` set to the output of `git rev-parse --show-toplevel`. MCP results carry no output detail, so no acceptance condition reads a count, percentage, or finding from an MCP result; counts come from the on-disk JUnit and coverage files through the readers, and format outcomes come from `git status --porcelain`.
4. **R3-4 Scan sets.** `SCAN_QC` = `[".claude/hooks", ".codex/hooks", "tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]` (the original plan's format/analyze set; all four folders exist). `SCAN_FAIL` = `["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]` (expect-fail run only). The final test step does not use an MCP scan set: it is route B (rule R3-6), which resolves `config/poshqc-scan.json` as CI does.
5. **R3-5 Executor isolation guard.** Command text never contains the words `bash`, `pwsh`, or `wsl`, never uses a heredoc, and runs one command per call (no `&&`, no `;`, no `cd`). Searches use plain `grep`. A grep pattern that begins with `-` is passed through `-e`. Python runs only as `poetry run python -I ...` (scratch readers) or `poetry run pytest ...`. In command text the scratch path is written with forward slashes.
6. **R3-6 Pester route.** The final QC test step is route B of cycle 2 (decisions D-R2-1 and D-R2-2 of `remediation-plan.2026-10-16T11-20.md`): `sh SCRATCH/r3/run-poshqc-927.sh SCRATCH/r3/run-poshqc-927.ps1 SCRATCH/r3/direct-run.log`, the CI form of `.github/workflows/_poshqc.yml` with no coverage setting changed. Route A (MCP test over a full scan set) is not used, because it does not produce per-file entries for the helper. After the last route B run of [P3-T6], no Pester run and no PoshQC MCP test call occurs in this worktree in this cycle. A denial of the `sh` command is recorded verbatim and stops the cycle as BLOCKED (rule R3-8); no other form is substituted.
7. **R3-7 Live-hook hazard.** `.claude/hooks/enforce-epic-merge-gate.ps1` runs on every Bash call and dot-sources `.claude/hooks/hook-docs-only-diff.ps1`. Each helper edit is one Edit call that leaves a parsing file (Appendix H). If a Bash call is then denied with an `EPIC_MERGE_GATE_BLOCKED:` or `PR_AUTHOR_SKILL_BLOCKED:` dependency reason, the executor repairs the helper with Edit only and retries the denied command.
8. **R3-8 Hook denials.** If any other hook or permission rule denies a Write, Edit, Bash, or MCP call, the executor records the exact denial text in the task's artifact and stops as BLOCKED. It never works around a hook, never deletes hook state, and never resets a budget file.
9. **R3-9 Byte copies.** The three other helper paths are written only by `cp .claude/hooks/hook-docs-only-diff.ps1 <copy>` and verified by `cmp -s` (exit 0); never by Write or Edit.
10. **R3-10 Test purity.** No test text added by this plan uses `Mock git`, `Mock gh`, a function named `git` or `gh`, `Start-Process`, `Start-Sleep`, `TestDrive`, `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `$env:TEMP`, `ProcessStartInfo`, a real wait, or a file write. The process object stays a test-local fake passed through `-ProcessStarter`.
11. **R3-11 Scope boundary.** The complete repository write set is section 8 (`## 8. WRITES`). No edit under `.claude/rules/` or `.github/instructions/`. `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` and `.claude/hooks/enforce-epic-merge-gate.ps1` (491 lines) are not edited. No file is deleted, no evidence file is renamed, no prior review artifact or prior plan is edited. `artifacts/pester/*.xml` is written only by the Pester runs of [P1-T3] and [P3-T6]; it is never hand-edited, copied, downloaded into, or committed. Every production and test file stays at or below 500 lines.
12. **R3-12 Commit form.** Each commit task runs, in order: `git add -- <paths>`; `git commit -m '<subject>' --trailer 'Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>' --trailer 'Claude-Session: https://claude.ai/code/session_01SS5vejcsHWGod2C5tBwyM6'`; `git log -1 --format=%B`; `git push origin HEAD:refs/heads/bug/pr-author-docs-only-exemption-hardening-927`; `git status --porcelain`; `git rev-parse HEAD`; `git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927`. Acceptance: the commit exits 0; the `git log` output ends with the two trailer lines `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` and `Claude-Session: https://claude.ai/code/session_01SS5vejcsHWGod2C5tBwyM6` in one trailer block; the push exits 0 (a rejected non-fast-forward push stops the task as BLOCKED); every status line, if any, names this plan file (its checkbox state; any status code); the two `rev-parse` values are equal. No `--amend`, no rebase, no force push.
13. **R3-13 Final code commit.** `R3_FINAL_CODE_COMMIT` is the most recent commit of this cycle that changes a path outside `FEATURE`: the [P2-T4] commit, replaced by each later Phase 3 fix commit.
14. **R3-14 Stops.** A task that states a stop condition stops the executor run at that task; the run resumes only after the caller revises this plan. A task whose acceptance fails without a stated branch is not marked checked.

## 2. Finding trace

| Finding | Implementation | Tests | Evidence |
|---|---|---|---|
| CR-N1 | Appendix H edits H3-1, H3-2; copies by `cp` (decision D-R3-1) | Appendix T edits TF3-1 to TF3-5 (rows F1, F7, F8, F9, new F14) | [P1-T3], [P2-T3], [P3-T6], [P3-T7], [P5-T3] |
| CR-N2 | none in production code | Appendix T edits TD3-1, TD3-2 (new row D7) | [P3-T6], [P3-T7], [P5-T3] |

## 3. Decisions fixed by this plan

- **D-R3-1 (CR-N1 design).** The standard error read is kept in `$errorRead` instead of being discarded. In the expiry branch, after the stop attempt, `foreach ($pendingRead in @($output, $errorRead))` calls `$pendingRead.Wait(0)` inside its own `try`/`catch`, so each read is checked once, standard output first, before the `finally` block disposes the process object. `Wait(0)` returns at once: a read that has completed is settled, a read that has faulted throws and its exception is observed by the `catch`, and a read still pending is abandoned at that fixed point. No wait time is added, so the limits (3000 ms git, 7000 ms gh, 1000 ms output wait) and the 20 s worst case in the helper header (`.claude/hooks/hook-docs-only-diff.ps1` lines 50-56) are unchanged; the expiry result is unchanged (no output, `$LASTEXITCODE` 124); the normal path performs no new call (row F1 asserts its event order). The process-start statement and the `[scriptblock] $ProcessStarter` seam are unchanged, so `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (rows at lines 62 and 433) sees no new `&`-invoked variable. Residual, recorded in [P5-T3]: a read still pending at the check faults after disposal and that exception is not observed; observing it would need a bounded wait that lengthens the worst case, which D-RUN-10 excludes. The hook process ends after one decision, so the residual does not affect the decision (code-review CR-N1 rationale).
- **D-R3-2 (changed-line measure).** Changed-line coverage is required on `.claude/hooks/hook-docs-only-diff.ps1`, whose suite F reaches every new branch (row F14 reaches the new `catch`). `.codex/hooks/hook-docs-only-diff.ps1` is measured by whole-file line coverage against its baseline and by the CR-N2 statement line; suite D has no faulting-read row, so the Codex copy's new `catch` body is recorded for information.

---

## 4. Phases

### Phase 0 — Baseline Capture

- [x] [P0-T1] Write `FEATURE/evidence/remediation-baseline/r3-phase0-instructions-read.<timestamp>.md` after reading, in this order: `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `FEATURE/remediation-inputs.2026-10-16T14-05.md`, `FEATURE/policy-audit.2026-10-16T11-19.md`, `FEATURE/code-review.2026-10-16T11-19.md`, `FEATURE/feature-audit.2026-10-16T11-19.md`, `FEATURE/spec.md`, `FEATURE/remediation-plan.2026-10-16T14-05.md`. The artifact carries `Timestamp:`, `Policy Order:`, `Command: Read (17 files)`, `EXIT_CODE: 0`, `Output Summary:`, and one line `READ: <repository-relative path>` per file in the order above. Acceptance: `grep -c '^READ: '` on the new artifact prints `17`; `grep -c '^Policy Order:'` on it prints `1`.
- [x] [P0-T2] Write `FEATURE/evidence/remediation-baseline/r3-branch-state.<timestamp>.md`. Commands: `git rev-parse --abbrev-ref HEAD`; `git status --porcelain`; `git fetch origin bug/pr-author-docs-only-exemption-hardening-927`; `git rev-parse HEAD`; `git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927`; `git rev-parse --show-toplevel`. Acceptance: the first prints `bug/pr-author-docs-only-exemption-hardening-927`; every status line, whatever its status code (`??`, ` M`, or `A `), names a path under `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/`; the fetch exits 0; `HEAD` equals the origin value and is recorded as `R3_START_HEAD: <40-hex>`; the top-level output is used as the MCP `workspace_root` and recorded only as `WORKSPACE_ROOT: <WORKSPACE_ROOT>`. A different branch, a status line outside that folder, or unequal heads stops the plan as BLOCKED.
- [x] [P0-T3] Write `FEATURE/evidence/remediation-baseline/r3-line-counts-parity.<timestamp>.md`. Commands: `grep -c '^' .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 .claude/hooks/enforce-epic-merge-gate.ps1`; `cmp -s .claude/hooks/hook-docs-only-diff.ps1 <copy>` for each of the three other helper paths above; `grep -c -F -e '& $ProcessStarter $startInfo' .claude/hooks/hook-docs-only-diff.ps1`; `grep -c -F -e '$null = $process.StandardError.ReadToEndAsync()' .claude/hooks/hook-docs-only-diff.ps1`; `grep -c -F -e 'pendingRead' .claude/hooks/hook-docs-only-diff.ps1`. Acceptance: the counts print `484` four times, then `194`, `241`, and `491`; all three `cmp -s` calls exit 0; the `$ProcessStarter` grep prints `1`; the `StandardError` grep prints `1`; the `pendingRead` grep prints `0` (exit 1, recorded on its labelled line). A different line count stops the plan for re-derivation of Appendix H and T; a `cmp` difference stops the plan as BLOCKED.
- [x] [P0-T4] Prepare the scratch tools (files outside the repository, written with the Write tool, LF line endings, not committed) and write `FEATURE/evidence/remediation-baseline/r3-scratch-tools.<timestamp>.md`. Writes: `SCRATCH/r3/read_coverage_927.py` with the exact content of Appendix S of `FEATURE/plan.2026-10-15T07-41.md` (section 14); `SCRATCH/r3/read_report_totals_927.py` with the exact content of Appendix S2 of `FEATURE/remediation-plan.2026-10-16T05-25.md` (section 12); `SCRATCH/r3/read_hook_aggregate_927.py` with the exact content of Appendix A1 of `FEATURE/remediation-plan.2026-10-16T11-20.md`; `SCRATCH/r3/run-poshqc-927.ps1` with the exact content of Appendix A2 of that plan; `SCRATCH/r3/run-poshqc-927.sh` with the exact content of Appendix A3 of that plan. Commands: `grep -c -F -e 'def find_classes' SCRATCH/r3/read_coverage_927.py`; `grep -c -F -e 'def report_line' SCRATCH/r3/read_report_totals_927.py`; `grep -c -F -e 'HOOK_AGGREGATE_LINE: counters=' SCRATCH/r3/read_hook_aggregate_927.py`; `grep -c -F -e 'Invoke-PoshQCTest -Root $root' SCRATCH/r3/run-poshqc-927.ps1`; `grep -c -F -e 'POSHQC_EXIT_CODE=' SCRATCH/r3/run-poshqc-927.sh`; `awk '/\r/{n++} END{print n+0}' SCRATCH/r3/run-poshqc-927.sh`. Acceptance: the five greps print `1` each; the `awk` count prints `0` (no carriage return in the shell wrapper).
- [x] [P0-T5] Write `FEATURE/evidence/remediation-baseline/r3-poshqc-format.<timestamp>.md` (baseline format; write-mode tool observed by tree state). Commands: `mcp__drm-copilot__run_poshqc_format` with `scan_folders` = `SCAN_QC`; `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`. Acceptance: `MCP_CALL: returned`; the status prints nothing (no PowerShell file was modified before the call, per [P0-T2], so an empty status means the formatter rewrote none). Any listed path stops the plan as BLOCKED with `BASELINE_FORMAT_DRIFT: <path>` lines; the executor does not revert it.
- [x] [P0-T6] Write `FEATURE/evidence/remediation-baseline/r3-poshqc-analyze.<timestamp>.md` (baseline analyze). Commands: `mcp__drm-copilot__run_poshqc_analyze` with `scan_folders` = `SCAN_QC`; `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`. Acceptance: `MCP_CALL: returned`; the status prints nothing. `MCP_CALL: error` stops the plan as BLOCKED.
- [x] [P0-T7] Write `FEATURE/evidence/remediation-baseline/r3-coverage-baseline.<timestamp>.md` (baseline coverage and test totals of the reviewed code). `R2_ROUTE_B` is the lexicographically greatest file matching `FEATURE/evidence/qa-gates/r2-pa1r-route-b.*.md` (the cycle 2 full-population route B record of the code that the review 2026-10-16T11-19 examined); its name is recorded as `R3_BASE_SOURCE: <file name>`. Command: `grep -E -e '^(REPORT_LINE|JUNIT_TOTALS|COVERAGE_RESULT): '` on that file. Acceptance: the grep prints nine lines, copied verbatim with the prefix `R3_BASE ` (one `REPORT_LINE` with `line_pct=90.33`, one `JUNIT_TOTALS` with `tests=10606 failures=0 errors=0`, and seven `COVERAGE_RESULT`, of which the two helper-copy lines show `line_pct=97.54`). These values are the baseline for [P3-T7].
- [x] [P0-T8] Commit and push Phase 0 (rule R3-12). Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record R3 remediation baseline evidence`.

### Phase 1 — Regression Rows (expect-fail)

- [x] [P1-T1] Apply Appendix T edits TF3-1 to TF3-5 to `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` with Edit. Acceptance: `grep -c '^' tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` prints `206`; `grep -c -F -e 'Events -join' tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` prints `2`; `grep -c -F -e 'simulated read fault' tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` prints `1`; `grep -c -F -e 'a read check faults' tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` prints `1`; `grep -c -F -e '-ReadFaults $ReadFaults' tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` prints `1`.
- [x] [P1-T2] Apply Appendix T edits TD3-1 and TD3-2 to `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` with Edit. Acceptance: `grep -c '^' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `243`; `grep -c -F -e 'the process emits LF-terminated lines' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `1`; `grep -c -F -e '-Text $Text' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `1`; `grep -c -F -e '$Milliseconds -ge 0' tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` prints `1`.
- [x] [P1-T3] [expect-fail] Write `FEATURE/evidence/regression-testing/r3-expect-fail.<timestamp>.md` (helper not yet edited). Commands: `stat -c %Y artifacts/pester/pester-junit.xml` (before; recorded as `absent` when it exits non-zero, and the exit code is recorded on its labelled line); `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `SCAN_FAIL`; `stat -c %Y artifacts/pester/pester-junit.xml` (after); `grep -m 1 -o -E '<testsuites [^>]*>' artifacts/pester/pester-junit.xml` (record only `tests`, `failures`, `errors`); for each token of Appendix R the command `grep -c -F -e '<token>" status="<status>"' artifacts/pester/pester-junit.xml` with status `Failed` for the four tokens F7, F8, F9, F14 and status `Passed` for the seventeen tokens F1 to F6, F10 to F13, and D1 to D7. Per rule R3-1 the artifact's `Command:` is the first `stat` call. Acceptance: the MCP call is recorded as `MCP_CALL: error <message>`, and the exit code in the message equals the JUnit `failures` value (Pester exits with the failed-test count; cycle 2 recorded `MCP_CALL: error Command exited with code 14.` for 14 failures). A returned (ok) result, or an error message that reports a different code or no code, fails this task; the after-mtime is greater than the before-mtime (any value when `absent`); `failures` equals `4` and `errors` equals `0`; each of the twenty-one token counts prints `1`. When the twenty-one token counts print `1` but `failures` is above `4`, the executor also runs `grep -o -E 'testcase name="[^"]*" status="Failed"' artifacts/pester/pester-junit.xml`, records each failing name other than F7, F8, F9, and F14 as an `R3_LOCAL_FAILED: <test name>` line (names only, rule R3-2), and stops the run for caller decision. Any other result stops the plan for revision of Appendix T.

### Phase 2 — Implementation

- [x] [P2-T1] Apply Appendix H edits H3-1 then H3-2 to `.claude/hooks/hook-docs-only-diff.ps1` with Edit (rule R3-7). Acceptance: `grep -c '^' .claude/hooks/hook-docs-only-diff.ps1` prints `493`; `grep -c -F -e '$null = $pendingRead.Wait(0)' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e '$errorRead = $process.StandardError.ReadToEndAsync()' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e 'checked once without waiting' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e '& $ProcessStarter $startInfo' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e '$process.Dispose()' .claude/hooks/hook-docs-only-diff.ps1` prints `1`; `grep -c -F -e '$null = $process.StandardError.ReadToEndAsync()' .claude/hooks/hook-docs-only-diff.ps1` prints `0` (exit 1, recorded on its labelled line).
- [x] [P2-T2] Write `FEATURE/evidence/qa-gates/r3-helper-copies.<timestamp>.md`. Commands: `cp .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1`; `cp .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1`; `cp .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1`; `cmp -s` of the canonical helper against each copy; `git hash-object` on the four paths. Acceptance: the three `cp` and three `cmp -s` calls exit 0; the four hashes are equal and are recorded as `R3_HELPER_HASH: <40-hex>`.
- [x] [P2-T3] Write `FEATURE/evidence/qa-gates/r3-helper-structure.<timestamp>.md`. Commands: `grep -c '^'` on the four helper paths; `grep -c -F -e '$null = $pendingRead.Wait(0)'` on the four helper paths; `git diff --stat R3_START_HEAD -- .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1` with the [P0-T2] value substituted (worktree against the start commit); `git status --porcelain -- .claude .codex extensions tests`. Acceptance: the line counts print `493` four times; the `pendingRead` counts print `1` four times; the diff prints nothing; the status lists exactly the four helper paths and the two test suites of Phase 1, each with status ` M`.
- [x] [P2-T4] Commit and push Phases 1 and 2 (rule R3-12). Paths: `.claude/hooks/hook-docs-only-diff.ps1`, `.codex/hooks/hook-docs-only-diff.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1`, `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1`, `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`, `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `fix(927): settle output reads before disposal and cover the Codex trim (CR-N1, CR-N2)`. This commit is the initial `R3_FINAL_CODE_COMMIT` (rule R3-13).

### Phase 3 — Final QC Loop

Restart rule: run [P3-T1] to [P3-T8] in order. If [P3-T1] or [P3-T2] changes a file, or any of [P3-T1] to [P3-T7] fails without a stated branch, apply the fix (a fixed helper is re-copied by repeating [P2-T2]), commit and push the fix per rule R3-12 (paths: each fixed file, its copies, and `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`; subject `fix(927): R3 final QC loop pass <n> corrections`; this commit becomes `R3_FINAL_CODE_COMMIT`), and restart at [P3-T1]. Each pass writes new artifacts with new write-time stamps. The loop ends only when one pass completes [P3-T1] to [P3-T8] with no failure and no file change. Type checking does not apply to PowerShell. A stop condition of [P3-T6] stops the run instead of restarting.

- [x] [P3-T1] Write `FEATURE/evidence/qa-gates/r3-qc-format.<timestamp>.md` (QC step 1; write-mode tool observed by tree state). Commands: `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` (before); `mcp__drm-copilot__run_poshqc_format` with `scan_folders` = `SCAN_QC`; `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` (after). Acceptance: `MCP_CALL: returned`; both status commands print nothing (all code changes are committed at [P2-T4] or by the restart rule), meaning the formatter rewrote no PowerShell file in this pass. When the after-status lists a path, the executor records `FORMAT_REWRITE: <path>` and the output of `git diff HEAD -- <path>` for each, keeps the formatter output as the fix, and applies the restart rule.
- [x] [P3-T2] Write `FEATURE/evidence/qa-gates/r3-qc-analyze.<timestamp>.md` (QC step 2). Commands: `mcp__drm-copilot__run_poshqc_analyze` with `scan_folders` = `SCAN_QC`; `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'`. Acceptance: `MCP_CALL: returned`; the status prints nothing. The analyzer finding count is read from the CI `Analyze PowerShell` step at [P4-T2].
- [x] [P3-T3] Write `FEATURE/evidence/qa-gates/r3-qc-parity.<timestamp>.md`. Commands: `cmp -s .claude/hooks/hook-docs-only-diff.ps1 <copy>` for the three copies; `git hash-object` on the four helper paths; `grep -c '^'` on the four helper paths, `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1`, `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`, and `.claude/hooks/enforce-epic-merge-gate.ps1`. Acceptance: the three `cmp -s` calls exit 0; the four hashes are equal and equal `R3_HELPER_HASH` (or a value recorded as `R3_HELPER_HASH_FINAL:` after a loop fix of the helper); the counts print `493` four times, then `206`, `243`, and `491`, each below `500` (after a formatter rewrite, the post-format count of the rewritten file and of its copies is expected and recorded as `LINE_COUNT_SOURCE: <path> post-format <n>`; any value of `500` or more fails this task and stops the plan for revision).
- [x] [P3-T4] Write `FEATURE/evidence/qa-gates/r3-qc-test-purity.<timestamp>.md` (rule R3-10). Command: `grep -c -E -e 'Mock (git|gh)( |$)|Mock .(git|gh). |function (git|gh) |Start-Process|Start-Sleep|TestDrive|New-TemporaryFile|GetTempFileName|GetTempPath|env:TEMP|ProcessStartInfo' tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`. Acceptance: both printed counts are `0`; `EXIT_CODE: 1` is recorded with `ExpectedExitCode: 1` (the only command of this artifact).
- [x] [P3-T5] Write `FEATURE/evidence/qa-gates/r3-qc-pytest-contracts.<timestamp>.md` (bundle parity of the copies). Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q`. Acceptance: exit 0 and the final summary line, recorded verbatim, reports `passed` with no `failed` or `error` count.
- [x] [P3-T6] Write `FEATURE/evidence/qa-gates/r3-pester-route-b.<timestamp>.md` (QC step 3; the last Pester run of this cycle, rule R3-6). Commands: `date -u +%s` (recorded as `RUN_START_EPOCH:`); `sh SCRATCH/r3/run-poshqc-927.sh SCRATCH/r3/run-poshqc-927.ps1 SCRATCH/r3/direct-run.log`, run with the Bash tool's background option because the full population exceeds the foreground time limit, waiting for its completion notification and never starting a second run while the first is live; `grep -F -e 'POSHQC_EXIT_CODE=' SCRATCH/r3/direct-run.log`; `stat -c %Y artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml`; rule R3-READ steps K1 to K4 (section 5). Acceptance: per rule R3-1, `Command: date -u +%s`, and the run is recorded on the labelled lines `Command 2: sh SCRATCH/r3/run-poshqc-927.sh SCRATCH/r3/run-poshqc-927.ps1 SCRATCH/r3/direct-run.log` and `EXIT_CODE_2: <exit code from the completion notification>`; the grep prints `POSHQC_EXIT_CODE=0`; both mtimes are greater than `RUN_START_EPOCH`; the R3-READ pass condition holds; the artifact ends with `R3_PESTER: SATISFIED`. Branches: a failing token of suite F or suite D (K3) fails this task and applies the restart rule. Stop conditions: a denial of the `sh` command is recorded verbatim as `ROUTE_B_DENIAL: <text>` with `R3_PESTER: BLOCKED` and stops the run (rule R3-8); a JUnit `failures` or `errors` value above `0` whose failing names are all outside suites F and D is recorded as `R3_LOCAL_FAILED: <test name>` lines (names only, rule R3-2) with `R3_PESTER: REMEDIATION_REQUIRED` and stops the run for caller decision; any other failed condition records `R3_PESTER: REMEDIATION_REQUIRED <reasons>` and stops the run.
- [x] [P3-T7] Write `FEATURE/evidence/qa-gates/r3-coverage-delta.<timestamp>.md` (baseline vs post-change vs changed code). Commands: `git diff -U0 R3_START_HEAD HEAD -- .claude/hooks/hook-docs-only-diff.ps1` with the [P0-T2] value substituted; `grep -n -F -e '$null = $pendingRead.Wait(0)' .claude/hooks/hook-docs-only-diff.ps1`; `grep -n -F -e '$text = $text.Substring(0, $text.Length - 1)' .codex/hooks/hook-docs-only-diff.ps1`; `poetry run python -I SCRATCH/r3/read_coverage_927.py artifacts/pester/powershell-coverage.xml .claude/hooks/hook-docs-only-diff.ps1:<CHANGED_LINES> .codex/hooks/hook-docs-only-diff.ps1:<CHANGED_LINES>`; `poetry run python -I SCRATCH/r3/read_coverage_927.py artifacts/pester/powershell-coverage.xml .codex/hooks/hook-docs-only-diff.ps1:<TRIM_LINE>`. `<CHANGED_LINES>` is the comma-separated list of lines `c` to `c + d - 1` of every hunk header `@@ -a,b +c,d @@` (`+c` alone means `d = 1`) with `d > 0`, recorded as `CHANGED_LINES: <list>`; `<TRIM_LINE>` is the line number printed by the third command, recorded as `TRIM_LINE: <n>`. Content: `REPO_LINE_BASELINE:` and `REPO_LINE_POST:` (from the [P0-T7] `R3_BASE REPORT_LINE` line and the [P3-T6] artifact of this pass), `FILE_BASELINE:` and `FILE_POST:` for the seven files, the `LINE_RESULT:` lines verbatim, and `CHANGED_CODE: .claude/hooks/hook-docs-only-diff.ps1 covered=<n> executable=<n> pct=<x>`, where `executable` counts lines not reported `NOT_EXECUTABLE_OR_ABSENT` and `covered` counts those with `ci` above `0`. Acceptance: `REPO_LINE_POST` is at least 85.00%; each `FILE_POST` is at least 85.00%; the `FILE_POST` of each helper copy is at least its `FILE_BASELINE` (97.54%); on `.claude/hooks/hook-docs-only-diff.ps1` `covered` equals `executable`, and the line printed by the second command reports `ci` above `0`; the `TRIM_LINE` result for `.codex/hooks/hook-docs-only-diff.ps1` reports `ci` above `0` (CR-N2); the other `.codex/hooks/hook-docs-only-diff.ps1` changed lines are recorded for information (decision D-R3-2). A failed condition fails this task and applies the restart rule.
- [x] [P3-T8] Write `FEATURE/evidence/qa-gates/r3-qc-loop-record.<timestamp>.md`. Command recorded: `R3 final QC loop per Phase 3 restart rule`; `EXIT_CODE: 0`. Acceptance: the artifact lists each pass as `LOOP_PASS: <n> RESULT: <clean|restarted at P3-T1 because ...>`; its last pass is `clean` and names the [P3-T1] to [P3-T7] artifacts of that pass; it records `R3_FINAL_CODE_COMMIT: <40-hex>` from `git log -1 --format=%H -- .claude .codex extensions tests`.
- [x] [P3-T9] Commit and push the Phase 3 evidence (rule R3-12). Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record R3 final QC loop`. The XML files are not staged (they are gitignored; rule R3-11).

### Phase 4 — CI on the Final Code Commit

- [x] [P4-T1] Write `FEATURE/evidence/qa-gates/r3-ci-run.<timestamp>.md`. Commands: `git rev-parse HEAD`; `git rev-parse origin/bug/pr-author-docs-only-exemption-hardening-927`; `git diff --name-only R3_FINAL_CODE_COMMIT HEAD` with the [P3-T8] value substituted; `git status --porcelain`; `gh workflow run ci.yml --ref bug/pr-author-docs-only-exemption-hardening-927`; `gh run list --workflow ci.yml --branch bug/pr-author-docs-only-exemption-hardening-927 --event workflow_dispatch --json databaseId,headSha,status,conclusion,createdAt --limit 10`. Acceptance: the two `rev-parse` values are equal and recorded as `R3_CI_HEAD: <40-hex>`; every path listed by the diff and every status line is under `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/`; the dispatch exits 0; the newest listed run whose `headSha` equals `R3_CI_HEAD` is recorded as `R3_CI_RUN_ID: <databaseId>`. When no listed run matches yet, the executor reruns only the list command until one appears (this task authorizes that repetition; it never dispatches twice while a matching run is queued or in progress).
- [x] [P4-T2] Write `FEATURE/evidence/qa-gates/r3-ci-jobs.<timestamp>.md`. Commands (the [P4-T1] run id substituted): `gh run watch R3_CI_RUN_ID --interval 60 --exit-status` (background option allowed, as in [P3-T6]); `gh run view R3_CI_RUN_ID --json headSha,status,conclusion`; `gh run view R3_CI_RUN_ID --json jobs --jq '.jobs[] | [.name, .conclusion] | @tsv'`; `gh run view R3_CI_RUN_ID --json jobs --jq '.jobs[] | .name as $j | .steps[] | [$j, .name, .conclusion] | @tsv'`. Acceptance: the watch exits 0; `headSha` equals `R3_CI_HEAD` and `conclusion` is `success`; every job row reads `success` or `skipped`, and the rows `poshqc / PowerShell QC` (windows-latest, every suite with coverage) and `poshqc / PowerShell hook suites (Linux)` (ubuntu-latest, `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, no coverage) each read `success`; among the step rows whose first field is `poshqc / PowerShell QC`, the steps `Format PowerShell`, `Analyze PowerShell`, and `Test PowerShell` each read `success`. All rows are recorded verbatim with `R3_CI_RUN_ID` and `R3_CI_HEAD`. A failure records the failing job and step names and `R3_CI: REMEDIATION_REQUIRED`, and stops the run.

### Phase 5 — Acceptance Re-verification and Remediation Closure

- [x] [P5-T1] Write `FEATURE/evidence/qa-gates/r3-ac-reverification.<timestamp>.md`. Command recorded: `AC re-verification against R3 Phase 3 and Phase 4 evidence`; `EXIT_CODE: 0`. Content: one line per criterion: `AC-<id>: REVERIFIED <artifact names>` for AC-M1 to AC-M22, AC-1 to AC-8, AC-10, AC-11, AC-12, AC-20, and AC-22 (each citing the [P3-T6] artifact and the [P3-T3] parity artifact of the clean pass); `AC-<id>: UNAFFECTED <reason>` for AC-M25 and AC-13 to AC-17 (no file in their scope changed in R3, per the [P2-T3] diff and status); `AC-<id>: PENDING_CI_SUPPORTED R3_CI_RUN_ID=<id> <values>` for AC-9, AC-18, AC-19, AC-21, AC-M23, and AC-M24 (values from [P4-T2] and the [P3-T7] `FILE_POST` lines; check-off stays with the original plan Phase 8). Acceptance: `grep -c -E '^AC-M?[0-9]+: REVERIFIED '` on the artifact prints `35`; `grep -c -E '^AC-M?[0-9]+: UNAFFECTED '` prints `6`; `grep -c -E '^AC-M?[0-9]+: PENDING_CI_SUPPORTED '` prints `6`.
- [x] [P5-T2] Write `FEATURE/evidence/qa-gates/r3-ac-state.<timestamp>.md` (`spec.md` is not edited in R3). Commands: `grep -c -E '^- \[x\] AC-M?[0-9]+ ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`; `grep -c -E '^- \[ \] AC-(9|18|19|21|M23|M24) ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md`; `git diff --stat R3_START_HEAD -- docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/spec.md` with the [P0-T2] value substituted. Acceptance: the counts print `41` and `6`; the diff prints nothing.
- [x] [P5-T3] Write `FEATURE/evidence/qa-gates/r3-remediation-closure.<timestamp>.md`. Command recorded: `R3 remediation closure`; `EXIT_CODE: 0`. Content, one line each: `CR-N1: CLOSED r3-expect-fail r3-helper-structure r3-pester-route-b r3-coverage-delta`; `CR-N2: CLOSED r3-pester-route-b r3-coverage-delta TRIM_LINE ci above 0`; `DECISION D-R3-1: expiry branch checks each read once with Wait(0) before disposal; limits and the 20 s worst case unchanged; residual: a read still pending at the check is abandoned and a later fault after disposal is not observed (no added wait, per D-RUN-10)`; `DECISION D-R3-2: changed-line coverage on the canonical helper; Codex copy by whole-file coverage and the trim line`; `LOCAL_XML_STATE: artifacts/pester/powershell-coverage.xml and pester-junit.xml are the full-population route B output of the clean pass; no later task of this cycle runs Pester or a PoshQC MCP test locally`; `REVIEW_READ_PATH: the feature-review coverage hook reads artifacts/pester/powershell-coverage.xml relative to its working directory (.claude/hooks/validate-feature-review-coverage-metrics.ps1 lines 25 and 176); the next feature-review must run with <WORKSPACE_ROOT> as its working directory, and no Pester or PoshQC MCP test run may occur in this worktree before it`. Acceptance: `grep -c -E '^CR-N[12]: CLOSED '` on the artifact prints `2`; `grep -c -E '^DECISION D-R3-[12]: '` prints `2`; `grep -c -F -e 'LOCAL_XML_STATE:'` prints `1`; `grep -c -F -e 'REVIEW_READ_PATH:'` prints `1`.
- [x] [P5-T4] Commit and push Phases 4 and 5 (rule R3-12). Commands before the commit: `git diff --name-only R3_FINAL_CODE_COMMIT HEAD` with the [P3-T8] value substituted; `git status --porcelain`. Acceptance (in addition to rule R3-12): every path listed by the diff and every status line is under `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/`. Paths: `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927`. Subject: `docs(927): record R3 CI run, acceptance re-verification, and closure`.

---

## 5. Rule R3-READ (reading the regenerated local XML)

`<COV>` is `artifacts/pester/powershell-coverage.xml`; `<JUNIT>` is `artifacts/pester/pester-junit.xml`. Reader output is copied verbatim into the calling artifact, with each exit code on its labelled line.

- **K1** `poetry run python -I SCRATCH/r3/read_report_totals_927.py <COV> <JUNIT>`: prints `REPORT_LINE:` (report-level LINE counter) and `JUNIT_TOTALS:` (`<testsuites>` root).
- **K2** `poetry run python -I SCRATCH/r3/read_hook_aggregate_927.py <COV>`: prints `HOOK_AGGREGATE_LINE:`, the sum over every `LINE` counter that `.claude/hooks/validate-feature-review-coverage-metrics.ps1` computes for the path at line 176, compared against the 85% floor.
- **K3** for each of the twenty-one tokens of Appendix R: `grep -c -F -e '<token>" status="Passed"' <JUNIT>`; and `grep -o -E 'testcase name="[^"]*" status="Failed"' <JUNIT>` (failing names only).
- **K4** `poetry run python -I SCRATCH/r3/read_coverage_927.py <COV> .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .codex/hooks/enforce-epic-merge-gate.ps1`: one `COVERAGE_RESULT:` line per file; `CLASS_COUNT=0` means the file has no entry.

**Pass condition:** K1 exits 0, `REPORT_LINE:` shows `result=PASS`, and `JUNIT_TOTALS:` shows `tests` of at least `10000` (cycle 2 route B reported 10606; this cycle adds two rows), `failures=0`, and `errors=0`; K2 exits 0 and shows `result=PASS`; every K3 count prints `1` and the failed-name grep prints nothing (exit 1, recorded on its labelled line); K4 exits 0 and prints seven `COVERAGE_RESULT:` lines, each with `result=PASS`.

---

## 6. Appendix H — edits to `.claude/hooks/hook-docs-only-diff.ps1` (484 lines before, 493 after)

**H3-1** (help text, +1 line). Old (lines 168-169; 8 leading spaces):

```powershell
        because the seams read it after the invoker, as they do after a native command.
        The process object is disposed on every return path once it has started.
```

New:

```powershell
        because the seams read it after the invoker, as they do after a native command.
        The process object is disposed on every return path once it has started.
        After an expired wait, each read is checked once without waiting before disposal.
```

**H3-2** (body, +8 lines). Old (lines 203-213 before H3-1; 204-214 after it; the first line at 8 leading spaces):

```powershell
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
```

New:

```powershell
        $errorRead = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit($TimeoutMilliseconds) -or -not $output.Wait(1000)) {
            try {
                $process.Kill($true)
            }
            catch {
                $null = $_
            }
            foreach ($pendingRead in @($output, $errorRead)) {
                try {
                    $null = $pendingRead.Wait(0)
                }
                catch {
                    $null = $_
                }
            }
            Set-Variable -Name LASTEXITCODE -Value 124 -Scope Global
            return
        }
```

The statements `$process = & $ProcessStarter $startInfo` (line 200 before H3-1), `try {` (line 201), `$output = $process.StandardOutput.ReadToEndAsync()` (line 202), the normal path (lines 214-224), and `finally { $process.Dispose() }` (lines 226-228) are unchanged.

## 7. Appendix T — test edits

Suite F `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` (194 lines before; 206 after). Line numbers are before any edit; each Edit matches its old text, which is unique in the file.

**TF3-1** (fake process, +9 lines). Old (lines 22-26; 12 leading spaces):

```powershell
            param([bool] $Exits = $true, [bool] $OutputCompletes = $true, [bool] $KillThrows = $false, [int] $ExitCode = 0, [string] $Text = '')
            $output = [pscustomobject]@{ Result = $Text; Completes = $OutputCompletes; Limit = 0 }
            $output | Add-Member -MemberType ScriptMethod -Name Wait -Value { param([int] $Milliseconds) $this.Limit = $Milliseconds; $this.Completes }
            $drain = [pscustomobject]@{ Result = 'ignored error text' }
            $process = [pscustomobject]@{ ExitCode = $ExitCode; Exits = $Exits; KillThrows = $KillThrows; Killed = $false; Disposed = $false; WaitLimit = 0; StandardOutput = [pscustomobject]@{ Task = $output }; StandardError = [pscustomobject]@{ Task = $drain } }
```

New:

```powershell
            param([bool] $Exits = $true, [bool] $OutputCompletes = $true, [bool] $KillThrows = $false, [int] $ExitCode = 0, [string] $Text = '', [bool] $ReadFaults = $false)
            $events = [System.Collections.Generic.List[string]]::new()
            $output = [pscustomobject]@{ Result = $Text; Completes = $OutputCompletes; Limit = 0; Events = $events }
            $output | Add-Member -MemberType ScriptMethod -Name Wait -Value { param([int] $Milliseconds) $this.Limit = $Milliseconds; $this.Events.Add("output-wait $Milliseconds"); $this.Completes }
            $drain = [pscustomobject]@{ Result = 'ignored error text'; Faults = $ReadFaults; Events = $events }
            $drain | Add-Member -MemberType ScriptMethod -Name Wait -Value {
                param([int] $Milliseconds)
                $this.Events.Add("error-wait $Milliseconds")
                if ($this.Faults) {
                    throw 'simulated read fault'
                }
                return $true
            }
            $process = [pscustomobject]@{ ExitCode = $ExitCode; Exits = $Exits; KillThrows = $KillThrows; Killed = $false; Disposed = $false; Events = $events; WaitLimit = 0; StandardOutput = [pscustomobject]@{ Task = $output }; StandardError = [pscustomobject]@{ Task = $drain } }
```

**TF3-2** (dispose records its event, in place). Old (line 37; 12 leading spaces):

```powershell
            $process | Add-Member -MemberType ScriptMethod -Name Dispose -Value { $this.Disposed = $true }
```

New:

```powershell
            $process | Add-Member -MemberType ScriptMethod -Name Dispose -Value { $this.Disposed = $true; $this.Events.Add('dispose') }
```

**TF3-3** (row F1, +1 line; normal path unchanged). Old (lines 84-85; 12 leading spaces):

```powershell
            $script:DocsOnlyFakeProcess.StandardOutput.Task.Limit | Should -Be 1000
            $script:DocsOnlyFakeProcess.Disposed | Should -BeTrue -Because 'the runner disposes the process object on every return path'
```

New:

```powershell
            $script:DocsOnlyFakeProcess.StandardOutput.Task.Limit | Should -Be 1000
            $script:DocsOnlyFakeProcess.Disposed | Should -BeTrue -Because 'the runner disposes the process object on every return path'
            ($script:DocsOnlyFakeProcess.Events -join '|') | Should -BeExactly 'output-wait 1000|dispose' -Because 'a read is checked without waiting only after an expired wait'
```

**TF3-4** (rows F7 to F9 gain two keys; new row F14, +1 line). Old (lines 121-127; `It` and `) {` at 8 leading spaces, the rest at 12):

```powershell
        It 'stops the process tree, emits nothing, and reports 124 when <Name> (issue #927)' -ForEach @(
            @{ Name = 'the exit wait expires'; Exits = $false; OutputCompletes = $true; KillThrows = $false; Killed = $true }
            @{ Name = 'the output wait expires'; Exits = $true; OutputCompletes = $false; KillThrows = $false; Killed = $true }
            @{ Name = 'stopping the process throws'; Exits = $false; OutputCompletes = $true; KillThrows = $true; Killed = $false }
        ) {
            # Arrange: the row supplies which wait expires and whether stopping the process throws.
            $script:DocsOnlyFakeProcess = Get-DocsOnlyFakeProcess -Exits $Exits -OutputCompletes $OutputCompletes -KillThrows $KillThrows -Text 'docs/a.md'
```

New:

```powershell
        It 'stops the process tree, emits nothing, and reports 124 when <Name> (issue #927)' -ForEach @(
            @{ Name = 'the exit wait expires'; Exits = $false; OutputCompletes = $true; KillThrows = $false; ReadFaults = $false; Killed = $true; Order = 'output-wait 0|error-wait 0|dispose' }
            @{ Name = 'the output wait expires'; Exits = $true; OutputCompletes = $false; KillThrows = $false; ReadFaults = $false; Killed = $true; Order = 'output-wait 1000|output-wait 0|error-wait 0|dispose' }
            @{ Name = 'stopping the process throws'; Exits = $false; OutputCompletes = $true; KillThrows = $true; ReadFaults = $false; Killed = $false; Order = 'output-wait 0|error-wait 0|dispose' }
            @{ Name = 'a read check faults'; Exits = $false; OutputCompletes = $true; KillThrows = $false; ReadFaults = $true; Killed = $true; Order = 'output-wait 0|error-wait 0|dispose' }
        ) {
            # Arrange: the row supplies which wait expires, whether stopping the process throws, and whether checking a read faults.
            $script:DocsOnlyFakeProcess = Get-DocsOnlyFakeProcess -Exits $Exits -OutputCompletes $OutputCompletes -KillThrows $KillThrows -ReadFaults $ReadFaults -Text 'docs/a.md'
```

**TF3-5** (rows F7 to F9 and F14, +1 line). Old (lines 136-137; 12 leading spaces):

```powershell
            $script:DocsOnlyFakeProcess.WaitLimit | Should -Be 7000
            $script:DocsOnlyFakeProcess.Disposed | Should -BeTrue -Because 'the runner disposes the process object on every return path'
```

New:

```powershell
            $script:DocsOnlyFakeProcess.WaitLimit | Should -Be 7000
            $script:DocsOnlyFakeProcess.Disposed | Should -BeTrue -Because 'the runner disposes the process object on every return path'
            ($script:DocsOnlyFakeProcess.Events -join '|') | Should -BeExactly $Order -Because 'each read is checked once without waiting before the process object is disposed'
```

Expected rows before the helper edit: F7, F8, F9, and F14 fail on the last assertion (the recorded order is `dispose` or `output-wait 1000|dispose`, because the current runner makes no zero-length check); F1 passes, because the normal path records `output-wait 1000|dispose` before and after the edit. After the edit all four pass; F14 passes only if the new `catch` absorbs the simulated fault.

Suite D `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` (241 lines before; 243 after).

**TD3-1** (+1 line). Old (line 44; 12 leading spaces):

```powershell
            $drain = [pscustomobject]@{ Result = 'ignored error text' }
```

New:

```powershell
            $drain = [pscustomobject]@{ Result = 'ignored error text' }
            $drain | Add-Member -MemberType ScriptMethod -Name Wait -Value { param([int] $Milliseconds) $Milliseconds -ge 0 }
```

**TD3-2** (rows D1 to D4 gain a `Text` key; new row D7, +1 line). Old (lines 198-205; `It` and `) {` at 4 leading spaces, the rest at 8):

```powershell
    It 'runs the bounded runner when <Name> (codex copy, issue #927)' -ForEach @(
        @{ Name = 'the process exits in time'; Exits = $true; OutputCompletes = $true; KillThrows = $false; ExitCode = 0; Output = "docs/a.md`0"; Killed = $false }
        @{ Name = 'the exit wait expires'; Exits = $false; OutputCompletes = $true; KillThrows = $false; ExitCode = 124; Output = ''; Killed = $true }
        @{ Name = 'the output wait expires'; Exits = $true; OutputCompletes = $false; KillThrows = $false; ExitCode = 124; Output = ''; Killed = $true }
        @{ Name = 'stopping the process throws'; Exits = $false; OutputCompletes = $true; KillThrows = $true; ExitCode = 124; Output = ''; Killed = $false }
    ) {
        # Arrange: the row supplies which wait expires and whether stopping the process throws.
        $script:CodexDocsOnlyFakeProcess = Get-CodexDocsOnlyFakeProcess -Exits $Exits -OutputCompletes $OutputCompletes -KillThrows $KillThrows -Text "docs/a.md`0"
```

New:

```powershell
    It 'runs the bounded runner when <Name> (codex copy, issue #927)' -ForEach @(
        @{ Name = 'the process exits in time'; Exits = $true; OutputCompletes = $true; KillThrows = $false; Text = "docs/a.md`0"; ExitCode = 0; Output = "docs/a.md`0"; Killed = $false }
        @{ Name = 'the exit wait expires'; Exits = $false; OutputCompletes = $true; KillThrows = $false; Text = "docs/a.md`0"; ExitCode = 124; Output = ''; Killed = $true }
        @{ Name = 'the output wait expires'; Exits = $true; OutputCompletes = $false; KillThrows = $false; Text = "docs/a.md`0"; ExitCode = 124; Output = ''; Killed = $true }
        @{ Name = 'stopping the process throws'; Exits = $false; OutputCompletes = $true; KillThrows = $true; Text = "docs/a.md`0"; ExitCode = 124; Output = ''; Killed = $false }
        @{ Name = 'the process emits LF-terminated lines'; Exits = $true; OutputCompletes = $true; KillThrows = $false; Text = "a`nb`n"; ExitCode = 0; Output = 'a|b'; Killed = $false }
    ) {
        # Arrange: the row supplies the output text, which wait expires, and whether stopping the process throws.
        $script:CodexDocsOnlyFakeProcess = Get-CodexDocsOnlyFakeProcess -Exits $Exits -OutputCompletes $OutputCompletes -KillThrows $KillThrows -Text $Text
```

The D7 output `a|b` follows from the trim statement (`a`, LF, `b`, LF becomes `a`, LF, `b`, split into two lines); without the trim the split would add an empty third element. Each edit sits in an Arrange line, a row table, an Assert section, or a test-local fake; no Act line changes and no existing row name changes.

## Appendix R — JUnit row tokens

Each token is the tail of a `testcase name` value. F1 to F13 and D1 to D6 are unchanged from Appendix R of `remediation-plan.2026-10-16T11-20.md`; F14 and D7 are new.

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
- F14 `stops the process tree, emits nothing, and reports 124 when a read check faults (issue #927)`
- D1 `runs the bounded runner when the process exits in time (codex copy, issue #927)`
- D2 `runs the bounded runner when the exit wait expires (codex copy, issue #927)`
- D3 `runs the bounded runner when the output wait expires (codex copy, issue #927)`
- D4 `runs the bounded runner when stopping the process throws (codex copy, issue #927)`
- D5 `routes the default git invoker through the bounded runner (codex copy, issue #927)`
- D6 `routes the default gh invoker through the bounded runner (codex copy, issue #927)`
- D7 `runs the bounded runner when the process emits LF-terminated lines (codex copy, issue #927)`

## 8. WRITES

Repository paths this cycle may change (every other change is out of scope, rule R3-11):

- `.claude/hooks/hook-docs-only-diff.ps1` (Edit)
- `.codex/hooks/hook-docs-only-diff.ps1` (cp)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1` (cp)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1` (cp)
- `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1` (Edit)
- `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1` (Edit)
- `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/remediation-plan.2026-10-16T14-05.md` (this plan; checkbox updates)
- `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/remediation-inputs.2026-10-16T14-05.md` (committed unchanged at [P0-T8])
- `docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/**` (new artifacts only)

Gitignored tool output written by the Pester runs (not committed): `artifacts/pester/powershell-coverage.xml`, `artifacts/pester/pester-junit.xml`. Scratch files under `SCRATCH/r3/` are outside the repository.

## 9. Quoted literals created by this plan

Literals that acceptance conditions assert and that do not exist before their task runs: `$null = $pendingRead.Wait(0)`, `$errorRead = $process.StandardError.ReadToEndAsync()`, `checked once without waiting` (Appendix H); `Events -join`, `simulated read fault`, `a read check faults`, `-ReadFaults $ReadFaults`, `the process emits LF-terminated lines`, `-Text $Text`, `$Milliseconds -ge 0` (Appendix T); and the artifact lines `R3_BASE `, `R3_PESTER:`, `CR-N1: CLOSED `, `CR-N2: CLOSED `, `DECISION D-R3-1: `, `DECISION D-R3-2: `, `LOCAL_XML_STATE:`, `REVIEW_READ_PATH:`. Each is quoted verbatim in the task or appendix that creates it. The scratch-file tokens of [P0-T4] exist in the cited prior-plan appendices.
