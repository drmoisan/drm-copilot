# N1 Fail-Before - issue #1021, remediation cycle 1

Timestamp: 2026-11-04T00-47
Task: [P2-T1] [expect-fail]
Command: `sh SCRATCH/issue-1021-runfile.sh tests/scripts/claude-lib/docs/DocsPageCheck.LinkMap.Tests.ps1` (one PowerShell 7 process, `Invoke-Pester` with `Run.PassThru`, against the unmodified `DocsPageCheck.psm1`)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: Pester total=2 passed=0 failed=2. `Invoke-DocsCheckCommand link map.builds the link map once per check run` fails with `Expected Get-DocsPageLinkMap in module DocsPageCheck to be called 1 times exactly, but was called 2 times`. `Invoke-DocsCheckCommand link map.returns the same findings with and without a precomputed map` fails with `A parameter cannot be found that matches parameter name 'LinkMap'.` The runner exits 0 because `Invoke-Pester` runs without `Run.Exit`; the result comes from the PassThru counts.

The expect-fail outcome is met: both tests fail for the reasons [P2-T1] states.
