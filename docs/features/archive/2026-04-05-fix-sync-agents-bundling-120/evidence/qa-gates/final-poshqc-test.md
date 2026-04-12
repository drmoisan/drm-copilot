# Final PoshQC Test Evidence

- Timestamp: 2026-04-05T10:43:00Z
- Command: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
- EXIT_CODE: 0
- Output Summary: Tests Passed: 238, Failed: 0, Skipped: 7, Inconclusive: 0, NotRun: 0. Coverage: 47.57% (up from 46.72% baseline). All 13 test files passed including sync-agents-from-instructions.Tests.ps1 with 6 new tests (regression, optional preamble x2, compaction x4).
