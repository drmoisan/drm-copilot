# Shell edits verified locally (P5-T3 to P5-T6; AC-37, AC-38 local evidence)

Timestamp: 2026-10-17T00-00
Command: sh SCRATCH/tools/run-cr.sh cr-shell-static
EXIT_CODE: 0
Output Summary: S1 to S3 applied. SHELL-RECURSIVE-INVOCATIONS: 2, SHELL-NONRECURSIVE-INVOCATIONS: 0, SHELL-THRESHOLD-FUNCTION: 1, SHELL-THRESHOLD-WIRING: 1, SHELL-THRESHOLD-DEFAULT-85: 1, SHELL-USAGE-THRESHOLD-LINE: 1, SHELL-NOUNSET-ASSERTIONS-UPDATED: 2, SHELL-NEW-TESTS-MISSING: 0, SHELL-NESTED-BATS-FILES: 0, SHELL-LINES-OVER-500: 0, SHELL-CRLF-FILES: 0; line counts 432 (shell_qc_lib.sh), 106 (shell-qc.sh), 265 (bats suite). Local lint ran: shellcheck exit 0 and shfmt -d exit 0 (SHELL-LOCAL-LINT: ran=2 | failing=0); -LintInformational was not passed because the P0-T18 baseline recorded failing=0. EXIT_CODE_COMPUTED: 0. Bats tests and kcov coverage are CI evidence (P7-T4); AC-37 and AC-38 are not checked here.

## Output

```
RUN-CR: cr-shell-static
SHELL-LINES: scripts/bash/shell_qc_lib.sh | 432
SHELL-LINES: scripts/bash/shell-qc.sh | 106
SHELL-LINES: tests/shell/test_shell_qc_commands.bats | 265
SHELL-RECURSIVE-INVOCATIONS: 2
SHELL-NONRECURSIVE-INVOCATIONS: 0
SHELL-THRESHOLD-FUNCTION: 1
SHELL-THRESHOLD-WIRING: 1
SHELL-THRESHOLD-DEFAULT-85: 1
SHELL-USAGE-THRESHOLD-LINE: 1
SHELL-NOUNSET-ASSERTIONS-UPDATED: 2
SHELL-NEW-TESTS-MISSING: 0
SHELL-NESTED-FILE: helpers/codex_web_setup_common.bash
SHELL-NESTED-BATS-FILES: 0
SHELL-TESTS-BASH-DIR-EXISTS: False
SHELL-LINES-OVER-500: 0
SHELL-CRLF-FILES: 0
SHELLCHECK-EXIT: 0
SHFMT-EXIT: 0
SHELL-LOCAL-LINT: ran=2 | failing=0 | informational=False
EXIT_CODE_COMPUTED: 0
```
