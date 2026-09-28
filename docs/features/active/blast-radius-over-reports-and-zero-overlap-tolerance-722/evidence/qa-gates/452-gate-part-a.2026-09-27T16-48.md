# #452 Gate Re-run, Part A (P7-T4)

Timestamp: 2026-09-27T16-48
Command: poetry run pytest -v <the ten B1 node IDs> ; sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1
EXIT_CODE: 0
Output Summary: PASS. The P0-T21 command, run unmodified, exited 0 with "10 passed" and one PASSED line per B1 node ID. The #452 Pester gate form of the Terms (one unfiltered pester-counts run over the parity file) printed TotalCount=80, PassedCount=80, FailedCount=0, no result line beginning "[-]" after ANSI colour codes were removed, and exactly two passing "[+]" result lines ending " for F" for each of the five fixtures of P0-T20's branch list: verdict and reasons for conflict-directory-vs-glob, conflict-directory-vs-file, and conflict-sibling-prefix-disjoint; radius and findings for derivation-root-surface-reached and derivation-root-surface-not-configured. Both commands exited 0.

## Python driver (P0-T21 command, unmodified)

Command: poetry run pytest -v tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_verdict[conflict-directory-vs-glob] ... (ten B1 node IDs)
EXIT_CODE: 0

```text
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_verdict[conflict-directory-vs-glob] PASSED [ 10%]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_verdict[conflict-directory-vs-file] PASSED [ 20%]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_verdict[conflict-sibling-prefix-disjoint] PASSED [ 30%]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_reasons[conflict-directory-vs-glob] PASSED [ 40%]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_reasons[conflict-directory-vs-file] PASSED [ 50%]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_reasons[conflict-sibling-prefix-disjoint] PASSED [ 60%]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_derivation_fixture_reproduces_the_expected_radius[derivation-root-surface-reached] PASSED [ 70%]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_derivation_fixture_reproduces_the_expected_radius[derivation-root-surface-not-configured] PASSED [ 80%]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_derivation_fixture_reproduces_the_expected_findings[derivation-root-surface-reached] PASSED [ 90%]
tests/scripts/dev_tools/test_blast_radius_parity.py::test_derivation_fixture_reproduces_the_expected_findings[derivation-root-surface-not-configured] PASSED [100%]
============================= 10 passed in 0.09s ==============================
```

## PowerShell driver (#452 Pester gate form, no -FullNameFilter)

Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1
EXIT_CODE: 0

```text
TotalCount=80
PassedCount=80
FailedCount=0
```

Result lines beginning "[-]" (after ANSI removal): 0.

Passing result lines attributed to the five #452 fixtures (ANSI removed):

```text
   [+] reproduces the expected radius for derivation-root-surface-not-configured 7ms (6ms|0ms)
   [+] reproduces the expected radius for derivation-root-surface-reached 8ms (8ms|0ms)
   [+] reproduces the expected findings for derivation-root-surface-not-configured 11ms (10ms|1ms)
   [+] reproduces the expected findings for derivation-root-surface-reached 12ms (11ms|0ms)
   [+] reproduces the expected verdict for conflict-directory-vs-file 4ms (4ms|0ms)
   [+] reproduces the expected verdict for conflict-directory-vs-glob 4ms (4ms|0ms)
   [+] reproduces the expected verdict for conflict-sibling-prefix-disjoint 3ms (3ms|0ms)
   [+] reproduces the expected reasons for conflict-directory-vs-file 4ms (3ms|0ms)
   [+] reproduces the expected reasons for conflict-directory-vs-glob 4ms (4ms|0ms)
   [+] reproduces the expected reasons for conflict-sibling-prefix-disjoint 4ms (3ms|0ms)
```

| Fixture F | Passing lines ending " for F" | Cases |
| --- | --- | --- |
| conflict-directory-vs-glob | 2 | verdict, reasons |
| conflict-directory-vs-file | 2 | verdict, reasons |
| conflict-sibling-prefix-disjoint | 2 | verdict, reasons |
| derivation-root-surface-reached | 2 | radius, findings |
| derivation-root-surface-not-configured | 2 | radius, findings |

SCRATCH denotes the executor session scratchpad directory (outside the repository).
