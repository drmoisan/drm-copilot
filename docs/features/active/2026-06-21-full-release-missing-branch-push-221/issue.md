# full-release-missing-branch-push (Issue #221)

- Date captured: 2026-06-21
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/full-release-missing-branch-push/ (Issue #221)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #221
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/221
- Last Updated: 2026-06-21
- Work Mode: full-bug

## Summary

`scripts/dev-tools/Invoke-FullRelease.ps1` fails when opening the release PR because the locally created release branch is never pushed to the remote before `gh pr create` runs.

## Environment

- OS/version: Windows, PowerShell 7+
- Python version: n/a
- Command/flags used: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/dev-tools/Invoke-FullRelease.ps1 -ConfirmToken yes`
- Data source or fixture: n/a

## Steps to Reproduce

1. Ensure a clean working tree on a branch ahead of `main`.
2. Run the "Release: Open Full Version-Bump PR" task (`Invoke-FullRelease.ps1 -ConfirmToken yes`).
3. Observe the run reach Step 5 (`gh pr create`).

## Expected Behavior

The release branch is published to `origin` and a version-bump PR is opened against `main`.

## Actual Behavior

PR creation fails with:

```
pull request create failed: GraphQL: Head sha can't be blank, Base sha can't be blank, No commits between main and release/full-20260621155124, Head ref must be a branch (createPullRequest)
Failed to open release PR (gh exit code 1).
```

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see Actual Behavior.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The full release task cannot open a PR; the release flow is blocked at the final step.

## Suspected Cause / Notes

In `Invoke-FullReleaseGuarded`, Step 4 commits the bumped manifests on the local release branch, then Step 5 calls `gh pr create --base main --head $branchName`. The branch is never pushed to `origin`. In non-interactive mode with an explicit `--head`, `gh pr create` does not push the branch, so the remote has no ref or SHA for it. GitHub therefore reports blank head/base SHAs and "No commits between main and release/...".

The companion `Invoke-ReleaseTagPush.ps1` establishes the correct pattern: it explicitly pushes via the `Invoke-GitExe` seam (`git push origin <tag>`). `Invoke-FullRelease.ps1` is missing the equivalent branch push.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: add a Pester case for the push-failure path; update the success-path test to assert the push call occurs before `gh pr create`.
- [ ] Integration scenario to retest
- [x] Manual verification notes: re-run the release task and confirm a PR opens.

Add a Step between commit (Step 4) and PR creation (Step 5) that runs `git push -u origin $branchName` through the existing `Invoke-GitExe` seam, returning a non-zero exit with a `Write-StderrLine` diagnostic on failure.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch