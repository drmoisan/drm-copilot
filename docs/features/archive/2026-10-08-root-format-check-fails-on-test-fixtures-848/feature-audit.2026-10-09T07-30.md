# Feature Audit: root-format-check-fails-on-test-fixtures (Issue #848)

- Timestamp: 2026-10-09T07-30
- Branch: bug/root-format-check-fails-on-test-fixtures-848
- Baseline: origin/main
- Work Mode: minor-audit
- AC source: `issue.md` `## Acceptance Criteria` (explicit section present, 4 checkbox items)
- Plan reviewed: `plan.2026-10-09T01-32.md`

## Scope and Baseline

- Scope: full branch diff against `origin/main` (24 files, 719 insertions, 0 deletions).
- Baseline: `origin/main`; baseline format-check evidence recorded under `evidence/baseline/`.
- Work Mode: minor-audit; the AC source is the explicit `## Acceptance Criteria` section of `issue.md`.

## Acceptance Criteria Inventory

1. AC-1: root `npm run format:check` exits 0 on branch head.
2. AC-2: Prettier excludes `tests/fixtures/` for both `format` and `format:check`.
3. AC-3: no file under `tests/fixtures/` modified; invalid-JSON fixture byte-identical.
4. AC-4: two WorktreeResolution Pester suites pass unchanged.

## Summary

PASS. Blocking findings: 0. All four acceptance criteria are verified PASS.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|---|---|---|
| AC-1: root `npm run format:check` exits 0 on branch head | PASS | `evidence/qa-gates/root-format-check.2026-10-09T06-30.md`: EXIT_CODE 0, "All matched files use Prettier code style!", no warn or error line. Contrast: baseline exit 2 with 216 warn lines and 1 parse error. |
| AC-2: Prettier excludes `tests/fixtures/` for both `format` and `format:check` | PASS | Root `.prettierignore` contains `tests/fixtures/`. Check script output has 0 `tests/fixtures` tokens (reviewer re-grep: 0). `format-script-file-set` artifact: `--list-different` over the six write-script globs exits 0 with no output and no error, so the write script's file set excludes fixtures. The write script itself was not run, correctly, since it rewrites files. |
| AC-3: no file under `tests/fixtures/` modified; invalid-JSON fixture byte-identical | PASS | `git diff --name-only origin/main -- tests/fixtures` printed nothing (reviewer re-run) and `git status --porcelain` is clean. The branch diff of 24 files contains no fixture path. |
| AC-4: two WorktreeResolution Pester suites pass unchanged | PASS | model-routing-receipt: 20 passed, 0 failed; pr-author-skill: 18 passed, 0 failed; both equal baseline counts. Suites and fixtures are unmodified. |

## Plan Conformance

- Plan tasks P0-T1 through P2-T14 are all checked. Every artifact-bearing task has its artifact under `evidence/baseline`, `evidence/qa-gates`, or `evidence/regression-testing`.
- Implemented file matches P1-T2 exactly (comment line plus `tests/fixtures/`, LF, final newline).
- Scope boundary (P2-T8): only `.prettierignore`, the feature folder, and the promoted lifecycle record appear in the diff. Package manifest scripts and lockfile are unchanged.

## Deviation Assessment: 216 vs 214 baseline warn lines

- Observed: 216 `[warn]` lines (reviewer grep of the baseline artifact confirms 216), plus 1 `[error]`. The plan and issue estimated 214 warn lines.
- The plan's P0-T7 acceptance requires every printed warn and error path to start with `tests/fixtures/`. That holds, and the executor recorded the discrepancy in the artifact's Output Summary.
- Cause: likely fixture files added to main after the #830 baseline from which 214 was taken. This is probable, not confirmed.
- No AC references the count, and the post-change run reports zero issues in all paths.
- Classification: non-blocking deviation (informational).

## Out-of-Scope Item

Adding root `format:check` to CI is excluded by the issue scope note and is not evaluated.

## Acceptance Criteria Check-off

- [x] AC-1: confirmed PASS; already checked in `issue.md`.
- [x] AC-2: confirmed PASS; already checked in `issue.md`.
- [x] AC-3: confirmed PASS; already checked in `issue.md`.
- [x] AC-4: confirmed PASS; already checked in `issue.md`.

Newly checked-off items: none. All four items were already checked in `issue.md`.

### Acceptance Criteria Status
- Source: docs/features/active/2026-10-08-root-format-check-fails-on-test-fixtures-848/issue.md
- Total AC items: 4
- Checked off (delivered): 4
- Remaining (unchecked): 0
- Items remaining: none

## Advisory (non-blocking)

- `issue.md` Status line names a folder that does not match the actual feature folder.
- Plan `Status` remains "Draft".
- `changed-files` evidence abbreviates its path list.
