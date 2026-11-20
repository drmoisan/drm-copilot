# Remediation cycle 2 - edited-suite line counts and temporary-file scan (P2-T5)

Timestamp: 2026-10-16T20-05
Command: git grep -c -e '^' -- tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1; git grep -n -E -e "New-TemporaryFile|TestDrive|GetTempFileName|GetTempPath|Start-Sleep" -- <the same six paths>
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: count command EXIT_CODE 0, six counts as expected, each at or below 500; temporary-file and sleep scan EXIT_CODE 1 with no output (no match). The artifact-level EXIT_CODE records the scan.

## Count command output (verbatim, EXIT_CODE 0)

```text
tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1:216
tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1:260
tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1:91
tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:176
tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:208
tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1:244
```

## Scan command (EXIT_CODE 1, ExpectedExitCode 1)

Full command: `git grep -n -E -e "New-TemporaryFile|TestDrive|GetTempFileName|GetTempPath|Start-Sleep" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`

Output: (empty)
