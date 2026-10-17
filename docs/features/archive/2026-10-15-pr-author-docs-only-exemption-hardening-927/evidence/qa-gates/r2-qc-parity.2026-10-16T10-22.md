# R2 QC Parity and File Size, Loop Pass 1 (Issue #927)

Timestamp: 2026-10-16T10-22
Command: cmp -s .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1
EXIT_CODE: 0
Output Summary: All three cmp -s calls exited 0; the four helper hashes equal R2_HELPER_HASH (64d472beb58f06c06a1b7c499d28df091693b146). Line counts 484 (four helper copies), 194 (suite F), 241 (suite D), 491 (Claude merge gate); every value is below 500.

## Commands

- Command 1: `cmp -s .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1`
  - EXIT_CODE_1: 0
- Command 2: `cmp -s .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1`
  - EXIT_CODE_2: 0
- Command 3: `cmp -s .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1`
  - EXIT_CODE_3: 0
- Command 4: `git hash-object` on the four helper paths
  - EXIT_CODE_4: 0
  - Output: `64d472beb58f06c06a1b7c499d28df091693b146` (four times; equals R2_HELPER_HASH)
- Command 5: `grep -c '^'` on the four helper paths, the two suites, and `.claude/hooks/enforce-epic-merge-gate.ps1`
  - EXIT_CODE_5: 0
  - Output:
    - `.claude/hooks/hook-docs-only-diff.ps1:484`
    - `.codex/hooks/hook-docs-only-diff.ps1:484`
    - `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1:484`
    - `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1:484`
    - `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1:194`
    - `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1:241`
    - `.claude/hooks/enforce-epic-merge-gate.ps1:491`
