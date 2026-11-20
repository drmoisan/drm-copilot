# Scratch Tooling (P0-T3)

Timestamp: 2026-11-03T23-10
Command: sh SCRATCH/issue-1066-launch-p0t3.sh (runs SCRATCH/issue-1066-run-list.ps1 over a list file holding tests/scripts/dev-tools/run-actionlint.Tests.ps1 to RAW/target-alone-tooling.xml, then SCRATCH/issue-1066-junit-sets.ps1 -ListAll over that file)
EXIT_CODE: 0
Output Summary:
- RUN-LIST: Total=35 Passed=35 Failed=0 Skipped=0 NotRun=0 FailedBlocks=0 FailedContainers=0
- JUnit for TARGET alone holds 35 testcases.
- Parser keys carry no worktree root prefix, for example `tests/scripts/dev-tools/run-actionlint.Tests.ps1|run-actionlint.ps1.Resolve-ActionlintPath.resolves paths correctly from script location`.

Tooling created under SCRATCH:
- `issue-1066-run-list.ps1`: single-process `Invoke-Pester` over an ordered path list read from a text file; `CodeCoverage.Enabled` false, `Run.Exit` false, `Run.PassThru` true; writes JUnit to the named RAW file; exits 1 when any test, block, or container fails.
- `issue-1066-junit-writer.ps1`: writes JUnit from the Pester PassThru result. Deviation note: Pester's built-in JUnit export fails on this host when a failure message holds an 0x1B character and leaves a truncated file, so the writer strips XML-invalid control characters and writes one `testsuite` per container (name = repository-relative path) and one `testcase` per test (name = Pester `ExpandedPath`). A failed block adds a `<block path> [block]` testcase; a failed container with no failed test adds a `[container]` testcase.
- `issue-1066-sets-lib.ps1` and `issue-1066-junit-sets.ps1`: read one or two JUnit files, print totals, failing keys (testcase key convention: relative suite path, `|`, testcase name), and set differences.
- `issue-1066-order.ps1`: writes the forward, reversed, seeded (`Get-Random -SetSeed`), or reduced DEVLIST list file from `Get-ChildItem tests/scripts/dev-tools -Filter *.Tests.ps1 | Sort-Object -Property FullName`.
- One `sh` launcher per invocation (`issue-1066-launch-<task>.sh`).
- RAW (`artifacts/pester/issue-1066/`) is gitignored (`.gitignore` rule `/artifacts`).
