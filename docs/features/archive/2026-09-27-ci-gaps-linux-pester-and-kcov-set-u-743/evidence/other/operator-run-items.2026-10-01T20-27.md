# Operator-Run Items (P5-T3)

Timestamp: 2026-10-01T20-27

Operator command (not run by the executor, per the 2026-10-01 operator decision, Option A):

`pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml`

- Run from: the repository root of the item worktree.
- Expected result: exit 0 and no findings.
- Destination for the record (command, exit code, output, new timestamp): `<FEATURE>/evidence/qa-gates/`.
- Supplementary direct-actionlint evidence (binary on PATH, not the wrapper): `evidence/qa-gates/qc-actionlint-direct.2026-10-01T19-58.md` (P3-T8, exit 0, no output) and `evidence/qa-gates/qc-actionlint.2026-10-01T17-23.md`.
- AC-5 and AC-21 remain unchecked in `spec.md` until the operator run is recorded. This plan changed no workflow file, so one operator run satisfies both AC-5 and the AC-21 actionlint step.
