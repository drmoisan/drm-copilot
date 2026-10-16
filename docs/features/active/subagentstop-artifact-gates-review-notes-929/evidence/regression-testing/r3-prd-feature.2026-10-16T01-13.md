# R3 Rows: prd-feature Suite (P1-T6)

Timestamp: 2026-10-16T01-13

Command: sh SCRATCH/issue-929/P1-T6-1.sh
Script: `Import-Module Pester -MinimumVersion 5.0.0; $r = Invoke-Pester -Path 'tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1' -PassThru -Output None; $r.Tests | ForEach-Object { '{0} | {1}' -f $_.Result, $_.ExpandedName }; 'FAILED=' + $r.FailedCount; 'FAILED_BLOCKS=' + $r.FailedBlocksCount; 'FAILED_CONTAINERS=' + $r.FailedContainersCount; 'PASSED=' + $r.PassedCount; exit [int]($r.FailedCount + $r.FailedBlocksCount + $r.FailedContainersCount)`
EXIT_CODE: 0

Output Summary: `FAILED=0`, `FAILED_BLOCKS=0`, `FAILED_CONTAINERS=0`, `PASSED=55`. Each of the 17 required lines is present as a complete line (verified with a whole-line fixed-string comparison against the list below; no line missing) (AC-01, AC-03):
- Passed | R3 accepts the exhaustive scope entire worktree
- Passed | R3 accepts the exhaustive scope whole worktree with all directories
- Passed | R3 accepts the exhaustive scope entire repository accepted before R3
- Passed | R3 accepts the exhaustive scope complete source tree
- Passed | R3 accepts the exhaustive scope whole repo
- Passed | R3 accepts the exhaustive scope upper-case entire worktree
- Passed | R3 accepts the exhaustive scope entire worktree root
- Passed | R3 accepts the exhaustive scope whole repository excluding docs
- Passed | R3 accepts the exhaustive scope NB-2 whole worktree restricted to code
- Passed | R3 accepts the exhaustive scope NB-2 entire repository excluding docs
- Passed | R3 rejects the exhaustive scope the hooks folder
- Passed | R3 rejects the exhaustive scope noun without a quantifier
- Passed | R3 rejects the exhaustive scope quantifier without a noun
- Passed | R3 rejects the exhaustive scope path-shaped value
- Passed | R3 rejects the exhaustive scope all inside allocated
- Passed | R3 rejects the exhaustive scope tree inside subtree
- Passed | R3 rejects the exhaustive scope worktree inside worktrees

Full output:
```
Passed | allows a spec without numeric acceptance criteria
Passed | detects a numeric spec acceptance criterion
Passed | does not count numeric boxes outside Acceptance Criteria
Passed | rejects a numeric claim without a complete research record
Passed | rejects a research record whose independent cross-check disagrees
Passed | accepts an independently exhaustive complete-family research record
Passed | rejects an invalid envelope and a blank assistant message
Passed | rejects missing and nonexistent spec paths
Passed | accepts a nonnumeric spec without research evidence
Passed | rejects numeric specs with missing or nonexistent research paths
Passed | accepts matching numeric provenance and extracts artifact labels
Passed | rejects every missing numeric-evidence field and a missing section
Passed | rejects copied-count, duplicate-search, member-set, scope, and narrow-pattern records
Passed | R2 triggers on all with a digit cardinal
Passed | R2 triggers on all with a word cardinal
Passed | R2 triggers on exactly with a digit cardinal
Passed | R2 triggers on exactly with a word cardinal
Passed | R2 triggers on the with a digit cardinal
Passed | R2 triggers on the with a word cardinal
Passed | R2 triggers on these with a digit cardinal
Passed | R2 triggers on these with a word cardinal
Passed | R2 triggers on those with a digit cardinal
Passed | R2 triggers on those with a word cardinal
Passed | R2 does not trigger on a threshold
Passed | R2 does not trigger on a comparator
Passed | R2 does not trigger on an exit code
Passed | R2 does not trigger on an issue or PR number
Passed | R2 does not trigger on a line number or file:line
Passed | R2 does not trigger on an AC or task identifier
Passed | R2 does not trigger on a version
Passed | R2 does not trigger on a date or timestamp
Passed | R2 does not trigger on a section reference
Passed | R2 does not trigger on zero
Passed | R2 does not trigger on a unit of size or duration
Passed | R2 does not trigger on a count citing .claude/rules/
Passed | R2 does not trigger on a count citing .github/instructions/
Passed | R2 does not trigger on a count citing .github/copilot-instructions.md
Passed | R2 does not trigger on a non-noun word after the cardinal
Passed | R3 accepts the exhaustive scope entire worktree
Passed | R3 accepts the exhaustive scope whole worktree with all directories
Passed | R3 accepts the exhaustive scope entire repository accepted before R3
Passed | R3 accepts the exhaustive scope complete source tree
Passed | R3 accepts the exhaustive scope whole repo
Passed | R3 accepts the exhaustive scope upper-case entire worktree
Passed | R3 accepts the exhaustive scope entire worktree root
Passed | R3 accepts the exhaustive scope whole repository excluding docs
Passed | R3 accepts the exhaustive scope NB-2 whole worktree restricted to code
Passed | R3 accepts the exhaustive scope NB-2 entire repository excluding docs
Passed | R3 rejects the exhaustive scope the hooks folder
Passed | R3 rejects the exhaustive scope noun without a quantifier
Passed | R3 rejects the exhaustive scope quantifier without a noun
Passed | R3 rejects the exhaustive scope path-shaped value
Passed | R3 rejects the exhaustive scope all inside allocated
Passed | R3 rejects the exhaustive scope tree inside subtree
Passed | R3 rejects the exhaustive scope worktree inside worktrees
FAILED=0
FAILED_BLOCKS=0
FAILED_CONTAINERS=0
PASSED=55
```
