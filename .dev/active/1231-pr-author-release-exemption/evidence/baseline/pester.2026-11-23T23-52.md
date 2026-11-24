# Pester Gate Baseline (Phase 0, issue #1231)

Timestamp: 2026-11-23T23-52
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest run with coverage; integration and golden lanes excluded by the launcher); counts and coverage read by sh SCRATCH/issue-1231-read-pester.sh from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCParallelTest: workers=8; wall-clock=772.67s; exit code=0. All 8 shards exited 0.
- JUnit (artifacts/pester/pester-junit.xml): 29153 test cases; 29135 passed; 0 failed; 0 errors; 18 skipped.
- Failing tests: none.
- Repo-wide line coverage (artifacts/pester/powershell-coverage.xml, LINE counter): 47285 covered, 1542 missed, 96.84%.
- Per-file line coverage of the four edited hook files:
  - .claude/hooks/enforce-pr-author-skill.ps1: 52/57, 91.23%
  - .claude/hooks/enforce-pr-author-skill.cleanup.ps1: 63/64, 98.44%
  - .claude/hooks/enforce-model-routing-receipt.ps1: 106/110, 96.36%
  - .claude/hooks/enforce-orchestration-preimplementation-gate.ps1: 173/179, 96.65%
- A copy of the baseline coverage file is kept at SCRATCH/issue-1231-p0-coverage.xml for the P4-T3 comparison.
