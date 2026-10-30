# P18-T3 PowerShell test gate on the cycle-2 tree

Timestamp: 2026-10-30T12-41
Task: [P18-T3] Run the PowerShell format, analyzer and single-process coverage gates.
Command: Import-Module scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root <worktree> (scan folders from config/poshqc-scan.json, coverage population from config/poshqc-coverage.json, repository pester.runsettings.psd1; one process, the CI single-process shape, run from a SCRATCH launcher in PowerShell 7)
EXIT_CODE: 0
Output Summary: Read from the actual JUnit file: 13091 tests over 466 test files, 13081 passed, 0 failed, 0 errors, 10 skipped (the same ten pre-existing skips as P16-T3). Line coverage, read from the actual coverage file: 20374 of 21812 lines (93.41%), 1438 missed; P16-T3 recorded 20188 of 21629 (93.34%) and the P17-T1 baseline is 93.34%. Pester measures no branch coverage, and none is recorded. The population includes `tests/scripts/claude-lib/discovery-validation/DiscoverySentinelConsumption.Contract.Tests.ps1` (3 tests, 0 failures; case (b) now passes on the corrected probe), `DiscoveryCapability.Tests.ps1` (43 tests), the three host `discovery-capability.Tests.ps1` suites (12, 12 and 10 tests) and `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` (5 tests), all with 0 failures. One clean pass with no fix and no restart (single process 2026-10-30T12-21 to 12-40 UTC, 938.76 s of test time, under the 20-minute runtime guard; the Python and TypeScript gates ran in parallel on the same machine). The shard matrix is not re-run in this cycle, as the plan states.

Per-file line coverage of the production file this cycle changed, read from the coverage file: `.claude/lib/discovery-validation/DiscoveryCapability.psm1` 183/184 (99.46%); the one missed line is in `Get-DiscoveryHostRegistration` (the Codex TOML `matcher` branch), the same pre-existing line P16-T4 reported as uncovered before the cycle's additions shifted it, and no line the cycle added or changed is missed (`DiscoveryObservation.psm1` 65/65, unchanged).

Retained files, made repository-relative with the host and user identity fields redacted and no result value changed: `p18-powershell-junit.2026-10-30T12-41.xml` and `p18-powershell-coverage.2026-10-30T12-41.xml`. Every later consumer (P18-T4, P18-T5) reads these evidence copies.

## Canonical coverage file

No shard run followed the single process in this cycle, so `artifacts/pester/powershell-coverage.xml` is the single-process report: `cmp` against the launcher's copy reports identity (`CANONICAL_EQUALS_SINGLE_RUN_COPY`), and both carry the LINE counter `missed="1438" covered="20374"`, equal to the evidence copy's total of 20374 of 21812 lines (93.41%). Both canonical paths are git-ignored.
Result: PASS
