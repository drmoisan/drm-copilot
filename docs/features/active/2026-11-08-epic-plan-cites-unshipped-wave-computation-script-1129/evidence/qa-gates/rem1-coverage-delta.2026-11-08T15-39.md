# rem1-coverage-delta

Timestamp: 2026-11-08T15-39
Command: comparison of rem1 gate artifacts with baseline gate artifacts
EXIT_CODE: 0
Output Summary:
Each row compares the rem1 gates (qa-gates/rem1-ps-pester, qa-gates/rem1-py-pytest) with the Phase 0 baseline artifacts (baseline/ps-pester, baseline/py-pytest) and, for the new module, the cycle-0 final (qa-gates/ps-pester).
| Subject | Baseline | Final | Rule | Result |
| .claude/lib/epic-wave/EpicWave.psm1 | cycle-0 final: lines 100.00% (56/56); no pre-change run | lines 100.00% (56/56) | >= 85% line, no drop vs cycle-0 final | PASS |
| .codex/hooks/enforce-epic-planning-only.ps1 | lines 95.86% (162/169) | lines 95.86% (162/169) | no line drop | PASS |
| Pester repo-wide | lines 95.56% (35308/36947) | lines 95.57% (35368/37008) | no drop | PASS |
| scripts/dev_tools/epic_wave_computation.py | lines 100.00%, branches 100.00% (8/8) | lines 100.00% (34/34), branches 100.00% (12/12) | no drop; thresholds | PASS |
| scripts/dev_tools/validate_epic_planner_state.py | lines 100.00%, branches 99.00% (99/100) | lines 100.00% (191/191), branches 99.00% (99/100) | no drop; thresholds | PASS |
| scripts/dev_tools/push_down_codex_and_agents_customizations.py | lines 98.17% (107/109), branches 88.89% (16/18) | lines 98.18% (108/110), branches 88.89% (16/18) | no drop; thresholds | PASS |
| pytest repo-wide | lines 97.11%, branches 94.37% (12645/13400) | lines 97.11%, branches 94.36% (12648/13404) | no material drop (unchanged from cycle-0 final; 4 added branches, 3 covered, cycle-0 push-down module) | PASS |
New failing tests: none. Pester 19584 -> 19708 tests, 0 failures; pytest 16537 -> 16559 passed, 0 failed. No TypeScript file changed, so no Jest gate ran.
Note: the pytest repo-wide branch ratio of 94.36% equals the cycle-0 final already accepted; cycle 1 changed no production Python file and its figures are identical (34296/35317 lines, 12648/13404 branches).
