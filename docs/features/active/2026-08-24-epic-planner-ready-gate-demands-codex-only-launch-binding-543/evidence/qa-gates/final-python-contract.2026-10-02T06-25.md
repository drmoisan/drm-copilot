# Final Python contract / schema compatibility (issue #543)

Timestamp: 2026-10-02T05-39
Timestamp-Correction: original value 2026-10-02T06-25 was composed on a fixed schedule rather than read from the host clock; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T05-58.md), an upper bound on the command run time.
Task: P8-T7
Loop iteration: 1
Command: `git diff ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd --stat -- scripts/dev_tools/validate_orchestration_artifacts.py` and `git status --porcelain -- scripts/dev_tools/validate_orchestration_artifacts.py`
Route: native (D2, D3) for the anchored diff (literal merge-base SHA in place of `(git merge-base origin/main HEAD)`)
EXIT_CODE: 0

Output Summary:
- Both commands printed nothing: the Python CLI surface (the `epic-planner-state` subparser and its dispatch) is unchanged.
- Every new Python parameter is keyword-only with a default equal to the pre-fix behaviour:
  - `validate_epic_planner_child_launch_bindings(features, *, require_launch_paths=False)` (False validates every feature, as before)
  - `validate_epic_planner_launch_evidence(state, context, *, require_launch_paths=False)`
  - `validate_epic_readiness_integrity(state, state_text, context, *, require_launch_paths=False)`
  - `validate_epic_planner_state_text(text, *, ..., require_codex_model_routing=False, require_codex_topology=False)`; only the ready gate itself applies the key gate when neither flag is set, which is the intended behaviour change.
- `feature_carries_launch_path` replaces the private `_carries_launch_path` with the same key-membership body; its only caller was updated.
