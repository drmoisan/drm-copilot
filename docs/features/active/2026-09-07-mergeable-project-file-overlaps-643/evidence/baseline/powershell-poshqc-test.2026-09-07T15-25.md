# Baseline — PowerShell tests and coverage (issue #643, task [P0-T14])

- Timestamp: 2026-09-07T15:25Z
- Command: MCP function `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-09-07T08-09`, then `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"` (run from the worktree root)
- EXIT_CODE: 0

## Output Summary

### MCP payload

- `ok`: `true`
- `summary`: `Ran bundled PoshQC test against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-09-07T08-09'.`

Both the MCP call required by `.claude/rules/powershell.md` and the self-hosted
`Invoke-PoshQCTest -Root` call are recorded, because the MCP payload carries only `ok`, `tool`,
`workspace_root`, and `summary` and therefore no numeric result.

### Self-hosted run — result line (verbatim)

```text
Tests Passed: 3921, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
```

Passed count for later comparison (plan task [P8-T12] requires at least this value plus 45): 3921.

### Self-hosted run — coverage line (verbatim)

```text
Covered 94.29% / 0%. 10,891 analyzed Commands in 88 Files.
```

The first figure is command (instruction) coverage; the second figure is `0%` because Pester
measures no branch coverage.

### JaCoCo report `artifacts/pester/powershell-coverage.xml`

Report-level `LINE` counter:

- `covered` = 7427
- `missed` = 407
- derived line coverage = `7427 / (7427 + 407) * 100` = **94.80%**

Per-`sourcefile` `LINE` counter for `BlastRadius.psm1`:

- `covered` = 110
- `missed` = 0
- derived line coverage = `110 / (110 + 0) * 100` = **100.00%**

### Branch coverage statement

Pester measures no branch coverage. Its coverage output reports command (instruction) coverage and
line coverage only, and the JaCoCo report carries no `BRANCH` counter for these sources.
Consequently no branch-coverage threshold applies to PowerShell in this feature, per
`.claude/rules/powershell.md` and `.claude/rules/quality-tiers.md`. This is a threshold exemption
only: PowerShell production files remain in the coverage denominator.
