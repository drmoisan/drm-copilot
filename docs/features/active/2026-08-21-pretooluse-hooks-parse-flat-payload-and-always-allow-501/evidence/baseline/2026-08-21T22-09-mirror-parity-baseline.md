# Baseline — Mirror Parity (push-down bundle) (#501)

Timestamp: 2026-08-21T22-09

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k test_bundled_claude_payload_contains_all_repo_runtime_contracts`

EXIT_CODE: 0

Task: [P0-T5]

Output Summary: `1 passed, 9 deselected in 0.09s` (pytest 9.0.2, Python 3.13.12, win32). The named test `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes at baseline, confirming byte parity between every `.claude/**` file at the repository root and its counterpart under `extensions/drm-copilot/resources/claude-customizations/.claude/` before any migration edits. This is the gate that will enforce the mirror rule for every hook and module file changed by this plan.
