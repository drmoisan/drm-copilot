# P0-T10 Baseline Sizes and Counts

Timestamp: 2026-10-09T22-43
Command: wc -l .claude/hooks/validate-feature-review-coverage.ps1 tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py .codex/codex-web-setup.sh; poetry run python -c "import json; d=json.load(open('extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json', encoding='utf-8')); print('PATHS', len(d['paths']))"; grep -c -F "hook-command-raw-invocation" extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json; poetry run pytest tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py --collect-only -q
EXIT_CODE: 0
Output Summary:
- wc -l: EXIT 0; 459 / 463 / 384
  - BASE_HOOK_LINES: 459 (matches RESEARCH_BASE)
  - BASE_TIER_LINES: 463 (matches RESEARCH_BASE)
  - BASE_SETUP_LINES: 384 (matches RESEARCH_BASE)
  - Each is at most 500
- Manifest reader: EXIT 0; "PATHS 202" -> BASE_MANIFEST_PATHS: 202
- Raw-invocation grep: printed 0 (EXIT 1, grep's no-match exit) -> BASE_RAW_ENTRY: 0
- Collection run: EXIT 0; "80 tests collected in 0.06s" -> BASE_TIER_COUNT: 80
- Result: PASS
