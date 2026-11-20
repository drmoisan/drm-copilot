# Final QA — Cycle-2 Exit-Condition Reconciliation and Final Batch Close

Task: `[P5-T12]`
Timestamp: 2026-09-07T23-04
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)
Head at reconciliation: `06d166e0f47e4c377618384c8d2904ac0ab1a306`

**Result: PASS.** All twelve closure conditions read PASS. One condition's stated verification method
is a proxy that overshoots its own intent; that is recorded in full under condition 12 and the
condition is discharged on substantive checks instead of, and in addition to, the proxy.

## The twelve closure conditions

| # | Condition | Discharging task(s) | Evidence artifact | Result |
|---|---|---|---|---|
| 1 | All four R-2 instances fixed at their call sites | `[P2-T5]`, `[P2-T6]`, `[P3-T5]`, `[P3-T6]`, `[P4-T4]` | `evidence/qa-gates/batch-b-toolchain.2026-09-07T21-49.md`, `evidence/qa-gates/batch-c-toolchain.2026-09-07T22-04.md`, `evidence/qa-gates/batch-d-toolchain.2026-09-07T22-22.md` | **PASS** |
| 2 | `Test-CommandLineFlag` and `Get-CommandLineFlagValue` unchanged | this task | recorded inline below | **PASS** |
| 3 | All six fail-closed-correct call sites unchanged | `[P5-T3]` | `evidence/qa-gates/failclosed-call-sites-unchanged.2026-09-07T22-31.md` | **PASS** |
| 4 | All four instances pinned by decision-surface tests on every applicable side | `[P1-T7]`, `[P2-T8]`, `[P3-T9]`, `[P4-T6]` | `evidence/regression-testing/pass-after-r2-predicate.2026-09-07T21-20.md`, `pass-after-r2a-merge-gate.2026-09-07T21-43.md`, `pass-after-r2bc.2026-09-07T21-58.md`, `pass-after-r2d.2026-09-07T22-17.md` | **PASS** |
| 5 | Canonical/bundle byte parity for all seven pairs | `[P1-T6]`, `[P2-T7]`, `[P3-T7]`, `[P4-T5]` | `evidence/qa-gates/batch-a-parity.2026-09-07T21-18.md`, `batch-b-parity.2026-09-07T21-40.md`, `batch-c-parity.2026-09-07T21-55.md`, `batch-d-parity.2026-09-07T22-15.md` | **PASS** |
| 6 | Format, analyze, and test completed in a single pass | `[P5-T1]` | `evidence/qa-gates/final-qa-loop.2026-09-07T22-29.md` | **PASS** |
| 7 | Per-file coverage re-measured via `_poshqc.yml` dispatch; all seven at or above 85.0000 with no regression, each carrying a numeric baseline from run `34158596238` | `[P5-T7]`, `[P5-T8]` | `evidence/qa-gates/final-per-file-coverage.2026-09-07T22-55.md`, `evidence/qa-gates/final-coverage-delta.2026-09-07T22-56.md` | **PASS** |
| 8 | Frozen literals and the two abandon token assignments unchanged | `[P5-T5]` | `evidence/qa-gates/frozen-literals-unchanged.2026-09-07T22-53.md` | **PASS** |
| 9 | Every touched file at or under 500 lines; the 500-line Codex preimplementation gate untouched | `[P5-T6]` | `evidence/qa-gates/final-line-counts.2026-09-07T22-37.md` | **PASS** |
| 10 | AC-09 re-checked with cited evidence; AC-22 left unchecked | `[P5-T10]` | `spec.md` lines 1499 and 1565; `evidence/qa-gates/deny-preservation-audit.2026-09-07T22-59.md` | **PASS** |
| 11 | No file under `.claude/rules/` or `.github/instructions/` modified | this task | recorded inline below | **PASS** |
| 12 | No F-1 through F-7 fix and no attempt on the two ambient-state failures | `[P5-T4]` | `evidence/qa-gates/cycle-scope.2026-09-07T22-33.md`, plus the substantive checks recorded inline below | **PASS** |

Twelve of twelve PASS.

## Condition 1 — verified inline

Command: `grep -F -c 'Test-CommandLineSegmentRawScan' <path>` on each fix location.
EXIT_CODE: 0

| Path | Count | Required by |
|---|---|---|
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 1 | `[P2-T5]` |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 1 | `[P2-T6]` |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 2 | `[P3-T5]` |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 1 | `[P3-T6]` |
| `.claude/hooks/validate-bash.ps1` | 1 | `[P4-T4]` |

