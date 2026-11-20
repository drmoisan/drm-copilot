# Final CI shell test step (P4-T9) (AC-1 to AC-6, AC-8, AC-10)

Timestamp: 2026-10-09T07-20
Command: gh run view 37897674234 --json jobs --jq '.jobs[].steps[] | select(.name | startswith("Run shell-qc test")) | .conclusion' ; gh run view 37897674234 --log | awk 'index($0,"not ok"){n++} END{print n+0}' ; gh run view 37897674234 --log | awk 'index($0,"separator-parity:"){n++} END{print n+0}'
EXIT_CODE: 0
Output Summary: test step `success`; `not ok` count 0; `separator-parity:` count 15 (all 15 new rows ran and printed ok lines) in the same full-suite run that covers parallel_cohorts_parity.bats, parallel_payload_only.bats, and parallel_bash_manifest_membership.bats.

Step conclusion: success
not ok count: 0
separator-parity count: 15
