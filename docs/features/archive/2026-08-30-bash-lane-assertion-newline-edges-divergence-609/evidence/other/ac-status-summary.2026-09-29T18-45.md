# Acceptance Criteria Status Summary

Timestamp: 2026-10-01T23:59:50-04:00

### Acceptance Criteria Status
- Source: docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md
- Total AC items: 17
- Checked off (delivered): 6 (`grep -c -F -e '- [x] '` printed 6)
- Remaining (unchecked): 11 (17 minus 6)

Checked: AC-2 (normalized expansion at line 88, removed statement count 0), AC-7 (fixture exists, `1 passed`, porcelain listed), AC-9 (pytest 83 passed = N_b 82 plus 1), AC-10 (else-branch: no `edges_crlf_separated.json`, case (4) added), AC-15 (497 lines), AC-16 (write set exactly four files).

Items remaining and reasons (each has a recorded gap in `ac-gaps.2026-09-29T18-45.md`):
- AC-1: bash-lane reproduction after the fix not run (D5); no pass-after bats result.
- AC-3: case (1) pass-after result absent (D4).
- AC-4: case (2) pass-after result absent (D4).
- AC-5: cases (3) and (4) pass-after result absent (D4).
- AC-6: fail-before run absent; a dossier alone does not satisfy it (D4).
- AC-8: parity bats run absent (D4).
- AC-11: membership bats run absent (D4).
- AC-12: bats suites absent (D4).
- AC-13: new-case exit-0 assertions not run (D4).
- AC-14: coverage values PENDING-CI (D3).
- AC-17: post-fix shell-qc format and check not run (D3).

Outcome: REMEDIATION-REQUIRED pending the CI job `shell-coverage` (Shell Coverage (Bats + kcov)) on the pushed head.

Deviations: D1 (origin/main merge: `run_test` runs bats under `BASH_ENV=kcov_trace_env.sh`), D3 (shell-qc check/format/test/coverage withheld, plus one pre-fix probe of `check` that was not denied and returned empty output), D4 (bats suites withheld; fail-before dossier created), D5 (`report-lane-assertion` repro and `sh -n` withheld).
