# Baseline — PowerShell Analyzer (P0-T5)

Timestamp: 2026-08-08T21-34

Task: [P0-T5] Capture PowerShell analyzer baseline.

Feature: `docs/features/active/2026-08-07-parallel-mutation-protocol-442` (issue #442)
Branch: `feature/parallel-mutation-protocol-442`
HEAD at capture time: `c939b5b80c8c297db49febaebdd35dda2c869a3f`

Command: MCP tool `mcp__drm-copilot__run_poshqc_analyze` with
`workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3b16f891ab2f782c`
(no `scan_folders` argument, so the scan set resolves from `config/poshqc-scan.json`)

EXIT_CODE: 0

## Raw Output

```json
{
  "ok": true,
  "tool": "run_poshqc_analyze",
  "workspace_root": "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3b16f891ab2f782c",
  "summary": "Ran bundled PoshQC analyze against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3b16f891ab2f782c'."
}
```

## Finding Count: 0

The MCP response does not print a finding count, so the count is established from the analyzer's
own contract rather than asserted. `Invoke-PoshQCAnalyze` in
`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` is throw-on-any-finding:

```powershell
    if ($results.Count -gt 0) {
        $results | Format-Table -AutoSize
        throw "PSScriptAnalyzer reported $($results.Count) issue(s)."
    }
    & $Logger "PSScriptAnalyzer passed: no findings under $Root"
```

(`PoshQC.Analyzer.psm1`, lines 181-185.) Any finding at Error, Warning, or Information severity
raises a terminating error, which would surface as a failed MCP call rather than `ok: true`. The
analyzer ran to completion and returned `ok: true`, therefore `$results.Count == 0` and the
`PSScriptAnalyzer passed: no findings` branch was taken.

| Metric | Baseline value |
| --- | --- |
| Analyzer findings (Error) | 0 |
| Analyzer findings (Warning) | 0 |
| Analyzer findings (Information) | 0 |
| Total findings | **0** |
| Severities scanned | Error, Warning, Information (`PoshQC.Analyzer.psm1:101`) |

Settings source: repository PSScriptAnalyzer settings under
`scripts/powershell/PoshQC/settings/`. Scan set: resolved from `config/poshqc-scan.json`.

Output Summary: `mcp__drm-copilot__run_poshqc_analyze` returned `ok: true` with exit code 0 and
**0 analyzer findings** across the configured scan set at Error, Warning, and Information severity.
The zero count is established by the analyzer's throw-on-any-finding contract
(`PoshQC.Analyzer.psm1:181-185`), under which a non-zero finding count cannot return `ok: true`.
There is no pre-existing PSScriptAnalyzer debt for this feature to inherit, so the P5-T5 and P7-T6
analyzer gates must also report zero findings.
