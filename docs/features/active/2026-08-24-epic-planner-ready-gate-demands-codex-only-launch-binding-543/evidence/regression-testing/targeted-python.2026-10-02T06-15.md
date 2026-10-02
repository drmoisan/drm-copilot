# Targeted Python run (issue #543)

Timestamp: 2026-10-02T06-15
Task: P7-T1
Command: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py tests/scripts/dev_tools/test_epic_planner_launch_evidence.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py --cov=scripts.dev_tools.validate_epic_planner_state --cov=scripts.dev_tools._epic_orchestrator_state_launch_binding --cov=scripts.dev_tools.epic_planner_launch_evidence --cov=scripts.dev_tools.epic_planner_readiness --cov-branch --cov-report=term-missing`
Unedited-file checks: `git diff ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd --stat -- tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_epic_planner_readiness.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py` and `git status --porcelain -- <same three paths>`
Route: native (D2, D3) for the anchored diff
EXIT_CODE: 0

Output Summary:
- Result line: `118 passed in 0.82s` (0 failed).
- term-missing rows (subset run; per-file values for the gate come from the full-suite run in P8-T5/P8-T6):
  - `scripts\dev_tools\_epic_orchestrator_state_launch_binding.py     119      3     56      3    97%   188, 227, 296`
  - `scripts\dev_tools\epic_planner_launch_evidence.py                195     15     92     10    91%   55, 58, 73-74, 81-82, 125-126, 130, 154, 162, 169, 175, 211, 294`
  - `scripts\dev_tools\epic_planner_readiness.py                      191     18     92     19    86%   33->exit, 35->exit, 37->exit, 39->exit, 41->exit, 50, 55, 60, 65, 70, 106, 108, 125-126, 173, 178, 214-219, 227, 230-231, 232->225, 250, 261->274, 263->262, 337->341, 344->348, 360->353, 377->383`
  - `scripts\dev_tools\validate_epic_planner_state.py                 181     15     94     15    89%   121, 127, 143-144, 149-150, 152, 154, 156, 169->173, 189, 211->209, 227, 236, 238, 255, 324`
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py`, `tests/scripts/dev_tools/test_epic_planner_readiness.py`, and `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py` were not edited: the anchored `git diff --stat` printed nothing and `git status --porcelain` printed nothing.
- The unchanged launch-binding tests named in AC14 (`test_rejects_invalid_branch_or_launch_path`, `test_rejects_invalid_delegation_binding`, `test_rejects_invalid_model_receipt_binding`, `test_requires_unique_branch_and_delegation_identifiers`, `test_complete_launch_evidence_reaches_repository_context_gate`) are included in this run and passed (see P4-T6 evidence for the per-node listing).
