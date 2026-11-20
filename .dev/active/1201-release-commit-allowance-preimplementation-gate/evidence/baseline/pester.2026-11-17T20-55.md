# Phase 0 baseline - Pester gate

Timestamp: 2026-11-17T20-38
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest run, 8 workers, integration and golden lanes excluded; launched from SCRATCH/issue-1201-suite-retry.sh; a first attempt exited 75 with TEST_EXECUTION_QUEUE_TIMEOUT because another worktree held the machine test-suite lock, recorded as a queue timeout, not a failure)
EXIT_CODE: 0
Output Summary:
- Run window 2026-11-17T20-38 to 2026-11-17T20-54 UTC; wall-clock 899.18 s; all 8 shards exited 0.
- JUnit (artifacts/pester/pester-junit.xml): tests 27494, passed 27476, failed 0, errors 0, skipped 18. Failing tests: none.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml): 44864/46711 = 96.05%.
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1: 169/175 = 96.57%.
- .codex/hooks/enforce-orchestration-preimplementation-gate.ps1: 180/180 = 100.00%.
- The two bundle gate copies under extensions/ are outside the coverage roots of config/poshqc-coverage.json and are not measured.
- Report copies saved as SCRATCH/issue-1201-p0-pester-junit.xml and SCRATCH/issue-1201-p0-pester-coverage.xml for the final comparison.
