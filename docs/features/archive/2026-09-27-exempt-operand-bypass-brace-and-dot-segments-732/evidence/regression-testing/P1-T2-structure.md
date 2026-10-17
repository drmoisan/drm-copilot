# P1-T2 Claude OperandBypass suite structure run (issue #732)

Timestamp: 2026-10-09T03-47
Task: [P1-T2]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/scoped-task.sh (R-SCOPED over 1 files)
EXIT_CODE: 1
ExpectedExitCode: 1

## Output

```text
FILES: 1
RUN_FILE: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1
PassedCount: 0
FailedCount: 2
FailedBlocksCount: 0
FailedContainersCount: 0
FAILED: enforce-orchestration-preimplementation-gate.ps1 exempt-operand bypass (issue #732).denies the issue 732 brace-expansion shape without an authorizing checkpoint
FAILED: enforce-orchestration-preimplementation-gate.ps1 exempt-operand bypass (issue #732).denies the issue 732 escaped dot-segment shape without an authorizing checkpoint
```

Output Summary: EXIT_CODE 1 as expected (fail-before). PassedCount 0, FailedCount 2, FailedBlocksCount 0, FailedContainersCount 0; both bypass rows are allowed by the unfixed Claude gate.
