# Non-blocking Deviation: bats and kcov absent on the host (P0-T7)

Timestamp: 2026-11-10T04-26
Command: sh scripts/bash/shell-qc.sh test --coverage
EXIT_CODE: 127
Output Summary: bats not installed; cannot run shell tests with coverage. Neither bats nor kcov is on the host PATH, so the local bats baseline cannot run. Authorized by the P0-T7 deviation branch.

Evidence of record for the bats suite and kcov line coverage is the CI job `shell-coverage / Shell Coverage (Bats + kcov)` on the pull-request head. The same branch is authorized for P7-T7 under the same condition.
