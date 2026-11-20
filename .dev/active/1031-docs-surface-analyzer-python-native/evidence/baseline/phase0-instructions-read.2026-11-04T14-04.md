# Phase 0 Policy Read Evidence ([P0-T1])

Timestamp: 2026-11-04T14-04
Plan: docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/plan.2026-10-30T18-38.md
Policy Order: CLAUDE.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/python.md -> .claude/rules/python-suppressions.md -> .claude/rules/powershell.md -> .claude/rules/typescript.md -> .claude/rules/quality-tiers.md, each with its .github/instructions source

## Files read (in order)

1. CLAUDE.md
2. .github/copilot-instructions.md
3. .claude/rules/tonality.md
4. .claude/rules/general-code-change.md
5. .github/instructions/general-code-change.instructions.md
6. .claude/rules/general-unit-test.md
7. .github/instructions/general-unit-test.instructions.md
8. .claude/rules/python.md
9. .github/instructions/python-code-change.instructions.md
10. .github/instructions/python-unit-test.instructions.md
11. .claude/rules/python-suppressions.md
12. .claude/rules/powershell.md
13. .github/instructions/powershell-code-change.instructions.md
14. .github/instructions/powershell-unit-test.instructions.md
15. .claude/rules/typescript.md
16. .github/instructions/typescript-code-change.instructions.md
17. .github/instructions/typescript-unit-test.instructions.md
18. .claude/rules/quality-tiers.md
19. FEATURE/spec.md
20. FEATURE/user-story.md
21. FEATURE/research/research.2026-10-30T22-48.md (sections 3 to 6)
22. docs/features/epics/documentation-estate-tooling/epic.md: `## Owner Decisions`, `### Amendment of 1020 required by D3 and D5`, `## Owner Questions Raised by the Refined Directive`, `### PowerShell contracts from the re-preparation of 1020`, `### 1020 amendment outcome (2026-10-31)`, `### Native-analyzer contracts from the preparation of 1031 (binding)`
23. 1022 spec (docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/spec.md): `## Behavior`, `## Precision Limit`, `## Inputs / Outputs`, `## API / CLI Surface`, `## Data & State`, `## Contracts for 1031 and Later Children` (including `### Declaration string per kind`, `### Source normalization and declaration-lines digest (D5)`, `### Other element fields 1031 reproduces`, `### Shared fixtures`)
24. 1020 spec sections `### DocsSurface.psm1 (pure)`, `### DocsAnalyzerRegistry.psm1`, `### Entry script (Invoke-DocsCommand.ps1)` and `## Decisions Later Children Must Honor` are read in [P0-T2] alongside the delivered modules.

## Notes

- Scope of this delegation: Phase 0 to Phase 3.
- Evidence records scratch locations only as the token SCRATCH.
- Observation for later phases: the delivered 1022 diagnostic codes use the upper-case grammar `^[A-Z][A-Z0-9_]*$` (for example `CLI_DYNAMIC_REGISTRATION`); the helper reproduces the corpus codes exactly, since [P3-T4] asserts equal `code` values.
