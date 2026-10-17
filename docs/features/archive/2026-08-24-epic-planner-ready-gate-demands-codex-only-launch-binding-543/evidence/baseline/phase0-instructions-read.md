# Phase 0 policy read record (issue #543)

Timestamp: 2026-10-02T05-01
Task: P0-T1
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> Python rules -> TypeScript rules

Files Read:
1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`
6. `.claude/rules/typescript.md`
7. `.claude/rules/typescript-suppressions.md`
8. `.claude/rules/quality-tiers.md`
9. `.claude/rules/tonality.md`
10. `.claude/rules/plan-acceptance-gates.md`
11. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

Notes:
- All eleven files were present in the worktree and read before any Phase 1 task.
- Binding constraints carried forward: 500-line file limit; line coverage >= 85% and branch coverage >= 75% per file; no temporary files in tests; suppressions only per the two suppression policies; evidence under `<FEATURE>/evidence/<kind>/`.
- Execution deviations in force for this run: D1 (merge adaptation), D2 (literal merge-base SHA `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`), D3 (no sh-pwsh route; native and poshqc-mcp substitutions per `evidence/other/pwsh-task-classification.2026-10-02T05-00.md`).
