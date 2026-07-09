# Baseline — Parity Gates (pre-change reference) (#331)

Timestamp: 2026-07-07T21-08

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
EXIT_CODE: 0
Output Summary: Pass. 7 passed. Every .claude/** runtime file byte-identical in the bundle mirror at baseline.

Command: npm run test -- claude-pack-manifest-completeness (from extensions/drm-copilot)
EXIT_CODE: 0
Output Summary: Pass. 7 passed (1 suite). Every bundled .claude agent/skill/hook appears in a pack-manifests/*.json paths[] at baseline.
