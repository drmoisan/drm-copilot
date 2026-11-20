# Baseline PowerShell Format (P0-T10)

Timestamp: 2026-10-01T16-02
Deviation: D2. SP1 was not written or run. The PoshQC MCP formatter ran instead, bracketed by `git status --porcelain`.

Command: git status --porcelain
EXIT_CODE: 0
Output Summary (before): ` M <FEATURE>/plan.2026-09-30T03-15.md` and `?? <FEATURE>/evidence/` (execution bookkeeping only).

Command: mcp__drm-copilot__run_poshqc_format (workspace_root = <REPO_ROOT>)
EXIT_CODE: 0
Output Summary: `ok: true`; summary `Ran bundled PoshQC format against '<REPO_ROOT>'.` The tool returns no `Formatted:` or `Already formatted:` counts.

Command: git status --porcelain
EXIT_CODE: 0
Output Summary (after): identical to the before listing; the MCP formatter changed no tracked file.

FORMAT-DRIFT: NONE

CI corroboration (run 36890793420, job `PowerShell QC` 110465608484, head 7282fb31153adb4d3449e5653d64c6b50e09de75): step `Format PowerShell` concluded `success`. Within that step the log carries 593 lines beginning `Already formatted: ` and 0 lines beginning `Formatted: `. The baseline `Formatted:` set is empty.
