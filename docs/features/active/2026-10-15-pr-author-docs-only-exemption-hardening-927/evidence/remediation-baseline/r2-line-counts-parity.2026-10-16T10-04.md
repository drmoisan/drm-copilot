# R2 Line Counts and Helper Parity Baseline (Issue #927)

Timestamp: 2026-10-16T10-04
Command: grep -c '^' .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1 .claude/hooks/enforce-epic-merge-gate.ps1
EXIT_CODE: 0
Output Summary: Line counts 478 (four helper copies), 188 (suite F), 239 (suite D), 491 (Claude merge gate), matching Appendix H and T. All three cmp -s calls exit 0. One `& $ProcessStarter $startInfo` line and one `finally {` line in the helper. No `Dispose` text in the helper or either suite (pre-cycle state).

## Line counts (Command 1)

- `.claude/hooks/hook-docs-only-diff.ps1:478`
- `.codex/hooks/hook-docs-only-diff.ps1:478`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1:478`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1:478`
- `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1:188`
- `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1:239`
- `.claude/hooks/enforce-epic-merge-gate.ps1:491`

## Parity (Commands 2-4)

- Command 2: `cmp -s .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1`
  - EXIT_CODE_2: 0
- Command 3: `cmp -s .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1`
  - EXIT_CODE_3: 0
- Command 4: `cmp -s .claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1`
  - EXIT_CODE_4: 0

## Structure greps (Commands 5-7)

- Command 5: `grep -c -F -e '& $ProcessStarter $startInfo' .claude/hooks/hook-docs-only-diff.ps1`
  - EXIT_CODE_5: 0
  - Output: `1`
- Command 6: `grep -c -F -e 'finally {' .claude/hooks/hook-docs-only-diff.ps1`
  - EXIT_CODE_6: 0
  - Output: `1`
- Command 7: `grep -c -F -e 'Dispose' .claude/hooks/hook-docs-only-diff.ps1 tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1 tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1`
  - EXIT_CODE_7: 1
  - Output: `.claude/hooks/hook-docs-only-diff.ps1:0`; `tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1:0`; `tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1:0`

Exit-code capture note: the `cmp -s` and the Command 7 exit codes were read from an `echo "EXIT=$?"` appended in the same Bash call, because the Bash tool does not display a non-zero exit code otherwise.
