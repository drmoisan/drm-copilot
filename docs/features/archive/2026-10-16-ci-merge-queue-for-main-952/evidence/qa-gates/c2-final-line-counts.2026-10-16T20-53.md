# Remediation cycle 2 - final line counts of touched production and test files (P4-T7)

Timestamp: 2026-10-16T20-53
Command: git grep -c -e '^' -- .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1
EXIT_CODE: 0
Output Summary: ten lines; every count at or below 500 (AC-26 stays satisfied); the four hook-docs-only-diff.ps1 counts are 497; the Codex command suite is 91; the Codex merge-queue suite is 208.

## Output (verbatim)

```text
.claude/hooks/hook-docs-only-diff.ps1:497
.codex/hooks/hook-docs-only-diff.ps1:497
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1:497
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1:497
tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1:216
tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1:260
tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1:91
tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:176
tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:208
tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1:244
```
