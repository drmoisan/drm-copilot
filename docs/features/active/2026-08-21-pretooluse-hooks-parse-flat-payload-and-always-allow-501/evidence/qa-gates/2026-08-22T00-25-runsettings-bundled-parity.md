# QA gate — Coverage-denominator additions and bundled parity (AC-11 prerequisite) (#501)

Timestamp: 2026-08-22T00-25

Task: [P5-T6]

## Why this change is required

`CodeCoverage.Path` in the Pester runsettings is an explicit per-file allow-list, not a glob. AC-11 requires `.claude/lib/hook-payload/HookPayload.psm1` and every modified hook to sit in the coverage denominator, which is unsatisfiable unless the new and newly-tested files are registered. Six of the migrated hooks and both extracted helper siblings were absent from the list.

## Paths added

The following nine paths were appended to the `CodeCoverage.Path` list in **both** copies:

1. `.claude/lib/hook-payload/HookPayload.psm1` (new shared module, [P1-T1])
2. `.claude/hooks/enforce-promotion-mcp-only.ps1`
3. `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
4. `.claude/hooks/enforce-evidence-locations.ps1`
5. `.claude/hooks/enforce-feature-folder-order.ps1`
6. `.claude/hooks/enforce-checkpoint-monotonic.ps1`
7. `.claude/hooks/enforce-prd-feature-before-planner.ps1`
8. `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1` (the [P4-T2] extraction)
9. `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (the [P2-T2] extraction)

Files edited:

- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`

No exclude entry was added anywhere; the change is additive to the denominator only.

## Verification of the nine entries

Command: `Import-PowerShellDataFile 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'` then a `-contains` probe per path.

EXIT_CODE: 0

Output:

```
CodeCoverage.Path count: 80
True .claude/lib/hook-payload/HookPayload.psm1
True .claude/hooks/enforce-promotion-mcp-only.ps1
True .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
True .claude/hooks/enforce-evidence-locations.ps1
True .claude/hooks/enforce-feature-folder-order.ps1
True .claude/hooks/enforce-checkpoint-monotonic.ps1
True .claude/hooks/enforce-prd-feature-before-planner.ps1
True .claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1
True .claude/hooks/enforce-pr-author-skill-helpers.ps1
```

All nine resolve, and the list parses as a valid PowerShell data file (80 entries, up from 71).

## Byte parity between the two copies

Command: `diff scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`

EXIT_CODE: 0

Output: no differences (`IDENTICAL`).

## Companion parity gate

Command: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py`

EXIT_CODE: 0

Output: `1 passed in 0.05s`

Output Summary: Nine production paths added to `CodeCoverage.Path` in both runsettings copies; all nine verified present by a parsed `-contains` probe; the two copies are byte-identical; the bundled-parity pytest passes. AC-11's denominator prerequisite is in place, and no coverage exclusion was introduced.
