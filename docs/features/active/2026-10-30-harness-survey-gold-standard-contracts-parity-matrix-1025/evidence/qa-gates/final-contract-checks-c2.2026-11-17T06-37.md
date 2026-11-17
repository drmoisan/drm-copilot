# Final Contract Checks — Remediation Cycle 2 (Issue 1025, [P2-T3])

Timestamp: 2026-11-17T06-34
Runner: `sh SCRATCH/issue-1025-contracts.sh c2f3` (from the worktree root, inside `sh SCRATCH/issue-1025-c2-phasegate.sh c2f3`; the pytest step re-runs only on exit 75)

## 1. Python contract set (plan A `## Gate Shape`)

Command: `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_codex_full_migration_inventory.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py --junitxml=SCRATCH/issue-1025-c2f3-contracts.xml`
EXIT_CODE: 0
Output Summary: 92 passed in 4.43s, 0 failed (attempt 1, no queue timeout). Baseline `cycle-2-contract-checks.2026-11-17T05-04.md`: 92 passed; the pass count is not below the baseline.

## 2. Codex generator check

Command: `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`
EXIT_CODE: 0
Output Summary: ok (exit 0, no drift reported; empty output). Baseline: exit 0.

## 3. Tier check

Command: `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.check_quality_tiers`
EXIT_CODE: 0
Output Summary: `quality-tiers: OK (36 entries, 36 discovered projects)`. Baseline: same.

Acceptance: each command exits 0; the pass count (92) is not below the newest `cycle-2-contract-checks.*.md` (92). PASS.
