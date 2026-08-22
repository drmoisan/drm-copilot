# Phase 0 — Policy Instructions Read (#501)

Timestamp: 2026-08-21T22-05

Policy Order: The repository policy-compliance reading order defined in `CLAUDE.md` and `.claude/skills/policy-compliance-order/SKILL.md`, restricted to the languages in scope for this plan (PowerShell production and test code; Python only as a named-test gate).

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/quality-tiers.md`
6. `.claude/rules/plan-acceptance-gates.md`

Task: [P0-T1]

Output Summary: All six policy files read prior to any code or test change. Key constraints carried into execution: PowerShell toolchain order format -> analyze -> test (no type-check stage); 500-line ceiling on production, test, and reusable script files; per-batch cap of at most 3 production files and 3 test files; line coverage >= 85% with no branch-coverage gate for Pester and no production PowerShell file excluded from the coverage denominator; no temporary files in tests; no external dependencies or child-process spawns in unit tests; wrapper/scriptblock design seams preferred over generic runner frameworks.
