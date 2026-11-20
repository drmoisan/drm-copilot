# Final Combined Coverage Delta Summary

Timestamp: 2026-05-01T00-00Z
Command: N/A (summary of per-language delta artifacts)
EXIT_CODE: 0

## Output Summary

### Python

Source: `evidence/qa-gates/final-python-coverage-delta.md`

- Baseline: 83% (repo-wide, 1012 tests)
- Post-change: 84% (repo-wide, 1060 tests, +48 tests)
- New-or-changed-code (converter package): 95% as a whole
- Per-file: engine.py 96%, models.py 99%, parser.py 90%, validation.py 98%, reporting.py 97%, inventory.py 96%, mapping.py 96%, classifier.py 92%, rewrites.py 91%, intermediate_state.py 87%, section_intent.py 76%
- Verdict: **CONDITIONAL PASS** — repo-wide target met; converter package ≥90% as a whole; `section_intent.py` (76%) and `intermediate_state.py` (87%) are below the ≥90% per-file target and require additional coverage in a follow-up

### TypeScript

Source: `evidence/qa-gates/final-typescript-coverage-delta.md`

- Baseline: 94.95% lines (336 tests, 28 suites)
- Post-change: 95.5% lines (348 tests, 32 suites, +12 tests, +4 suites)
- New-or-changed-code: all Phase 5 changed files ≥91% (lowest: `mcp-tools.ts` at 91.08%)
- Verdict: **PASS**

### Combined

- Python coverage increased by +1 pp; TypeScript coverage increased by +0.55 pp
- No regressions in either language
- All new TypeScript files meet ≥90% line coverage
- Python converter package meets ≥90% as a whole; two individual files are below per-file targets and are flagged for follow-up coverage improvement
