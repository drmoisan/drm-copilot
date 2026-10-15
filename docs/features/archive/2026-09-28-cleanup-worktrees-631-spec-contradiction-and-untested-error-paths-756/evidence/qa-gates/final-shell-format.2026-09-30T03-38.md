# Final shell format (P2-T1)

Timestamp: 2026-10-08T02:30:00Z
Command: sh scripts/bash/shell-qc.sh format (NOT run locally); tree observation: git status --porcelain (recorded once, before)
EXIT_CODE: NOT_RUN
EFC: TRIGGERED (operator decision Option A: not run locally; CI run 37716284664 is the evidence)
Output Summary: Command not run locally per operator decision Option A (the Bash guard in this worktree prevents the invocation). The CI step `Run shell-qc check (shfmt diff + shellcheck)` in run 37716284664 (job 113113368962, headSha 4f960432d0e7f3378d18091c2a02f5b8a94323e0) concluded success and stands as the equivalent shfmt diff evidence (see final-ci-run.2026-09-30T03-38.md, P2-T11). Bats files are not discovered by shell_qc_lib.sh, so no change is expected from the formatter.
Tree observation (git status --porcelain, before; the single observation, since the formatter was not run):
- M docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756/evidence/baseline/baseline-bats-classification.2026-09-30T03-38.md
- M docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756/evidence/baseline/baseline-bats-report-records.2026-09-30T03-38.md
- M docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756/evidence/baseline/baseline-shell-check.2026-09-30T03-38.md
- M docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756/evidence/baseline/baseline-shell-test.2026-09-30T03-38.md
- M docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756/evidence/regression-testing/bats-classification-after.2026-09-30T03-38.md
- M docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756/evidence/regression-testing/bats-report-records-after.2026-09-30T03-38.md
- M docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756/evidence/regression-testing/fail-before-exception.2026-09-30T03-38.md
- ?? docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756/evidence/qa-gates/
All listed paths are documentation evidence under docs/features/active/; no shell source, test, fixture, .claude, or extensions path appears.
