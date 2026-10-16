# R2 Helper Copies (Issue #927, CR-R1)

Timestamp: 2026-10-16T10-20
Command: cp .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1
EXIT_CODE: 0
Output Summary: The edited canonical helper was copied to its three other paths with cp (rule R2-8). All three cp and cmp -s calls exited 0, and the four git hash-object values are equal.

## Commands

- Command 1: `cp .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1`
  - EXIT_CODE_1: 0
- Command 2: `cp .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1`
  - EXIT_CODE_2: 0
- Command 3: `cp .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1`
  - EXIT_CODE_3: 0
- Command 4: `cmp -s .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1`
  - EXIT_CODE_4: 0
- Command 5: `cmp -s .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1`
  - EXIT_CODE_5: 0
- Command 6: `cmp -s .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1`
  - EXIT_CODE_6: 0
- Command 7: `git hash-object` on the four helper paths
  - EXIT_CODE_7: 0
  - Output: `64d472beb58f06c06a1b7c499d28df091693b146` (four times)

R2_HELPER_HASH: 64d472beb58f06c06a1b7c499d28df091693b146
