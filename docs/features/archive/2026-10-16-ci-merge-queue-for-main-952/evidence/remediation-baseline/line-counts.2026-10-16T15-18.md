# Baseline line counts (remediation cycle 1, issue #952)

Timestamp: 2026-10-16T15-18
Task: [P0-T5]
Command: git grep -c -e '^' -- .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md
EXIT_CODE: 0
Output Summary: LINE_COUNTS_MATCH=11/11 (the output set equals the expected set of P0-T5 exactly)

Output (verbatim):
.claude/hooks/enforce-epic-merge-gate-command.ps1:184
.claude/hooks/enforce-epic-merge-gate.ps1:460
.codex/hooks/enforce-epic-merge-gate-command.ps1:184
.codex/hooks/enforce-epic-merge-gate.ps1:390
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md:60
docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md:337
tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1:199
tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1:190
tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1:121
tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1:159
tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:191
