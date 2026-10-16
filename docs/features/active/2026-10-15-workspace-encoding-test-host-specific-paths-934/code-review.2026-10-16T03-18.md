# Code Review: Issue #934 — workspace-encoding test host-specific paths (remediation cycle 1 re-audit)

- Issue: #934
- Branch: `bug/workspace-encoding-test-host-specific-paths-934`
- Head: `735a60d825fc49de4919ad845c40db90540d52c0`
- Base: `origin/main` at `97559c3e0dcfceb807ae330d3c9e6ae4c5d67964`
- Review timestamp (UTC): 2026-10-16T03-18
- Scope: full branch diff (2 TypeScript test files, 83 feature-folder Markdown files)

## Executive Summary

The cycle-1 code change is limited to `workspace-encoding.test.ts`: the `encodedNameOf` helper no longer takes a `drive` parameter (prior finding N1) and builds the expected name from `UPPER_DRIVE` and the supplied segments. All 16 call sites were updated to pass segments only. `session-transcript-resolver.test.ts` is unchanged in this cycle. The documentation changes redact the host-path literals from the research artifact (prior blocking finding B1) and correct the `issue.md` Status line (prior N5).

The reviewer compared every assertion at head against `origin/main`. Each test keeps its input shape, separator, expected-value relationship, and matcher; only the user segment differs from the original literals (`fixtureuser`). Test call sites (9 and 6) and `expect(` counts (9 and 8) equal the base. `encodedNameOf` still does not call `encodeWorkspacePath`, so a regression in the production encoder would fail test 1 and the matcher tests.

Blocking count: 0.

## Assertion Semantics Comparison

| Test | Old input / expected (base) | New input / expected (head) | Equivalent |
|---|---|---|---|
| encode: backslash, slash, colon to hyphen | backslash path literal; encoded literal for the same path | `workspacePathOf(BACKSLASH, REPO)`; `encodedNameOf(REPO)` | yes |
| encode: slash equals backslash | two literals compared to each other | `workspacePathOf(BACKSLASH, REPO)` vs `workspacePathOf(SLASH, REPO)` | yes |
| match: lowercase on-disk drive | lowercase literal; other-repo literal; expect `[lowercase]` | `encodedNameOf(REPO).toLowerCase()`; `encodedNameOf(OTHER_REPO)` | yes |
| match: `-wt-` sibling | base, sibling, unrelated-suffix, other-repo; expect base + sibling | same four shapes via `encodedNameOf` | yes |
| match: nested worktree-of-worktree | backslash `-wt-` workspace; expect `directoryNames` | same | yes |
| match: empty result | other-repo only; expect `[]` | same | yes |
| match: new-scheme nested sibling | backslash base; expect base + nested | same | yes |
| match: new-scheme worktree-of-worktree | slash path with `-wt/<ts>`; expect `directoryNames` | `workspacePathOf(SLASH, `${REPO}-wt`, ts)` | yes |
| match: exact equality on nested leaf | slash path with `-wt/<ts>`; expect leaf only | same | yes |
| session resolver (12 tests) | `WORKSPACE_ROOT`, `EXACT_DIR`, `SIBLING_DIR` literals | same three constants composed at runtime; test bodies unchanged | yes |

Host-path checks run by the reviewer at head on both test files: AC-1 search token (case-insensitive) 0 matches (baseline 33 in `workspace-encoding.test.ts`); `[A-Za-z]:[\\/]` 0 matches; `[A-Za-z]--` 0 matches. The only `Users` occurrences are the neutral segment arrays.

## Prior Findings Verification

| ID | Prior severity | Status at head | Evidence |
|---|---|---|---|
| B1 | Blocking | Resolved | Research lines 55 and 107-111 now use `<drive>`, `<drive-lowercase>`, and `<host-user>` placeholders. Reviewer `grep -rnE '[A-Za-z]:[\\/]{1,2}Users[\\/]{1,2}[A-Za-z]'` over the feature folder and both test files: exit 1, empty. No encoded host name remains; the only encoded-form matches are one-letter synthetic examples, the generic prefix mention on research line 47, and placeholder forms. |
| N1 | Non-blocking | Applied | Line 21 signature `encodedNameOf(...segments: string[]): string`; `UPPER_DRIVE` appears on lines 8, 17, and 22 only. |
| N5 | Non-blocking | Fixed | `issue.md` line 5 names `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/`. |
| Visible expected-literal comment (prior row 3) | Non-blocking | Declined (decision D5) | A comment showing the encoded fixture name would itself contain a drive letter followed by `--` and would violate AC-2. The reviewer agrees with the decision. |

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Non-blocking | `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/research/2026-10-15T17-50-workspace-encoding-host-paths-research.md` | lines 31, 56 | The mixed-case form of the host user token remains as bare prose (letter-case description on line 31; `package.json` publisher identifier on line 56). No path or encoded name is present. | Optional: replace the token on line 31 with `<host-user>`. | Retained under decision D2 and permitted by the 01-25 remediation inputs (bare-token prose without a path). The string is the public publisher identifier already in the manifest. | Reviewer case-insensitive search of the research file: lines 31, 56, 143. |
| Non-blocking | same research file | lines 107-120, 145 | The derivation table "New" column and the absence-check note still show the pre-N1 two-argument helper form. | No action; the research file is a point-in-time artifact. | Documentation drift only; the test file is authoritative. | Research file at head. |
| Non-blocking | both test files | module constants | Fixture constants are defined separately in the two files (`PARENT_SEGMENTS` + `REPO` versus `WORKSPACE_SEGMENTS`). | No change required. | Small duplication limited to two files; decision D6. | Diff of both files. |

## Code Quality Observations

- Helpers are pure, typed, and two lines each.
- `node:path` is used only for its `sep` constants; no filesystem access is introduced.
- No `eslint-disable`, `@ts-ignore`, `@ts-expect-error`, or `@ts-nocheck` in either file.
- Arrange-Act-Assert comments are preserved in every test.
- File lengths: 198 and 152 lines.
- No production file under `extensions/drm-copilot/src` changed (`git diff origin/main --name-only -- extensions/drm-copilot/src`: empty).
- The merge commit `735a60d82` changed no file under `extensions/drm-copilot`.

## Blocking Count

- Blocking: 0
- Non-blocking: 3
