# Final QC Jest Coverage (P5-T6)

Timestamp: 2026-10-09T03-47
Task: [P5-T6]
Pass: 1
Working directory: extensions/drm-copilot
Command: npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary
EXIT_CODE: 0 (no per-file coverageThreshold failure reported)

Verbatim summary lines:

    Test Suites: 256 passed, 256 total
    Tests:       3917 passed, 3917 total
    Lines        : 97.16% ( 51037/52524 )
    Branches     : 91.7% ( 7520/8200 )

Per-module values read from `extensions/drm-copilot/coverage/lcov.info` (`SF:` key with `\` replaced by `/`; `LH`/`LF` and `BRH`/`BRF` records):

| Module | LH/LF | Lines % | BRH/BRF | Branches % | >= 85% lines | >= 75% branches |
| --- | --- | --- | --- | --- | --- | --- |
| src/lib/validate/orchestration-handoff-authority-service.ts | 386/390 | 98.97 | 65/71 | 91.55 | yes | yes |
| src/lib/validate/orchestration-handoff-materializer.ts | 489/494 | 98.99 | 86/88 | 97.73 | yes | yes |
| src/lib/validate/orchestration-handoff-materializer-production.ts | 138/138 | 100.00 | 39/39 | 100.00 | yes | yes |
| src/lib/validate/orchestration-handoff-materializer-request.ts | 155/155 | 100.00 | 31/31 | 100.00 | yes | yes |

The run includes `test/mcp-handlers/orchestration-handoff-handlers.test.ts` (integration stage 7). Suite count rose from 254 to 256 (new fallback and binding suites) and test count from 3906 to 3917 (+11: rows h, i, j, A7, F1-F7; the split moved 17 tests without changing the total).

Output Summary: Pass (AC-17 thresholds). 256 suites and 3917 tests passed, 0 failed. Repository Lines 97.16%, Branches 91.7%. All four in-scope modules are at or above 85% lines and 75% branches.
