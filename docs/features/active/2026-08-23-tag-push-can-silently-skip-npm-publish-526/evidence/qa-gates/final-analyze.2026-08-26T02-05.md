# Final QA — PowerShell Analyze — P7-T2

Timestamp: 2026-08-26T02-05

Note on filename stamp: the plan fixes every evidence filename at `.2026-08-24T13-10.md`. This
execution ran on 2026-08-26, so the executor substituted its own `yyyy-MM-ddTHH-mm` stamp
(`2026-08-26T02-05`) in that same position. The path prefix and base name are unchanged.

Command: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` =
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3c3e2a8cfa4dbcd5`

EXIT_CODE: 0

## Raw Result

```json
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a3c3e2a8cfa4dbcd5","summary":"Ran bundled PoshQC analyze against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a3c3e2a8cfa4dbcd5'."}
```

The MCP entry point returns a structured result rather than a raw process exit code. `ok: true` is
the success signal and is recorded as `EXIT_CODE: 0`.

## Diagnostic Counts

| Severity | Count |
|---|---|
| Error | 0 |
| Warning | 0 |
| Information | 0 |
| Total | 0 |

## Derivation of the Counts

The MCP result carries no severity breakdown, so the three counts were obtained by the same two
independent means the P0-T4 baseline artifact used, keeping the two figures directly comparable.

1. Direct invocation of the self-hosted PoshQC analyzer:

   ```
   Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
   Invoke-PoshQCAnalyze -Root (Get-Location).Path
   ```

   Console output:

   ```
   PSScriptAnalyzer passed: no findings under C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3c3e2a8cfa4dbcd5
   ```

2. Explicit per-severity grouping. `Get-PoshQCFileList -Root (Get-Location).Path` enumerated the
   scan set and each file was passed to `Invoke-ScriptAnalyzer` with the repository settings file
   `scripts/powershell/PoshQC/settings/pssa.settings.psd1`. Observed:

   ```
   FILES=411
   TOTAL=0
   ERROR=0
   WARNING=0
   INFORMATION=0
   ```

- Files in the scan set: 411 (baseline: 405; the increase of 6 is accounted for by the files this
  change adds, which are now in the scan set)
- Analyzer settings file used: `scripts/powershell/PoshQC/settings/pssa.settings.psd1`

The two means agree.

## Comparison against the P0-T4 baseline

| Metric | Baseline (P0-T4) | Post-change (P7-T2) | Delta |
|---|---|---|---|
| Error | 0 | 0 | 0 |
| Warning | 0 | 0 | 0 |
| Information | 0 | 0 | 0 |
| Files scanned | 405 | 411 | +6 |

Output Summary: PoshQC analyze completed successfully with `ok: true`, recorded as exit code 0. The
Error count is 0, satisfying the task's acceptance condition and the uniform zero-lint-error gate in
`.claude/rules/quality-tiers.md`. Warning and Information counts are also 0. The tree remains
analyzer-clean across 411 scanned PowerShell files, six more than at baseline, so this change
introduced no diagnostic at any severity. No toolchain-loop restart was triggered by this stage.
