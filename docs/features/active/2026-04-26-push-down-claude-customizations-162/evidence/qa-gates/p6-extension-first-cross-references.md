# P6-T2 Extension-First Cross-Reference Audit

Timestamp: 2026-04-26T15-35
Command: `git grep -n -i -E "extension-first|Extension-First" -- ".claude/**/*.md" ".github/**/*.md"`
EXIT_CODE: 0 (zero matches after remediation)

## Output Summary

**Initial grep result (before remediation):** 1 match found.

| File | Line | Content | Classification |
|------|------|---------|----------------|
| `.github/skills/feature-promotion-lifecycle/SKILL.md` | 18 | `## Extension-First Execution Rule` | (b) External reference — parallel Copilot-native surface copy, not the Phase 1 in-scope `.claude/` file |

**In-scope file check (`.claude/skills/feature-promotion-lifecycle/SKILL.md`):**
Zero matches confirmed. Phase 1 rename was complete and correct.

**Remediation applied:**
The external reference at `.github/skills/feature-promotion-lifecycle/SKILL.md` was updated with the same MCP-First reframing applied in Phase 1 to the `.claude/` copy:
- Frontmatter description updated to reference MCP server.
- `## Extension-First Execution Rule` heading renamed to `## MCP-First Execution Rule`.
- Paragraph updated to reference `drmCopilotExtension` MCP server.
- `Canonical extension command invocations:` label renamed to `Canonical MCP tool invocations:`.
- Four VS Code command bullets replaced with `mcp__drmCopilotExtension__*` MCP tool form.
- `Fallback rule:` block replaced with `Documented alternatives:` block (VS Code commands and direct scripts remain as documented fallbacks).

**Post-remediation grep result:** 0 matches in both `.claude/**/*.md` and `.github/**/*.md`.

Zero in-scope-file matches (`.claude/skills/feature-promotion-lifecycle/SKILL.md`): confirmed.
Zero external references remaining after remediation: confirmed.
