# P16-T3 PowerShell single-process and Linux hook-suite shapes

Timestamp: 2026-10-30T01-29
Task: [P16-T3] Run the PowerShell gates and regenerate the canonical coverage file from the full run.
Command: Invoke-PoshQCTest -Root <worktree> in one process over the full registered population; Invoke-Pester over tests/scripts/claude-hooks and tests/scripts/codex-hooks with CodeCoverage disabled, Run.Exit true and JUnit output (the `poshqc / PowerShell hook suites (Linux)` job shape)
EXIT_CODE: 0 (single process), 0 (hook suites)
Output Summary: Single process (2026-10-30T00-51 to 01-06 UTC): 12744 tests over 455 files, 12734 passed, 0 failed, 10 skipped, 93.34% lines, with no module-scope import or leaked-state failure; this is the fresh single-process run the P16-T5 isolation record cites. Hook suites (2026-10-30T01-23 to 01-29 UTC, from `p16-powershell-junit-linux-hooks.2026-10-30T01-29.xml`): 7394 tests over 260 test files, 0 failures, 0 errors, 0 skipped; the population includes `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` and every Phase 15 hook suite under the two folders. P14-T8 recorded 7358 hook-suite tests. The hook-suite run executed on Windows; the case-sensitive file-system behavior of the ubuntu-latest job is proven only by the CI run on the PR head, which remains a delivery gate.
Result: PASS
