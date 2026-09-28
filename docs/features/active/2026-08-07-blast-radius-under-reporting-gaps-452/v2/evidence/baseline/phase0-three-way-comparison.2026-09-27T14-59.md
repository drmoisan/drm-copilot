# Phase 0 Three-Way Comparison (P0-T33)

Timestamp: 2026-09-27T14-59

Command: poetry run python `<scratchpad>`/compare_verdicts.py `<scratchpad>`/phase0-python-output.txt `<scratchpad>`/phase0-powershell-output.txt

EXIT_CODE: 0

Full output:

```
COMPARE g1-plan-poetry-lock python=[conflict=True reasons=[path_overlap|poetry.lock ~ poetry.lock; shared_surface_overlap|poetry.lock]] powershell=[conflict=True reasons=[path_overlap|poetry.lock ~ poetry.lock; shared_surface_overlap|poetry.lock]] trace=[conflict=True reasons=[path_overlap|poetry.lock ~ poetry.lock; shared_surface_overlap|poetry.lock]] AGREE
COMPARE g1-plan-package-lock python=[conflict=True reasons=[path_overlap|package-lock.json ~ package-lock.json; shared_surface_overlap|package-lock.json]] powershell=[conflict=True reasons=[path_overlap|package-lock.json ~ package-lock.json; shared_surface_overlap|package-lock.json]] trace=[conflict=True reasons=[path_overlap|package-lock.json ~ package-lock.json; shared_surface_overlap|package-lock.json]] AGREE
COMPARE g1-plan-different-surfaces python=[conflict=False reasons=[]] powershell=[conflict=False reasons=[]] trace=[conflict=False reasons=[]] AGREE
COMPARE g1-plan-unconfigured-root-file python=[conflict=False reasons=[]] powershell=[conflict=False reasons=[]] trace=[conflict=False reasons=[]] AGREE
COMPARE g1-plan-quality-tiers-mandate-read python=[conflict=False reasons=[]] powershell=[conflict=False reasons=[]] trace=[conflict=False reasons=[]] AGREE
COMPARE g1-radius-quality-tiers python=[conflict=True reasons=[path_overlap|quality-tiers.yml ~ quality-tiers.yml; shared_surface_overlap|quality-tiers.yml]] powershell=[conflict=True reasons=[path_overlap|quality-tiers.yml ~ quality-tiers.yml; shared_surface_overlap|quality-tiers.yml]] trace=[conflict=True reasons=[path_overlap|quality-tiers.yml ~ quality-tiers.yml; shared_surface_overlap|quality-tiers.yml]] AGREE
COMPARE g1-radius-quality-tiers-vs-poetry-lock python=[conflict=False reasons=[]] powershell=[conflict=False reasons=[]] trace=[conflict=False reasons=[]] AGREE
COMPARE g2-dir-vs-glob python=[conflict=True reasons=[path_overlap|scripts/dev_tools ~ scripts/dev_tools/**]] powershell=[conflict=True reasons=[path_overlap|scripts/dev_tools ~ scripts/dev_tools/**]] trace=[conflict=True reasons=[path_overlap|scripts/dev_tools ~ scripts/dev_tools/**]] AGREE
COMPARE g2-glob-vs-dir python=[conflict=True reasons=[path_overlap|scripts/dev_tools ~ scripts/dev_tools/**]] powershell=[conflict=True reasons=[path_overlap|scripts/dev_tools ~ scripts/dev_tools/**]] trace=[conflict=True reasons=[path_overlap|scripts/dev_tools ~ scripts/dev_tools/**]] AGREE
COMPARE g2-dir-vs-sibling-glob python=[conflict=False reasons=[]] powershell=[conflict=False reasons=[]] trace=[conflict=False reasons=[]] AGREE
COMPARE g2-sibling-glob-vs-dir python=[conflict=False reasons=[]] powershell=[conflict=False reasons=[]] trace=[conflict=False reasons=[]] AGREE
COMPARE g2-artifacts-dir-vs-glob python=[conflict=True reasons=[path_overlap|artifacts/orchestration ~ artifacts/orchestration/**]] powershell=[conflict=True reasons=[path_overlap|artifacts/orchestration ~ artifacts/orchestration/**]] trace=[conflict=True reasons=[path_overlap|artifacts/orchestration ~ artifacts/orchestration/**]] AGREE
COMPARE g2-artifacts-glob-vs-dir python=[conflict=True reasons=[path_overlap|artifacts/orchestration ~ artifacts/orchestration/**]] powershell=[conflict=True reasons=[path_overlap|artifacts/orchestration ~ artifacts/orchestration/**]] trace=[conflict=True reasons=[path_overlap|artifacts/orchestration ~ artifacts/orchestration/**]] AGREE
COMPARE g2-artifacts-dir-vs-sibling-glob python=[conflict=False reasons=[]] powershell=[conflict=False reasons=[]] trace=[conflict=False reasons=[]] AGREE
COMPARE g2-artifacts-sibling-glob-vs-dir python=[conflict=False reasons=[]] powershell=[conflict=False reasons=[]] trace=[conflict=False reasons=[]] AGREE
COMPARE g2-empty-modules-dir-vs-glob python=[conflict=True reasons=[path_overlap|scripts/powershell/PoshQC ~ scripts/powershell/PoshQC/**]] powershell=[conflict=True reasons=[path_overlap|scripts/powershell/PoshQC ~ scripts/powershell/PoshQC/**]] trace=[conflict=True reasons=[path_overlap|scripts/powershell/PoshQC ~ scripts/powershell/PoshQC/**]] AGREE
COMPARE g2-empty-modules-dir-vs-sibling-glob python=[conflict=False reasons=[]] powershell=[conflict=False reasons=[]] trace=[conflict=False reasons=[]] AGREE
CASES_COMPARED=17 PYTHON_CASES=17 POWERSHELL_CASES=17
BRANCH=AGREE
```

Per-case agreement (Python, PowerShell, and research trace):

| Case | All three agree |
| --- | --- |
| g1-plan-poetry-lock | yes |
| g1-plan-package-lock | yes |
| g1-plan-different-surfaces | yes |
| g1-plan-unconfigured-root-file | yes |
| g1-plan-quality-tiers-mandate-read | yes |
| g1-radius-quality-tiers | yes |
| g1-radius-quality-tiers-vs-poetry-lock | yes |
| g2-dir-vs-glob | yes |
| g2-glob-vs-dir | yes |
| g2-dir-vs-sibling-glob | yes |
| g2-sibling-glob-vs-dir | yes |
| g2-artifacts-dir-vs-glob | yes |
| g2-artifacts-glob-vs-dir | yes |
| g2-artifacts-dir-vs-sibling-glob | yes |
| g2-artifacts-sibling-glob-vs-dir | yes |
| g2-empty-modules-dir-vs-glob | yes |
| g2-empty-modules-dir-vs-sibling-glob | yes |

Output Summary: EXIT_CODE 0; CASES_COMPARED=17 PYTHON_CASES=17 POWERSHELL_CASES=17; 17 COMPARE lines, all AGREE; BRANCH=AGREE. P1-T1 consumes this branch.
