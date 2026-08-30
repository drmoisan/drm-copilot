# POSTING BLOCKED — issue #596 update mirror

Timestamp: 2026-08-29T23-15

Command: `pwsh -NoProfile -Command "Test-Path -LiteralPath '.claude/state'"` and the `git hash-object`, `git grep`, and counter-module commands recorded in `evidence/qa-gates/ac-reconciliation.2026-08-29T16-05.md`, whose results are the source of every factual claim in the intended text below. No `gh` command was executed.

EXIT_CODE: 0

Output Summary: The verification commands whose results this mirror reports all completed
successfully, and the intended issue text below is reconciled against them. **No posting occurred**:
the executing agent holds no `gh` grant, so `PostedAs: unknown` is recorded and the `POSTING BLOCKED`
header above states the reason. The `EXIT_CODE: 0` on this artifact refers to the verification
commands that sourced the text, not to a posting attempt; no posting attempt was made and none is
claimed. This artifact is an issue-update mirror under `evidence-and-timestamp-conventions`, whose
required contents are a timestamp, the exact intended text, and a posting disposition; the
`Command:`, `EXIT_CODE:`, and this `Output Summary:` field are carried additionally so the artifact
also satisfies the uniform four-field schema stated in the plan's fail-closed evidence rule.

PostedAs: unknown

**Reason posting is blocked.** The executing agent holds no `gh` permission grant, so the text below
was not posted to GitHub. It is mirrored here in full so the orchestrator or a human can post it
verbatim as a comment on https://github.com/drmoisan/drm-copilot/issues/596. Nothing in the text
below has been posted; treat every statement in it as unpublished until someone posts it.

`PostedAs: unknown` is recorded rather than `comment` or `body` because no posting occurred and no
comment URL exists.

---

## Exact text intended for issue #596

### Feature B — batch-budget state portability: implementation complete, one acceptance criterion left open

All eight plan phases are executed. **16 of the 17 acceptance criteria in `spec.md` are satisfied and
checked off.** One is left unchecked, for a cause that predates this work.

#### What changed

Three defects in the Claude batch-budget hooks are fixed, together with a fourth gap in
destination-side ignore delivery.

1. **Shared session identity.** `enforce-powershell-batch-budget.ps1` and
   `enforce-python-batch-budget.ps1` no longer compose their state-file name from the literal
   `'default'`. They resolve a session identifier from `$env:CLAUDE_SESSION_ID`, then from
   `<root>/.claude/state/current-session-id` through a new read seam, then from a worktree-derived
   fallback, and sanitize the result before path composition. `persist-session-id.ps1` now publishes
   the session-id state file in the `CLAUDE_ENV_FILE`-set branch as well, so the second source is
   actually populated.
2. **Never-resetting poisoned counter.** Both hooks now apply a containment filter at rehydrate time,
   dropping persisted `prodFiles` and `testFiles` entries that lie outside the resolved root, so a
   stale out-of-root entry no longer permanently occupies a production slot.
3. **Unscoped recorded paths.** Both hooks replaced the `(Get-Location).Path` root default with a
   `$PSScriptRoot`-derived one and now discard out-of-root candidates instead of recording them.
   Neither hook introduces `Resolve-Path` or `[System.IO.Path]::GetFullPath`.
4. **Destination-side ignore delivery.** A new pure module,
   `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts`, merges a managed ignore
   block into the destination `.gitignore`, and the push-down call site writes it after the copy. The
   merge is idempotent and preserves unrelated destination entries in order.

All three repository hooks are byte-identically mirrored into the bundle under
`extensions/drm-copilot/resources/claude-customizations/`, verified by recomputed `git hash-object`
pairs.

#### Verification

| Gate | Result |
| --- | --- |
| Jest (full) | 203 suites, 2733 tests, 0 failed, exit 0 |
| `tsc --noEmit` | exit 0, no diagnostics |
| ESLint | exit 0, no diagnostics |
| Prettier `--check` | exit 0, all files conform |
| PoshQC format | `ok: true`, tree unchanged |
| PoshQC analyze | `ok: true`, zero findings |
| PoshQC test | `ok: false`, 3893 passed / 2 failed / 9 skipped — see below |
| Python parity gate | `1 passed`, exit 0 |

New-code coverage: `claude-gitignore-merge.ts` at 98.78 percent lines and 90 percent branches,
against its own `coverageThreshold` entry of 85 and 75.

Changed-code coverage, PowerShell LINE: `enforce-powershell-batch-budget.ps1` 93.8 percent,
`enforce-python-batch-budget.ps1` 93.8 percent, `persist-session-id.ps1` 88.1 percent. All three
clear the 85 percent floor. The two batch-budget hooks **declined 1.8 percentage points** from a
95.6 percent baseline; the cause is four newly added uncovered defensive lines (two degenerate-input
guards and one unreadable-file catch block) against a denominator that grew from 90 to 129 lines. The
decline is reported rather than rounded away.

#### The one unchecked acceptance criterion

`spec.md` line 773 requires `run_poshqc_format`, `run_poshqc_analyze`, and `run_poshqc_test` to be
consecutively clean. Format and analyze are clean and all three per-file coverage figures clear the
floor. `run_poshqc_test` returns `ok: false` because of exactly two failing tests:

```
enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
```

Both are pre-existing, on three independent grounds: the names are byte-identical to the pair
recorded in the pre-change baseline; the failure count held at exactly 2 while the discovered test
total rose from 3851 to 3904 across the integration merge; and the owning suites
(`enforce-pr-author-skill.Tests.ps1` and `codex-pretooluse-integration.Tests.ps1`) are touched by no
diff this feature produces. Two independent full runs produced byte-identical results, so the
condition is stable rather than flaky.

Neither suite is in this feature's scope, and repairing them would widen it. The criterion is
therefore left unchecked, and the three plan tasks it makes unsatisfiable — [P7-T4], [P7-T5], and
[P7-T11] — are left unchecked with their evidence artifacts present and their unmet acceptance stated
inside them rather than reinterpreted as met.

**Suggested follow-up:** repair the two suites in separately scoped work, then re-run
`run_poshqc_test` and close out `spec.md` line 773.

#### Accepted residuals

Eight limitations are documented in
`docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/other/known-limitations.2026-08-29T16-05.md`.
The six the spec requires to remain visible are: concurrent sessions in the same worktree still share
one counter; Windows 8.3 short-name paths are classified out-of-root and under-counted; a CRLF
destination `.gitignore` is normalized wholly to LF on first delivery; a destination `!`-negation
placed after the managed block still wins under git's last-match-wins semantics; the delivered
`.gitignore` does not appear in the push-down summary; and whether a Claude PreToolUse envelope
carries `session_id` remains unresolved, which blocks adopting the Codex fail-closed posture. The two
added during execution are the coverage decline and the pre-existing PoshQC failures described above.

Note for consumers: the destination-side ignore delivery reaches an installed extension only after a
rebuild, repackage, and reinstall. A repository-side `resources/` edit alone does not change what an
installed extension writes.

---

## End of intended text

`IssueUpdatedAt:` is not recorded, because no update was made.
`Comment URL:` is not recorded, because no comment was created.
