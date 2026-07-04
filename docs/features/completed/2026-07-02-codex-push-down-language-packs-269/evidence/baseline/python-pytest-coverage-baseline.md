Timestamp: 2026-07-02T13-37
Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing
EXIT_CODE: 1
Output Summary: tests\scripts\dev_tools\test_new_active_feature_folder_models_coverage.py . [ 53%]
C:\Users\DanMoisan\repos\drm-copilot\.venv\Lib\site-packages\coverage\inorout.py:495: CoverageWarning: Module src/lexile_corpus_tuner was never imported. (module-not-imported); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-module-not-imported
================================== FAILURES ===================================
E           assert 'default_perm..." = "allow"\n' == 'default_perm...coverage.ps1"'
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________
TOTAL                                                               8661   1236    86%
Coverage LCOV written to file artifacts/python/lcov.info
FAILED tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts
======================= 1 failed, 1151 passed in 4.84s ========================
