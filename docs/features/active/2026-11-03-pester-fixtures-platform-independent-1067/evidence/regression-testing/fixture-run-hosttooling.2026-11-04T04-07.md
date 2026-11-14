# Fixture Run: HostTooling.Tests.ps1 (P5-T3)

Timestamp: 2026-11-04T04-07
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/HostTooling.Tests.ps1
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=22 Passed=22 Failed=0 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/HostTooling.Tests.ps1 tests=22 failed=0 (baseline: 1 failed)
- Changes: portable root `hosttooling-root`; both `Read-HostToolsManifest` calls pass a manifest path built from the root. The `Get-Content` mock is kept unchanged.
- C3 confirmed: the baseline failure was `Read-HostToolsManifest.returns the parsed manifest object when the file exists` with "A parameter cannot be found that matches parameter name 'Raw'." Changing only the bound path from a `C:` path to a path on an existing drive makes the same mocked `Get-Content -Raw` call bind and the test pass, so the failure came from the FileSystem dynamic parameter `-Raw` not binding for a path on a drive that does not exist.
