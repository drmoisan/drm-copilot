# Issue update mirror — issue #596, remediation cycle 1 ([P6-T3])

Timestamp: 2026-08-30T01-53
Task: [P6-T3]
Issue: #596
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Command: this task authors an update mirror. It runs no toolchain stage.

EXIT_CODE: 0
ExpectedExitCode: 0

## POSTING BLOCKED

**Reason:** this executor is not authorized to post to GitHub in this run. The delegating directive
for Phase 5 and Phase 6 restricts the run to plan execution in the target worktree and prohibits
committing and pushing; it grants no issue-posting step, and no plan task instructs a post. The
[P6-T3] acceptance permits recording a `POSTING BLOCKED` header with the reason in place of
`PostedAs: body` or `PostedAs: comment`, and that is the branch taken.

Because the update was not posted as a body update, the conditional mirror into
`docs/features/active/2026-08-29-batch-budget-state-portability-596/issue.md` does **not** apply and
was not performed. That mirror is required only under `PostedAs: body`.

The orchestrator or a subsequent authorized step may post the text below verbatim.

---

## Exact text intended for issue #596

### Remediation cycle 1 complete — three findings closed

The cycle-1 remediation for #596 addressed exactly three findings from the
`2026-08-29T23-07` audit. All three are closed. No acceptance criterion in `spec.md` changed state:
the two Major findings were conformance defects against criteria already recorded as satisfied, and
the Minor finding closes a Test Strategy edge case that carries no criterion.

**B-1 (Major) — prefix collision in the batch-budget containment predicate.** The containment check
in both batch-budget hooks used
`StartsWith($normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase)` with no separator, so a
candidate in a sibling directory whose name merely extends the root — `/repo-sibling/scripts/tool.ps1`
against the root `/repo` — was wrongly classified as in-root and consumed a batch slot. The
comparison now combines an explicit `[string]::Equals` operand with
`StartsWith($normalizedRoot + '/', [System.StringComparison]::OrdinalIgnoreCase)`. The equality
operand deliberately preserves the pre-existing admission of a candidate equal to the root, which the
separator form alone would have rejected. Fixed in `.claude/hooks/enforce-powershell-batch-budget.ps1`,
`.claude/hooks/enforce-python-batch-budget.ps1`, and both bundle mirrors under
`extensions/drm-copilot/resources/claude-customizations/`; each hook and its mirror are byte-identical.
The replacement changed no line count, so both files remain at 457 and 454 lines.

**B-2 (Major) — `mergeClaudeGitignore` deleted every line following an unterminated managed block.**
At `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts:126`, an absent closing
sentinel set `endIndex` to `lines.length - 1`, so the slice after the block was empty and all
following content was dropped. An unterminated block is now treated as its opening sentinel line
alone, and every line after it is preserved in original order. The result is a fixed point with each
sentinel occurring exactly once. The well-formed path is untouched.

**B-3 (Minor, folded in) — the unreadable-session-id catch block was untested in both hook suites.**
One test per suite now drives `Get-*BatchBudgetSessionId` with a throwing `ReadSessionIdFile` seam
and asserts the fall-through to the worktree-derived identifier. No production line changed for this
finding.

### Test and coverage results

Three tests were added to each of the two Pester hook suites and one to the merge-module Jest suite.

- `enforce-powershell-batch-budget.Tests.ps1`: 33 to 36 passing, 0 failing.
- `enforce-python-batch-budget.Tests.ps1`: 32 to 35 passing, 0 failing.
- Full extension Jest suite: 2733 to 2734 passing, 203 suites, 0 failing.

Coverage moved in one direction only; nothing declined.

- Scoped per-file Pester LINE coverage, both hooks: **93.8 to 95.3 percent** (covered 121 to 123 of
  129). The two newly covered lines in each file are the B-3 catch bodies. No previously covered line
  became uncovered.
- Jest `All files`: lines held at **96.72 percent**; branches **90.16 to 90.17 percent**.
- Jest `claude-gitignore-merge.ts`: lines **98.78 to 98.79 percent**; branches **90 to 95 percent**,
  the rise attributable to the previously unexercised line-126 arm.

### Toolchain

The Phase 5 final QA loop converged in a single uninterrupted iteration: PoshQC format and analyze
both returned `ok: true`; the two scoped Pester suites passed; Prettier, ESLint, `tsc --noEmit`, and
Jest with coverage all exited 0. Both write-mode stages were checked by `git status --porcelain`
captures taken immediately before and after, and neither rewrote a file — Prettier visited 413 files
and reported every one unchanged.

### Out of scope, and still open

Advisory findings N-2 through N-6 were not addressed in this cycle. N-1 was addressed **in part
only**: the unreadable-session-id catch block it names is now covered, while the empty-root guard and
the null-or-whitespace path guard it also names remain uncovered.

The acceptance criterion at `spec.md:773` — all three PoshQC MCP tools passing in a single
consecutive run — remains unchecked. A clean unscoped Pester run is blocked by two pre-existing
failures outside this feature's scope: the `enforce-pr-author-skill.ps1` allowed-commands suite, and
the Codex PreToolUse handler-matcher test, the latter caused by the epic wave-barrier hook reading an
ambient epic checkpoint that currently records issue 596's own unmerged dependency edges. This
remediation deliberately ran no unscoped Pester invocation.

### Evidence

All artifacts are under
`docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/`, in the canonical
`remediation-baseline/`, `regression-testing/`, `qa-gates/`, `other/`, and `issue-updates/` kinds.
The reconciliation summary is at
`evidence/qa-gates/remediation-reconciliation.2026-08-29T23-07.md` and the coverage comparison at
`evidence/qa-gates/coverage-delta.2026-08-29T23-07.md`.

---

Output Summary: The issue-update text for #596 summarising remediation cycle 1 is recorded above in
full. It was **not posted**: the `POSTING BLOCKED` branch was taken because this run carries no
authorization to post to GitHub and no plan task instructs a post. The conditional mirror into
`issue.md` does not apply, because that mirror is required only under `PostedAs: body`.
