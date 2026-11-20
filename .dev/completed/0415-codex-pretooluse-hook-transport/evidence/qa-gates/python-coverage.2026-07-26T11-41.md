# Python Full-Suite Coverage Evidence (Remediation Cycle 1) — the R2 Deliverable

- **Issue:** #415
- **Task:** [P6-T7]
- **Finding:** R2 (no Python per-language coverage evidence despite one changed Python file)

Timestamp: 2026-07-26T11-41

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

`pyproject.toml:112` sets `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"`, so this is the repo-standard lcov-producing invocation (RI-3).

## Output Summary

### (i) Pass/fail counts

```
============================ 2123 passed in 13.22s ============================
```

- passed = **2123**
- failed = **0**
- errors = **0**

### (ii) Repo-wide Python LINE coverage (NUMERIC, derived per RI-3)

Terminal TOTAL row (columns `Stmts  Miss  Branch  BrPart  Cover`):

```
TOTAL                                                              12280   1105   4450    554    89%
```

The `Cover` column (89%) is a COMBINED statement+branch figure under `--cov-branch` and MUST NOT be reported as line coverage. Line coverage is derived as `(Stmts − Miss) / Stmts`:

- Stmts = **12280**
- Miss = **1105**
- Covered statements = 12280 − 1105 = **11175**
- **Line coverage = 11175 / 12280 = 91.0016% → 91.00%**
- **Threshold >= 85%: PASS**

Independent confirmation from summed per-file `LH`/`LF` records in `artifacts/python/lcov.info`: `LH=11175 LF=12280 line=91.0016%` — exact agreement with the TOTAL-row derivation.

### (iii) Repo-wide Python BRANCH coverage (NUMERIC, derived per RI-3)

Derived as summed `BRH` / `BRF` across all `artifacts/python/lcov.info` records:

- BRH (branches hit) = **3642**
- BRF (branches found) = **4450**
- **Branch coverage = 3642 / 4450 = 81.8427% → 81.84%**
- **Threshold >= 75%: PASS**

The `BRF` sum (4450) matches the TOTAL row's `Branch` column (4450), confirming both sources describe the same branch population.

Derivation command:

```
awk -F: '/^LH:/{lh+=$2} /^LF:/{lf+=$2} /^BRH:/{brh+=$2} /^BRF:/{brf+=$2} \
  END{printf "LH=%d LF=%d line=%.4f%%\nBRH=%d BRF=%d branch=%.4f%%\n", \
  lh, lf, 100*lh/lf, brh, brf, 100*brh/brf}' artifacts/python/lcov.info
```

### (iv) lcov artifact existence

- `Test-Path artifacts/python/lcov.info` = **True**
- Artifact path: `artifacts/python/lcov.info` (344174 bytes, written 2026-07-26 13:26 by this run)
- Terminal confirmation line: `Coverage LCOV written to file artifacts/python/lcov.info`

This is the artifact whose absence finding B2/R2 flagged. Reading it as tool output is permitted; the evidence artifact itself is written under the canonical `<FEATURE>/evidence/qa-gates/` path.

### (v) Changed Python surface and expected per-file movement

The only changed `.py` file on this branch is the test module
`tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`
(`git diff --stat fb483b8468204e4385b5583c3b3ec4c0a987eede..HEAD`, one deleted line). **No production Python changed** on this branch, and this remediation cycle changed no `.py` file at all — `git diff fef82fa2 --name-only | grep '\.py$'` returns nothing.

Therefore **no per-file coverage movement is expected**, and none occurred. Comparison against the [P0-T9] remediation baseline:

| Metric | [P0-T9] baseline | [P6-T7] post-remediation | Delta |
|---|---:|---:|---:|
| Tests passed | 2123 | 2123 | 0 |
| Stmts | 12280 | 12280 | 0 |
| Miss | 1105 | 1105 | 0 |
| Line coverage | 91.00% | **91.00%** | **0.00** |
| BRH | 3642 | 3642 | 0 |
| BRF | 4450 | 4450 | 0 |
| Branch coverage | 81.84% | **81.84%** | **0.00** |

The repo-wide numbers are unchanged, exactly as predicted. Both thresholds are met numerically.

## Verdict

**R2 RESOLVED — PASS.** Python per-language coverage evidence now exists with derived numeric line and branch percentages, both above threshold, the lcov artifact confirmed present, and the no-movement expectation stated and verified against the baseline.

The [P6-T7] FAILURE BRANCH was not taken: neither threshold was missed.
