# Bash Static Checks After Edit (P2-T4, P2-T5)

Timestamp: 2026-10-01T16-34

P2-T4 acceptance:

Command: grep -c -F 'kcov_trace_env.sh' scripts/bash/shell_qc_lib.sh
EXIT_CODE: 0
Output Summary: `2` (one comment reference, one assignment).

Command: grep -c -F 'BASH_XTRACEFD="$trace_fd"' scripts/bash/shell_qc_lib.sh
EXIT_CODE: 0
Output Summary: `1`

Command: git diff -U0 41217012d31d35c2ee33a50be50684affd2f5f43 -- scripts/bash/shell_qc_lib.sh
EXIT_CODE: 0
Output Summary: five hunk headers (`@@ -227 +227,2 @@`, `@@ -232,0 +234,8 @@`, `@@ -243,0 +253,5 @@`, `@@ -248 +262 @@`, `@@ -252,0 +267 @@`), all inside `run_test` (new-side lines 226 to 268; `extract_cobertura_line_rate() {` is at line 271). `run_test_coverage` is unchanged.

P2-T5:

Command: shfmt -d scripts/bash/shell_qc_lib.sh scripts/bash/kcov_trace_env.sh
EXIT_CODE: 0
Output Summary: no output.

Command: shellcheck -f gcc scripts/bash/shell_qc_lib.sh scripts/bash/kcov_trace_env.sh
EXIT_CODE: 0
Output Summary: no output.

Command: sh -n scripts/bash/shell_qc_lib.sh
EXIT_CODE: 0
Output Summary: no output.
