# Feature Audit: Issue #934 — workspace-encoding test host-specific paths

- Issue: #934
- Review timestamp (UTC): 2026-10-16T01-25

## Scope and Baseline

- Branch: `bug/workspace-encoding-test-host-specific-paths-934` at `9fcf0909eb24a6c3a0cdb419149e2288baa7cc9f`
- Base: `origin/main` at `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`; merge base equals `origin/main`.
- Work mode: `minor-audit` (`issue.md` line 12). AC source: `issue.md` `## Acceptance Criteria` only. `spec.md` and `user-story.md` are absent, as expected for this mode.
- Diff scope: `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts` (+74/-47), `extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts` (+11/-6), and 39 feature-folder Markdown files. No production file changed.
- Method: the executor had already checked off AC-1 through AC-6. The reviewer re-verified each criterion against the code at head and against `git diff origin/main...HEAD`, using the committed evidence only where rerunning would mutate state or regenerate coverage.

## Acceptance Criteria Inventory

| ID | Criterion (abridged) | Source |
|---|---|---|
| AC-1 | `workspace-encoding.test.ts` has zero case-insensitive matches for the host user token (33 before) | `issue.md` line 61 |
| AC-2 | Neither test file holds a drive-letter absolute path or an encoded absolute directory name in a literal or comment; fixtures composed at runtime | `issue.md` line 62 |
| AC-3 | Assertion semantics unchanged: all tests pass, per-file counts equal baseline, covered input shapes preserved | `issue.md` line 63 |
| AC-4 | Expected encoded names in `workspace-encoding.test.ts` are derived without calling `encodeWorkspacePath` | `issue.md` line 64 |
| AC-5 | No production file changes under `extensions/drm-copilot/src` | `issue.md` line 65 |
| AC-6 | Prettier, ESLint, typecheck pass; both files <= 500 lines; full coverage run passes with no regression for the two modules, recorded numerically | `issue.md` line 66 |

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence |
|---|---|---|
| AC-1 | PASS | Reviewer `grep -ci danmoisan` on the head file: 0. Same command on the `origin/main` version: 33. Matches `evidence/baseline/ac1-token-count.2026-10-16T00-12.md` and `evidence/qa-gates/ac1-token-count.2026-10-16T01-17.md`. |
| AC-2 | PASS | Reviewer searches on both head files: `\b[A-Za-z]:[\\/]` 0 matches; `(^|[^A-Za-z0-9])[A-Za-z]--` 0 matches. Fixtures are composed as `` `${UPPER_DRIVE}:${separator}${...join(separator)}` `` and `` `${drive}--${...join("-")}` `` (workspace-encoding) and `` `${DRIVE}:${path.win32.sep}...` `` / `` `${DRIVE}--...` `` (session resolver). The comment that previously held a path now reads `<workspace parent>/drm-copilot-wt/<timestamp>`. Consistent with `evidence/qa-gates/ac2-hostpath-count.2026-10-16T01-17.md` (exit 1, empty) and the positive and negative regex probes in `evidence/baseline/`. |
| AC-3 | PASS | Reviewer counts, base vs head: `it(` 9/9 and 5/5 (plus one 7-case `it.each`), `expect(` 9/9 and 8/8. Per-test comparison of the diff (code review, Assertion Semantics Comparison) shows each test keeps its separator, case, suffix, rejection, and empty-result shape and its matcher; only the user segment changes. `evidence/qa-gates/jest-workspace-encoding.2026-10-16T01-14.md` (9/9) and `jest-session-transcript-resolver.2026-10-16T01-15.md` (12/12) record passing runs with titles identical to baseline; `ac3-shape-tokens.2026-10-16T01-18.md` maps all nine shape tokens. The reviewer did not rerun Jest. |
| AC-4 | PASS | `encodedNameOf` (lines 21–23) is `` return `${drive}--${[...PARENT_SEGMENTS, ...segments].join("-")}`; `` and calls neither `encodeWorkspacePath` nor `workspacePathOf`. `encodeWorkspacePath` appears only at line 4 (import), line 25 (describe title), and inside test bodies to produce the value under test or the matcher input. A regression in the encoder would change the actual value without changing the expected value. |
| AC-5 | PASS | Reviewer `git diff --name-only origin/main...HEAD -- extensions/drm-copilot/src`: empty. Full branch name list contains only the two test files and feature-folder Markdown. |
| AC-6 | PASS | Prettier check, ESLint, `tsc -p ./ --noEmit`, and `tsc -p tsconfig.jest.json --noEmit` exit 0 (`evidence/qa-gates/*.2026-10-16T01-13.md`). Reviewer `wc -l`: 219 and 152. Reviewer read the raw coverage logs `SCRATCH/issue-934/jest-coverage-baseline.log` and `jest-coverage-final.log`: 270/270 suites, 4002/4002 tests; `workspace-encoding.ts` 100% lines / 100% branch before and after; `session-transcript-resolver.ts` 100% lines / 85.71% branch before and after; no threshold failure. Numbers recorded in `evidence/baseline/jest-coverage.2026-10-16T00-20.md`, `evidence/qa-gates/jest-coverage.2026-10-16T01-16.md`, and `coverage-delta.2026-10-16T01-17.md`. The criterion names `npm run typecheck`; the executor ran its two `tsc` halves directly, which the end-state summary attributes to `package.json` lines 209–210. |

### Findings outside the AC set

- B1 (Blocking, autonomous): the research artifact `research/2026-10-15T17-50-workspace-encoding-host-paths-research.md` quotes the removed absolute host paths and encoded names on lines 55 and 107–111. The ACs are scoped to the two test files, so this does not change any AC verdict, but it conflicts with the repository rule cited in `issue.md` §Suspected Cause. Details in the policy audit and code review.
- Non-blocking: `issue.md` line 5 Status names a folder path that differs from the actual feature folder.

## Summary

- AC verdicts: 6 PASS, 0 PARTIAL, 0 FAIL, 0 UNVERIFIED.
- Blocking findings: 1 (B1, documentation artifact, autonomous).
- Feature verdict: the code change delivers the issue's acceptance criteria; merge readiness depends on resolving B1.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/issue.md`
- Total AC items: 6
- Checked off (delivered): 6
- Remaining (unchecked): 0
- Items remaining: none

## Acceptance Criteria Check-off

All six AC items were already checked off by the executor in `issue.md`. The reviewer's independent evaluation agrees with each check-off (all PASS). No item was newly checked off and no item was unchecked by this review.
