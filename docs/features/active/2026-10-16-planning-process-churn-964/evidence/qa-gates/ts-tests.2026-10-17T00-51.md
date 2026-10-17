# QA Gate — Jest with Coverage

Timestamp: 2026-10-17T00-50
Task: [P6-T4]
Command: node run-jest.cjs --coverage --coverageReporters=text-summary --coverageReporters=json-summary --coverageDirectory=../../artifacts/jest-964-qa (in extensions/drm-copilot)
EXIT_CODE: 0
Output Summary:
- Test Suites: 281 passed, 281 total. Tests: 4103 passed, 4103 total (baseline 279 / 4085).
- No coverage-threshold failure (the per-file `coverageThreshold` map, including the new `./src/lib/validate/plan-gate-document.ts` entry, is enforced; exit 0 and no threshold message in the output).
- Totals: Statements 97.41%, Branches 92.65%, Functions 91.55%, Lines 97.41% (baseline 97.39% / 92.63% / 91.7% / 97.39%).
- `src/lib/validate/plan-gate-document.ts` (new): lines 100%, branches 95.08%.
- `src/lib/validate/plan-gate-discrimination.ts`: lines 100%, branches 98.27% (baseline 100% / 98.27%; no regression).
- `src/lib/codex-native-converter/rewrites-rules.ts` (related finding): lines 100%, branches 100% (unchanged).
