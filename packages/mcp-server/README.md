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
      "args": ["-y", "@danmoisan/drm-copilot-mcp"],
      "cwd": "/absolute/path/to/your/workspace"
    }
  }
}
```

Set `cwd` to the absolute path of the workspace root that the MCP server tools should operate on.

## Runtime Prerequisites

- Node >=18 required to run the MCP server process.
- Python 3 and PowerShell 7+ required for script-backed tools (repo automation scripts).
- The MCP server must be run from within the drm-copilot repository workspace.

## Available Tools

The server exposes the drm-copilot repo-automation MCP tools defined in the `extensions/drm-copilot` source. See the extension README for the full tool listing.

## Development Docs Migration

The package bin also runs the `migrate_development_docs` tool (issue #1016) as a subcommand, without the VS Code extension:

```bash
npx -y @danmoisan/drm-copilot-mcp migrate-development-docs --workspace <path> --mode dry-run|apply [--decisions <path>] [--report-dir <path>]
```

- `--workspace`: repository root to migrate (required).
- `--mode`: `dry-run` reports the plan and writes nothing outside the report directory; `apply` moves development records from `docs/` to `.dev/` with `git mv`, renames feature folders and rewrites references (required). The tool never commits.
- `--decisions`: decision file (`folder-rename-decisions.<UTC>.json`). Apply mode refuses without it when the dry run reports held items or open global choices, and refuses when the file leaves a held item or a required global choice unset or when its `source_digest` differs from a fresh dry run.
- `--report-dir`: directory for the `dev-docs-migration-dry-run.<UTC>.md` and `.json` reports; when omitted, no report file is written.

Exit codes: `0` success; `1` refusal or execution error, with the reason on standard error; `2` usage error (unknown flag, missing `--workspace` or `--mode`, invalid mode). Standard output carries the Markdown summary.

Entries under `docs/` that the mapping table does not map, other than `docs/features/`, are retained production documentation: they are reported, never moved or rewritten, and never cause a refusal. After apply, `docs/` holds `docs/README.md` and that production documentation.

Before a release that carries the subcommand, run the branch build from the repository as `node packages/mcp-server/out/mcp-server.js migrate-development-docs ...`.

## License

MIT
