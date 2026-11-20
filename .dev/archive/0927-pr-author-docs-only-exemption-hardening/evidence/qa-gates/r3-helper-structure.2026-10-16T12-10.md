# R3 helper structure (issue #927, remediation cycle 3)

Timestamp: 2026-10-16T12-10
Command: grep -c '^' .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1
EXIT_CODE: 0
Output Summary: All four helper copies have 493 lines and one pendingRead check line. The create-side docs-only file and both merge gates are unchanged against the start commit. Working-tree status lists exactly the four helper copies and the two edited suites, each modified.

LINE_COUNT: .claude/hooks/hook-docs-only-diff.ps1 493
LINE_COUNT: .codex/hooks/hook-docs-only-diff.ps1 493
LINE_COUNT: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 493
LINE_COUNT: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 493

Command 2: grep -c -F -e '$null = $pendingRead.Wait(0)' (four helper paths)
EXIT_CODE_2: 0
PENDING_READ_COUNT: .claude/hooks/hook-docs-only-diff.ps1 1
PENDING_READ_COUNT: .codex/hooks/hook-docs-only-diff.ps1 1
PENDING_READ_COUNT: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 1
PENDING_READ_COUNT: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 1

Command 3: git diff --stat bcdc5990963c6a1f732908141a3361a29af6bafe -- .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1
EXIT_CODE_3: 0
DIFF_OUTPUT: (empty)

Command 4: git status --porcelain -- .claude .codex extensions tests
EXIT_CODE_4: 0
STATUS:  M .claude/hooks/hook-docs-only-diff.ps1
STATUS:  M .codex/hooks/hook-docs-only-diff.ps1
STATUS:  M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1
STATUS:  M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1
STATUS:  M tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1
STATUS:  M tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1
