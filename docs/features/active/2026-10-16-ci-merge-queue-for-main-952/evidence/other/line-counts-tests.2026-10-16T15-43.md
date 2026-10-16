# Line counts and temporary-file scan of the six created or edited suites (remediation cycle 1)

Timestamp: 2026-10-16T15-43
Task: [P2-T9]
Command: git grep -c -e '^' -- tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1
EXIT_CODE: 0
Output Summary: six counts, all at or below 500 (max 204); temporary-file scan exit 1 with no output

| Suite | Observed | Planner projection |
|---|---|---|
| tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | 75 | 75 |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 | 200 | 200 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 | 204 | 204 |
| tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 | 153 | 153 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 | 199 | 199 |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 | 159 | 159 |

## Temporary-file scan

Command: git grep -n -E -e "New-TemporaryFile|TestDrive|Start-Process|Start-Sleep|GetTempFileName|GetTempPath" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1
EXIT_CODE (scan): 1
ExpectedExitCode (scan): 1
Output (scan): (empty)
