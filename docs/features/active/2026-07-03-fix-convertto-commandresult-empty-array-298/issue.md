# fix-convertto-commandresult-empty-array (Issue #298)

- Date captured: 2026-07-03
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/fix-convertto-commandresult-empty-array/ (Issue #298)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #298
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/298
- Last Updated: 2026-07-04
- Work Mode: minor-audit

## Summary

The VS Code task "Release: Automate Full Release Flow" (`scripts/dev-tools/Invoke-FullReleaseFlow.ps1`) fails immediately on a clean working tree because its internal `ConvertTo-CommandResult` helper rejects an empty array as a Mandatory argument, which is exactly the value produced by a successful `git status --porcelain` call on a clean tree.

## Environment

- OS/version: Windows, PowerShell 7 (`pwsh`)
- Command/flags used: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/dev-tools/Invoke-FullReleaseFlow.ps1 -ConfirmToken yes`
- Data source or fixture: Live git repository with a clean working tree on branch `main`.

## Steps to Reproduce

1. Ensure the working tree is clean (`git status --porcelain` produces no output).
2. Run the VS Code task "Release: Automate Full Release Flow" (or invoke the script directly with `-ConfirmToken yes`).
3. Observe the script fail at the very first `git status --porcelain` precondition check.

## Expected Behavior

The script should proceed past the clean-working-tree check (git produced zero lines of output, which correctly means "clean") and continue with the release flow.

## Actual Behavior

```
ConvertTo-CommandResult: C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-03-11-04\scripts\dev-tools\Invoke-FullReleaseFlow.ps1:81:44
Line |
  81 |      return ConvertTo-CommandResult -Output $output -ExitCode $LASTEXI …
     |                                             ~~~~~~~
     | Cannot bind argument to parameter 'Output' because it is an empty
     | array.
Failed to read git status (git exit code ).
```

The terminal task exits with code 1.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see "Actual Behavior" above.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Blocks the automated full release flow entirely on the single most common precondition state (a clean working tree), which is the expected starting state for every release run.

## Suspected Cause / Notes

Root cause confirmed empirically (standalone `pwsh` repro reproduced the identical error text from a Mandatory `[object[]]` parameter bound to `@()`):

- `ConvertTo-CommandResult` (`scripts/dev-tools/Invoke-FullReleaseFlow.ps1:53-65`) declares `[Parameter(Mandatory = $true)] [object[]]$Output` with no `[AllowEmptyCollection()]` attribute.
- PowerShell's mandatory-parameter binder treats an empty array the same as `$null` for array-typed Mandatory parameters and rejects the call with "Cannot bind argument to parameter 'Output' because it is an empty array."
- `Invoke-GitExe` (lines 67-82) computes `$output = @(& git @GitArgs 2>&1)`. When `git status --porcelain` runs on a clean tree it emits zero lines, so `$output` is `@()`, and the subsequent `ConvertTo-CommandResult -Output $output -ExitCode $LASTEXITCODE` call throws.
- Because the error is non-terminating (default `$ErrorActionPreference`) and uncaught, `Invoke-GitExe` returns `$null` to the caller. Back in `Invoke-FullReleaseFlowGuarded`, `$status.ExitCode` on a `$null` object evaluates to `$null`, and `$null -ne 0` is `$true`, so the guard at line 164 fires and prints "git exit code " with an empty value -- matching the reported message exactly.
- The same defect affects every other `Invoke-GitExe` / `Invoke-GhExe` call whose underlying command can legitimately produce zero lines of output (e.g., `git fetch`, `git checkout`, `git pull`, `gh pr merge` with quiet output), not only `git status --porcelain`.
- The existing Pester suite (`tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`) mocks `Invoke-GitExe`/`Invoke-GhExe` directly, so it never exercises the real `ConvertTo-CommandResult` empty-array path, which is why this regression was not caught by the test suite.

## Proposed Fix / Validation Ideas

- [x] Add `[AllowEmptyCollection()]` to the `$Output` parameter of `ConvertTo-CommandResult` so a zero-line command result is accepted and represented as an empty array rather than rejected.
- [x] Unit coverage areas: add a direct Pester case asserting `ConvertTo-CommandResult -Output @() -ExitCode 0` does not throw and returns `Output.Count -eq 0`.
- [x] Manual verification notes: re-run the toolchain (PoshQC format/analyze, Pester) and confirm the fix does not change behavior for any non-empty-output call site.

## Acceptance Criteria

- [x] `ConvertTo-CommandResult` in `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` accepts `-Output @()` (an empty array) without throwing a parameter-binding error.
- [x] The `$Output` parameter's type (`[object[]]`), mandatory-ness, and all other function signatures in `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (`Invoke-GitExe`, `Invoke-GhExe`, `Invoke-ChildPowerShellScript`, etc.) remain unchanged; only `[AllowEmptyCollection()]` is added to `$Output`.
- [x] `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` contains a new `It` case in the existing "helpers" `Context` block asserting `ConvertTo-CommandResult -Output @() -ExitCode 0` does not throw and returns `Output.Count -eq 0` and `ExitCode -eq 0`.
- [x] No other test in `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` is modified.
- [x] PoshQC format, PoshQC lint (analyze), and Pester tests all pass cleanly for the two in-scope files after the change.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
