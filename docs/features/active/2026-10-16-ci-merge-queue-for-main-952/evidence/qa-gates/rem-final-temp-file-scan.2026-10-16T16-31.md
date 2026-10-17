# Final temporary-file scan (remediation cycle 1)

Timestamp: 2026-10-16T16-31
Task: [P5-T8]
Command: git grep -n -E -e "New-TemporaryFile|TestDrive|GetTempFileName|GetTempPath|Start-Process" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: no output; no created or edited test uses a temporary-file or process-start API.
