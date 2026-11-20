# P11-T4 PowerShell single-process and Linux hook-suite shapes

Timestamp: 2026-10-23T03-27
Command: Invoke-PoshQCTest -Root <worktree> (one process over the full registered population, the shape the aggregator's discovery pass and the shard completeness check compare against); Invoke-Pester over tests/scripts/claude-hooks and tests/scripts/codex-hooks with CodeCoverage disabled, Run.Exit true and JUnit output (the `poshqc / PowerShell hook suites (Linux)` job shape)
EXIT_CODE: 0 (single process), 0 (hook suites)
Output Summary: Single process: 12099 tests, 12089 passed, 0 failed, 10 skipped, 92.66% lines over 240 files, with no module-scope import or leaked-state failure remaining (the two cross-suite defects the first pass exposed are repaired in `powershell-tests.2026-10-23T03-27.md`). Hook suites: 7089 tests, 7089 passed, 0 failed, 0 skipped (`powershell-junit-linux-hooks.2026-10-23T03-27.xml`). The hook-suite run executed on Windows; the case-sensitive file-system behavior of the ubuntu-latest job is not reproducible locally and is proven only by the CI run on the PR head, which remains a delivery gate.
