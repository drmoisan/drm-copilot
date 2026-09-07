# Phase 1 gate — Pester key partition and truth-table shape (issue #643, task [P1-T10])

- Timestamp: 2026-09-07T15:47Z
- Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1, tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 -Output Detailed"` (run from the worktree root)
- EXIT_CODE: 0

## Output Summary

Result line (verbatim, ANSI colour codes stripped):

```text
Tests Passed: 22, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
```

`Failed: 0` is reported.

The two cases the acceptance condition names appear in the detailed output as passed:

```text
   [+] declares mergeable_paths as a list of non-empty strings 25ms (24ms|1ms)
   [+] requires every top-level key in both copies to be classified and shared 6ms (5ms|1ms)
```

The first is the shape case added by [P1-T5] and asserts the five entries, in order, in both
committed copies. The second is the exhaustiveness case, which now covers the new key through the
`$script:ClassOneKeys` extension made by [P1-T4].
