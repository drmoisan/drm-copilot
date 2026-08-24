# Baseline — `.agents/**` Bundled Parity Test (Issue #422)

Timestamp: 2026-07-26T00-50

Command:
```
poetry run pytest "tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts"
```

EXIT_CODE: 0

Output Summary:

- Collected: 1 item
- Passed: 1
- Failed: 0
- Duration: 0.11s
- Verbatim result line: `1 passed in 0.11s`
- Baseline result: PASS, as expected. Repo-root `.agents/**` runtime contracts are currently content-identical to their bundled copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/`. This baseline establishes that any parity failure observed after Phase 2 would be caused by an unmirrored edit, not by pre-existing drift.
