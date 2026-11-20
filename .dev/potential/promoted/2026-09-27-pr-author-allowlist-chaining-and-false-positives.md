# pr-author-allowlist-chaining-and-false-positives (Issue #733)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pr-author-allowlist-chaining-and-false-positives/ (Issue #733)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #733
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/733
- Last Updated: 2026-09-27
## Summary

The `pr-author` agent's `Bash(git log *)` permission can be stretched to other commands by chaining. Meanwhile `enforce-pr-author-skill.ps1` blocks some legitimate commands. Both problems come from matching on whole command text.

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: the pr-author agent's receipt generation; `gh pr create --body-file ...`; commit messages
- Data source or fixture: parallel run followups-2026-09-27 (items #712, #714, #715)

## Steps to Reproduce

1. The pr-author agent needs the SHA-256 of the PR body for its receipt, but has no sanctioned tool to compute it. In #712 it ran `git log ... && sha256sum ... && date ...`, and the command was accepted under its `git log` allowlist prefix.
2. `enforce-pr-author-skill.ps1` blocked a commit message containing the words `gh`, `pr` and `create` (#714).
3. The same hook rejects a quoted or absolute `--body-file` path with `PR_BODY_PATH_NONCANONICAL` (#715).

## Expected Behavior

An allowlist entry authorises exactly the command it names; chained commands are evaluated segment by segment. Receipts can be produced with a sanctioned tool. The hook matches `gh pr create` invocations, not text inside commit messages or legitimate path spellings.

## Actual Behavior

- Allowlist boundary gap: a chained command inherits the permission of its first segment.
- False positives cost remediation steps on two items.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: #712, #714 and #715 final reports (the parallel-orchestrator's completion report for followups-2026-09-27).

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Prefix-match permission rules and whole-text hook matching. Related memory notes: worktree-isolation-guard-denylist and enforcement-hook-trigger-matches-whole-command-text. The #715 child recorded "hook-body-file-must-be-unquoted" in `.claude/agent-memory/pr-author/`.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: give pr-author a sanctioned receipt generator (a small script or MCP tool that writes the body and the `.receipt.json` with the SHA-256); add a hook or permission check that denies chained commands for the pr-author agent; make the pr-author hook match the tokenised `gh pr create` invocation only; accept quoted or absolute `--body-file` values that resolve to the canonical `artifacts/pr_body_<N>.md`.
- [ ] Integration scenario to retest: a pr-author delegation produces a valid receipt with no chaining.
- [ ] Manual verification notes: audit the other agents' `Bash(<prefix> *)` rules for the same chaining exposure.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
