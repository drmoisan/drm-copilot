# Phase 0 Policy Reads (Issue #507)

Timestamp: 2026-09-29T17-28
Plan: docs/features/active/2026-08-22-push-down-root-folders-divergence-507/plan.2026-09-29T14-13.md
Tasks: P0-T1 through P0-T8

Policy Order:
1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/python.md
5. .claude/rules/python-suppressions.md
6. .claude/rules/typescript.md
7. .claude/rules/typescript-suppressions.md

Files read (in full, in the order above; line counts from `wc -l` in the worktree):
1. CLAUDE.md (56 lines) - tone policy, policy reading order, four-layer architecture, checkpoint path.
2. .claude/rules/general-code-change.md (80 lines) - design principles, seven-stage toolchain loop, 500-line cap, error handling, I/O isolation, no temp files in tests.
3. .claude/rules/general-unit-test.md (105 lines) - independence/isolation/determinism, line >= 85% and branch >= 75%, no production coverage exclusions, AAA, tests/ mirror layout, no temp files.
4. .claude/rules/python.md (100 lines) - Black, Ruff, Pyright, Pytest; strong typing; dependency seams; monkeypatch at import location.
5. .claude/rules/python-suppressions.md (143 lines) - pre-authorized noqa/type-ignore patterns; F401/D401 not authorized.
6. .claude/rules/typescript.md (74 lines) - Prettier, ESLint, tsc, Jest; no `any`; ES modules; AAA.
7. .claude/rules/typescript-suppressions.md (66 lines) - single-line eslint-disable-next-line and ts-expect-error with reasons only.

Count of files listed: 7
