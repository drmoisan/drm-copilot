# Python Coverage Comparison

- Timestamp: `2026-09-02T23:24:00.1557409-04:00`

## Baseline-to-final comparison

- Command: `node -e "const fs=require('node:fs');const read=(path,name)=>{const text=fs.readFileSync(path,'utf8');const match=text.match(new RegExp('^'+name+':\\s*([0-9]+(?:\\.[0-9]+)?)%?$','m'));if(!match)throw new Error(path+': missing '+name);return Number(match[1]);};const result={baselineLine:read('docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/python-toolchain-baseline.2026-09-02T22-17.md','LINE_COVERAGE'),finalLine:read('docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/python-unit-coverage.2026-09-02T22-17.md','LINE_COVERAGE'),baselineBranch:read('docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/baseline/python-toolchain-baseline.2026-09-02T22-17.md','BRANCH_COVERAGE'),finalBranch:read('docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/qa-gates/python-unit-coverage.2026-09-02T22-17.md','BRANCH_COVERAGE')};console.log(JSON.stringify(result));if(result.finalLine<result.baselineLine||result.finalBranch<result.baselineBranch||result.finalLine<85||result.finalBranch<75)process.exitCode=1;"`
- Exit code: `0`
- Output: `{"baselineLine":92.86076591427847,"finalLine":92.86076591427847,"baselineBranch":85.41811846689896,"finalBranch":85.41811846689896}`

LINE_COVERAGE_BASELINE: 92.86076591427847%
LINE_COVERAGE_FINAL: 92.86076591427847%
BRANCH_COVERAGE_BASELINE: 85.41811846689896%
BRANCH_COVERAGE_FINAL: 85.41811846689896%

## Code-path scope proof

- Command: `git status --porcelain=v1 --untracked-files=all -- '*.py' '*.pyi' '*.ts' '*.tsx' '*.js' '*.mjs' '*.cjs' '*.ps1' '*.psm1' '*.psd1'`
- Exit code: `0`
- Output: no paths.

- Command: `git diff --name-only 6230d7912e1ea6ab600609c11420caad74ffed6e -- '*.py' '*.pyi' '*.ts' '*.tsx' '*.js' '*.mjs' '*.cjs' '*.ps1' '*.psm1' '*.psd1'`
- Exit code: `0`
- Output: no paths.

- Command: `git diff --cached --name-only -- '*.py' '*.pyi' '*.ts' '*.tsx' '*.js' '*.mjs' '*.cjs' '*.ps1' '*.psm1' '*.psd1'`
- Exit code: `0`
- Output: no paths.

## Acceptance verification

- Final Python line and branch coverage are identical to baseline and exceed the required `85%` line and `75%` branch thresholds.
- The P0-T2 classified working tree contained only pre-existing requirement-marker, review, remediation, and evidence paths; it contained no current Python, TypeScript, JavaScript, or PowerShell path.
- The current scoped porcelain output also contains no code path, so no new or executor-owned code path was introduced relative to P0-T2.
- Both anchored code-path diff commands returned zero paths.
- Changed-code coverage: `N/A`, because these observations prove this remediation changes no production or test code file.
