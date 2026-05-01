# Final Python Coverage Delta Evidence

Timestamp: 2026-05-01T00-00Z
Command: N/A (delta computed by comparing baseline and final coverage evidence artifacts)
EXIT_CODE: 0

## Output Summary

**Baseline (Phase 0):**
- Source: `evidence/baseline/phase0-python-test-coverage.md` (from git commit `79d02b7`)
- Tests: 1012 passed, 14 skipped
- Coverage: **83%** across `src` and `scripts/dev_tools`

**Post-Change:**
- Source: `evidence/qa-gates/final-python-test-coverage.md`
- Tests: 1060 passed, 14 skipped
- Coverage: **84%** across `src` and `scripts/dev_tools` (+1 pp)

**New-or-Changed-Code (converter package only):**
- Source: `evidence/qa-gates/final-python-targeted-coverage.md`
- Coverage: **95%** across the `codex_native_converter` package (937 stmts, 50 missed)

**Per-file new/changed code coverage:**
- `engine.py`: 96% (8 missed)
- `models.py`: 99% (1 missed)
- `parser.py`: 90% (9 missed) — meets ≥90% threshold
- `intermediate_state.py`: 87% (4 missed) — existing module extended; lines 96/128/150/174 are JSON-serialization branches for non-empty collections not exercised in isolation tests
- `section_intent.py`: 76% (10 missed) — 8 of the missed lines are in the lesser-used intent paths (LAUNCHER_ONLY, UNSUPPORTED fallback branches)

**Threshold Verdict:**
- Repo-wide new-module target (≥90%): **PASS** for converter package as a whole (95%)
- Repo-wide coverage must not decrease: **PASS** (83% → 84%, +1 pp)
- Changed-lines coverage for individual files: **PASS** for all files except `section_intent.py` (76%) and `intermediate_state.py` (87%) — both are below the ≥90% target for individual new modules. These shortfalls are noted for follow-up test coverage in subsequent iterations.

Overall verdict: **CONDITIONAL PASS** — repo-wide coverage increased; converter package as a whole meets ≥90%; two individual files are below the per-file target and require additional test coverage in a follow-up.
