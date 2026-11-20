# Python Test Coverage Baseline

Timestamp: 2026-03-13T00-34
Task: P0-T7
Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing
EXIT_CODE: 0

## Output Summary:

836 passed in 3.04s
Coverage LCOV written to file artifacts/python/lcov.info

### Coverage Headline:

TOTAL: 6615 statements, 1193 missed, **82%** overall coverage

### Notable module coverage (scripts/dev_tools):
- new_potential_bug_entry.py: 91%
- new_active_feature_folder_flow.py: 89%
- new_active_feature_folder_models.py: 68%
- potential_to_issue.py: 90%
- push_down_copilot_customizations.py: 100%
- shell_qc.py: 0% (not exercised)
