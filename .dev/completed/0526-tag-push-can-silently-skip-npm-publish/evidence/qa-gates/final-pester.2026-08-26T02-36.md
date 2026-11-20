# Final QA Loop — Stage 3 — Pester with Coverage

Timestamp: 2026-08-26T04-18

> Filename-stamp substitution note: the filename carries the fixed cycle stamp `2026-08-26T02-36`
> required by the plan, whose acceptance conditions assert exact filenames. The `Timestamp:` field
> records the actual execution stamp, `2026-08-26T04-18`. Same convention as Phases 0 through 3.

Command: `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path'`

EXIT_CODE: 0

## Output Summary

### Suite result

- **Tests passed: 3646**
- **Tests failed: 0**
- Tests skipped: 9
- Inconclusive: 0; NotRun: 0
- Tests completed in 110.69 s
- Suite exit code: 0

### Repository-wide line coverage

- Lines covered: 6794
- Lines missed: 279
- Lines measured: 7073
- **Repository-wide line coverage: 96.0554 percent**

96.0554 percent is **at or above the 85.0 percent floor** required uniformly across tiers T1 through
T4 by `.claude/rules/quality-tiers.md`.

### Per-file line coverage for the files this cycle touched

| File | Covered | Missed | Measured | Line coverage |
|---|---|---|---|---|
| `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | 56 | 9 | 65 | 86.1538 percent |
| `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` | 29 | 0 | 29 | 100 percent |
| `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` | 75 | 2 | 77 | 97.4026 percent |

Coverage was read from the direct self-hosted PoshQC invocation, not from the MCP test tool, because
the MCP runner resolves its runsettings from the installed extension bundle and emits no coverage row
for the newly registered helpers file. Per-file rows were parsed from
`artifacts/pester/powershell-coverage.xml` by keying on the enclosing `package` element and then
selecting the `sourcefile` by name within it.

The stage changed no source file on disk. `testResults.xml` at the repository root is a tracked run
artifact that the suite rewrites on every invocation; it is not a source change and does not trigger
a loop restart. The loop proceeds to stage 4 (`P7-T4`) without a restart. This is loop iteration 1.
