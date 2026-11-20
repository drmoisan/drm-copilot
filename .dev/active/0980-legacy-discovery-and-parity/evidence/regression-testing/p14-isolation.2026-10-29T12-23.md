# P14-T11 Isolation runs on the final tree

Timestamp: 2026-10-29T12-23
Task: [P14-T11] Repeat the isolation runs on the final tree, discharging [P13-T5].
Command: sh SCRATCH/issue-980-p14t11.sh (node run-jest.cjs --randomize --seed=1414 in extensions/drm-copilot; pwsh -File SCRATCH/issue-980-p14t11-pester-shuffle.ps1 -Seed 141, 242 and 343; poetry run python SCRATCH/issue-980-reversed.py SCRATCH/issue-980-p14t11-python-modules.txt)
EXIT_CODE: 0 (Jest), 0 / 0 / 0 (Pester seeds 141, 242, 343), 0 (Python)
Output Summary: Every order passes; no order dependence was found, so no fix and no loop repeat were needed. Run window 2026-10-29T12-20 to 12-23 UTC on the tree after P14-T8 (the last file change of Phase 14).

| Run | Record | Result |
| --- | --- | --- |
| Seeded shuffled Jest, seed 1414 | `p14-isolation-jest-seed-1414.2026-10-29T12-23.md` | 316 suites, 5109 tests passed |
| Reversed-order Python, 25 modules in one process | `p14-isolation-python-reversed.2026-10-29T12-23.md` | 664 passed |
| Seeded shuffled Pester file order, seeds 141, 242, 343, 15 suites | `p14-isolation-pester-seeds.2026-10-29T12-23.md` | 242 passed per seed, executed order equals seeded order |

The evidence committed for P13-T5 (`p13-isolation*.2026-10-29T02-27.md`) predates the catalog correction and the latest rebase; it is retained and is not cited as final proof. [P13-T5] is discharged by this task.

Result: PASS
