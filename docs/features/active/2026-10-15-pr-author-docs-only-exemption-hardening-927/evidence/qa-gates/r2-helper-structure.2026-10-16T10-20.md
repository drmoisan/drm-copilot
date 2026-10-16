# R2 Helper Structure (Issue #927, CR-R1)

Timestamp: 2026-10-16T10-20
Command: grep -c '^' .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1
EXIT_CODE: 0
Output Summary: Four helper copies at 484 lines each, each with one `$process.Dispose()` line. The out-of-scope hook files show no diff since R2_START_HEAD. The code-path status lists exactly the four helper paths and the two Phase 1 suites, each ` M`.

## Commands

- Command 1: `grep -c '^'` on the four helper paths
  - Output: `.claude/hooks/hook-docs-only-diff.ps1:484`; `.codex/hooks/hook-docs-only-diff.ps1:484`; `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1:484`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1:484`
- Command 2: `grep -c -F -e '$process.Dispose()'` on the four helper paths
  - EXIT_CODE_2: 0
  - Output: `1` for each of the four paths
- Command 3: `git diff --stat df6c9d6cc411d9c445d7c8820ac8a897f5f74071 HEAD -- .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1`
  - EXIT_CODE_3: 0
  - Output: (empty)
- Command 4: `git status --porcelain -- .claude .codex extensions tests`
  - EXIT_CODE_4: 0
  - Output:
    - ` M .claude/hooks/hook-docs-only-diff.ps1`
    - ` M .codex/hooks/hook-docs-only-diff.ps1`
    - ` M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1`
    - ` M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1`
    - ` M tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1`
    - ` M tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`
