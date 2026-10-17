# QC Pass 2: Issue824-Tagged Rows ([P10-T9])

Timestamp: 2026-10-08T23-21
Command: sh <SCRATCHPAD>/s-pester.sh I824
EXIT_CODE: 0
Output Summary:
PESTER_SET: I824 FILES=147 (all *.Tests.ps1 under tests/scripts/claude-hooks and tests/scripts/codex-hooks; Filter.Tag = Issue824)
PESTER_TOTAL: 4104 (3415 RESULT NotRun lines are tests excluded by the tag filter; 689 executed)
PESTER_PASSED: 689
PESTER_FAILED: 0
PESTER_SKIPPED: 0
PESTER_FAILED_BLOCKS: 0
PESTER_FAILED_CONTAINERS: 0
RESULT Failed lines: 0

## Distinct row IDs on RESULT Passed lines (325 IDs)

```
AL: 01-38
CN: 01-10
CW: 01-40
EW: 01-40
IV: 01-24
OP: 01-16
PA: 01-24
PM: 01-32
PW: 01-40
PY: 01-27
REG: 01-21
SC: 01-13
```

Every row ID defined in plan section 5 (REG-01..21, SC-01..13, PY-01..24, IV-01..24, OP-01..16, PM-01..32, EW/PW/CW-01..39, PA-01..22, AL-01..37, CN-01..10) appears on at least one `RESULT Passed` line and on no `RESULT Failed` line. The additional IDs PY-25..27, EW-40, PW-40, CW-40, PA-23, PA-24, and AL-38 are the changed-line coverage rows added between QC pass 1 and pass 2.

## Per-runtime checks used by the AC check-off tasks

- Dual-surface rows pass for both runtimes: PM-02, PM-13, PM-14, PM-18, IV-10, IV-11, REG-01, CN-01 each appear on 2 `RESULT Passed` lines (claude and codex copies); CN-09 on 4 (two commands per runtime); IV-09 on 52 (terminal-option table per runtime).
- IV-06 sink rows: 18 `RESULT Passed` lines, one per SINKS member (Write-Output, Write-Host, Write-Verbose, Write-Information, Select-String, echo, printf, grep, rg) for each of the claude and codex copies.
