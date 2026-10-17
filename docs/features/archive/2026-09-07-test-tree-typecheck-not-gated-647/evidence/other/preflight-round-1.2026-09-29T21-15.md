# Preflight Round 1

Timestamp: 2026-09-29T21-15
Plan: docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/plan.2026-09-29T20-10.md
Reviewer: atomic-executor (DIRECTIVE: PREFLIGHT VALIDATION ONLY)
Result: PREFLIGHT: REVISIONS REQUIRED
Convergence: CONVERGENCE: FURTHER ROUNDS LIKELY

## Passed

- Format, task IDs, canonical evidence paths, Phase 0 policy reads and baseline field schema.
- Write set: the 71 distinct files in the baseline diagnostic log match the 71 Fix task titles in both directions; package.json, the workflow file, the new regression test, and spec.md are named in write-task titles.
- Line citations in models.ts, index.ts, package.json, and the workflow file.
- Base-state observations: tsc (jest config) exits 2 with 353 errors; prettier and lint output literals confirmed; AC-9 base run 6 passed.
- Ordering, diff anchoring, and #645 R20 coverage.

## Defects

1. Blocking: command route uses PowerShell syntax; the executor has no PowerShell tool and `pwsh -Command` is refused by the worktree guard. Rewrite all commands for the Bash tool (Git Bash) with `; echo "EXIT=$?"` capture and grep/sed pipelines (rule 4, rule 7 line counts, rule 11 R-DIAG, per-phase tsc and added-lines scans, P4-T9, P8-T1, P9-T6, P9-T14, P9-T15).
2. Blocking: P0-T20 and P9-T3 prettier check uses Push-Location; replace with a direct node prettier.cjs --check invocation over repository-relative globs.
3. Blocking: no actionlint gate for the modified workflow; add P0-T24, P8-T10, and extend P9-T12.
4. Blocking: line budgets exceed 500 in P4-T7, P6-T6, P6-T7, P7-T14; add the measured line-recovery edits.
5. Clarification: rule 6 parameter declarations would trip no-unused-vars; declare unused parameters only in the jest.fn type argument.
6. Minor: git diff --numstat literal output includes the path column.
7. Minor: P9-T9 lcov SF path matching must accept either separator.
8. Minor: P9-T1 rewrite outside the write set must stop as BLOCKED.
