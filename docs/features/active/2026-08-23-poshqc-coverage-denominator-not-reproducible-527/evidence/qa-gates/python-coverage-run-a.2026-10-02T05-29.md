# Python Coverage Run A (configured source set, statement coverage; issue #527)

Timestamp: 2026-10-02T05-29
Command: poetry -C <ROOT> run pytest --cov --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info (working directory <ROOT>; output redirected to artifacts/python/run-a-output.txt)
EXIT_CODE: 0
Output Summary: 6377 passed, 6 skipped, 0 failed. TOTAL row reports 17244 statements, 1115 missed, 94% Cover. The header has no branch columns, which confirms the configured run measures statement coverage only.

Pytest result line:
`================= 6377 passed, 6 skipped in 69.64s (0:01:09) ==================`

Table header row:
`Name                                                                  Stmts   Miss  Cover   Missing`

TOTAL row:
`TOTAL                                                                 17244   1115    94%`
