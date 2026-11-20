# Structural Guard Against Four Modules - Issue 1019, Remediation Cycle 1

Timestamp: 2026-11-06T20-57
Command: sh SCRATCH/issue-1019-rc1-p2-t3.sh (timeout 165 pwsh -NoProfile -File SCRATCH/issue-1019-guard-driver.ps1 -Root <worktree> -Scratch SCRATCH; rebuilds SCRATCH/fixed-tree from the final .claude/lib, builds SCRATCH/mutant-tree with the four asserted replacements, copies the final SUITE into each of the four trees, and SCRATCH/issue-1019-guard-child.ps1 runs only the guard describe from each tree in its own process, through Filter.FullName and a result object)
EXIT_CODE: 0
Output Summary: The observed matrix equals the expected matrix, with 0 mismatches. The guard describe has at least one failing case on unfixed (2 failed), candidate (1 failed), and mutant (2 failed), and none on fixed (3 passed). git status --porcelain is empty for MODULE, BUNDLE, and SUITE before and after the driver. Final MODULE hash 015c38363874b798b35ea2afae62c276f346199047337890e661d84927d77702. The driver exits 0 only when the observed matrix equals the expected one, so this artifact carries no `ExpectedExitCode:`. The failing cases are the expected outcome for this `[expect-fail]` task. The mutant stays under SCRATCH.

## Matrix

| Case | Unfixed | Candidate | Fixed | Mutant |
| --- | --- | --- | --- | --- |
| `passes no source text variable to a .NET method inside a loop` | Failed (expected Failed) | Passed (expected Passed) | Passed (expected Passed) | Passed (expected Passed) |
| `assigns the lexing window only from a Substring of the source text` | Failed (expected Failed) | Failed (expected Failed) | Passed (expected Passed) | Failed (expected Failed) |
| `passes only the lexing window to Match inside the token loop` | Passed (expected Passed) | Passed (expected Passed) | Passed (expected Passed) | Failed (expected Failed) |

## Module Under Each Tree

| Tree | Module SHA-256 | Passed | Failed | Not run (outside the filter) |
| --- | --- | --- | --- | --- |
| `SCRATCH/unfixed` | `4ec8d9c5006a7ad2648a87cbba9a7f42136330cda94c9704b5ff980b68dbab53` | 1 | 2 | 54 |
| `SCRATCH/candidate-tree` | `7fcca693045a6bea1a6c7f2145314a3e512389b24e04fe79386ad77bf08374b9` | 2 | 1 | 54 |
| `SCRATCH/fixed-tree` | `015c38363874b798b35ea2afae62c276f346199047337890e661d84927d77702` | 3 | 0 | 54 |
| `SCRATCH/mutant-tree` | `d8c20dbc4d47841a513fa588afb3b339f7b29687c9e4bb753428b8f878a6cd15` | 1 | 2 | 54 |

## Mutant Replacements (occurrence counts asserted by the driver)

| Replacement | Observed | Expected |
| --- | --- | --- |
| First `$source` assignment to `$sourceText.Substring(0)` | 1 | 1 |
| Rebase `$source` assignments to `$sourceText.Substring($windowStart)` | 2 | 2 |
| `Match` call to `$script:DocsPythonTokenPattern.Match($sourceText.Substring($windowStart), $position)` | 1 | 1 |

## Failure Messages

Unfixed, `passes no source text variable to a .NET method inside a loop`:

```text
Expected $null or empty, because a call in a loop must not receive the source text as an argument, but got @('[string]::CompareOrdinal($Text, $index, $Quote, 0, $Quote.Length)', '[string]::CompareOrdinal($Text, $index, [string] $character * 3, 0, 3)').
```

Unfixed and candidate, `assigns the lexing window only from a Substring of the source text` (the same message on both trees):

```text
Expected $null or empty, because the window must always be a slice of the source text bounded by [math]::Min($windowSize, ...), but got '$source = $lines -join "`n"'.
```

Mutant, `assigns the lexing window only from a Substring of the source text`, naming all three assignments:

```text
Expected $null or empty, because the window must always be a slice of the source text bounded by [math]::Min($windowSize, ...), but got @('$source = $sourceText.Substring(0)', '$source = $sourceText.Substring($windowStart)', '$source = $sourceText.Substring($windowStart)').
```

Mutant, `passes only the lexing window to Match inside the token loop`:

```text
Expected $null or empty, because Match inside the token loop must receive the bounded window $source as its first argument, but got '$script:DocsPythonTokenPattern.Match($sourceText.Substring($windowStart), $position)'.
```

## Porcelain

`git status --porcelain` for MODULE, BUNDLE, and SUITE: empty before, empty after, unchanged True.

## Interrupted Earlier Run

The run stopped by the owner reboot left no artifact. Its `fixed-tree` subdirectory times advance from 14:43:57 to 15:06:20 local time, so its recursive copy of `.claude/lib` from the worktree took about 22 minutes, while its copy from `fixed-tree` to `mutant-tree` took about 2 seconds. This run measured a 0.94 s copy of 172 files from the worktree, and the driver finished all four trees in about 10 seconds. The earlier delay did not reproduce and its cause is unknown. The driver change for this run adds step time lines and a launcher bound of 165 s; the asserted matrix and tree contents are unchanged.
