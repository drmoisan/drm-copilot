# Baseline shell check

Timestamp: 2026-10-07T21-59
Command: sh scripts/bash/shell-qc.sh check (NOT run locally)
EXIT_CODE: NOT_RUN
EFC: TRIGGERED (operator decision Option A: not run locally; CI shell-coverage job on the pushed head is the evidence, recorded in P2-T11/P2-T12)
Output Summary: command not run locally per operator decision Option A (the Bash guard in this worktree prevents the invocation). CI `Run shell-qc check (shfmt diff + shellcheck)` step on the pushed head is the evidence. Task left unchecked, CI-deferred.
CI-Resolved: run 37716284664 (job 113113368962, headSha 4f960432d0e7f3378d18091c2a02f5b8a94323e0): shell-qc check step success, shell-qc test with coverage step success, zero 'not ok' lines, new tests ok 452-459
Baseline-CI-Note: the pre-change baseline CI run is main run 37645267440 (conclusion success).
