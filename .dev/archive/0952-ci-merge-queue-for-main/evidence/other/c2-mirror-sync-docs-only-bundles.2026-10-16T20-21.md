# Remediation cycle 2 - bundle mirrors of hook-docs-only-diff.ps1 (P3-T5)

Timestamp: 2026-10-16T20-21
Command: git add .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1; git checkout-index -f --prefix=extensions/drm-copilot/resources/claude-customizations/ -- .claude/hooks/hook-docs-only-diff.ps1; git checkout-index -f --prefix=extensions/drm-copilot/resources/codex-and-agents-customizations/ -- .codex/hooks/hook-docs-only-diff.ps1; git hash-object .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1
EXIT_CODE: 0
Output Summary: DOCS_ONLY_COPIES_EQUAL=4/4 DOCS_ONLY_HASH=62e0d3529b1f6ccd0f11ed2f1c615cab2a152d19

## Per-command exit codes

| Command | EXIT_CODE |
|---|---|
| git add (both sources) | 0 |
| git checkout-index (Claude bundle) | 0 (no output) |
| git checkout-index (Codex bundle) | 0 (no output) |
| git hash-object (four copies) | 0 |

## Hashes (verbatim)

```text
62e0d3529b1f6ccd0f11ed2f1c615cab2a152d19   .claude/hooks/hook-docs-only-diff.ps1
62e0d3529b1f6ccd0f11ed2f1c615cab2a152d19   .codex/hooks/hook-docs-only-diff.ps1
62e0d3529b1f6ccd0f11ed2f1c615cab2a152d19   extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1
62e0d3529b1f6ccd0f11ed2f1c615cab2a152d19   extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1
```

All four are equal and differ from the P0-T4 `DOCS_ONLY_BASE_HASH=7e429ae6cc216ee91968ab921572d78638f9b976`.
