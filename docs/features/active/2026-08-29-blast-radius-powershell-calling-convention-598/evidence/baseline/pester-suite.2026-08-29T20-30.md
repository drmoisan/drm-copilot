# Pester suite baseline — issue #598

Timestamp: 2026-08-29T20-30
Task: [P0-T7]

Command:
`pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`

The self-hosted PoshQC module is the observation source rather than
`mcp__drm-copilot__run_poshqc_test`, because the MCP runner resolves its runsettings from the
installed VS Code extension rather than from
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.

EXIT_CODE: 0

BaselineSuiteRed: false

Output Summary:

Verbatim replayed summary line (ANSI colour escapes removed):

```
Tests Passed: 3842, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
```

Numeric counts:

- Passed: 3842
- Failed: 0
- Skipped: 9
- Inconclusive: 0
- NotRun: 0

Additional lines recorded from the same run:

```
Tests completed in 129.81s
Processing code coverage result.
Covered 94.19% / 0%. 10,563 analyzed Commands in 88 Files.
Wrote Koverage coverage copy: <workspace>\artifacts\pester\powershell-coverage.koverage.xml
```

The `94.19% / 0%` pair is the command-coverage figure and the (unmeasured) branch figure that Pester
prints. The line-coverage figure that policy gates on is derived separately in `[P0-T8]` from
`artifacts/pester/powershell-coverage.xml`.

## Acceptance evaluation

- `Output Summary:` contains a line beginning `Tests Passed: `.
- Five integer counts recorded: 3842, 0, 9, 0, 0.
- The run's result was Passed, so the `BaselineSuiteRed: true` branch of `[P0-T7]` does not fire and
  no failing test names are reported.
