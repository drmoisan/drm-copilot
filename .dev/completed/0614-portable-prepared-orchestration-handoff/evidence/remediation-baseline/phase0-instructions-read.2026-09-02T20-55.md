# Phase 0 Policy Read Evidence

Timestamp: 2026-09-02T21-09
Command: sequential `Get-Content -LiteralPath <policy-path>` for each policy below
EXIT_CODE: 0

## Policy Order

Policy Order: exact sequence listed below

1. `AGENTS.md`
2. `.agents/skills/general-code-change/SKILL.md`
3. `.agents/skills/general-unit-test/SKILL.md`
4. `.agents/skills/typescript/SKILL.md`
5. `.agents/skills/typescript-suppressions/SKILL.md`
6. `.agents/skills/python/SKILL.md`
7. `.agents/skills/python-suppressions/SKILL.md`
8. `.agents/skills/powershell/SKILL.md`
9. `.agents/skills/quality-tiers/SKILL.md`
10. `.agents/skills/architecture-boundaries/SKILL.md`
11. `.agents/skills/atomic-plan-contract/SKILL.md`
12. `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`
13. `.agents/skills/acceptance-criteria-tracking/SKILL.md`

Output Summary: All required policy files were read completely in the stated order. The applicable toolchain is the seven-stage format, lint, type-check, architecture-boundary, unit-test, contract/schema, and integration sequence; restart at formatting if a stage fails or changes files. Tests must be independent, isolated, fast, deterministic, and free of temporary files, external services, external processes, wall-clock reads, waits, or retries. Repository line coverage must remain at least 85%, branch coverage must remain at least 75% where measured, PowerShell is branch-exempt, and each new executable module, class, or method must reach at least 90% line coverage without regression on changed lines. Production, test, and reusable script files are capped at 500 lines. Evidence belongs under the feature's `evidence/<kind>/` directories. Acceptance criteria and plan tasks may be checked only after direct verification evidence exists, one marker at a time while preserving criterion text.

The parallel GitHub Copilot tone and general code/test policy mirrors were also read. They do not change the canonical shared-skill requirements above.
