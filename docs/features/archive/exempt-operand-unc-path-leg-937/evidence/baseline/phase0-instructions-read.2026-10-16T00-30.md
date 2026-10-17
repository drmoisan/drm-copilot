# Phase 0 Instructions Read (issue #937)

Timestamp: 2026-10-16T00-30
Task: P0-T1
Policy Order: CLAUDE.md, then .github repository tone and baseline policies, then PowerShell language policies, then .claude rule mirrors, then tier, acceptance-gate, and tone rules.

Files Read:

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.github/instructions/general-code-change.instructions.md`
4. `.github/instructions/general-unit-test.instructions.md`
5. `.github/instructions/powershell-code-change.instructions.md`
6. `.github/instructions/powershell-unit-test.instructions.md`
7. `.claude/rules/general-code-change.md`
8. `.claude/rules/general-unit-test.md`
9. `.claude/rules/powershell.md`
10. `.claude/rules/quality-tiers.md`
11. `quality-tiers.yml`
12. `.claude/rules/plan-acceptance-gates.md`
13. `.claude/rules/tonality.md`

Notes:

- `quality-tiers.yml` exists at the repository root; `.claude/hooks` and `.codex/hooks` are classified T3. Uniform line coverage default 85% applies; PowerShell has no branch-coverage gate.
- File size limit: 500 lines for production and test files.
- PowerShell toolchain: PoshQC MCP format, analyze, test (Option A per plan; no local `pwsh`).
