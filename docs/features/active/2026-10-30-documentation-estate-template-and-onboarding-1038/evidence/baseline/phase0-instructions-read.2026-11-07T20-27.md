# Phase 0 instructions read

Timestamp: 2026-11-07T20-27
Command: Read (file reads, no shell command)
EXIT_CODE: 0
Output Summary: All fifteen entries read in the order below; no conflict found between the policy files.

Policy Order:
1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.claude/rules/general-code-change.md`
4. `.claude/rules/general-unit-test.md`
5. `.claude/rules/powershell.md`
6. `.github/instructions/powershell-code-change.instructions.md`
7. `.github/instructions/powershell-unit-test.instructions.md`
8. `.claude/rules/quality-tiers.md`
9. `.claude/rules/plan-acceptance-gates.md`
10. `.claude/skills/execution-environment/SKILL.md`
11. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
12. `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/spec.md`
13. `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/user-story.md`
14. `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/research/research.2026-10-30T23-29.md`
15. `docs/features/epics/documentation-estate-tooling/epic.md` (sections listed under the plan's Inputs)

Owner directive 2026-11-07 (recorded for this run): test gates run in parallel only (one `Invoke-PoshQCParallelTest` run and one `poetry run pytest -n auto` run, each re-run only after a fix); no single-process, seeded-shuffle or reversed-order runs; pre-existing baseline failures are recorded, not fixed.
