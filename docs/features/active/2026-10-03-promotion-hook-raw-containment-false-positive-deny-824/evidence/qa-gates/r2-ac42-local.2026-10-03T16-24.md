# r2 P7-T9 AC-42 local evidence and pending items

Timestamp: 2026-10-03T16-24
Command: step script SCRATCH/steps/r2-p7-t9.ps1 (SH-CHECK on both setup copies; bundle byte identity; line counts of SETUP, its bundle copy, and BATS; guard comparison; C824 @test count; VERDICT)
EXIT_CODE: 0
Output Summary:
- .codex/codex-web-setup.sh SYNTAX-EXIT=0; bundle copy SYNTAX-EXIT=0; SYNTAX-EXIT=0
- BUNDLE-EQUAL=True
- LINES=405,405,187 (all at most 500)
- SETUP-LAST-IS-GUARD=True
- BATS-TESTS=15

AC-42 local criteria: VERIFIED - safe to source (the BASH_SOURCE guard is the last line), byte identity with the bundle copy, sh -n on both copies, line counts, the 15 BATS cases with their static traceability (r2-p5-t2), the gate logic (r2-p5-t5, 15 passed), and the workflow invariants (r2-p5-t8, 6 passed).

AC-42 bats pass: PENDING CI - shell-coverage / Shell Coverage (Bats + kcov), steps Run shell-qc test with coverage and Measure .codex/codex-web-setup.sh coverage with kcov (issue 824), on the PR head

AC-42 kcov changed-function coverage: PENDING CI - step Gate .codex/codex-web-setup.sh changed-function coverage (issue 824) on the PR head pull_request run (D13, P9-T4)
