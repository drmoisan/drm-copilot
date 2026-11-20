# Task Check [P2-T6]

Timestamp: 2026-11-20T07-37
Command: git -C <worktree> grep -l -e "mcp-server/README" -e "drm-copilot/README.md" -- tests extensions/drm-copilot/test; grep -c migrate_development_docs extensions/drm-copilot/README.md; grep -n for the section heading and tokens in packages/mcp-server/README.md
EXIT_CODE: 0
Output Summary: changed files `extensions/drm-copilot/README.md` (the name under `### Exposed MCP Tools`, a tool paragraph, and an entry under `### MCP Input Summary`; 3 occurrences of `migrate_development_docs`) and `packages/mcp-server/README.md` (new `## Development Docs Migration` section carrying `migrate-development-docs` and `--decisions`, the flags, the exit codes, the decision-file requirement for apply mode and the retained production documentation rule). Selection rule: contract tests that read a changed Markdown path; the search found none, so no test ran. Markdown is outside the `extensions/drm-copilot` Prettier globs.
