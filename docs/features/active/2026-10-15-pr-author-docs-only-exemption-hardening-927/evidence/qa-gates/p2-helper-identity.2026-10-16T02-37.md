# P2-T11 Helper Identity after the revision 2.1 rework (issue #927, AC-M2 hash half)

Timestamp: 2026-10-16T02-37
Command: git hash-object .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1
EXIT_CODE: 0
Output Summary: All four helper copies hash to the same blob (b2383fee88a69aa70d50602245077326c821593c), which differs from the version 2.0 hash recorded by [P2-T5]. The three copies were re-written with cp at [P2-T10] and each cmp -s against the canonical file exited 0. The rewritten helper is byte-identical to the revision 2.1 Appendix D text (cmp against the extracted appendix exited 0) and has 397 lines.

HELPER_HASH: b2383fee88a69aa70d50602245077326c821593c
- .claude/hooks/hook-docs-only-diff.ps1
- .codex/hooks/hook-docs-only-diff.ps1
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1

PRIOR_HELPER_HASH: d140874bb42ba07c8eb1fbd0a3dccba0e16fffda

## [P2-T9] rework checks

REWORK_HELPER: '[ValidateNotNull()][scriptblock] $GitInvoker = { git @args' -> 1
REWORK_HELPER: '[ValidateNotNull()][scriptblock] $GhInvoker = { gh @args' -> 1
REWORK_HELPER: '& $GitInvoker -C $WorktreeRoot @GitArgs' -> 1
REWORK_HELPER: '& $GhInvoker @GhArgs' -> 1
REWORK_HELPER: '.PARAMETER GitInvoker' -> 1
REWORK_HELPER: '.PARAMETER GhInvoker' -> 1
REWORK_HELPER: 'GitCommand' -> 0
REWORK_HELPER: 'GhCommand' -> 0
REWORK_HELPER: grep -c '^function ' -> 8
REWORK_HELPER: six named functions -> 6
REWORK_HELPER: 'did not return NUL-terminated output' -> 1
REWORK_HELPER: 'EndsWith([char]0)' -> 1
REWORK_HELPER: "'fetch'" -> 0
REWORK_HELPER: 'Get-Content' -> 0
REWORK_HELPER: 'Import-Module' -> 0
REWORK_HELPER: dot-source lines -> 0
REWORK_HELPER: grep -c '^' -> 397 (HELPER_LINES)

## [P2-T10] copy checks

COPY_EXIT: cp .codex/hooks/hook-docs-only-diff.ps1 -> 0; cmp -s -> 0
COPY_EXIT: cp extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 -> 0; cmp -s -> 0
COPY_EXIT: cp extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1 -> 0; cmp -s -> 0
