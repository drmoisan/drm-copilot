# PowerShell Coverage Delta (P16-T5)

Timestamp: 2026-09-27T18-24
Command: poetry run python SCRATCH/changed-lines-cov.py jacoco SCRATCH/pester-final.xml beae3f021674e64fa6662097fe48a332d8da62b8 .claude/lib/blast-radius/BlastRadius.psm1 .claude/lib/blast-radius/BlastRadiusValidation.psm1
EXIT_CODE: 0
Output Summary: PASS. Facade BlastRadius.psm1: baseline 100 (P0-T32), final 100 (P16-T4), delta 0. Validation module BlastRadiusValidation.psm1: baseline 97, final 97.03, delta +0.03. Both are at least their baseline and at least 85. New modules (no baseline): BlastRadiusScheduling.psm1 100 and BlastRadiusWriteIntent.psm1 100, both >= 85. Script changed-lines-cov (B42), anchored to FINAL_BASE beae3f021674e64fa6662097fe48a332d8da62b8, printed Found=True and ChangedLinePercent=100.00 for the facade (15 of 15 changed executable lines covered) and for the validation module (2 of 2).

## Baseline vs final vs changed lines

| Module | Baseline LinePercent (P0-T32) | Final LinePercent (P16-T4) | Delta | Changed executable | Covered | ChangedLinePercent |
| --- | --- | --- | --- | --- | --- | --- |
| .claude/lib/blast-radius/BlastRadius.psm1 | 100 (97/97) | 100 (107/107) | 0 | 15 | 15 | 100.00 |
| .claude/lib/blast-radius/BlastRadiusValidation.psm1 | 97 (97/100) | 97.03 (98/101) | +0.03 | 2 | 2 | 100.00 |
| .claude/lib/blast-radius/BlastRadiusScheduling.psm1 | new | 100 (122/122) | n/a | n/a | n/a | n/a |
| .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 | new | 100 (102/102) | n/a | n/a | n/a | n/a |

## Script B42 output

```text
CHANGED file=.claude/lib/blast-radius/BlastRadius.psm1 Found=True ExecutableLines=107 ChangedExecutable=15 Covered=15 ChangedLinePercent=100.00
CHANGED file=.claude/lib/blast-radius/BlastRadiusValidation.psm1 Found=True ExecutableLines=101 ChangedExecutable=2 Covered=2 ChangedLinePercent=100.00
(exit 0)
```

Branch coverage is not measured for PowerShell (Pester does not report it), so only line coverage applies.

SCRATCH denotes the executor session scratchpad directory (outside the repository).
