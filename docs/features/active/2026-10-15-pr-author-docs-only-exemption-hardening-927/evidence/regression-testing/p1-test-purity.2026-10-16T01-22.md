# P1-T8 Test Purity Search (issue #927)

Timestamp: 2026-10-16T01-22
Command: grep -c -E -e 'Mock[[:space:]]+.?(git|gh)\b|Start-Process|Start-Sleep|TestDrive|New-TemporaryFile|GetTemp|env:TEMP|function[[:space:]]+(global:|script:)?(git|gh)\b' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: No prohibited pattern (Mock git/gh, Start-Process, Start-Sleep, TestDrive, New-TemporaryFile, GetTemp, env:TEMP, function named git or gh) appears in any of the five suites; all five counts are 0 and grep exits 1 because nothing matched.

## Output

- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1:0
- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1:0
- tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1:0
- tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1:0
- tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:0
