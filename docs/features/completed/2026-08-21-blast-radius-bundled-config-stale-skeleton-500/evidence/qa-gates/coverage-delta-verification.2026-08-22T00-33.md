# Coverage delta and threshold verification (Issue #500)

Timestamp: 2026-08-22T00:33:00Z
Issue: #500
Task: [P8-T12]

Command: the three coverage commands compared, each run once at baseline (Phase 0) and once
post-change (Phase 8):

```
poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
npm run test:coverage                       # working directory extensions/drm-copilot
mcp__drm-copilot__run_poshqc_test           # workspace_root = the worktree root
```

Per-file figures were read from `extensions/drm-copilot/coverage/lcov.info` (`LF`/`LH`/`BRF`/`BRH`
records) and from `artifacts/python/coverage.json`.

EXIT_CODE: 0

Output Summary:

## Python

| Column | Statements | Branches |
| --- | --- | --- |
| Baseline (P0-T8) | 92.60% | 85.19% |
| Post-change (P8-T4) | 92.60% | 85.19% |
| Delta | 0.00 | 0.00 |

Sources, per the plan's binding rule: the statement figure is `(Stmts - Miss) / Stmts` from the
terminal `TOTAL` row, cross-checked against `totals.percent_statements_covered`; the branch figure is
`totals.percent_branches_covered` in `artifacts/python/coverage.json`, which is **not** a report
cell. Neither figure is the combined `Cover` cell.

Underlying counters are identical across the two runs: `num_statements` 14939, `missing_lines` 1105,
`num_branches` 5488, `missing_branches` 813. **No regression.**

**Changed-lines coverage, Python.** This change set modifies **no Python production file**. The two
Python files it adds are test modules:

| File | Kind | Changed-lines coverage |
| --- | --- | --- |
| `tests/scripts/dev_tools/test_blast_radius_config_parity.py` | new test module, 387 lines | not in the coverage denominator; executed in full by the run, 14 of 14 cases passing |
| `tests/scripts/dev_tools/blast_radius_parity_test_support.py` | new test-support module, 172 lines | not in the coverage denominator; every constant and all four accessors are exercised by the 14 cases that import them |

The coverage selection is `--cov=scripts.dev_tools`, so `tests/` is outside the denominator by
construction, which is what `.claude/rules/general-unit-test.md` requires. The Python coverage
figures are therefore flat rather than improved, and that is the correct outcome for a change set
whose Python contribution is entirely test code.

## TypeScript

| Column | Statements | Branches | Functions | Lines |
| --- | --- | --- | --- | --- |
| Baseline (P0-T11) | 96.66% | 90.04% | 89.67% | 96.66% |
| Post-change (P8-T8) | 96.66% | 90.04% | 89.67% | 96.66% |
| Delta | 0.00 | 0.00 | 0.00 | 0.00 |

Ratios moved from 43055/44542 to 43071/44558 for statements and lines: the denominator grew by 16
and the numerator grew by 16, so every one of the 16 added statements is covered. Branch counters are
unchanged at 6122/6799.

**Changed-lines coverage, TypeScript.** This is the binding column, because the change edits an
exported constant in a module whose test file already exists.

| File | Kind | Lines (LH/LF) | Branches (BRH/BRF) |
| --- | --- | --- | --- |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` | production, edited by [P2-T1] and [P2-T2] | **468/468 = 100.00%** | 46/48 = 95.83% |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` | test, edited by [P2-T3] through [P2-T6] | test file, outside the denominator | n/a |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` | test, edited by [P2-T7] | test file, outside the denominator | n/a |
| `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` | test, edited by [P1-T4], [P4-T1], [P4-T2] | test file, outside the denominator | n/a |
| `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` | test helper, edited by [P4-T3] and [P4-T4] | test support, outside the denominator | n/a |

The single edited production module carries **100.00% line coverage**, so no changed production
line is uncovered and there is no reduction in coverage for the changed lines.

## PowerShell

| Column | Line coverage | Branch coverage |
| --- | --- | --- |
| Baseline (P0-T14) | 96.21% | not measurable |
| Post-change (P8-T11) | 96.21% | not measurable |
| Delta | 0.00 | n/a |

Counters are identical across the two runs: LINE covered 5792 / missed 228. Pester emits no BRANCH
counter in any output format, so no branch figure exists and no branch threshold applies per
`.claude/rules/quality-tiers.md`.

**Changed-lines coverage, PowerShell.** The only PowerShell file this change set touches is
`tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`, a test file outside the
coverage denominator. No PowerShell production file was modified.

## Threshold status

| Language | Line / statement | Threshold | Branch | Threshold | Result |
| --- | --- | --- | --- | --- | --- |
| Python | 92.60% | >= 85% | 85.19% | >= 75% | PASS |
| TypeScript | 96.66% | >= 85% | 90.04% | >= 75% | PASS |
| PowerShell | 96.21% | >= 85% | n/a | exempt | PASS |

## Coverage-configuration statement

**No `exclude` entry was added to any coverage configuration by this change set.** No entry was
added to, removed from, or modified in `pyproject.toml`, `extensions/drm-copilot/jest.config.cjs`,
or any other coverage configuration file. The complete set of files this change set modifies or adds
is:

- `.claude/rules/parallel-orchestration.md` and its bundled mirror
- `config/blast-radius.json` and its bundled counterpart
- `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`
- four TypeScript test and test-helper files under `extensions/drm-copilot/test/lib/push-down/`
- `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`
- two new Python test modules under `tests/scripts/dev_tools/`
- the plan of record and this feature's evidence artifacts

None of those is a coverage configuration file.
