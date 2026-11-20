# Agent Bundle Hashes (P3-T4)

Timestamp: 2026-11-07T16-32
Command: sh SCRATCH/issue-1037-copy-bundle.sh agents (`cp` of each agent file to its bundle location, then `sha256sum` of source and copy)
EXIT_CODE: 0
Output Summary: Twelve byte copies made by a copy step; twelve equal SHA-256 pairs, zero differences. The four Codex role files parse as TOML with exactly the keys `name`, `description` and `developer_instructions`.

| Source | Bundle copy | SHA-256 (source = copy) | Result |
|---|---|---|---|
| `.github/agents/docs-architect.agent.md` | `extensions/drm-copilot/resources/customizations/.github/agents/docs-architect.agent.md` | `ab74808bff2cad588d4b62213949e0b80539bb0ea46d79ce7b85ffe7b15240c8` | EQUAL |
| `.claude/agents/docs-architect.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/docs-architect.md` | `9cb0bf72d5365048481e771ca297bca1bfa1a9451fa4c0cfbc89544e2f472484` | EQUAL |
| `.codex/agents/docs-architect.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/docs-architect.toml` | `1170962b3309e94496ed15c25c48ccf996cfc1e41f19f3a6bcb405c02520cbcd` | EQUAL |
| `.github/agents/docs-author.agent.md` | `extensions/drm-copilot/resources/customizations/.github/agents/docs-author.agent.md` | `34eb5de43b3c5d6f8a68f6bbd4d257a088161ab759339977a88fcffea20f836c` | EQUAL |
| `.claude/agents/docs-author.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/docs-author.md` | `802a6d6c14d112c6eae7b5ba5c99da84401e40fef8c5e554d4a2ed83bba5de89` | EQUAL |
| `.codex/agents/docs-author.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/docs-author.toml` | `4062307a21414309ae40bd5e6929187424f21b9de33fa5d3d69323926dd25c7c` | EQUAL |
| `.github/agents/docs-reconciler.agent.md` | `extensions/drm-copilot/resources/customizations/.github/agents/docs-reconciler.agent.md` | `fb7a62265590e0d6324e3a788e2c9cd130b77799ea51d32c99bceee9e7032ad8` | EQUAL |
| `.claude/agents/docs-reconciler.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/docs-reconciler.md` | `0aee3964b81e32b5a99e5e627526edb33d3931698f27ed605795c6d183fa6f2b` | EQUAL |
| `.codex/agents/docs-reconciler.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/docs-reconciler.toml` | `a4588d0b338a65e1c1f15186d4ab72ecb968ae9b373838f96a0f8119e0cfb0a8` | EQUAL |
| `.github/agents/docs-coverage-reviewer.agent.md` | `extensions/drm-copilot/resources/customizations/.github/agents/docs-coverage-reviewer.agent.md` | `76c473e093badb5c132e4bf2cf56b4b72a652875b19474a7801705795667f69e` | EQUAL |
| `.claude/agents/docs-coverage-reviewer.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/docs-coverage-reviewer.md` | `0a3f1433171ba960ed479ce7c746590575993a2286882132e120b787ceb2c616` | EQUAL |
| `.codex/agents/docs-coverage-reviewer.toml` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/docs-coverage-reviewer.toml` | `881efad0945ffe01b1d941b92e534c181dba4bc0ca7761a1d240f4a00f369da6` | EQUAL |
