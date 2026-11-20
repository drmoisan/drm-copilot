# P16-T5 Isolation runs on the remediated tree

Timestamp: 2026-10-30T01-45
Task: [P16-T5] Run the isolation checks on the remediated tree.
Command: sh SCRATCH/issue-980-p16t5.sh (node run-jest.cjs --randomize --seed=1616 in extensions/drm-copilot and at the worktree root; pwsh -File SCRATCH/issue-980-p16t5-pester-shuffle.ps1 -Seed 161, 262 and 363; poetry run python SCRATCH/issue-980-reversed.py SCRATCH/issue-980-p16t5-python-modules.txt)
EXIT_CODE: 0 (Jest extension), 0 (Jest root), 0 / 0 / 0 (Pester seeds 161, 262, 363), 0 (Python)
Output Summary: Every order passes; no order dependence was found, so no fix and no loop repeat were needed. Run window 2026-10-30T01-43 to 01-45 UTC on the tree after the P16-T4 repair commit (the last file change of Phase 16 before this task).

| Run | Record | Result |
| --- | --- | --- |
| Seeded shuffled Jest, seed 1616, extension and root | `p16-isolation-jest-seed-1616.2026-10-30T01-45.md` | 321 suites / 5177 tests and 324 suites / 5194 tests passed |
| Reversed-order Python, 12 Phase 15 modules in one process, test_catalog.py last | `p16-isolation-python-reversed.2026-10-30T01-45.md` | 292 passed |
| Seeded shuffled Pester file order, seeds 161, 262, 363, 25 Phase 15 suites | `p16-isolation-pester-seeds.2026-10-30T01-45.md` | 538 passed per seed, executed order equals seeded order |
| Fresh single-process Pester run over the full population | `evidence/qa-gates/p16-powershell-single-process.2026-10-30T01-29.md` (P16-T3) | 12744 tests, 0 failed |

Result: PASS
