# Bats File Static Checks

All checks use `git grep --no-index` because the file is untracked until P1-T12. Static checks only; the bats pass result comes from CI in Phase 2.

## Block 1

Timestamp: 2026-10-12T12-55
Command: git grep --no-index -c -F -e "@test" -- tests/shell/compute_concurrency_batches_cli.bats
EXIT_CODE: 0
Output Summary: tests/shell/compute_concurrency_batches_cli.bats:5 (expected 5; match)

## Block 2

Timestamp: 2026-10-12T12-55
Command: git grep --no-index -c -F -e "run bash" -- tests/shell/compute_concurrency_batches_cli.bats
EXIT_CODE: 0
Output Summary: tests/shell/compute_concurrency_batches_cli.bats:5 (expected 5; match)

## Block 3

Timestamp: 2026-10-12T12-55
Command: git grep --no-index -c -F -e "-eq 2" -- tests/shell/compute_concurrency_batches_cli.bats
EXIT_CODE: 0
Output Summary: tests/shell/compute_concurrency_batches_cli.bats:3 (expected 3; match)

## Block 4

Timestamp: 2026-10-12T12-55
Command: git grep --no-index -c -F -e "-eq 0" -- tests/shell/compute_concurrency_batches_cli.bats
EXIT_CODE: 0
Output Summary: tests/shell/compute_concurrency_batches_cli.bats:2 (expected 2; match)

## Block 5

Timestamp: 2026-10-12T12-55
Command: git grep --no-index -c -E -e '^    run bash "\$BATCHES" --keys$' -- tests/shell/compute_concurrency_batches_cli.bats
EXIT_CODE: 0
Output Summary: tests/shell/compute_concurrency_batches_cli.bats:1 (expected 1; match; the P1-T6 run line)

## Block 6

Timestamp: 2026-10-12T12-55
Command: git grep --no-index -c -E -e '^    run bash "\$BATCHES" --keys "1 2" --max-concurrency$' -- tests/shell/compute_concurrency_batches_cli.bats
EXIT_CODE: 0
Output Summary: tests/shell/compute_concurrency_batches_cli.bats:1 (expected 1; match; the P1-T7 run line)

## Block 7

Timestamp: 2026-10-12T12-55
Command: git grep --no-index -c -E -e '^' -- tests/shell/compute_concurrency_batches_cli.bats
EXIT_CODE: 0
Output Summary: tests/shell/compute_concurrency_batches_cli.bats:50 (line count 50, below the 500-line limit)

## Result

Every printed count matches the expected value and the line count is below 500. The `mktemp` check is recorded separately in bats-file-no-temp-file-check.2026-10-12T12-55.md.
