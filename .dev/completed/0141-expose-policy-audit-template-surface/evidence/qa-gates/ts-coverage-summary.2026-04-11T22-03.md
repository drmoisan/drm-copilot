Timestamp: 2026-04-12T00:03:46-04:00
Command: derived-from-baseline-ts-test-unit-and-P2-T4/P2-T5/P2-T6
EXIT_CODE: 0
Output Summary:
- Baseline coverage from `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/baseline/ts-test-unit.2026-04-11T22-03.md`:
  - Statements: 94.54%
  - Branches: 81.60%
  - Functions: 98.49%
  - Lines: 94.54%
- Refreshed post-change coverage from `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/qa-gates/ts-test-unit.2026-04-11T22-03.md`:
  - Statements: 94.75%
  - Branches: 83.72%
  - Functions: 98.65%
  - Lines: 94.75%
- Coverage regression disposition: no headline regression was recorded; all reported headline values increased from baseline to post-change.
- New-module line coverage context from `extensions/drm-copilot/coverage/coverage-summary.json`:
  - `src/document-workflow-commands.ts`: 91.52% lines
  - `src/policy-audit-template-assets.ts`: 96.96% lines
  - `src/poshqc-command-registration.ts`: 91.81% lines
  - `src/repo-automation-service-support.ts`: 100.00% lines
- Changed-line proof for modified existing TypeScript production files from `docs/features/active/2026-04-11-expose-policy-audit-template-surface-141/evidence/regression-testing/ts-changed-existing-source-coverage.2026-04-11T22-54.md`:
  - `extensions/drm-copilot/src/extension.ts`: `PASS` (`19/19` changed lines covered; `0` uncovered; `0` unmatched)
  - `extensions/drm-copilot/src/mcp-tool-inputs.ts`: `PASS` (`31/31` executable changed lines covered; structural exclusions documented in `ts-coverage-proof-basis.2026-04-11T23-23.md`)
  - `extensions/drm-copilot/src/mcp-tools.ts`: `PASS` (`36/36` executable changed lines covered; structural exclusions documented in `ts-coverage-proof-basis.2026-04-11T23-23.md`)
  - `extensions/drm-copilot/src/repo-automation-service.ts`: `PASS` (`96/96` changed lines covered; `0` uncovered; `0` unmatched)
  - `extensions/drm-copilot/src/workflow-command-arguments.ts`: `PASS` (`31/31` executable changed lines covered; structural exclusions documented in `ts-coverage-proof-basis.2026-04-11T23-23.md`)
- Approved exception search result: not required because the final changed-line proof reported `PASS`.
- Changed/new-code coverage disposition: PASS. The refreshed evidence shows improved headline coverage, `>= 90%` line coverage for the new production modules, and `PASS` for every modified existing TypeScript production file still in executable scope.
