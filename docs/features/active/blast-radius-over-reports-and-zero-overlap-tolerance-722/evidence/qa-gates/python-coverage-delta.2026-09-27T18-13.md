# Python Coverage Delta (P15-T5)

Timestamp: 2026-09-27T18-13
Command: poetry run python SCRATCH/changed-lines.py SCRATCH/coverage-722-final.json beae3f021674e64fa6662097fe48a332d8da62b8 scripts/dev_tools/compute_blast_radius.py scripts/dev_tools/_blast_radius_validation.py scripts/dev_tools/parallel_drift_detection.py
EXIT_CODE: 0
Output Summary: PASS. For each of the three pre-existing Python production files, the final line and branch percentages (P15-T4) equal the baseline values (P0-T18) of 100.00, so no file regressed; script changed-lines (B39), anchored to FINAL_BASE beae3f021674e64fa6662097fe48a332d8da62b8, printed ChangedLinePercent=100.00 for all three files (15 changed executable lines, all covered). The three new production files (_blast_radius_scheduling.py, _parallel_drift_scheduling.py, _blast_radius_write_intent.py) have no baseline; their final values are 100.00/100.00, 100.00/100.00, and 97.98/95.24 (line/branch), recorded in P15-T4.

## Baseline vs final vs changed lines

| File | Baseline line / branch (P0-T18) | Final line / branch (P15-T4) | Delta | Changed executable | Covered | ChangedLinePercent |
| --- | --- | --- | --- | --- | --- | --- |
| scripts/dev_tools/compute_blast_radius.py | 100.00 / 100.00 | 100.00 / 100.00 | 0.00 / 0.00 | 10 | 10 | 100.00 |
| scripts/dev_tools/_blast_radius_validation.py | 100.00 / 100.00 | 100.00 / 100.00 | 0.00 / 0.00 | 1 | 1 | 100.00 |
| scripts/dev_tools/parallel_drift_detection.py | 100.00 / 100.00 | 100.00 / 100.00 | 0.00 / 0.00 | 4 | 4 | 100.00 |

## Script B39 output

```text
CHANGED file=scripts/dev_tools/compute_blast_radius.py ChangedExecutable=10 Covered=10 ChangedLinePercent=100.00
CHANGED file=scripts/dev_tools/_blast_radius_validation.py ChangedExecutable=1 Covered=1 ChangedLinePercent=100.00
CHANGED file=scripts/dev_tools/parallel_drift_detection.py ChangedExecutable=4 Covered=4 ChangedLinePercent=100.00
(exit 0)
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
