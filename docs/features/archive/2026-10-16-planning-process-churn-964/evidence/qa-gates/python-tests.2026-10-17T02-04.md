# QA Gate — Python Tests with Coverage (final pass, merged tree)

Timestamp: 2026-10-17T01-45
Task: [P6-T2]
Command: poetry run pytest tests -q -p no:cacheprovider --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-964-qa.json
EXIT_CODE: 0
Output Summary:
- 7325 passed, 6 skipped, 0 failed (67.81 s); the count includes the suites merged from `origin/main`.
- Total (JSON report): line 94.11%, branch 88.78% (baseline [P0-T4]: 94.04% / 88.65%; no regression).
- `scripts.dev_tools.plan_gate_document` (new): line 100.00%, branch 100.00%.
- `scripts.dev_tools.plan_gate_discrimination`: line 99.26%, branch 98.08% (baseline 99.25% / 98.08%).
- `scripts/dev_tools/generate_codex_agent_variants.py`: line 94.53%, branch 89.13% (baseline 90.62% / 82.61%).
- `scripts/dev_tools/codex_native_converter/rewrites.py`: line 91.30%, branch 85.71% (unchanged).
