# #452 Pester Gate Form (Remediation Cycle 1, P2-T6)

Timestamp: 2026-09-27T20-17
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1
EXIT_CODE: 0

No -FullNameFilter was passed (the #452 Pester gate form of the main plan's Terms).

## Summary lines (verbatim)

```text
TotalCount=80
PassedCount=80
FailedCount=0
```

Result lines whose first non-whitespace text after ANSI removal is "[-]": 0 (grep -c).

## "[+]" result lines for the five gate fixtures (ANSI colour codes removed)

```text
   [+] reproduces the expected radius for derivation-root-surface-not-configured 8ms (7ms|1ms)
   [+] reproduces the expected radius for derivation-root-surface-reached 7ms (7ms|0ms)
   [+] reproduces the expected findings for derivation-root-surface-not-configured 10ms (9ms|1ms)
   [+] reproduces the expected findings for derivation-root-surface-reached 10ms (10ms|0ms)
   [+] reproduces the expected verdict for conflict-directory-vs-file 5ms (4ms|0ms)
   [+] reproduces the expected verdict for conflict-directory-vs-glob 5ms (4ms|0ms)
   [+] reproduces the expected verdict for conflict-sibling-prefix-disjoint 3ms (3ms|0ms)
   [+] reproduces the expected reasons for conflict-directory-vs-file 4ms (3ms|0ms)
   [+] reproduces the expected reasons for conflict-directory-vs-glob 4ms (4ms|0ms)
   [+] reproduces the expected reasons for conflict-sibling-prefix-disjoint 4ms (3ms|0ms)
```

| Fixture | "[+]" lines ending " for F" |
| --- | --- |
| conflict-directory-vs-glob | 2 (verdict, reasons) |
| conflict-directory-vs-file | 2 (verdict, reasons) |
| conflict-sibling-prefix-disjoint | 2 (verdict, reasons) |
| derivation-root-surface-reached | 2 (radius, findings) |
| derivation-root-surface-not-configured | 2 (radius, findings) |

Output Summary: PASS. TotalCount=80, FailedCount=0, zero "[-]" result lines, and exactly two "[+]" result lines for each of the five gate fixtures.
