# Remediation Cycle 1 Coverage Delta Verification (P7-T1)

Timestamp: 2026-10-16T04-24
Command: read evidence/remediation-baseline/rc1-baseline-python-per-file-coverage.2026-10-16T03-47.md (P0-T12), evidence/remediation-baseline/rc1-baseline-python-repo-wide-coverage.2026-10-16T03-49.md (P0-T14), evidence/remediation-baseline/rc1-baseline-typescript-lcov-coverage.2026-10-16T03-51.md (P0-T20), evidence/qa-gates/rc1-final-python-per-file-coverage.2026-10-16T04-13.md (P5-T6), evidence/qa-gates/python-repo-wide-coverage.2026-10-16T04-18.md (P5-T9), evidence/qa-gates/typescript-lcov-coverage.2026-10-16T04-22.md (P6-T6)
EXIT_CODE: 0
Output Summary:

Python (source artifact artifacts/python/lcov.info)

| File | Baseline line / branch | Post-change line / branch | Line delta | Branch delta | Uncovered added lines |
|---|---|---|---|---|---|
| scripts/dev_tools/validate_epic_planner_state.py | 92.55 / 86.00 | 94.24 / 88.00 | +1.69 | +2.00 | 0 |
| scripts/dev_tools/epic_planner_git_integrity.py | 98.50 / 97.44 | 99.34 / 98.84 | +0.84 | +1.40 | 0 |
| scripts/dev_tools/_epic_orchestrator_state_launch_binding.py | 97.48 / 94.64 | 98.32 / 96.43 | +0.84 | +1.79 | 0 |
| Repository-wide (scripts.dev_tools, FILES=214) | 93.82 / 88.14 | 93.86 / 88.21 | +0.04 | +0.07 | n/a |

TypeScript (source artifact extensions/drm-copilot/coverage/lcov.info)

| File | Baseline line / branch | Post-change line / branch | Line delta | Branch delta | Uncovered added lines |
|---|---|---|---|---|---|
| src/lib/validate/epic-planner-state-core.ts | 98.36 / 94.07 | 98.38 / 94.12 | +0.02 | +0.05 | 0 |
| src/lib/validate/epic-orchestrator-state-launch-binding.ts | 96.11 / 93.28 | 96.75 / 94.17 | +0.64 | +0.89 | 0 |
| src/lib/validate/epic-planner-git-integrity.ts | 100.00 / 93.98 | 100.00 / 96.84 | 0.00 | +2.86 | 0 |
| Repository-wide (FILES=212) | 97.27 / 92.29 | 97.28 / 92.34 | +0.01 | +0.05 | n/a |

Changed-code coverage: 0 added executable lines appear in any zero-hit list (P5-T6 validator 0 and git integrity 0; P5-T9 launch binding 0; P6-T6 core 0, launch binding 0, git integrity 0 with an empty zero-hit list).

Requirements:
- All six production files at or above 85.00 line and 75.00 branch: met.
- TypeScript repository-wide at or above 85.00 / 75.00: met (97.28 / 92.34).
- No per-file post-change percentage lower than baseline by more than 0.50 points: met (every delta is zero or positive).
- Zero added executable lines uncovered: met.

CR-5 paths exercised in both runtimes:
- Non-object entry preceding objects at the ready gate: the four parametrized cases (string, null, number, list).
- Codex flag with a preceding non-object entry: receipts (model_routing_receipt, topology_receipt) and launch binding.
- Dependency-wave uniqueness, resolution, and wave loops after a non-object entry (one state exercising all three).
- Git-integrity pairing after a non-object entry and after a plan-less entry.
- Git-integrity positional fallback: with entries (no entry carries the plan), with no entries (empty list), and with a non-list value.
- No skipped entry: the preservation tests in both pairs.

Verdict: PASS. No numeric value is missing.
