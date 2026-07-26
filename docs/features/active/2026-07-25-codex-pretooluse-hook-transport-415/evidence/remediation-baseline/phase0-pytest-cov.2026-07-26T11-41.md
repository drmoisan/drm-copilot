# Phase 0 — Baseline Python Test + Coverage (Remediation Cycle 1)

- **Issue:** #415
- **Task:** [P0-T9]
- **Finding addressed (baseline half):** R2

Timestamp: 2026-07-26T11-41

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

## Output Summary

### Pass/fail counts

```
============================ 2123 passed in 10.75s ============================
```

- passed = **2123**
- failed = **0**
- errors = **0**

### Terminal TOTAL row (verbatim)

```
--------------------------------------------------------------------------------------------------------------
TOTAL                                                              12280   1105   4450    554    89%
```

Columns are `Stmts  Miss  Branch  BrPart  Cover`.

### Derived Python LINE coverage (RI-3 method)

Per RI-3, the `Cover` column under `--cov-branch` is a COMBINED statement+branch figure (89%) and MUST NOT be reported as line coverage. Line coverage is derived from the TOTAL row as `(Stmts − Miss) / Stmts`:

- Stmts = **12280**
- Miss = **1105**
- Covered statements = 12280 − 1105 = **11175**
- **Line coverage = 11175 / 12280 = 91.0016% → 91.00%**
- Threshold >= 85%: **PASS**

Independent confirmation from `artifacts/python/lcov.info` (summed per-file records):

```
LH=11175  LF=12280  line=91.0016%
```

Summed `LH`/`LF` agrees exactly with the TOTAL-row derivation.

### Derived Python BRANCH coverage (RI-3 method)

Derived as summed `BRH` / `BRF` across all `artifacts/python/lcov.info` records:

- BRH (branches hit) = **3642**
- BRF (branches found) = **4450**
- **Branch coverage = 3642 / 4450 = 81.8427% → 81.84%**
- Threshold >= 75%: **PASS**

The `BRF` sum (4450) matches the TOTAL row's `Branch` column (4450), confirming the two sources describe the same branch population.

Derivation command:

```
awk -F: '/^LH:/{lh+=$2} /^LF:/{lf+=$2} /^BRH:/{brh+=$2} /^BRF:/{brf+=$2} \
  END{printf "LH=%d LF=%d line=%.4f%%\nBRH=%d BRF=%d branch=%.4f%%\n", \
  lh, lf, 100*lh/lf, brh, brf, 100*brh/brf}' artifacts/python/lcov.info
```

### lcov artifact existence

- `Test-Path artifacts/python/lcov.info` = **True**
- Size 344174 bytes, written 2026-07-26 11:51 by this run.
- Terminal confirmation line: `Coverage LCOV written to file artifacts/python/lcov.info`

This is the artifact whose absence finding B2/R2 flagged. `pyproject.toml:112` sets `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`, so the stated command is the repo-standard lcov-producing invocation.

### Baseline verdict

Both Python thresholds pass at baseline: line 91.00% >= 85%, branch 81.84% >= 75%. No production Python file changed on this branch, so [P6-T7] is expected to reproduce these numbers unchanged.
