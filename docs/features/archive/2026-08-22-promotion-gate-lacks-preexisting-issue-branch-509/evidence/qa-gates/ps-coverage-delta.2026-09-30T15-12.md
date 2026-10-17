# PowerShell Coverage Comparison (P8-T16)

Timestamp: 2026-09-30T15-12
Task: [P8-T16]
Scope: `.claude/lib/orchestrator-state/`
Inputs: baseline `evidence/baseline/ps-test-coverage.2026-09-30T14-08.md` (P0-T19); post-change `evidence/qa-gates/ps-test-coverage.2026-09-30T15-08.md` (P8-T13). No command ran in this task.
Source used by both runs: B (P0-T19: Source B, run 36725543249; P8-T13: Source B, run 36732800820). The sources match, so `BLOCKED: MIXED POWERSHELL SOURCES` does not apply.

## Output Summary

| Figure | Baseline (P0-T19) | Post-change (P8-T13) | Difference |
| --- | --- | --- | --- |
| `OrchestratorStateRoutingContract.psm1` line coverage | 106 / 107 = 99.07% | 110 / 111 = 99.10% | +0.03 pp |
| `OrchestratorStateRoutingContract.psm1` changed-line coverage | n/a (no changed lines at baseline) | 4 / 4 = 100.0% (instrumented added lines 61, 418, 420, 425) | n/a |
| `OrchestratorStateIssueAdoption.psm1` line coverage (new code) | n/a (file did not exist) | 112 / 112 = 100.0% | n/a |

Gate evaluation:
- Routing value did not decrease: yes (0.99099 >= 0.99065; both round to the recorded `PS_ROUTING_BASELINE_LINE` of 99.1%).
- Changed-line floor 85.0: holds (100.0).
- New-code floor 85.0: holds (100.0).
- Pester measures no branch coverage, so no branch figure is recorded.

Result: PASS.
