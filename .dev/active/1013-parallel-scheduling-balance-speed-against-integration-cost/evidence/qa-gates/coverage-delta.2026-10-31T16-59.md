# Coverage Delta

Timestamp: 2026-10-31T16-59
Command: comparison of evidence/baseline/python-tests.2026-10-31T15-06.md, evidence/baseline/powershell-tests.2026-10-31T15-09.md, evidence/qa-gates/python-tests.2026-10-31T16-08.md, and evidence/qa-gates/powershell-tests.2026-10-31T16-59.md
EXIT_CODE: 0
Output Summary: every changed or new production file is measured; no file is excluded; no changed file regresses; every value is numeric. Lowest values: `_blast_radius_combination.py` line 98.75%, branch 91.67%.

| Production file | Status | Baseline line | Baseline branch | Post-change line | Post-change branch | Result |
|---|---|---|---|---|---|---|
| `scripts/dev_tools/_blast_radius_scheduling.py` | changed | 100.00% (143/143) | 100.00% (32/32) | 100.00% (158/158) | 100.00% (36/36) | no regression |
| `scripts/dev_tools/_blast_radius_aggregate.py` | new | n/a | n/a | 100.00% (35/35) | 100.00% (10/10) | meets 85% / 75% |
| `scripts/dev_tools/_blast_radius_combination.py` | new | n/a | n/a | 98.75% (79/80) | 91.67% (22/24) | meets 85% / 75% |
| `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | changed | 100.00% (116/116) | n/a (Pester) | 100.00% (138/138) | n/a (Pester) | no regression |
| `.claude/lib/blast-radius/BlastRadius.psm1` | changed | 100.00% (108/108) | n/a (Pester) | 100.00% (109/109) | n/a (Pester) | no regression |
| `.claude/lib/blast-radius/BlastRadiusAggregate.psm1` | new | n/a | n/a | 100.00% (37/37) | n/a (Pester) | meets 85% line |
| `.claude/lib/blast-radius/BlastRadiusCombination.psm1` | new | n/a | n/a | 100.00% (72/72) | n/a (Pester) | meets 85% line |

Pester measures line coverage only; no branch gate applies to PowerShell. No TypeScript production file changed. The bundle copies under `extensions/drm-copilot/resources/` are byte-identical to the measured sources.
