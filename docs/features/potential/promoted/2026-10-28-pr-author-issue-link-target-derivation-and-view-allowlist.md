# pr-author-issue-link-target-derivation-and-view-allowlist (Issue #989)

- Date captured: 2026-10-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pr-author-issue-link-target-derivation-and-view-allowlist/ (Issue #989)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #989
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/989
- Last Updated: 2026-10-28
## Summary

Three defects in orchestration and PR-authoring tooling: (1) orchestrated runs do not pass their own issue to the pr-author delegation as author-asserted, so the PR body falls back to `- None` and the issue stays open after merge; (2) the `TARGET_WORKTREE_NOT_DERIVABLE` PreToolUse gate rejects `gh pr edit <N> --body-file <path>` because the command has no branch or issue signal and `gh pr edit` has no `--head` flag; (3) the pr-author agent cannot run `gh pr view`, so it cannot perform the `closingIssuesReferences` verification its own skill requires.

## Environment

- OS/version: Windows 11 and Linux CI
- Python version: not applicable
- Command/flags used: `gh pr create --body-file`, `gh pr edit <N> --body-file`, `gh pr view <N> --json closingIssuesReferences,body`
- Data source or fixture: `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `.claude/hooks/enforce-pr-author-command-allowlist.ps1`, `.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`

## Steps to Reproduce

1. Run an orchestrated feature to the PR-authoring step with a checkpoint that records `issue-num` and a PR context that lists no verified autoclose issues.
2. Delegate to `Agent(pr-author)`; observe the PR body Auto-close section reads `- None` and the issue stays open after merge.
3. Run `gh pr edit <N> --body-file artifacts/pr_body_<N>.md` from the pr-author agent; observe the deny `TARGET_WORKTREE_NOT_DERIVABLE`, which recommends `--head`, an invalid flag for `gh pr edit`.
4. Attempt `gh pr view <N> --json closingIssuesReferences,body` from the pr-author agent; observe it is outside the agent's allowlist.

## Expected Behavior

- The orchestrate delegation names the run's issue as author-asserted, and the PR body emits `- Closes #NNN`.
- The hook derives the target from the current worktree's branch when the command carries no signal, and its message names the accepted forms for `gh pr create` and `gh pr edit`.
- The pr-author agent verifies closing references after every create or edit.

## Actual Behavior

- `Author-asserted autoclose issues` is never passed; PR body shows `- None`.
- `TARGET_WORKTREE_NOT_DERIVABLE` is returned for `gh pr edit` unless a `# branch: <branch>` shell comment is appended, which depends on incidental parsing.
- The agent reports the closing-reference check as unverified and hands it back to the caller.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `TARGET_WORKTREE_NOT_DERIVABLE: the call carries neither a canonical issue number line nor a branch signal (--head, --branch, or branch:)`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

- Defect 1: `.claude/skills/orchestrate/SKILL.md` `## PR Authoring (pr-author Handoff)` and `.claude/agents/orchestrator.md` `## PR Creation Delegation` never mention auto-close.
- Defect 2: `Resolve-PrAuthorWorktreeTarget` in `.claude/hooks/enforce-pr-author-skill-helpers.ps1` passes only command text to `Resolve-WorktreeItemTarget`, which returns NoTarget when no signal exists.
- Defect 3: `.claude/agents/pr-author.md` `tools:` and `Test-PrAuthorAllowlistForm` in `.claude/hooks/enforce-pr-author-command-allowlist.ps1` exclude `gh pr view`.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: Pester for the seam fallback (branch derived, detached HEAD, signal present, git failure), the deny message, and the allowlist `gh pr view` form; a validator/test failing when an orchestrated pr-author delegation omits the author-asserted line while the checkpoint has an `issue-num`.
- [ ] Integration scenario to retest
- [ ] Manual verification notes

### Acceptance Criteria

- [ ] AC1: The orchestrate skill and `agents/orchestrator.md` require the pr-author delegation prompt to carry `Author-asserted autoclose issues: #<issue-num>`, omitted only when the checkpoint has no `issue-num` or the run is a child of an epic whose integration PR owns the closing keyword.
- [ ] AC2: `skills/pr-author/SKILL.md` states that an issue named as author-asserted in the delegation prompt is a valid source for `- Closes #NNN` even when the PR context lists no verified autoclose issues, and that `- None` is correct only when neither list has an entry.
- [ ] AC3: A test or validator check fails when an orchestrated run's pr-author delegation omits the author-asserted line while the checkpoint has an `issue-num`.
- [ ] AC4: When a `gh pr create` or `gh pr edit` command carries no branch or issue signal, the PreToolUse hook derives the target from the current worktree's checked-out branch and applies the existing checks to that item; a detached HEAD or unreadable branch keeps the NoTarget deny.
- [ ] AC5: The `TARGET_WORKTREE_NOT_DERIVABLE` message names the exact accepted forms for `gh pr edit` and `gh pr create` and states that `--head` is not valid for edit.
- [ ] AC6: `agents/pr-author.md` allows `Bash(gh pr view *)`; the allowlist hook permits `gh pr view <N> --json closingIssuesReferences,body` and no other `gh pr view` form with write effect; allowlist tests cover the new entry.
- [ ] AC7: `skills/pr-author/SKILL.md` and the agent require running `gh pr view <N> --json closingIssuesReferences,body` after every create or edit and reporting the closing references found.
- [ ] AC8: Every change is mirrored under `extensions/drm-copilot/resources/` and the `.agents`/`.codex` parallel surfaces as the contract tests require, and the seven-stage toolchain passes.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
