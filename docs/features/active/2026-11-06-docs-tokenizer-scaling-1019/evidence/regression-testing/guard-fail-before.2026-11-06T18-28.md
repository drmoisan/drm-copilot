# Structural Guard Against Three Modules - Issue 1019

Timestamp: 2026-11-06T18-28
Command: pwsh -NoProfile -File SCRATCH/issue-1019-guard-driver.ps1 -Root <worktree> -Scratch SCRATCH (copies the final SUITE into SCRATCH/unfixed, SCRATCH/candidate-tree, and SCRATCH/fixed-tree; SCRATCH/issue-1019-guard-child.ps1 runs only the guard describe from each copy in its own process, through Filter.FullName and a result object)
EXIT_CODE: 0
Output Summary: The observed matrix equals the expected matrix, with 0 mismatches. The guard describe has at least one failing case on unfixed (2 failed) and on candidate (1 failed) and none on fixed (2 passed). git status --porcelain is empty for MODULE, BUNDLE, and SUITE before and after. MODULE hash 6010cf357e5816136cf60b8d0e7dcf52f85555c42c7ec37b7e65883493ab9cbf.

The driver exits 0 only when the observed matrix equals the expected one, so this artifact carries no `ExpectedExitCode:`. The failing test cases are the expected outcome for this `[expect-fail]` task.

## Matrix

| Case | Unfixed | Candidate | Fixed |
| --- | --- | --- | --- |
| `passes no source text variable to a .NET method inside a loop` | Failed (expected Failed) | Passed (expected Passed) | Passed (expected Passed) |
| `assigns the lexing window only from a Substring of the source text` | Failed (expected Failed) | Failed (expected Failed) | Passed (expected Passed) |

## Module Under Each Tree

| Tree | Module SHA-256 | Passed | Failed | Not run (outside the filter) |
| --- | --- | --- | --- | --- |
| `SCRATCH/unfixed` | `4ec8d9c5006a7ad2648a87cbba9a7f42136330cda94c9704b5ff980b68dbab53` | 0 | 2 | 54 |
| `SCRATCH/candidate-tree` | `7fcca693045a6bea1a6c7f2145314a3e512389b24e04fe79386ad77bf08374b9` | 1 | 1 | 54 |
| `SCRATCH/fixed-tree` | `6010cf357e5816136cf60b8d0e7dcf52f85555c42c7ec37b7e65883493ab9cbf` | 2 | 0 | 54 |

## Failure Messages

Unfixed, `passes no source text variable to a .NET method inside a loop`:

```text
Expected $null or empty, because a call in a loop must not receive the source text as an argument, but got @('[string]::CompareOrdinal($Text, $index, $Quote, 0, $Quote.Length)', '[string]::CompareOrdinal($Text, $index, [string] $character * 3, 0, 3)').
```

Unfixed, `assigns the lexing window only from a Substring of the source text`:

```text
Expected $null or empty, because the window must always be a slice of the source text, but got '$source = $lines -join "`n"'.
```

Candidate, `assigns the lexing window only from a Substring of the source text`:

```text
Expected $null or empty, because the window must always be a slice of the source text, but got '$source = $lines -join "`n"'.
```
