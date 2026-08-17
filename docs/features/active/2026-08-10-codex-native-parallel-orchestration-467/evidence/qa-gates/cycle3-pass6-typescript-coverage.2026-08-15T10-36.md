# Cycle 3 Pass 6 TypeScript Coverage

Timestamp: 2026-08-16T21-00

Command: `Get-FileHash extensions/drm-copilot/coverage/coverage-summary.json,evidence/qa-gates/cycle1-typescript-test.2026-08-14T09-36.md,evidence/qa-gates/cycle3-pass6-typescript-freshness.2026-08-15T10-36.md -Algorithm SHA256; parse coverage-summary.json total counters and accepted owner reconciliation`

EXIT_CODE: 0

Output Summary: The approved `UNCHANGED` branch applies. The accepted coverage summary and test receipt match their locked hashes. The retained result is 44,127/45,740 = 96.47% lines, 6,589/7,338 = 89.79% genuine branches, 2,690/2,690 passing tests, and 5/5 modified owners non-regressing.

- Selected branch: `UNCHANGED`
- Expected/current coverage summary SHA-256: `D1F43ABFA4FF4200CE315B3E30598B6F7DD320A5F02C873B9EF1063A59B1C5C0`
- Expected/current test receipt SHA-256: `41245C2DC5F113864AFAB445A61FB541A6D52AD63E41098F9DF5237C8296CDD7`
- Current freshness receipt SHA-256: `AEFFE77108ED4CE9182D1004AE165A898BE02120BC88FA68EBF5C1DD577D7273`
- Current TypeScript selected-path mismatches: 0

## Numeric Gates

- Tests: 2,690/2,690 passed; 0 failed.
- Lines: 44,127/45,740 = 96.47% >= 85% — PASS.
- Genuine branches: 6,589/7,338 = 89.79% >= 75% — PASS.
- Functions: 1,304/1,434 = 90.93%.
- Modified owners non-regressing: 5/5 — PASS.

Result: PASS
