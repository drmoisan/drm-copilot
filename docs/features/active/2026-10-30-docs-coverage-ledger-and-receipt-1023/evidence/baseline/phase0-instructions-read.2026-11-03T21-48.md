# Phase 0 Policy and Requirements Reads ([P0-T2])

Timestamp: 2026-11-03T21-48
Command: Read tool over each file below, in the order listed (read-only; nothing written to the tree)
EXIT_CODE: 0
Output Summary: 24 files read in the required order; no conflicting instruction found. The design source differs from `spec.md` version 0.3 on precision-limit representation (addendum `precision_limits[]` records versus spec marked ledger entries), the conflict finding code (addendum `DOCS_MUTATION_FAILED` versus spec `DOCS_CLI_RUNTIME`) and the owner-question lettering; per the plan `Design source` line, `spec.md` governs on each.
Policy Order: CLAUDE.md -> .github/copilot-instructions.md -> .claude/rules/general-code-change.md -> .github/instructions/general-code-change.instructions.md -> .claude/rules/general-unit-test.md -> .github/instructions/general-unit-test.instructions.md -> .claude/rules/powershell.md -> .github/instructions/powershell-code-change.instructions.md -> .github/instructions/powershell-unit-test.instructions.md -> .claude/rules/quality-tiers.md -> requirements and environment sources

## Files read (in order)

1. `CLAUDE.md` (standing instructions; loaded in the session context)
2. `.github/copilot-instructions.md`
3. `.claude/rules/general-code-change.md` (loaded in the session context)
4. `.github/instructions/general-code-change.instructions.md`
5. `.claude/rules/general-unit-test.md` (loaded in the session context)
6. `.github/instructions/general-unit-test.instructions.md`
7. `.claude/rules/powershell.md`
8. `.github/instructions/powershell-code-change.instructions.md`
9. `.github/instructions/powershell-unit-test.instructions.md`
10. `.claude/rules/quality-tiers.md` (loaded in the session context; `quality-tiers.yml` exists at the repository root, so tiers apply; `.claude/lib/docs` is T3)
11. `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/spec.md` (version 0.3, all sections)
12. `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/user-story.md`
13. `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/research/2026-10-30T22-40-docs-coverage-ledger-and-receipt-powershell-addendum.md` (design source, sections 0 through 12, numeric derivation, pre-mortem, owner questions, items to confirm)
14. `docs/features/epics/documentation-estate-tooling/epic.md` section `## Owner Directive: Implementation Language (2026-10-30, refined)` with `### Artifact classes for this epic`
15. `docs/features/epics/documentation-estate-tooling/epic.md` section `## Owner Decisions (2026-10-30, received through the coordinator)`
16. `docs/features/epics/documentation-estate-tooling/epic.md` section `### Amendment of 1020 required by D3 and D5`
17. `docs/features/epics/documentation-estate-tooling/epic.md` section `### PowerShell contracts from the re-preparation of 1020 (binding; authoritative text in 1020 spec.md ...)` through `### Page-check contracts from the PowerShell preparation of 1021 (binding)` (includes `### Ledger contracts from the PowerShell preparation of 1023 (binding)`)
18. `docs/features/epics/documentation-estate-tooling/epic.md` section `### 1023 - docs-coverage-ledger-and-receipt (wave 1, C4)`
19. `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md` section `## Decisions Later Children Must Honor`
20. `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/research/2026-10-30T22-35-docs-profile-amendment-d3-d5-addendum-research.md` (sections 0 through 5)
21. `.claude/skills/execution-environment/SKILL.md` (loaded in the session context)
22. `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `.claude/skills/acceptance-criteria-tracking/SKILL.md` (loaded in the session context)
23. `.claude/hooks/check-powershell-test-purity.ps1` (forbidden test tokens, read for the test rules)
24. `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/plan.2026-10-30T16-51.md` (the plan of record)

## Notes recorded for execution

- Work mode `full-feature`: AC sources are `spec.md` (33 items) and `user-story.md` (23 items) `## Acceptance Criteria`.
- The PowerShell policy names the MCP PoshQC tools as the agent route; per the `execution-environment` skill, PoshQC MCP results carry no output, so counts and coverage are read from `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` produced by branch-current `Invoke-PoshQCTest` runs launched from a `sh` file under `SCRATCH`.
- Language rule: every production and test artifact of this feature is PowerShell; no Python or TypeScript file is created or edited.
