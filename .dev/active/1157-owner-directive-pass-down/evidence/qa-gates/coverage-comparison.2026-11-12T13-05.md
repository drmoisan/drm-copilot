# Coverage comparison, post-merge confirmation (issue #1157, P6-T6)

Timestamp: 2026-11-12T13-05
Command: sh SCRATCH/issue-1157-summary.sh over artifacts/pester/powershell-coverage.xml written by the run recorded in pester-final.2026-11-12T13-05.md
EXIT_CODE: 0
Output Summary:
- Outcome: every value is numeric and meets its threshold.
- New files (threshold 90%; no pre-change run): .claude/hooks/enforce-owner-directive-pass-down.ps1 91.41% (149/163); .claude/hooks/owner-directive-pass-down-target.ps1 92.50% (111/120); .claude/hooks/validate-orchestrator-output-owner-pass-down.ps1 92.86% (117/126); .claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1 100.00% (110/110); .claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1 98.53% (67/68).
- Changed files (threshold 85%, no drop against pester-baseline.2026-11-10T04-02.md): .claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1 100.00% (209/209), baseline 100.00% (151/151); .claude/hooks/validate-orchestrator-output.ps1 99.32% (147/148), baseline 99.30% (141/142).
- Repo-wide line coverage: 95.79% (38176/39854), threshold 85%; baseline 95.80% (37492/39137). The 0.01-point difference comes from the denominator growing by the new files; no changed file dropped.
- Figures are identical to coverage-comparison.2026-11-11T06-55.md; the origin/main merge added no production PowerShell line to the coverage population.
- Coverage evidence location: spec AC-47 names evidence/coverage/, which is not a canonical evidence kind; this artifact is under evidence/qa-gates/ per the plan's EVIDENCE_LOCATION_OVERRIDE_REJECTED line.
