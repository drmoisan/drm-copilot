# worktree-run-resolution-review-nits (Issue #789)

- Date captured: 2026-09-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/worktree-run-resolution-review-nits/ (Issue #789)
- Related: #690

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #789
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/789
- Last Updated: 2026-09-30
## Summary

The #690 code review (`docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/code-review.2026-09-30T01-45.md`) recorded two Nits that remediation R1 left unfixed. CR-4: UNC path comparison in `Test-WorktreeRunPathEqual` is case-sensitive. CR-5: the final deny of the parallel worktree removal gate repeats its reason token.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a
- Command/flags used: Pester suites for `WorktreeRunResolution` and `enforce-parallel-worktree-removal-gate.ps1`
- Data source or fixture: main at ae7c7779

## Steps to Reproduce

1. CR-4: call `Test-WorktreeRunPathEqual` with `//Server/Share/x` and `//server/share/X`.
2. CR-5: trigger the final deny of `enforce-parallel-worktree-removal-gate.ps1` when both run kinds resolve `NoTarget` and read the reason text.

## Expected Behavior

CR-4: UNC roots recorded with different casing compare equal, or the case-sensitive behavior is documented and tested. CR-5: the deny carries a single leading `PARALLEL_WORKTREE_REMOVAL_BLOCKED:` token.

## Actual Behavior

CR-4: `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1:355-356` selects `OrdinalIgnoreCase` only when a side matches `^[A-Za-z]:`; any other path, including UNC, compares with `Ordinal`. CR-5: `enforce-parallel-worktree-removal-gate.ps1:418-420` builds a prefix that begins `PARALLEL_WORKTREE_REMOVAL_BLOCKED:` and then appends a second string that also begins with the token.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: lines above verified by reading main; behavior not executed.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

- Changing the deny text changes what callers see; any caller that matches on the full text rather than the leading token must be checked.
- Both files are imported by live PreToolUse hooks; changes follow the single-write procedure with the suites run immediately after.

## Proposed Fix / Validation Ideas

- [ ] Add a UNC row to `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1` and make UNC comparison case-insensitive or document it as case-sensitive.
- [ ] Give the parallel removal gate's final deny a single leading token and update the existing exact-text rows.
- [ ] Keep every changed primary file byte-identical to its bundle mirror and at or below 500 lines.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
