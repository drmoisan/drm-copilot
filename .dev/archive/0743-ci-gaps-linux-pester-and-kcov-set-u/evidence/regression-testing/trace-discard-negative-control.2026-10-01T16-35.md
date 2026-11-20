# Trace-Discard Negative Control (P2-T8)

Timestamp: 2026-10-01T16-35
Command: npx --yes bats --print-output-on-failure --filter 'resets nounset after sourcing' tests/shell/test_shell_qc_commands.bats
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `1..1`; one `not ok` line, `not ok 1 test passes when a bats child resets nounset after sourcing`, failing on `[[ "$output" != *"kcov@"* ]]`; the printed output contains 15 lines with `kcov@` (for example `kcov@<REPO_ROOT>/tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset@9@echo 'nounset-reset-stub ran: tests/shell'`).

Mutation applied for this run only: the text `BASH_XTRACEFD="$trace_fd" ` was deleted from the bats invocation line (line 262) of `scripts/bash/shell_qc_lib.sh`, so the trace went to stderr instead of the discard descriptor. The file was restored byte for byte afterwards (see `trace-discard-restored.2026-10-01T16-35.md`).
