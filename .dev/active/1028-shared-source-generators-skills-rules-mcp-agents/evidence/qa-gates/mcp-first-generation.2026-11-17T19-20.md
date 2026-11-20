# MCP surface — first generation ([P1-T2])

Timestamp: 2026-11-17T19-20
Command: sh SCRATCH/issue-1028-gen.sh mcp check; sh SCRATCH/issue-1028-gen.sh mcp; sh SCRATCH/issue-1028-gen.sh mcp check (each runs `scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Surface mcp` with or without `-Check` from the worktree root); git diff --stat <BASE> -- .mcp.json .codex/config.toml extensions/drm-copilot/resources/claude-dir-customizations/.mcp.json extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml; git status --porcelain -- (the same four paths)
EXIT_CODE: 0
Output Summary: The check before the write printed "harness-generation: no drift" (exit 0). The write run printed "harness-generation: no drift" (exit 0) and rewrote no file, because every rendered target already equals the tree. The check after the write printed "harness-generation: no drift" (exit 0). `git diff --stat` against `BASE` (the merge base of `origin/epic/shared-agent-harness-layer-integration` and `HEAD`) printed nothing for the four targets, and `git status --porcelain` for them was empty. The four files are byte-identical to `BASE`.

Rendered from `scripts/harness-generation/sources/mcp-servers.json`, with no stored version:
- `.mcp.json` and `extensions/drm-copilot/resources/claude-dir-customizations/.mcp.json`: the whole file, unpinned Claude args `["-y", "@danmoisan/drm-copilot-mcp"]`.
- `.codex/config.toml` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`: only the region from `[mcp_servers.drm-copilot]` to the line before `[permissions.orchestrator-workspace]`. The args line is `args = ["-y", "@danmoisan/drm-copilot-mcp@1.2.3"]` on one line; its version is read from `packages/mcp-server/package.json` `version` (`1.2.3`).

No difference had to be fixed in the source or in a target.
