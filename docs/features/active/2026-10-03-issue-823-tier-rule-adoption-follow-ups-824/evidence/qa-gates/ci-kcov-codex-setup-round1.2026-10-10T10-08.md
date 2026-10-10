# P16-T5 kcov Coverage of `.codex/codex-web-setup.sh`, Round 1

Timestamp: 2026-10-10T10-08
Command: poetry run python -c "<reader R5 of Appendix P>" artifacts/orchestration/ci-shell-coverage/38057811190/shell-coverage/cov.xml
EXIT_CODE: 0
Output Summary:
- R5 exit 0.
- ROOT_LINE_RATE 0.943 MATCHES 1 CLASS_LINE_RATE 0.957 LINES 208 HIT 199 PCT 95.67 GATE PASS
- UNCOVERED [207, 210, 302, 317, 318, 319, 322, 323, 324]
- MATCHES 1: the widened kcov include pattern took effect and `.codex/codex-web-setup.sh` is measured.
- CLASS_LINE_RATE 0.957 is at least the 0.85 threshold.
- Six of the nine uncovered lines (317-319, 322-324) lie inside the `pwsh -Command` string content, which AC-14 forbids changing.

FINAL_CODEX_SETUP_PCT: 95.67
FINAL_CODEX_SETUP_RATE: 0.957
ROOT_LINE_RATE: 0.943 (same merged report as FINAL_BASH_LINE 94.3)
RUN_ID_1: 38057811190
HOLD_HEAD_1: 5231485f772d656f868d028e463d15e4341fee19
Result: PASS
