# Gate wiring order (WLOG)

Timestamp: 2026-10-08T23-56
Command: SW procedure (LH-2) and per-phase A2 runs
EXIT_CODE: 0
Output Summary:
  Latest entry: P6-T21 SET-PRA TotalCount=262 PassedCount=262 FailedCount=0.

## Staged writes

| Seq | Task | File written | SW-2 STAGE-CHECK | SW-4 hash equal | Timestamp | Corrective re-Write reason |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | P1-T4/P1-T5 | .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 | STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0 (SW-2b: LOAD-CHECK Module=WorktreeRunResolution Imported=True ExportCount=7) | True (51AE914FB560C445E36D0330E7A599028A26DE32C844EE4D5D7325FCD5AA70B4) | 2026-10-08T23-56 | n/a |
| 2 | P2-T4/P2-T5 | .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0 | True (486DE570E450E96ED55A5A5B5E44A907F58121674CF9F62243AF867B3EC697C0) | 2026-10-08T23-58 | n/a |
| 3 | P3-T4/P3-T6 | .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1 | STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0 (first SW-2 printed DiagnosticCount=1, PSUseSingularNouns on the plan-named Get-EpicWorktreeGateDenyDiagnostics; the staged copy was corrected with a justified suppression attribute before SW-3) | True (5929B17580B25577E9886AFCA4382018AF66513C2679BC1EA15F6BC224146D4D) | 2026-10-09T00-05 | n/a |
| 4 | P3-T5/P3-T6 | .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0 | True (42CE72D70AE3A8FFC60B436DE0A58AEFFCEB238DAC948CE428E20D1485E19F74) | 2026-10-09T00-05 | n/a |
| 5 | P4-T4/P4-T5 | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0 (SW-2b: LOAD-CHECK Module=WorktreeItemResolution Imported=True ExportCount=10) | True (BA2B4C4DFC4AE92532312308F471FCB795DE6BD06579D359A64602ABC84F7194) | 2026-10-09T00-12 | n/a |
| 6 | P5-T4/P5-T6 | .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0 | True (2E079865E1BE2BC8014FFE33127CDDA2DDCAE39A78B7D12446369240F64533DE) | 2026-10-09T00-19 | n/a |
| 7 | P5-T5/P5-T6 | .claude/hooks/enforce-epic-merge-gate.ps1 | STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0 | True (1B4488F7E7B835B15DC4666D3D9D09BDD4E3876E5DB14D27453A2B565B7762DD) | 2026-10-09T00-19 | n/a |
| 8 | P5-T12 (corrective) | .claude/lib/worktree-resolution/WorktreeItemResolution.psm1 | STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0 (SW-2b into SCRATCH/stage-lib-p4-2: LOAD-CHECK Module=WorktreeItemResolution Imported=True ExportCount=10) | True (74E7A2CDA251B1BEDFC75560D9D7C049EC173047E7B6B130F79D6C2CCF5C53DB) | 2026-10-09T00-23 | Corrective re-Write: P5-T12 rows "denies an unresolvable item target with the no-target code" and "observes module-scoped WorktreeItemResolution mocks" failed with "The property 'Name' cannot be found on this object" because Test-WorktreeItemCheckpointRecordsPr read PSObject.Properties.Name on an empty JSON object under strict mode; property names are now collected per property. |
| 9 | P6-T5/P6-T8 | .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 | STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0 | True (F3AC50FA88A34413364446DF86AD4CDCE054033B18782257B1160ADDB7F19CE5) | 2026-10-09T00-33 | n/a |
| 10 | P6-T6/P6-T8 | .claude/hooks/enforce-pr-author-skill-helpers.ps1 | STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0 | True (A78CE90D66F8791C5E726FE3998CB1535ADFA62FD4155CF57415060C5BE5014C) | 2026-10-09T00-33 | n/a |
| 11 | P6-T7/P6-T8 | .claude/hooks/enforce-pr-author-skill.ps1 | STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0 | True (B52B894CC650A7A81319A82E1EE40F352F0D9BFD923464A1B98F70D2E345ADD0) | 2026-10-09T00-33 | n/a |

## Suite results

| Task | Suite set | TotalCount= | PassedCount= | FailedCount= |
| --- | --- | --- | --- | --- |
| P1-T10 | SET-LIB | 255 | 255 | 0 |
| P2-T10 | SET-REM | 224 | 224 | 0 |
| P3-T12 | SET-REM (with T-EREM-DX) | 232 | 232 | 0 |
| P4-T10 | SET-LIB (with T-WIR-PR) | 266 | 266 | 0 |
| P5 (WIR corrective re-check) | SET-LIB | 266 | 266 | 0 |
| P5-T14 | SET-MRG (with T-MRG-IR), run 1 | 160 | 160 | 0 |
| P6-T21 | SET-PRA (with T-PRA-IAR), run 1 | 262 | 262 | 0 |
