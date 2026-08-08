# Coverage Delta and Threshold Verification (P7-T9)

Timestamp: 2026-08-07T20-30

Task: [P7-T9]

Feature: 2026-08-07-parallel-schema-validators-444 (issue #444)

Branch: `feature/parallel-schema-validators-444`

Thresholds applied (uniform across tiers T1-T4, per `.claude/rules/general-unit-test.md` and
`.claude/rules/quality-tiers.md`): **line >= 85%**, **branch >= 75%**, and **no regression on changed
lines**.

## Verdict

**PASS.** Every required numeric value was obtained. Aggregate line and branch coverage improved on
both surfaces. All six new Python modules and all five new TypeScript modules exceed both thresholds.
Every line added or modified by this feature in the five pre-existing source files is covered by
tests (zero uncovered changed lines).

---

## 1. Aggregate Coverage Delta

### Python

Source of baseline: `evidence/baseline/python-test-coverage-baseline.2026-08-07T18-05.md` (P0-T5).
Source of post-change: `evidence/qa-gates/final-qc-python-test-coverage.2026-08-07T20-10.md` (P7-T4).

| Metric | Baseline (P0-T5) | Post-change (P7-T4) | Delta | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- |
| Line (statement) coverage | 91.32% (11619/12724) | **91.71%** (12247/13354) | **+0.39 pp** | >= 85% | PASS |
| Branch coverage | 82.54% (3820/4628) | **83.58%** (4122/4932) | **+1.04 pp** | >= 75% | PASS |
| Tests passed | 2465 | 2835 | +370 | all pass | PASS |
| Combined `percent_covered` | 88.98% | 89.52% | +0.54 pp | (informational) | — |

Both figures moved upward. No aggregate regression.

### TypeScript

Source of baseline: `evidence/baseline/ts-test-coverage-baseline.2026-08-07T18-08.md` (P0-T9).
Source of post-change: `evidence/qa-gates/final-qc-ts-test-coverage.2026-08-07T20-17.md` (P7-T8).

| Metric | Baseline (P0-T9) | Post-change (P7-T8) | Delta | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- |
| Line coverage | 96.34% (37718/39147) | **96.49%** (39833/41279) | **+0.15 pp** | >= 85% | PASS |
| Branch coverage | 89.27% (5220/5847) | **89.75%** (5582/6219) | **+0.48 pp** | >= 75% | PASS |
| Statement coverage | 96.34% | 96.49% | +0.15 pp | >= 85% | PASS |
| Function coverage | 89.51% (1101/1230) | 89.95% (1155/1284) | +0.44 pp | (informational) | — |
| Test suites | 169 | 177 | +8 | all pass | PASS |
| Tests passed | 2061 | 2363 | +302 | all pass | PASS |

Both figures moved upward. No aggregate regression.

---

## 2. Per-New-Module Coverage — Python (6 modules)

Derivation method: the `--cov-report=term-missing` per-file table gives the combined `Cover` column
and the missing-line list. The separate line and branch percentages below are derived from the same
coverage data file re-serialized with `poetry run coverage json` into the session scratchpad (the same
method used by the P0-T5 baseline). No coverage artifact was added to the repository.

All six modules are **new files created by this feature**, so there is no prior coverage figure for
them; "baseline coverage" is `n/a (module did not exist)` and "new/changed-code coverage" is identical
to the post-change module coverage, because 100% of each module's lines are new code.

| # | Module (`scripts/dev_tools/`) | Baseline | Post-change LINE | Post-change BRANCH | New-code LINE | New-code BRANCH | Line >= 85% | Branch >= 75% |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `_parallel_state_common.py` | n/a (new) | **100.00%** (122/122) | **100.00%** (62/62) | 100.00% | 100.00% | PASS | PASS |
| 2 | `_parallel_state_structures.py` | n/a (new) | **100.00%** (149/149) | **100.00%** (86/86) | 100.00% | 100.00% | PASS | PASS |
| 3 | `_parallel_state_records.py` | n/a (new) | **100.00%** (88/88) | **100.00%** (50/50) | 100.00% | 100.00% | PASS | PASS |
| 4 | `validate_parallel_orchestrator_state.py` | n/a (new) | **97.56%** (80/82) | **94.12%** (32/34) | 97.56% | 94.12% | PASS | PASS |
| 5 | `validate_parallel_planner_state.py` | n/a (new) | **100.00%** (112/112) | **100.00%** (46/46) | 100.00% | 100.00% | PASS | PASS |
| 6 | `parallel_manifest_contract.py` | n/a (new) | **100.00%** (65/65) | **100.00%** (22/22) | 100.00% | 100.00% | PASS | PASS |

Counts are `covered / total` statements and `covered / total` branch exits.

### Uncovered lines in module 4

`validate_parallel_orchestrator_state.py` reports two uncovered statements, lines **226** and **265**.
Both are defensive type guards inside the completion gate:

- Line 226 — `return False` in `_has_close_mutation` when `mutations` is not a list.
- Line 265 — `continue` in `_validate_completion` when an `items[]` entry is not a dict.

Neither is reachable through the public entry point in a way that a test can exercise meaningfully:
invariant 1 (required keys) and invariant 5 (item shape) already emit errors for those same malformed
shapes before the `require_complete` gate runs, so the guards exist to keep the gate total rather than
to encode reachable behavior. They are retained as fail-safe guards rather than removed, and the
module still clears both thresholds by a wide margin (97.56% line, 94.12% branch). No test was
weakened and no threshold was lowered to reach this result.

### Python module not counted as new

`scripts/dev_tools/parallel_cohort_computation.py` appears in the per-file table at 100% but is a
pre-existing tracked file, not a module created by this feature. It is excluded from the new-module
set above.

---

## 3. Per-New-Module Coverage — TypeScript (5 modules)

Derivation method: the `text-summary` reporter emits aggregate totals only, as anticipated by the
P7-T9 task text. Per-module figures below are parsed from `extensions/drm-copilot/coverage/lcov.info`,
written by the configured `lcov` reporter during the P7-T8 run. `jest.config.cjs` sets
`coverageProvider: "v8"`, so the lcov `DA:` records map to physical source lines of the `.ts` files
(verified: each record's `LF` equals the source file's physical line count). Line % is `LH/LF`;
branch % is `BRH/BRF`.

All five modules are **new files created by this feature**, so "baseline coverage" is
`n/a (module did not exist)` and "new/changed-code coverage" equals the post-change module coverage.

| # | Module (`extensions/drm-copilot/src/lib/validate/`) | Baseline | Post-change LINE | Post-change BRANCH | New-code LINE | New-code BRANCH | Line >= 85% | Branch >= 75% |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `parallel-state-shared.ts` | n/a (new) | **96.91%** (471/486) | **96.04%** (97/101) | 96.91% | 96.04% | PASS | PASS |
| 2 | `parallel-state-structures.ts` | n/a (new) | **100.00%** (496/496) | **98.21%** (110/112) | 100.00% | 98.21% | PASS | PASS |
| 3 | `parallel-state-records.ts` | n/a (new) | **100.00%** (347/347) | **100.00%** (66/66) | 100.00% | 100.00% | PASS | PASS |
| 4 | `parallel-orchestrator-state-core.ts` | n/a (new) | **99.38%** (318/320) | **92.11%** (35/38) | 99.38% | 92.11% | PASS | PASS |
| 5 | `parallel-planner-state-core.ts` | n/a (new) | **100.00%** (453/453) | **97.96%** (48/49) | 100.00% | 97.96% | PASS | PASS |

Counts are `LH/LF` lines and `BRH/BRF` branches from `coverage/lcov.info`.

### Jest per-file `coverageThreshold` gate

P5-T5 added `lines: 85` / `branches: 75` entries to `extensions/drm-copilot/jest.config.cjs` for four
of these modules: `parallel-state-shared.ts`, `parallel-state-structures.ts`,
`parallel-orchestrator-state-core.ts`, and `parallel-planner-state-core.ts`. The P7-T8 exit code of 0
confirms all four gates passed.

Observation (recorded, not remediated in this phase): `parallel-state-records.ts` has **no** per-file
`coverageThreshold` entry. That module was introduced during Phase 4 as a third structural split
beyond the two production modules the plan's P5-T5 enumerated, and P5-T5's task text fixes the entry
list at exactly four files with the constraint that no existing entry is modified. The module's
measured coverage is 100.00% line / 100.00% branch, so the P7-T9 threshold verification passes on the
numbers; the gap is a durability gap in the automated gate, not a coverage shortfall. Adding a fifth
`coverageThreshold` entry is outside the approved plan's task set and is therefore surfaced here for
the reviewer rather than performed.

---

## 4. No Regression on Changed Lines — Modified Files

Five pre-existing source files were modified by this feature. For each, the added/modified
post-change source line ranges were taken from `git diff -U0` hunk headers and cross-referenced
against per-line hit data (coverage.py `missing_lines` for Python; lcov `DA:` records for TypeScript).

| File | Changed source lines | Uncovered among changed | Post-change LINE | Post-change BRANCH | Verdict |
| --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/validate_orchestration_artifacts.py` | 31-36, 258-279, 348-357 (38 lines) | **0** | 93.55% (116/124) | 84.00% (42/50) | PASS |
| `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` | 17-24, 262-277 (24 lines) | **0** | 100.00% (281/281) | 98.48% (65/66) | PASS |
| `extensions/drm-copilot/src/mcp-tool-inputs.ts` | 436-437 (2 lines) | **0** | 94.57% (453/479) | 92.75% (64/69) | PASS |
| `extensions/drm-copilot/src/mcp-tool-definitions.ts` | 412-413, 425, 445 (4 lines) | **0** | 100.00% (453/453) | 0/0 branches | PASS |
| `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts` | 345-346, 358, 378 (4 lines) | **0** | 100.00% (404/404) | 0/0 branches | PASS |

Changed-line coverage is therefore **100% (0 of 72 changed lines uncovered)** across all five modified
files. No changed line lost coverage.

The two definition-surface files report `BRF: 0` because they contain only exported literal data
structures with no conditional branches; a zero-denominator branch metric is not a threshold failure.

Uncovered lines remaining in `validate_orchestration_artifacts.py` are 65, 116, 120, 131, 146, 312,
314, and 316 — all outside every hunk this feature touched, and therefore pre-existing.
`mcp-tool-inputs.ts` retains 26 uncovered lines, also outside the two lines this feature added.

Two other tracked files were modified but carry no executable code and are outside coverage
measurement: `config/orchestration-routing.json` and
`extensions/drm-copilot/resources/config/orchestration-routing.json` (data files, verified for
byte-identity by `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` in P6-T3), plus
`extensions/drm-copilot/jest.config.cjs` (a config file explicitly listed as a permitted coverage
exclusion in `.claude/rules/general-unit-test.md`).

---

## 5. Data Availability Statement

The P7-T9 task text specifies that the outcome is remediation-required, not PASS, if any required
numeric value is unavailable. Every required value was obtained:

- Python aggregate line and branch: obtained via `poetry run coverage json` re-serialization of the
  P7-T4 data file (scratchpad only; no repository artifact added).
- Python per-new-module line and branch: obtained for all 6 modules from the same JSON, cross-checked
  against the `term-missing` per-file table reproduced in the P7-T4 artifact.
- TypeScript aggregate line and branch: obtained from the P7-T8 `text-summary` output.
- TypeScript per-new-module line and branch: obtained for all 5 modules from
  `extensions/drm-copilot/coverage/lcov.info`.
- Changed-line coverage for all 5 modified source files: obtained from per-line hit data.

No value is missing, estimated, or marked `UNVERIFIED`.

---

## 6. Commands Used

```
poetry run pytest --cov --cov-branch --cov-report=term-missing      # P7-T4, EXIT_CODE 0
poetry run coverage json -o <scratchpad>/py-final-cov.json           # EXIT_CODE 0
npm run test:coverage        (in extensions/drm-copilot/)            # P7-T8, EXIT_CODE 0
git diff -U0 -- <each modified source file>                          # changed-line ranges
```

Per-module parsing of `coverage/lcov.info` and of the coverage JSON was performed by throwaway
scripts written to the session scratchpad and not to the repository tree.
