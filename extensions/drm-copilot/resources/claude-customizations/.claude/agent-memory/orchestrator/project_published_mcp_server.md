---
name: Published MCP server identity
description: The drm-copilot MCP server is published to npm and is now the source of truth; the side-loaded extension is no longer the MCP source.
type: project
---

The MCP server is published as `@danmoisan/drm-copilot-mcp`. Repo `.mcp.json` registers it under server key `drm-copilot`, so MCP tool references use the prefix `mcp__drm-copilot__<tool>`. The bundled mirror at `extensions/drm-copilot/resources/claude-dir-customizations/.mcp.json` matches the published config (`npx -y @danmoisan/drm-copilot-mcp`).

**Why:** The side-loaded VS Code extension at `extensions/drm-copilot/` previously hosted the MCP server via `McpStdioServerDefinition("drmCopilotExtension", ...)`. After publication on 2026-05-08, the published package became the source of truth; the side-loaded extension's MCP provider is no longer authoritative.

**How to apply:** When authoring new agents, skills, hooks, settings, or runtime tests, use `mcp__drm-copilot__<tool>` for MCP tool references. The string `mcp__drmCopilotExtension__` is obsolete in `.claude/`, `.codex/`, `.agents/`, `.github/agents/`, `.github/skills/`, and the bundled mirrors under `extensions/drm-copilot/resources/`. VS Code command IDs of the form `drmCopilotExtension.<command>` remain valid — they are owned by the side-loaded extension's `package.json` and are distinct from the MCP server identity.
