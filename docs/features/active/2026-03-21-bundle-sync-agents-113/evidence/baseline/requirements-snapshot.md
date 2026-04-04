Timestamp: 2026-04-03T16-08

Objective:
Expose `sync-agents-from-instructions` through the VS Code extension, make `AGENTS.md` generation discovery-based and deterministic, preserve the repo-local PowerShell entrypoint, and keep bundled resources aligned with the repo-root implementation.

Constraints Preserved:
- Keep scope limited to generating `<workspace-root>/AGENTS.md` from destination-workspace `.github` instruction sources.
- Preserve the existing repo-root PowerShell CLI contract with `-RepoRoot` defaulting to the repository root when omitted.
- Do not add new runtime dependencies.
- Keep bundled and repo-root implementations aligned exactly where parity is required.
- Fail fast with actionable errors when required inputs are missing or discovery yields no supported instruction files.

PowerShell Surfaces:
- `scripts/dev-tools/sync-agents-from-instructions.ps1`
- `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`
- `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1`

TypeScript Surfaces:
- `extensions/drm-copilot/package.json`
- `extensions/drm-copilot/src/extension.ts`
- `extensions/drm-copilot/test/extension.test.ts`
- `extensions/drm-copilot/test/extension.integration.test.ts`

Python Rewrite Surfaces:
- `scripts/dev_tools/push_down_copilot_customizations_rewrites.py`
- `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_rewrites.py`
- `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`
- `tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py`

Determinism Requirements:
- Treat `.github/copilot-instructions.md` as the canonical required preamble.
- Discover supported `*.instructions.md` files under `.github/` from the destination workspace.
- Normalize discovered relative paths and sort them with ordinal comparison.
- Use the same discovered file list for the generated-source note and aggregated rendered sections.
- Strip YAML frontmatter before deriving section content.
- Derive section labels deterministically by preferring the first stripped Markdown heading, then frontmatter `name`, then a filename-based fallback.
- Repeated runs with unchanged inputs must produce identical output.

Documentation Targets:
- `README.md`
- `extensions/drm-copilot/README.md`
- Feature evidence artifacts under `docs/features/active/2026-03-21-bundle-sync-agents-113/evidence/`
