# Pass-After: Operand-Option Rows and F1 Parity Rows (Issue #1010, remediation cycle 1, P3-T1)

Timestamp: 2026-10-30T22-22
Command: sh SCRATCH/issue-1010-pt.sh issue-1010-r1-s123.txt -NoCoverage (Invoke-PoshQCTest in one process over suites 1, 2, and 3 after the P2-T1 and P2-T2 production changes; counts read from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: 93 tests, 93 passed, 0 failed. Suite 1: 42 passed, 0 failed. Suite 2: 46 passed, 0 failed. Suite 3: 5 passed, 0 failed.

| Suite | Tests | Passed | Failed |
|---|---|---|---|
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1` | 42 | 42 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1` | 46 | 46 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeHelperParity.Tests.ps1` | 5 | 5 | 0 |

## Rows Named by the Plan (all passing)

- Suite 1: `T15 admits git commit -m msg <abs file> against a ready item checkpoint, reading the item checkpoint`; `B11 collects an absolute pathspec after git add --pathspec-from-file <value>`; `B14 collects an absolute pathspec after a standalone flag and after --`; B10 for each of `-m msg`, `--message msg`, `--message=msg`, `-mmsg`, `-F msg.txt`, `--file msg.txt`, `--author Sample`, `--author=Sample`, `--date now`, `-C HEAD`, `-c HEAD`; B12 and B13.
- Suite 2: `C18 admits git commit -m msg <abs file> against a ready item checkpoint, reading the item checkpoint`; B11; B14; the same eleven B10 cases; B12 and B13.
- Suite 3: `F1 the Get-OrchestrationGateWorktreeList definition is identical on the Claude and Codex surfaces`, `F1 the Invoke-OrchestrationGateWorktreeList definition is identical on the Claude and Codex surfaces`, `F1 the Get-OrchestrationGateCommandOperandPath definition is identical on the Claude and Codex surfaces`, and both negative rows.

B12, which failed before the change because the existing collector reads `-F` as the standalone flag `-f`, passes after it: the walk reads `-F` case-sensitively as a value option and its value is excluded from the returned operands.
