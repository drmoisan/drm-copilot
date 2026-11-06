# Guard Fail-Before Matrix - Issue 1019, Remediation Cycle 2

Timestamp: 2026-11-06T21-55
Command: sh SCRATCH/issue-1019-rc1-p2-t3.sh (SCRATCH/issue-1019-guard-driver.ps1 -Root WORKTREE -Scratch SCRATCH, one SCRATCH/issue-1019-guard-child.ps1 process per tree, Pester filter on the guard describe, counts and messages from the result object)
EXIT_CODE: 0
Output Summary: Driver exit 0, matrix mismatches 0. Six trees, four guard cases each, not-run 54 on every tree. Every tree except fixed has at least one failing case; fixed passes 4 and fails 0. mutant-r1 fails only the window size case, naming 1073741824. mutant-r2 fails only the lexing window case, naming the typed assignment. All replacements matched their asserted occurrence counts. git status --porcelain for MODULE, BUNDLE, and SUITE is the same (empty) before and after the driver.

## Observed Matrix

F is Failed and P is Passed. Observed values equal the expected matrix in `[P2-T2]`.

| Case | unfixed | candidate | fixed | mutant | mutant-r1 | mutant-r2 |
| --- | --- | --- | --- | --- | --- | --- |
| `passes no source text variable to a .NET method inside a loop` | F | P | P | P | P | P |
| `assigns the lexing window only from a Substring of the source text` | F | F | P | F | P | F |
| `passes only the lexing window to Match inside the token loop` | P | P | P | F | P | P |
| `assigns the window size once at module scope from an integer literal no greater than 65536` | F | F | P | P | F | P |
| Passed, Failed | 1, 3 | 2, 2 | 4, 0 | 2, 2 | 3, 1 | 3, 1 |

## Trees

| Tree | Module SHA-256 | Passed | Failed | Not run |
| --- | --- | --- | --- | --- |
| `SCRATCH/unfixed` | `4ec8d9c5006a7ad2648a87cbba9a7f42136330cda94c9704b5ff980b68dbab53` | 1 | 3 | 54 |
| `SCRATCH/candidate-tree` | `7fcca693045a6bea1a6c7f2145314a3e512389b24e04fe79386ad77bf08374b9` | 2 | 2 | 54 |
| `SCRATCH/fixed-tree` | `015c38363874b798b35ea2afae62c276f346199047337890e661d84927d77702` (`MODULE HASH`) | 4 | 0 | 54 |
| `SCRATCH/mutant-tree` | `d8c20dbc4d47841a513fa588afb3b339f7b29687c9e4bb753428b8f878a6cd15` | 2 | 2 | 54 |
| `SCRATCH/mutant-r1-tree` | `bb8cfed559d60cf95e4016264ab4b4ad56aff144b2de96ad6ecfb99abd434d0c` | 3 | 1 | 54 |
| `SCRATCH/mutant-r2-tree` | `0f2ea31a494025e0a50698396454bb89f4c1829db749f534d5dc37538385b371` | 3 | 1 | 54 |

## Mutations

| Tree | Replacement | Occurrences found | Expected |
| --- | --- | --- | --- |
| `mutant-tree` | first window assignment | 1 | 1 |
| `mutant-tree` | rebase window assignments | 2 | 2 |
| `mutant-tree` | `Match` call in the token loop | 1 | 1 |
| `mutant-r1-tree` | window size declaration, set to 1073741824 | 1 | 1 |
| `mutant-r2-tree` | string rebase assignment, the last of the two, set to `[string] $source = $sourceText.Substring($windowStart)` | 2 | 2 |

## Failure Messages

- unfixed, `passes no source text variable to a .NET method inside a loop`: Expected $null or empty, because a call in a loop must not receive the source text as an argument, but got @('[string]::CompareOrdinal($Text, $index, $Quote, 0, $Quote.Length)', '[string]::CompareOrdinal($Text, $index, [string] $character * 3, 0, 3)').
- unfixed, `assigns the lexing window only from a Substring of the source text`: Expected $null or empty, because the window must always be a slice of the source text bounded by [math]::Min($windowSize, ...), but got '$source = $lines -join "`n"'.
- unfixed, `assigns the window size once at module scope from an integer literal no greater than 65536`: Expected 1, because the window size must be assigned exactly once, but got 0.
- candidate-tree, `assigns the lexing window only from a Substring of the source text`: Expected $null or empty, because the window must always be a slice of the source text bounded by [math]::Min($windowSize, ...), but got '$source = $lines -join "`n"'.
- candidate-tree, `assigns the window size once at module scope from an integer literal no greater than 65536`: Expected 1, because the window size must be assigned exactly once, but got 0.
- mutant-tree, `assigns the lexing window only from a Substring of the source text`: Expected $null or empty, because the window must always be a slice of the source text bounded by [math]::Min($windowSize, ...), but got @('$source = $sourceText.Substring(0)', '$source = $sourceText.Substring($windowStart)', '$source = $sourceText.Substring($windowStart)').
- mutant-tree, `passes only the lexing window to Match inside the token loop`: Expected $null or empty, because Match inside the token loop must receive the bounded window $source as its first argument, but got '$script:DocsPythonTokenPattern.Match($sourceText.Substring($windowStart), $position)'.
- mutant-r1-tree, `assigns the window size once at module scope from an integer literal no greater than 65536`: Expected the actual value to be less than or equal to 65536, because a larger window restores whole-remainder Match calls on a string-heavy source, but got 1073741824.
- mutant-r2-tree, `assigns the lexing window only from a Substring of the source text`: Expected $null or empty, because the window must always be a slice of the source text bounded by [math]::Min($windowSize, ...), but got '[string] $source = $sourceText.Substring($windowStart)'.

## Prior Result Cited

The `size-constant-huge` and `typed-evasion` rows of `policy-audit.2026-11-06T21-29.md` record that these same two mutations passed 57 of 57 on the prior `SUITE`. On the final `SUITE` each now fails its case: `SCRATCH/mutant-r1-tree` is the fail-before tree for R1 and `SCRATCH/mutant-r2-tree` is the fail-before tree for R2.

## Tree Porcelain

`git status --porcelain` for `MODULE`, `BUNDLE`, and `SUITE` is empty before and after the driver. The mutants stay under `SCRATCH`.
