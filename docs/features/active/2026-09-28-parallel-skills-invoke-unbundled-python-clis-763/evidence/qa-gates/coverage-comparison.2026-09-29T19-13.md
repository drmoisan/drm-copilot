# Coverage Comparison (P11-T5)

Timestamp: 2026-09-29T19-13
Command: comparison of the recorded artifacts of P0-T15, P0-T19, P0-T21, P0-T22, P8-T5, P9-T5, P11-T3, and P11-T4 (no new command)
EXIT_CODE: 0
Output Summary:
- bash: PASS (headline 93.3 -> 93.4; abandon-parallel-item.sh 94.6% line)
- PowerShell: PASS (hook 93.59 -> 93.59; new files 100.00 / 100.00 / 94.79)
- Python: PASS (skill_bundle_contract 96.45/95.00 -> 96.45/95.00; skill_bundle_contract_cli
  92.98/77.27 -> 93.10/77.27; 0 uncovered changed lines in each)
- TypeScript: NOT-APPLICABLE
- Overall Disposition: PASS

## bash

Baseline Coverage: 93.3 (CI headline `Bash coverage (lines): 93.3%`, run 36636142693, P0-T21);
COBERTURA-TOTAL line-rate 0.933 (P0-T22)
Post-Change Coverage: 93.4 (CI headline `Bash coverage (lines): 93.4%`, run 36645685724 at FINAL_SHA,
P11-T3); COBERTURA-TOTAL line-rate 0.934 (P11-T4)
New/Changed-code Coverage: `.claude/lib/bash/abandon-parallel-item.sh` line-rate 0.946 (94.6%;
threshold 0.85) (P11-T4)
Disposition: PASS (P11-T3: NOT-OK-COUNT=0, headline >= 85.0, OK-COUNT 498 = 478 + 20; P11-T4:
line-rate >= 0.85). kcov measures no branches; no bash branch threshold applies.

## PowerShell

Baseline Coverage: `.claude/hooks/enforce-parallel-abandon-gate.ps1` LinePercent 93.59 (P0-T19). The
three new files are absent at BASE_SHA: `.claude/lib/parallel-drift/ParallelDriftHalt.psm1`,
`.claude/lib/parallel-drift/ParallelDrift.psm1`,
`.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1` (baseline: absent at BASE_SHA).
Post-Change Coverage: `.claude/hooks/enforce-parallel-abandon-gate.ps1` LinePercent 93.59 (P8-T5;
not below its baseline).
New/Changed-code Coverage: ParallelDriftHalt.psm1 100.00 (67/67), ParallelDrift.psm1 100.00
(123/123), Invoke-ParallelDriftDetection.ps1 94.79 (91/96) (P8-T5; each >= 85). The hook change is
comment-only (P6-T6).
Disposition: PASS. Pester measures no branches; no PowerShell branch threshold applies.

## Python

Baseline Coverage (P0-T15): `scripts/dev_tools/skill_bundle_contract.py` Line 96.45 / Branch 95.00;
`scripts/dev_tools/skill_bundle_contract_cli.py` Line 92.98 / Branch 77.27.
Post-Change Coverage (P9-T5): `scripts/dev_tools/skill_bundle_contract.py` Line 96.45 / Branch 95.00;
`scripts/dev_tools/skill_bundle_contract_cli.py` Line 93.10 / Branch 77.27 (each line >= 85 and >=
its baseline; each branch >= 75).
New/Changed-code Coverage (A19 against BASE_SHA): skill_bundle_contract.py ChangedLines=5,
ChangedExecutableLines=1, UncoveredChangedLines=0; skill_bundle_contract_cli.py ChangedLines=13,
ChangedExecutableLines=1, UncoveredChangedLines=0.
Disposition: PASS (`test_main_returns_one_for_stale_exception` PASSED, so the stale-exception branch
is executed).

## TypeScript

Disposition: NOT-APPLICABLE. No TypeScript source or test file changed (the name-only diff against
BASE_SHA in qa-gates/final-commit lists none); the push-down Jest regression over the bundle
resources this plan edits passed 262 of 262 (P10-T1).

## Overall

Disposition: PASS. Every threshold of P8-T5, P9-T5, P11-T3, and P11-T4 holds.
