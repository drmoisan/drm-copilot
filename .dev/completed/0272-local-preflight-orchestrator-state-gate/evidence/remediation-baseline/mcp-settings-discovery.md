## MCP Settings Discovery — Remediation Cycle 1 (Issue #272)

**Timestamp:** 2026-07-02T20-35
**Command:**
```powershell
Get-ChildItem -Path @("$env:USERPROFILE\.vscode-server-insiders", "$env:USERPROFILE\.vscode-insiders", "$env:APPDATA\Code - Insiders") -Recurse -Filter 'pester.runsettings.psd1' -ErrorAction SilentlyContinue
```
**EXIT_CODE:** 0
**Output Summary:**
Searched directories (all exist):
- `C:\Users\DanMoisan\.vscode-server-insiders`
- `C:\Users\DanMoisan\.vscode-insiders`
- `C:\Users\DanMoisan\AppData\Roaming\Code - Insiders`

Four non-repo-tracked copies of `pester.runsettings.psd1` were discovered:
1. `C:\Users\DanMoisan\.vscode-server-insiders\extensions\danmoisan.drm-copilot-0.0.2\resources\powershell\PoshQC\settings\pester.runsettings.psd1`
2. `C:\Users\DanMoisan\.vscode-server-insiders\extensions\danmoisan.drm-copilot-0.0.6\resources\powershell\PoshQC\settings\pester.runsettings.psd1`
3. `C:\Users\DanMoisan\.vscode-insiders\extensions\danmoisan.drm-copilot-1.0.2\resources\powershell\PoshQC\settings\pester.runsettings.psd1`
4. `C:\Users\DanMoisan\.vscode-insiders\extensions\undefined_publisher.drm-copilot-0.0.1\resources\powershell\PoshQC\settings\pester.runsettings.psd1`
