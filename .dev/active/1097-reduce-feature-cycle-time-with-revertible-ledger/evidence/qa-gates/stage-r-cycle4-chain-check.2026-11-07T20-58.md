# Stage R Cycle 4 Chain Check over the Live Ledger

Timestamp: 2026-11-07T20-58
Command: sh-launched PowerShell 7 script SCRATCH/r3/issue-1097-r3-probe.ps1 from the worktree root: Read-ProcessReductionChainInput over the live ledger, then Invoke-ProcessReductionChain over the unchanged live text, over the live text with a line appended to a created file, over the live text with that created file set to null, and Invoke-ProcessReductionChain -StopBefore for each patch entry
EXIT_CODE: 0
Output Summary:
  Live ledger, unchanged: IsValid True, 0 errors (required: 0 errors, as in the stage R baseline).
  Created file tests/scripts/codex-hooks/feature-review-coverage-narrowing-parity.Tests.ps1 (created by entry 0001), line appended: IsValid False, 1 error: "0001-parallel-only-test-gates.md: <path>: the file the entry created differs from its create hunk."
  The same file set to null: IsValid False, 1 error: "0001-parallel-only-test-gates.md: <path>: the file the entry created is absent at this step."
  Sub-chains with -StopBefore 0001-parallel-only-test-gates.md and -StopBefore 0006-test-suite-baseline-restored.md: IsValid True, 0 errors each.
  Before the change both probe edits gave IsValid True (reviewer probes recorded in the remediation inputs); the new check makes the chain fail on an edited or deleted created file and pass on the unchanged one.
