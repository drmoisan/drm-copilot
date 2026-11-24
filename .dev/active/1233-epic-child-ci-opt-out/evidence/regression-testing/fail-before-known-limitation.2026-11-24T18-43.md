# Fail-before: whitespace-set known limitation rows (RC2 P1-T5)

Timestamp: 2026-11-24T18-43
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/child-ci-opt-out-skill-contract.Tests.ps1 (through SCRATCH/issue-1233-gate-pester.sh and SCRATCH/issue-1233-retry.sh; shard JUnit copied to SCRATCH/rc2-fb-limit-parallel/shard-1/pester-junit.xml)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- State: the X-LIMIT rows are added to tests/scripts/claude-runtime/child-ci-opt-out-skill-contract.Tests.ps1 (and to $script:CaseCount); the rule source and the generated rule are not yet edited.
- First attempt, no queue timeout. Invoke-PoshQCParallelTest: workers=1; wall-clock=99.85s; exit code=1. No merged JUnit is written for a failed run; the shard-1 JUnit records 67 testcases and 2 failures.
- Failing rows (exactly two, by name):
  - CCO X-LIMIT [claude] states the whitespace-set known limitation in its own section: "missing: Known limitation: | str.strip | IsNullOrWhiteSpace | U+0085 | U+001C | U+FEFF".
  - CCO X-LIMIT [claude-bundle] states the whitespace-set known limitation in its own section: the same six tokens missing.
- Every other row, including CCO-CASE-LABELS-DISTINCT, passes.
