# Fail-Before / Pass-After Pairing (issue #673)

Timestamp: 2026-09-19T18-44

Command: no new command. This artifact pairs the recorded statuses of two runs already archived: the `[expect-fail]` run in `evidence/regression-testing/r3-fail-before-matrix.md` (`EXIT_CODE: 27`), taken against the unmodified hooks, and the post-implementation run in `evidence/qa-gates/r3-p7-scoped-pester.md` (`EXIT_CODE: 0`).

EXIT_CODE: 0

## The four pairs

Each row failed against the unmodified hooks and passes after the implementation phases. Nothing about the row changed between the two runs; only the production code did.

| # | Testcase | Before (`[P4-T5]`) | After (`[P7-T6]`) | Binding it proves |
| --- | --- | --- | --- | --- |
| 1 | `model-routing R2 denies with the no-target code when only the sibling session-root checkpoint is present` | Failed | Passed | Binding 3. The gate had no resolution step, so it read the session root's checkpoint, found the sibling's `atomic-planner` receipt, and allowed. This is defect 3.4 as a test. |
| 2 | `model-routing R2 denies with the no-target code when the only signal is a repository-relative path` | Failed | Passed | Binding 3, driven by the prompt pinned in the archived reproduction control pair, which confirms a file path is not an identity. |
| 3 | `model-routing R4 takes the verdict from the own checkpoint located by issue number when the sibling checkpoint records the receipt` | Failed | Passed | Binding 3. The verdict now comes from the worktree the issue number identifies, not from the session root. |
| 4 | `pr-author R4 takes the epic base-branch verdict from the own checkpoint when own and sibling checkpoints are both present` | Failed | Passed | Binding 2. `Test-EpicBaseBranchOverride` took no checkpoint path, so check 6 read the session root's checkpoint whatever binding 1 had resolved. |

Four Failed-then-Passed pairs.

## Dossier citation for the pr-author R2 row

The pr-author sibling-only row, `pr-author R2 denies with the no-target code when only the sibling session-root checkpoint is present`, is **not** in the table above, because it passed in both runs and therefore forms no pair. Its fail-before requirement is discharged by the exception dossier at `evidence/regression-testing/fail-before-exception.2026-09-19T09-00.md`.

That dossier records why a failing run of the row is structurally impossible on this tree: issue #687, commit `f62c85abd62d05c828751fcc6353310db49f02f5`, added the no-target deny to the pr-author gate before this plan's first task ran, so the row already asserted behaviour that was present. It offers three records in place of a failing run — the archived pre-#687 `allow` in `evidence/baseline/repro-3-2-control-pair.md`, the confirmed reproduction verdict whose commit precedes every hook edit on this branch, and row 4 of the table above as the substitute failing row for the pr-author family's second binding.

## Why row 4 is the load-bearing pr-author pair

RS-5 names row 4 specifically because it is the only pr-author row that both fails before the fix and must traverse checks 1 through 5 to reach check 6. It runs in `pr-author/session-root`, which carries the receipt, body, and context-summary bytes those checks read, while resolving its target to `pr-author/item-own-epic-mode`, which carries no artifact files and whose checkpoint is the only one under epic mode. Before the fix the epic verdict came from the working directory's checkpoint, which has no epic mode, so the row allowed; after the fix it comes from the resolved checkpoint, whose integration branch does not match the command's `--base main`, so the row denies.

Output Summary: Four Failed-then-Passed pairs are recorded, three for binding 3 and one for binding 2, each taken from two archived runs with no change to the rows between them. The pr-author sibling-only row forms no pair and is covered by the cited exception dossier, whose reasoning and substitute evidence are summarised here.
