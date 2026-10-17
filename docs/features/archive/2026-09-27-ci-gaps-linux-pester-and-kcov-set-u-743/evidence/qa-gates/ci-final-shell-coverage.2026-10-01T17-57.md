# Final kcov Results (P7-T20, AC-16)

Timestamp: 2026-10-01T17-57
RUN_ID: 36901896617; job `shell-coverage / Shell Coverage (Bats + kcov)` databaseId 110502826537; CI_SHA ecba8829604f6265dc491c74cf42546f9d5aab57; conclusion `success`.

Command: gh run view 36901896617 --log --job 110502826537 | grep -F 'Bash coverage (lines):'
EXIT_CODE: 0
Output Summary: headline `Bash coverage (lines): 93.7%` (at least 85.0; baseline 93.4%). Usage-text lines containing the literal `NN.N%` are excluded.

Command: gh run view 36901896617 --log --job 110502826537 | grep -E ' not ok [0-9]+ '
EXIT_CODE: 1
Output Summary: no output; the `not ok` set is empty, a subset of the empty P0-T23 CI bats baseline failure set.

Command: gh run view 36901896617 --log --job 110502826537 | grep -F -e 'test fails when a bats child sources a nounset library inside bash -c' -e 'test passes when a bats child resets nounset after sourcing' -e 'kcov_trace_env.sh sets the kcov PS4 format'
EXIT_CODE: 0
Output Summary: `ok 486 test fails when a bats child sources a nounset library inside bash -c`; `ok 487 test passes when a bats child resets nounset after sourcing`; `ok 488 kcov_trace_env.sh sets the kcov PS4 format`.

Command: gh run download 36901896617 --name shell-coverage --dir <session-scratchpad>/kcov-final-743
EXIT_CODE: 0
Output Summary: root `cov.xml` present.

Command: sh <session-scratchpad>/kcov-changed-lines.sh <session-scratchpad>/kcov-final-743/cov.xml 41217012d31d35c2ee33a50be50684affd2f5f43
EXIT_CODE: 0
Output Summary: `scripts/bash/shell_qc_lib.sh` line-rate 0.905 (baseline 0.865); `scripts/bash/kcov_trace_env.sh` line-rate 1.000. Every instrumented changed line has `hits=1`; the remaining changed lines are comments or blank lines (`NOT-INSTRUMENTED`). Each file has at least one `hits=` record.

```
CLASS: scripts/bash/shell_qc_lib.sh line-rate="0.905"
LINE: scripts/bash/shell_qc_lib.sh:227 NOT-INSTRUMENTED
LINE: scripts/bash/shell_qc_lib.sh:228 NOT-INSTRUMENTED
LINE: scripts/bash/shell_qc_lib.sh:234 NOT-INSTRUMENTED
LINE: scripts/bash/shell_qc_lib.sh:235 NOT-INSTRUMENTED
LINE: scripts/bash/shell_qc_lib.sh:236 NOT-INSTRUMENTED
LINE: scripts/bash/shell_qc_lib.sh:237 NOT-INSTRUMENTED
LINE: scripts/bash/shell_qc_lib.sh:238 NOT-INSTRUMENTED
LINE: scripts/bash/shell_qc_lib.sh:239 NOT-INSTRUMENTED
LINE: scripts/bash/shell_qc_lib.sh:240 NOT-INSTRUMENTED
LINE: scripts/bash/shell_qc_lib.sh:241 NOT-INSTRUMENTED
LINE: scripts/bash/shell_qc_lib.sh:253 hits=1
LINE: scripts/bash/shell_qc_lib.sh:254 hits=1
LINE: scripts/bash/shell_qc_lib.sh:255 hits=1
LINE: scripts/bash/shell_qc_lib.sh:256 NOT-INSTRUMENTED
LINE: scripts/bash/shell_qc_lib.sh:257 hits=1
LINE: scripts/bash/shell_qc_lib.sh:262 hits=1
LINE: scripts/bash/shell_qc_lib.sh:267 hits=1
CLASS: scripts/bash/kcov_trace_env.sh line-rate="1.000"
LINE: scripts/bash/kcov_trace_env.sh:1 NOT-INSTRUMENTED
LINE: scripts/bash/kcov_trace_env.sh:2 NOT-INSTRUMENTED
LINE: scripts/bash/kcov_trace_env.sh:3 NOT-INSTRUMENTED
LINE: scripts/bash/kcov_trace_env.sh:4 NOT-INSTRUMENTED
LINE: scripts/bash/kcov_trace_env.sh:5 NOT-INSTRUMENTED
LINE: scripts/bash/kcov_trace_env.sh:6 NOT-INSTRUMENTED
LINE: scripts/bash/kcov_trace_env.sh:7 NOT-INSTRUMENTED
LINE: scripts/bash/kcov_trace_env.sh:8 hits=1
LINE: scripts/bash/kcov_trace_env.sh:9 hits=1
```

Command: git diff --exit-code 41217012d31d35c2ee33a50be50684affd2f5f43 -- .github/workflows/_shell-coverage.yml
EXIT_CODE: 0
Output Summary: no output; `_shell-coverage.yml` is unchanged.
