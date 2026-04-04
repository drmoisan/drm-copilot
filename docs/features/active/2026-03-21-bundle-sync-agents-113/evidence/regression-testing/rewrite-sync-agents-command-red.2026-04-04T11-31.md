# Rewrite Sync-Agents Command — Red Phase Evidence

Timestamp: 2026-04-04T11-31
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k test_sync_agents_script_reference_rewrites_to_live_command
EXIT_CODE: 1

## Output Summary

1 failed — `test_sync_agents_script_reference_rewrites_to_live_command`

Failure reason: `rewritten_reference_count` was 0 instead of 1.
The reference `scripts/dev_tools/sync-agents-from-instructions.ps1` appeared in
`unmatched_references`, confirming the rewrite catalog does not yet contain an
entry for the sync-agents script.

The test was written before the rewrite rule to satisfy the TDD red-phase
requirement. It will be made green in [P5-T2] by adding the catalog entry.
