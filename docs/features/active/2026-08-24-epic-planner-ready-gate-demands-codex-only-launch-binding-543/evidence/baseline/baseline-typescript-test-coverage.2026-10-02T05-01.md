# Baseline TypeScript tests and coverage (issue #543)

Timestamp: 2026-10-02T05-01
Task: P0-T16
Command: `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary` (in `extensions/drm-copilot/`)
EXIT_CODE: 0

Output Summary:
- `Test Suites: 250 passed, 250 total`
- `Tests:       3786 passed, 3786 total`
- text-summary: `Lines        : 97.07% ( 50620/52146 )`; `Branches     : 91.35% ( 7391/8090 )`
- `text` rows (`% Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s`) for the five write-set production files:
  - `epic-orchestrator-state-launch-binding.ts | 96 | 92.79 | 100 | 96 | 45-46,56-61,215-217,256-257`
  - `epic-planner-launch-evidence.ts | 91.64 | 80.61 | 100 | 91.64 | 34-37,52-55,78-83,88-96,190-191,202-203,212,223-224,269-270,383-384,399-400,406-407`
  - `epic-planner-readiness-integrity.ts | 91.48 | 82.81 | 100 | 91.48 | 36-39,41-42,67-72,130-131,176-182,191-192,196-197,223-226,332-333`
  - `epic-planner-state-core.ts | 98.26 | 93.51 | 100 | 98.26 | 65-66,71-72,74-75,269-270`
  - `orchestration-artifacts.ts | 100 | 97.43 | 100 | 100 | 308,358`
- All five rows meet `% Lines` >= 85 and `% Branch` >= 75; no failed test. No stop condition applies.
