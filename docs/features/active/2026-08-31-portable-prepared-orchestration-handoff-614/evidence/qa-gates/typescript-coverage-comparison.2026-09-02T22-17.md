# TypeScript Coverage Comparison

- Timestamp: `2026-09-02T23:25:05.6363039-04:00`
- Command: `node -e "const fs=require('node:fs');const read=(path,name)=>{const text=fs.readFileSync(path,'utf8');const match=text.match(new RegExp('^'+name+':\\s*([0-9]+(?:\\.[0-9]+)?)%?$','m'));if(!match)throw new Error(path+': missing '+name);return Number(match[1]);};const baseline='docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/typescript-coverage-baseline.2026-09-02T22-17.md',final='docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/typescript-unit-coverage.2026-09-02T22-17.md',names=['OVERALL_LINE_COVERAGE','OVERALL_BRANCH_COVERAGE','AUTHORITY_SERVICE_LINE_COVERAGE','PATH_BOUNDARY_LINE_COVERAGE'];const result=Object.fromEntries(names.map(name=>[name,{baseline:read(baseline,name),final:read(final,name)}]));console.log(JSON.stringify(result));if(result.OVERALL_LINE_COVERAGE.final<Math.max(85,result.OVERALL_LINE_COVERAGE.baseline)||result.OVERALL_BRANCH_COVERAGE.final<Math.max(75,result.OVERALL_BRANCH_COVERAGE.baseline)||result.AUTHORITY_SERVICE_LINE_COVERAGE.final<Math.max(90,result.AUTHORITY_SERVICE_LINE_COVERAGE.baseline)||result.PATH_BOUNDARY_LINE_COVERAGE.final<Math.max(90,result.PATH_BOUNDARY_LINE_COVERAGE.baseline))process.exitCode=1;"`
- Exit code: `0`
- Output: `{"OVERALL_LINE_COVERAGE":{"baseline":96.78,"final":96.78},"OVERALL_BRANCH_COVERAGE":{"baseline":90.28,"final":90.28},"AUTHORITY_SERVICE_LINE_COVERAGE":{"baseline":97.73584905660377,"final":97.73584905660377},"PATH_BOUNDARY_LINE_COVERAGE":{"baseline":97.5609756097561,"final":97.5609756097561}}`

OVERALL_LINE_COVERAGE_BASELINE: 96.78%
OVERALL_LINE_COVERAGE_FINAL: 96.78%
OVERALL_BRANCH_COVERAGE_BASELINE: 90.28%
OVERALL_BRANCH_COVERAGE_FINAL: 90.28%
AUTHORITY_SERVICE_LINE_COVERAGE_BASELINE: 97.73584905660377%
AUTHORITY_SERVICE_LINE_COVERAGE_FINAL: 97.73584905660377%
PATH_BOUNDARY_LINE_COVERAGE_BASELINE: 97.5609756097561%
PATH_BOUNDARY_LINE_COVERAGE_FINAL: 97.5609756097561%

## Acceptance verification

- All four final values equal their baselines.
- Overall coverage exceeds the `85%` line and `75%` branch thresholds.
- Authority-service and path-boundary line coverage each exceeds `90%`.
- Changed-code coverage: `N/A`. The zero-code-path porcelain and anchored diff proof is recorded in `evidence/qa-gates/python-coverage-comparison.2026-09-02T22-17.md`.
