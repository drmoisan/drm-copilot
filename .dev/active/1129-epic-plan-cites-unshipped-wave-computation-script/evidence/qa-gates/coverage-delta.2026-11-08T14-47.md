# coverage-delta

Timestamp: 2026-11-08T14-47
Command: comparison of qa-gates and baseline gate artifacts
EXIT_CODE: 0
Output Summary:
Each row compares a gate with its Phase 0 baseline artifact (baseline/ts-jest, baseline/ps-pester, baseline/py-pytest) and the final gate artifact (qa-gates/ts-jest, qa-gates/ps-pester, qa-gates/py-pytest).
| Subject | Baseline | Final | Rule | Result |
| .claude/lib/epic-wave/EpicWave.psm1 (new) | N/A - no pre-change run | lines 100.00% (56/56) | >= 85% line | PASS |
| .claude/lib/epic-wave/Invoke-EpicWave.ps1 (new) | N/A - no pre-change run | lines 100.00% (5/5) | >= 85% line | PASS |
| .codex/hooks/enforce-epic-planning-only.ps1 | lines 95.86% (162/169) | lines 95.86% (162/169) | no line drop | PASS |
| Pester repo-wide | lines 95.56% (35308/36947) | lines 95.57% (35368/37008) | no drop | PASS |
| scripts/dev_tools/epic_wave_computation.py | lines 100.00%, branches 100.00% (8/8) | lines 100.00% (34/34), branches 100.00% (12/12) | no drop; >= 85% line, >= 75% branch | PASS |
| scripts/dev_tools/validate_epic_planner_state.py | lines 100.00%, branches 99.00% (99/100) | lines 100.00% (191/191), branches 99.00% (99/100) | no drop; thresholds | PASS |
| scripts/dev_tools/push_down_codex_and_agents_customizations.py | lines 98.17% (107/109), branches 88.89% (16/18) | lines 98.18% (108/110), branches 88.89% (16/18) | no drop; thresholds | PASS |
| pytest repo-wide | lines 97.11%, branches 94.37% (12645/13400) | lines 97.11%, branches 94.36% (12648/13404) | no material drop (ratio of added covered branches, 3 of 4) | PASS |
| extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts | lines 98.98% (387/391), branches 95.65% (66/69) | lines 98.97% (390/394), branches 95.71% (67/70) | within its coverageThreshold entry (Jest exit 0); the 3 added lines and 1 added branch are all covered, uncovered lines stay at 4 and uncovered branches at 3 | PASS |
| Jest repo-wide | lines 97.13%, branches 93.81% | lines 97.13%, branches 93.81% | no drop | PASS |
New failing tests: none. Jest 5446 -> 5448 passed, 0 failed; Pester 19584 -> 19623 tests, 0 failures; pytest 16537 -> 16555 passed, 0 failed.
Notes: the codex-agents-customizations.ts percentage moves by 0.01 point only because 3 added lines (all covered) enlarge the denominator; its uncovered line count (4) and uncovered branch count (3) are unchanged, so changed-line coverage is 100%. The pytest repo-wide branch ratio moves from 94.37% to 94.36% for the same arithmetic reason (4 added branches, 3 covered, in the changed push-down module path); every changed file holds or improves its own figures.
