# ci-merge-queue-for-main (Issue #952)

- Date captured: 2026-10-16
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/ci-merge-queue-for-main/ (Issue #952)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #952
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/952
- Last Updated: 2026-10-16
- Work Mode: full-bug

## Summary

The `protect-main` ruleset (id 15241672) requires branches to be up to date before merge. When several PRs are green at once, each merge forces every remaining PR to merge main in and rerun the full CI (about 15–19 minutes). Merges therefore serialize into one roughly 19-minute cycle per PR. A GitHub merge queue removes that loop.

## Environment

- OS/version: GitHub Actions (windows-latest, ubuntu-latest)
- Python version: n/a
- Command/flags used: `gh pr merge --merge` from the parallel-orchestrator, orchestrate and epic-orchestrate merge steps
- Data source or fixture: parallel run `bug-burndown-2026-10-15` (15 items; PRs #942, #944, #947, #948, #949, #950, #951)

## Steps to Reproduce

1. Have three or more PRs with green CI targeting `main`.
2. Merge one of them.
3. Observe that each remaining PR is now out of date and blocked until it merges `main` in and CI reruns.

## Expected Behavior

Green PRs are merged in order without a manual re-sync and full CI rerun per PR. The combined result is still validated before it lands on `main`.

## Actual Behavior

Each remaining PR needs one manual re-sync and one full CI rerun per earlier merge. Six ready PRs take about 6 × 19 minutes of mostly serial waiting.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: CI run 38846579572 took 19 minutes; the `protect-main` ruleset carries `required_status_checks` with strict up-to-date enforcement.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

- Every workflow that produces a required status check must trigger on `merge_group:`, or the queue stalls. Check `ci.yml` and its reusable workflows, `npm-audit-gate.yml` and `publish-extension.yml`.
- Expressions that read `github.event.pull_request.*` and `paths`/`branches` filters must behave correctly on `merge_group` events.
- With the queue enabled, `gh pr merge` enqueues the PR instead of merging it. Every repository procedure that merges and then reads `mergeCommit` must poll until the PR state is MERGED. Affected:
  - the parallel-orchestrator agent and the parallel-run/parallel-orchestrate skills;
  - orchestrate step 9 and epic-orchestrate;
  - the `.codex` and `.github` mirrors.
- The merge-gate hooks (`.claude/hooks/enforce-*merge-gate*.ps1`) must gate `gh pr merge --auto` and queue invocations exactly like plain `gh pr merge`.
- The ruleset change itself (adding a `merge_queue` rule) is a repository setting. Ship it as an apply/rollback payload plus runbook. The coordinator applies it after the PR that adds the `merge_group` trigger has merged.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: Pester tests for the merge-gate hooks' handling of `--auto` and queue mode, and for the queue-aware merge-confirmation logic.
- [x] Integration scenario to retest: after the ruleset is applied, queue two green PRs and confirm that both merge with no manual re-sync.
- [x] Manual verification notes: confirm every required check reports on a `merge_group` event.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
