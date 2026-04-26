# Phase 1 — feature-promotion-lifecycle/SKILL.md Diff Evidence

Timestamp: 2026-04-26T14:10:00Z

Command: `git diff -- ".claude/skills/feature-promotion-lifecycle/SKILL.md"`

EXIT_CODE: 0

Output Summary:
Lines changed:
- Line 3 (description): replaced "Prefer VS Code extension command execution..." with "Prefer the drmCopilotExtension MCP tools..."
- Line 18 (heading): "Extension-First Execution Rule" → "MCP-First Execution Rule"
- Line 20 (paragraph): replaced VS Code extension reference with MCP server reference
- Line 22 (label): "Canonical extension command invocations:" → "Canonical MCP tool invocations:"
- Lines 23–26 (4 command bullets): replaced VS Code command IDs with MCP tool forms
- Lines 28–30 (fallback block): replaced "Fallback rule:" with "Documented alternatives:"
- After line 44 heading `## Canonical Fallback Command Sequence`: inserted `### Fallback only — when MCP server is unreachable` subsection heading and introductory paragraph (5 lines added)
- After line 62 heading `## Canonical Fallback Short-Path Sequence (Minor Audit Mode)`: inserted `### Fallback only — when MCP server is unreachable` subsection heading and paragraph (4 lines added)

Original script bullets confirmed intact (unchanged in diff):
- `.claude/skills/feature-promotion-lifecycle/SKILL.md` line 47 (orig): `- feature: \`${workspaceFolder}/scripts/dev-tools/new-potential-entry.ps1 -ShortName ${short-name}\``
- `.claude/skills/feature-promotion-lifecycle/SKILL.md` line 48 (orig): `- bug: \`${workspaceFolder}/scripts/dev_tools/new_potential_bug_entry.py --short-name ${short-name}\``
- `.claude/skills/feature-promotion-lifecycle/SKILL.md` line 51 (orig): `\`poetry run python -m scripts.dev_tools.potential_to_issue ...\``
- `.claude/skills/feature-promotion-lifecycle/SKILL.md` line 57 (orig): `\`poetry run python -m scripts.dev_tools.new_active_feature_folder ...\``
- `.claude/skills/feature-promotion-lifecycle/SKILL.md` line 64 (orig): `\`poetry run python -m scripts.dev_tools.potential_to_issue ... --work-mode minor-audit\``
- `.claude/skills/feature-promotion-lifecycle/SKILL.md` line 70 (orig): `\`poetry run python -m scripts.dev_tools.new_active_feature_folder ... --work-mode minor-audit\``

All six original script bullets remain unchanged under their respective `### Fallback only — when MCP server is unreachable` subsections.
