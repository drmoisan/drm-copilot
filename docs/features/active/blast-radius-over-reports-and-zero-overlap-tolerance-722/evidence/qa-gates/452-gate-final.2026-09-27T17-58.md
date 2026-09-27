# #452 Re-gate, Final (P14-T3)

Timestamp: 2026-09-27T17-58
Command: poetry run pytest -v <the ten B1 node IDs> ; sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1
EXIT_CODE: 0
Output Summary: PASS. Run on the merged tree (HEAD 4dc5d488945ff59fb3ebbc67312b7bb87491072f, FINAL_BASE beae3f021674e64fa6662097fe48a332d8da62b8), fixtures unmodified. P14-T2 recorded no gate fixture outside the five B1 fixtures, so the P0-T21 command is extended by zero node IDs (added node IDs: none) and runs as the ten B1 node IDs; it exited 0 with "10 passed" and one PASSED line per node. The #452 Pester gate form of the Terms (one unfiltered pester-counts run over the parity file, substituting for the per-fixture filter of P0-T22, which selects 0 tests under Pester 5.6.1) printed TotalCount=80, PassedCount=80, FailedCount=0, zero result lines beginning "[-]" after ANSI colour codes were removed, and exactly two "[+]" result lines ending " for F" for each of the five gate fixtures recorded by P14-T2. Both commands exited 0.

## Substitute recorded

The per-fixture -FullNameFilter form of P0-T22 is replaced by the #452 Pester gate form defined in the
Terms (revision round 5): one run of script pester-counts (A2) over
tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 with no -FullNameFilter.

Added node IDs (gate fixtures not among the five B1 fixtures): none.

## Python driver

Command: poetry run pytest -v tests/scripts/dev_tools/test_blast_radius_parity.py::test_conflict_fixture_reproduces_the_expected_verdict[conflict-directory-vs-glob] ... (ten B1 node IDs, no additions)
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

Passing result lines attributed to the gate fixtures (ANSI removed):

```text
   [+] reproduces the expected radius for derivation-root-surface-not-configured 8ms (7ms|1ms)
   [+] reproduces the expected radius for derivation-root-surface-reached 7ms (7ms|1ms)
   [+] reproduces the expected findings for derivation-root-surface-not-configured 10ms (9ms|1ms)
   [+] reproduces the expected findings for derivation-root-surface-reached 10ms (9ms|0ms)
   [+] reproduces the expected verdict for conflict-directory-vs-file 4ms (4ms|0ms)
   [+] reproduces the expected verdict for conflict-directory-vs-glob 4ms (4ms|0ms)
   [+] reproduces the expected verdict for conflict-sibling-prefix-disjoint 3ms (3ms|0ms)
   [+] reproduces the expected reasons for conflict-directory-vs-file 4ms (3ms|0ms)
   [+] reproduces the expected reasons for conflict-directory-vs-glob 4ms (4ms|0ms)
   [+] reproduces the expected reasons for conflict-sibling-prefix-disjoint 3ms (3ms|0ms)
```

| Gate fixture F (P14-T2) | "[+]" lines ending " for F" | Cases |
| --- | --- | --- |
| conflict-directory-vs-glob | 2 | verdict, reasons |
| conflict-directory-vs-file | 2 | verdict, reasons |
| conflict-sibling-prefix-disjoint | 2 | verdict, reasons |
| derivation-root-surface-reached | 2 | radius, findings |
| derivation-root-surface-not-configured | 2 | radius, findings |

SCRATCH denotes the executor session scratchpad directory (outside the repository).
