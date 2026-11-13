# Preflight Fixes - Remediation Cycle 1 (Issue 1157)

Timestamp: 2026-11-13T14-27
Plan: docs/features/active/owner-directive-pass-down-1157/remediation-plan.2026-11-13T14-04.md
Preflight outcome: PREFLIGHT: REVISIONS REQUIRED (one substantive defect returned; the fixes below are trivial and were applied in place)

## Fixes

1. [P2-T3] | citation correction | The acceptance named "the two modified files named in spec AC-47"; spec AC-47 names only new files. Changed to "the five new files named in spec AC-47 and the two modified files named in P2-T4". The asserted set of seven files is unchanged.
2. [P1-T6] | literal clarification | The `Register-PassDownStopSeam` instruction now states that the mapped-path lookup keys the path after replacing `\` with `/`, as the current mock does. On Windows, `Join-Path` produces backslash separators for the `/synthetic-worktrees/` roots (observed in the SCRATCH probe below), so the lookup must keep that normalization. The asserted behavior is unchanged.

## Substantive defect returned (not fixed in place)

- [P1-T4] / [P1-T6] / `## Changed Behavior and Asserting Tests` | wrong file set (asserting tests outside the task file set) | `tests/scripts/claude-hooks/validate-orchestrator-output.TargetWorktree.Tests.ps1` records every `Get-CheckpointFileContent` path in its `Invoke-Case` mock, and rows H1, H3, H7, H8, and H11 assert the exact read list (`Should -Be @(<checkpoint path>)`). After P1-T6 the sibling's ledger read goes through the same mock, so each list gains the `owner-directives.jsonl` path and those rows fail. The plan says the suite's assertions are unchanged, and the P1-T4 acceptance requires 0 insertions and 1 deletion in that file.

Probe: Command: `sh SCRATCH/issue-1157-probe.sh` (a SCRATCH copy of the TargetWorktree suite on unmodified code, with the read-seam mock replaced by a mock that calls `Get-CheckpointFileContent -Path $Path` and returns `$null`). It is a focused debugging run, not a gate. Result: 12 passed, 5 failed (H1, H3, H7, H8, H11). Each failure is "Expected a collection ... with length 1, but got ... length 2", and the second element is the `owner-directives.jsonl` path.
