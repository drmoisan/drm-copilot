# Integration and Publication Parity Baseline

Timestamp: 2026-09-03T00-50:00-04:00
Command: poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py tests/scripts/dev_tools/test_orchestration_handoff_adapters.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_validate_epic_planner_state.py
EXIT_CODE: 0
Output Summary: All 167 integration/publication parity cases passed. Both TaskMaster plan fixtures remained CRLF-only, 101,998 bytes, and SHA-256 `54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f`. The passing parallel-orchestrator and epic-planner surface cases preserve issue #467 and issue #543 ownership boundaries.

```text
collected 167 items
167 passed in 0.46s
```

Fixture identity:

```text
claude-to-codex: Bytes=101998 SHA256=54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f CRLF=1413 BareLF=0
codex-to-claude: Bytes=101998 SHA256=54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f CRLF=1413 BareLF=0
```
