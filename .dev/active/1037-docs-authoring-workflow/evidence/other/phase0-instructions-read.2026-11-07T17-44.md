# Phase 0 Instructions Read (remediation plan [P0-T1])

Timestamp: 2026-11-07T17-44
Plan: docs/features/active/2026-10-30-docs-authoring-workflow-1037/remediation-plan.2026-11-07T17-30.md
Policy Order: CLAUDE.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/powershell.md -> .claude/rules/quality-tiers.md -> .claude/rules/tonality.md

Files read, in order:

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/quality-tiers.md`
6. `.claude/rules/tonality.md`

Also consulted: `.claude/skills/execution-environment/SKILL.md` (tool routes, launcher, commit route), `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (evidence paths and stamps), `.claude/rules/plan-acceptance-gates.md` (G1 to G13).

Notes: `quality-tiers.yml` exists at the repository root, so the uniform gates apply (85% PowerShell line coverage, no PowerShell branch gate); this cycle changes one Pester test file and one JSON manifest through a merge, and no Python or TypeScript file is in scope. Owner directive 2026-11-07: parallel test gates only.
