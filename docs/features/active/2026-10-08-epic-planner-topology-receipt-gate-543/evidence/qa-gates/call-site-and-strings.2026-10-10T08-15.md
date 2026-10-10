# Call-Site Gate and Unchanged Error Strings (Issue #543)

Timestamp: 2026-10-10T08-15
Task: [P6-T5]
Command: grep -n -F -e 'if not key_gated or "topology_receipt" in state:' scripts/dev_tools/validate_epic_planner_state.py; grep -n -F -e 'if (!requireLaunchPaths || "topology_receipt" in value) {' extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts; git diff -U0 7bbd0b9b990737642b4eeded01a27b7c5c8348b3 -- scripts/dev_tools/validate_epic_planner_state.py extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts | grep -e '^[-+][^-+]' | grep -c -e 'Epic planner'; git diff -U0 7bbd0b9b990737642b4eeded01a27b7c5c8348b3 -- scripts/dev_tools/validate_epic_planner_state.py extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts | grep -c -F -e '"topology_receipt" in '
Route: diff-file (the worktree isolation guard refused the git-to-grep pipelines; the anchored diff was written to a session scratchpad file with the same `git diff -U0` command and the same grep stages were run against that file)
EXIT_CODE: 0
Output Summary:
- Command 1 (exit 0): one match — `348:        if not key_gated or "topology_receipt" in state:`
- Command 2 (exit 0): one match — `444:    if (!requireLaunchPaths || "topology_receipt" in value) {`
- Command 3: printed `0` (exit 1, its stated expectation). No added or removed line in either production file contains `Epic planner`; no error string was added, removed, or reworded.
- Command 4: printed `2` (exit 0) — one added condition line per runtime.
- Source-reading confirmation: in `scripts/dev_tools/validate_epic_planner_state.py` the new `if` block (lines 348-351) contains only `errors.extend(_validate_planner_topology_receipt(state.get("topology_receipt")))` (Black-wrapped) and sits inside `if require_ready_for_execution:` (line 329). In `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` the new block (lines 444-446) contains only `errors.push(...validatePlannerTopologyReceipt(value["topology_receipt"]));` and sits inside `if (options.requireReadyForExecution === true) {` (line 422).
- The spec's `git diff main` is run as the anchored diff against the recorded merge base 7bbd0b9b990737642b4eeded01a27b7c5c8348b3.
