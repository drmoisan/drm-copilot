# Phase 0 Instructions Read — [P0-T1]

Timestamp: 2026-08-26T07-47
Task: [P0-T1]
Command: Read (policy files, in `policy-compliance-order` order)
EXIT_CODE: 0

Policy Order: `policy-compliance-order` skill order — (1) `CLAUDE.md` standing instructions; (2) `.claude/rules/general-code-change.md` cross-language code change policy; (3) `.claude/rules/general-unit-test.md` cross-language unit test policy; (4) language- and domain-specific rules for the files in scope, which for this plan are Python and TypeScript, plus the tier rule that the two general rules both reference.

## Files read (all six, in order)

1. `CLAUDE.md` — 4417 bytes. Standing instructions: tone policy, policy compliance reading order, path-scoped language rules loaded from `.claude/rules/`, four-layer runtime architecture, orchestration checkpoint path `artifacts/orchestration/orchestrator-state.json`.
2. `.claude/rules/general-code-change.md` — 4586 bytes. Design principles, class-versus-function guidance, the seven-stage mandatory toolchain loop with restart-from-step-1 on any failure or auto-fix, the 500-line file size limit, error handling, naming, public API compatibility, dependency policy, I/O boundaries.
3. `.claude/rules/general-unit-test.md` — 7373 bytes. Five core test properties, coverage requirements (line >= 85%, branch >= 75%), the coverage exclusion policy prohibiting any `src/` production path exclusion, scenario completeness, Arrange–Act–Assert, external dependency prohibition including the temp-file prohibition, test file location rule, test categories, determinism infrastructure.
4. `.claude/rules/quality-tiers.md` — 3709 bytes. T1–T4 tier definitions, source-of-truth statement naming `quality-tiers.yml` at repo root, the uniform-versus-tier-dependent gate matrix, and the rationale for uniform coverage thresholds.
5. `.claude/rules/python.md` — 5971 bytes. Toolchain (Black, Ruff, Pyright, Pytest) with the ordered loop, PEP 8 naming, strong typing, dataclasses, protocols, dependency seams, Pytest rules, prohibited behaviors.
6. `.claude/rules/typescript.md` — 4789 bytes. Toolchain (Prettier, ESLint, TSC, Jest) with the ordered loop, coding standards, ESLint stack, testing standards, architecture boundaries, property-based and mutation testing, golden tests, runtime determinism.

## Tier-lookup finding (required by this task's acceptance)

No file at the repository root of this worktree maps projects to rigor tiers. `.claude/rules/quality-tiers.md` names `quality-tiers.yml` at repo root as the source of truth, but that file does not exist here:

```
$ ls -la quality-tiers.yml
ls: cannot access 'quality-tiers.yml': No such file or directory
```

Worktree root checked: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6b0c3b38073271d8`.

Consequence, recorded so no later task in this plan attempts one: **no tier lookup is performed anywhere in this plan.** This costs nothing, because every threshold this plan is judged against is uniform across T1 through T4. `.claude/rules/quality-tiers.md` states line coverage >= 85% and branch coverage >= 75% apply uniformly across all tiers, and both `.claude/rules/python.md` and `.claude/rules/typescript.md` restate the same two uniform numbers. The tier-dependent column of the gate matrix (untyped escape hatches, property-test density, mutation score, contract breaking changes, determinism retry rate, golden tests, E2E scope) is not exercised by any acceptance condition in this plan.

## Output Summary

All six policy files read in the `policy-compliance-order` order and summarized above. No policy file was modified; the hard constraint against editing `.claude/rules/` and `.github/instructions/` is observed. The repository root carries no `quality-tiers.yml`, so no tier lookup is performed by this plan; the uniform >= 85% line and >= 75% branch thresholds apply and are the only coverage numbers this plan is judged against.
