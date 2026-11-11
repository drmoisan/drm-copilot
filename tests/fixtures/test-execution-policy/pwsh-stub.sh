#!/bin/sh
# Test stub for run-test-suite.sh (issue #1158): prints a marker and each argument on its own
# line, then exits with STUB_EXIT_CODE (default 0). It starts no PowerShell process.
printf '%s\n' 'pwsh-stub'
for argument in "$@"; do
    printf '%s\n' "$argument"
done
exit "${STUB_EXIT_CODE:-0}"
