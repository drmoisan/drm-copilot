# Coverage comparison, after the #1163 main sync (issue #1157, P6-T6 repeat)

Timestamp: 2026-11-13T17-36
Command: SCRATCH/issue-1157-sync2-summary.ps1 over artifacts/pester/powershell-coverage.xml written by the run recorded in pester-final.2026-11-13T17-36.md; baselines from evidence/baseline/pester-baseline.2026-11-10T04-02.md
EXIT_CODE: 0
Output Summary:
- Outcome: PASS; every value is numeric and meets its threshold (AC-47).
- New files (threshold 90%; no pre-change run): enforce-owner-directive-pass-down.ps1 91.41% (149/163); owner-directive-pass-down-target.ps1 92.50% (111/120); validate-orchestrator-output-owner-pass-down.ps1 94.62% (123/130); OrchestratorStateOwnerDirectiveSelection.psm1 100.00% (110/110); OrchestratorStateOwnerDirectiveDecision.psm1 98.53% (67/68).
- Modified files (threshold 85%, not below the Phase 0 baseline): OrchestratorStateOwnerDirectives.psm1 post 100.00% (209/209), baseline 100.00% (151/151); validate-orchestrator-output.ps1 post 99.32% (147/148), baseline 99.30% (141/142).
- Repo-wide (threshold 85%): post 95.82% (38431/40109), baseline 95.80% (37492/39137).
- Every per-file figure equals the pre-sync gate (coverage-comparison.2026-11-13T15-49.md); the merge changed none of these seven files.
