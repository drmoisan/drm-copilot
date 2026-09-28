# PowerShell Analyze Baseline (P0-T4)

Timestamp: 2026-08-25T23-33

Filename-stamp substitution: plan-fixed suffix `.2026-08-24T13-10.md` replaced with
`.2026-08-25T23-33.md` for this execution date. Path prefix and base name unchanged.

Command: `mcp__drm-copilot__run_poshqc_analyze` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3c3e2a8cfa4dbcd5`

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

The MCP result carries no severity breakdown, so the three counts were obtained by two independent
means, both against the same baseline commit `afbf51dfe6508319a2d673603d31825077d8cddb`.

1. Direct invocation of the self-hosted PoshQC analyzer:

   ```
   Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
   Invoke-PoshQCAnalyze -Root (Get-Location).Path
   ```

   Console output:

   ```
   PSScriptAnalyzer passed: no findings under C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3c3e2a8cfa4dbcd5
   ```

   The function emits no diagnostic objects on the success path, so the analyzer's own verdict is
   zero findings of any severity.

2. Explicit per-severity grouping, to convert that verdict into the three numeric values this task
   requires. `Get-PoshQCFileList -Root (Get-Location).Path` enumerated the scan set, and each file
   was passed to `Invoke-ScriptAnalyzer` with the repository settings file
   `scripts/powershell/PoshQC/settings/pssa.settings.psd1`. Observed:

   ```
   TOTAL=0
   ERROR=0
   WARNING=0
   INFORMATION=0
   ```

- Files in the scan set: 405
- Analyzer settings file used: `scripts/powershell/PoshQC/settings/pssa.settings.psd1`

The two means agree.

Output Summary: PoshQC analyze completed successfully with `ok: true`, recorded as exit code 0.
Diagnostic counts are Error 0, Warning 0, Information 0, total 0, across 405 scanned PowerShell
files. The tree is analyzer-clean at the baseline commit, so any diagnostic reported by the Phase 7
final-analyze run (P7-T2) is attributable to this change. The `.claude/rules/quality-tiers.md`
uniform gate of zero lint errors is satisfied at baseline.
