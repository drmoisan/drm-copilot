# Acceptance Criteria Status (P6-T10)

Timestamp: 2026-11-10T02-10
Command: grep -n "US-AC" user-story.md; grep -n "Acceptance Criteria" spec.md (read against the final gate artifacts under evidence/qa-gates/)
EXIT_CODE: 0
Output Summary:
- Work Mode full-feature: AC sources are user-story.md (checkbox-backed, US-AC1 to US-AC13) and spec.md (no checkbox AC section; its `## Acceptance Criteria Traceability` table maps issue AC1-AC6 to US-AC1-US-AC13, so it carries no separate check-off).
- Checked in this task: US-AC7, after the P6-T8 CI run 42737591848 proved the bash validator over the shared M9 corpus (tests/shell/parallel_manifest_parity.bats ok 154-156; shell-coverage success). Its Python half passed in pytest-gate.2026-11-10T01-35.md (parallel_manifest_contract.py corpus tests, NAMED_NOT_ALL_PASSED 0) and its parallel-scheduling.json emission cases passed in pester-gate.2026-11-10T01-17.md.
- US-AC13 stays unchecked: it is satisfied by the PR body, which is written at PR authoring (pending PR authoring).

## Per-Criterion Evidence

| AC | Status | Gate evidence |
|---|---|---|
| US-AC1 | checked (earlier task) | pester-gate.2026-11-10T01-17.md: parallel-scheduling-rule-wording.Tests.ps1 228 cases, 0 failed |
| US-AC2 | checked (earlier task) | pester-gate.2026-11-10T01-17.md (wording cases for parallel-orchestrate and mirror); pytest-gate.2026-11-10T01-35.md (surface contract tests) |
| US-AC3 | checked (earlier task) | pytest-gate.2026-11-10T01-35.md (test_blast_radius_config_parity.py, test_blast_radius_config_tolerance_keys.py); pester-gate.2026-11-10T01-17.md |
| US-AC4 | checked (earlier task) | pester-gate.2026-11-10T01-17.md and pytest-gate.2026-11-10T01-35.md (scheduling-1164 fixture stems) |
| US-AC5 | checked (earlier task) | pester-gate.2026-11-10T01-17.md (BlastRadiusAccess, ParallelDriftAccess, access-paths cases); pytest-gate.2026-11-10T01-35.md (drift parity) |
| US-AC6 | checked (earlier task) | pytest-gate.2026-11-10T01-35.md (test_parallel_state_scheduling_parity.py, 22 cases); jest-gate.2026-11-10T01-35.md (parallel-state-scheduling-parity.test.ts) |
| US-AC7 | checked (this task) | shell-ci.2026-11-10T02-07.md; pytest-gate.2026-11-10T01-35.md; pester-gate.2026-11-10T01-17.md |
| US-AC8 | checked (earlier task) | pytest-gate.2026-11-10T01-35.md and jest-gate.2026-11-10T01-35.md (accept-without-fields corpus case); pester-gate.2026-11-10T01-17.md (seed-scheduling-record fixture) |
| US-AC9 | checked (earlier task) | pester-gate.2026-11-10T01-17.md (ParallelAdmissionPrecedenceGate.Tests.ps1, Invoke-ParallelAdmission.PrecedenceGate.Tests.ps1) |
| US-AC10 | checked (earlier task) | pester-gate.2026-11-10T01-17.md; agent tools: lines unchanged in the merge-base diff |
| US-AC11 | checked (earlier task) | pytest-gate.2026-11-10T01-35.md (test_push_down_claude_overlay_parity.py); jest-gate.2026-11-10T01-35.md (claude-blast-radius-overlay-parity.test.ts) |
| US-AC12 | checked (earlier task) | pytest-gate.2026-11-10T01-35.md (resource, pack-manifest completeness, dependency-closure, config-parity contract tests) |
| US-AC13 | unchecked, pending PR authoring | PR body not yet written |

### Acceptance Criteria Status
- Source: docs/features/active/parallel-planner-time-based-edge-rule-1164/user-story.md; docs/features/active/parallel-planner-time-based-edge-rule-1164/spec.md
- Total AC items: 13 (user-story.md); spec.md carries 0 checkbox AC items (traceability table only)
- Checked off (delivered): 12
- Remaining (unchecked): 1
- Items remaining: US-AC13 (issue AC6; spec B3, B10.4, rollout): the PR body states that the default scheduling behaviour changes as directed by the owner (OD-1164-1), and that the new validator rules apply through MCP only after the next extension release. Pending PR authoring.
