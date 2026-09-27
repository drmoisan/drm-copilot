# Final PowerShell Analyze (P16-T3)

Timestamp: 2026-09-27T18-19
Command: mcp__drm-copilot__run_poshqc_analyze (workspace_root = repository root, scan_folders = the ten B40 files)
EXIT_CODE: 0
Output Summary: PASS. The MCP analyze call over the ten B40 files returned without raising ({"ok":true, ..., "summary":"Ran bundled PoshQC analyze ... with 10 selected scan folder(s)."}). No finding was raised, so no file was edited, no mirror was re-copied, and Phase 16 does not restart.

## MCP call result

```text
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"<repository root>","summary":"Ran bundled PoshQC analyze against '<repository root>' with 10 selected scan folder(s)."}
```

Scanned files:

```text
.claude/lib/blast-radius/BlastRadiusScheduling.psm1
.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1
.claude/lib/blast-radius/BlastRadius.psm1
.claude/lib/blast-radius/BlastRadiusValidation.psm1
tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1
tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1
scripts/powershell/PoshQC/settings/pester.runsettings.psd1
```

The workspace root is replaced by a placeholder so that no host path is recorded. The PoshQC MCP tools
return no analyzer output; whether the call returns or raises is the only observable signal, as the
plan's command catalogue states.
