# Remediation Inputs — Issue #518

Timestamp: 2026-08-26T06-55
Reviewer: feature-review
Branch: `bug/prd-feature-gate-resolves-nested-artifact-as-feature-folder-518` @ `2ae27c01`

## Summary

- **Blocking findings: 0.** No finding prevents this branch from opening a pull request.
- **Non-blocking findings: 11.** Six are Should-Fix and five are Nice-to-Have or informational.

Three of the Should-Fix items (NB-3, NB-4, NB-5) are stale-documentation edits inside files already in
the plan's declared write set and can be folded into [P5-T2] at negligible cost. Two (NB-1, NB-2) are
corrections to evidence artifacts. None requires a code change to the delivered fix.

## Artifact Paths

- `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/policy-audit.2026-08-26T06-55.md`
- `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/code-review.2026-08-26T06-55.md`
- `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/feature-audit.2026-08-26T06-55.md`

## Blocking Findings

None.

## Should-Fix Findings

### NB-1 — Bundle-parity evidence must cite issue #510 and must not imply an unfiled obligation

**Severity:** Should-Fix. **Files:**
`evidence/qa-gates/qc-bundle-parity.2026-08-26T06-32.md`,
`evidence/qa-gates/post-rebase-toolchain-reverification.2026-08-26T06-55.md`.

The post-rebase artifact states that the underlying test defect "is carried to a follow-up issue". No
such issue was filed by this item, and none was required: issue **#510**, "Bug:
claude-resource-parity-enumerates-gitignored-state", is already OPEN and describes this exact failure,
including the observation that "the remedy looks like deleting a file, [so] the natural response is a
per-plan workaround rather than a repository fix."

As written, the phrasing reads as an obligation that was not discharged.

**Remediation:** amend both artifacts to cite `#510` by number. In the bundle-parity artifact, state that
the durable evidence for the parity property is the byte-identity comparison
(`git hash-object` returning `469fecca912e3be687a123b8a3e33ce8a7f327c6` for both copies), and that the
suite's exit code is environment-conditional.

**Supporting measurement:** the reviewer re-ran the suite in this worktree at 06:50 and observed
**1 failed / 9 passed** with the identical assertion, because the two `.claude/state/*.json` counters had
regenerated (modification times 06:47 and 06:49). The clearance performed during [P2-T7] is not durable.

### NB-2 — [P5-T1] evidence does not carry the exact submitted bodies, and its substitute claim is inaccurate

**Severity:** Should-Fix. **File:** `evidence/issue-updates/follow-up-issues.2026-08-26T07-05.md`.

The [P5-T1] acceptance condition requires the artifact to carry "the exact body text submitted for each"
issue. The artifact instead states: "The exact body text submitted for each issue is preserved verbatim
in that issue's promoted record under `docs/features/potential/promoted/`."

That claim does not hold. `gh issue view 565 --json body` returns a body whose first line is
`- Work Mode: full-bug`. The corresponding promoted record
`docs/features/potential/promoted/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder.md`
contains no `- Work Mode:` line. Three of the four promoted records lack the marker while all four issue
bodies carry it, and the prose differs in punctuation. The records are near-copies, not verbatim
preservations.

**Remediation:** either embed the four submitted bodies in the artifact, or replace the claim with an
accurate statement of the relationship (a near-copy that omits the work-mode marker line).

**Downstream consequence worth noting:** if a later `new_active_feature_folder` seeds an `issue.md` from a
promoted record that lacks the marker, the resulting folder would trigger the indeterminate-marker deny
path this very change introduces.

### NB-3 — Stale rationale comment in the hook contradicts the code three lines below it

**Severity:** Should-Fix. **File:** `.claude/hooks/enforce-prd-feature-before-planner.ps1:384-386`, and
the identical text in the bundled mirror.

```powershell
# Derive the prerequisite set from the persisted work-mode marker rather
# than a fixed spec.md/user-story.md pair. A marker that cannot be read or
# recognized must fail closed to the strictest set, not fail open.
```

The "fail closed ... not fail open" clause remains true. The "to the strictest set" clause is now false:
the statement immediately below routes an unreadable marker to a branch that names no prerequisite set at
all.

**Remediation:** rewrite the third sentence to describe the delivered behaviour — an indeterminate marker
denies on its own branch without probing. Apply the identical edit to the bundled mirror to preserve byte
identity.

### NB-4 — Stale `Context` comment in the test file states the opposite of the delivered contract

**Severity:** Should-Fix. **File:**
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1:368-374`.

```powershell
# ... The gate MUST fail closed to the strictest prerequisite set
# (spec.md and user-story.md) in every case. ...
```

This sits above the four cases that exercise the new indeterminate path and directly contradicts them.
It was not updated by [P1-T9] and was not flagged by the executor.

**Remediation:** rewrite to state that an undeterminable mode denies on a distinct path that names no
prerequisite document, and that the fail-open defect class from issue #501 remains locked because the
decision is still `deny`.

### NB-5 — Two `It` names no longer describe what their tests assert

**Severity:** Should-Fix. **File:**
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1:264` and `:269`.

- `It 'fails closed to the strictest set when the mode is $null'` now asserts `@('spec.md')`.
- `It 'fails closed to the strictest set for an unrecognized mode string'` now asserts `@('spec.md')`.

`spec.md` alone is not the strictest set. The behaviour is still fail-*closed*, because the returned set
is non-empty, but "strictest" is false. An `It` name is what appears in a failure message; a reader
seeing this name beside an expectation of `spec.md` will suspect the assertion rather than the name.

