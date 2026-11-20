# pr-author-impossible-from-session-not-rooted-in-item-worktree (Issue #1011)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pr-author-impossible-from-session-not-rooted-in-item-worktree/ (Issue #1011)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1011
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1011
- Last Updated: 2026-10-30
## Summary

PR authoring is impossible from a session not rooted in the item worktree. No combination of actions that the hook and the `pr-author` agent allow satisfies `enforce-pr-author-skill.ps1`, so the PR is never created. One of four sibling bugs that share the target-worktree resolver fix (see the batch-budget sibling issue for the resolver specification).

## Environment

- OS/version: not recorded
- Python version: not applicable
- Command/flags used: `gh pr create --body-file ...` run by `pr-author` from a coordinator-rooted session for an item in another worktree
- Data source or fixture: hook `enforce-pr-author-skill.ps1`, the `pr-author` agent tool allow-list (`Bash(sha256sum *)`, `Write(/artifacts/**)`), and the `pr-author` skill text

## Steps to Reproduce

1. Run `pr-author` from a coordinator-rooted session for an item whose worktree is elsewhere.
2. The hook requires `gh pr create --body-file <absolute item-worktree path>/artifacts/pr_body_<N>.md`; a relative path is denied `PR_BODY_PATH_NONCANONICAL`.
3. pr-author's allow-list and skill only produce and checksum the relative `artifacts/pr_body_<N>.md`.

## Expected Behavior

- pr-author resolves the item worktree from the `--head` branch via the shared resolver.
- It writes the body, the receipt, and the refreshed PR context under that worktree's `artifacts/`.
- It checksums by absolute path; the allow-list is extended to `Bash(sha256sum /**/artifacts/pr_body_*.md)` or an equivalent.
- It passes the absolute body path to `--body-file`.
- The hook's five receipt checks are unchanged.
- The skill documents the coordinator-session topology explicitly.

## Actual Behavior

The relative path resolves to the coordinator checkout, so the body, its receipt, and the PR context summary land under the coordinator root while the hook looks under the item worktree. Writing the receipt under the item worktree is also denied by the preimplementation-gate bug.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `PR_BODY_PATH_NONCANONICAL`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Same root cause as the sibling bugs: root derived from the session project directory, not the worktree being acted on. Depends on the preimplementation-gate fix for the receipt write.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: a coordinator-rooted pr-author for a worktree item → body, receipt, and summary land under the worktree and `gh pr create` is allowed; the same flow in an item-rooted session → unchanged; a relative `--body-file` from a coordinator session → still denied, with a message naming the absolute path to use. Tests in every runtime carrying the hook (Claude, Codex, bundled copies).
- [ ] Integration scenario to retest
- [ ] Manual verification notes

Documentation and parity as in the sibling batch-budget issue.

Out of scope: the PR receipt checks stay as strict as today; no change to worktree-isolation behavior or checkpoint schemas.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
