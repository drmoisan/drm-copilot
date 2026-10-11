# Baseline Line Counts (#841, P0-T9)

Timestamp: 2026-10-10T09-11
Command: git grep -c "" -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1 tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 .claude/skills/orchestrate/SKILL.md .claude/skills/feature-review-workflow/SKILL.md .agents/skills/feature-review-workflow/SKILL.md
EXIT_CODE: 0
Output Summary: five LineCount values recorded; PARSER_LINES_0=329, PESTER_LINES_0=205 (both <= 500).

ROUTE_SUBSTITUTION: scratch scripts A1-A8 prohibited by operator constraint; substitutes below. The plan command `sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 <paths>` was replaced by the A7 substitute `git grep -c "" -- <paths>` (all five files are tracked).

- .claude/lib/ci-gate/Invoke-CiGateParser.ps1 LineCount=329
- tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 LineCount=205
- .claude/skills/orchestrate/SKILL.md LineCount=447
- .claude/skills/feature-review-workflow/SKILL.md LineCount=181
- .agents/skills/feature-review-workflow/SKILL.md LineCount=178

PARSER_LINES_0=329
PESTER_LINES_0=205
