# epic-child-pr-merges-without-ci (Issue #1130)

- Date captured: 2026-11-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-child-pr-merges-without-ci/ (Issue #1130)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1130
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1130
- Last Updated: 2026-11-08
- Work Mode: full-bug

## Summary

In a destination repository whose CI runs automatically only on pull requests to `main`, child PRs into an epic integration branch get no CI, and the merge gate lets them merge anyway. Several iar-migration E1 child PRs, for example #161, merged into the integration branch with no CI run. One agent worked around it by dispatching the workflow manually on the PR head.

## Environment

- OS/version: Windows 11 Pro, Claude Code
- Python version: n/a
- Command/flags used: `gh pr merge` on a child PR whose base is `epic/<slug>-integration`
- Data source or fixture: iar-migration E1, 2026-11-07/08; this repository's own `ci.yml` already includes `epic/**` in its pull_request trigger

## Steps to Reproduce

1. In a repository whose CI `pull_request` trigger lists only `main`, open a child PR into `epic/<slug>-integration`.
2. Observe that no CI runs.
3. Merge it through `epic-orchestrator`; observe that the merge gate allows it.

## Expected Behavior

`epic-orchestrator` and the merge gate require a green CI result on the child PR head SHA before merging into the integration branch, from either a `pull_request` run or a recorded `workflow_dispatch` run on the same SHA. Repository bootstrap and push-down add the integration-branch pattern (`epic/**`) to the CI `pull_request` trigger.

## Actual Behavior

Child PRs merge into the integration branch with no CI result at all.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: iar-migration PR #161 merged into the E1 integration branch with zero checks.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The merge gate (`.claude/hooks/enforce-epic-merge-gate.ps1` and its helpers, plus the Codex copy) checks epic membership and checkpoint state but not a CI result tied to the head SHA for epic children. The `epic-orchestrate` skill's CI step assumes CI runs. Do not weaken the gate: the legitimate path is a recorded green run on the head SHA.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: merge gate denies an epic-child merge with no CI record; allows one with a green `pull_request` run on the head SHA; allows one with a recorded green `workflow_dispatch` run on the same SHA; denies a run on a different SHA.
- [ ] Integration scenario to retest: `epic-orchestrator` dispatches CI when no run exists and records it before merging.
- [ ] Manual verification notes: update `epic-orchestrate` and `epic-run` text and mirrors, the bootstrap or push-down that writes the CI trigger, and state that destination repositories need a push-down refresh.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
