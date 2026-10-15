# Fail-before exception dossier

Timestamp: 2026-10-07T22-10

WhyFailingRunImpossible: The new tests pin behavior that already exists in the library (the `rc=2` pairwise hard-failure statement in `classify_all_branches` and the scan-failure, stale-ref, and rc-maximization statements in `run_report_scans`). No production file is changed by this work, so no pre-change run of the new tests can fail.

SearchScope: docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756/evidence/regression-testing/
SearchPatterns: fail-before-*.md
SearchResult: none (no failing-run artifact exists; this dossier is the only `fail-before-*` artifact)

## Alternative proof

1. Control versus pairwise scenario. The artifact `pairwise-scenario-diff.2026-09-30T03-38.md` (P1-T27) shows `child_of_pairwise_probe_error` differs from `child_of_not_merged` by exactly one file, `merge-base.feature-child.feature-parent.rc` (value 128). The existing `child_of_not_merged` test in `tests/shell/test_cleanup_worktrees_classification.bats` asserts status 0 and acts as the control; test N1 asserts status 2 on the one-file variant, so the status change is attributable to the pairwise probe alone.
2. Library line-rate. The pre-change library `line-rate` is 87.9% (0.879), as recorded in the artifact `baseline-ci-coverage-library.2026-09-30T03-38.md` (kcov `cov.xml` of the baseline CI run for `cleanup_worktrees_report_records_lib.sh`). That value is the AC-5 no-reduction reference.
3. Mutation argument (no production file is mutated). Removing the `rc=2` statement fails N1 (status would be 0) and N2 (status 2 assertion). Replacing `return "$scanrc"` fails N3 (status 3 asserted). Removing the `srrc > scanrc` branch fails N4 (status 5 asserted; the scan code 3 would be returned instead). Removing `rc=$srrc` fails N5 (status 4 asserted). Removing `rc=$orc` fails N6 (status 7 asserted). Removing `rc=$lrc` fails N7 (status 9 asserted). Replacing the `lrc > rc` guard with an unconditional assignment fails N8 (the later 7 would replace the earlier 9, so status 9 would not hold).
