# Baseline — `.claude/**` Bundled Parity Test (Issue #422)

Timestamp: 2026-07-26T00-50

Command:
```
poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"
```

EXIT_CODE: 0

Output Summary:

- Collected: 1 item
- Passed: 1
- Failed: 0
- Duration: 0.07s
- Verbatim result line: `1 passed in 0.07s`
- Baseline result: PASS, as expected. Repo-root `.claude/**` runtime contracts are currently content-identical to their bundled copies under `extensions/drm-copilot/resources/claude-customizations/`. This baseline establishes that any parity failure observed after Phase 2 would be caused by an unmirrored edit, not by pre-existing drift.
