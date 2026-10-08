# Scope Boundary (P7-T1, AC18)

Timestamp: 2026-09-29T17-58
Command: git diff --name-only origin/epic/push-down-payload-correctness-integration...HEAD
EXIT_CODE: 0
Command: git status --porcelain --untracked-files=all
EXIT_CODE: 0

Output Summary:
- Committed listing: 42 paths (below). Porcelain status: empty (no uncommitted or untracked paths).
- No path under `extensions/drm-copilot/src/`; the only `extensions/` path is the Jest test file.
- No path under `.claude/hooks/`; no path containing `enforce-powershell-batch-budget`.
- None of scripts/dev_tools/skill_bundle_contract.py, scripts/dev_tools/push_down_copilot_customizations.py, scripts/dev_tools/push_down_claude_filesystem.py, tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py appears.
- Every path is in the Execution Conventions change set (6 production, 10 new test paths, 1 changed test, README.md), the feature folder evidence, spec.md, or the plan file.

Committed listing:
README.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/coverage-baseline.json
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/git-anchor.2026-09-29T17-28.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/line-counts.2026-09-29T17-28.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/npm-ci.2026-09-29T17-28.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/phase0-instructions-read.2026-09-29T17-28.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/python-black-check.2026-09-29T17-28.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/python-coverage-baseline.2026-09-29T17-28.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/python-pyright.2026-09-29T17-28.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/python-pytest-full.2026-09-29T17-28.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/python-ruff-check.2026-09-29T17-28.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/ts-eslint.2026-09-29T17-28.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/ts-jest-coverage.2026-09-29T17-28.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/ts-prettier-check.2026-09-29T17-28.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/ts-typecheck-src.2026-09-29T17-28.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/baseline/ts-typecheck-tests.2026-09-29T17-28.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/other/cli-help-stale-text-absent.2026-09-29T17-54.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/regression-testing/ac1-root-folders-fail-before.2026-09-29T17-28.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/regression-testing/ac1-root-folders-pass-after.2026-09-29T17-54.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/regression-testing/ac17-push-down-claude-suite.2026-09-29T17-54.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/regression-testing/jest-routing-merge-parity.2026-09-29T17-57.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/regression-testing/parity-fail-before.2026-09-29T17-28.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/evidence/regression-testing/parity-pass-after.2026-09-29T17-54.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/plan.2026-09-29T14-13.md
docs/features/active/2026-08-22-push-down-root-folders-divergence-507/spec.md
extensions/drm-copilot/test/lib/push-down/claude-routing-merge-parity.test.ts
scripts/dev_tools/push_down_claude_blast_radius_derive.py
scripts/dev_tools/push_down_claude_blast_radius_derive_core.py
scripts/dev_tools/push_down_claude_blast_radius_derive_manifests.py
scripts/dev_tools/push_down_claude_customizations.py
scripts/dev_tools/push_down_claude_destination_writes.py
scripts/dev_tools/push_down_claude_routing_merge.py
tests/fixtures/push_down/routing-merge-parity.json
tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive.py
tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive_core.py
tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive_core_guard.py
tests/scripts/dev_tools/test_push_down_claude_blast_radius_derive_manifests.py
tests/scripts/dev_tools/test_push_down_claude_config_carriage.py
tests/scripts/dev_tools/test_push_down_claude_customizations.py
tests/scripts/dev_tools/test_push_down_claude_destination_writes.py
tests/scripts/dev_tools/test_push_down_claude_parity.py
tests/scripts/dev_tools/test_push_down_claude_routing_merge.py
