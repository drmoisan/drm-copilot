# automate-full-release-flow (Issue #291)

- Date captured: 2026-07-03
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-07-03-automate-full-release-flow-291/ (Issue #291)

- Issue: #291
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/291
- Last Updated: 2026-07-03
- Work Mode: minor-audit

## Problem / Why

The release workflow currently requires running `Release: Open Full Version-Bump PR`, waiting for the pull request checks to finish, merging the pull request, switching back to `main`, pulling the merged commit, and then running `Release: Push Release Tags (post-merge)`. These steps are deterministic and can be automated to reduce manual release handling while preserving the existing guarded release scripts.

## Proposed Behavior

Add a guarded PowerShell release orchestration script and VS Code task that:

1. Verifies the repository is on an up-to-date, clean `main` branch.
2. Runs the existing full version-bump PR script with explicit confirmation.
3. Captures the release branch and associated pull request number.
4. Waits for GitHub pull request checks through `gh`.
5. Merges the pull request when checks pass and branch protection permits it.
6. Returns to `main`, pulls the merged commit, and runs the existing post-merge tag-push script with explicit confirmation.

The new wrapper must reuse `Invoke-FullRelease.ps1` and `Invoke-ReleaseTagPush.ps1` rather than duplicating their version-bump or tag-push logic.

## Acceptance Criteria

- [x] A new guarded PowerShell script automates the full release flow by wrapping the existing full release PR and release tag-push scripts.
- [x] The script waits for GitHub pull request checks using `gh`, stops before merge/tag push when checks fail or remain blocked, and supports a safe confirmation model.
- [x] A VS Code task exposes the automated release flow, and Pester tests cover success, failed-check, dirty-worktree, and merge-blocked paths without invoking live `git`, `gh`, or `npm`.

## Constraints & Risks

- The script must not bypass branch protection, required reviews, or GitHub permissions.
- The script must stop before tag creation unless the version-bump PR is confirmed merged into `main`.
- Existing release scripts remain authoritative for version bumping and tag creation.
- External command calls must use wrapper seams so tests do not call live `git`, `gh`, `npm`, or network services.

## Test Conditions to Consider

- [ ] Successful end-to-end command sequence with mocked `git`, `gh`, and script invocations.
- [ ] Dirty worktree blocks before opening a release PR.
- [ ] GitHub checks failure blocks before merge.
- [ ] Merge failure blocks before checkout/pull/tag push.
- [ ] Confirmation token must be required before performing release actions.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/2026-07-03-automate-full-release-flow-291/` folder from the template
