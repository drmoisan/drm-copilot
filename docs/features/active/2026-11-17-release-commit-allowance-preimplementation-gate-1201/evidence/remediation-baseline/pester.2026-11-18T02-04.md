# Remediation Phase 0 baseline - Pester gate (cycle 1)

Timestamp: 2026-11-18T01-51
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest run, 8 workers, integration and golden lanes excluded; launched from SCRATCH/issue-1201-suite.sh)
EXIT_CODE: 0
Output Summary:
- Run window 2026-11-18T01-51 to 2026-11-18T02-03 UTC; wall-clock 732.5 s; all shards exited 0.
- JUnit (artifacts/pester/pester-junit.xml): tests 28105, passed 28087, failed 0, errors 0, skipped 18. Failing tests: none.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 45276/47121 = 96.08%.
- .claude/hooks/hook-release-allowance-context.ps1: 171/171 = 100.00%.
- .codex/hooks/hook-release-allowance-context.ps1: 171/171 = 100.00%.
- .claude/hooks/enforce-orchestration-preimplementation-gate-release.ps1: 32/32 = 100.00%.
- .codex/hooks/enforce-orchestration-preimplementation-gate-release.ps1: 32/32 = 100.00%.
- Report copies saved as SCRATCH/issue-1201-rc1-p0-junit.xml and SCRATCH/issue-1201-rc1-p0-coverage.xml for the final comparison.
- The probe row hook-release-allowance-context.ps1 (Claude).baseline mock interception probe passes here because the parallel gate does not place a run-module-replacing suite before it in the same process (see the P1-T1 diagnosis).
