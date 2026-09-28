# TypeScript Unit and Coverage QA

- Timestamp: `2026-09-02T23:17:42.9589226-04:00`
- Working directory: `extensions/drm-copilot`
- Command: `npm run test:coverage`
- Exit code: `0`
- Test suites: `213 passed, 213 total`
- Tests: `2894 passed, 2894 total`
- Snapshots: `0 total`
- Machine-readable coverage: `extensions/drm-copilot/coverage/lcov.info`

OVERALL_LINE_COVERAGE: 96.78%
OVERALL_BRANCH_COVERAGE: 90.28%
AUTHORITY_SERVICE_LINE_COVERAGE: 97.73584905660377%
PATH_BOUNDARY_LINE_COVERAGE: 97.5609756097561%
AUTHORITY_SERVICE_LINES: 259/265
PATH_BOUNDARY_LINES: 200/205

## Coverage parser

- Command: `node -e "const fs=require('node:fs');const text=fs.readFileSync('coverage/lcov.info','utf8');for(const record of text.split('end_of_record')){const sf=record.match(/^SF:(.+)$/m)?.[1];if(sf&&/orchestration-handoff-(authority-service|path-boundary)\.ts$/.test(sf)){const get=k=>Number(record.match(new RegExp('^'+k+':(\\d+)$','m'))?.[1]??0);const lh=get('LH'),lf=get('LF'),brh=get('BRH'),brf=get('BRF');console.log(JSON.stringify({file:sf,lineCovered:lh,lineTotal:lf,linePercent:lf?lh/lf*100:100,branchCovered:brh,branchTotal:brf,branchPercent:brf?brh/brf*100:100}));}}"`
- Exit code: `0`
- Authority service: `259/265` lines and `42/48` branches.
- Path boundary: `200/205` lines and `43/53` branches.

## Acceptance verification

- Overall line coverage `96.78%` is at least `85%`.
- Overall branch coverage `90.28%` is at least `75%`.
- Authority-service line coverage `97.73584905660377%` and path-boundary line coverage `97.5609756097561%` are each at least `90%`.
- A scoped status check returned exit code `0` with no output for `src`, `test`, `package.json`, or `package-lock.json`; the run did not mutate governed TypeScript files.
- The complete passing suite and named coverage thresholds preserve FR-614-003.
