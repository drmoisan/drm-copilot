# guard-denylist-false-positives (Issue #742)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/guard-denylist-false-positives/ (Issue #742)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #742
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/742
- Last Updated: 2026-09-27
## Summary

Several PreToolUse guards match substrings of the whole command or path and refuse harmless operations. Across runs backlog-2026-09-26 and followups-2026-09-27 this cost agents many remediation and workaround steps.

## Environment

- OS/version: Windows 11, Claude Code
- Python version: n/a
- Command/flags used: listed below
- Data source or fixture: the #706, #707 and #713 reports and coordinator observations (2026-09-25 to 27)

## Steps to Reproduce

1. `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` blocks a plain `git --version` with `PARALLEL_WORKTREE_REMOVAL_BLOCKED` (#713).
2. The worktree isolation guard refuses `git -C` chains, output piped from `sh`, and any argument that is the word `hash` (#707).
3. A Write guard refuses evidence file names that contain "report" (#706 FU-706-5).
4. The Bash permission engine refuses `cd ... && <read-command>` forms. Observed by the coordinator; noted for completeness.

## Expected Behavior

Guards tokenise the command and match the specific operations they govern: `git worktree remove`, destructive commands, and so on. Harmless read-only commands and ordinary file names pass.

## Actual Behavior

Substring and denylist matching over the whole text produces false positives.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `PARALLEL_WORKTREE_REMOVAL_BLOCKED` on `git --version`.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

This is a recurring throughput cost; every false positive costs an agent a round trip.

## Suspected Cause / Notes

Related memory notes: worktree-isolation-guard-denylist, force-with-lease-blocked-by-validate-bash-hook, enforcement-hook-trigger-matches-whole-command-text. The pr-author hook's false positives are tracked separately (pr-author allowlist issue).

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: tokenise before matching; match the exact subcommand; add regression tests for each false positive listed, plus the true positives they protect.
- [ ] Integration scenario to retest: an agent session can run `git --version`, `git -C a status && git -C b status`, and write `evidence/.../report-*.md` without denial.
- [ ] Manual verification notes: keep every existing deny case green.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
