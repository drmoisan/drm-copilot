# Baseline line counts ([P0-T7])

Timestamp: 2026-10-08T17-31
Command: wc -l .claude/hooks/enforce-completion-consistency.ps1 .codex/hooks/enforce-completion-consistency.ps1 .claude/hooks/enforce-completion-helpers.ps1 .codex/hooks/enforce-completion-helpers.ps1 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
EXIT_CODE: 0
Output Summary: counts 423, 438, 163, 163, 491, 227, 492; all at most 500.

423 .claude/hooks/enforce-completion-consistency.ps1
438 .codex/hooks/enforce-completion-consistency.ps1
163 .claude/hooks/enforce-completion-helpers.ps1
163 .codex/hooks/enforce-completion-helpers.ps1
491 tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1
227 tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1
492 tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1

LINES_MATCH_SPEC: yes
