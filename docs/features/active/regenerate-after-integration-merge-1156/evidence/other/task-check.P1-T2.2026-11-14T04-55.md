# Task Check — [P1-T2]

Timestamp: 2026-11-14T04-55
Changed files: `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` (new `Resolve-RegenerationExecutable` and `Get-RegenerationProcessStartSpec`; the `Invoke-RegenerationProcess` `-Invoker` default now resolves `argv[0]` and starts the spec `FileName` with the spec `ArgumentList`; `.DESCRIPTION` seam list and `Invoke-RegenerationProcess` help updated) and its byte copy `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/Invoke-RegenerationPath.ps1`.
Selection: `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1` (mirrored test of the changed file) and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (contract test reading the bundle copy). Rule: mirrored test files of each changed production file plus the contract tests that read the changed path, as the plan task names them.

## Steps

- Command: sh SCRATCH/issue-1156-mirror.sh (copy, then sha256sum of both copies). EXIT_CODE: 0. Both SHA-256 values are `6c28bd186aaaff7a3510af34f2193448057f23d0104f3cb16f0e0b51d88509eb`.
- Command: sh SCRATCH/issue-1156-static.sh over both copies (check-only Invoke-Formatter comparison and Invoke-ScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`). EXIT_CODE: 0. Formatter differences 0 and analyzer findings 0 for each copy; 788 logical lines each (cap 790).
- Command: sh SCRATCH/issue-1156-pester.sh (New-PesterConfiguration, Run.Path = the test file, Run.Exit = $true). EXIT_CODE: 1. Passed 121, Failed 1. The one failure is the expected one: `Invoke-RegenerationPath seam defaults (AST).(h) the process -Invoker default starts one ProcessStartInfo with UseShellExecute false, forwards output to [Console]::Error.WriteLine and returns ExitCode`, which [P1-T3] replaces. Every other case passes.
- Command: sh SCRATCH/issue-1156-pushdown.sh tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py (env -u VIRTUAL_ENV poetry run pytest -n auto -q --no-cov). EXIT_CODE: 0. 14 passed, 0 failed.

Output Summary: mirror equal; static clean; 1 expected (h) failure until [P1-T3]; push-down contract 14/0.
