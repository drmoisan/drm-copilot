# Coverage and File-Size Comparison (P6-T9)

Timestamp: 2026-11-10T02-09
Command: python SCRATCH/issue-1164-changed-cov.py <worktree> <merge base> SCRATCH (changed lines from git diff -U0 of the merge base of origin/main and HEAD against HEAD, intersected with the executable and missed lines of SCRATCH/issue-1164-cov-final4.json, SCRATCH/issue-1164-jest-final2-lcov.info, artifacts/pester/powershell-coverage.xml, and SCRATCH/shell-final/cov.xml); awk 'END{print NR}' over every changed or new file for logical line counts
EXIT_CODE: 0
Output Summary:
- Verdict: PASS. Every changed file shows no drop against the Phase 0 baseline, every new file is at or above 90% line coverage, every changed line is covered except one line of a new file, and no file exceeds a size ceiling. No figure is missing.
- Inputs: baseline artifacts evidence/baseline/pester-gate.2026-11-09T23-35.md, pytest-gate.2026-11-09T23-39.md, jest-gate.2026-11-09T23-40.md, shell-ci.2026-11-09T23-37.md; final artifacts evidence/qa-gates/pester-gate.2026-11-10T01-17.md, pytest-gate.2026-11-10T01-35.md, jest-gate.2026-11-10T01-35.md, shell-ci.2026-11-10T02-07.md. Merge base: ff9d8afc0a61ac723cd449b0c0658ea42680cd2e.
- Repo-wide: PowerShell line 95.79% -> 95.81%; Python line 97.11% -> 97.13%, branch 94.38% -> 94.41%; TypeScript lines 97.15% -> 97.16%, branches 93.87% -> 93.91%; bash (kcov) line 94.7% -> 94.9%.

## Per-File Coverage

| File | Baseline | Post-change | Changed-line coverage | Threshold | Result |
|---|---|---|---|---|---|
| .claude/lib/blast-radius/BlastRadiusScheduling.psm1 | 100.00% (138/138) | 100.00% (136/136) | 13/13 = 100.00% | 85% line | PASS |
| .claude/lib/blast-radius/BlastRadiusAccess.psm1 (new) | N/A - no pre-change run | 100.00% (53/53) | 53/53 = 100.00% | 90% line (new) | PASS |
| .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1 | 100.00% (179/179) | 100.00% (179/179) | 4/4 = 100.00% | 85% line | PASS |
| .claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1 (new) | N/A - no pre-change run | 97.62% (41/42) | 41/42 = 97.62% (line 65 missed) | 90% line (new) | PASS |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 96.48% (219/227) | 96.79% (241/249) | 29/29 = 100.00% (missed lines are pre-existing, outside the changed hunks) | 85% line | PASS |
| .claude/lib/parallel-drift/ParallelDrift.psm1 | 100.00% (123/123) | 100.00% (128/128) | 8/8 = 100.00% | 85% line | PASS |
| .claude/lib/parallel-drift/ParallelDriftAccess.psm1 (new) | N/A - no pre-change run | 100.00% (14/14) | 14/14 = 100.00% | 90% line (new) | PASS |
| scripts/dev_tools/_blast_radius_scheduling.py | 100.00% / 100.00% | 100.00% / 100.00% (171/171, 40/40) | 17/17 = 100.00% | 85% line, 75% branch | PASS |
| scripts/dev_tools/_parallel_drift_scheduling.py | 100.00% / 100.00% | 100.00% / 100.00% (47/47, 18/18) | 16/16 = 100.00% | 85% line, 75% branch | PASS |
| scripts/dev_tools/_parallel_state_records.py | 100.00% / 100.00% | 100.00% / 100.00% (191/191, 96/96) | 103/103 = 100.00% | 85% line, 75% branch | PASS |
| scripts/dev_tools/parallel_drift_detection.py | 100.00% / 100.00% | 100.00% / 100.00% (80/80, 26/26) | 1/1 = 100.00% | 85% line, 75% branch | PASS |
| scripts/dev_tools/parallel_drift_detection_cli.py | 100.00% / 100.00% | 100.00% / 100.00% (75/75, 10/10) | 2/2 = 100.00% | 85% line, 75% branch | PASS |
| scripts/dev_tools/parallel_manifest_contract.py | 100.00% / 100.00% | 100.00% / 100.00% (168/168, 82/82) | 55/55 = 100.00% | 85% line, 75% branch | PASS |
| scripts/dev_tools/validate_parallel_planner_state.py | 100.00% / 100.00% | 100.00% / 100.00% (117/117, 46/46) | 2/2 = 100.00% | 85% line, 75% branch | PASS |
| scripts/dev_tools/validate_parallel_orchestrator_state.py | 97.73% / 94.12% | 97.78% / 94.12% (88/90, 32/34) | 2/2 = 100.00% (missed lines 235 and 274 and their branches are pre-existing, outside the changed hunks) | 85% line, 75% branch | PASS |
| extensions/drm-copilot/src/lib/validate/parallel-state-records.ts | 100.00% / 100.00% | 100.00% / 100.00% (643/643, 141/141) | 297/297 = 100.00% | 85% line, 75% branch | PASS |
| extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts | 100.00% / 97.96% | 100.00% / 97.96% (468/468, 48/49) | 4/4 = 100.00% (the zero-count branch is pre-existing, outside the changed hunks) | 85% line, 75% branch | PASS |
| extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts | 99.38% / 92.11% | 99.39% / 92.11% (324/326, 35/38) | 4/4 = 100.00% (missed lines and zero-count branches are pre-existing, outside the changed hunks) | 85% line, 75% branch | PASS |
| .claude/lib/bash/parallel-manifest-validate.sh | 97.5% (117/120) | 97.54% (119/122) | 2/2 = 100.00% (missed lines 97, 98, 262 are pre-existing) | 85% line | PASS |
| .claude/lib/bash/parallel-manifest-pairs.sh (new) | N/A - no pre-change run | 100.00% (68/68) | 68/68 = 100.00% | 90% line (new) | PASS |

