# Phase 0 Instructions Read (Issue 887)

Timestamp: 2026-10-12T14-29
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> language-specific (PowerShell) -> quality tiers

Files read (in order, from the executing worktree):

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/quality-tiers.md`

Policy edits: none

Notes:
- PowerShell toolchain order: format -> analyze -> test via PoshQC MCP tools; type checking not applicable.
- Line coverage threshold 85% (no root `CLAUDE.md` override); PowerShell is exempt from the branch threshold only.
- Temporary files in tests are prohibited.
