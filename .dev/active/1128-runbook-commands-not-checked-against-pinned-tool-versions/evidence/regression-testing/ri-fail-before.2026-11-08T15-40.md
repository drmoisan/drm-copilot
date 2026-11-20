# RI-1 / RI-2 fail-before (P1-T2)

Timestamp: 2026-11-08T15-40
Command: Invoke-Pester -Path tests/scripts/claude-lib/runbook/RunbookCommandVersion.Tests.ps1 -PassThru (debugging run, not a gate; sh launcher SCRATCH/focused.sh exits with FailedCount plus FailedContainersCount)
EXIT_CODE: 22
ExpectedExitCode: 22
Output Summary: Expected failure before the fix. Passed=40 Failed=22 FailedContainers=0 Total=62. Failures include both observed reproductions: "passes a multi-line nuitka command joined by backslash continuations when the nuitka marker is present" (RI-1 nuitka continuation block) and "passes a cd-prefixed chained command when the nuitka marker is present" (RI-2, `cd x && python -m nuitka --clean-cache=all`), plus the unmarked variants, backtick and caret joins, assignment skips, builtin skips, separator splits, and the piped-command marker case. The 40 passing tests are the pre-existing cases and the quote-guard and final-line-continuation cases, which hold both before and after the fix.
