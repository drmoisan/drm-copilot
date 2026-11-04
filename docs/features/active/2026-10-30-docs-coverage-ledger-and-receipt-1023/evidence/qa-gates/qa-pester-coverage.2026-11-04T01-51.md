# Final QA: Pester and Coverage ([P7-T3])

Timestamp: 2026-11-04T01-51
Command: sh SCRATCH/issue-1023-pester-run.sh (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> with no -ScanFolders, so the scan set is resolved from config/poshqc-scan.json: scripts, tests/powershell, tests/scripts; the CI shape, one process, coverage enabled; the fresh single-process run over tests/scripts). Counts read from the root testsuites attributes of artifacts/pester/pester-junit.xml and the Pester console summary; failing suite and test names from the console log; per-file line coverage from the LINE counters of artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1023-pester-summary.ps1
EXIT_CODE: 255
Output Summary: tests=14333, passed=13914, failures=409, errors=6, skipped=10 (disabled=10), 1522.71 s. failures and errors are not 0; every failure is one the baseline [P0-T6] recorded as pre-existing: the set of 25 failing suites and the set of 97 failing test names are identical to the baseline sets (diff empty), all outside tests/scripts/claude-lib/docs and all Linux-host-only. The 225 new tests (14333 - 14108) are the 1023 suites plus the four Docs.Manifest.Tests.ps1 cases now passing; no 1023 suite and no docs suite fails. Overall line coverage 92.99% (23226 covered, 1751 missed, 279 files; baseline 92.66%). Per-file line coverage: DocsLedger.psm1 98.82, DocsLedgerRules.psm1 98.94, DocsEvidencePins.psm1 96.84, DocsStaleness.psm1 100, DocsParity.psm1 98.92, DocsReceipt.psm1 100, DocsLedgerMutation.psm1 98.33, DocsValidation.psm1 98.72, DocsCoverageReport.psm1 100, DocsLedgerCommands.psm1 99.13, Invoke-DocsCommand.ps1 87.58 (baseline 87.33). The non-zero exit is the pre-existing Pester JUnit export defect of [P0-T6], raised after the run and the coverage report completed.

## Counts

Source: the root `<testsuites>` element of `artifacts/pester/pester-junit.xml` (`tests="14333" errors="6" failures="409" disabled="10"`) and the console summary `Tests Passed: 13914, Failed: 409, Skipped: 10, Inconclusive: 0, NotRun: 0`.

- tests: 14333 (baseline 14108; +225)
- passed: 13914 (baseline 13689; +225)
- failed: 409 failures plus 6 errors (baseline 409 and 6)
- skipped: 10 (baseline 10)

JUnit export defect (pre-existing, host-side, as in [P0-T6]): Pester's `Export-XmlReport` threw on an escape character (U+001B) inside a failure message of the Linux-only failures, so the JUnit file is cut off after its first two suites; the root attributes are complete, and the console summary and the coverage report were written in full before that step.

## Failing-suite comparison against the baseline

Derived from the console log: the suite names in every failure stack line (`at ..., tests/scripts/<suite>:<n>`) and the test names in every `[-]` line, each set de-duplicated and compared with the same derivation over the [P0-T6] console log.

- Failing suites: 25; identical to the 25 suites listed in `evidence/baseline/baseline-pester-coverage.2026-11-03T22-10.md` (`diff` empty).
- Failing test names: 97; identical to the 97 names listed in the baseline artifact (`diff` empty).
- Failing suites under `tests/scripts/claude-lib/docs`: none. All 37 docs suites (12 from 1020, 25 from 1023) pass.
- The Linux-host causes (drive-letter and `/repo` fixtures, `pwsh` not resolvable inside hook probes, Windows-only host tooling) are unchanged and are owned by separate items; nothing outside this feature's file set was touched.

Acceptance: `failures="0"` and `errors="0"` is not met on this host; the alternative condition, only failures [P0-T6] recorded as pre-existing, is met. CI: `poshqc / PowerShell QC` (`windows-latest`), where these failures do not occur.

## Coverage (artifacts/pester/powershell-coverage.xml, LINE counter per file; 279 files)

| File | Covered | Missed | Line coverage |
|---|---|---|---|
| `.claude/lib/docs/DocsLedger.psm1` (new) | 167 | 2 | 98.82 |
| `.claude/lib/docs/DocsLedgerRules.psm1` (new) | 93 | 1 | 98.94 |
| `.claude/lib/docs/DocsEvidencePins.psm1` (new) | 92 | 3 | 96.84 |
| `.claude/lib/docs/DocsStaleness.psm1` (new) | 46 | 0 | 100 |
| `.claude/lib/docs/DocsParity.psm1` (new) | 183 | 2 | 98.92 |
| `.claude/lib/docs/DocsReceipt.psm1` (new) | 95 | 0 | 100 |
| `.claude/lib/docs/DocsLedgerMutation.psm1` (new) | 59 | 1 | 98.33 |
| `.claude/lib/docs/DocsValidation.psm1` (new) | 154 | 2 | 98.72 |
| `.claude/lib/docs/DocsCoverageReport.psm1` (new) | 77 | 0 | 100 |
| `.claude/lib/docs/DocsLedgerCommands.psm1` (new) | 343 | 3 | 99.13 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` (edited) | 134 | 19 | 87.58 |
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` | 119 | 0 | 100 |
| `.claude/lib/docs/DocsFinding.psm1` | 88 | 0 | 100 |
| `.claude/lib/docs/DocsJson.psm1` | 102 | 0 | 100 |
| `.claude/lib/docs/DocsProfile.psm1` | 81 | 0 | 100 |
| `.claude/lib/docs/DocsProfileCommands.psm1` | 67 | 2 | 97.1 |
| `.claude/lib/docs/DocsSchema.psm1` | 127 | 0 | 100 |
| `.claude/lib/docs/DocsSchemaWalk.psm1` | 87 | 0 | 100 |
| `.claude/lib/docs/DocsSurface.psm1` | 130 | 0 | 100 |
| Total (all 279 files) | 23226 | 1751 | 92.99 |

The three 1023 dispatch rows of `Invoke-DocsCommand.ps1` (the three `[pscustomobject]` lines directly under the `# --- 1023: coverage, update-ledger, validate ---` anchor) are covered: hit counts 7, 21 and 10 with 0 missed instructions each. The 19 missed lines of that file are the pre-existing entry-point block (the script's top-level invocation path), the same 19 lines as at baseline.

Console coverage line: `Covered 92.53% / 0%. 39,217 analyzed Commands in 279 Files.` (command coverage; the line figures above are the LINE counters of the report). The bundle copies under `extensions/drm-copilot/resources/` are not in the coverage population of `config/poshqc-coverage.json`, which is unchanged.
