Timestamp: 2026-11-04T03-17
Command: poetry run pytest eight environment/workflow/cleanup/resource/manifest/dependency-closure suites --cov=scripts.dev_tools.clean_devcontainer --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-1069-python-final.json --junitxml=SCRATCH/issue-1069-python-final-junit.xml
EXIT_CODE: 0
Output Summary: ______________ coverage: platform win32, python 3.13.17-final-0 _______________

Name                                      Stmts   Miss Branch BrPart  Cover
---------------------------------------------------------------------------
scripts\dev_tools\clean_devcontainer.py      36      2     10      1    93%
---------------------------------------------------------------------------
TOTAL                                        36      2     10      1    93%
Coverage JSON written to file C:\Users\DANMOI~1\AppData\Local\Temp/issue-1069/issue-1069-python-final.json
Coverage LCOV written to file artifacts/python/lcov.info
============================= 80 passed in 2.47s ==============================


