# P14-T8 PowerShell test gate

Timestamp: 2026-10-29T12-14
Task: [P14-T8] Re-run the PowerShell gates and CI-shaped execution on the rebased tree.
Command: Import-Module scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root <worktree> (scan folders from config/poshqc-scan.json, coverage population from config/poshqc-coverage.json, repository pester.runsettings.psd1; run from a SCRATCH launcher in PowerShell 7, never through the MCP tool)
EXIT_CODE: 1 (pass 1), 0 (pass 2)
Output Summary: Pass 2 read from the actual JUnit file: 12615 tests over 452 test files, 12605 passed, 0 failed, 0 errors, 10 skipped (the same ten pre-existing skips as P13-T3). Line coverage, read from the actual coverage file: 20003 of 21443 lines (93.28%); P13-T3 recorded 93.14%. Pester measures no branch coverage, and none is recorded. The population includes `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` (5 tests, 0 failures) and `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` (3 tests, 0 failures).

Per-file line coverage of the discovery PowerShell production files (unchanged by Phase 14): DiscoveryAuthorization.psm1 192/202 (95.05%), DiscoveryAuthority.psm1 139/147 (94.56%), DiscoveryCapability.psm1 137/138 (99.28%), DiscoveryValidation.psm1 78/78 (100%), CodexDiscoveryRouting.psm1 68/68 (100%), the capability probe hooks 37/38, 30/31 and 33/34 (.claude, .codex, .github).

Retained files, made repository-relative with the host and user identity fields redacted and no result value changed: `p14-powershell-junit.2026-10-29T12-14.xml` and `p14-powershell-coverage.2026-10-29T12-14.xml`.

## Loop record

Pass 1 (10-51Z; 12604 passed, 1 failed) failed `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` "reports zero ratchet violations against config/file-size-baseline.json" with `scripts/dev_tools/agentic_sync.py: stale baseline entry: 'scripts/dev_tools/agentic_sync.py' has 454 lines, at or below the 800-line hard limit; remove the entry.`

- Cause: the rebase brought `config/file-size-baseline.json` from origin/main, where `scripts/dev_tools/agentic_sync.py` has 819 logical lines and is the only baselined file. The P12-T10 split on this branch reduced the file to 454 lines, and the strict ratchet fails on a baseline entry for a file at or below the hard limit.
- Repair: the entry is removed, leaving `"files": {}`. The new file is byte-identical to the text `New-FileSizeBaseline -Ref HEAD` renders through its injected writer seam (0 entries, `IDENTICAL=True`), so it is the generator's canonical output for this tree. No test or assertion changed. The only readers of the file are `FileSizePolicy.RepoGate.Tests.ps1` and the generator; no Python or TypeScript test reads it, so the P14-T6 and P14-T7 loops are unaffected.
- The shard pass of the first run failed the same test in shard 1. The aggregator then reported a count mismatch only because shard 1's failing run threw before its JUnit copy step, leaving the P13 shard-1 file in place. This was a consequence of the failure, not a merge defect.

Pass 2 (restarted from formatting at 11-31Z) is clean in every stage. The first run's Linux hook-suite stage was still finishing (11-31Z to 11-36Z) when pass 2 started; it passed, and pass 2's own hook-suite run later replaced its JUnit file.

Result: PASS
