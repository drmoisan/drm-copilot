#!/bin/sh
# run-test-suite.sh: POSIX shim for the test-execution launcher (issue #1158).
# Usage: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh <suite> [extra arguments]
# Runs the sibling Invoke-TestSuite.ps1 with PowerShell 7 (TEST_SUITE_PWSH_BIN, default pwsh from
# PATH) and passes every shim argument unchanged, so the suite name stays the first script argument.
# The exit status of the launcher is the exit status of this shim.
set -eu

script_dir=$(cd "$(dirname "$0")" && pwd)
pwsh_bin=${TEST_SUITE_PWSH_BIN:-pwsh}
exec "$pwsh_bin" -NoProfile -File "$script_dir/Invoke-TestSuite.ps1" "$@"
