# Remediation Cycle 1 Coverage Comparison (P3-T5, QA pass 1)

Timestamp: 2026-10-16T07-50
Command: sh SCRATCH/929/RC1-P3-T5-1.sh
EXIT_CODE: 0

Script: SCRATCH/929/RC1-P3-T5-1.ps1, verbatim:

```powershell
$ErrorActionPreference = 'Stop'; $fd = 'docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence'; $b = Get-ChildItem -LiteralPath ($fd + '/remediation-baseline') -Filter 'rc1-suite-coverage-baseline.*.md' | Sort-Object Name | Select-Object -Last 1; $f = Get-ChildItem -LiteralPath ($fd + '/qa-gates') -Filter 'rc1-final-suite-coverage.*.md' | Sort-Object Name | Select-Object -Last 1; 'BASELINE_ARTIFACT=' + $b.Name; 'FINAL_ARTIFACT=' + $f.Name; $cp = 'HOOK_LINE_COUNTER=<counter type="LINE" missed="(\d+)" covered="(\d+)" />'; $bc = @(Select-String -LiteralPath $b.FullName -Pattern $cp)[0].Matches[0]; $fc = @(Select-String -LiteralPath $f.FullName -Pattern $cp)[0].Matches[0]; $bp = [int]@(Select-String -LiteralPath $b.FullName -Pattern '^PASSED=(\d+)$')[0].Matches[0].Groups[1].Value; $fp = [int]@(Select-String -LiteralPath $f.FullName -Pattern '^PASSED=(\d+)$')[0].Matches[0].Groups[1].Value; $bm = [int]$bc.Groups[1].Value; $bt = $bm + [int]$bc.Groups[2].Value; $fm = [int]$fc.Groups[1].Value; $ft = $fm + [int]$fc.Groups[2].Value; 'BASELINE_MISSED=' + $bm; 'FINAL_MISSED=' + $fm; 'BASELINE_TOTAL=' + $bt; 'FINAL_TOTAL=' + $ft; 'BASELINE_PASSED=' + $bp; 'FINAL_PASSED=' + $fp; $ok = @(($fm -le $bm), ($ft -eq $bt), ($fp -eq $bp)); 'MISSED_NOT_INCREASED=' + $ok[0]; 'TOTAL_EQUAL=' + $ok[1]; 'PASSED_EQUAL=' + $ok[2]; exit @($ok | Where-Object { -not $_ }).Count
```

Output (verbatim):

```
BASELINE_ARTIFACT=rc1-suite-coverage-baseline.2026-10-16T07-05.md
FINAL_ARTIFACT=rc1-final-suite-coverage.2026-10-16T07-49.md
BASELINE_MISSED=18
FINAL_MISSED=18
BASELINE_TOTAL=102
FINAL_TOTAL=102
BASELINE_PASSED=66
FINAL_PASSED=66
MISSED_NOT_INCREASED=True
TOTAL_EQUAL=True
PASSED_EQUAL=True
```

Output Summary: baseline missed 18 of 102, final missed 18 of 102 (totals equal, missed not increased); passed 66 in both runs. Final HOOK_LINE_PCT=82.35 (quoted from `rc1-final-suite-coverage.2026-10-16T07-49.md`; this figure is the hook's coverage under this one suite only, and the hook's coverage under the full run is 100/102 in `coverage-repo-wide.2026-10-16T07-38.md`).
