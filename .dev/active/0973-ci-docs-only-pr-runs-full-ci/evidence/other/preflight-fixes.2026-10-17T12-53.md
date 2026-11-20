# Preflight Fixes (Issue #973)

Timestamp: 2026-10-17T12-53
Plan: docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973/plan.2026-10-17T08-16.md

## Fix 1

- Task: [P1-T1] (row M1)
- Defect class: validator-blind ordering defect that made a later acceptance condition depend on unspecified assertion order.
- Observation: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` sets `Should.ErrorAction = 'Stop'`, so a row stops at its first failing assertion. [P1-T6] requires the M1 failure message to show the observed reason `NO_FULL_GREEN_RUN`. With the Output assertion listed first, the message would show only `code=true`.
- Change made: M1 now asserts, in this order, Log, Output, Summary, with the reason stated in the task text. What M1 asserts is unchanged.

## Fix 2

- Task: [P4-T1]
- Defect class: tool-route literal correction.
- Observation: `mcp__drm-copilot__run_poshqc_format` accepts scan folders only, not individual files.
- Change made: the task names the scan folders `scripts/ci`, `tests/scripts/ci`, and `tests/scripts/workflows`, which hold the seven PowerShell files written by the plan. The before-and-after porcelain observation and the non-writing format check over the seven files are unchanged.
