# P13-T3 PowerShell single-process and Linux hook-suite shapes

Timestamp: 2026-10-29T02-03
Task: [P13-T3] Repeat the PowerShell gates when PowerShell changed after P11-T4.
Command: Invoke-PoshQCTest -Root <worktree> in one process over the full registered population; Invoke-Pester over tests/scripts/claude-hooks and tests/scripts/codex-hooks with CodeCoverage disabled, Run.Exit true and JUnit output (the `poshqc / PowerShell hook suites (Linux)` job shape)
EXIT_CODE: 0 (single process), 0 (hook suites)
Output Summary: Single process: 12202 tests, 12192 passed, 0 failed, 10 skipped, 93.14% lines, with no module-scope import or leaked-state failure. Hook suites (from `p13-powershell-junit-linux-hooks.2026-10-29T02-02.xml`): 7155 tests over 257 test files, 0 failures, 0 errors, 0 skipped. The hook-suite run executed on Windows. The case-sensitive file-system behavior of the ubuntu-latest job cannot be reproduced locally and is proven only by the CI run on the PR head, which remains a delivery gate.
Result: PASS
