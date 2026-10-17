# Remediation cycle 2 - remediation status record (P4-T11)

Timestamp: 2026-10-16T20-54
Command: none (record assembled from the cycle 2 evidence listed below)
EXIT_CODE: 0
Output Summary: R1 DOCUMENTED, coverage and disposition pending ORCH-R3 and ORCH-R4; R2 LOCAL-PASS, CI rows pending ORCH-R1 and ORCH-R2; CR-13 LOCAL-PASS; CR-14 ORCH-OWNED; R3 PENDING-CI. No acceptance criterion was checked off by the executor.

| Finding | Evidence | Status |
|---|---|---|
| R1 (PA-1, CR-1) | `evidence/regression-testing/c2-attribution-note-diff.2026-10-16T19-56.md`; `evidence/regression-testing/c2-attribution-note-codex-after.2026-10-16T20-00.md`; `evidence/regression-testing/codex-helper-coverage-diagnosis.2026-10-16T20-01.md` (the latest); Record 4 of `FEATURE/policy-followups.md` | DOCUMENTED (test-header notes, line-to-row diagnosis, operator follow-up), COVERAGE PENDING-ORCH (ORCH-R3 disposition), R1 DISPOSITION PENDING RE-AUDIT (ORCH-R4) |
| R2 (PA-2, CR-12) | `evidence/regression-testing/c2-url-selector-claude-before.2026-10-16T20-14.md`; `evidence/regression-testing/c2-url-selector-codex-before.2026-10-16T20-18.md`; `evidence/regression-testing/c2-url-selector-claude-after.2026-10-16T20-36.md`; `evidence/regression-testing/c2-url-selector-codex-after.2026-10-16T20-36.md`; `evidence/other/c2-mirror-sync-docs-only-bundles.2026-10-16T20-21.md`; `evidence/qa-gates/c2-final-shared-file-hashes.2026-10-16T20-53.md` | LOCAL-PASS, CI rows PENDING-ORCH (ORCH-R1 rows (m) to (q), ORCH-R2) |
| CR-13 (PA-N1) | P1-T1 token checks (`R1 provenance check` count 1; `byte-identical Claude twin` absent; row (g) name count 1; 200 lines); `evidence/qa-gates/c2-final-shared-file-hashes.2026-10-16T20-53.md` (`HELPER_UNCHANGED=true`) | LOCAL-PASS |
| CR-14 (PA-N2) | recorded by ORCH-R3 in its `CauseStatement:` | ORCH-OWNED (ORCH-R3) |
| R3 (PA-3, AC-28) | none in this cycle | PENDING-CI (main plan ORCH-3 and ORCH-7 at S9) |

## Next step

The orchestrator performs ORCH-R1 (dispatch `ci.yml` on the pushed head and record Windows per-suite results, rows (a) to (q)), ORCH-R2 (Linux per-suite results and the AC-1, AC-2, AC-5 to AC-15 check-offs when ORCH-R1 and ORCH-R2 pass), ORCH-R3 (coverage comparison with the Codex helper disposition and the CR-14 cause statement), and ORCH-R4 (re-audit and the AC-27 decision).

No acceptance criterion in `FEATURE/spec.md` was checked off by the executor.
