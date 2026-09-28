# Feature Audit — 2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate (Issue #634)

- Timestamp: 2026-09-07T11-18 (UTC)
- Reviewer: feature-review agent
- Work mode: `full-bug`
- AC source (resolved by work mode): `docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/spec.md` **only**
- Baseline: `origin/epic/cleanup-merged-worktrees-hardening-integration` @ `a36b6dca`
- Overall verdict: **PASS** (14 of 15 criteria PASS; 1 legitimately deferred, not failed)

## AC Source Resolution

`issue.md` carries the marker `- Work Mode: full-bug`. Per the AC-source table in
`.claude/skills/acceptance-criteria-tracking/SKILL.md`, `full-bug` resolves to `spec.md` only.
`user-story.md` exists in the folder but is not an AC source in this mode; it was read and
confirmed to carry no acceptance criteria, matching the plan's own statement. `issue.md` was
likewise not used as an AC source.

`spec.md` carries fifteen criteria, AC-1 through AC-15, under `## Acceptance Criteria`
(lines 592–606), all in standard `- [ ]` / `- [x]` checkbox format with no gaps and no duplicate
identifiers.

## Verification Method

Every criterion below was re-verified by this reviewer executing the criterion's own stated
assertion against the current tree. Executor evidence artifacts were read for corroboration but
were **not** treated as sufficient on their own. Where a criterion asserts section containment,
the section boundaries were established independently from the document's heading and list
structure:

- End-to-End Workflow: lines 73–130; **step 5 item spans lines 107–120** (line 121 is the blank
  separator; item 6 begins at 122).
- `## Prohibited Shortcuts`: lines 240–266 (`## Cross-References` begins at 267).
- `## Cross-References`: lines 267–283 (end of file).

## Acceptance Criteria Evaluation

