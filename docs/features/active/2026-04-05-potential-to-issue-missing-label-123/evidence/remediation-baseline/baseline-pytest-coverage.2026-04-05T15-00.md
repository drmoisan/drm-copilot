# Baseline: Pytest Coverage (Bundled Runtime)

Timestamp: 2026-04-05T15-00
Command: `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q --cov=extensions/drm-copilot/resources/scripts/dev_tools --cov-report=term-missing`
EXIT_CODE: 0
Output Summary: 12 passed. Bundled-runtime `potential_to_issue.py`: 200 stmts, 10 miss, **95% coverage**. Missing lines: 166, 169, 172, 175, 178-179, 182, 185-186, 319.

Note: The plan-specified `--cov=extensions.drm_copilot.resources.scripts.dev_tools.potential_to_issue` module path does not resolve because the test loads the module via `importlib.util.spec_from_file_location` as `dev_tools.potential_to_issue`. The source-directory approach (`--cov=extensions/drm-copilot/resources/scripts/dev_tools`) correctly tracks coverage.
