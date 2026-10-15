# Baseline Issue-#510 Claude Bundle Parity Node

Timestamp: 2026-10-02T01-22
Timestamp-Correction: original value 2026-10-02T01-17 was a Phase 0 start reading reused through Phase 4; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T02-02.md), an upper bound on the command run time.
Command: poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts" -q
EXIT_CODE: 0
Output Summary:
- Result line: `1 passed in 0.12s`
- The node passed locally in this worktree (no gitignored `.claude/state/` drift present), so no failure classification applies and no `ExpectedExitCode` is declared.
