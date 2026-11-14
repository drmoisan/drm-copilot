# Coverage comparison (issue #1157, P6-T6)

Timestamp: 2026-11-11T06-55
Command: pwsh SCRATCH/issue-1157-summary.ps1 and SCRATCH/issue-1157-missed.ps1 over artifacts/pester/powershell-coverage.xml written by the run recorded in pester-final.2026-11-11T06-55.md
EXIT_CODE: 0
Output Summary:
- Outcome: every value is numeric and meets its threshold.
- New files (threshold 90%): .claude/hooks/enforce-owner-directive-pass-down.ps1 91.41% (149/163); .claude/hooks/owner-directive-pass-down-target.ps1 92.50% (111/120); .claude/hooks/validate-orchestrator-output-owner-pass-down.ps1 92.86% (117/126); .claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1 100.00% (110/110); .claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1 98.53% (67/68). New files have no pre-change run.
- Changed files (threshold 85%, no drop against pester-baseline.2026-11-10T04-02.md): .claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1 100.00% (209/209), baseline 100.00% (151/151); .claude/hooks/validate-orchestrator-output.ps1 99.32% (147/148), baseline 99.30% (141/142).
- Repo-wide line coverage: 95.79% (38176/39854), threshold 85%; baseline 95.80% (37492/39137). The 0.01-point difference comes from the denominator growing by the new files; no changed file dropped.
- Remaining uncovered lines: enforce-owner-directive-pass-down.ps1 14 lines (the entry-point tail that runs only as a process, and the coordinator branch's default resolver seam); owner-directive-pass-down-target.ps1 9 lines (the file-read line of the default reader and default git-listing and resolver seams); validate-orchestrator-output-owner-pass-down.ps1 9 lines (default reader and child-resolver seams); OrchestratorStateOwnerDirectiveDecision.psm1 1 line.
- Coverage evidence location: spec AC-47 names evidence/coverage/, which is not a canonical evidence kind; this artifact is under evidence/qa-gates/ per the plan's EVIDENCE_LOCATION_OVERRIDE_REJECTED line.
