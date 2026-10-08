#!/usr/bin/env bash
# kcov_trace_env.sh: kcov-equivalent xtrace environment for run_test in
# scripts/bash/shell_qc_lib.sh (issue #743). run_test points BASH_ENV at this file, so every
# non-interactive child bash of a bats run sources it and traces with the PS4 that kcov v43
# installs (src/engines/bash-helper.sh). BASH_SOURCE is unset at the top level of bash -c,
# so a test that sources a nounset-enabling library there fails locally as it fails under
# CI kcov. run_test discards the trace through BASH_XTRACEFD. Defines nothing else.
PS4='kcov@${BASH_SOURCE}@${LINENO}@'
set -x
