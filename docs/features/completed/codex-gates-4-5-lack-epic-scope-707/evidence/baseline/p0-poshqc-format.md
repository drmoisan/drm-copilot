# Phase 0 PowerShell Format Baseline ([P0-T6])

Timestamp: 2026-09-27T06-30
Command: git status --porcelain; sh <SCRATCHPAD>/p0-format.sh (fresh PowerShell 7 process: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root $root with the information stream captured); git status --porcelain
EXIT_CODE: 0
Output Summary: Invoke-PoshQCFormat logged 0 lines beginning `Formatted: ` and 531 lines beginning `Already formatted: ` (531 log lines in total, no other lines). The porcelain output before and after the run is identical, so no tracked file was rewritten and no restore was needed.

Formatted count: 0
Already formatted count: 531

## Tree Delta

Porcelain before:

```
 M docs/features/active/codex-gates-4-5-lack-epic-scope-707/plan.2026-09-26T22-55.md
?? docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/
```

Porcelain after:

```
 M docs/features/active/codex-gates-4-5-lack-epic-scope-707/plan.2026-09-26T22-55.md
?? docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/
```

Restore: not required (no tracked file rewritten; the final porcelain output equals the first).
