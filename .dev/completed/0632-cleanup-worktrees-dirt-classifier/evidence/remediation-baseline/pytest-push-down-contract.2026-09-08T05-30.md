# Baseline — push-down claude-resource contract tests

Timestamp: 2026-09-08T05-12

Task: [P0-T9] of `remediation-plan.2026-09-08T05-00.md`

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`

EXIT_CODE: 0

Summary line: `11 passed in 0.15s`

Output Summary: All 11 push-down contract tests pass at the pre-change state. This is the
baseline that Phase 8's P8-T9 re-run is compared against: the contract requires every
`.claude/**` file this plan edits to mirror byte-identically into
`extensions/drm-copilot/resources/claude-customizations/.claude/**`, and the count must
remain `11 passed` rather than dropping to a smaller number through a skip.
