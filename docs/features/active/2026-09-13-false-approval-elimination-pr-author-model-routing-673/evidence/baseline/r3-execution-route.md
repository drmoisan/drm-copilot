# Fresh-Process Execution Route (issue #673)

Timestamp: 2026-09-19T17-25

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-probe.ps1`, launched with the executing worktree as the working directory.

EXIT_CODE: 0

ROUTE_SELECTED: a

Probe script body (`<SCRATCHPAD>/r3-probe.ps1`, repository-relative paths only; it names no path at all and derives both values at run time):

```
$ErrorActionPreference = 'Stop'
Write-Output ("PSVersion: {0}" -f $PSVersionTable.PSVersion)
$sep = [string][char]92
$here = (Get-Location).Path.Replace($sep, '/').TrimEnd('/')
$top = (& git rev-parse --show-toplevel).Replace($sep, '/').TrimEnd('/')
Write-Output ("LocationIsWorktreeRoot: {0}" -f ($here -eq $top))
```

Probe output:

```
PSVersion: 7.6.6
LocationIsWorktreeRoot: True
```

Route-establishment note: route `a` was attempted first and was not refused, so route `a-prime` was never needed and no refusal text exists to record. An earlier authoring attempt at the same script failed on a shell-quoting defect in how the script was written to the scratchpad, not on a refusal of the route: a backslash in a regular-expression literal was lost in transit, so the script raised `The regular expression pattern \ is not valid.` The script was rewritten to compose the separator as `[string][char]92` and to use `String.Replace` instead of `-replace`, which removes the quoting hazard entirely. That failure is recorded because it is the reason this artifact's script body differs in form from the plan's description, and because the same hazard governs how every later runner script in this plan is written.

Output Summary: Route `a` is available. A fresh `pwsh -NoProfile -File` process runs at PowerShell 7.6.6 and reports `LocationIsWorktreeRoot: True`, so a fresh process launched this way starts in the executing worktree root and repository-relative paths resolve correctly inside it. Neither the worktree root nor the scratchpad directory is written anywhere in this artifact. Every later PowerShell toolchain task in this plan uses route `a`.
