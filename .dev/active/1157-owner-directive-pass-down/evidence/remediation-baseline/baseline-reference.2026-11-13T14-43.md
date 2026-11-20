# Remediation Baseline Reference (issue #1157, cycle 1, P0-T2)

Timestamp: 2026-11-13T14-43
Command: git grep -l Read-OrchestratorOutputOwnerPassDownText -- .claude extensions tests (in the item worktree), plus reads of the recorded baseline artifacts named below; no test run
EXIT_CODE: 0
Output Summary:
- Pester Phase 0 baseline (evidence/baseline/pester-baseline.2026-11-10T04-02.md): repo-wide line coverage 95.80% (37492/39137); .claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1 100.00% (151/151); .claude/hooks/validate-orchestrator-output.ps1 99.30% (141/142).
- New-file figures (evidence/qa-gates/coverage-comparison.2026-11-12T13-05.md, no pre-change run, threshold 90%): enforce-owner-directive-pass-down.ps1 91.41% (149/163); owner-directive-pass-down-target.ps1 92.50% (111/120); validate-orchestrator-output-owner-pass-down.ps1 92.86% (117/126); OrchestratorStateOwnerDirectiveSelection.psm1 100.00% (110/110); OrchestratorStateOwnerDirectiveDecision.psm1 98.53% (67/68).
- pytest Phase 0 baseline (evidence/baseline/pytest-baseline.2026-11-10T04-08.md): 16590 passed, 0 failed, 6 skipped.
- Merge-base CI pytest TOTAL (from remediation-inputs.2026-11-13T14-04.md, CI run 43170341553): 35355 statements, 1035 missed; 13424 branches, 554 partial.
- Files naming Read-OrchestratorOutputOwnerPassDownText: 21 (the hook and its bundle copy, and 19 suites under tests/scripts/claude-hooks/), matching the plan's expected count.
