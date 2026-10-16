# R3 QC parity and line counts, loop pass 1 (issue #927, remediation cycle 3)

Timestamp: 2026-10-16T12-12
Command: cmp -s .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1
EXIT_CODE: 0
Output Summary: Loop pass 1. All three cmp -s calls exit 0; the four helper hashes are equal and equal R3_HELPER_HASH 7e429ae6cc216ee91968ab921572d78638f9b976; line counts 493 (four helper copies), 206 (suite F), 243 (suite D), 491 (Claude merge gate), each below 500.

Command 2: cmp -s .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1
EXIT_CODE_2: 0
Command 3: cmp -s .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1
EXIT_CODE_3: 0

Command 4: git hash-object (four helper paths)
EXIT_CODE_4: 0
HASH: .claude/hooks/hook-docs-only-diff.ps1 7e429ae6cc216ee91968ab921572d78638f9b976
HASH: .codex/hooks/hook-docs-only-diff.ps1 7e429ae6cc216ee91968ab921572d78638f9b976
HASH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 7e429ae6cc216ee91968ab921572d78638f9b976
HASH: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 7e429ae6cc216ee91968ab921572d78638f9b976
HASHES_EQUAL_R3_HELPER_HASH: true

Command 5: grep -c '^' (four helper paths, both suites, .claude/hooks/enforce-epic-merge-gate.ps1)
EXIT_CODE_5: 0
LINE_COUNT: .claude/hooks/hook-docs-only-diff.ps1 493
LINE_COUNT: .codex/hooks/hook-docs-only-diff.ps1 493
LINE_COUNT: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 493
LINE_COUNT: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 493
LINE_COUNT: tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1 206
LINE_COUNT: tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 243
LINE_COUNT: .claude/hooks/enforce-epic-merge-gate.ps1 491
ALL_BELOW_500: true
LOOP_PASS: 1
