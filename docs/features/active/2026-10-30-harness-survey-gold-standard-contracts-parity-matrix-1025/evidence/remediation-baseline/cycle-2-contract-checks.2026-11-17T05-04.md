# Remediation Baseline — Cycle 2 Contract Checks (Issue 1025)

Timestamp: 2026-11-17T05-03
Plan task: [P0-T3] of `remediation-plan.2026-11-16T06-14.md`
Runner: `sh SCRATCH/issue-1025-c2-contracts.sh c2p0` (runs `SCRATCH/issue-1025-contracts.sh` from the worktree root; the pytest step re-runs only on exit 75)

## 1. Python contract set (plan A `## Gate Shape`)

Command: `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_codex_full_migration_inventory.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py --junitxml=SCRATCH/issue-1025-c2p0-contracts.xml`
EXIT_CODE: 0
Output Summary: 92 passed in 4.29s; 0 failed; attempt 1 (no queue timeout).

## 2. Codex generator check

Command: `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`
EXIT_CODE: 0
Output Summary: ok (exit 0, no drift reported; empty output).

## 3. Tier check

Command: `env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.check_quality_tiers`
EXIT_CODE: 0
Output Summary: `quality-tiers: OK (36 entries, 36 discovered projects)`.

Acceptance: each block holds its pass count or ok result. PASS.
