# Coverage comparison (issue #1157, cycle 1, P2-T4)

Timestamp: 2026-11-13T15-49
Command: SCRATCH/issue-1157-pester-summary.ps1 over artifacts/pester/powershell-coverage.xml written by the run recorded in pester-final.2026-11-13T15-48.md; baselines from evidence/baseline/pester-baseline.2026-11-10T04-02.md and, for the new files (no pre-change run), the cycle-entry figures in evidence/remediation-baseline/baseline-reference.2026-11-13T14-43.md
EXIT_CODE: 0
Output Summary:
- Outcome: PASS; every comparison holds.
- New files (threshold 90%; no pre-change run; cycle-entry figure for reference): enforce-owner-directive-pass-down.ps1 post 91.41% (149/163), cycle entry 91.41%; owner-directive-pass-down-target.ps1 post 92.50% (111/120), cycle entry 92.50%; validate-orchestrator-output-owner-pass-down.ps1 post 94.62% (123/130), cycle entry 92.86%; OrchestratorStateOwnerDirectiveSelection.psm1 post 100.00% (110/110), cycle entry 100.00%; OrchestratorStateOwnerDirectiveDecision.psm1 post 98.53% (67/68), cycle entry 98.53%.
- Modified files (threshold 85%, not below the Phase 0 baseline): OrchestratorStateOwnerDirectives.psm1 post 100.00% (209/209), baseline 100.00% (151/151); validate-orchestrator-output.ps1 post 99.32% (147/148), baseline 99.30% (141/142).
- Repo-wide (threshold 85%): post 95.80% (38182/39858), baseline 95.80% (37492/39137).
- New behavior of this cycle is tested: the case-insensitive ledger comparison by the two P1-T1 rows of enforce-owner-directive-pass-down.Tests.ps1; Get-OrchestratorOutputOwnerPassDownSourceText by the six rows of Describe 'source read seam (F1)' and 'treats a parent ledger read that returns the checkpoint text as absent'; its routing through the main hook by H14 of validate-orchestrator-output.TargetWorktree.Tests.ps1. All passed in the gate run.
