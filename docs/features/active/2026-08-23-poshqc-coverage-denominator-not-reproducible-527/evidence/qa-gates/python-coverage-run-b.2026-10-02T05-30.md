# Python Coverage Run B (configured source set plus --cov-branch; issue #527)

Timestamp: 2026-10-02T05-30
Command: poetry -C <ROOT> run pytest --cov --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info (working directory <ROOT>; output redirected to artifacts/python/run-b-output.txt)
EXIT_CODE: 0
Output Summary: 6377 passed, 6 skipped, 0 failed. Header records Branch and BrPart columns. TOTAL row reports 17244 statements, 1115 missed, 6230 branches, 572 partial, 92% combined Cover. EXIT_CODE equals the Run A EXIT_CODE (0). The 92% figure is the combined statement-plus-branch figure and is not the line percentage.

Pytest result line:
`================= 6377 passed, 6 skipped in 81.06s (0:01:21) ==================`

Table header row:
`Name                                                                  Stmts   Miss Branch BrPart  Cover   Missing`

TOTAL row:
`TOTAL                                                                 17244   1115   6230    572    92%`
