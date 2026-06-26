# F6 Final QA — Test + Coverage

Timestamp: 2026-06-26T02-23

Command: `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` (run from `extensions/drm-copilot/`)

EXIT_CODE: 0

Output Summary:
- Test result: 64 suites passed / 64 total; 725 tests passed / 725 total.
- Overall `src/lib/**` coverage ("All files" row): line 96.33%, branch 87.87% (statements 96.33%, functions 92.85%).
- Per-file coverage for the new F6 files:
  - `src/lib/new-potential-bug-entry.ts`: line 95.87%, branch 82.97% (statements 95.87%, functions 91.66%).
    - Uncovered lines: 263-272 (win32-only PATHEXT inner-loop `existsSync`-true path in `defaultWhichLookup`), 348-351 (`buildDefaultAuthorProvider` default-seam glue), 404-408 (`createBugEntry` default-seam `??` construction of `SubprocessRunner`/launcher when no seam injected).
    - These uncovered branches are production defaults for standalone/CLI-equivalent callers; exercising them requires a real `git` subprocess or a real PATH/filesystem probe, which the hermetic unit-test policy prohibits. The service/MCP path always injects both seams. New-file thresholds are met: line 95.87% >= 85%, branch 82.97% >= 75%.
  - `src/lib/new-potential-bug-entry-service-call.ts`: line 100%, branch 100% (statements 100%, functions 100%).

Threshold check: both new files meet line >= 85% and branch >= 75%. See `f6-coverage-delta.md` for the baseline-vs-post-change comparison and the overall-branch delta rationale.
