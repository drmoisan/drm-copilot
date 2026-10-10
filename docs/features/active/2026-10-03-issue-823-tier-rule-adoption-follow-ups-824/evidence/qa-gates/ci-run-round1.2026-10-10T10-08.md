# P16-T2 CI Run Summary, Round 1

Timestamp: 2026-10-10T10-08
Command: poetry run python -c "<reader R2 of Appendix P>" artifacts/orchestration/ci-shell-coverage/38057811190/run.json
EXIT_CODE: 0
Output Summary:
- R2 exit 0.
- RUN 38057811190 HEAD 5231485f772d656f868d028e463d15e4341fee19 CONCLUSION success
- HEAD equals HOLD_HEAD_1 (5231485f772d656f868d028e463d15e4341fee19).
- The three gated steps (`Run shell-qc check (shfmt diff + shellcheck)`, `Run shell-qc test with coverage`, `Upload shell coverage artifacts`) each end in `| success`.

STEP lines (verbatim):

```
STEP Set up job | success
STEP Check out repository | success
STEP Install shell tooling (shellcheck, shfmt, bats) | success
STEP Cache kcov build | success
STEP Build kcov from source | skipped
STEP Install kcov from cache | success
STEP Run shell-qc check (shfmt diff + shellcheck) | success
STEP Run shell-qc test with coverage | success
STEP Upload shell coverage artifacts | success
STEP Post Cache kcov build | success
STEP Post Check out repository | success
STEP Complete job | success
```

RUN_ID_1: 38057811190
Result: PASS
