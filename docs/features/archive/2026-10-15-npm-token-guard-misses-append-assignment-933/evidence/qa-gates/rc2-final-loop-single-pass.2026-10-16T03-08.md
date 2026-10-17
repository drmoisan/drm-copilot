# rc2 Final Loop Single Pass (P2-T8)

Timestamp: 2026-10-16T03-08
Command: git status --porcelain -- tests/scripts/dev_tools/npm_token_guard_test_support.py tests/scripts/dev_tools/test_workflow_npm_token_guard.py
EXIT_CODE: 0
Output Summary: single pass of P2-T1 through P2-T7 completed; no rerun was needed.

Artifacts of the last P2-T1 through P2-T7 run (each is the lexicographically greatest file of its name in evidence/qa-gates/, and each is the only file of its name):

1. P2-T1 evidence/qa-gates/rc2-final-black.2026-10-16T03-03.md (acceptance literal `2 files left unchanged.`, EXIT_CODE 0, PostPassStatus equals PrePassStatus)
2. P2-T2 evidence/qa-gates/rc2-final-ruff.2026-10-16T03-03.md (acceptance literal `All checks passed!`, EXIT_CODE 0)
3. P2-T3 evidence/qa-gates/rc2-final-pyright.2026-10-16T03-03.md (acceptance literal `0 errors, 0 warnings, 0 informations`, EXIT_CODE 0)
4. P2-T4 evidence/qa-gates/rc2-final-pytest-guard.2026-10-16T03-03.md (acceptance literal `70 passed`, EXIT_CODE 0)
5. P2-T5 evidence/qa-gates/rc2-final-pytest-coverage.2026-10-16T03-07.md (`FinalFailingNodes: none`, EXIT_CODE 0, `PostChangePassedCount: 7104`, `PostChangeSkippedCount: 6`, `PostChangeTotalCover: 92%`)
6. P2-T6 evidence/qa-gates/rc2-final-coverage-thresholds.2026-10-16T03-07.md (`Output Summary: no output`, EXIT_CODE 0)
7. P2-T7 evidence/qa-gates/rc2-final-coverage-percentages.2026-10-16T03-07.md (EXIT_CODE 1 with ExpectedExitCode 1; two lines beginning `line coverage ` and `branch coverage `; 93.79748270779 >= 85 and 88.11243718592965 >= 75)

PrePassStatus (from the last P2-T1 artifact): no output
CurrentStatus (command run now): no output
Result: the two outputs are identical.
