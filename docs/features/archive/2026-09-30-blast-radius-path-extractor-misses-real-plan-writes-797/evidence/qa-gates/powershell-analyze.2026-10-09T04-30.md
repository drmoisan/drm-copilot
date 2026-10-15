# PowerShell Analyzer Counts, Final (P7-T4, AC-18)

Timestamp: 2026-10-09T04-30
Command: substitute for the P0-T16 Invoke-ScriptAnalyzer loop: mcp__drm-copilot__run_poshqc_analyze scan_folders [".claude/lib/blast-radius", "tests/scripts/claude-lib/blast-radius"] (the P7-T3 call)
EXIT_CODE: 0
Output Summary: substitute evidence. The analyzer returned ok:true over both folders, which contain the four P0-T16 files; the run writes no output file, so per-file `Findings=` integers are unavailable and are not inferred. Baseline (P0-T16) was also ok:true, so no file's result is above its baseline.

## Deviation (PowerShell route denied)

The exact P0-T16 command needs the PowerShell tool or inline `pwsh`; inline `pwsh` is denied by the worktree-isolation hook (denial text recorded in evidence/baseline/requirements-source.2026-10-09T02-51.md). Per operator constraint 3, AC-18 is reported PARTIAL pending CI evidence.
