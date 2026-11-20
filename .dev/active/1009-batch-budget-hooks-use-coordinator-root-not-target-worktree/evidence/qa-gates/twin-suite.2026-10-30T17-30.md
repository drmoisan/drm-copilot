# Codex Twin Suite (issue #1009)

Timestamp: 2026-10-30T17-30
Command: sh SCRATCH/issue-1009-pester.sh issue-1009-twin-suite.txt issue-1009-cov-hooks.txt (Invoke-PoshQCTest over tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1 with coverage; counts from artifacts/pester/pester-junit.xml, coverage from artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary:
- JUnit: total=83 passed=83 failed=0 skipped=0
- Shared behavior rows passed against the dot-sourced twin: 74 (helper 24, porcelain 7, resolver 18, identity 25). The [P2-T8] module run passed the same 74 shared rows, so the counts are equal.
- Parity rows passed: 9 (implementation guard 1, function-name set 1, byte-identical function text 6, no statement outside function definitions 1).
- Line coverage `.codex/hooks/hook-target-worktree.ps1`: 148/149 = 99.33% (threshold 85%); the uncovered line is the host-bound default WorktreeListInvoker body.
- Guard-row note: under the plan-mandated `Invoke-PoshQCTest` host, a dot-sourced function reports `Module = PoshQC`, so a literal "no module" assertion fails on the runner itself. The guard asserts that the answering command's module is not `HookTargetWorktree` and that its `ScriptBlock.File` leaf is `hook-target-worktree.ps1`, which proves the twin answers the rows.
- CI: this suite runs in `poshqc / PowerShell hook suites (Linux)` and `poshqc / PowerShell QC`; the Linux result is pending CI (see [P9-T15]).
