# Coverage Delta and Threshold Verification — Independent Re-measurement [P6-T10]

Timestamp: 2026-08-25T08-25

Task: [P6-T10]
Worktree: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ab3e4d3669d51fc03`
HEAD: `14e9cac0a749d5bda53b34104f3511ef45b16e21`

Gate applied: the uniform gate of `.claude/rules/quality-tiers.md` — line coverage at or above
**85 percent** and branch coverage at or above **75 percent**, applied identically across T1 through
T4 — plus the no-regression-on-changed-lines rule of `.claude/rules/general-unit-test.md`.
`quality-tiers.yml` is absent from the repository root (verified in this session by `ls` and
`git ls-files`, both returning nothing), so no tier-specific overlay applies.

## Provenance of the post-change numbers

The **post-change** figures below were produced by commands this session executed directly, not read
from a prior artifact:

| Group | Source |
| --- | --- |
| Python baseline | `evidence/baseline/baseline-python-test-coverage.2026-08-24T22-20.md` ([P0-T6]) |
| Python post-change | `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing`, run in this session, EXIT_CODE 0 |
| TypeScript baseline | `evidence/baseline/baseline-typescript-test-coverage.2026-08-24T22-23.md` ([P0-T10]) |
| TypeScript post-change | `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` in `extensions/drm-copilot/`, run in this session, EXIT_CODE 0 |

Both post-change runs are the clean-pass runs recorded in
`evidence/qa-gates/final-qa-clean-pass.2026-08-25T08-23.md`.

### Agreement with the earlier artifact

Every post-change value measured in this session is **identical** to the corresponding value in
`evidence/qa-gates/coverage-delta-verification.2026-08-24T23-22.md` and in the [P6-T4] and [P6-T8]
artifacts it cites: the Python `TOTAL` row `14950 / 1105 / 5492 / 559`, the Python target-module row
`119 / 3 / 56 / 3 / 97% / 185, 224, 287`, the Jest summary `43084/44571` statements and
`6128/6805` branches, and the Jest target-module row `96 | 92.72 | 100 | 96 | 45-46,56-61,215-217,256-257`.
**The earlier artifact is therefore NOT stale.** This artifact restates the verification against
independently produced output and adds the derived per-file branch counts for TypeScript.

---

## Python

### Group 1 — Baseline coverage ([P0-T6])

| Scope | Line | Branch | Exact counts |
| --- | --- | --- | --- |
| Whole `scripts.dev_tools` package | 92.61% | 89.82% | 13841 / 14946 statements; 4931 / 5490 branches |
| `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` | 97.39% | 94.44% | 112 / 115 statements; 51 / 54 branches |

Baseline uncovered lines in the changed module: 185, 217, 277.

### Group 2 — Post-change coverage (measured this session)

`TOTAL` row, verbatim from the `term-missing` table:

```
TOTAL                                                               14950   1105   5492    559    91%
```

Target-module row, verbatim:

```
scripts\dev_tools\_epic_orchestrator_state_launch_binding.py          119      3     56      3    97%   185, 224, 287
```

| Scope | Line | Branch | Exact counts |
| --- | --- | --- | --- |
| Whole `scripts.dev_tools` package | 92.61% | 89.82% | 13845 / 14950 statements; 4933 / 5492 branches |
| `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` | 97.48% | 94.64% | 116 / 119 statements; 53 / 56 branches |

Post-change uncovered lines in the changed module: 185, 224, 287.

The `Cover` column prints a single combined statement-plus-branch figure under `--cov-branch`, so the
separate line and branch percentages above are derived from the exact integer columns of the same
table.

### Group 3 — New/changed-code coverage (lines added by [P3-T1] through [P3-T3])

Established two independent ways, both re-derived from this session's output:

1. **Counter arithmetic.** Statements rose 115 to 119 (**+4**) and branches rose 54 to 56 (**+2**),
   while missed statements stayed at **3** and partial branches stayed at **3**. Zero added
   statements and zero added branch arms are uncovered.
   **New-code line coverage: 100 percent (4 / 4). New-code branch coverage: 100 percent (2 / 2).**
2. **Uncovered-line identity.** Each post-change uncovered line was read in this session and is a
   pre-existing construct displaced by the insertions above it, not an added line:
   - **185** — inside `_validate_model_receipt`, the `if not _is_non_empty_string(model_agent):`
     guard. Unmoved, because it precedes every hunk.
   - **224** — the `continue` for a non-dict entry in the feature loop. Baseline 217.
   - **287** — the `return []` for a non-list `features` value. Baseline 277.

   No line number in the added set appears in the uncovered list.

### Python threshold and regression verdict

| Scope | Measure | Baseline | Post-change | Delta | Gate | Result |
| --- | --- | --- | --- | --- | --- | --- |
| Whole package | Line | 92.61% | 92.61% | 0.00 pp | >= 85% | PASS |
| Whole package | Branch | 89.82% | 89.82% | 0.00 pp | >= 75% | PASS |
| Changed module | Line | 97.39% | 97.48% | +0.09 pp | >= 85% | PASS |
| Changed module | Branch | 94.44% | 94.64% | +0.20 pp | >= 75% | PASS |
| Changed lines | Line | n/a | 100% (4 / 4) | n/a | no regression | PASS |
| Changed lines | Branch | n/a | 100% (2 / 2) | n/a | no regression | PASS |

No coverage measure decreased. Suite result moved from 4116 passed / 0 failed at baseline to
**4117 passed / 0 failed** in this session's run.

---

## TypeScript

### Group 1 — Baseline coverage ([P0-T10])

| Scope | Line | Branch | Exact counts |
| --- | --- | --- | --- |
| All files | 96.66% | 90.04% | 43071 / 44558 lines; 6122 / 6799 branches |
| `src/lib/validate/epic-orchestrator-state-launch-binding.ts` | 95.83% | 92.30% | 299 / 312 statements; 96 / 104 branches (derived, see below) |

Baseline uncovered lines in the changed module: 45-46, 56-61, 215-217, 250-251 (13 lines).

### Group 2 — Post-change coverage (measured this session)

Coverage summary, verbatim:

```
=============================== Coverage summary ===============================
Statements   : 96.66% ( 43084/44571 )
Branches     : 90.05% ( 6128/6805 )
Functions    : 89.67% ( 1260/1405 )
Lines        : 96.66% ( 43084/44571 )
================================================================================
```

Target-module row, verbatim from the `text` table:

```
  epic-orchestrator-state-launch-binding.ts                 |      96 |    92.72 |     100 |      96 | 45-46,56-61,215-217,256-257
