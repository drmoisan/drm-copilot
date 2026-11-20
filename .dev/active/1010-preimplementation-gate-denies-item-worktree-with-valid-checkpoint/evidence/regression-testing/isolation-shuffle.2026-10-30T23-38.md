# Isolation: Seeded Shuffled File-Order Pester Runs, Re-run (Issue #1010, remediation cycle 1, P3-T9)

Timestamp: 2026-10-30T23-38
Command: sh SCRATCH/issue-1010-pt.sh issue-1010-r1-suites.txt -NoCoverage -Seed <seed> (Invoke-PoshQCTest in one process per seed over the 18 touched suites; file order is a System.Random(<seed>) shuffle of the touched-suite list; counts read from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: Re-run after the loop-pass-4 test edits (B10 labels, F1 suite path construction). Three seeds (1010, 20261030, 737), each 1353 tests, 1353 passed, 0 failed. No order dependence was found.

The shuffle is a deterministic function of the seed and the unchanged suite list, so the file order for each seed is the same as recorded in `isolation-shuffle.2026-10-30T22-32.md`.
