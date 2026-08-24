# Phase 0 — Python Test and Coverage Baseline (Issue #412)

Task: [P0-T5]

Timestamp: 2026-07-25T17-23

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing` (run from the repo root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585`; executed with `-q` for output volume only, which does not change collection, execution, or coverage)

EXIT_CODE: 0

Output Summary:

```
2084 passed in 10.58s
TOTAL   Stmts 12259   Miss 1105   Branch 4448   BrPart 554   Cover 89%
Coverage LCOV written to file artifacts/python/lcov.info
```

All 2084 tests passed. Zero failures, zero errors, zero skips reported.

### Baseline coverage (numeric)

| Metric | Value |
|---|---|
| Line coverage | **90.99%** (11154 of 12259 lines hit) |
| Branch coverage | **81.83%** (3640 of 4448 branches hit) |
| Combined `Cover` column reported by pytest-cov | 89% |

Both values clear the uniform repository thresholds (line >= 85%, branch >= 75%).

The `Cover` column printed by pytest-cov under `--cov-branch` is coverage.py's combined
statement-plus-branch figure, not the line percentage. The separate line and branch
percentages above were computed from the LCOV report coverage.py wrote at
`artifacts/python/lcov.info` (`LF`/`LH` for lines, `BRF`/`BRH` for branches), which is a
tool output rather than an evidence artifact.

### Per-file baseline for the modules this feature will change

| File | Lines hit/found | Line % | Branches hit/found | Branch % |
|---|---|---|---|---|
| `scripts/dev_tools/validate_orchestrator_state.py` | 162 / 166 | 97.59% | 86 / 92 | 93.48% |
| `scripts/dev_tools/compute_complexity_floor.py` | 14 / 14 | 100.00% | 2 / 2 | 100.00% |
| `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py` | (term-missing) 18 stmts, 0 miss, 10 branch, 0 partial | 100% | — | 100% |
| `scripts/dev_tools/_orchestrator_state_complexity.py` (not modified; Hard Constraint 7) | 45 stmts, 0 miss, 20 branch, 0 partial | 100% | — | 100% |

### Push-down guard

Per Plan Conventions, the `.claude/state` push-down guard was executed immediately before
this pytest run:

```
pwsh -NoProfile -Command "Remove-Item -Path .claude/state -Recurse -Force -ErrorAction SilentlyContinue; exit 0"
```

Post-condition verified: `ls .claude/state` returns
`No such file or directory`. `; exit 0` was appended because a bare `Remove-Item ... -ErrorAction SilentlyContinue`
leaves a non-zero `$LASTEXITCODE` from the preceding pipeline in this shell; the appended
`exit 0` is the reset pattern required by `.claude/rules/ci-workflows.md` and does not change
the removal semantics.

### Pre-existing failures

None. The Python baseline is fully green.
