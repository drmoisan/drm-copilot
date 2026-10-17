# QA Gate — Python Tests with Coverage

Timestamp: 2026-10-17T00-44
Task: [P6-T2]
Command: poetry run pytest tests -q -p no:cacheprovider --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-964-qa.json
EXIT_CODE: 0
Output Summary:
- 7307 passed, 6 skipped, 0 failed (67.93 s).
- Total (JSON report): line 94.11%, branch 88.78% (baseline [P0-T4]: line 94.04%, branch 88.65%; no regression).
- `scripts.dev_tools.plan_gate_document` (new): line 100.00%, branch 100.00%.
- `scripts.dev_tools.plan_gate_discrimination`: line 99.26%, branch 98.08% (baseline 99.25% / 98.08%; no regression).
- Related-finding modules: `scripts/dev_tools/generate_codex_agent_variants.py` line 94.53%, branch 89.13% (baseline 90.62% / 82.61%); `scripts/dev_tools/codex_native_converter/rewrites.py` line 91.30%, branch 85.71% (unchanged; the edit is a string constant).
- The first pass of this task at 2026-10-17T00-41 failed one test, `test_every_skill_script_reference_is_bundled` (`tests/scripts/dev_tools/test_skill_bundle_contract_repo.py`): the brief and the contract copies wrote the plan validator and the Codex generator in `python -m` invocation form, which a pushed skill cannot carry. The references were rewritten as citations, the mirrors re-copied with [P5-T1], and the loop restarted from [P6-T1].
