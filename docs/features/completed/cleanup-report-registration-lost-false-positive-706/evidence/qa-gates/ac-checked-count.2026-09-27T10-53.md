# AC Checked Count (P4-T22)

Timestamp: 2026-09-27T10-53
Command: grep -c -e '^- \[x\] AC-[1-4]:' docs/features/active/cleanup-report-registration-lost-false-positive-706/spec.md
EXIT_CODE: 0
Output Summary: 4. AC-1 through AC-4 are checked; evidence on disk: AC-1 and AC-2 (`regression-testing/scan-helper-all-tests.2026-09-27T10-28.md`, `qa-gates/qc-step4-bats.2026-09-27T10-45.md`, `qa-gates/ci-shell-coverage.2026-09-27T10-48.md`, `qa-gates/ci-not-ok-count.2026-09-27T10-48.md`, `qa-gates/scope-check.2026-09-27T10-51.md`); AC-3 (`regression-testing/fail-before.2026-09-27T10-17.md`, `regression-testing/pass-after.2026-09-27T10-25.md`, `qa-gates/ac3-root-cause.2026-09-27T10-52.md`); AC-4 (`qa-gates/qc-loop-pass.2026-09-27T10-46.md`, `qa-gates/kcov-per-file.2026-09-27T10-49.md`, `qa-gates/kcov-new-line-hits.2026-09-27T10-49.md`, `qa-gates/coverage-delta.2026-09-27T10-50.md`). The spec.md diff is exactly 4 lines changed (checkbox marks only).
