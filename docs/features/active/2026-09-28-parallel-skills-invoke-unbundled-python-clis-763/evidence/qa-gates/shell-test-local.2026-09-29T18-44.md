# Bash Tests, Local (P7-T3)

Timestamp: 2026-09-29T18-44
Command: npx --yes bats tests/shell/parallel_abandon.bats tests/shell/parallel_payload_only.bats tests/shell/parallel_ba?h_manifest_membership.bats ; sh SCRATCH/bats-parity-local.sh
EXIT_CODE: 0
Output Summary:
- Three suites: exit 0, TAP plan `1..34`, 34 `ok` lines, no `not ok` line (satisfies the P5-T10
  rule: no failing test in `tests/shell/parallel_abandon.bats`, in the B29 tests, or in the B30 test,
  and the P0-T20 baseline failure set is empty).
- Parity lane: `1..3`, `ok 1 the abandon parity corpus meets the declared floor`,
  `ok 2 the harness interpreter is available to read the corpus`,
  `ok 3 the bash lane reproduces every abandon corpus fixture`, `BATS-PARITY-EXIT=0` (satisfies the
  P2-T15 rule without the environment branch).
- Coverage: local kcov is unavailable; the bash coverage values for this language are produced by
  P11-T3 and P11-T4 from the committed final state.
