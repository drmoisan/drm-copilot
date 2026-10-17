# P2-T5 Helper Identity (issue #927, AC-M2 hash half)

Timestamp: 2026-10-16T01-26
Command: git hash-object .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1
EXIT_CODE: 0
Output Summary: All four helper copies hash to the same blob (d140874bb42ba07c8eb1fbd0a3dccba0e16fffda). The three copies were written with cp and each cmp -s against the canonical file exited 0 ([P2-T2] to [P2-T4]). The helper has 397 lines (below 500) and 8 functions.

HELPER_HASH: d140874bb42ba07c8eb1fbd0a3dccba0e16fffda
- .claude/hooks/hook-docs-only-diff.ps1
- .codex/hooks/hook-docs-only-diff.ps1
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1

HELPER_LINES: 397

## [P2-T1] source checks (recorded here)

- `grep -c '^function '` -> 8
- six named functions -> 6
- 'did not return NUL-terminated output' -> 1
- 'EndsWith([char]0)' -> 1
- "'fetch'" -> 0
- 'Get-Content' -> 0
- 'Import-Module' -> 0
- dot-source lines -> 0
- Appendix D text diff against the written file: no difference
