# Assumption A1 re-verification — expectation-key namespace is clean (AC11, pre-change leg)

Timestamp: 2026-08-20T09-53

Task: [P0-T5]

Command: git grep --untracked -n -E "ExpectedExitCode|expected_exit|expectedExit|expected_nonzero|EXPECTED_EXIT" -- docs/features
EXIT_CODE: 0

## Why `--untracked` is load-bearing

The evidence artifacts this gate searches are newly created and UNTRACKED when the gate runs, so a
plain search of tracked content would not see them and the gate could not fail. `--untracked`
searches tracked and untracked files both, so the gate is correct whether or not the feature
documents have already been committed. Exit `0` here reflects matches found (all of them inside this
feature's own folder), which is the expected outcome for this gate: the assertion is about WHERE the
matches are, not about their absence.

## Result — 107 matching lines across 6 files, all under this feature folder

| File (all under `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/`) | Matching lines |
| --- | --- |
| `evidence/baseline/ac-inventory.2026-08-20T09-53.md` | 7 |
| `evidence/baseline/file-size-census.2026-08-20T09-53.md` | 1 |
| `issue.md` | 2 |
| `plan.2026-08-17T15-00.md` | 39 |
| `research/2026-08-17T16-10-expected-nonzero-exit-research.md` | 17 |
| `spec.md` | 41 |

Zero matches anywhere else under `docs/features` — no other feature folder, no completed folder, no
archive folder, and no evidence artifact outside this feature carries any of the five tokens. The
two matches inside `issue.md` are the ones research section 7.1 recorded; the `plan`, `spec`,
`research`, and the two new baseline-evidence matches are this feature's own documents.

Assumption A1 therefore holds at the pre-change baseline: no evidence artifact in the repository
carries the new expectation token outside this feature's own documents, so the 968-artifact corpus
Invariant A is asserted over is by construction a pure "no expectation key present" population. The
plan is not halted; no spec amendment is required.

Output Summary: 107 matches in 6 files, every file under the feature folder
`docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/`.
Zero matches outside it. Assumption A1 confirmed; AC11 pre-change leg satisfied. The post-change leg
is re-run at [P7-T5].
