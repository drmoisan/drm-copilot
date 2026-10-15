# Phase 0 Policy Reads (P0-T1)

Timestamp: 2026-10-09T02-51
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> quality-tiers -> python -> python-suppressions -> powershell -> plan-acceptance-gates -> parallel-orchestration

Files read, in order:

1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/quality-tiers.md
5. .claude/rules/python.md
6. .claude/rules/python-suppressions.md
7. .claude/rules/powershell.md
8. .claude/rules/plan-acceptance-gates.md
9. .claude/rules/parallel-orchestration.md

Output Summary: all nine policy files read from the worktree in the plan's order. Key constraints applied: 500-line file limit; Python line >= 85% and branch >= 75%; PowerShell line >= 85% (no branch gate); no temporary files in tests; no suppressions outside the pre-authorized list; parallel-orchestration.md and its bundled mirror are the only rules-tree files in scope.
