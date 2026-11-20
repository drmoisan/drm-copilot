# R2 Coverage Delta Record (issue #935, remediation cycle 2)

Timestamp: 2026-10-16T11-06
Task: [P4-T5]

Baseline coverage (CI, quoted by P0-T5 from `FEATURE/remediation-inputs.2026-10-16T07-55.md`):
- Baseline `adb9aa5f0`: 90.42%
- main at `b6be46b5e`: 90.44%
- PR head `da4ccf4f0`: 90.27%
- `.claude/lib/worktree-resolution/WorktreeResolution.psm1`: 142 covered on main vs 112 covered on the PR head

Local per-file values for `WorktreeResolution.psm1` (covered):
- P0-T5 (pre-existing file, `r2-coverage-baseline.2026-10-16T08-59.md`): 127
- P2-T2 HEAD repo-scope (`r2-cov-head.2026-10-16T09-49.md`): 127
- P2-T3 BASE repo-scope (`r2-cov-base.2026-10-16T10-05.md`): 142
- P3-T4 FIX verification: NOT-RUN (route BLOCKED; P3-T4 not applicable)
- P4-T3 final three-folder run (`r2-ps-test.2026-10-16T11-05.md`): 127

Post-change CI coverage: PENDING-CI (orchestrator, S9, AC-24)

New and changed production-line coverage: n/a: no production file changed (every changed file is under `tests/`, outside the `config/poshqc-coverage.json` roots)

COV-1-STATUS: blocked (REPRODUCED-U2-DOES-NOT-RESTORE)

This record does not evaluate AC-24; the AC-24 gate value comes only from the PR CI coverage file, read by the orchestrator at S9.
