# Phase 0 Policy Reads ([P0-T3])

Timestamp: 2026-10-11T23-42

Policy Order:
1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/powershell.md

Files Read:
- CLAUDE.md
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/powershell.md
- .claude/rules/quality-tiers.md
- .claude/rules/tonality.md
- .claude/rules/plan-acceptance-gates.md

Notes: the policy files are read-only for this run; no file under `.claude/rules/` or `.github/instructions/` is edited. Key constraints applied: 500-line cap, line coverage >= 85% (no PowerShell branch gate), no temporary files in tests, PowerShell 7+ compatibility, format -> analyze -> test loop with restart on change.
