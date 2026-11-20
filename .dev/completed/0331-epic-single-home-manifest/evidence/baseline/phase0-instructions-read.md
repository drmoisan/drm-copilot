# Phase 0 — Policy Instructions Read (#331)

Timestamp: 2026-07-07T21-08

Policy Order: CLAUDE.md → .claude/rules/general-code-change.md → .claude/rules/general-unit-test.md → .claude/rules/quality-tiers.md → .claude/rules/orchestrator-state.md → language rules (.claude/rules/python.md, .claude/rules/python-suppressions.md, .claude/rules/typescript.md, .claude/rules/typescript-suppressions.md, .claude/rules/self-explanatory-code-commenting.md, .claude/rules/architecture-boundaries.md)

Files read (explicit list):
- CLAUDE.md (standing instructions; auto-loaded)
- .claude/rules/general-code-change.md (cross-language code change policy; 500-line file limit)
- .claude/rules/general-unit-test.md (cross-language unit test policy; no temp files; coverage)
- .claude/rules/quality-tiers.md (uniform coverage thresholds: line >= 85%, branch >= 75%)
- .claude/rules/orchestrator-state.md (presence-gated / key-gated validator idiom reference)
- .claude/rules/benchmark-baselines.md (auto-loaded)
- .claude/rules/ci-workflows.md (auto-loaded)
- .claude/rules/tonality.md (auto-loaded)
- .claude/rules/python.md (Python toolchain: black, ruff, pyright, pytest)
- .claude/rules/python-suppressions.md (Python suppression authorization policy)
- .claude/rules/typescript.md (TypeScript toolchain: prettier, eslint, tsc, tests)
- .claude/rules/typescript-suppressions.md (TypeScript suppression authorization policy)
- .claude/rules/architecture-boundaries.md (dependency-cruiser boundaries)
- .claude/rules/self-explanatory-code-commenting.md (docstring/comment requirements)

Plan and requirements sources read:
- docs/features/active/2026-07-07-epic-single-home-manifest-331/plan.2026-07-07T20-29.md (plan of record)
- docs/features/active/2026-07-07-epic-single-home-manifest-331/spec.md (authoritative requirements)
- docs/features/active/2026-07-07-epic-single-home-manifest-331/research/2026-07-07-implementation-surface-mapping.md (surface map)

Output Summary: All policy files in the required order were read prior to execution. Preflight confirmed all cited files, functions, and line references exist and the toolchains (poetry 2.3.2, node v24, npm 11) are runnable.
