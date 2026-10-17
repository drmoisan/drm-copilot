# R1 Baseline Line Counts and Mirror Parity (Issue #927)

Timestamp: 2026-10-16T07-18
Command: grep -c '^' .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1
EXIT_CODE: 0
Output Summary: Counts match the plan (397 x4, 490 x2, 410 x2, 318, 218, 169, 159, 242). All eight cmp -s calls exited 0 (no mirror drift). Suite F does not exist yet (test -f exit 1).

LINE_COUNT: .claude/hooks/hook-docs-only-diff.ps1 397
LINE_COUNT: .codex/hooks/hook-docs-only-diff.ps1 397
LINE_COUNT: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 397
LINE_COUNT: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 397
LINE_COUNT: .claude/hooks/enforce-epic-merge-gate.ps1 490
LINE_COUNT: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 490
LINE_COUNT: .codex/hooks/enforce-epic-merge-gate.ps1 410
LINE_COUNT: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 410
LINE_COUNT: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 318
LINE_COUNT: tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1 218
LINE_COUNT: tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 169
LINE_COUNT: tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 159
LINE_COUNT: tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1 242

CMP_EXIT: .claude/hooks/hook-docs-only-diff.ps1 vs .codex/hooks/hook-docs-only-diff.ps1 0
CMP_EXIT: .claude/hooks/hook-docs-only-diff.ps1 vs extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 0
CMP_EXIT: .claude/hooks/hook-docs-only-diff.ps1 vs extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 0
CMP_EXIT: .claude/hooks/enforce-epic-merge-gate.ps1 vs bundled mirror 0
CMP_EXIT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 vs bundled mirror 0
CMP_EXIT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 vs bundled mirror 0
CMP_EXIT: .claude/hooks/enforce-pr-author-skill.ps1 vs bundled mirror 0
CMP_EXIT: .codex/hooks/enforce-epic-merge-gate.ps1 vs bundled mirror 0

Command: test -f tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1
TEST_F_EXIT_CODE: 1
