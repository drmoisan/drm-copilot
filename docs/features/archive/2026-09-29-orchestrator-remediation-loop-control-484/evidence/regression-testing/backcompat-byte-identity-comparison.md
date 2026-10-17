# Back-Compat Byte-Identity Comparison (P7-T5, AC-5)

Timestamp: 2026-10-01T23-33
Task: P7-T5

## Modes per runtime

- Python: plain, require_complete, require_pr_creation_ready, require_model_routing (4 modes x 11 stems = 44 cases + fixture-count case).
- TypeScript: plain, require_complete, require_model_routing (3 modes x 11 stems = 33 cases + fixture-count case).
- PowerShell: plain, require_complete, require_pr_creation_ready (3 modes x 11 stems = 33 cases + fixture-count case).

## Cited runs

| Runtime | Before (unmodified validator) | After (changed validator) | Equal |
|---|---|---|---|
| Python | P1-T5 `backcompat-python-before.md`: EXIT_CODE 0, 45 passed (re-run in P1-T11: 45 passed) | P7-T2 `backcompat-python-after.md`: EXIT_CODE 0, 45 passed | yes |
| TypeScript | P1-T8 `backcompat-jest-before.md`: EXIT_CODE 0, 34 passed (re-run in P1-T11: 34 passed) | P7-T3 `backcompat-jest-after.md`: EXIT_CODE 0, 34 passed | yes |
| PowerShell | P1-T11 `backcompat-pester-before.md`: `Passed=34 Failed=0` | P7-T4 `backcompat-pester-after.md`: `Passed=34 Failed=0` | yes |

## Capture integrity

- P1-T12 `backcompat-production-untouched.md`: both commands printed nothing, so the expected lists were captured from unmodified production code.
- P1-T13 `backcompat-hashes-before.md` vs P7-T1 `backcompat-hashes-after.md`: 15 of 15 SHA256 hashes equal (eleven fixtures, the expected file, three test files), so the expected error lists and the readers asserting them are the ones captured before any production edit.

Each after-run asserts ordered, full, unfiltered error-list equality against the expected file for every stem and mode, so equal pass counts with unchanged expected bytes mean the changed validators produce byte-identical error lists for checkpoints that do not use the new fields.

Result: BYTE-IDENTICAL

Output Summary: all six cited runs passed with equal counts (45/45, 34/34, 34/34) and all fifteen hashes matched. Result: BYTE-IDENTICAL.
