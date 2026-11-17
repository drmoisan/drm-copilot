# Final Contract Checks (P4-T4)

Timestamp: 2026-11-16T03-41
Command: sh SCRATCH/issue-1025-contracts.sh p4 (the three commands below)
EXIT_CODE: 0
Output Summary: Python contract set 92 passed, 0 failed per module; generator exit 0; tier check exit 0 with no line beginning QT0 and `quality-tiers: OK (36 entries, 36 discovered projects)`: 36 entries is one greater than TierEntries 35 in contract-checks-baseline.2026-11-16T01-18.md.

## Python contract set

Timestamp: 2026-11-16T03-40
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_codex_full_migration_inventory.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py --junitxml=SCRATCH/issue-1025-p4-contracts.xml
EXIT_CODE: 0
Output Summary: 92 passed in 3.45s.

- test_codex_full_migration_inventory: passed 3, failed 0
- test_push_down_codex_and_agents_pack_manifest_completeness: passed 2, failed 0
- test_push_down_codex_and_agents_resource_contracts: passed 9, failed 0 (bundle copies of the 65 contracts are byte-identical)
- test_push_down_issue_824_follow_ups: passed 62, failed 0
- test_quality_tiers_contract_classification: passed 16, failed 0

## Generator check

Timestamp: 2026-11-16T03-41
Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
EXIT_CODE: 0
Output Summary: no output; exit 0.

## Tier check

Timestamp: 2026-11-16T03-41
Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.check_quality_tiers
EXIT_CODE: 0
Output Summary: quality-tiers: OK (36 entries, 36 discovered projects); no line beginning QT0.
