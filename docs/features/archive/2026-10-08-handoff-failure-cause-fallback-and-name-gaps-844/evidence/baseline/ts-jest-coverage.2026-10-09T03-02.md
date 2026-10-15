# Baseline Jest Coverage (P0-T9)

Timestamp: 2026-10-09T03-02
Task: [P0-T9]
Working directory: extensions/drm-copilot
Command: npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary
EXIT_CODE: 0

Verbatim summary lines:

    Test Suites: 254 passed, 254 total
    Tests:       3906 passed, 3906 total
    Lines        : 97.16% ( 50999/52486 )
    Branches     : 91.66% ( 7508/8191 )

Per-module values read from `extensions/drm-copilot/coverage/lcov.info` (`SF:` key with `\` replaced by `/`; `LH`/`LF` and `BRH`/`BRF` records):

| Module | LH/LF | Lines % | BRH/BRF | Branches % |
| --- | --- | --- | --- | --- |
| src/lib/validate/orchestration-handoff-authority-service.ts | 386/390 | 98.97 | 64/71 | 90.14 |
| src/lib/validate/orchestration-handoff-materializer.ts | 483/488 | 98.98 | 81/84 | 96.43 |
| src/lib/validate/orchestration-handoff-materializer-production.ts | 139/139 | 100.00 | 39/40 | 97.50 |
| src/lib/validate/orchestration-handoff-materializer-request.ts | 122/122 | 100.00 | 26/26 | 100.00 |

Output Summary: Pass. 254 suites and 3906 tests passed. Repository text-summary: Lines 97.16%, Branches 91.66%. The four in-scope modules are at 98.97/90.14, 98.98/96.43, 100.00/97.50, and 100.00/100.00 (lines/branches %).
