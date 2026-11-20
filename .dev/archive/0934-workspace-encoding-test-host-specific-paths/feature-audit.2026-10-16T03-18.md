# Feature Audit: Issue #934 — workspace-encoding test host-specific paths (remediation cycle 1 re-audit)

- Issue: #934
- Review timestamp (UTC): 2026-10-16T03-18

## Scope and Baseline

- Branch: `bug/workspace-encoding-test-host-specific-paths-934` at `735a60d825fc49de4919ad845c40db90540d52c0` (includes a merge of `origin/main`).
- Base: `origin/main` at `97559c3e0dcfceb807ae330d3c9e6ae4c5d67964`; merge base equals `origin/main`.
- Work mode: `minor-audit` (`issue.md` line 12). AC source: `issue.md` `## Acceptance Criteria` only. `spec.md` and `user-story.md` are absent, as expected for this mode.
- Diff scope: `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts`, `extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts`, and 83 feature-folder Markdown files. No production file changed.
- Method: re-verification at remediation cycle 1 exit. The reviewer re-evaluated each criterion against the code at head and against `git diff origin/main...HEAD`, and read the cycle-1 evidence under `evidence/remediation-baseline/`, `evidence/other/remediation-*`, and `evidence/qa-gates/rem-*`. Coverage generation was not rerun; the raw Jest logs and JSON results under the untracked `SCRATCH/issue-934/` folder were read directly. The merge commit changed nothing under `extensions/drm-copilot`, so evidence recorded at `c71a1d242` applies to head.

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
| AC-1 | PASS | Reviewer `grep -ci` with the AC-1 token on the head file: 0. Consistent with `evidence/qa-gates/rem-ac1-token-count.2026-10-16T03-10.md` (exit 1, expected 1). |
| AC-2 | PASS | Reviewer searches on both head files: `[A-Za-z]:[\\/]` 0 matches; `[A-Za-z]--` 0 matches. After N1, fixtures are composed as `` `${UPPER_DRIVE}:${separator}${...join(separator)}` `` and `` `${UPPER_DRIVE}--${...join("-")}` `` (workspace-encoding) and `` `${DRIVE}:${path.win32.sep}...` `` / `` `${DRIVE}--...` `` (session resolver). Consistent with `evidence/qa-gates/rem-ac2-hostpath-count.2026-10-16T03-10.md` (exit 1). |
| AC-3 | PASS | Reviewer counts, base vs head: test call sites (`it(` and `it.each`) 9/9 and 6/6, `expect(` 9/9 and 8/8. Reviewer read `SCRATCH/issue-934/jest-we-rem-final.json` (9 passed of 9) and `jest-str-rem-final.json` (12 passed of 12), equal to the original baselines `jest-we-baseline.json` (9) and `jest-str-baseline.json` (12). Title lists identical to baseline per `evidence/qa-gates/rem-jest-workspace-encoding.2026-10-16T03-06.md` and `rem-jest-session-transcript-resolver.2026-10-16T03-06.md`. The per-test comparison in `code-review.2026-10-16T03-18.md` shows all covered shapes preserved. |
| AC-4 | PASS | `encodedNameOf` (lines 21-23) is `` return `${UPPER_DRIVE}--${[...PARENT_SEGMENTS, ...segments].join("-")}`; `` and calls neither `encodeWorkspacePath` nor `workspacePathOf`. Consistent with `evidence/qa-gates/rem-ac4-helper-isolation.2026-10-16T03-10.md`. |
| AC-5 | PASS | Reviewer `git diff origin/main --name-only -- extensions/drm-copilot/src`: empty. The full branch name list contains only the two test files and feature-folder Markdown. |
| AC-6 | PASS | `evidence/qa-gates/rem-prettier-check.2026-10-16T03-04.md`, `rem-eslint.2026-10-16T03-04.md`, `rem-tsc-src.2026-10-16T03-04.md`, and `rem-tsc-jest.2026-10-16T03-04.md` record exit 0. Reviewer `wc -l`: 198 and 152. Reviewer read `SCRATCH/issue-934/jest-coverage-rem-baseline.log` and `jest-coverage-rem-final.log`: 270/270 suites, 4002/4002 tests; `All files` 97.26% lines / 92.28% branch in both; `workspace-encoding.ts` 100% / 100% in both; `session-transcript-resolver.ts` 100% / 85.71% in both; no threshold failure. Numbers are recorded in `evidence/remediation-baseline/jest-coverage.2026-10-16T02-48.md`, `evidence/qa-gates/rem-jest-coverage.2026-10-16T03-07.md`, and `rem-coverage-delta.2026-10-16T03-07.md`. |

### Remediation Cycle 1 Targets

| Target | Verdict | Evidence |
|---|---|---|
| B1 (blocking): research artifact quoted host paths | RESOLVED | Reviewer `grep -rnE '[A-Za-z]:[\\/]{1,2}Users[\\/]{1,2}[A-Za-z]'` over the feature folder and both test files: exit 1, empty. Research lines 55 and 107-111 hold placeholders. No encoded host name, POSIX-style drive mount, `AppData`, 8.3 short name, or agent-worktree path appears in `issue.md`, the plans, the research file, or evidence. The lowercase AC-1 token appears only inside search commands and bare-token prose (decision D1). |
| N5: `issue.md` Status line | FIXED | `issue.md` line 5 names the actual feature folder. |
| N1: `encodedNameOf` drive parameter | APPLIED | Helper takes only `...segments`; AC-2 and AC-4 re-verified above. |

### Findings outside the AC set

- Non-blocking R1: research lines 31 and 56 retain the mixed-case host user token as bare prose without a path (decision D2). This is narrower than the caller's stated exception (lowercase AC-1 token only), but it holds no path or encoded name, equals the public publisher identifier in the extension manifest, and was permitted by the 01-25 remediation inputs. Optional redaction of line 31.
- Non-blocking R2: the research derivation table predates the N1 signature change.
- Non-blocking R3: coverage evidence is a text log in untracked `SCRATCH/`; the reviewer verified the numbers.

## Summary

- AC verdicts: 6 PASS, 0 PARTIAL, 0 FAIL, 0 UNVERIFIED.
- Blocking findings: 0.
- Feature verdict: the branch delivers all six acceptance criteria, and the remediation cycle resolved B1 without regressing any criterion. Ready for PR authoring; CI on the PR head is the remaining gate.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/issue.md`
- Total AC items: 6
- Checked off (delivered): 6
- Remaining (unchecked): 0
- Items remaining: none

## Acceptance Criteria Check-off

All six AC items were already checked off in `issue.md` (reviewer `grep -c '\[x\] AC-'`: 6). The reviewer's independent evaluation agrees with each check-off (all PASS). No item was newly checked off and no item was unchecked by this review.
