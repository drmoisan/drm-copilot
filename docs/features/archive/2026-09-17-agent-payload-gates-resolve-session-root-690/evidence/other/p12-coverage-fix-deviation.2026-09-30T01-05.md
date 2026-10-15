# Phase 12 Coverage Fix and Restart (Deviation Record)

Timestamp: 2026-09-30T01-05
Command: sh SCRATCH/cov-final.sh (A3 over CG-LIB, CG-PRE, CG-WAVE, CG-COHORT, CG-MERGE, CG-EREM, CG-PREM, CG-DRIFT)
EXIT_CODE: 0
Output Summary:
- First final coverage pass: five files below their P0 BASEPCT: ESR 89.29 (base 89.42), PRES 94.03 (base 100), WAVE 98.02 (base 98.9), COH 97.37 (base 98.48), DRIFT 98.25 (base 99.04). All suites passed.
- Causes: (1) the import-guard catch assignment added to WAVE (line 49), COH (63), DRIFT (78), and PRES (49) was never executed, because the import-failure rows set the failure variable directly; (2) Get-CheckpointContent, relocated from PRE to PRES in P3, had no row executing its body (it was already uncovered in PRE at BASE_SHA); (3) the ESR null-candidate branch-mismatch return (line 348), split out of the combined condition by B11, had no row.
- Fix, per the Phase 12 rule "fix the cause ... and restart from P12-T1":
  - Rows G2 W7, G3 C5, G7 D6, and G1B O7 now reload their hook with Import-Module mocked (throwing for WorktreeRunResolution.psm1, a no-op otherwise), so the real import guard records the failure. Assertions are unchanged; row counts are unchanged.
  - Two rows added to enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 for Get-CheckpointContent (absent, present).
  - One row added to EpicScopeResolution.Tests.ps1 for a detached HEAD on a head-matched leg.
- Consequence for fixed counts: tests/scripts/claude-hooks grows by 80 (plan: 78) and tests/scripts/claude-lib by 73 (plan: 72). P12-T13 and P12-T14 record the plan totals plus these three rows.
- Post-fix coverage: ESR 90.18, PRES 100, WAVE 99.01, COH 98.68, DRIFT 99.12; all other files unchanged and at or above their thresholds.
