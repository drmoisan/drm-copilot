# workspace-encoding-test-host-specific-paths (Issue #934)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/ (Issue #934)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #934
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/934
- Last Updated: 2026-10-15
- Work Mode: minor-audit

## Summary

extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts contains about 30 lines with a host-specific user path segment. Recorded as #903 Operator Follow-up 2 (related to #846 CR-6).

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

1. grep the file for the host user segment.

## Expected Behavior

Tests use neutral fixture paths.

## Actual Behavior

About 30 lines encode a real host path, which leaks host data and ties the test to one machine layout.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: #903 issue.md Operator Follow-ups item 2.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Suspected Cause / Notes

Repository rule: never encode absolute host paths in artifacts.

## Proposed Fix / Validation Ideas

- [ ] Replace the host-specific segments with a neutral placeholder and keep the encoding assertions unchanged.

## Acceptance Criteria

Adopted approach (research artifact `research/2026-10-15T17-50-workspace-encoding-host-paths-research.md`, Option A): fixture workspace paths and expected encoded directory names are composed at runtime from a drive-letter token, separator constants (`path.win32.sep`, `path.posix.sep`), and neutral relative segments (neutral user segment `fixtureuser`). No source literal or comment holds an absolute path or an encoded absolute path. Scope is the two test files below; the production module `extensions/drm-copilot/src/lib/subagent-tree/workspace-encoding.ts` is unchanged. `session-transcript-resolver.test.ts` is included as a related occurrence of the same defect class (decision OD-1, recorded in the orchestrator checkpoint).

- [x] AC-1: `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts` contains no occurrence of the host user segment: a case-insensitive search for the token `danmoisan` in that file returns zero matches (33 matching lines before the change).
- [x] AC-2: Neither `workspace-encoding.test.ts` nor `extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts` contains a string literal or comment holding a drive-letter absolute path (a drive letter followed by `:` and a path separator) or an encoded absolute directory name (a drive letter followed by `--`); every fixture workspace path and expected encoded name in both files is composed at runtime from neutral relative segments, verified by zero-match searches on both files after formatting.
- [x] AC-3: Assertion semantics are unchanged: every test in `workspace-encoding.test.ts` (9 tests) and in `session-transcript-resolver.test.ts` passes, the per-file test counts equal the baseline counts, and the covered input shapes are preserved (backslash and forward-slash separators, uppercase input versus lowercase on-disk directory, `-wt-` worktree and nested worktree suffixes, unrelated-suffix rejection, other-repository rejection, empty result).
- [x] AC-4: The expected encoded names in `workspace-encoding.test.ts` are derived without calling `encodeWorkspacePath`, so a regression in the production function cannot be masked by the fixture helper.
- [x] AC-5: No production file changes: `git diff origin/main --name-only -- extensions/drm-copilot/src` is empty at the end of execution.
- [x] AC-6: Prettier check, ESLint, and `npm run typecheck` pass for the touched files, both touched files are at or under 500 lines, and the full TypeScript coverage run (`npm run test:coverage` in `extensions/drm-copilot`) passes with line and branch coverage for `src/lib/subagent-tree/workspace-encoding.ts` and `src/lib/subagent-tree/session-transcript-resolver.ts` not below their baseline values, recorded numerically in baseline and QA-gate evidence.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch