# Remediation cycle 2 - final shared-file hashes (P4-T6)

Timestamp: 2026-10-16T20-53
Command: git hash-object .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1; git hash-object .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1
EXIT_CODE: 0
Output Summary: DOCS_ONLY_COPIES_EQUAL=4/4 HELPER_COPIES_EQUAL=4/4 HELPER_UNCHANGED=true

## hook-docs-only-diff.ps1 (EXIT_CODE 0)

```text
62e0d3529b1f6ccd0f11ed2f1c615cab2a152d19
62e0d3529b1f6ccd0f11ed2f1c615cab2a152d19
62e0d3529b1f6ccd0f11ed2f1c615cab2a152d19
62e0d3529b1f6ccd0f11ed2f1c615cab2a152d19
```

Equal to each other and to the P3-T5 `DOCS_ONLY_HASH=62e0d3529b1f6ccd0f11ed2f1c615cab2a152d19`; different from `DOCS_ONLY_BASE_HASH=7e429ae6cc216ee91968ab921572d78638f9b976`.

## enforce-epic-merge-gate-command.ps1 (EXIT_CODE 0)

```text
94d2145cddf4f2a2ea00133216df715e52be38d5
94d2145cddf4f2a2ea00133216df715e52be38d5
94d2145cddf4f2a2ea00133216df715e52be38d5
94d2145cddf4f2a2ea00133216df715e52be38d5
```

Equal to each other and to the P0-T4 `HELPER_BASE_HASH=94d2145cddf4f2a2ea00133216df715e52be38d5`.
