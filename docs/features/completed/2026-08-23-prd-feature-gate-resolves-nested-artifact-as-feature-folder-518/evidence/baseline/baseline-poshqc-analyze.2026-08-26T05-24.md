# PSScriptAnalyzer Baseline — [P0-T4]

Timestamp: 2026-08-26T05-24

Task: [P0-T4]
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3`
Tree state: unmodified with respect to the declared write set. No production or test file had been
edited at the time of this run.

Command:

```text
mcp__drm-copilot__run_poshqc_analyze  workspace_root="C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3"
```

EXIT_CODE: 0

MCP result:

```json
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a931fa47c98f755c3","summary":"Ran bundled PoshQC analyze against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a931fa47c98f755c3'."}
```

## Numeric Finding Count by Severity

The MCP surface reports only a pass/fail outcome; it does not return a per-severity breakdown.
`Invoke-PoshQCAnalyze` throws `"PSScriptAnalyzer reported N issue(s)."` when any finding is present
(`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` line 183), so the `ok: true` result establishes
that the total is zero but supplies no per-severity numbers.

To record the per-severity counts as measured values rather than as an inference, the self-hosted
PoshQC module in this workspace was invoked directly, reusing the same file discovery
(`Get-PoshQCFileList` with the module's default exclusions), the same settings file, and the same
severity set that `Invoke-PoshQCAnalyze` passes to `Invoke-ScriptAnalyzer`.

Verification command:

```text
pwsh -NoProfile -ExecutionPolicy Bypass -File <scratchpad>/analyze-severity-count.ps1
```

Script body (imports `scripts/powershell/PoshQC/PoshQC.psd1` from this workspace root and
`scripts/powershell/PoshQC/settings/pssa.settings.psd1` as the settings file):

```powershell
$files = @(Get-PoshQCFileList -Root $root | Where-Object { $_.Extension -in '.ps1', '.psm1' })
foreach ($f in $files) {
    $results += Invoke-ScriptAnalyzer -Path $f.FullName -Settings $settings -Severity Error, Warning, Information -ErrorAction Stop
}
```

Verification EXIT_CODE: 0

Verification output:

```text
FILES_SCANNED=399
TOTAL_FINDINGS=0
SEVERITY_Error=0
SEVERITY_Warning=0
SEVERITY_Information=0
PSSA_VERSION=1.25.0
PS_VERSION=7.6.5
```

| Severity | Baseline finding count |
| --- | --- |
| Error | 0 |
| Warning | 0 |
| Information | 0 |
| **Total** | **0** |

Route used for the per-severity numbers: the self-hosted PoshQC module in this workspace, invoked
directly via `pwsh`. The MCP run is recorded above as the primary command and agrees with the direct
run on the total.

Output Summary: PSScriptAnalyzer ran against the unmodified tree and reported zero findings. The MCP
invocation returned `ok: true` (EXIT_CODE 0), which under `Invoke-PoshQCAnalyze` means the analyzer
did not throw and therefore recorded no issues. The direct self-hosted run over the same 399
discovered `.ps1` and `.psm1` files confirms the breakdown numerically: 0 Error, 0 Warning, 0
Information, 0 total. PSScriptAnalyzer 1.25.0 on PowerShell 7.6.5. The lint baseline is clean, so
any finding introduced later in this plan is attributable to the change under test.
