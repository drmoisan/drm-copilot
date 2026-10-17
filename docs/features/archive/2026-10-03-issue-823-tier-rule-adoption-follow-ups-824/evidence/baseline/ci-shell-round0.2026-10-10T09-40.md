# P13-T1 CI Round-0 Readout (Bash Baseline)

Timestamp: 2026-10-10T09-40
Command: ls artifacts/orchestration/ci-shell-coverage/38056265858; reader R2 of Appendix P on artifacts/orchestration/ci-shell-coverage/38056265858/run.json; reader R3 on artifacts/orchestration/ci-shell-coverage/38056265858/run.log; reader R4 on artifacts/orchestration/ci-shell-coverage/38056265858/run.log; reader R5 on artifacts/orchestration/ci-shell-coverage/38056265858/shell-coverage/cov.xml
EXIT_CODE: 0
Output Summary:
- RUN_ID_0: 38056265858. HOLD_HEAD_0: db0ef518791ae28777a80e5236b9a199af37506c.
- ls: exit 0; listed `run.json`, `run.log`, `shell-coverage/` (shell-coverage/ holds `cov.xml` at its root).
- R2: exit 0. Output verbatim:
  - RUN 38056265858 HEAD db0ef518791ae28777a80e5236b9a199af37506c CONCLUSION success
  - STEP Set up job | success
  - STEP Check out repository | success
  - STEP Install shell tooling (shellcheck, shfmt, bats) | success
  - STEP Cache kcov build | success
  - STEP Build kcov from source | skipped
  - STEP Install kcov from cache | success
  - STEP Run shell-qc check (shfmt diff + shellcheck) | success
  - STEP Run shell-qc test with coverage | success
  - STEP Upload shell coverage artifacts | success
  - STEP Post Cache kcov build | success
  - STEP Post Check out repository | success
  - STEP Complete job | success
- R2 HEAD equals HOLD_HEAD_0 (the run tested the held commit).
- R3: exit 0. Output verbatim: `CHECK_LINES 4 SHELLCHECK_FINDINGS 0 SHFMT_DIFF_FILES 0` (no CHECK| lines; both counts are 0).
- R4: exit 0. Output verbatim: `TEST_LINES 7904 OK 559 NOT_OK 0 C824_OK 15 C824_MAX 15 REPO_BASH_LINE 94.2` (no NOT_OK| or DIAG| lines).
- R5: exit 0. Output verbatim:
  - ROOT_LINE_RATE 0.942 MATCHES 0 CLASS_LINE_RATE MISSING LINES 0 HIT 0 PCT MISSING GATE FAIL
  - UNCOVERED NONE

Expected pre-widening facts (recorded, not stop conditions):
- R5 prints `MATCHES 0` and `GATE FAIL`: kcov does not yet measure `.codex/`.
- R4 prints `C824_OK 15` (at most 15).

BASE_BASH_LINE: 94.2

Round-0 pre-existing failure set: none (R3 counts are 0; R4 `NOT_OK 0`, so no NOT_OK| or DIAG| lines were printed).