Every count equals the value its task's acceptance requires. The abandon gate carries 2 because the
raw-scan leg is needed in both `Test-ParallelAbandonSegmentDisposition` and
`Test-ParallelAbandonCommandConfirmed`.

## Condition 2 — verified inline

Command:
`git diff 26dba29533ba70f6cd80d14ac3c87ac24ca82aca -- .claude/hooks/hook-command-invocation.ps1 .codex/hooks/hook-command-invocation.ps1`
EXIT_CODE: 0
Observed output: **(no output)**

Neither `hook-command-invocation.ps1` copy changed in cycle 2, so `Test-CommandLineFlag` and
`Get-CommandLineFlagValue` — both defined in that file — are byte-unchanged on both runtimes. The
cycle-scope anchor `26dba295` remains an ancestor of the current head `06d166e0`, so this anchored
diff is still valid after the orchestrator's commit.

## Condition 11 — verified inline

Command:
`git diff --name-only 26dba29533ba70f6cd80d14ac3c87ac24ca82aca -- .claude/rules .github/instructions`
EXIT_CODE: 0
Observed output: **(no output)**

Command: `git status --porcelain .claude/rules .github/instructions`
EXIT_CODE: 0
Observed output: **(no output)**

Both spans are required and both are empty. The anchored name-listing diff is blind to an untracked
path; porcelain status goes empty once a change is committed. Together they establish that no policy
file was modified, in either the committed or the working-tree state.

## Condition 12 — the stated proxy overshoots; discharged on substance

The condition's stated verification method is "`[P5-T4]`'s scope enumeration containing none of the
files those follow-ups name". Applied literally, that proxy fails for three of the seven follow-ups,
because three of them name files this cycle legitimately edits for R-2:

| Follow-up | File(s) it names | In `[P5-T4]`'s twenty-one-path scope |
|---|---|---|
| F-1 | `hook-command-invocation.ps1` | no |
| F-2 | `enforce-epic-worktree-removal-gate.Tests.ps1`, `enforce-parallel-worktree-removal-gate.Tests.ps1` | no |
| F-3 | `.claude/hooks/validate-bash.ps1` | **yes** |
| F-4 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | no |
| F-5 | `.claude/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1` | **yes** |
| F-6 | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | **yes** |
| F-7 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | no |

The overshoot is a property of the proxy, not a finding about the work: the R-2 fix locations and
three of the follow-ups happen to sit in the same files, so file-level presence cannot distinguish
"this cycle edited the file for R-2" from "this cycle fixed the follow-up". The condition's intent is
the latter. It is therefore discharged on substantive per-follow-up checks, recorded below, with the
proxy result also recorded for the four follow-ups where it is decisive.

### F-1, F-2, F-4, F-7 — decided by the proxy

