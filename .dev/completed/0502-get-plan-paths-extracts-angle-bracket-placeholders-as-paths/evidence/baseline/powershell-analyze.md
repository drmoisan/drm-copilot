# Baseline — PowerShell Analysis — [P0-T7]

Timestamp: 2026-08-23T00-15

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P0-T7]
State captured: PRE-CHANGE baseline

Command: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` set to the worktree root.

EXIT_CODE: 0

## ok status

`ok: true`

## Tool summary, verbatim

```json
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-22T22-50","summary":"Ran bundled PoshQC analyze against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-22T22-50'."}
```

## Diagnostic count by severity

The summary reports no diagnostic count and no severity breakdown. The measured return shape
carries exactly four fields — `ok`, `tool`, `workspace_root`, and a one-sentence `summary` — and
the analyzer writes no report file, so there is nowhere to read a count from. The acceptance
therefore requires a severity breakdown only "when the summary reports one"; this summary does
not, so none is recorded. The ok flag is the only available signal and is the gate.

## Why no snapshot pair is needed here

Unlike the formatter at [P0-T6], the analyzer is read-only. Its ok status is therefore a faithful
signal of its own outcome and no before-and-after pair is required to detect an invisible
rewrite.

## Output Summary

Baseline PowerShell analysis reports ok with no diagnostics surfaced. The tool emits no
diagnostic count or severity breakdown, so the ok flag is the recorded signal.
