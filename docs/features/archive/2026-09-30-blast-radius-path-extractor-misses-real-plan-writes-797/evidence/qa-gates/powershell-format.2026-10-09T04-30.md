# PowerShell Formatting Without Rewriting, Final (P7-T2, AC-18)

Timestamp: 2026-10-09T04-30
Command: substitute for the P0-T15 Invoke-Formatter comparison: the P7-T1 PoshQC formatter run bracketed by SHA256 listings (evidence/qa-gates/poshqc-format.2026-10-09T04-30.md)
EXIT_CODE: 0
Output Summary: substitute evidence. The formatter returned ok:true and the four P0-T15 files hash identically before and after, which is the tree-observation equivalent of four `True` lines:
  .claude/lib/blast-radius/BlastRadiusExtraction.psm1 True
  .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 True
  tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 True
  tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 True

## Deviation (PowerShell route denied)

The exact P0-T15 command needs the PowerShell tool or inline `pwsh`; inline `pwsh` is denied by the worktree-isolation hook (denial text recorded in evidence/baseline/requirements-source.2026-10-09T02-51.md). Per operator constraint 3, AC-18 is reported PARTIAL pending CI evidence.
