# Pester isolation fixes (#1048, P7-T5)

Timestamp: 2026-10-31T19-51
Command: review of the P7-T3 concurrent and serial runs and the P7-T4 seeded shuffled runs (seeds 1048, 20261031, 7)
EXIT_CODE: 0
Output Summary:
NONE FOUND

- The concurrent run (8 shard processes) and the serial run both finished with 13643 tests, 0 failures, and 0 errors; the three seeded shuffled runs of the touched suites each finished with 242 tests and 0 failures. No test leaked state into another test file or depended on prior state, so no leaker or victim fix was needed and no re-run was required.
- The one defect the concurrent run exposed was in the new runner, not in a test: the default wait seam looked up an already-exited shard process by id. It was fixed in `PoshQC.Parallel.psm1` during P7-T3 (deviation D5), and the concurrent run was repeated with exit code 0.
- No ordering, file exclusion, or shard pinning was used.
