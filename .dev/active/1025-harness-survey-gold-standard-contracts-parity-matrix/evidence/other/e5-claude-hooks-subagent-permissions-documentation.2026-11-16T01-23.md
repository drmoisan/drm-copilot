# E5 Result: Claude Code Hooks, Subagent and Permissions Details (Resolved by Documentation)

Timestamp: 2026-11-16T01-23
Command: documentation read recorded in research `### E5. Claude Code hooks, subagent and permissions details` (research/research.2026-10-30T21-08.md); sources fetched 2026-10-30
EXIT_CODE: 0
Output Summary: the three finding groups below are settled by vendor documentation; no runbook is needed. They inform the `hook-registration`, `permission` and `subagent-frontmatter-field` matrix entries.

## Subagent frontmatter fields

- Source: https://code.claude.com/docs/en/sub-agents (fetched 2026-10-30)
- Fields: `name`, `description`, `tools`, `disallowedTools`, `model`, `permissionMode`, `maxTurns`, `autoCompactWindow`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `omitClaudeMd`, `effort`, `isolation`, `color`, `initialPrompt`, `experimental`.
- Unknown fields are ignored without an error.
- Precedence: managed, then `--agents`, then `.claude/agents/`, then `~/.claude/agents/`, then plugin agents.
- Frontmatter hooks support every event; `Stop` in subagent frontmatter is converted to `SubagentStop`. Project agents skip frontmatter hooks until the folder is trusted.

## Hook configuration levels and handler types

- Source: https://code.claude.com/docs/en/hooks (fetched 2026-10-30)
- Levels: user, project and local settings, managed settings, plugin `hooks/hooks.json`, skill frontmatter and subagent frontmatter; entries merge across levels.
- Handler types: `command`, `http`, `mcp_tool`, `prompt`, `agent`.
- Exit code 2 blocks the action; other non-zero exit codes are non-blocking.

## Permission evaluation order

- Source: https://code.claude.com/docs/en/permissions (fetched 2026-10-30)
- Rules are evaluated deny, then ask, then allow.
- Path forms: `//path` is absolute, `~/path` is relative to the home folder, and `/path` is relative to the settings source; Windows paths are normalized to POSIX form (`//c/...`).

## Notes

- Several statements carry Claude Code version floors; the matrix records features, not versions.
- Skills: Claude Code does not read `.agents/skills` (https://code.claude.com/docs/en/skills, fetched 2026-10-30).
