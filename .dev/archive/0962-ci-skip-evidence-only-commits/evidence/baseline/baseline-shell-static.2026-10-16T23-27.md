# Shell baseline (P0-T18, rule 18, PD-21)

Timestamp: 2026-10-16T23-27
Command: sh SCRATCH/tools/run-cr.sh cr-shell-static
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Unchanged files. SHELL-LINES 394 (shell_qc_lib.sh), 103 (shell-qc.sh), 204 (test_shell_qc_commands.bats). SHELL-RECURSIVE-INVOCATIONS: 0, SHELL-NONRECURSIVE-INVOCATIONS: 2, SHELL-THRESHOLD-FUNCTION: 0, SHELL-NEW-TESTS-MISSING: 8, SHELL-NESTED-BATS-FILES: 0, SHELL-LINES-OVER-500: 0, SHELL-CRLF-FILES: 0. Local lint ran and passed (shellcheck exit 0, shfmt -d exit 0; SHELL-LOCAL-LINT: ran=2 | failing=0), so -LintInformational is not needed later. Bash coverage baseline: the CI figure `Bash coverage (lines): 95.2%` of main run 38948304976 (orchestrator observation; not measurable locally, re-read by P7-T4).

## Output

```
RUN-CR: cr-shell-static
SHELL-LINES: scripts/bash/shell_qc_lib.sh | 394
SHELL-LINES: scripts/bash/shell-qc.sh | 103
SHELL-LINES: tests/shell/test_shell_qc_commands.bats | 204
SHELL-RECURSIVE-INVOCATIONS: 0
SHELL-NONRECURSIVE-INVOCATIONS: 2
SHELL-THRESHOLD-FUNCTION: 0
SHELL-THRESHOLD-WIRING: 0
SHELL-THRESHOLD-DEFAULT-85: 0
SHELL-USAGE-THRESHOLD-LINE: 0
SHELL-NOUNSET-ASSERTIONS-UPDATED: 0
SHELL-NEW-TEST-MISSING: test passes --recursive to bats for each test directory
SHELL-NEW-TEST-MISSING: test --coverage passes --recursive to bats under kcov
SHELL-NEW-TEST-MISSING: check_coverage_threshold fails below the default 85 percent minimum
SHELL-NEW-TEST-MISSING: check_coverage_threshold passes when coverage equals the minimum
SHELL-NEW-TEST-MISSING: check_coverage_threshold passes when coverage is above the minimum
SHELL-NEW-TEST-MISSING: check_coverage_threshold rejects a minimum that is not an integer
SHELL-NEW-TEST-MISSING: check_coverage_threshold rejects a minimum above 100
SHELL-NEW-TEST-MISSING: check_coverage_threshold prints nothing and passes when cov.xml is missing
SHELL-NEW-TESTS-MISSING: 8
SHELL-NESTED-FILE: helpers/codex_web_setup_common.bash
SHELL-NESTED-BATS-FILES: 0
SHELL-TESTS-BASH-DIR-EXISTS: False
SHELL-LINES-OVER-500: 0
SHELL-CRLF-FILES: 0
SHELLCHECK-EXIT: 0
SHFMT-EXIT: 0
SHELL-LOCAL-LINT: ran=2 | failing=0 | informational=False
EXIT_CODE_COMPUTED: 1
```
