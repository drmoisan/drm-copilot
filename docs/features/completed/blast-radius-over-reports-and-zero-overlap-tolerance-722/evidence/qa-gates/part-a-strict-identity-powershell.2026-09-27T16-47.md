# Part A Strict Identity and #452 Cases, PowerShell (P7-T2)

Timestamp: 2026-09-27T16-47
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1 -FullNameFilter <filter> (one run per B29 filter; six runs)
EXIT_CODE: 0
Output Summary: PASS. All six runs exited 0 and printed FailedCount=0 with a PassedCount of at least 1: the five scheduling-fixture filters each selected and passed 1 test, and the "matches detection at tolerance 0" filter selected and passed 15 tests (one per existing conflict fixture). TotalCount=50 is the discovered test count of the file; filtered-out tests are not run. The fixture It names are interpolated per case at discovery (not Pester templates), so the FullName filter selects them.

## Results per filter

| Filter (block B29) | TotalCount | PassedCount | FailedCount |
| --- | --- | --- | --- |
| *scheduling-452-shared-surface-hard* | 50 | 1 | 0 |
| *scheduling-452-directory-prefix-weighted* | 50 | 1 | 0 |
| *scheduling-452-negative-controls* | 50 | 1 | 0 |
| *scheduling-soft-pair-tolerated* | 50 | 1 | 0 |
| *scheduling-absent-key-strict* | 50 | 1 | 0 |
| *matches detection at tolerance 0* | 50 | 15 | 0 |

## Passing lines (ANSI colour codes removed; durations omitted)

```text
[run 1] [+] reproduces the expected decisions for scheduling-452-shared-surface-hard
[run 2] [+] reproduces the expected decisions for scheduling-452-directory-prefix-weighted
[run 3] [+] reproduces the expected decisions for scheduling-452-negative-controls
[run 4] [+] reproduces the expected decisions for scheduling-soft-pair-tolerated
[run 5] [+] reproduces the expected decisions for scheduling-absent-key-strict
[run 6] [+] matches detection at tolerance 0 for conflict-contract
[run 6] [+] matches detection at tolerance 0 for conflict-directory-vs-file
[run 6] [+] matches detection at tolerance 0 for conflict-directory-vs-glob
[run 6] [+] matches detection at tolerance 0 for conflict-empty-vs-empty
[run 6] [+] matches detection at tolerance 0 for conflict-empty-vs-nonempty
[run 6] [+] matches detection at tolerance 0 for conflict-glob-concrete
[run 6] [+] matches detection at tolerance 0 for conflict-glob-undecidable
[run 6] [+] matches detection at tolerance 0 for conflict-mergeable-csproj-no-edge
[run 6] [+] matches detection at tolerance 0 for conflict-mergeable-glob-still-contends
[run 6] [+] matches detection at tolerance 0 for conflict-module-overlap
[run 6] [+] matches detection at tolerance 0 for conflict-multi-reason
[run 6] [+] matches detection at tolerance 0 for conflict-none-disjoint
[run 6] [+] matches detection at tolerance 0 for conflict-path-overlap
[run 6] [+] matches detection at tolerance 0 for conflict-shared-surface
[run 6] [+] matches detection at tolerance 0 for conflict-sibling-prefix-disjoint
```

No run printed a FAILED: line or a "[-]" result line.

SCRATCH denotes the executor session scratchpad directory (outside the repository).
