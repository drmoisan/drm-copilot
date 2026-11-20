# Phase 0 Instructions Read (issue #1022)

Timestamp: 2026-11-03T21-41
Task: [P0-T1]
Policy Order: CLAUDE.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/powershell.md -> .claude/rules/quality-tiers.md -> .github/instructions sources -> feature documents -> epic sections -> 1020 spec decisions

## Files read (in order)

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/quality-tiers.md`
6. `.claude/rules/tonality.md` (loaded with `CLAUDE.md`)
7. `.github/copilot-instructions.md`
8. `.github/instructions/general-code-change.instructions.md`
9. `.github/instructions/general-unit-test.instructions.md`
10. `.github/instructions/powershell-code-change.instructions.md`
11. `.github/instructions/powershell-unit-test.instructions.md`
12. `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/spec.md` (version 0.3, in full)
13. `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/user-story.md` (in full)
14. `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/research/2026-10-30T22-40-docs-surface-analyzers-python-config-powershell-addendum.md` (in full)
15. `docs/features/epics/documentation-estate-tooling/epic.md`: `## Owner Directive: Implementation Language (2026-10-30, refined)`, `### Artifact classes for this epic`, `## Owner Decisions`, `### Amendment of 1020 required by D3 and D5`, `### PowerShell contracts from the re-preparation of 1020`, `### Native-analyzer contracts from the preparation of 1031 (binding)`, `### Analyzer decisions from the first preparation of 1022`, `### 1022 - docs-surface-analyzers-python-config (wave 1, C4)`, `### 1031 - docs-surface-analyzer-python-native (wave 2, C3)`
16. `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md`: `### DocsSurface.psm1 (pure)`, `#### Element identifiers`, `#### Declaration-lines digest (D5)`, `### DocsAnalyzerRegistry.psm1`, `### Envelope schema: docs-command-envelope`, `## Decisions Later Children Must Honor`
17. `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/plan.2026-10-30T16-46.md` (plan of record, in full)

## Notes

- Work mode: `full-feature`; AC sources are `spec.md` and `user-story.md` `## Acceptance Criteria`.
- Language rule: every new production and test file is PowerShell; no Python, TypeScript, hook, skill, agent or MCP file is created.
- The `.github/instructions` general sources are byte-level mirrors of the `.claude/rules` summaries already loaded; no conflict was found between any two policy documents.