**Remediation:** rename to describe the assertion, for example
`returns spec.md alone for a $null mode so no reachable path can demand user-story.md`. Renaming an `It`
does not change coverage or any acceptance criterion.

### NB-6 — Two evidence artifacts carry future-dated timestamps

**Severity:** Should-Fix. **Files:**
`evidence/qa-gates/post-rebase-toolchain-reverification.2026-08-26T06-55.md`,
`evidence/issue-updates/follow-up-issues.2026-08-26T07-05.md`.

Both were committed in `2ae27c01`, whose committer and author date is `2026-08-26 06:44:29 -0400`. Their
declared timestamps are 11 and 21 minutes after the commit that introduced them. A timestamp segment must
record the actual capture time per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

**Remediation:** correct the declared timestamps to the capture times, or record why they diverge. This
also affects the auditability of the "`.claude/state/` was verified empty before Stage 1 and after
Stage 4" claim in the post-rebase artifact, which cannot be placed on a timeline against the observed
file modification times of 06:47 and 06:49.

## Nice-to-Have and Informational Findings

### NB-7 — Fail-before evidence does not correspond to the committed test text (closed by this review)

**Severity:** informational; already discharged.

`evidence/regression-testing/fail-before-regression-run.2026-08-26T06-08.md` was captured against commit
`22c702cf`, before two prompts were corrected during Phase 2. The run was not repeated afterwards.

The reviewer independently re-measured both corrected prompts against the pre-fix resolver extracted from
`22c702cf`; both still misresolve, so both cases remain genuine regression tests. The full method and
results are recorded in `feature-audit.2026-08-26T06-55.md` and `code-review.2026-08-26T06-55.md`. The
check-off may cite that verification.

Separately, one subsection of that artifact heads a list "(4 of 6 failing)" and then enumerates five
items. The five-item count is the correct one; it is what makes the section totals sum to the stated 18.
A transcription error in the heading only.

### NB-8 — `spec.md:117` states a purity invariant the delivered function does not satisfy

**Severity:** Nice-to-Have. **File:** `spec.md:117`.

`spec.md:117` states that `Find-PrdFeatureFolderFromPrompt` "remains a pure string function. No filesystem
probe is added to folder resolution", while the operative data-flow text at `spec.md:158-161` mandates
consulting `Get-PrdFeatureCheckpointFolder` inside the selection rule. The implementation follows the
operative text and discloses the I/O in its own help. This is a contradiction inside `spec.md`, not an
executor error.

**Remediation:** at close-out, correct `spec.md:117` to state that resolution performs no *new* I/O and
reaches the existing checkpoint seam only when two or more distinct candidates survive deduplication.

### NB-9 — The plan's [P5-T1] task text named a command the repository forbids

**Severity:** Nice-to-Have; feedback to `atomic-planner`.

[P5-T1] specified `gh issue create` and asserted the task would write no repository file other than the
evidence mirror. `gh issue create` is denied by the `PROMOTION_MCP_ONLY_BLOCKED` `PreToolUse` hook, and
`atomic-executor` carries no `gh` in its allowlist, so the task was unexecutable by its assignee through
the only command it named. The "no repository file" clause is unsatisfiable through the only permitted
path, because the MCP promotion route necessarily writes a lifecycle record.

**Remediation:** future plans that file issues should name the MCP promotion sequence and should declare
the promoted-record writes in the Declared write set.

### NB-10 — Four files added outside the plan's Declared write set

**Severity:** informational; acceptable.

```text
docs/features/potential/promoted/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder.md
docs/features/potential/promoted/2026-08-26-feature-folder-order-hook-work-mode-and-plan-filename-defects.md
docs/features/potential/promoted/2026-08-26-parallel-cohort-barrier-resolves-nested-artifact-as-feature-folder.md
docs/features/potential/promoted/2026-08-26-parallel-drift-gate-resolves-nested-artifact-as-feature-folder.md
```

These are the lifecycle records the only permitted promotion path produces. Verified from the diff:
exactly four additions with no residual file under `docs/features/potential/`, confirming that
`potential_to_issue` moves rather than copies. `new_active_feature_folder` was correctly not invoked, so
no feature folder or branch was created for the four follow-ups. No Scope Containment criterion is
violated.

**Remediation:** call out the four additions in the pull-request body so a reviewer is not surprised by
files the plan does not name.

### NB-11 — PR context reports `#501` among author-asserted auto-close issues

**Severity:** Nice-to-Have. **Artifact:** `artifacts/pr_context.summary.txt` (regenerated during review).

The collector reports author-asserted auto-close issues `#501` and `#518`. `#501` is already CLOSED and
appears on the branch only as a citation to the prior fix that established the fail-open regression lock.

**Remediation:** ensure the pull-request body closes `#518` alone.

### NB-12 — Degenerate token behaviour change (recorded for completeness)

**Severity:** Nice-to-Have; no practical exposure.

A token of the shape `docs/features/active/foo.md` — a stray Markdown file directly under `active/` with
no feature folder — previously resolved to `docs/features/active` via the `.md`-parent rule and now
resolves to `docs/features/active/foo.md` as though it were a folder. No such file exists, and
`docs/features/active` was never a valid feature folder, so nothing is affected. Recorded so a later
reader does not mistake it for an oversight.

## Recommended Disposition

Proceed to [P5-T2]. Check off all 38 acceptance criteria, citing `feature-audit.2026-08-26T06-55.md`, and
fold NB-3, NB-4, and NB-5 into the same commit since all three touch files already in the declared write
set. NB-3 requires the identical edit in both hook copies to preserve byte identity, which is re-verified
by the parity check. Correct NB-1, NB-2, and NB-6 in the affected evidence artifacts before opening the
pull request.
