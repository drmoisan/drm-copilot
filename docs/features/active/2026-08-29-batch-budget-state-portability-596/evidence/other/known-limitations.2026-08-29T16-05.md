# [P8-T3] Known limitations and residuals — issue #596

Timestamp: 2026-08-29T23-10

Command: `git -C . grep -n "accepted residual" -- docs/features/active/2026-08-29-batch-budget-state-portability-596/spec.md` (source reconciliation of this list against the spec's `## Risks & Mitigations` section, lines 781 through 796)

EXIT_CODE: 0

Output Summary: Eight limitations are recorded. The **six** the spec requires to remain visible are
items 1 through 6 and are reproduced from `spec.md` lines 786 through 796 without softening. Two
further items discovered during execution are recorded as items 7 and 8: the per-file PowerShell
coverage decline on both batch-budget hooks, and the two pre-existing PoshQC test failures that leave
the criterion on `spec.md` line 773 unchecked. Every item states what the limitation is, why it was
accepted rather than fixed, and what a consumer or a future maintainer should do about it.

## The six spec-mandated residuals

### 1. Concurrent sessions in the same worktree still share one counter

The session-identity fix resolves an identifier from, in order, `$env:CLAUDE_SESSION_ID`, the
contents of `<root>/.claude/state/current-session-id`, and a worktree-derived fallback. When two
concurrent agent sessions run in the **same** worktree and neither supplies a session id through the
first two sources, both fall through to the third, and the worktree-derived identifier is by
construction identical for both. The two sessions therefore share one batch-budget counter, and one
session's file edits consume the other's cap.

Status: **accepted residual, not a fixed defect.** The fix narrows the sharing from every session on
the machine to concurrent sessions in one worktree; it does not eliminate it. Eliminating it requires
a session id that the runtime supplies, which is item 6.

What to do about it: supply `CLAUDE_SESSION_ID` explicitly, or run concurrent sessions in separate
worktrees.

### 2. Windows 8.3 short-name paths are classified as out-of-root and under-counted

Containment is decided by a normalized, case-insensitive `StartsWith` comparison of the candidate
path against the resolved root. `Resolve-Path` and `[System.IO.Path]::GetFullPath` are deliberately
not used, so no short-name expansion occurs. A candidate expressed in Windows 8.3 short-name form —
for example a `PROGRA~1`-style segment — does not share a textual prefix with the long-form resolved
root even though it denotes a location inside it. Such a candidate is classified out-of-root and
discarded, so the edit is **not counted** against the batch budget.

Direction of the error: the budget under-counts. It does not deny an edit that should be allowed; it
allows one that should have consumed a slot.

Why accepted: introducing path canonicalization would make the hook touch the filesystem on every
invocation, which the hook's design deliberately avoids and which the Pester suites are structured to
keep out.

### 3. A CRLF destination `.gitignore` is rewritten wholly to LF on first delivery

`mergeClaudeGitignore` normalizes CRLF and lone CR to LF across the whole input before locating or
inserting the managed block. A destination repository whose `.gitignore` uses CRLF endings therefore
receives a file whose **every line** has changed, not merely the managed block, producing a large and
initially alarming diff in the consumer repository on the first delivery only. Subsequent deliveries
are stable, because the normalized file is a fixed point.

Why accepted: whole-file normalization is what makes the merge function a genuine fixed point and
keeps the idempotency criterion on `spec.md` line 741 satisfiable. A line-ending-preserving variant
would need to detect and reproduce the destination's prevailing convention, which multiplies the
merge cases without changing what git actually reads.

What to do about it: expect one large whitespace-only diff on the first delivery into a CRLF
repository, and review it as such.

### 4. A destination `!`-negation placed after the managed block still wins

Git applies last-match-wins semantics to `.gitignore` patterns. The writer inserts or replaces the
managed block in place and **does not reorder the destination's file**. A `!`-negation of a managed
entry that the destination places *after* the managed block therefore continues to override the
managed entry, and the delivered ignore has no effect for that pattern.

Why accepted: reordering a consumer's `.gitignore` would violate the criterion on `spec.md` line 745,
which requires unrelated destination entries to be preserved in their original relative order, and
would make the tool's behaviour depend on semantics it does not own.

What to do about it: a consumer who wants the managed entry to take effect must remove or relocate
the negation.

### 5. The delivered `.gitignore` is absent from the push-down summary

The post-copy merge runs after `enginePushDown` returns, writes through the raw injected `fs`
adapter, and returns the engine summary **unmodified**. The `PushDownSummary` schema is unchanged and
the delivered `.gitignore` is deliberately not added to its `files` list. A consumer reading the
summary artifact to learn what a push-down wrote will therefore not see the `.gitignore`, even though
it was written.

Why accepted: adding the path to the summary changes a published schema, which is a separate change
with its own compatibility surface. It is recorded in the spec's own follow-up list as a candidate
follow-up rather than as part of this feature.

### 6. Whether a Claude PreToolUse envelope carries `session_id` remains unknown

The Codex sibling hooks adopt a fail-closed posture keyed on an envelope-supplied session id. Whether
the Claude Code PreToolUse envelope carries a `session_id` field was **not** resolved by this work.
Because it is unknown, the Claude hooks retain the resolution chain described in item 1 rather than
reading the id from the envelope, and a future tightening to the Codex fail-closed posture is not yet
decidable.

Why accepted: resolving it requires observing a live envelope, which is an empirical question outside
this feature's change surface. The spec records it as the precondition for the follow-up.

## Two further limitations observed during execution

### 7. Per-file PowerShell line coverage declined on both batch-budget hooks

Both batch-budget hooks lost 1.8 percentage points of Pester LINE coverage against the pre-change
baseline. The figures are recorded here rather than rounded away.

| File | Baseline | Post-change | Delta | Floor 85 met | Margin |
| --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 95.6 (86/90) | 93.8 (121/129) | **-1.8 pp** | yes | +8.8 pp |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 95.6 (86/90) | 93.8 (121/129) | **-1.8 pp** | yes | +8.8 pp |
| `.claude/hooks/persist-session-id.ps1` | 86.8 (33/38) | 88.1 (37/42) | +1.3 pp | yes | +3.1 pp |
| Repository-wide | 94.7 (7236/7639) | 94.7 (7384/7795) | +0.0 pp | yes | +9.7 pp |

Cause. Each hook grew from 90 to 129 measured lines while missed lines grew from 4 to 8. The four
newly uncovered lines are defensive: two degenerate-input guards in the containment helper, and the
catch block that lets an unreadable `current-session-id` file fall through to the next resolution
source without throwing. The decline is a denominator effect from added defensive code, not the
removal of a test.

Why accepted: both files clear the 85 percent floor with 8.8 points of margin, and the uncovered
lines are error paths whose exercise would require injecting failures into seams the suites
deliberately keep filesystem-free. The declines are nonetheless real and are reported as declines.
Full treatment is in `evidence/qa-gates/coverage-delta.2026-08-29T16-05.md`.

### 8. Two pre-existing PoshQC test failures leave the line-773 criterion unchecked

The unscoped Pester run exits 2 with exactly two failures, so
`mcp__drm-copilot__run_poshqc_test` returns `ok: false` and the criterion on `spec.md` line 773 —
which requires format, analyze, and test to be **consecutively** clean — cannot be satisfied. Format
and analyze are clean and all three per-file coverage figures clear 85 percent; the test component is
the only unsatisfied one.

The two failures, verbatim:

```
enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
```

Evidence that the pair is pre-existing: both names are byte-identical to the [P0-T12] baseline pair
captured before any edit; the failure count held at exactly 2 while the discovered total rose from
3851 to 3904; and the owning suites,
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` and
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, appear in no diff this feature
produces. Two independent full runs produced byte-identical results, so the condition is stable
rather than flaky.

Why accepted: neither suite is touched by this feature, and repairing them would widen scope. The
criterion is left unchecked and the three correspondingly unsatisfiable plan tasks — [P7-T4],
[P7-T5], and [P7-T11] — are left unchecked with their artifacts present and their unmet acceptance
stated inside them.

What to do about it: repair the two suites in separate, independently scoped work, then re-run
`mcp__drm-copilot__run_poshqc_test` and check off `spec.md` line 773.
