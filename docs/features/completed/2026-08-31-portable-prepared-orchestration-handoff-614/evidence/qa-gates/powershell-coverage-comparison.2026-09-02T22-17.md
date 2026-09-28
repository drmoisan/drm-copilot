# PowerShell Coverage Comparison

- Timestamp: `2026-09-02T23:25:52.7333431-04:00`
- Command: `node -e "const fs=require('node:fs');const read=(path,name)=>{const text=fs.readFileSync(path,'utf8');const match=text.match(new RegExp('^'+name+':\\s*([0-9]+(?:\\.[0-9]+)?)%?$','m'));if(!match)throw new Error(path+': missing '+name);return Number(match[1]);};const result={baselineLine:read('docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/powershell-test-coverage-baseline.2026-09-02T22-17.md','LINE_COVERAGE'),finalLine:read('docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/powershell-unit-coverage.2026-09-02T22-17.md','LINE_COVERAGE')};console.log(JSON.stringify(result));if(result.finalLine<result.baselineLine||result.finalLine<85)process.exitCode=1;"`
- Exit code: `0`
- Output: `{"baselineLine":94.762997,"finalLine":94.762997}`

LINE_COVERAGE_BASELINE: 94.762997%
LINE_COVERAGE_FINAL: 94.762997%

## Acceptance verification

- Final line coverage equals baseline and exceeds the required `85%`.
- The Pester branch-coverage exemption is unchanged because the configured PowerShell coverage tool does not measure branch coverage.
- Changed-code coverage: `N/A`. The zero-code-path porcelain and anchored diff proof is recorded in `evidence/qa-gates/python-coverage-comparison.2026-09-02T22-17.md`.
