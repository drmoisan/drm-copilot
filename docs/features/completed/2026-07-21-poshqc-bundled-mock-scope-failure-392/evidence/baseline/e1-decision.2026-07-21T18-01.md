# E1 Contingency Decision (Issue #392)

Timestamp: 2026-07-21T18-01

E1a artifact: `docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/evidence/baseline/e1a-global-hosted-preimport.2026-07-21T18-01.md`

E1a outcome: Passed=95, Failed=0, Skipped=7 (exit 0). A global-hosted `Invoke-Pester` run passed even with the colliding bundled `PoshQC` module pre-imported. E1b (module-hosted) failed with 31. This isolates module-session-state hosting as the necessary and sufficient condition; the pre-import collision alone does not reproduce the defect under global hosting.

CONTINGENCY: NOT-REQUIRED

CONTINGENCY-APPLIED: no

P1-T3 branch executed: NOT-REQUIRED branch. No code edit was made to the default `$InvokePester` (no `Get-Module -Name PoshQC | Remove-Module -Force` pre-clear added). The seam fix from P1-T1 (`-Global` import) and P1-T2 (global trampoline) is the complete fix, consistent with the E1a-passed verdict.
