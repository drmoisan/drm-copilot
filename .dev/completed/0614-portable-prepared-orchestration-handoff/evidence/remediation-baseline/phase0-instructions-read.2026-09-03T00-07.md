# Phase 0 Policy Reading Evidence

Timestamp: 2026-09-03T00-38:47-04:00

Policy Order:

1. `AGENTS.md`
2. `.agents/skills/general-code-change/SKILL.md`
3. `.agents/skills/general-unit-test/SKILL.md`
4. `.agents/skills/python/SKILL.md`
5. `.agents/skills/python-suppressions/SKILL.md`
6. `.agents/skills/typescript/SKILL.md`
7. `.agents/skills/typescript-suppressions/SKILL.md`
8. `.agents/skills/powershell/SKILL.md`
9. `.agents/skills/quality-tiers/SKILL.md`
10. `.agents/skills/architecture-boundaries/SKILL.md`
11. `.agents/skills/atomic-plan-contract/SKILL.md`
12. `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`
13. `.agents/skills/acceptance-criteria-tracking/SKILL.md`

Binding Rules:

- Unit tests must not create or use temporary files.
- No new Python or TypeScript suppression is permitted unless it matches a pre-authorized narrow pattern or receives explicit user approval.
- Production code, tests, and reusable scripts must remain at or below 500 lines, subject only to documented policy exceptions.
- The full toolchain must run in the prescribed order, and the QA loop restarts at formatting if a stage fails or changes governed files.
- Evidence must be written only below the canonical feature path `<FEATURE>/evidence/<kind>/`.
- Repository line coverage must remain at least 85%, branch coverage must remain at least 75% where measured, changed/new executable behavior must retain at least 90% coverage as required by the plan, and PowerShell is exempt only from branch coverage.
- Acceptance criteria may be checked only after direct evidence verifies delivery; criterion text must remain unchanged.

Output Summary: All thirteen required policy sources were read completely in the specified order, and the binding rules above govern this remediation execution.
