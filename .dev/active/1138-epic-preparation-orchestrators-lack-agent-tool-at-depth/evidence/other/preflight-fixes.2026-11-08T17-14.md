# Preflight Fixes

Timestamp: 2026-11-08T17-14
Plan: docs/features/active/2026-11-08-epic-preparation-orchestrators-lack-agent-tool-at-depth-1138/plan.2026-11-08T11-44.md

## Fixes

1. `## Pre-Mortem` (Test isolation bullet) | inaccurate literal | "one `pytest -n auto` run per phase" changed to "one `pytest -n auto` run in Phase 0 and in Phase 5"; the plan runs the gates only in P0-T3/P0-T4 and P5-T3/P5-T4.
2. [P0-T3] | evidence source gap | added the coverage source for a run with a failed shard: `Invoke-PoshQCParallelTest` writes the merged `artifacts/pester/powershell-coverage.xml` only after a fully green run, so the per-file baseline figure is read from the per-shard `powershell-coverage.xml` files merged with the exported `Merge-PoshQCCoverageReport`.
3. [P1-T2] | test-isolation clarification | the "guarded import failure denies" It now states that it follows the B1 pattern including the reset of the dependency-failure state in `finally`, so a recorded failure does not deny later It blocks in the same file. The assertion is unchanged.
4. [P5-T1] | unsatisfiable literal | "`git status --porcelain` is empty after the formatter" changed to "shows no tracked file modified by the formatter". Phase 0 evidence artifacts are untracked when P5-T1 runs (the commit rule covers Phases 1 to 4 only), so an empty porcelain could not hold; the intended observation is that the formatter changed no file.
