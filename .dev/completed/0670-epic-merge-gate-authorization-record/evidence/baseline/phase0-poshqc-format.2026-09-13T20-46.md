# Phase 0 Formatting Baseline — Issue #670

Timestamp: 2026-09-17T07-52
Task: [P0-T5]
Command: git status --porcelain ; Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path -ScanFolders @('.claude/hooks','.codex/hooks','tests/scripts/claude-hooks','tests/scripts/codex-hooks') ; git status --porcelain
EXIT_CODE: 0

## Porcelain before the run (verbatim)

```
 M docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/plan.2026-09-13T20-46.md
?? docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/evidence/
```

(Both entries are this plan's own bookkeeping: the Phase 0 check-offs and the Phase 0 evidence folder.)

## Porcelain after the run (verbatim)

```
 M docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/plan.2026-09-13T20-46.md
?? docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/evidence/
```

## Files rewritten by the run

None. Every file in the four scan folders printed an `Already formatted:` line; no other per-file status line was printed. The run rewrote no tracked file.

## Restores performed

None required (zero rewritten paths, so zero `git checkout --` restores).

## Pre-existing formatting drift left unrepaired in Phase 0

None.

Output Summary:
- Formatter exit 0; before and after porcelain outputs are byte-identical (two bookkeeping lines each).
- Zero files rewritten; zero restores; pre-existing drift list is empty.
- Porcelain after the (zero) restores prints the same output it printed before the run.
