# Cycle 3 Pass 6 Exception Raw-Branch Reconciliation

Timestamp: 2026-08-16T21-00

Command: `Get-FileHash -Algorithm SHA256 <P1-T1..P1-T5 evidence>; Select-String GENUINE_BRANCH_COLLECTOR_ESTABLISHED,covered,missed,denominator,synthetic,measured`

EXIT_CODE: 0

Output Summary: All five completed P1-T1 through P1-T5 evidence artifacts remain present and hash-stable. They consistently establish zero genuine source-attributable branch outcomes and prohibit proxy, synthetic, percentage, or measured-pass claims.

## Evidence Hashes

| Task | Evidence path | SHA-256 |
|---|---|---|
| P1-T1 | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/cycle3-pass6-branch-capability-inventory.2026-08-15T10-36.md` | `D48FF4359F85751ED6F3367A9F179EAFDD419443B709AD1D4CE795590864D529` |
| P1-T2 | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/regression-testing/cycle3-pass6-branch-capability-probe.2026-08-15T10-36.md` | `171C1006277C925B280A6AAC657E5684C2526B797AFEA323D1772E9ED14D2D45` |
| P1-T3 | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/cycle3-pass6-branch-capability-decision.2026-08-15T10-36.md` | `864DE2814858B2DF63D85032999B27AA9884D39F485C487995A336050A3B4C7F` |
| P1-T4 | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/cycle3-pass6-fail-closed-decision.2026-08-15T10-36.md` | `60EEFB00F9EAEDCC3863787066A32243EA4128338114AA33A76F2C29386D60D8` |
| P1-T5 | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/cycle3-pass6-executor-to-orchestrator-handback.2026-08-15T10-36.md` | `A5D03071312D75107C4350554750E745F6EBB769A1F430326C9C6A32FFB67281` |

## Reconciled Raw Finding

- `GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO`
- Genuine source-attributable covered branch outcomes: 0
- Genuine source-attributable missed branch outcomes: 0
- Genuine source-attributable branch denominator: 0
- `RAW_BRANCH_RESULT: 0/0 UNAVAILABLE`
- Synthetic or proxy-derived branch percentage introduced: `false`
- Measured 75% PowerShell branch PASS introduced: `false`

The one-time exception does not modify these measurements. It changes only the compliance disposition recorded in later exception evidence.
