# Post-merge Pester suite baseline — issue #598

Timestamp: 2026-08-29T23-10
Task: [P0-T16]

Command:
`pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`

The self-hosted PoshQC module is the observation source rather than
`mcp__drm-copilot__run_poshqc_test`, for the reason recorded in `[P0-T7]`: the MCP runner resolves
its runsettings from the installed VS Code extension rather than from
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.

EXIT_CODE: 0

Output Summary:

Verbatim replayed summary line, with ANSI colour escapes stripped:

```
Tests Passed: 3873, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
```

`Invoke-PoshQCTest` emits this summary as several separate `Write-Information` records
(`scripts/powershell/PoshQC/PoshQC.Testing.psm1:423` builds it from the format string
`Tests Passed: {0}, Failed: {1}, Skipped: {2}, Inconclusive: {3}, NotRun: {4}`). The line above is
the concatenation of those records. Filtering on `-like 'Tests Passed: *'` alone would have yielded
only the first fragment.

PostMergeBaselinePassed: 3873
PostMergeBaselineFailed: 0
PostMergeBaselineSkipped: 9
PostMergeBaselineInconclusive: 0
PostMergeBaselineNotRun: 0

SupersededPreMergeBaseline: Tests Passed: 3842, Failed: 0, Skipped: 9

The superseded line is copied from `evidence/baseline/pester-suite.2026-08-29T20-30.md`. The passed
count rose by 31 and the skipped count is unchanged; the increase is attributable to the test files
the merge added, which include
`tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1`,
`tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1`, and their siblings.

The run also reported `Tests completed in 124.59s` and
`Covered 94.24% / 0%. 10,722 analyzed Commands in 88 Files.`, which is Pester's command-coverage
figure. The line-coverage figure this plan uses is derived separately by `[P0-T17]` from the
report-level `counter type="LINE"` element of
`artifacts/pester/powershell-coverage.xml`, which this run wrote.

A count of the failing-file marker `[-]` over the stripped output returns `0`, consistent with the
`Failed: 0` field.

PostMergeSuiteRed: false

## Coverage artifact produced by this run

`artifacts/pester/powershell-coverage.xml` was rewritten by this run (657,343 bytes). `[P0-T17]` and
`[P0-T18]` read that file, and per sequencing constraint 8 they run before any batch gate overwrites
it.

## Acceptance evaluation

- `Output Summary:` contains a line beginning `Tests Passed: `.
- The five `PostMergeBaseline*` fields are integers: `3873`, `0`, `9`, `0`, `0`.
- `PostMergeBaselineFailed:` is `0`.

All three acceptance conditions hold. The merged tree is green, so the report-to-caller branch does
not fire.

`PostMergeBaselinePassed:` (3873) and `PostMergeBaselineSkipped:` (9) are the comparands for
`[P8-T3]` and `[P10-T3]`. The `[P0-T7]` figures of 3842 and 9 are not.
