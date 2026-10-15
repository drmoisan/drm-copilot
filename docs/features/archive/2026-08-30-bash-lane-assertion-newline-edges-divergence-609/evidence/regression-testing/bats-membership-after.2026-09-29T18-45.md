# Bats Membership Suite After the Fix (P3-T4)

Timestamp: 2026-10-01T23:43:00-04:00
Command: bats --tap tests/shell/parallel_bash_manifest_membership.bats   (NOT RUN locally; withheld by operator rule Option A, deviation D4)
EXIT_CODE: NOT-RUN (no local exit code observed; no value fabricated)
Output Summary: BATS is absent for local use. Expected on a passing run: exit 0 and no line beginning with `not ok`, showing the bundled mirror matches the canonical file per `cmp -s`. The equivalent local fact observed is the byte-identity of the two files (`cmp` exit 0 in `mirror-updated.2026-09-29T18-45.md`). Authority: CI job `shell-coverage` on the pushed head.

Operator-run blocker (optional local confirmation, requires bats): bats --tap tests/shell/parallel_bash_manifest_membership.bats
