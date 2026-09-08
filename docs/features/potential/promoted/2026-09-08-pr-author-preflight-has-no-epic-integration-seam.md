# pr-author-preflight-has-no-epic-integration-seam (Issue #663)

- Date captured: 2026-09-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pr-author-preflight-has-no-epic-integration-seam/ (Issue #663)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #663
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/663
- Last Updated: 2026-09-08
## Summary

The pr-author PR-creation preflight in `.claude/hooks/enforce-pr-author-skill.ps1` validates the per-feature checkpoint `artifacts/orchestration/orchestrator-state.json` with `--require-pr-creation-ready`, and its sixth check (`enforce-pr-author-skill.epic-base-branch.ps1`) under `epic_mode: true` demands `--base <epic_context.integration_branch>`. The epic integration-to-`main` PR is the one PR in an epic whose base is `main`, and an epic owns no GitHub issue by default, so no truthful per-feature checkpoint admits it. `epic-orchestrator` halted at this step during epic #655 after rejecting every falsifying option.

## Environment

- OS/version: Windows 11 Pro 10.0.26200, Claude Code runtime.
- Python version: 3.13 (validator via Poetry).
- Command/flags used: `gh pr create --base main --body-file artifacts/pr_body_<N>.md` from `Agent(pr-author)`.
- Data source or fixture: epic #655; prior epics #388, #459, #610 left no record of how their integration PRs passed.

## Steps to Reproduce

1. Complete every child of an epic; the worktree's `orchestrator-state.json` describes a child or superseded run.
2. Delegate `Agent(pr-author)` for `epic/<slug>-integration -> main`.
3. Observe `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` (steps 5-8 pending, wrong issue) or, with `epic_mode: true`, `EPIC_BASE_BRANCH_MISMATCH` because the base is `main`.

## Expected Behavior

Either (a) `epic-planner` promotes an epic-level issue at planning time (`promotion_type: epic` is already supported by `potential_to_issue`) and the epic-orchestrate skill defines the per-feature checkpoint shape for the integration-PR run, or (b) the preflight and the base-branch check accept `epic-orchestrator-state.json` with `epic_merge_pr` as the readiness source when the caller is `epic-orchestrator` and the PR base equals `main`.

## Actual Behavior

The main session resolved it by promoting issue #655 as an epic and writing a per-feature checkpoint for the integration-PR run keyed to it, with `epic_mode: false`. That passed all three validator modes but is undocumented, and the epic-orchestrate skill's integration-PR step names no checkpoint at all.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

```
INTEGRATION_PR_CANNOT_BE_OPENED: every available path to satisfying the pr-author PR-creation preflight requires asserting something untrue in a checkpoint.
```

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Every epic stalls at its final PR without manual intervention.

## Suspected Cause / Notes

- The preflight assumes a single-feature checkpoint shape with an `issue-num`; the epic manifest carries only child issue numbers.
- Under `epic_mode: true` the base check has no seam for the integration PR whose base is legitimately `main`.
- The recipe that worked is recorded in the #655 checkpoint's `checkpoint_provenance` block and in the epic-integration memory note.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: Pester cases for the epic-integration checkpoint shape passing the preflight, and for the base check accepting `--base main` when `epic_merge_pr` is present.
- [x] Integration scenario to retest: open an epic integration PR end-to-end from `epic-orchestrator` without a hand-written per-feature checkpoint.
- [x] Manual verification notes: `epic-planner` should promote the epic issue during planning so the manifest carries `epic_issue_num`.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
