# Spec Documentation-Only Criteria

Timestamp: 2026-10-29T11-45
Task: [P6-T13]
Command: Read of `spec.md` sections `## Scope & Non-Goals`, `## Live-Verification Items`, and `## Acceptance Criteria`, with grep for "D8", "LV", and "Deferral" in the same file
EXIT_CODE: 0
Output Summary: AC-15 PASS and AC-16 PASS.

## AC-15: D8 recorded as out of scope and tracked separately

Finding: PASS. `## Scope & Non-Goals` carries the non-goal "D8: the standalone merge-on-green hook change is OUT of scope", states that it "is tracked in a separate issue, to be filed after this one", and states that this issue does not modify the merge-gate hooks, the #670 authorization branch, or the `epic_mode` merge prose. `## Rollout & Follow-up` repeats the follow-up to file the separate D8 issue.

## AC-16: Live-verification items labelled with deferral behaviors; no criterion asserts their outcome

Finding: PASS. `## Live-Verification Items` opens by stating that the items "cannot be established by unit tests or by source reading", "are not acceptance facts", are verified on a live run after merge, and that each has a defined deferral behavior. LV1, LV2, and LV3 each end with an explicit "Deferral:" clause (record the refusal and leave `merged`; report the pull request as open; report that the records pull request needs manual authoring). LV4 is the post-merge two-cohort rerun; its stated outcome already allows "reported deferrals", and the section states it can only be rerun after merge. No checkbox under `## Acceptance Criteria` asserts the outcome of LV1 through LV4: AC-16 itself asserts only the labelling, and AC-20 asserts CI results.
