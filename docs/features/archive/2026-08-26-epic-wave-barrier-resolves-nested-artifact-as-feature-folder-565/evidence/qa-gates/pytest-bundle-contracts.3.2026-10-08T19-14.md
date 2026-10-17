# Bundle and Manifest Contract Tests, Final QC Iteration 3

Timestamp: 2026-10-08T19-14
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_codex_core_manifest_closure.py
EXIT_CODE: 0
Output Summary: 32 passed in 0.87s. The Claude and Codex bundle-parity contracts, both pack-manifest completeness tests, and the Codex core-manifest dot-source closure test pass locally with the new shared resolver, its mirrors, and both manifest entries. AC item 30 remains pending the PR CI run, as the plan specifies.

```
============================= 32 passed in 0.87s ==============================
```
