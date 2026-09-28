Timestamp: 2026-08-29T21:53:42.1639838Z
Command: `$ErrorActionPreference = 'Stop'; Import-Module Pester -Force -ErrorAction Stop; $focusedResult = Invoke-Pester -Path 'tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1' -PassThru -ErrorAction Stop; if ($null -eq $focusedResult -or $focusedResult.FailedCount -ne 0 -or $focusedResult.Result -notcontains 'Passed') { throw 'Focused Codex PreToolUse isolation test failed.' }`
EXIT_CODE: 0
Output Summary: The focused Codex PreToolUse integration test passed: 6 passed, 0 failed, and 0 skipped. The task-local result was non-null and reported `Passed`.

Red evidence: `docs/features/active/2026-08-29-claude-planning-integrity-593/evidence/regression-testing/planner-review-codex-ambient-state-red.2026-08-29T14-41.md`

Synthetic session paths checked after the benign probes:

- `.codex/state/python-batch-budget.native-hook-contract.json`
- `.codex/state/powershell-batch-budget.native-hook-contract.json`

The test now permits unrelated active-session state files and verifies only that neither synthetic-session batch-budget record exists. No `.codex/state` file was reset, moved, deleted, modified, or excluded. No Codex agent, skill, prompt, hook, configuration, runtime contract, or orchestration behavior was changed.
