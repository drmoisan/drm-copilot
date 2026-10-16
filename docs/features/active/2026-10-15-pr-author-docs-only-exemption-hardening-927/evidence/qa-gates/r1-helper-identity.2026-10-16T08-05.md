# R1 Helper Identity (Issue #927, AC-M2 hash half)

Timestamp: 2026-10-16T08-05
Command: git hash-object .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1
EXIT_CODE: 0
Output Summary: All four helper copies hash to the same value, which differs from the prior helper hash recorded before R1.

R1_HELPER_HASH: e04723f2724f8534747cb262d710038282c52a7c
PATH: .claude/hooks/hook-docs-only-diff.ps1
PATH: .codex/hooks/hook-docs-only-diff.ps1
PATH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1
PATH: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1

Command 2: grep -m 1 -o -E '^HELPER_HASH: [0-9a-f]{40}' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/p2-helper-identity.2026-10-16T02-37.md
EXIT_CODE_2: 0
PRIOR_HELPER_HASH: b2383fee88a69aa70d50602245077326c821593c
HASH_CHANGED: true
