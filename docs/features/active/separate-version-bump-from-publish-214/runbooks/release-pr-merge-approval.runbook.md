# Runbook: Approve and Merge a Release Version-Bump PR

Issue: #214

## Cue

Act when the orchestrator has recorded an `exception` for the `branch-protection-merge-approval` requirement — that is, when the release version-bump task has opened a pull request against `main` that patch-bumps `extensions/drm-copilot/package.json` and `packages/mcp-server/package.json`, and that PR is waiting for review. Branch protection on `main` requires an approving review from a write-access reviewer who is not the PR author, so this step cannot be automated and is a permitted human gate.

## Prerequisites

- You have write (or admin) access to `drmoisan/drm-copilot`.
- You are not the author of the release PR (GitHub prohibits authors from approving their own pull requests).
- The PR's required status checks (CI) have completed successfully. If checks are still running, wait for them.

## Step-by-step Instructions

1. Open the repository **Pull requests** tab and select the release version-bump PR (title begins with "Release v...").
2. Confirm the diff contains only the two manifest version bumps (and any generated lockfile updates). If the diff includes unrelated changes, stop and request correction.
3. Open the **Files changed** tab and select **Review changes**.
4. Optionally enter a review comment, select **Approve**, then select **Submit review**.
5. Return to the **Conversation** tab. When the required approvals and status checks are satisfied, the **Merge pull request** button becomes enabled.
6. Select **Merge pull request** (or choose squash/rebase from the dropdown per repository convention), then **Confirm merge**.

## Verification

- The PR state shows **Merged**, and `main` now contains the bumped versions in both manifests (`git pull origin main` then inspect `version` in each `package.json`).
- The required status checks show as passed on the merge commit.
- Note: if branch protection has "dismiss stale approvals" enabled and new commits are pushed after your approval, the approval is dismissed and must be re-obtained before merge.
- After merge, the post-merge tag-push task can push `v<version>` and `mcp-server-v<version>`, which trigger the CI publish workflows.

## Source and Citation

- GitHub Docs — Approving a pull request with required reviews (reviewer approve flow; authors cannot approve their own PRs): `https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/approving-a-pull-request-with-required-reviews` — captured 2026-06-19.
- GitHub Docs — About protected branches (required reviews gate merge; stale-review dismissal; admin exemption): `https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches` — captured 2026-06-19.
- GitHub Docs — Merging a pull request: `https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/merging-a-pull-request` — captured 2026-06-19.
