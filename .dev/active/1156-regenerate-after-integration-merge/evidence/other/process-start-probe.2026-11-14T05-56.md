# Process Start Probe — batch-shim edge cases (feature review, remediation cycle 1 re-audit)

Timestamp: 2026-11-14T05-56
Command: sh SCRATCH/issue-1156-cmdprobe.sh (Windows host, PowerShell 7 from the item worktree root; dot-sources `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` at head 6bb6365d1 and calls `Invoke-RegenerationProcess -Argv <argv>` with the default invoker; each probe batch file under SCRATCH echoes `%*`, `%1`, and `%2` and exits 7)
EXIT_CODE: 0
Output Summary:
- Resolved batch path without spaces: one Int32 equal to 7; the batch file received `run build` unchanged.
- Resolved batch path containing a space (`p q`): one Int32 equal to 7; arguments unchanged.
- Resolved batch path containing a space and parentheses (`p (x86)`): one Int32 equal to 7; arguments unchanged.
- Arguments `--x=1` and `a,b;c`: one Int32 equal to 7; `%*` received `--x=1 a,b;c` unchanged, while `%1` and `%2` were `--x` and `1` (cmd.exe treats `=`, `,`, and `;` as batch parameter delimiters). A batch shim that forwards `%*`, as npm.cmd does, receives the text unchanged.
- Argument `a!b`: one Int32 equal to 7; received unchanged (delayed expansion is off under `/d`).
- Argument `%PATH%`: refused before any start with `batch file argument '%PATH%' holds whitespace, a quote, or a cmd.exe metacharacter`.
- `node -e "process.exit(3)"` (an `.exe` application): one Int32 equal to 3.
- Resolved batch paths whose directory names contain `&` (`a&b`, `a b&c`) or `%` (`pct%OS%`): each returned one Int32 equal to 1 without running the batch file. For `a&b`, cmd.exe split the command line at `&` and tried to run the path prefix and then `b\bin\echoargs.cmd` relative to the working directory; for `%OS%`, the variable was expanded and the path was not found. `Get-RegenerationProcessStartSpec` screens the arguments but not the resolved path, so a path holding a cmd.exe metacharacter is not refused.
- stdout of each probe held only the probe's summary lines; the child output reached stderr.
