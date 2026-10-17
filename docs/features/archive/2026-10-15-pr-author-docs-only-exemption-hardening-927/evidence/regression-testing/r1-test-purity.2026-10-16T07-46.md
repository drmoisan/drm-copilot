# R1 Test Purity Search (Issue #927, rule R1-11)

Timestamp: 2026-10-16T07-46
Command: grep -c -E -e 'Mock[[:space:]]+.?(git|gh)\b|Start-Process|Start-Sleep|TestDrive|New-TemporaryFile|GetTemp|env:TEMP|ProcessStartInfo|function[[:space:]]+(global:|script:)?(git|gh)\b' tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: All nine suites report 0 matches for the forbidden test constructs.

COUNT: tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1:0
COUNT: tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1:0
COUNT: tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1:0
COUNT: tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1:0
COUNT: tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:0
COUNT: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1:0
COUNT: tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1:0
COUNT: tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1:0
COUNT: tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1:0
