# TypeScript Full-Suite Coverage Run (Remediation Cycle 1, R1)

Timestamp: 2026-10-02T06-52
Task: P1-T1 of remediation-plan.2026-10-02T05-58.md
Command: npm run test:coverage --prefix extensions/drm-copilot -- --coverageReporters=text > <scratchpad>/jest-coverage-543.log 2>&1 (run from the worktree root). The `test:coverage` script (`extensions/drm-copilot/package.json` line 213) expands, in `extensions/drm-copilot/`, to `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=text`; the log's npm banner prints exactly that expansion. Extraction: grep -nE 'Test Suites:|Tests:|Lines +:|Branches +:' <scratchpad>/jest-coverage-543.log; grep -nE '(launch-binding|launch-evidence|readiness-integrity|state-core|orchestration-artifacts)\.ts' <scratchpad>/jest-coverage-543.log
EXIT_CODE: 0
Output Summary:
- `Test Suites: 250 passed, 250 total`
- `Tests:       3794 passed, 3794 total`
- `Branches     : 91.42% ( 7434/8131 )`
- `Lines        : 97.08% ( 50670/52192 )`
- `text` table header: `File | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s`
- Five `text` rows for the changed production files (verbatim, trailing padding trimmed):
  - `  epic-orchestrator-state-launch-binding.ts                 |    96.1 |    93.27 |     100 |    96.1 | 45-46,56-61,215-217,258-259`
  - `  epic-planner-launch-evidence.ts                           |   92.75 |    84.48 |     100 |   92.75 | 54-57,80-85,90-98,192-193,204-205,214,225-226,271-272,385-386,406-407,413-414`
  - `  epic-planner-readiness-integrity.ts                       |   91.62 |    84.28 |     100 |   91.62 | 37-40,42-43,68-73,131-132,177-183,192-193,197-198,224-227,338-339`
  - `  epic-planner-state-core.ts                                |    98.3 |    93.57 |     100 |    98.3 | 69-70,75-76,78-79,273-274`
  - `  orchestration-artifacts.ts                                |     100 |    97.56 |     100 |     100 | 308,364`
- The `Tests:` line contains no `failed` count; a `grep -n failed` over the log returned no match.
- Comparison with the previous full run (250 suites, 3794 tests): identical counts; no difference.
- Exit 0 also establishes that every `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs` is met.
- The extraction regex also matched non-target rows (`epic-orchestrator-state-core.ts`, `orchestrator-state-core.ts`, `parallel-orchestrator-state-core.ts`, `parallel-planner-state-core.ts`); those are outside R1 scope and are not quoted above.
- No prohibited flag (`--passWithNoTests`, `--onlyChanged`, `--lastCommit`) was passed.
