# Task Check — remediation cycle 2, [P1-T1]

Timestamp: 2026-11-14T06-33
Command: sh SCRATCH/issue-1156-static.sh (check-only Invoke-Formatter and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1); sh SCRATCH/issue-1156-taskcheck.sh (New-PesterConfiguration, Run.Path = the two adapter test files, PassThru; the launcher exits with FailedCount); sh SCRATCH/issue-1156-pytest-sel.sh tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py (poetry run pytest -q, VIRTUAL_ENV unset)
EXIT_CODE: 0
Output Summary:
- Changed files: `.claude/lib/regeneration/Invoke-RegenerationPath.ps1`, its bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/Invoke-RegenerationPath.ps1`, and `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.ProcessStart.Tests.ps1`.
- Selection rule: mirrored tests of the changed production file (`Invoke-RegenerationPath.ProcessStart.Tests.ps1`, `Invoke-RegenerationPath.Tests.ps1`) plus the contract test that reads the bundle copy (`test_push_down_claude_resource_contracts.py`).
- Static: 3 files, 0 formatter differences, 0 analyzer findings (static exit 0).
- Adapter: 792 logical lines (cap 796, limit 800). SHA-256 of source and bundle copy equal: 957247bcc608dfc08093a74049c5c012979501d3b314f824383bacdae7229a4a.
- Pester (exit 0): `Invoke-RegenerationPath.ProcessStart.Tests.ps1` 33 passed, 0 failed (was 17: 8 argument rows, 7 path rows, 1 parentheses case added); `Invoke-RegenerationPath.Tests.ps1` 123 passed, 0 failed.
- pytest (exit 0): `test_push_down_claude_resource_contracts.py` 14 passed, 0 failed.
- `Get-RegenerationProcessStartSpec` now refuses a batch `ResolvedPath` matching `["&|<>^%]` after the ComSpec check with a message containing `batch file path` and `cmd.exe metacharacter`; whitespace and parentheses stay allowed.
