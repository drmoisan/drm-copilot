# Final Python per-file coverage (issue #543)

Timestamp: 2026-10-02T06-25
Task: P8-T6
Loop iteration: 1
Command: `poetry run coverage json --data-file=artifacts/.coverage --include="*validate_epic_planner_state.py,*_epic_orchestrator_state_launch_binding.py,*epic_planner_launch_evidence.py,*epic_planner_readiness.py" --pretty-print -o artifacts/python/coverage-543-final.json` (immediately after P8-T5), then the JSON read over `files[<key>].summary`
EXIT_CODE: 0

Output Summary (`files[<key>].summary`):

| File | covered_lines/num_statements | Line % | covered_branches/num_branches | Branch % | Floors |
|---|---|---|---|---|---|
| `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` | 116/119 | 97.48 | 53/56 | 94.64 | met |
| `scripts/dev_tools/epic_planner_launch_evidence.py` | 180/195 | 92.31 | 82/92 | 89.13 | met |
| `scripts/dev_tools/epic_planner_readiness.py` | 178/191 | 93.19 | 71/92 | 77.17 | met |
| `scripts/dev_tools/validate_epic_planner_state.py` | 166/181 | 91.71 | 79/94 | 84.04 | met |

- Every file is at or above 85.00% line and 75.00% branch coverage; no added tests or loop restart are required.
- `scripts/dev_tools/epic_planner_readiness.py` rose from the baseline 64/92 (69.57%) to 71/92 (77.17%) through the P4-T11 tests; the denominator stayed 92 as the plan projected.
- `missing_lines` (used by P10-T1):
  - `_epic_orchestrator_state_launch_binding.py`: [188, 227, 296]
  - `epic_planner_launch_evidence.py`: [55, 58, 73, 74, 81, 82, 125, 126, 130, 154, 162, 169, 175, 211, 294]
  - `epic_planner_readiness.py`: [106, 108, 125, 126, 173, 178, 214, 215, 219, 227, 230, 231, 250]
  - `validate_epic_planner_state.py`: [121, 127, 143, 144, 149, 150, 152, 154, 156, 189, 227, 236, 238, 255, 324]
