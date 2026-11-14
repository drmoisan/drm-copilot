# Process Start Probe — batch path screen (remediation cycle 2, [P1-T3])

Timestamp: 2026-11-14T06-36
Command: sh SCRATCH/issue-1156-probe.sh (Windows host; PowerShell 7 from the item worktree root dot-sources `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` at the [P1-T2] head; creates SCRATCH/probe/ with the folders `amp&dir`, `pct%OS%dir`, and `p (x86) q`, each holding `probe.cmd`, which writes `marker.txt` into its own folder via `%~dp0`; calls `Invoke-RegenerationProcessStep -Argv @(<absolute probe.cmd path>, 'x')` with the default invoker, capturing [Console]::Error to a SCRATCH file per folder)
EXIT_CODE: 0
Output Summary:
- `amp&dir`: Started False, ExitCode null, no marker file. stderr: `process SCRATCH\probe\amp&dir\probe.cmd x cannot be started: batch file path 'SCRATCH\probe\amp&dir\probe.cmd' holds a quote or a cmd.exe metacharacter`.
- `pct%OS%dir`: Started False, ExitCode null, no marker file. stderr: `process SCRATCH\probe\pct%OS%dir\probe.cmd x cannot be started: batch file path 'SCRATCH\probe\pct%OS%dir\probe.cmd' holds a quote or a cmd.exe metacharacter`.
- `p (x86) q`: Started True, ExitCode 0, marker file present (the batch file ran through ComSpec /d /c with the quoted path containing a space and parentheses).
- Result: all acceptance conditions hold. Compared with `process-start-probe.2026-11-14T05-56.md`, the `&` and `%` paths are now refused before any start instead of running a different command line. This is a verification step on a real process, not a unit test; no tracked file was written.
