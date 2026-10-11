# Baseline — bats (two edited suites)

Timestamp: 2026-10-10T08-08
Task: [P0-T11]
Command: npx --yes bats tests/shell/parallel_payload_only.bats tests/shell/parallel_bash_manifest_membership.bats (not run locally)
EXIT_CODE: N/A
CI-DEFERRED: yes
Reason: operator constraint prohibits local bats execution

Output Summary:
- The command was not executed in this worktree, per the binding operator constraint for this run.
- The baseline TAP plan line (`1..N`) and any `not ok` lines will be taken from the CI bats job log on the pull request for branch `bug/issue-763-parallel-skill-cli-port-follow-ups-791`.
- Deviation recorded in `evidence/other/execution-deviations.2026-10-10T08-02.md`.
