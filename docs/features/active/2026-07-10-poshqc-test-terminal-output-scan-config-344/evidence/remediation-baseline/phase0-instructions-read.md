# Phase 0 — Policy Instructions Read (Remediation Cycle 1)

- Issue: #344
- Timestamp: 2026-07-10T20-46
- Policy Order: CLAUDE.md → general-code-change → general-unit-test → language-specific (powershell, typescript, typescript-suppressions, python, python-suppressions)

## Files Read (in order)

1. `CLAUDE.md` (standing instructions; loaded into session context)
2. `.claude/rules/general-code-change.md` (loaded into session context)
3. `.claude/rules/general-unit-test.md` (loaded into session context)
4. `.claude/rules/powershell.md`
5. `.claude/rules/typescript.md`
6. `.claude/rules/typescript-suppressions.md`
7. `.claude/rules/python.md`
8. `.claude/rules/python-suppressions.md`

Additional standing rules loaded via CLAUDE.md context: `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `.claude/rules/orchestrator-state.md`, `.claude/rules/benchmark-baselines.md`, `.claude/rules/ci-workflows.md`.

## Notes

All files read in the required order. Languages in scope for this remediation cycle: PowerShell (R2 refactor), TypeScript (R1 coverage regeneration), Python (R3 coverage artifact generation). Suppressions policies reviewed; no suppressions are planned in this cycle.
