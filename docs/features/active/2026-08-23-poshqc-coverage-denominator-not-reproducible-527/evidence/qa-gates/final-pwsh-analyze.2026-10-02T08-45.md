# Final PowerShell Analyze Gate (P6-T3)

Timestamp: 2026-10-02T08-45
Command: CI-evidence deviation DEV-P6-T3 (replaces `Invoke-PoshQCAnalyze -Root (Get-Location).Path -GetFileList { <ten CHANGED_PS .ps1/.psm1 files> }` in a `pwsh` child). Source: run A https://github.com/drmoisan/drm-copilot/actions/runs/36983551836, job https://github.com/drmoisan/drm-copilot/actions/runs/36983551836/job/110763341194, step `Analyze PowerShell` (`Invoke-PoshQCAnalyze -Root <CI_ROOT>` over the whole repository, a superset of the ten files, branch copy of PoshQC at a987ebfb); confirmed by run B https://github.com/drmoisan/drm-copilot/actions/runs/36984586891 (job log line 822). Route-compliance call: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` = `<ROOT>` and `scan_folders` `["scripts/powershell/PoshQC","tests/scripts/powershell/PoshQC","tests/fixtures/poshqc-consumer"]`.
EXIT_CODE: 0
Output Summary: run A job log line 830: `PSScriptAnalyzer passed: no findings under <CI_ROOT>`; the step concluded success (no `##[error]` line in the Format, Analyze, or Test steps). MCP call returned `ok: true` (installed extension copy; not acceptance evidence, D10); `git status --porcelain --untracked-files=all` was empty after it.
- Acceptance: EXIT_CODE 0 and the output contains `PSScriptAnalyzer passed: no findings under`. Met.

## MCP summary string (root replaced by `<ROOT>`)

```text
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"<ROOT>","summary":"Ran bundled PoshQC analyze against '<ROOT>' with 3 selected scan folder(s)."}
```
