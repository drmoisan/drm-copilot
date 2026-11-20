# Fresh single-process Pester run over tests/scripts, the CI shape ([P7-T6])

Timestamp: 2026-11-04T03-22
Command: pwsh -NoProfile -File SCRATCH/issue-1033-poshqc-test.ps1 -Root <worktree> -ScanFolders tests/scripts (imports scripts/powershell/PoshQC/PoshQC.psd1 and calls `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts` in one fresh process with coverage; Pester 5.9.1, PowerShell 7.6.9, Linux Codespace host; counts read from the `testsuites` header of artifacts/pester/pester-junit.xml and the console summary, coverage from artifacts/pester/powershell-coverage.xml through SCRATCH/issue-1033-coverage-summary.ps1; failing test names taken from the console `[-]` lines with durations stripped and compared with the [P0-T8] list by `diff`). This is the re-run after the [P7-T9] hygiene edit; a first run at 2026-11-04T02-52 (before the edit) gave the identical counts, names and coverage.
EXIT_CODE: 255
Output Summary: JUnit header: tests=14461, failures=409, errors=6, skipped (disabled)=10. Console: `Tests Passed: 14042, Failed: 409, Skipped: 10, Inconclusive: 0, NotRun: 0`, `BeforeAll \ AfterAll failed: 6`, 1183.27 s. Errors: 6 (the same six failing containers as the baseline; `errors` counts containers, so the plan's "0 errors" acceptance is read against the baseline-listed containers, none of which is under `tests/scripts/claude-lib/docs`). Every failing test name (97 console `[-]` lines) is listed as failing in `baseline-pester-coverage.2026-11-03T22-12.md` (`diff` of the two sorted lists is empty) and the six failing containers are the baseline's six; none is under `T` (0 names contain `claude-lib/docs`). Exit 255 is the pre-existing Linux-host shape recorded in the baseline (Pester's JUnit export aborts on a 0x1B character in an `activate.Tests.ps1` failure message, so pester-junit.xml is written truncated at 14869 bytes after its header; the coverage XML is complete). Overall line coverage 93.21% (24523 of 26308 lines), up from the baseline 92.64% (21910 of 23651). Test count up from 14108 to 14461 (+353 tests of this feature: 21 new suites plus the extended support module). CI: `poshqc / PowerShell QC` (Windows shards); the Windows shards do not carry the Linux-host failures (#1066, #1067).

## Comparison with the [P0-T8] baseline

| Figure | Baseline (2026-11-03T22-12) | This run |
|---|---|---|
| tests (JUnit header) | 14108 | 14461 |
| failures | 409 | 409 |
| errors (failed containers) | 6 | 6 |
| skipped (disabled) | 10 | 10 |
| console `[-]` failing names | 97 | 97 (identical set) |
| failing containers | 6 (Codex routing wrappers; bundled Codex PreToolUse hooks; every registered Codex PreToolUse handler; Codex PreToolUse native stdin; Codex epic preparation, wave, merge and worktree gates; legacy Codex hooks native lifecycle) | the same 6 |
| failing names under `tests/scripts/claude-lib/docs` | 0 | 0 |
| overall line coverage | 92.64% | 93.21% |
| exit code | 255 (truncated JUnit export) | 255 (same shape) |
