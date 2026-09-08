# Acceptance-criteria check-off for the remediation cycle

Timestamp: 2026-09-08T08-14

Task: [P8-T10] of `remediation-plan.2026-09-08T05-00.md`

AC source: `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md`
only. Work mode is `full-bug` (marker `- Work Mode: full-bug` at `issue.md:12`), so
`user-story.md` is not an acceptance-criteria source and was not evaluated.

## Section counts after check-off

`## Acceptance Criteria` contains exactly **45** checkbox items, of which exactly **45** are
`- [x]` and **0** are `- [ ]`.

The three unchecked boxes remaining anywhere in `spec.md` are at lines 24, 26, and 27: the
Blocker/High/Medium/Low severity radio block in `## Context`. They are not acceptance
criteria, sit outside the `## Acceptance Criteria` section, and were neither counted nor
altered.

## The twelve criteria checked off by this task

Each row names a distinct evidence artifact path and the test description or command that
satisfies the criterion.

| AC | Subject | Evidence artifact | Test description or command |
|---|---|---|---|
| AC-1 | library sourced by every self-sourcing suite | `evidence/qa-gates/dirt-lib-source-set.2026-09-08T06-00.md` | the per-suite reference table: 11 suites in the sourcing set, all referencing both libraries; the three named exclusions each show zero |
| AC-14 | non-`HintPath` csproj line is `UNIQUE` | `evidence/regression-testing/pass-after-diff-header-anchor.2026-09-08T06-00.md` | `dirt_build_artifact_plus_content: an added content line beginning with plus-plus-plus is counted and the entry is UNIQUE` |
| AC-15 | one `DIRTFILE\|` per entry, narrowed to classified registrations | `evidence/regression-testing/pass-after-rename-split.2026-09-08T06-00.md` | `dirt_rename_split: an untracked path containing the rename literal is reported in full and is UNIQUE` |
| AC-31 | format, lint, and test pass in a single consecutive pass | `evidence/qa-gates/single-consecutive-pass.2026-09-08T07-00.md` | `bash scripts/bash/shell-qc.sh format`, `check`, and `test` — the last with `SHELL_QC_BATS_BIN` set |
| AC-32 | CI dispatch reports at least 85% line coverage | `evidence/qa-gates/coverage-delta.2026-09-08T07-00.md` | `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-dirt-classifier-632-r2`; 93.7% repo-wide, 94.05% for the dirt library |
| AC-39 | rung 1 requires a space Y column | `evidence/regression-testing/pass-after-staged-y-column.2026-09-08T06-00.md` | `dirt_staged_tree_worktree_delta: the MM entry is not STAGED_TREE_IS_COMMIT and the worktree is not ALL_DISPOSABLE` |
| AC-40 | the ` -> ` split is `R`/`C`-only | `evidence/regression-testing/fail-before-rename-split.2026-09-08T06-00.md` | `dirt_rename_split: a genuine R entry is still split and the destination path is classified` |
| AC-41 | the header skip is anchored | `evidence/regression-testing/sibling-check-phase4.2026-09-08T06-00.md` | `dirt_build_artifact_added_file: a dev-null header is still skipped and the entry is DISPOSABLE_BUILD_ARTIFACT` |
| AC-42 | five material staged-rung directions | `evidence/qa-gates/staged-rung-mutation-probe.2026-09-08T06-00.md` | `dirt_staged_probe_diffindex_error: a diff-index exit above one maps the staged entry to UNIQUE`, plus the four other direction tests |
| AC-43 | report-mode exit code documented and pinned | `evidence/other/decision-report-mode-exit-code.2026-09-08T06-00.md` | `report mode over dirty_worktree_status_error returns the status read exit code and emits no dirt record` |
| AC-44 | session-artifact rung retained; no `--ignored` | `evidence/other/decision-session-artifact-reachability.2026-09-08T06-00.md` | `no status read the classifier issues carries --ignored` |
| AC-45 | dirt library at or above 85% line coverage | `evidence/qa-gates/dirt-lib-coverage.2026-09-08T07-00.md` | 158 of 168 instrumented lines, 94.05%, from `kcov-merged/cov.xml` of run 34194469882 |

All twelve artifact paths are distinct.

## Check-off discipline

Each criterion was checked off only after the work satisfying it was implemented and
verified, with the verifying run recorded in the named artifact. Only `- [ ]` was changed to
`- [x]`; no criterion text was altered by this task. No criterion was added. The five
criteria that this cycle unchecked before re-checking — AC-1, AC-14, AC-15, AC-31, AC-32 —
are the reconciliation set named in `remediation-inputs.2026-09-08T05-00.md`; AC-1, AC-15,
AC-31, and AC-32 had their text amended in Phase 1 to describe what is actually true and
actually run, and AC-14's text was left unchanged because the defect was in the code rather
than in the criterion.

Output Summary: All 45 acceptance criteria in `spec.md` are checked. The twelve this task
closed each carry a distinct evidence artifact and a named verifying test or command.
