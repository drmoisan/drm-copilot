# P0-T2 Policy Reads

Timestamp: 2026-10-09T02-56
Policy Order: (1) standing instructions and tone; (2) general code change; (3) general unit test; (4) Python language rules; (5) quality tiers and plan acceptance gates; (6) evidence and acceptance-criteria skills
Files read (in order):
1. CLAUDE.md
2. .claude/rules/tonality.md
3. .claude/rules/general-code-change.md
4. .claude/rules/general-unit-test.md
5. .claude/rules/python.md
6. .claude/rules/python-suppressions.md
7. .claude/rules/quality-tiers.md
8. .claude/rules/plan-acceptance-gates.md
9. .claude/skills/evidence-and-timestamp-conventions/SKILL.md
10. .claude/skills/acceptance-criteria-tracking/SKILL.md

Notes:
- python-suppressions.md: a file-level E402 ignore is not pre-authorized; explicit user approval is required (relevant to P3-T3 F2).
- OPERATOR_OVERRIDE: commit and push at every phase boundary (overrides the plan's "no commit before Phase 8" constraint); `python -S` for direct interpreter invocations; Pester through mcp__drm-copilot__run_poshqc_test instead of a scratchpad runner script.
