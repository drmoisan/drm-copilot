# Bash Abandon Parity Lane, Local Run (P2-T15)

Timestamp: 2026-09-29T18-00
Command: sh SCRATCH/bats-parity-local.sh
EXIT_CODE: 0
Output Summary:
1..3
ok 1 the abandon parity corpus meets the declared floor
ok 2 the harness interpreter is available to read the corpus
ok 3 the bash lane reproduces every abandon corpus fixture
BATS-PARITY-EXIT=0

The authorized environment branch was not needed: all three tests passed locally with the Poetry
environment's `python` as the harness interpreter. Test 3 asserts that at least 9 fixtures were
checked.
