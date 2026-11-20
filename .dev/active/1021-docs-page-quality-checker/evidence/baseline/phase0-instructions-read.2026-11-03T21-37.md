# Phase 0 Instructions Read - Issue #1021

Timestamp: 2026-11-03T21-37
Task: [P0-T1]
Policy Order: CLAUDE.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/powershell.md -> .claude/rules/quality-tiers.md

## Files Read (in order)

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/quality-tiers.md`
6. `docs/features/active/2026-10-30-docs-page-quality-checker-1021/spec.md`
7. `docs/features/active/2026-10-30-docs-page-quality-checker-1021/user-story.md`
8. `docs/features/active/2026-10-30-docs-page-quality-checker-1021/research/2026-10-30T22-45-docs-page-quality-checker-powershell-design-addendum-research.md` (sections 3 to 6, 16, 18)
9. `docs/features/epics/documentation-estate-tooling/epic.md` heading `### 1021 - docs-page-quality-checker (wave 1, C3)` (and `### Page-check contracts from the PowerShell preparation of 1021 (binding)`, `### Enforcement notes from the two preparations of 1034`)
10. `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md` `## API / CLI Surface` and `## Decisions Later Children Must Honor`

## Notes

- Skills applied: `policy-compliance-order`, `atomic-plan-contract`, `evidence-and-timestamp-conventions`, `acceptance-criteria-tracking`, `execution-environment`.
- SCRATCH is the session scratchpad subdirectory `issue-1021/`; recorded as the token `SCRATCH`.
- 1020 spec states that init template `Source` values are repository-relative strings read through `Context.ReadText`, not `$PSScriptRoot` joins; recorded for [P0-T2].
