# QC — Coverage Delta and Threshold Verification

Timestamp: 2026-08-19T08-58

Scope: `.claude/hooks/enforce-epic-merge-gate.ps1` (the only production file changed; its bundle mirror is byte-identical and not separately measured).

## Numeric values

- Baseline line coverage (from `evidence/baseline/baseline-pester-coverage.md`): LINE covered=71, missed=5, total=76 -> **93.42%**.
- Post-change line coverage (from `evidence/qa-gates/qc-pester-coverage.md`): LINE covered=100, missed=5, total=105 -> **95.24%**.
- Changed-lines coverage: the change added 29 executable lines (covered count rose 71 -> 100). The missed count is unchanged at 5, and those 5 are the same pre-existing host-bound entrypoint lines present in the baseline. Therefore every newly added executable line is covered -> **changed-lines coverage = 100% (29/29)**.

## Threshold checks

- Line coverage >= 85%: PASS (95.24%).
- No regression on changed lines: PASS (no previously covered line became uncovered; baseline covered set is a subset of post-change covered set; missed count did not increase).
- Overall coverage direction: improved (+1.82 percentage points).

## Verdict

PASS. Line coverage exceeds the 85% threshold and there is no changed-line coverage regression. (Pester does not measure branch coverage; no branch-coverage gate applies to PowerShell per `.claude/rules/quality-tiers.md`.)
