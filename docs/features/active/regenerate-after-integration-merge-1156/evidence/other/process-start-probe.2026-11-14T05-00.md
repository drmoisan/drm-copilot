# Process Start Probe — R2 verification after the fix (cycle 1, [P1-T6])

Timestamp: 2026-11-14T05-00
Command: sh SCRATCH/issue-1156-probe.sh (Windows host, PowerShell 7 from the worktree root; dot-sources `.claude/lib/regeneration/Invoke-RegenerationPath.ps1`; calls `Resolve-RegenerationExecutable -Name npm`, then `Invoke-RegenerationProcess -Argv @('npm','--version')` with the default invoker, then `Invoke-RegenerationProcess -Argv @('issue1156-no-such-tool','--version')` inside try/catch; stdout and stderr captured to separate SCRATCH files)
EXIT_CODE: 0
Output Summary:
- stdout holds exactly one line, the probe summary: `PROBE resolved-leaf=npm.cmd returned-count=1 type=Int32 value=0 unresolved-message=executable issue1156-no-such-tool cannot be resolved`.
- `npm` resolves to `npm.cmd` and runs through ComSpec `/d /c`; the default invoker returns exactly one `[int]` equal to 0.
- The unresolvable name throws `executable issue1156-no-such-tool cannot be resolved`.
- stderr holds the forwarded child output (`11.20.0` and an empty stderr line), as the default forwards both streams to `[Console]::Error`.
- The reviewer's probe `process-start-probe.2026-11-14T04-29.md` (fail-before: `npm --version` threw) is not edited.
