# Cross-Ecosystem Equality (AC4)

- Timestamp: 2026-06-24T16-43
- Issue: #231

## Claude root vs bundled — byte-identical (sha256)

| File (relative to `.claude/` and bundled `.claude/`) | sha256 | Result |
|---|---|---|
| hooks/enforce-pr-author-skill.ps1 | 2f986f3df24300153ccc1a57b643c69552b11a6c78d5d9c307c498049ef0f286 | MATCH |
| hooks/validate-pr-author-output.ps1 | 142ac1e17e89fedc3b6916cedd1d6e5a4303c9656147e86f83b751b093b6aeb7 | MATCH |
| agents/pr-author.md | e40e005e737d18c628ee51fc9028a5cbcc98c45a991d99d09c45b668a7169816 | MATCH |
| settings.json | 7c1fb1f22309c51cdabb6a28369ad9bb595cb62ea9db368f39acba5fd676367d | MATCH |
| skills/orchestrate/SKILL.md | 1e0c39729872ed8f2ec4c43f3779abc910bc127d68ef642621ae7dc9687bb4da | MATCH |
| agents/orchestrator.md | 55c262739a7c66f68eeebc82bfc352d0a25e5ddd5e6d0538e1fa8b64d39bc422 | MATCH |

Bundled tree root: `extensions/drm-copilot/resources/claude-customizations/.claude/`.

## Codex ecosystem

- Hook `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` exists with the `# Converted hook` header; its body is byte-identical to the root hook (decision logic preserved).
- Wired in `.codex/config.toml` via a `[[hooks.PreToolUse]]` entry referencing `enforce-pr-author-skill.ps1` (matcher `Bash`); TOML validated as well-formed.
- Codex agent `.codex/agents/pr-author.toml` updated with the sentinel write/delete protocol and the guardrail limitation.

## GitHub Copilot ecosystem

- Agent `extensions/drm-copilot/resources/customizations/.github/agents/pr-author.agent.md` updated with the sentinel protocol, the documentation-only statement (no PreToolUse hook surface), and the guardrail-not-cryptographic limitation.

## Conclusion

Claude root and bundled copies are byte-identical for all six paired files. The Codex hook is added and wired; the Copilot agent is documentation-updated. AC4 satisfied.
