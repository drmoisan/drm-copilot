# feature-review-coverage-hook-review-follow-ups (Issue #896)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/feature-review-coverage-hook-review-follow-ups/ (Issue #896)
- Origin: issue #824 follow-ups (PR #879), code-review findings CR-4, CR-6, CR-8, CR-9 and Follow-ups item 5

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #896
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/896
- Last Updated: 2026-10-11
## Summary

PR #879 made `.claude/hooks/validate-feature-review-coverage.ps1` read coverage floors from the consuming repository's `CLAUDE.md`. Open findings remain: an unreadable `CLAUDE.md` makes the hook fail closed although the spec says it falls back to defaults (CR-4); the hook is 477 lines, 23 under the 500-line limit (CR-8); comparator-after-figure statements silently fall back to defaults (CR-9); a mock is repeated in eight test cases (CR-6). The Codex copy `.codex/hooks/validate-feature-review-coverage.ps1` still enforces a separate fixed 80% floor, and 80/90 figures remain in the feature-review-workflow skills and `.codex/agents/feature-review.toml`.

## Environment

- OS/version: any
- Python version: n/a (PowerShell 7)
- Command/flags used: feature-review SubagentStop completion gate
- Data source or fixture: main at 2ef8d361

## Steps to Reproduce

1. Make the repository-root `CLAUDE.md` unreadable (or simulate a read failure in a test) and run the hook.
2. Write a coverage statement as "line coverage: 70% minimum" in `CLAUDE.md` and run the hook.
3. Read `.codex/hooks/validate-feature-review-coverage.ps1` and `.codex/agents/feature-review.toml` for fixed floors.

## Expected Behavior

- Behavior on an unreadable `CLAUDE.md` matches the spec (fall back to defaults), or the spec states fail-closed.
- Statements the parser does not recognize are reported rather than silently replaced by defaults, or the accepted form is documented.
- The Claude and Codex hooks and the feature-review skill/agent texts use the same floor source.

## Actual Behavior

- CR-4 (Minor): `.claude/hooks/validate-feature-review-coverage.ps1:50-71`, used at line 441, throws on an unreadable `CLAUDE.md` (fail closed).
- CR-8 (Info): the hook was 471 lines at review and is 477 on main after 8cf45ada7.
- CR-9 (Info): `.claude/hooks/feature-review-coverage-thresholds.ps1:57`: statements that put the figure before the comparator fall back to defaults.
- CR-6 (Nit): `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1`, F824-1..F824-8 (lines 41-230), repeat the `Get-ArtifactFileContent` mock switch.
- PR #879 Follow-ups item 5: "`.codex/hooks/validate-feature-review-coverage.ps1` and its mirror keep a separate 80 percent floor; 80/90 figures remain in the feature-review-workflow skills and `.codex/agents/feature-review.toml` and their mirrors".

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: PR #879 Risks: "Unreadable root `CLAUDE.md` makes the hook fail closed rather than apply defaults (CR-4). Mitigation: safe direction; spec wording or behavior alignment is a follow-up."
- Sources: `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/code-review.2026-10-10T00-44.md` lines 33-41 and `code-review.2026-10-10T14-25.md` lines 46-54 (CR-4 and CR-6 "Open, deferred").

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. The Claude and Codex feature-review gates enforce different floors, so the same review can pass on one surface and fail on the other. The other findings are low individually; the line-count headroom limits further changes to the hook.

## Suspected Cause / Notes

- #824 Addendum 2 scoped the configurable floor to the Claude hook; the Codex hook and the skill/agent texts were left for follow-up.
- The Codex hook's own test coverage (7.30%) is tracked separately in #884.

## Proposed Fix / Validation Ideas

- [ ] Align CR-4 behavior and spec wording; document or accept the comparator-after-figure form (CR-9).
- [ ] Move further logic into dot-sourced helpers to restore headroom below 500 lines (CR-8).
- [ ] Port the configurable floor to `.codex/hooks/validate-feature-review-coverage.ps1` and replace fixed 80/90 figures in the feature-review-workflow skills and `.codex/agents/feature-review.toml` (and mirrors).
- [ ] Unit coverage areas: extract the repeated mock into a helper (CR-6); add tests for the unreadable-file and comparator-after-figure paths.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch