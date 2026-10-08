# Python batch-budget plan (issue #543)

Timestamp: 2026-10-02T05-18
Timestamp-Correction: original value 2026-10-02T05-01 was a reused reading rather than a clock reading for this artifact; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T07-08.md), an upper bound on the write time.
Task: P0-T5

Cap: 3 production, 3 test (planning-time citation: `.claude/hooks/enforce-python-batch-budget.ps1` lines 9-10).

D1.1 (merge adaptation, hook text): the current hook no longer carries the cap at lines 9-10. Its synopsis (lines 1-40) now states a production-file threshold of three (line 30, "threshold of three production files is a routing constant") and that test files are never counted (lines 26-29, 301); the test-file cap was removed (lines 186, 220-221). The effective cap for this run is therefore 3 production files and no test cap. The plan's single scheduled reset before the fourth production file remains necessary and is kept.

Batch 1 production files:
- `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`
- `scripts/dev_tools/epic_planner_launch_evidence.py`
- `scripts/dev_tools/epic_planner_readiness.py`

Batch 2 production file:
- `scripts/dev_tools/validate_epic_planner_state.py`

Test files (not counted by the current hook):
- `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py`
- `tests/scripts/dev_tools/test_epic_planner_launch_evidence.py`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`

Resets scheduled: 1 (P2-T4)

State at planning of this run: `.claude/state/` does not exist in this worktree (`ls` reported no such directory).

## Reset log

### Reset 1 (P2-T4)

Timestamp: 2026-10-02T05-18
Timestamp-Correction: original value 2026-10-02T05-30 was composed on a fixed schedule rather than read from the host clock; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T07-08.md), an upper bound on the command run time.
Command: `ls .claude/state/python-batch-budget.*.json` (worktree root), then `rm` of each listed file; recount with the same `ls` (D3 substitute for `Get-ChildItem ... | Remove-Item` and the `.Count` recount)
Route: native (D3)
EXIT_CODE: 2 (ls: no such file or directory)

- Files listed before deletion: none. `.claude/state/` does not exist in this worktree, so no production or test file was recorded in any state file here.
- Deleted files: none (nothing to delete).
- Recount immediately after the step: 0 files.
- Observation: the hook's synopsis exempts the orchestrated large path from counting. `artifacts/orchestration/orchestrator-state.json` in this worktree carries `route_id: "large"` and `next_step: "S5_atomic_execution"` (non-terminal), so the three batch-1 production edits (P2-T1 to P2-T3) were not counted and no state file was written. A session-keyed state file exists in the coordinator checkout (outside this worktree); it lists `prodFiles: []` and was not touched, because this run operates only inside its own worktree.
