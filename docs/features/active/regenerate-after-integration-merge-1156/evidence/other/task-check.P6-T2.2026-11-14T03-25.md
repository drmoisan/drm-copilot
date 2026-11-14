# Task check — [P6-T2] pre-gate fix (orchestrator decision AD-1)

Timestamp: 2026-11-14T03-25
Command: sh SCRATCH/issue-1156-tc-p6t2.sh (Invoke-Formatter drift comparison and Invoke-ScriptAnalyzer with pssa.settings.psd1 on the three changed PowerShell files); TC_PATHS="tests/scripts/claude-lib/regeneration;tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1" sh SCRATCH/issue-1156-tc-pester.sh (Run.Path = selection, exit = FailedCount)
EXIT_CODE: 0
Output Summary: format drift 0 files, PSSA findings 0; Pester selection 315 passed, 0 failed, 0 skipped. Not a gate; no coverage measured.

## Reason for the change

Pester final gate run 1 (`evidence/qa-gates/pester-final.2026-11-14T03-18.md`) failed `enforcement-hooks-no-python-invocation.Tests.ps1` because the `-Invoker` default of `Invoke-RegenerationProcess` invoked the non-scriptblock variable `$FilePath` with the call operator (DynamicInvocation), while the plan's check (h) required exactly that shape. The orchestrator recorded autonomous decision AD-1 (option B): the allowlist and its "ships exactly the D3 allowlist entry" test stay unchanged, the entry point is not moved, and the process default starts the argv through `[System.Diagnostics.ProcessStartInfo]` and `[System.Diagnostics.Process]::Start`, following `Invoke-DocsProcess` in `.claude/lib/docs/Invoke-DocsCommand.ps1`.

## Changed files

- `.claude/lib/regeneration/Invoke-RegenerationPath.ps1`: the `-Invoker` default of `Invoke-RegenerationProcess` builds one `ProcessStartInfo` from `$FilePath`, adds each `$ArgumentList` item to `ArgumentList` (no shell, no command-line string), sets `UseShellExecute = $false` and both redirects to `$true`, starts with `[System.Diagnostics.Process]::Start`, reads stdout and stderr with `ReadToEndAsync` before `WaitForExit()`, writes both texts with `[Console]::Error.WriteLine`, returns `[int] $process.ExitCode`, and disposes the process. A start failure throws (Process.Start throws, or a null process throws), so `Invoke-RegenerationProcessStep` reports `Started = $false`. The function contract is unchanged: exactly one integer returned, an empty argv throws before any invocation.
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/Invoke-RegenerationPath.ps1`: byte copy of the source (cmp equal). No pinned hash covers the file; its `pack-manifests/core.json` entry is path-only and unchanged.
- `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1`: the check (h) test is renamed and rewritten (below).

## Assertion change (implements AD-1)

Old test: `(h) the process -Invoker default pipes one call-operator invocation to [Console]::Error.WriteLine and reads $LASTEXITCODE`.
New test: `(h) the process -Invoker default starts one ProcessStartInfo with UseShellExecute false, forwards output to [Console]::Error.WriteLine and returns ExitCode`.

The old assertion pinned the call-operator shape that the repository-wide no-Python scan rejects, so both could not pass. AD-1 replaces the start mechanism; the new assertion pins the new default by AST: exactly one static `[System.Diagnostics.ProcessStartInfo]::new` taking `$FilePath`; exactly one `[System.Diagnostics.Process]::Start`; exactly one `$info.ArgumentList.Add` taking `$item` inside exactly one `foreach` over `$ArgumentList`; `$info.UseShellExecute` assigned `$false` once; both redirects assigned `$true` once; two `ReadToEndAsync` calls and one `WaitForExit`; exactly two `[Console]::Error` write calls; exactly one `ExitCode` member read on `$process`; and zero `CommandAst` nodes in the default (stronger than zero call-operator invocations: it also excludes any cmdlet process start and `Invoke-Expression`). The test `(h) no seam default writes to the success or host stream` is unchanged and passes. No other assertion was changed or weakened.

## Tests asserting the old default, with disposition

Search: `Invoke-RegenerationProcess`, `call-operator`, `LASTEXITCODE`, and `Invoke-RegenerationPath.ps1` across `tests/`.

- `Invoke-RegenerationPath.Tests.ps1`, the process (h) test: updated as above (AD-1).
- `Invoke-RegenerationPath.Tests.ps1`, `(h) the git -Invoker default runs one git command with only the splatted GitArgs and reads $LASTEXITCODE`: unchanged; it pins the git seam, which this change does not touch.
- `Invoke-RegenerationPath.Tests.ps1`, `Describe 'Invoke-RegenerationProcess seam'` cases: unchanged; they inject their own `-Invoker` and assert the wrapper contract (argv split, integer return, empty argv throws, extra output throws, start failure propagates), which is unchanged.
- `RegenerationResultScenario.ps1` (mocks `Invoke-RegenerationProcess`), `Invoke-RegenerationPath.Merge.Tests.ps1`, `Invoke-RegenerationPath.Tip.Tests.ps1`: unchanged; they mock the wrapper and never reach the default.
- `RegenerationDelta.Tests.ps1` and `regeneration-path-skill-contract.Tests.ps1`: unchanged; they assert the invocation text and the Bash grant, not the seam.
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`: unchanged; it names the file in a comment only, with no digest of it.
- `enforcement-hooks-no-python-invocation.Tests.ps1`: unchanged; now passes because the default holds no dynamic invocation.

## Selection and rule

Rule: mirrored test files of the changed production file (the `tests/scripts/claude-lib/regeneration/` folder, which dot-sources or mocks `Invoke-RegenerationPath.ps1`) plus the suite that failed in the gate and scans the changed file.

## Commands and exit codes

| Step | Command | Exit | Result |
|---|---|---|---|
| copy | cp + cmp (bundle copy) | 0 | cmp equal |
| format + analyze | sh SCRATCH/issue-1156-tc-p6t2.sh | 0 | drift 0 files, PSSA 0 findings |
| test | Invoke-Pester, Run.Path = selection | 0 | 315 passed, 0 failed |

A SCRATCH probe (not a test) dot-sourced the script and confirmed: `git --version` returns one Int32 0 with the child output on stderr only; a failing git subcommand returns 1; a missing executable gives `Started = False` from `Invoke-RegenerationProcessStep`.
