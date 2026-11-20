# F1 Parity Detection Run (Issue #1010, remediation cycle 1, P1-T2)

Timestamp: 2026-10-30T22-17
Command: sh SCRATCH/issue-1010-pt.sh issue-1010-r1-s3.txt -NoCoverage (Invoke-PoshQCTest over tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeHelperParity.Tests.ps1; counts read from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: 5 tests, 5 passed, 0 failed. The three parity rows pass on the unmodified tree, and both negative rows pass, which shows that the parity assertion throws on a one-character difference and on a missing definition.

| Row | Passed | Failed |
|---|---|---|
| F1 the Get-OrchestrationGateWorktreeList definition is identical on the Claude and Codex surfaces | 1 | 0 |
| F1 the Invoke-OrchestrationGateWorktreeList definition is identical on the Claude and Codex surfaces | 1 | 0 |
| F1 the Get-OrchestrationGateCommandOperandPath definition is identical on the Claude and Codex surfaces | 1 | 0 |
| F1 a definition that differs by one character fails the parity assertion | 1 | 0 |
| F1 a definition missing from one surface fails the parity assertion | 1 | 0 |
