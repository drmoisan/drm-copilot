# No Temporary Files: AC-32 and RS-19 (issue #673, closing #672)

Timestamp: 2026-09-19T19-15

Command: `git diff --name-only b7c1161655b4b53b0358dc7890a26200207c4b91 HEAD` filtered to `tests/scripts/**/*.ps1`; then `Select-String -SimpleMatch` for each forbidden token across the resulting 17 files; then per-token counts for the two prd suites, with the `Resolve-Path` occurrences classified by their argument.

EXIT_CODE: 0

## Token scan across every test file this plan added or modified

TEST_FILES: 17

| Token | Occurrences |
| --- | --- |
| `New-TemporaryFile` | **0** |
| `GetTempPath` | **0** |
| `GetTempFileName` | **0** |
| `TestDrive` | **0** |
| `$env:TEMP` | **0** |

Zero token matches, which is the first acceptance condition.

## `$env:CLAUDE_TOOL_INPUT` assignments

**None.** No test file this plan added or modified assigns that variable, so the condition that every such assignment sit in a `try` whose `finally` restores it is satisfied over an empty set. Every suite drives its gate by passing the payload to the decision entrypoint as a parameter instead of through the environment, which is why no assignment exists to guard.

## `Set-Location` and `CurrentDirectory` assignments

Five occurrences, all in one file and all inside one function:

| Location | Line |
| --- | --- |
| `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1:68` | `$previousCurrentDirectory = [System.Environment]::CurrentDirectory` |
| `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1:70` | `Set-Location -LiteralPath $WorkingDirectory` |
| `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1:71` | `[System.Environment]::CurrentDirectory = $WorkingDirectory` |
| `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1:75` | `Set-Location -LiteralPath $previousLocation` |
| `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1:76` | `[System.Environment]::CurrentDirectory = $previousCurrentDirectory` |

Enclosing construct, verified by reading the function:

```
    $previousLocation = (Get-Location).Path
    $previousCurrentDirectory = [System.Environment]::CurrentDirectory
    try {
        Set-Location -LiteralPath $WorkingDirectory
        [System.Environment]::CurrentDirectory = $WorkingDirectory
        return (& $ScriptBlock)
    }
    finally {
        Set-Location -LiteralPath $previousLocation
        [System.Environment]::CurrentDirectory = $previousCurrentDirectory
    }
```

Both values are captured before the `try`, both are set inside it, and both are restored in the `finally`, so a row that throws cannot leak its directory change into the next row. Both must be set because the two are independent: the gate's `Test-Path` calls follow the PowerShell location while `[System.IO.File]::ReadAllBytes` follows the .NET one, and a wrapper that set only the first would read body bytes from the wrong directory.

Every occurrence sits in `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1` inside a `try` whose `finally` restores both, which is the second acceptance condition. No occurrence appears in a child-process script string, because no suite spawns one.

## The five counted tokens in the two prd suites

| Token | `TargetResolution.Tests.ps1` | `IdentityResolution.Tests.ps1` |
| --- | --- | --- |
| `Set-Location` | **0** | **0** |
| `CurrentDirectory` | **0** | **0** |
| `Get-Location` | **0** | **0** |
| `Resolve-Path` whose argument is not a dot-sourced hook path or an imported module path | **0** | **0** |
| `git ` in a command position | **0** | **0** |

All five counts are 0 for both suites.

The `Resolve-Path` row is a classified count rather than a raw one, because both suites legitimately use it. `TargetResolution.Tests.ps1` has four occurrences and `IdentityResolution.Tests.ps1` three; every one resolves either a dot-sourced hook path (`enforce-prd-feature-before-planner.ps1`, `enforce-prd-feature-before-planner-helpers.ps1`) or a worktree-resolution module path, which the acceptance condition permits. Zero fall outside that set.

`Get-Location` is counted separately from the other directory tokens because it is the one remaining way a row in these two suites could derive a path from the current directory, and the other four tokens would not catch it. It occurs zero times in both.

## RS-19: issue #672's test-hygiene criterion, re-asserted

Issue #672's spec requires its suite to create no temporary file or directory, to leave the process working directory unchanged, and to derive no absolute path from the environment, the current directory, the script file location, or a source-control query. That criterion is re-asserted here over the suite as Phase 9 leaves it **and** over the new identity suite:

- Neither creates a file or directory: all five temp tokens are 0 across all 17 files.
- Neither changes the process working directory: `Set-Location` and `CurrentDirectory` are 0 in both.
- Neither derives a path from the environment or the current directory: `Get-Location` is 0 in both, and no `$env:` path read appears.
- Neither derives a path from a source-control query: `git ` in a command position is 0 in both.
- Neither derives a path from the script file location for use as a synthetic root: both keep bare-literal synthetic roots. The identity suite composes one family of roots from a bare literal and a loop index, which reads nothing from the host.
- The modelled directory is supplied as data on an injected result, not read from the process.

`tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1` is not used by either prd suite, so the one wrapper that does change a directory is outside their scope entirely.

Output Summary: Zero matches for all five forbidden tokens across the 17 test files this plan added or modified. There are no `$env:CLAUDE_TOOL_INPUT` assignments to guard. The five directory-changing statements all sit in one helper function, inside a `try` whose `finally` restores both location values. All five counted tokens are 0 for both prd suites, with the `Resolve-Path` count classified by argument, so issue #672's test-hygiene criterion holds over the migrated suite and the new one alike.
