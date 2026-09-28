# TypeScript Coverage Baseline

Timestamp: 2026-09-03T02-54
Command: `npm run test:coverage` (working directory: `extensions/drm-copilot`)
EXIT_CODE: 0

Output Summary: Jest completed 213 of 213 suites and 2,894 of 2,894 tests successfully. Overall line coverage was 96.78% and branch coverage was 90.28%. Machine-readable LCOV output was preserved at `extensions/drm-copilot/coverage/lcov.info`.

OVERALL_LINE_COVERAGE: 96.78%
OVERALL_BRANCH_COVERAGE: 90.28%
AUTHORITY_SERVICE_LINE_COVERAGE: 97.73584905660377%
PATH_BOUNDARY_LINE_COVERAGE: 97.5609756097561%
AUTHORITY_SERVICE_LINES: 259/265
PATH_BOUNDARY_LINES: 200/205

```text
Statements   : 96.78% ( 47197/48763 )
Branches     : 90.28% ( 6729/7453 )
Functions    : 90.54% ( 1407/1554 )
Lines        : 96.78% ( 47197/48763 )
Test Suites: 213 passed, 213 total
Tests:       2894 passed, 2894 total
Snapshots:   0 total
```

Command: `node -e "const fs=require('node:fs');const text=fs.readFileSync('coverage/lcov.info','utf8');for(const record of text.split('end_of_record')){const sf=record.match(/^SF:(.+)$/m)?.[1];if(sf&&/orchestration-handoff-(authority-service|path-boundary)\.ts$/.test(sf)){const get=k=>Number(record.match(new RegExp('^'+k+':(\\d+)$','m'))?.[1]??0);const lh=get('LH'),lf=get('LF'),brh=get('BRH'),brf=get('BRF');console.log(JSON.stringify({file:sf,lineCovered:lh,lineTotal:lf,linePercent:lf?lh/lf*100:100,branchCovered:brh,branchTotal:brf,branchPercent:brf?brh/brf*100:100}));}}"` (working directory: `extensions/drm-copilot`)
EXIT_CODE: 0

Output Summary: Authority-service coverage was 259/265 lines (97.73584905660377%); path-boundary coverage was 200/205 lines (97.5609756097561%).

```json
{"file":"src\\lib\\validate\\orchestration-handoff-authority-service.ts","lineCovered":259,"lineTotal":265,"linePercent":97.73584905660377,"branchCovered":42,"branchTotal":48,"branchPercent":87.5}
{"file":"src\\lib\\validate\\orchestration-handoff-path-boundary.ts","lineCovered":200,"lineTotal":205,"linePercent":97.5609756097561,"branchCovered":43,"branchTotal":53,"branchPercent":81.13207547169812}
```

Command: `git status --porcelain=v1 --untracked-files=all -- 'extensions/drm-copilot/src' 'extensions/drm-copilot/test' 'extensions/drm-copilot/package.json' 'extensions/drm-copilot/package-lock.json'`
EXIT_CODE: 0

Output Summary: No TypeScript source, test, package, or lockfile mutation was produced by the coverage run. The complete passing suite preserves the resolved FR-614-001 containment/failure-precedence behavior and FR-614-003 authority-service coverage baseline.
