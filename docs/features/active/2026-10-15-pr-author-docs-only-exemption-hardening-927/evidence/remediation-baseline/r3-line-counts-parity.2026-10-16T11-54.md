# R3 line counts and helper parity baseline (issue #927, remediation cycle 3)

Timestamp: 2026-10-16T11-54
Command: grep -c '^' .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 .claude/hooks/enforce-epic-merge-gate.ps1
EXIT_CODE: 0
Output Summary: Helper 484 lines at all four paths; suite F 194; suite D 241; Claude merge gate 491. All three cmp calls exit 0. ProcessStarter invocation 1; discarded stderr read 1; pendingRead 0. Matches the plan's Appendix H and T preconditions.

LINE_COUNT: .claude/hooks/hook-docs-only-diff.ps1 484
LINE_COUNT: .codex/hooks/hook-docs-only-diff.ps1 484
LINE_COUNT: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 484
LINE_COUNT: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 484
LINE_COUNT: tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1 194
LINE_COUNT: tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 241
LINE_COUNT: .claude/hooks/enforce-epic-merge-gate.ps1 491

Command 2: cmp -s .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1
EXIT_CODE_2: 0
Command 3: cmp -s .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1
EXIT_CODE_3: 0
Command 4: cmp -s .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1
EXIT_CODE_4: 0

Command 5: grep -c -F -e '& $ProcessStarter $startInfo' .claude/hooks/hook-docs-only-diff.ps1
EXIT_CODE_5: 0
COUNT_PROCESS_STARTER: 1
Command 6: grep -c -F -e '$null = $process.StandardError.ReadToEndAsync()' .claude/hooks/hook-docs-only-diff.ps1
EXIT_CODE_6: 0
COUNT_DISCARDED_STDERR_READ: 1
Command 7: grep -c -F -e 'pendingRead' .claude/hooks/hook-docs-only-diff.ps1
EXIT_CODE_7: 1
COUNT_PENDING_READ: 0
