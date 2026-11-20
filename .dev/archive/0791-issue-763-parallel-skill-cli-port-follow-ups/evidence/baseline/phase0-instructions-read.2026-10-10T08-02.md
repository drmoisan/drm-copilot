# Phase 0 Policy Reads — Issue #791

Timestamp: 2026-10-10T08-02
Task: [P0-T1]
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> quality-tiers -> python -> python-suppressions -> shell -> powershell -> plan-acceptance-gates (order stated in plan task [P0-T1])

Files Read:
1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/quality-tiers.md
5. .claude/rules/python.md
6. .claude/rules/python-suppressions.md
7. .claude/rules/shell.md
8. .claude/rules/powershell.md
9. .claude/rules/plan-acceptance-gates.md

Notes:
- All nine files were read from the agent worktree checkout (branch `bug/issue-763-parallel-skill-cli-port-follow-ups-791`).
- `quality-tiers.yml` exists at the repository root, so the tier rules apply (plan-time fact 1).
- `.claude/rules/powershell.md` names the PoshQC MCP tools as the PowerShell toolchain; the operator constraint for this run restricts PowerShell verification to those tools (see `evidence/other/execution-deviations.2026-10-10T08-02.md`).
