# PowerShell Format (P8-T1)

Timestamp: 2026-09-28T22-17
Command: sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 <4 files> (before) ; mcp__drm-copilot__run_poshqc_format (workspace_root = repository root, scan_folders = .claude/lib/ci-gate, tests/scripts/claude-lib/ci-gate, scripts/powershell/PoshQC/settings) ; sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 <4 files> (after) ; sh SCRATCH/run-ps.sh SCRATCH/ps-format-check.ps1 <4 files>
EXIT_CODE: 0
Output Summary:
- The MCP format call returned without raising (`ok: true`; its result carries no formatter output, only a summary sentence).
- The before and after SHA-256 hashes are identical for all four files (`cmp` exit 0), so the formatter rewrote nothing.
- A6 printed `FORMAT-SUMMARY ChangedCount=0`, with every file `Changed=False`.

```text
.claude/lib/ci-gate/Invoke-CiGateParser.ps1 Hash=DDC342CB254A9AF28BD9F52957933A82A5D150553613B7272DC733495CB3D34A
tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 Hash=98493410DC0745EA336A080678CF8F91AF2D9E3E85BFB4503E75D64D2053C026
tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1 Hash=3DC8687F953CDC26765C229A1F4F57BB1871835C65D51238B8B0D2FB33DB7E94
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 Hash=3DC93E54874251C032E7AA7CC3F61159FA9E856FE40E15CF2ED2CEDBEB871CD6
```
