# P2-T15 Test Purity Search after the revision 2.1 rework (issue #927)

Timestamp: 2026-10-16T02-42
Command: grep -c -E -e 'Mock[[:space:]]+.?(git|gh)\b|Start-Process|Start-Sleep|TestDrive|New-TemporaryFile|GetTemp|env:TEMP|function[[:space:]]+(global:|script:)?(git|gh)\b' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: No prohibited pattern (Mock git/gh, Start-Process, Start-Sleep, TestDrive, New-TemporaryFile, GetTemp, env:TEMP, function named git or gh) appears in any of the eight suites after the scriptblock-invoker conversion; all eight counts are 0 and grep exits 1 because nothing matched.

## Output

- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1:0
- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1:0
- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1:0
- tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1:0
- tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:0
- tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1:0
- tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1:0
- tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1:0
