# Phase 0 policy and requirements reads ([P0-T1])

Timestamp: 2026-11-03T21-43
Command: Read tool over each file listed below (no shell command; read-only)
EXIT_CODE: 0
Policy Order: CLAUDE.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/powershell.md -> .claude/rules/quality-tiers.md -> (mirrored sources under .github/) -> feature requirements -> primary research -> epic headings

## Files read, in order

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/quality-tiers.md`
6. `.claude/rules/tonality.md` (loaded with the standing instructions)
7. Mirrored sources: `.github/copilot-instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md` (read in full); `.github/instructions/general-code-change.instructions.md` and `.github/instructions/general-unit-test.instructions.md` (section headings confirmed against the `.claude/rules/` mirrors already loaded)
8. `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/spec.md` (version 0.4, whole file)
9. `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/user-story.md` (whole file)
10. `docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/research/2026-10-30T22-45-docs-surface-analyzers-typescript-dotnet-research.md` (whole file)
11. `docs/features/epics/documentation-estate-tooling/epic.md`, headings: `## Owner Directive: Implementation Language (2026-10-30, refined)`, `### Artifact classes for this epic`, `## Owner Decisions (2026-10-30, received through the coordinator)`, `### Amendment of 1020 required by D3 and D5`, `### PowerShell contracts from the re-preparation of 1020 (binding; ...)`, `### Ledger contracts from the PowerShell preparation of 1023 (binding)`, `### Command contract decisions from the first preparation of 1023 (language-independent)`, `### Analyzer decisions from the first preparation of 1022 (language-independent)`, `### 1033 - docs-surface-analyzers-typescript-dotnet (wave 1, C4)`
12. 1020 `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md`: `### DocsSurface.psm1 (pure)` with `#### Element identifiers` and `#### Declaration-lines digest (D5)`, `### DocsAnalyzerRegistry.psm1`, `## Decisions Later Children Must Honor`
13. 1020 `plan.2026-10-30T16-08.md` `[P4-T1]` (membership-only registry suite)
14. 1022 `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/spec.md` `### Inventory command and snapshot builder`
15. 1023 `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/spec.md` `### Scanner precision limits (D3)` and `### #1022 and #1033 (PowerShell scanners) for precision-limit diagnostics`
16. `.claude/skills/execution-environment/SKILL.md` (loaded with the delegation)

## Output Summary

All policy files read in the required order; no conflicting instruction found between the `.claude/rules/` mirrors and the `.github/instructions/` sources. Feature requirements (spec v0.4, user story), the primary research file, and every upstream heading named under the plan's `## Required References` were read before any file outside `FEATURE/evidence/` was changed.
