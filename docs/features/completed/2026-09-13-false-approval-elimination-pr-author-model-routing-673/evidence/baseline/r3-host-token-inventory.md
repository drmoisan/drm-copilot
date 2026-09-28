# Phase 0 Host-Token Inventory (issue #673)

Timestamp: 2026-09-19T17-35

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-host-tokens.ps1` (route `a`), with the scan root supplied as the repository-relative value `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673`.

EXIT_CODE: 0

## Host values computed at run time

The script derived, and did not print, three host values: the worktree-root set from `git worktree list --porcelain` (74 registered roots), the user profile directory (an 18-character string), and the account name (a 9-character string). Only the last of these feeds a matcher; the first two are computed because the task text requires it and because `[P1-T5]` consumes them as replacement sources. Their spellings are not written here or anywhere else in this artifact.

## Matchers applied

- m1: regex `(?<![A-Za-z])[A-Za-z]:[\\/]`
- m2: regex `(?<![A-Za-z0-9._-])/[A-Za-z]/[A-Za-z]`
- m3: regex `[\\/](Users|home)[\\/]`
- m4: case-insensitive simple match of the account name

A file's reported count is the number of lines matching **any** matcher; the per-matcher figures beside it are line counts per matcher and therefore sum to at least the file count.

## Files with a non-zero count (18 of 46 scanned)

All paths are repository-relative. No matched text is reproduced, per binding rule 6.

| # | File | Lines matching any matcher | m1 | m2 | m3 | m4 |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-13T20-48.md` | 2 | 1 | 1 | 1 | 1 |
| 2 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-18T13-30.md` | 4 | 2 | 2 | 0 | 0 |
| 3 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/execution-route.md` | 12 | 12 | 1 | 12 | 12 |
| 4 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/phase0-base-ref.md` | 2 | 2 | 0 | 2 | 2 |
| 5 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/phase0-mirror-gate.md` | 1 | 1 | 0 | 1 | 1 |
| 6 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/phase0-pester-coverage.md` | 6 | 5 | 1 | 5 | 5 |
| 7 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/phase0-poshqc-analyze.md` | 5 | 4 | 1 | 4 | 4 |
| 8 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/phase0-poshqc-format.md` | 2 | 2 | 0 | 2 | 2 |
| 9 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/phase0-python-free-guard.md` | 4 | 4 | 0 | 4 | 4 |
| 10 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/phase0-worktree-status.md` | 1 | 1 | 0 | 1 | 1 |
| 11 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/repro-3-2-control-pair.md` | 5 | 3 | 3 | 5 | 5 |
| 12 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/repro-3-4-control-pair.md` | 4 | 2 | 3 | 4 | 4 |
| 13 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/repro-fixture-manifest.md` | 4 | 3 | 1 | 3 | 3 |
| 14 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/other/f1-manifest-registration.md` | 4 | 4 | 0 | 4 | 4 |
| 15 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/other/payload-derivability-results.md` | 2 | 2 | 0 | 2 | 2 |
| 16 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/other/payload-sample-inventory.md` | 1 | 1 | 0 | 1 | 1 |
| 17 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/other/phase1-evidence-commit.md` | 3 | 3 | 0 | 3 | 3 |
| 18 | `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/research/2026-09-13T22-10-false-approval-elimination-research.md` | 2 | 2 | 0 | 2 | 1 |

FILES_SCANNED: 46
MATCHER_TOTALS: m1=54 m2=13 m3=56 m4=55

## Files with a zero count, called out because a later task depends on it

- `plan.2026-09-19T09-00.md` — count 0. This is the acceptance condition of this task, and it holds: the plan of record carries no host token under any of the four matchers.
- `plan.2026-09-18T16-00.md` — count 0. This superseded plan is one of the three `[P1-T5]` excludes from redaction, and it needs no redaction in any case.
- All eleven `r3-`-prefixed artifacts written earlier in Phase 0 — count 0 each. They are absent from the table above.

## Redaction set handed to `[P1-T5]`

`[P1-T5]` redacts every file listed above **except** the three superseded plans it names by path. Two of those three appear above (rows 1 and 2); the third, `plan.2026-09-18T16-00.md`, has a zero count and is absent from the table. The redaction set is therefore the **16 files at rows 3 to 18**.

Output Summary: 46 files scanned under the feature folder; 18 carry at least one host token, for 54, 13, 56, and 55 matching lines under matchers m1 to m4 respectively. Every listed path is repository-relative and every count is a number. `plan.2026-09-19T09-00.md` has count 0, satisfying the acceptance condition. No matched text is reproduced anywhere in this artifact. The redaction set for `[P1-T5]` is 16 files: rows 3 to 18, which is rows 1 to 18 less the two superseded plans that appear in the table.
