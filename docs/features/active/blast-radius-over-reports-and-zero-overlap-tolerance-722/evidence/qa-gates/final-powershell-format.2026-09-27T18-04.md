# Final PowerShell Format (P16-T1)

Timestamp: 2026-09-27T18-04
Command: sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 <the ten B40 files> ; mcp__drm-copilot__run_poshqc_format (workspace_root = repository root, scan_folders = the ten B40 files) ; sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 <the ten B40 files>
EXIT_CODE: 0
Output Summary: PASS. Both file-hashes runs exited 0. The MCP format call returned without raising ({"ok":true, ..., "summary":"Ran bundled PoshQC format ... with 10 selected scan folder(s)."}). All ten SHA256 hashes are identical before and after the call, and git status --porcelain printed nothing afterwards, so the formatter changed no file. No mirror re-copy was required and Phase 16 does not restart; the mirrors-final artifact of P14-T6 (FEATURE/evidence/qa-gates/mirrors-final.2026-09-27T17-58.md, every pair equal) remains current.

## Hashes before and after

| B40 file | Hash before | Hash after | Changed |
| --- | --- | --- | --- |
| .claude/lib/blast-radius/BlastRadiusScheduling.psm1 | 50F8AE215463F0B53A8E23CAFF8EE8D829CD003ADBA67C75D53C515A60F2CE24 | 50F8AE215463F0B53A8E23CAFF8EE8D829CD003ADBA67C75D53C515A60F2CE24 | no |
| .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 | E0BA0AA43F80B497A94C3EEFA8A7C98EFBEE7943E3C31697AB3237457C13A33E | E0BA0AA43F80B497A94C3EEFA8A7C98EFBEE7943E3C31697AB3237457C13A33E | no |
| .claude/lib/blast-radius/BlastRadius.psm1 | 5D41E44410209242FA0E18EE337A176455CDA0724675ECD25A572F4F8D099400 | 5D41E44410209242FA0E18EE337A176455CDA0724675ECD25A572F4F8D099400 | no |
| .claude/lib/blast-radius/BlastRadiusValidation.psm1 | B323355B234C8CF079265CB0484E17B38E59AAA94FAC1C15A355D52EAD45C2A1 | B323355B234C8CF079265CB0484E17B38E59AAA94FAC1C15A355D52EAD45C2A1 | no |
| tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 | 27B74F59BD95F5B93A9F1DFDE880E670041E408C2C12EE0E0633D757CEDA6404 | 27B74F59BD95F5B93A9F1DFDE880E670041E408C2C12EE0E0633D757CEDA6404 | no |
| tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 | 1AB0C0CB8763964E9B557A901107B0390F6D93D23C7E9DCC9826666E4623A8E0 | 1AB0C0CB8763964E9B557A901107B0390F6D93D23C7E9DCC9826666E4623A8E0 | no |
| tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 | CD1EAE0EC39E2D3FA01FDDFBA39D0C43CE13C9C53EF1E7AF08B237DD043B29BF | CD1EAE0EC39E2D3FA01FDDFBA39D0C43CE13C9C53EF1E7AF08B237DD043B29BF | no |
| tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 | F5D60BFE436B136FD88485C72C41AC48249F6F36AA7CF46BCB1310C57324BA89 | F5D60BFE436B136FD88485C72C41AC48249F6F36AA7CF46BCB1310C57324BA89 | no |
| tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 | F4470BCCA6938018304B4B2FD83D9BC1B082DC5B4AF91DBE6E4C11C9094D6781 | F4470BCCA6938018304B4B2FD83D9BC1B082DC5B4AF91DBE6E4C11C9094D6781 | no |
| scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | 323C6BB5A1E577A0CEEDB8070DB831D8D4F3FE94AE0A403ECDCEDE235333D080 | 323C6BB5A1E577A0CEEDB8070DB831D8D4F3FE94AE0A403ECDCEDE235333D080 | no |

## MCP call result

```text
{"ok":true,"tool":"run_poshqc_format","workspace_root":"<repository root>","summary":"Ran bundled PoshQC format against '<repository root>' with 10 selected scan folder(s)."}
```

The workspace root is replaced by a placeholder so that no host path is recorded. The PoshQC MCP tools
return no formatter output or exit code; the hash comparison is the observation of whether files changed.

SCRATCH denotes the executor session scratchpad directory (outside the repository).
