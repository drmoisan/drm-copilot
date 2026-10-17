# Code Review: Issue #934 — workspace-encoding test host-specific paths

- Issue: #934
- Branch: `bug/workspace-encoding-test-host-specific-paths-934`
- Head: `9fcf0909eb24a6c3a0cdb419149e2288baa7cc9f`
- Base: `origin/main` at `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`
- Review timestamp (UTC): 2026-10-16T01-25
- Scope: full branch diff (2 TypeScript test files, 39 feature-folder Markdown files)

## Executive Summary

The code change is limited to two Jest test files and is correct. Literal host-specific workspace paths and encoded directory names are replaced by values composed at runtime from a drive-letter token, `path.win32.sep` / `path.posix.sep`, and neutral segments (`Users`, `fixtureuser`, `repos`). The reviewer compared every changed assertion against `git diff origin/main...HEAD` and found that each test keeps its input shape, its separator, its expected-value relationship, and its assertion matcher; only the user segment differs (`fixtureuser` in place of the host user name). Test counts (9 and 12) and `expect(` counts (9 and 8) are unchanged.

The expected-name helper `encodedNameOf` does not call `encodeWorkspacePath`; it restates the encoding rule (`<drive>--` followed by hyphen-joined segments), so a regression in the production encoder would still fail test 1 and the matcher tests.

One blocking finding concerns a committed documentation artifact, not code: the research file quotes the removed host-path literals verbatim. Blocking count: 1.

## Assertion Semantics Comparison

| Test | Old input / expected | New input / expected | Equivalent |
|---|---|---|---|
| encode: backslash, slash, colon to hyphen | backslash path literal; `C--Users-<user>-repos-drm-copilot` | `workspacePathOf(BACKSLASH, REPO)`; `encodedNameOf(UPPER_DRIVE, REPO)` | yes |
| encode: slash equals backslash | two literals, compared to each other | `workspacePathOf(BACKSLASH, REPO)` vs `workspacePathOf(SLASH, REPO)` | yes |
| match: lowercase on-disk drive | lowercase literal; other-repo literal; expect `[lowercase]` | `encodedNameOf(...).toLowerCase()`; `encodedNameOf(UPPER_DRIVE, OTHER_REPO)` | yes (whole-name lowercase, as before) |
| match: `-wt-` sibling | base, sibling, unrelated-suffix, other-repo; expect base + sibling | same four shapes via `encodedNameOf` | yes |
| match: nested worktree-of-worktree | backslash `-wt-` workspace; expect `directoryNames` | same; assertion line unchanged | yes |
| match: empty result | other-repo only; expect `[]` | same | yes |
| match: new-scheme nested sibling | backslash base; expect base + nested | same | yes |
| match: new-scheme worktree-of-worktree | slash path with `-wt/<ts>`; expect `directoryNames` | `workspacePathOf(SLASH, "drm-copilot-wt", ts)` | yes |
| match: exact equality on nested leaf | slash path with `-wt/<ts>`; expect leaf only | same | yes |
| session resolver (12 tests) | `WORKSPACE_ROOT`, `EXACT_DIR`, `SIBLING_DIR` literals | same three constants composed at runtime; test bodies unchanged | yes |

Host-path checks run by the reviewer at head on both files: case-insensitive `danmoisan` 0 matches (baseline 33 in `workspace-encoding.test.ts`); `\b[A-Za-z]:[\\/]` 0 matches; `[A-Za-z]--` at a token boundary 0 matches; the only `Users` occurrence is the neutral segment array.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/research/2026-10-15T17-50-workspace-encoding-host-paths-research.md` | lines 55, 107–111 | The derivation table and related-occurrence note quote the removed absolute host paths and their encoded names verbatim. | Replace with placeholder forms such as `<drive>:\\Users\\<host-user>\\repos\\drm-copilot` and `<drive>--Users-<host-user>-repos-drm-copilot`; keep line references and the new-expression column. | The issue cites the rule "never encode absolute host paths in artifacts"; the branch removes the literals from tests and adds them to a committed artifact. | Reviewer `grep -nE '[A-Za-z]:[\\/]{1,2}Users[\\/]{1,2}[A-Za-z]'` on the feature folder. |
| Non-blocking | `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts` | lines 21–23 | `encodedNameOf(drive, ...)` takes a `drive` parameter, but every call site passes `UPPER_DRIVE`. | Optionally drop the parameter and use `UPPER_DRIVE` inside the helper. | Unused flexibility; simplicity-first principle. | 16 call sites, all passing `UPPER_DRIVE` as the first argument. |
| Non-blocking | `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts` | lines 25–35 | Test 1 no longer shows a visible expected literal; the expected value is the helper output. A reader cannot see the concrete encoded string. | Optionally add a short comment showing the expected shape with neutral segments, for example `C--Users-fixtureuser-repos-drm-copilot`. | Readability of the primary encoding test; the research artifact identified this as residual risk. | Diff hunk at line 25. |
| Non-blocking | both test files | module constants | Fixture constants are defined separately in the two files (`PARENT_SEGMENTS` + `REPO` versus `WORKSPACE_SEGMENTS`). | No change required; consider a shared fixture module only if a third file needs the same shapes. | Duplication is small and limited to two files. | Diff of both files. |
| Non-blocking | `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/issue.md` | line 5 | Status line names `docs/features/active/workspace-encoding-test-host-specific-paths/`, which differs from the actual folder name. | Update the Status line to the actual folder path. | Documentation accuracy. | `issue.md` line 5. |

## Code Quality Observations

- Helpers are pure, typed (`(separator: string, ...segments: string[]): string`), and short.
- `node:path` is used only for its `sep` constants; no filesystem access is introduced.
- No `eslint-disable`, `@ts-ignore`, `@ts-expect-error`, `@ts-nocheck`, or `any` in either file.
- Arrange–Act–Assert comments are preserved in every test.
- The rewritten comment in the new-scheme nested sibling test describes the path as `<workspace parent>/drm-copilot-wt/<timestamp>` and no longer contains a drive or user segment.
- File lengths: 219 and 152 lines.
- No production file under `extensions/drm-copilot/src` changed.

## Blocking Count

- Blocking: 1
- Non-blocking: 4
