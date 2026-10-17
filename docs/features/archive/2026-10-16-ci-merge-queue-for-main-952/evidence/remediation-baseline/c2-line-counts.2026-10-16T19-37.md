# Remediation cycle 2 - baseline line counts (P0-T5)

Timestamp: 2026-10-16T19-37
Command: git grep -c -e '^' -- .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-followups.md tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1
EXIT_CODE: 0
Output Summary: LINE_COUNTS_MATCH=15/15 (every expected line present; no extra or different line); TRIGGER_SCOPING_LINES=117 (recorded only)

## Output (verbatim)

.claude/hooks/enforce-epic-merge-gate-command.ps1:190
.claude/hooks/enforce-epic-merge-gate.ps1:460
.claude/hooks/hook-docs-only-diff.ps1:493
.codex/hooks/enforce-epic-merge-gate-command.ps1:190
.codex/hooks/enforce-epic-merge-gate.ps1:390
.codex/hooks/hook-docs-only-diff.ps1:493
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-followups.md:47
tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1:199
tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1:204
tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1:130
tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1:245
tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1:75
tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:159
tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:200
tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1:117
tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1:243
