# Mirror Contract Tests (remediation cycle 1, P1-T4)

Timestamp: 2026-11-16T02-48
Plan: remediation-plan.2026-11-16T02-21.md
Command: (1) env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh with the python suite and tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py (SCRATCH/issue-1195-c1-retry.sh, which re-runs only on a launcher exit 75); (2) sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 (SCRATCH/issue-1195-gate.sh); Pester totals from artifacts/pester/parallel/shard-1 and shard-2 JUnit files
EXIT_CODE: 0
Output Summary:
- (1) pytest push-down resource contracts: attempt 1 at 2026-11-16T02-48 exited 75 (TEST_EXECUTION_QUEUE_TIMEOUT, lock held by another worktree's suite), recorded as a queue timeout, not a failure; an earlier attempt at 02-43 was also exit 75. Attempt 2 exit 0: 23 passed, 0 failed (24 xdist workers).
- (2) Pester classify parity test and legacy Codex hook contracts: launcher exit 0, 2 workers, wall-clock 121.1 s; 53 tests, 53 passed, 0 failed, 0 skipped.
- The four classify copies are byte-identical (SHA256 d2ff656bb2999e3bb9efd283c0bc989c88f493f57f509bc1aeb02c7de10927cb) and each bundle copy equals its source.
