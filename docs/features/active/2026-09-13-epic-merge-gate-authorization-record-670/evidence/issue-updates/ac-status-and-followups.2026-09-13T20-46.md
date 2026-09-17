# AC Status and Follow-Ups — Issue #670

Timestamp: 2026-09-17T08-42
Task: [P7-T6]
PostedAs: unknown
POSTING BLOCKED: this artifact is a local record. Nothing was posted to GitHub; the follow-up deferral paragraph below is for the pull-request author to carry into the pull-request description.

## Acceptance Criteria Status (at [P7-T6])

- Source: `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/spec.md` (section `## Acceptance Criteria`, lines 728-907)
- Total AC items: 42
- Checked off (delivered): 36
- Remaining (unchecked): 6
- Items remaining:
  1. AC-17 — Gates still deny when the required evidence is genuinely absent (depends on [P8-T4]).
  2. AC-22 — Both bundled Claude hook mirrors updated with the resource-contract test green (depends on [P8-T3]).
  3. AC-23 — Bundled mirrors of the rules and skill files updated (depends on [P8-T3]).
  4. AC-35 — FU-1 through FU-4 filed as issues or their deferral recorded in the pull-request description. The deferral is recorded below; the pull-request description does not exist yet, so the criterion is not yet met.
  5. AC-39 — No Python invocation from any changed `.claude/hooks/**` file (depends on [P8-T6]).
  6. AC-42 — Full toolchain loop completed in a single clean pass (depends on Phase 8).

Verification of the checked count: `@(Select-String -LiteralPath 'docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/spec.md' -SimpleMatch -Pattern '- [x] ').Count` printed 38, which equals 2 + 36. The constant 2 covers the pre-existing non-AC checked boxes at `spec.md:83` and `spec.md:90`.

## Follow-ups

- FU-1 — deferred. Reason: proposes a Claude-side permissions posture change (an authorization store outside the gated agent's write reach); this is a substrate decision outside #670's scope. `gh issue create` is denied by a PreToolUse hook in this environment, and the MCP promotion route writes repository files that would widen this feature's bounded change set.
- FU-2 — deferred. Reason: Claude-side checkpoint path anchoring belongs to the epic's F1 (worktree-scoped state resolution) and its consumers, per spec open question OQ4.
- FU-3 — deferred. Reason: a key-gated Python checkpoint validator for `standalone_merge_authorizations` is defence in depth at completion time; the Enforcement bullet added to `.claude/rules/orchestrator-state.md` records that the Python validator does not currently validate this block.
- FU-4 — deferred. Reason: a bounded spike on whether a Bash-matcher PreToolUse envelope carries `agent_type`; not required by this design.

Deferral paragraph to carry into the pull-request description (verbatim):

> Follow-ups deferred from #670: FU-1 (Claude-side permissions posture for an authorization store outside the gated agent's write reach), FU-2 (Claude-side checkpoint path anchoring, owned by the epic's F1), FU-3 (key-gated Python checkpoint validator for `standalone_merge_authorizations`), and FU-4 (spike: does a Bash-matcher PreToolUse envelope carry `agent_type`). None is required for this change; each is recorded in `spec.md` under the named follow-ups.

## AC-40 stored-artifact location

EVIDENCE_LOCATION_OVERRIDE_REJECTED: docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/evidence/coverage/ replaced with docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/evidence/qa-gates/

The coverage baseline (`evidence/baseline/p1-post-registration-coverage.2026-09-13T20-46.md`), post-change measurement (`evidence/qa-gates/post-change-coverage.2026-09-13T20-46.md`) and comparison (`evidence/qa-gates/coverage-comparison.2026-09-13T20-46.md`) are stored at canonical locations.

## AC-13 `--squash` check

Command: `@(Select-String -LiteralPath 'docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/spec.md' -SimpleMatch -Pattern '--squash` denies')` (run from a script file that builds the backtick with `[char]0x60`).

Matched line numbers: 130, 776, 918.

- Inside `## Acceptance Criteria` (lines 728-907): exactly one match, line 776, which is AC-13's own line (the negative declaration that no criterion asserts `--squash` denies).
- Lines 130 and 918 are outside the section; recorded, not counted.
