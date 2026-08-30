Timestamp: 2026-08-30T08-12
Command: pwsh -NoProfile -Command "Invoke-Pester -Path 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1' -CI -Output Detailed"
ExpectedExitCode: 1
EXIT_CODE: 1
Pester Counts: 84 passed, 3 failed, 0 skipped, 0 inconclusive, 0 not run.
Intended Failing Assertions: `Issue number: 644` parsing; later normalized folder selection over an earlier terminal issue match in epic readiness; the same selection rule in parallel readiness.
Not Applicable: P1-T2 launched Pester.
Output Summary: The unchanged helper does not parse the whitespace form and returns the first issue-number record before scanning later exact folder records. The expected fail-before result was observed.
