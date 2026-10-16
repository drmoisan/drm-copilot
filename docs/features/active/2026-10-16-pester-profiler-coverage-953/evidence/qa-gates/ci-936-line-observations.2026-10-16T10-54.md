# CI #936 Line Observations (P7-T9, AC-12)

Timestamp: 2026-10-16T10-54
Command: sh SCRATCH/issue-953-compare.sh (line lookup L(key, nr) on both files) ; git diff --name-only origin/main...HEAD -- tests/scripts/codex-hooks ; git status --porcelain -- tests/scripts/codex-hooks
EXIT_CODE: 0
Output Summary: Under profiler mode the three #936 lines are recorded as covered (ci=1) on the PR head; they are uncovered (ci=0) in both breakpoint-mode baselines (run 38846579572 per ci-baseline-coverage-figures, and comparison baseline run 38885440106). Both git listings are empty, so no #936-owned test file is modified.

| line | baseline run 38846579572 | comparison baseline run 38885440106 | PR-head run 38887178530 |
|---|---|---|---|
| .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:41 | ci=0 mi=1 | ci=0 mi=1 | ci=1 mi=0 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:206 | ci=0 mi=1 | ci=0 mi=1 | ci=1 mi=0 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:207 | ci=0 mi=1 | ci=0 mi=1 | ci=1 mi=0 |
