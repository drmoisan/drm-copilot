# @danmoisan/drm-copilot-mcp

Stdio MCP server exposing drm-copilot repo-automation tools. Intended for use with MCP-compatible AI clients such as Claude Desktop, GitHub Copilot, and Codex CLI.

## Installation

### npx (recommended, no install required)

```bash
npx -y @danmoisan/drm-copilot-mcp
```

### Global install

```bash
npm install -g @danmoisan/drm-copilot-mcp
drm-copilot-mcp
```

## MCP Client Configuration

Add the following to your MCP client configuration file (e.g., `claude_desktop_config.json` or equivalent):

```json
{
  "mcpServers": {
    "drm-copilot": {
      "command": "npx",
      "args": ["-y", "@danmoisan/drm-copilot-mcp"]
    }
  }
}
```

## Runtime Prerequisites

- Node >=18 required to run the MCP server process.
- Python 3 and PowerShell 7+ required for script-backed tools (repo automation scripts).
- The MCP server must be run from within the drm-copilot repository workspace.

## Available Tools

The server exposes the drm-copilot repo-automation MCP tools defined in the `extensions/drm-copilot` source. See the extension README for the full tool listing.

## License

MIT
