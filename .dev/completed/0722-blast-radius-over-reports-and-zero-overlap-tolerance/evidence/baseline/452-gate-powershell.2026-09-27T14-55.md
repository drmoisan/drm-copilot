# #452 Detection Gate, PowerShell Driver (P0-T22)

Timestamp: 2026-09-27T14-55
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 -FullNameFilter "*<fixture>*" (five runs, one per P0-T20 branch fixture) ; sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 (one unfiltered run, detailed output)
EXIT_CODE: 0
Output Summary: The five filtered runs as written each exited 0 but selected 0 of 80 tests (PassedCount=0, FailedCount=0), because Pester 5.6.1 applies the FullName filter to the unexpanded It name, which carries the FixtureName template rather than the fixture name. The unfiltered run of the same file with the same script exited 0 with TotalCount=80, PassedCount=80, FailedCount=0, and its detailed output shows exactly two passing cases per #452 fixture (verdict and reasons for each conflict fixture; radius and findings for each derivation fixture) and zero failing lines. The fixtures were run unmodified.

## Deviation from the written acceptance (recorded for plan revision)

The written acceptance is "every run prints PassedCount=2 and FailedCount=0". With the written filter
that line cannot be printed by any run: Pester 5.6.1 evaluates Filter.FullName against the
unexpanded test path, for example

```text
Blast-radius contention parity.Conflict verdict.reproduces the expected verdict for <FixtureName>
```

so a pattern built from a fixture name never matches. The outcome the gate asserts (both parity cases
of every #452 fixture pass under the PowerShell detection driver, with no failure) was instead
observed from the per-test result lines of one unfiltered run of the same planned script over the
same test file. P14-T3 re-uses this filter form and will select 0 tests in the same way; a plan
revision should replace the per-fixture FullName filter for both tasks.

## Filtered runs as written (each exit 0)

| Fixture | Filter | Tests selected | TotalCount | PassedCount | FailedCount |
| --- | --- | --- | --- | --- | --- |
| conflict-directory-vs-glob | *conflict-directory-vs-glob* | 0 | 80 | 0 | 0 |
| conflict-directory-vs-file | *conflict-directory-vs-file* | 0 | 80 | 0 | 0 |
| conflict-sibling-prefix-disjoint | *conflict-sibling-prefix-disjoint* | 0 | 80 | 0 | 0 |
| derivation-root-surface-not-configured | *derivation-root-surface-not-configured* | 0 | 80 | 0 | 0 |
| derivation-root-surface-reached | *derivation-root-surface-reached* | 0 | 80 | 0 | 0 |

Representative Pester output of a filtered run:

```text
Discovery found 80 tests in 171ms.
Filter 'FullName' set to ('*conflict-directory-vs-glob*').
Filters selected 0 tests to run.
Tests Passed: 0, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 80
TotalCount=80
PassedCount=0
FailedCount=0
```

## Unfiltered run: per-fixture result lines (verbatim, colour codes removed)

```text
[+] reproduces the expected radius for derivation-root-surface-not-configured
[+] reproduces the expected radius for derivation-root-surface-reached
[+] reproduces the expected findings for derivation-root-surface-not-configured
[+] reproduces the expected findings for derivation-root-surface-reached
[+] reproduces the expected verdict for conflict-directory-vs-file
[+] reproduces the expected verdict for conflict-directory-vs-glob
[+] reproduces the expected verdict for conflict-sibling-prefix-disjoint
[+] reproduces the expected reasons for conflict-directory-vs-file
[+] reproduces the expected reasons for conflict-directory-vs-glob
[+] reproduces the expected reasons for conflict-sibling-prefix-disjoint
Tests Passed: 80, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
TotalCount=80
PassedCount=80
FailedCount=0
```

A search of the full detailed log for the failing-test marker "[-]" returned a count of 0.

## Per-fixture tally from the unfiltered run

| Fixture | Cases passed | Cases failed |
| --- | --- | --- |
| conflict-directory-vs-glob | 2 (verdict, reasons) | 0 |
| conflict-directory-vs-file | 2 (verdict, reasons) | 0 |
| conflict-sibling-prefix-disjoint | 2 (verdict, reasons) | 0 |
| derivation-root-surface-reached | 2 (radius, findings) | 0 |
| derivation-root-surface-not-configured | 2 (radius, findings) | 0 |
