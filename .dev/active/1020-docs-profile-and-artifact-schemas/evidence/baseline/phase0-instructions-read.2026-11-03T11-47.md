# Phase 0 Instructions Read ([P0-T1])

Timestamp: 2026-11-03T11-47
Policy Order: CLAUDE.md -> .claude/rules/general-code-change.md -> .claude/rules/general-unit-test.md -> .claude/rules/powershell.md -> .claude/rules/quality-tiers.md
Command: git show origin/epic/documentation-estate-tooling-integration:docs/features/epics/documentation-estate-tooling/epic.md
EXIT_CODE: 0
Output Summary: Policy files, feature documents, research, and the epic (read from the integration branch, not a main-based working copy) were read in the order below.

## Files Read (in order)

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/quality-tiers.md`
6. `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md` (version 0.6)
7. `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/user-story.md`
8. `research/2026-10-30T22-35-docs-profile-amendment-d3-d5-addendum-research.md` (amendment research)
9. `research/2026-10-30T21-45-docs-profile-powershell-design-addendum-research.md` (primary design research)
10. Epic `docs/features/epics/documentation-estate-tooling/epic.md` on `origin/epic/documentation-estate-tooling-integration`, headings:
    - `## Owner Decisions (2026-10-30, received through the coordinator)`
    - `### Amendment of 1020 required by D3 and D5`
    - `### 1020 amendment outcome (2026-10-31)`
    - `### Page-check contracts from the PowerShell preparation of 1021 (binding)`
    - `### Native-analyzer contracts from the preparation of 1031 (binding)`
    - `### Analyzer decisions from the first preparation of 1022 (language-independent)`
    - `### 1020 - docs-profile-and-artifact-schemas (wave 0, C3)`

## Statements

- The epic manifest (front matter `features:`) lists issues 1031, 1033, 1034, 1036, 1037, and 1038 (together with 1020, 1021, 1022, 1023, 1024), which are the anchor numbers this plan asserts.
- `## Owner Decisions` records `P1-P4 (2026-10-31, all approved)`; P1 is approved.
- Premise check: `.claude/lib/docs`, `schemas/docs`, `examples/docs`, and `tests/scripts/claude-lib/docs` do not exist on the branch at execution start, so the plan premise holds after the main merge into the integration branch.
