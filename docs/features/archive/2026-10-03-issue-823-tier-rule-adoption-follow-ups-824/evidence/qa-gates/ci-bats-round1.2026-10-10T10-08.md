# P16-T4 CI Bats Results and Repo-Wide Bash Coverage, Round 1

Timestamp: 2026-10-10T10-08
Command: poetry run python -c "<reader R4 of Appendix P>" artifacts/orchestration/ci-shell-coverage/38057811190/run.log
EXIT_CODE: 0
Output Summary:
- R4 exit 0.
- TEST_LINES 8282 OK 606 NOT_OK 0 C824_OK 61 C824_MAX 61 REPO_BASH_LINE 94.3
- NOT_OK 0: every bats case passed, including both shell-qc suites (`tests/shell/test_shell_qc_discovery.bats`, `tests/shell/test_shell_qc_commands.bats`) and C824-1 to C824-15.
- ADDED_CASES is 0 (no remediation round), so the required C824 count is 61 + 0 = 61; C824_OK 61 and C824_MAX 61 both equal it.
- OK 606 is above 61.
- REPO_BASH_LINE 94.3 is at least 85.0.
- No `NOT_OK|` or `DIAG|` lines were printed.

FINAL_BASH_LINE: 94.3
RUN_ID_1: 38057811190
HOLD_HEAD_1: 5231485f772d656f868d028e463d15e4341fee19
Result: PASS
