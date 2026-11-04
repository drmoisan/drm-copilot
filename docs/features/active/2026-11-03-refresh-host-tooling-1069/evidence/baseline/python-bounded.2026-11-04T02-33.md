Timestamp: 2026-11-04T02-33
Command: poetry run pytest tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py tests/scripts/dev_tools/test_clean_devcontainer.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py --cov=scripts.dev_tools.clean_devcontainer --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-1069-python-bounded-baseline.json --junitxml=SCRATCH/issue-1069-python-bounded-baseline-junit.xml
EXIT_CODE: 0
Output Summary: - generated xml file: C:\Users\DANMOI~1\AppData\Local\Temp\issue-1069\issue-1069-python-bounded-baseline-junit.xml -
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.17-final-0 _______________

Name                                      Stmts   Miss Branch BrPart  Cover
---------------------------------------------------------------------------
scripts\dev_tools\clean_devcontainer.py      36      2     10      1    93%
---------------------------------------------------------------------------
TOTAL                                        36      2     10      1    93%
Coverage JSON written to file C:\Users\DANMOI~1\AppData\Local\Temp/issue-1069/issue-1069-python-bounded-baseline.json
Coverage LCOV written to file artifacts/python/lcov.info
============================= 58 passed in 2.65s ==============================


