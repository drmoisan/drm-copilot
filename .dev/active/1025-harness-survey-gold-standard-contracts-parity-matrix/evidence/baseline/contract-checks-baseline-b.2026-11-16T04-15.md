# Contract-Check Baseline, Plan B (P0-T4)

Timestamp: 2026-11-16T04-15
Command: sh SCRATCH/issue-1025-contracts.sh b0 (three commands below)
EXIT_CODE: 0
Output Summary: Python contract set 92 passed, 0 failed (pytest exit 0); generator --check exit 0 with no output; tier check exit 0 printing `quality-tiers: OK (36 entries, 36 discovered projects)` and no line beginning QT0.

## Python contract set

Timestamp: 2026-11-16T04-15
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_codex_full_migration_inventory.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py --junitxml=SCRATCH/issue-1025-b0-contracts.xml
EXIT_CODE: 0
Output Summary: 92 passed in 2.98s.

- test_codex_full_migration_inventory: passed 3, failed 0
- test_push_down_codex_and_agents_pack_manifest_completeness: passed 2, failed 0
- test_push_down_codex_and_agents_resource_contracts: passed 9, failed 0
- test_push_down_issue_824_follow_ups: passed 62, failed 0
- test_quality_tiers_contract_classification: passed 16, failed 0

## Generator check

Timestamp: 2026-11-16T04-15
Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check
EXIT_CODE: 0
Output Summary: no output; generated variants, bundle copies and the Codex core.json are current.

## Tier check

Timestamp: 2026-11-16T04-15
Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.check_quality_tiers
EXIT_CODE: 0
Output Summary: quality-tiers: OK (36 entries, 36 discovered projects); no line beginning QT0.

quality-tiers: OK (36 entries, 36 discovered projects)
TierEntries: 36
TierProjects: 36
