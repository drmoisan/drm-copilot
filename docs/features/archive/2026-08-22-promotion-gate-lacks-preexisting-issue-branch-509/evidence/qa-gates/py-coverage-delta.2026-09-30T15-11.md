# Python Coverage Comparison (P8-T15)

Timestamp: 2026-09-30T15-11
Task: [P8-T15]
Scope: `scripts/dev_tools/`
Inputs: baseline `evidence/baseline/py-routing-coverage.2026-09-30T13-52.md` (P0-T15) and `evidence/baseline/py-pytest-coverage.2026-09-30T13-54.md` (P0-T16); post-change `evidence/qa-gates/py-module-coverage.2026-09-30T14-50.md` (P8-T8) and `evidence/qa-gates/py-pytest-coverage.2026-09-30T14-51.md` (P8-T9). No command ran in this task (the arithmetic below was computed with `awk`).

## Output Summary

Repository-wide (`--cov=scripts.dev_tools`, JSON `totals`):

| Metric | Baseline (P0-T16) | Post-change (P8-T9) | Difference |
| --- | --- | --- | --- |
| Line | 15847 / 16974 = 93.36% | 15974 / 17101 = 93.41% | +0.05 pp |
| Branch | 5275 / 6110 = 86.33% | 5323 / 6158 = 86.44% | +0.11 pp |

Routing code (pre-split `_orchestrator_state_routing.py` against the three post-split modules combined):

| Metric | Baseline (P0-T15, pre-split module) | Post-change (P8-T8, three modules combined) | Difference |
| --- | --- | --- | --- |
| Line | 193 / 219 = 88.1% | (116 + 90 + 10) / (125 + 98 + 10) = 216 / 233 = 92.7% | +4.6 pp |
| Branch | 85 / 112 = 75.9% | (58 + 36 + 2) / (68 + 44 + 2) = 96 / 114 = 84.2% | +8.3 pp |

Post-change per-module figures (P8-T8 JSON `summary` objects):

| Module | Line | Branch |
| --- | --- | --- |
| `_orchestrator_state_routing.py` | 92.8 | 85.3 |
| `_orchestrator_state_route_gates.py` | 91.8 | 81.8 |
| `_orchestrator_state_promotion_tools.py` | 100.0 | 100.0 |

New-code figures (`_orchestrator_state_issue_adoption.py`, new file, no baseline): line 113 / 113 = 100.0%, branch 46 / 46 = 100.0%.

Gate evaluation:
- Repository-wide line and branch values do not decrease: yes (+0.05 pp and +0.11 pp).
- Every module meets 85.0 line and 75.0 branch: yes (lowest line 91.8, lowest branch 81.8).

Result: PASS.
