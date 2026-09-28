# Batch A Line Counts Against The 500-Line Cap

Timestamp: 2026-09-08T02-44

Task: [P1-T10]

Command:
`wc -l .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1 tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1`

EXIT_CODE: 0

`pwsh` cannot be invoked in this worktree, so the `Get-Content`-based measurement the repository's
own convention test uses cannot be run here directly. `wc -l` is the substituted command. Both files
end with a newline byte, verified with `tail -c 1 | od -c` (each returned `\n`), so a
`Get-Content`-based count returns the same integer as `wc -l` for each file and the substitution
changes the tool rather than the observation.

## Measured counts

| File | Lines | Cap | Within cap |
| --- | --- | --- | --- |
| `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | **415** | 500 | **yes**, 85 lines of headroom |
| `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1` | **152** | 500 | **yes**, 348 lines of headroom |

## Independent confirmation from the suite run

`tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` discovers every `.claude/lib/**/*.psm1`
from disk and carries `It 'keeps every claude library module within the five hundred line limit'`,
which counts physical lines with `Get-Content` rather than `Measure-Object -Line`. That suite ran
inside the [P1-T8] full-suite run with the new module in the discovered set and reported no failure,
so the repository's own measurement agrees with the counts above.

Output Summary: Both Batch A files are within the 500-line cap. The new module measures **415**
lines and its unit suite **152** lines, each confirmed to end with a newline byte so the `wc -l`
substitution matches a `Get-Content` count exactly. The repository's own 500-line convention test
passed for the module in the [P1-T8] run. Contributes to AC-27, which additionally covers both gate
hooks and both changed gate suites and is therefore not checked off here.