```

| Scope | Line | Branch | Exact counts |
| --- | --- | --- | --- |
| All files | 96.66% | 90.05% | 43084 / 44571 lines; 6128 / 6805 branches |
| `src/lib/validate/epic-orchestrator-state-launch-binding.ts` | 96.00% | 92.72% | 312 / 325 statements; 102 / 110 branches (derived, see below) |

Post-change uncovered lines in the changed module: 45-46, 56-61, 215-217, 256-257 (13 lines).

**Derivation of the per-file counts.** The Jest `text` reporter prints per-file percentages but not
per-file counts. The counts above are solved exactly from the printed percentages together with the
13-line uncovered set, and each solution reproduces the printed percentage without rounding slack:

- Statements/lines: 13 uncovered at 95.83% implies 312 total (299 / 312 = 95.83%); 13 uncovered at
  96.00% implies 325 total (312 / 325 = 96.00%). Growth **+13**, which equals the whole-suite growth
  of 44558 to 44571, confirming this file is the only one that changed.
- Branches: solving 96 / 104 = 92.31% at baseline and 102 / 110 = 92.727% post-change against a
  constant 8 uncovered branches gives a growth of **+6**, which equals the whole-suite branch growth
  of 6799 to 6805.

### Group 3 — New/changed-code coverage (lines added by [P3-T4])

1. **Whole-suite counter arithmetic.** Total statements rose by 13 and covered statements rose by 13
   (43071 to 43084 of 44558 to 44571). Total branches rose by 6 and covered branches rose by 6
   (6122 to 6128 of 6799 to 6805). Total functions rose by 1 and covered functions rose by 1
   (1259 to 1260 of 1404 to 1405). Since the changed module is the only file in the diff that carries
   coverage, every added statement, branch arm, and function in it is covered.
   **New-code line coverage: 100 percent (13 / 13). New-code branch coverage: 100 percent (6 / 6).
   New-code function coverage: 100 percent (1 / 1).**
2. **Uncovered-line identity.** The post-change uncovered set is the same four spans as at baseline,
   with only the last span displaced by the six inserted lines above it (250-251 becomes 256-257).
   Read in this session, lines 256-257 are the `return;` of the `if (!isObject(item))` guard inside
   `features.forEach`, a pre-existing construct. The added `featureCarriesLaunchPath` definition at
   lines 235-236 and the added skip at line 261 do not appear in the uncovered list.
3. **Percentage movement.** Both per-file measures rose (line 95.83 to 96.00, branch 92.30 to 92.72)
   while the file grew, which is only possible if the added code is covered at a rate above the
   file's prior rate.

### TypeScript threshold and regression verdict

| Scope | Measure | Baseline | Post-change | Delta | Gate | Result |
| --- | --- | --- | --- | --- | --- | --- |
| All files | Line | 96.66% | 96.66% | 0.00 pp | >= 85% | PASS |
| All files | Branch | 90.04% | 90.05% | +0.01 pp | >= 75% | PASS |
| Changed module | Line | 95.83% | 96.00% | +0.17 pp | >= 85% | PASS |
| Changed module | Branch | 92.30% | 92.72% | +0.42 pp | >= 75% | PASS |
| Changed lines | Line | n/a | 100% (13 / 13) | n/a | no regression | PASS |
| Changed lines | Branch | n/a | 100% (6 / 6) | n/a | no regression | PASS |

No coverage measure decreased. Suite result moved from 195 suites / 2657 tests passed at baseline to
**195 suites / 2658 tests passed, 0 failed** in this session's run.

---

## Verdict

**PASS.**

- `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`: line **97.48 percent** (>= 85),
  branch **94.64 percent** (>= 75). Both gates PASS.
- `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts`: line
  **96.00 percent** (>= 85), branch **92.72 percent** (>= 75). Both gates PASS.
- Whole-scope totals clear both gates in both languages.
- No regression on changed lines: every statement and branch arm added by [P3-T1] through [P3-T4] is
  covered, established on the Python side by unchanged missed/partial counters and on both sides by
  the unchanged uncovered-span set and by whole-suite counter arithmetic.
- Every value in all three groups, for both languages, is a real number. No placeholder is present,
  so the plan's fail-closed INCOMPLETE condition does not apply.

The remaining files in the diff carry no coverage obligation: `.claude/rules/orchestrator-state.md`
and its bundle twin are Markdown, and the two test files are test code rather than production code
in the coverage denominator.
