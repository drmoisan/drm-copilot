# Local bats, companion suites after the fix (P3-T6)

Timestamp: 2026-10-09T07-10
Command: bats --tap tests/shell/parallel_cohorts_parity.bats tests/shell/parallel_payload_only.bats tests/shell/parallel_bash_manifest_membership.bats
EXIT_CODE: 127
Output Summary: BATS absent. Real message: `bats: command not found`. The P4-T9 artifact (final-shell-test-ci.2026-10-08T21-25.md) is the authority; the full-suite CI run covers these three files.

stderr: /usr/bin/bash: line 5: bats: command not found
