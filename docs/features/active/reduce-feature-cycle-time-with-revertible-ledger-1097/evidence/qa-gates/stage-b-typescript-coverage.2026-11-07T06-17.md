# Stage B TypeScript Coverage and Full-Suite Gate (Remediation Cycle 2, finding F1)

Timestamp: 2026-11-07T06-17
Command: node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary, run once in extensions/drm-copilot from a sh launcher under SCRATCH
EXIT_CODE: 0
Output Summary: Test Suites: 328 passed, 328 total. Tests: 5287 passed, 5287 total, 0 failed. Repo-wide coverage from the text-summary block: Lines 97.06% (61859 of 63730), Branches 93.67% (9388 of 10022), Statements 97.06%, Functions 91.9%. extensions/drm-copilot/coverage/lcov.info exists after the run and is left on disk (the directory is gitignored). The jest binary was present under extensions/drm-copilot/node_modules/.bin, so no npm ci was run. No TypeScript production file changed on this branch, so no per-file figure applies; this run is the repo-wide artifact and full-suite result the Stage B gates lacked (they ran a 24-suite subset with coverage off).