| AC | Criterion (abbreviated) | Assertion result | Verdict | Checkbox state |
|---|---|---|---|---|
| AC-1 | Step 5 names the human actor | `human-performed` — exactly 1 match, line 108, inside 107–120. Exclusivity requirement ("every reported match line lies within step 5") holds trivially with a single match. | **PASS** | `[x]` (already checked) |
| AC-2 | Step 5 names the gate's deny reason | `EPIC_MERGE_GATE_BLOCKED` — 1 match, line 112, inside step 5. | **PASS** | `[x]` |
| AC-3 | Step 5 names the permission allow-list blocker | `permissions.allow` — 1 match, line 110. `settings.json` — 1 match, line 111. Both inside step 5. | **PASS** | `[x]` |
| AC-4 | Step 5 states the up-to-date-branch precondition | `strict_required_status_checks_policy` — 1 match, line 114, inside step 5. Claim independently re-verified against the live ruleset API. | **PASS** | `[x]` |
| AC-5 | Step 5 discloses the unbounded wait | `unbounded` — 1 match, line 116, inside step 5. | **PASS** | `[x]` |
| AC-6 | Prohibited Shortcuts forbids the shape-1 checkpoint evasion | `epic_mode` — 1 match, line 264. `step9_status` — 1 match, line 264. Both are the **only** matches in the file and both lie inside 240–266, satisfying the stricter "every reported match line" condition. | **PASS** | `[x]` |
| AC-7 | Cross-References names the gate and explains the mismatch | `enforce-epic-merge-gate.ps1` — 3 matches (lines 111, 262, 279); the criterion requires at least one inside `## Cross-References`, and line 279 satisfies it. The accompanying prose correctly enumerates all three checkpoint shapes. | **PASS** | `[x]` |
| AC-8 | The two SKILL.md copies are byte-identical | Reviewer-executed: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` → exit 0, `1 passed in 0.10s`. Corroborated by identical SHA256 `4189bd77...4b716` and `cmp` reporting no difference. | **PASS** | `[x]` |
| AC-9 | Merge gate hook unmodified | `git diff <base> -- .claude/hooks/enforce-epic-merge-gate.ps1` → empty. | **PASS** | `[x]` |
| AC-10 | Merge gate test file unmodified | `git diff <base> -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` → empty; the whole `tests/scripts/claude-hooks` directory is empty in the diff. | **PASS** | `[x]` |
| AC-11 | No out-of-scope surface modified | `git diff <base> -- .claude/hooks .claude/settings.json scripts/bash` → empty. Extended by this reviewer to also cover `tests/scripts/claude-hooks` → also empty. The full branch diff is four files, none of which is an out-of-scope path. | **PASS** | `[x]` |
| AC-12 | No cleanup checkpoint contract introduced anywhere | `grep -rn "cleanup-worktrees-state" .claude scripts tests extensions` → exit 1, zero matches. | **PASS** | `[x]` |
| AC-13 | Fail-before exception dossier at canonical evidence location | `evidence/regression-testing/fail-before-exception.2026-09-07T11-02.md` exists; `WhyFailingRunImpossible` present at line 3 with a substantive reason (the defect is an omission in prose, so no automated test could have failed pre-edit). | **PASS** | `[x]` |
| AC-14 | Manual read-through record at canonical evidence location | `evidence/qa-gates/manual-read-through.2026-09-07T11-02.md` exists; `human-performed` appears in four artifacts under `evidence/qa-gates/`. The record states step 5 names its actor and that push-down parity passed — both re-verified independently by this reviewer. | **PASS** | `[x]` |
| AC-15 | `docs-validation / Documentation Validation` reports `success` on this feature's PR | No pull request exists for this branch. `gh` reports no PR, and the regenerated PR context shows `None (no PR exists yet for this branch)`. The check cannot be observed. | **DEFERRED / UNVERIFIED** — not FAIL | `[ ]` (correctly left unchecked) |

## AC-15 Assessment

AC-15 is the only unmet criterion and it is **structurally unmeetable at this point in the
lifecycle**, not a delivery gap. It requires a required-check conclusion on a pull request that,
by design, is authored *after* this review. The executor correctly left it unchecked and recorded
the deferral in `evidence/qa-gates/ac-15-deferred.2026-09-07T11-08.md`. This reviewer confirms it
remains unchecked and does **not** check it off.

Two supporting observations on the likelihood of satisfaction, offered as forecast rather than as
evidence:

1. `docs-validation / Documentation Validation` is confirmed present in the required-status-check
   context list returned by `gh api repos/drmoisan/drm-copilot/rules/branches/main`, so the check
   will in fact run on the PR.
2. `.github/workflows/_docs-validation.yml` performs three steps: assert `README.md` exists and is
   non-empty, assert `LICENSE` exists, and emit warnings if two instruction documents are missing.
   None of these can be affected by a Markdown skill-document change. The workflow has no
   Markdown linting step. The check is therefore expected to pass, but expectation is not the
   `success` conclusion the criterion demands, so the criterion stays open.

**Handoff to the orchestrator:** after PR authoring and CI completion, confirm the
`docs-validation / Documentation Validation` conclusion is `success` and check AC-15 off in
`spec.md`. Until then it remains the single outstanding criterion.

## Check-Offs Performed by This Review

**None.** All fourteen criteria evaluated as PASS were already `[x]` in `spec.md` when this review
began. The AC-tracking protocol was applied as verification rather than as re-checking: each
existing check-off was independently re-derived from its own assertion before being accepted, and
none was found to be unsupported. AC-15 was verified to be correctly unchecked and was left
unchecked.

Integrity of the executor's check-offs was additionally confirmed structurally:
`git diff --word-diff=porcelain` on `spec.md` against the base shows **exactly** 14 checkbox token
changes and no other word-level change anywhere in the file. No criterion text was altered, no
criterion was added, and no criterion was removed. This satisfies rules 3 and 5 of the
acceptance-criteria-tracking protocol.

## Plan Task Completion

All plan tasks in `plan.2026-09-06T23-08.md` are complete: **34 of 34** task checkboxes are `[x]`
and zero remain `[ ]`, distributed as P0: 8, P1: 6, P2: 15, P3: 5. The `git diff` on the plan file
shows only checkbox flips, with no task text altered.

Note: the delegation prompt relayed a count of "24 plan tasks". The plan carries 34. The artifact
state is complete and internally consistent; only the relayed count is inaccurate. No action
required.

## Regression Assessment Relative to Baseline

| Risk | Assessment |
|---|---|
| Loss of the git-native ancestry invariant in step 5 | **No regression.** The `--is-ancestor` verification and its consequence sentence appear as unmodified context lines in the diff. New prose was inserted before it, not over it. |
| Behavioural change to the cleanup script or hooks | **No regression.** Zero executable files changed on the branch. |
| Bundled-payload drift | **No regression.** Byte-identity confirmed by hash and by the contract test. |
| Encroachment on sibling epic children (#545 and others) | **No regression.** All six named out-of-scope paths carry an empty diff. |
| Introduction of the rejected Option B surface | **Not present.** The `cleanup-worktrees-state` token is absent from `.claude`, `scripts`, `tests`, and `extensions`. |
| Contradiction elsewhere in the skill document | **None found.** All 27 "merge" occurrences reviewed; no passage implies the agent performs the merge. |

## Does the Delivery Resolve the Reported Defect?

Yes. `issue.md` `## Expected Behavior` states the requirement as a disjunction: *"The skill's own
workflow is executable end to end by the agent that runs it, **or** the skill states plainly that
the merge is a human step and does not present it as an agent action."* The delivery satisfies the
second disjunct. Step 5 now states the merge is human-performed, gives three independent reasons,
defines the agent's terminal action at the handoff, and discloses that the wait is unbounded
within a session.

The impact described in `issue.md` — "an undocumented handoff" — is directly addressed: the
handoff is now documented at the point in the workflow where it occurs, which is where an agent
executing the skill will encounter it.

### Acceptance Criteria Status

```
- Source: docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/spec.md
- Total AC items: 15
- Checked off (delivered): 14
- Remaining (unchecked): 1
- Items remaining:
  - AC-15 — The `docs-validation / Documentation Validation` required check reports a `success`
    conclusion on this feature's pull request.
    Reason: no pull request exists yet for branch `exec-634`. PR authoring and CI monitoring occur
    after this review, performed by the orchestrator. The check is confirmed to be a required
    context on `main` and the workflow contains nothing a Markdown change can break, so the
    criterion is expected to be satisfiable, but the required `success` conclusion cannot be
    observed at review time. Deferral recorded in
    `evidence/qa-gates/ac-15-deferred.2026-09-07T11-08.md`.
```

## Verdict

**PASS.** Fourteen of fifteen acceptance criteria are verified satisfied by independent
re-execution of their own assertions. The fifteenth is deferred by lifecycle design, correctly
left unchecked, and carries a documented deferral record. No acceptance criterion is failed, and
no criterion was found to have been checked off without support.