## Logical Line Counts (awk END{print NR})

Ceilings: hard limit 800 for every file (Markdown exempt); plan ceilings of 700 for Invoke-ParallelAdmission.ps1, _blast_radius_scheduling.py, and Invoke-ParallelAdmission.Tests.ps1.

| File | Lines | Result |
|---|---|---|
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 678 | PASS (<= 700) |
| scripts/dev_tools/_blast_radius_scheduling.py | 641 | PASS (<= 700) |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | 695 (unchanged by this branch) | PASS (<= 700) |
| extensions/drm-copilot/src/lib/validate/parallel-state-records.ts | 643 | PASS |
| scripts/dev_tools/parallel_manifest_contract.py | 580 | PASS |
| .claude/lib/blast-radius/BlastRadiusScheduling.psm1 | 542 | PASS |
| .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1 | 513 | PASS |
| scripts/dev_tools/_parallel_state_records.py | 500 | PASS |
| scripts/dev_tools/parallel_drift_detection_cli.py | 477 | PASS |
| .claude/lib/parallel-drift/ParallelDrift.psm1 | 476 | PASS |
| scripts/dev_tools/parallel_drift_detection.py | 475 | PASS |
| extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts | 468 | PASS |
| scripts/dev_tools/validate_parallel_planner_state.py | 465 | PASS |
| tests/scripts/dev_tools/test_blast_radius_scheduling.py | 452 | PASS |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1 | 417 | PASS |
| tests/scripts/dev_tools/test_parallel_drift_detection_cli.py | 411 | PASS |
| tests/scripts/dev_tools/test_parallel_issue_combination_contracts.py | 406 | PASS |
| tests/scripts/dev_tools/test_blast_radius_contract_weight.py | 399 | PASS |
| tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 | 374 | PASS |
| scripts/dev_tools/validate_parallel_orchestrator_state.py | 348 | PASS |
| extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts | 326 | PASS |
| .claude/lib/bash/parallel-manifest-validate.sh | 306 | PASS |
| tests/scripts/dev_tools/test_parallel_drift_scheduling.py | 289 | PASS |
| extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts | 282 | PASS |
| extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts | 265 | PASS |
| .claude/lib/blast-radius/BlastRadiusAccess.psm1 | 242 | PASS |
| tests/scripts/dev_tools/test_blast_radius_access_weights.py | 192 | PASS |
| scripts/dev_tools/_parallel_drift_scheduling.py | 190 | PASS |
| tests/scripts/claude-lib/blast-radius/BlastRadiusAccess.Tests.ps1 | 176 | PASS |
| tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py | 176 | PASS |
| tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py | 159 | PASS |
| tests/scripts/claude-runtime/parallel-scheduling-rule-wording.Tests.ps1 | 145 | PASS |
| .claude/lib/bash/parallel-manifest-pairs.sh | 130 | PASS |
| .claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1 | 128 | PASS |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedenceGate.Tests.ps1 | 117 | PASS |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.PrecedenceGate.Tests.ps1 | 110 | PASS |
| extensions/drm-copilot/test/lib/validate/parallel-state-scheduling-parity.test.ts | 83 | PASS |
| config/blast-radius.json | 83 | PASS |
| tests/scripts/dev_tools/test_parallel_state_scheduling_parity.py | 68 | PASS |
| .claude/lib/parallel-drift/ParallelDriftAccess.psm1 | 53 | PASS |
| tests/scripts/claude-lib/parallel-drift/ParallelDriftAccess.Tests.ps1 | 43 | PASS |

Markdown surfaces (exempt from the size limit): .claude/skills/parallel-orchestrate/SKILL.md 1398, .claude/skills/parallel-plan/SKILL.md 861, .claude/rules/parallel-orchestration.md 854, .claude/agents/parallel-orchestrator.md 379, .claude/skills/parallel-add/SKILL.md 324, .claude/agents/parallel-planner.md 268, .claude/skills/parallel-run/SKILL.md 78. No file is at or above 700 logical lines, so no non-blocking size Warning applies.
