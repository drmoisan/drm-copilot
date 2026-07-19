# Phase 0 — Policy Instructions Read

- Timestamp: 2026-07-19T00-40
- Issue: #370
- Feature: legacy-discovery-mcp-vscode

## Policy Order

Read in the required order per `.claude/skills/policy-compliance-order` and the plan's Phase 0 [P0-T1]:

1. `CLAUDE.md` (standing instructions, tone, policy-compliance order, architecture)
2. `.claude/rules/general-code-change.md` (cross-language code change policy)
3. `.claude/rules/general-unit-test.md` (cross-language unit test policy)
4. `.claude/rules/typescript.md` (TypeScript toolchain and coding standards)
5. `.claude/rules/typescript-suppressions.md` (TypeScript suppression authorization policy)
6. `.claude/rules/python.md` (Python CLI contracts referenced by the wrapper design; no Python authored in this feature)

## Files Read

- `CLAUDE.md`
- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/typescript.md`
- `.claude/rules/typescript-suppressions.md`
- `.claude/rules/python.md`
- Supporting (loaded via project context): `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `.claude/rules/architecture-boundaries.md`

## Key Constraints Recorded

- 500-line cap on any production/test file.
- Full toolchain loop order: format -> lint -> typecheck -> test; restart on any change/failure.
- Line coverage >= 85%, branch coverage >= 75% (uniform across tiers).
- No temporary files in tests; no real subprocess at the spawn boundary.
- Domain neutrality: no TaskMaster/TMW/Outlook/email/task-management identifiers in the exposure layer.
- Evidence artifacts under `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/<kind>/` only.
