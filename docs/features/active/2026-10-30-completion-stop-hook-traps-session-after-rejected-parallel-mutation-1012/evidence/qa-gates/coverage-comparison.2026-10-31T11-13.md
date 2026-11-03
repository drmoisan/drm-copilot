# Coverage Comparison (issue #1012)

Timestamp: 2026-10-31T11-13
Command: sh SCRATCH/issue-1012-ps.sh SCRATCH/issue-1012-summary.ps1 -CoverageFileList ".claude/hooks/validate-orchestrator-output-rejection.ps1;.claude/hooks/validate-orchestrator-output.ps1" (reads the LINE counters and per-line `ci` values of artifacts/pester/powershell-coverage.xml written by the P5-T3 run)
EXIT_CODE: 0
Output Summary:
- `.claude/hooks/validate-orchestrator-output-rejection.ps1`: 100.00% line coverage (43 of 43); new file, no baseline.
- `.claude/hooks/validate-orchestrator-output.ps1`: 99.19% line coverage (122 of 123), baseline 99.16% (118 of 119), delta +0.03 points.
- Changed lines of `validate-orchestrator-output.ps1` are all covered: the only missed line is 133 of the post-change file, the default `FileExistsCheck` scriptblock body of `Test-HumanInteractionShape`, which is the same unchanged line that was missed at baseline (line 132 before the one-line insertion of the guarded dot-source).
- Both files are at or above 85%. PowerShell has no branch-coverage gate. Result: PASS.

| File | Baseline (P0-T4) | Post-change (P5-T3) | Delta |
| --- | --- | --- | --- |
| `.claude/hooks/validate-orchestrator-output-rejection.ps1` | N/A (new file) | 100.00% (43/43) | N/A |
| `.claude/hooks/validate-orchestrator-output.ps1` | 99.16% (118/119) | 99.19% (122/123) | +0.03 |

Changed lines of `Get-OrchestratorOutputBlockDecision` and the dependency-load block (post-change file):

| Change | Covered |
| --- | --- |
| guarded dot-source of `validate-orchestrator-output-rejection.ps1` | yes |
| `Get-OrchestratorOutputRejectionDecision` call in the unresolved branch | yes |
| `return $rejectionDecision` on a non-null decision (allow path) | yes |
| unchanged `Repairable` computation | yes |
| block message with the `Get-ParallelMutationRejectionHint` append | yes |
