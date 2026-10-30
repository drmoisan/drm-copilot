# P14-T8 PowerShell single-process and Linux hook-suite shapes

Timestamp: 2026-10-29T12-14
Task: [P14-T8] Re-run the PowerShell gates and CI-shaped execution on the rebased tree.
Command: Invoke-PoshQCTest -Root <worktree> in one process over the full registered population; Invoke-Pester over tests/scripts/claude-hooks and tests/scripts/codex-hooks with CodeCoverage disabled, Run.Exit true and JUnit output (the `poshqc / PowerShell hook suites (Linux)` job shape)
EXIT_CODE: 0 (single process, pass 2), 0 (hook suites)
Output Summary: Single process (pass 2): 12615 tests over 452 files, 12605 passed, 0 failed, 10 skipped, 93.28% lines, with no module-scope import or leaked-state failure. Hook suites (from `p14-powershell-junit-linux-hooks.2026-10-29T12-14.xml`): 7358 tests over 260 test files, 0 failures, 0 errors, 0 skipped; the population includes `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`, the file whose rebase conflict was resolved. The hook-suite run executed on Windows; the case-sensitive file-system behavior of the ubuntu-latest job is proven only by the CI run on the PR head, which remains a delivery gate. Pass 1 single-process failure and its repair are recorded in `p14-powershell-tests.2026-10-29T12-14.md`.
Result: PASS