Command:
`git diff --name-only 26dba29533ba70f6cd80d14ac3c87ac24ca82aca -- .claude/hooks/hook-command-invocation.ps1 .codex/hooks/hook-command-invocation.ps1 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
EXIT_CODE: 0
Observed output: **(no output)**

Every file F-1, F-2, F-4, and F-7 name is unchanged in cycle 2. None of those four was attempted.
F-7 is additionally covered by `[P5-T6]`, which records
`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` still reading exactly `500`.

### F-3 — closes incidentally, by the plan's own disclosure; not remediated

F-3 is "a write-only constant that can drift": `$script:CdChainedReadCommandPattern` in
`.claude/hooks/validate-bash.ps1` was assigned and never read. The R-2.d fix adds a read of it at
line 292, which un-orphans it.

This is not an F-3 remediation and is not an unplanned side effect. The plan's Scope section states
it in advance: "Implementing it un-orphans `$script:CdChainedReadCommandPattern` … closing
code-review finding C-3 as a side effect with no separate task." No task in this plan addresses F-3's
own subject matter — whether a write-only constant should exist, how drift should be prevented, or
any change to the constant itself. The constant's declaration is byte-unchanged, confirmed by
`[P4-T4]` condition (3) and independently by `[P5-T5]`, whose group-6 row records an unpaired-removal
count of `0` for the pattern text.

### F-5 (EA-3) — not fixed; explicitly out of scope

F-5 is the epic merge gate authorizing any pull request. It names
`Test-ChildCheckpointAllowsEpicMerge` at `.claude/hooks/enforce-epic-merge-gate.ps1:177` and
`Test-CodexChildMergeReady` at `.codex/hooks/enforce-epic-merge-gate.ps1:69`.

Command:
`git diff 26dba29533ba70f6cd80d14ac3c87ac24ca82aca -- .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 | grep '^[-+][^-+]'`
EXIT_CODE: 0

The changed-line set contains **no `-` line at all** and its `+` lines are confined to the
`$hasMergeFlag` raw-scan fallback and its explanatory comment, on both runtimes. Nothing in
`Test-ChildCheckpointAllowsEpicMerge` or `Test-CodexChildMergeReady` was added, removed, or altered.
Both functions remain at their recorded lines — 177 in the Claude copy, 69 in the Codex copy —
confirmed by `grep -n`. EA-3 remains out of scope, unattempted and unfixed.

### F-6 — not fixed

F-6 is the abandon gate applying `-replace '\s+', ' '` before segmentation, which collapses
newlines.

Command:
`git diff 26dba29533ba70f6cd80d14ac3c87ac24ca82aca -- .claude/hooks/enforce-parallel-abandon-gate.ps1 | grep -n "replace"`
EXIT_CODE: 0
Observed output: one line, `7:         replaces. Because a quoted span is one token, a grep whose quoted search term is the`

That is an unchanged context line inside a doc comment — it carries a leading space, not a `+` or
`-`. No changed line in the abandon-gate diff touches the normalization.

Command: `grep -n -- "-replace" .claude/hooks/enforce-parallel-abandon-gate.ps1`
EXIT_CODE: 0
Observed output: `92:    return ($CommandText -replace '\s+', ' ').Trim()`

The normalization survives at line 92 in its original form. F-6 was not attempted.

### The two ambient-state failures — no attempt

Neither of the two tolerated failures was fixed or suppressed. They sit in suites this cycle did not
modify, and `[P5-T4]`'s enumeration contains no suite carrying them. Their status is unchanged: the
local `[P5-T1]` run at HEAD reports `tests="2408" errors="0" failures="2"`, the same two names the
plan tolerates. CI run `34181009673` on a clean checkout of the same head reports 4363 tests and 0
failures, which confirms the two failures are ambient to this workstation rather than defects
introduced or masked by this cycle.

### Condition 12 result

Seven of seven follow-ups unattempted and unfixed; both ambient-state failures unattempted. **PASS.**

## Budget reset (the `[P1-T1]` procedure)

Command: `ls -1 .claude/state/`
EXIT_CODE: 0
Pre-reset listing: **empty** (the directory contains only `./` and `../`).

`powershell-batch-budget.*.json` files observed: **none**. No contents to record, because no such
file exists.

Command: `rm -f .claude/state/powershell-batch-budget.*.json`
EXIT_CODE: 0

Command: `ls -1 .claude/state/`
EXIT_CODE: 0
Post-reset listing: **empty** (the directory contains only `./` and `../`). It contains no file whose
name begins `powershell-batch-budget.`

The exit code alone does not satisfy this step, because `rm -f` on an absent path also exits 0; the
post-reset listing is the observation that discharges it, and it is recorded above.

An empty pre-reset listing is a valid observation and is recorded as such. It is also the expected
observation here, and the reason is stated rather than left implicit: this execution group
(`[P5-T5]`, `[P5-T7]` through `[P5-T12]`) wrote **no** PowerShell production or test file. It wrote
only evidence markdown, the plan checklist, and one `spec.md` checkbox. The PreToolUse budget hook
therefore had no PowerShell write to record, so no budget file was created and none was expected.
This diverges from `[P1-T9]`, where batch A had written two production and two test PowerShell files
and one budget file was expected.

## Output Summary

All twelve cycle-2 closure conditions read PASS. Conditions 2 and 11 were verified inline against the
cycle-scope anchor `26dba295`, which remains an ancestor of head `06d166e0`; all three commands
produced no output. Condition 12's stated proxy — that `[P5-T4]`'s scope enumeration names none of
the follow-up files — overshoots for F-3, F-5, and F-6, whose files this cycle legitimately edits for
R-2; the condition was therefore discharged on substantive per-follow-up checks showing that F-1,
F-2, F-4, and F-7 touch no changed file, F-3's constant is byte-unchanged and its un-orphaning is the
plan's own pre-disclosed side effect, F-5's two authorization functions have no changed line, and
F-6's `-replace '\s+', ' '` survives unchanged at line 92. Neither ambient-state failure was
attempted; CI run `34181009673` reports 0 failures on a clean checkout of the same head. The final
batch closes with a budget reset: pre-reset listing empty, `rm -f` exit 0, post-reset listing empty
and carrying no `powershell-batch-budget.` file, with the empty pre-reset state explained by this
group having written no PowerShell file.
