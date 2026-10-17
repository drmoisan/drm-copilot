# P8-T4 PARITY-SET Run

Timestamp: 2026-10-10T00-01
Command: poetry run pytest "tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_codex_legacy_variant_files_contain_corrected_gate_commands" "tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest"; poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py
EXIT_CODE: 0
Output Summary:
- Command 1 (node run): EXIT 0; "2 passed" (variant pins and manifest completeness including the new helper).
- Command 2 (PARITY-SET): EXIT 0; "108 passed"; no failed. KL-510 not observed (no adjustment).
- Threshold: BASE_PARITY_PASSED 107 + 1 (note B test) - 0 (KL-510) = 108. Observed 108 >= 108. Met.
- The pytest "rootdir:" header line is not recorded (absolute host path).
- Result: PASS
