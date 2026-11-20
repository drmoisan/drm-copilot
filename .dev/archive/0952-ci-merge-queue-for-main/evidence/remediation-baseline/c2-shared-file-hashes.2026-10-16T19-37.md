# Remediation cycle 2 - baseline shared-file hashes (P0-T4)

Timestamp: 2026-10-16T19-37
Command: git hash-object .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1; git hash-object .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1
EXIT_CODE: 0
Output Summary:
DOCS_ONLY_COPIES_EQUAL=4/4 DOCS_ONLY_BASE_HASH=7e429ae6cc216ee91968ab921572d78638f9b976
HELPER_COPIES_EQUAL=4/4 HELPER_BASE_HASH=94d2145cddf4f2a2ea00133216df715e52be38d5
DOCS_ONLY_MATCHES_REVIEW_PREFIX=true (reviewer prefix 7e429ae6c)
HELPER_MATCHES_REVIEW_PREFIX=true (reviewer prefix 94d2145cd)

## Output (verbatim)

hook-docs-only-diff.ps1 (EXIT_CODE 0):
7e429ae6cc216ee91968ab921572d78638f9b976
7e429ae6cc216ee91968ab921572d78638f9b976
7e429ae6cc216ee91968ab921572d78638f9b976
7e429ae6cc216ee91968ab921572d78638f9b976

enforce-epic-merge-gate-command.ps1 (EXIT_CODE 0):
94d2145cddf4f2a2ea00133216df715e52be38d5
94d2145cddf4f2a2ea00133216df715e52be38d5
94d2145cddf4f2a2ea00133216df715e52be38d5
94d2145cddf4f2a2ea00133216df715e52be38d5
