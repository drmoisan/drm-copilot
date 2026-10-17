# P16-T3 CI shell-qc Check, Round 1

Timestamp: 2026-10-10T10-08
Command: poetry run python -c "<reader R3 of Appendix P>" artifacts/orchestration/ci-shell-coverage/38057811190/run.log
EXIT_CODE: 0
Output Summary:
- R3 exit 0.
- CHECK_LINES 4 SHELLCHECK_FINDINGS 0 SHFMT_DIFF_FILES 0
- CHECK_LINES is above 0, so the `Run shell-qc check` step is present in the log; no shellcheck finding and no shfmt diff over the widened discovery set (which includes `.codex/codex-web-setup.sh`).
- No `CHECK|` lines were printed, because both counts are 0.

RUN_ID_1: 38057811190
HOLD_HEAD_1: 5231485f772d656f868d028e463d15e4341fee19
Result: PASS
