# Coverage Comparison - Remediation Cycle 2 (P2-T4)

Timestamp: 2026-11-13T17-12
Command: compare evidence/qa-gates/jest-root-final.2026-11-13T17-12.md and jest-extension-final.2026-11-13T17-12.md with evidence/remediation-baseline/jest-root-baseline.2026-11-13T16-56.md and jest-extension-baseline.2026-11-13T16-57.md
EXIT_CODE: 0
Output Summary: PASS. Pass counts equal (root 5493, extension 5476); failing tests none in every run; all eight headline percentages equal to baseline at printed precision.

## Pass counts and failing tests

| Suite | Baseline passed | Final passed | Baseline failing | Final failing | Result |
|---|---|---|---|---|---|
| Root Jest (tests) | 5493 | 5493 | none | none | PASS |
| Root Jest (suites) | 343 | 343 | 0 | 0 | PASS |
| Extension Jest (tests) | 5476 | 5476 | none | none | PASS |
| Extension Jest (suites) | 340 | 340 | 0 | 0 | PASS |

## Headline percentages

| Suite | Metric | Baseline | Post-change | Result |
|---|---|---|---|---|
| Root (All files) | Statements | 98.27 | 98.27 | PASS (equal) |
| Root (All files) | Branches | 93.59 | 93.59 | PASS (equal) |
| Root (All files) | Functions | 92.23 | 92.23 | PASS (equal) |
| Root (All files) | Lines | 98.27 | 98.27 | PASS (equal) |
| Extension (text-summary) | Statements | 97.15 (63660/65526) | 97.15 (63660/65526) | PASS (equal) |
| Extension (text-summary) | Branches | 93.87 (9710/10344) | 93.87 (9710/10344) | PASS (equal) |
| Extension (text-summary) | Functions | 92.11 (1904/2067) | 92.11 (1904/2067) | PASS (equal) |
| Extension (text-summary) | Lines | 97.15 (63660/65526) | 97.15 (63660/65526) | PASS (equal) |

## Scope statement

No production source file changed in this cycle (only `package-lock.json`, `extensions/drm-copilot/package-lock.json`, and `packages/mcp-server/package-lock.json`), so no new-code or per-file comparison applies beyond the per-file `coverageThreshold` map enforced in P2-T3, which passed with no threshold failure.

Outcome: PASS
