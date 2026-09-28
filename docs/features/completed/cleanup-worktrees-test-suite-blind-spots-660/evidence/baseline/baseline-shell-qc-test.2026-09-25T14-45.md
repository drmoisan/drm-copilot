Timestamp: 2026-09-25T14-45
Command: npx --yes bats tests/shell
EXIT_CODE: 0
Output Summary: TAP header read `1..460` (N_baseline = 460). The captured output contains
460 `ok` lines and zero `not ok` lines. The literal string `bats not installed; skipping
shell tests.` (the `run_test()` silent-no-op hazard string) is ABSENT from the captured
output, confirming a real bats run executed (not a vacuous skip). All 460 baseline tests
passed. This run used the npx-resolved `bats` binary directly (npx-published `bats`
package), per the plan's Command-route note. A prior attempt to run `sh
scripts/bash/shell-qc.sh test` printed only `bats not installed; skipping shell tests.`
and exited 0 -- a vacuous pass with zero tests executed, illustrating exactly the hazard
this task's acceptance condition guards against; that run is not used as baseline evidence
and the npx-resolved run above is the authoritative baseline capture.
