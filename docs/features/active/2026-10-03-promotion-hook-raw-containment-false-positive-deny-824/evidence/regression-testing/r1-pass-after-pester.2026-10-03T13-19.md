# r1 P7-T1 — Issue824 Pester rows after the fix (pass-after)

Timestamp: 2026-10-03T13-19
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p7-t1.ps1 -Worktree WORKTREE; step script runs the P1-T10 command with 'tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1' appended to -Path, -JUnitPath '$Scratch/r1-pass-after-pester.junit.xml', and `-ExpectPassed 215 -ExpectFailed 0` followed by FIX-SET (`-RequirePassed @('P824-D12*2', 'P824-D13*2', 'P824-D14*2', 'P824-D15*2', 'P824-A4*2', 'A824-WT5-4*3', 'A824-WT5-5*3', 'A824-WT6*3', 'A824-WT8*3', 'A824-WT9*3', 'R824-P21*2', 'R824-P22*2', 'R824-P23*2', 'R824-P24*2', 'R824-P25*2', 'R824-N9*2', 'R824-N10*2', 'R824-O1*2', 'R824-O2*2', 'R824-O3*2', 'R824-O4*2', 'R824-O5*2', 'R824-O6*2', 'R824-O7*2', 'R824-O8*2', 'R824-O9*2', 'R824-O10*2', 'R824-O11*2', 'R824-W1*2', 'R824-W2*2', 'R824-W3*2', 'R824-W4*2', 'R824-W5*2', 'F824-1', 'F824-3')`), then `; exit `$LASTEXITCODE"; $LASTEXITCODE`
EXIT_CODE: 0
Output Summary:
- TOTALS passed=215 failed=0 skipped=0 notrun=29 total=244 (135 + 73 + U3 7 = 215; notrun rows are untagged tests filtered out by -Tag Issue824)
- EXPECTATION-MISMATCHES=0 (every FIX-SET name passed in every suite that carries it); no FAILED or CONTAINER-ERROR line; printed exit code 0.
- The JUnit file stays at SCRATCH/r1-pass-after-pester.junit.xml (host-path rule).

PASSED list (215):

PASSED: P824-A1 allows the issue 824 reproduction command
PASSED: P824-A2 allows a wrapped payload carrying through, issue, and New-Object with no gh issue sequence
PASSED: P824-A3 allows gh --repo o/r issue list
PASSED: P824-D1 denies gh issue create --title x
PASSED: P824-D2 denies gh issue new --title x
PASSED: P824-D3 denies GH  Issue  Create
PASSED: P824-D4 denies pwsh -NoProfile -Command 'gh issue create --title x'
PASSED: P824-D5 denies pwsh -c "& gh issue new"
PASSED: P824-D6 denies bash -c "gh issue create"
PASSED: P824-D7 denies gh api repos/o/r/issues -X POST
PASSED: P824-D8 denies bash -c "gh -R o/r issue create"
PASSED: P824-D9 denies bash -c 'x=create; gh issue $x'
PASSED: P824-D10 denies bash -c 'c=gh; $c issue create'
PASSED: P824-D11 denies the unbalanced segment echo unterminated
PASSED: P824-D12 denies bash -c 'cmd="issue create"; gh $cmd'
PASSED: P824-D13 denies pwsh -c '$a = "issue","create"; gh @a'
PASSED: P824-D14 denies bash -c 'args=(issue create); gh "${args[@]}"'
PASSED: P824-D15 denies bash -c with a backslash-newline between issue and create
PASSED: P824-A4 allows a wrapped Write-Output whose expansion precedes issue create
PASSED: P824-A1 allows the issue 824 reproduction command
PASSED: P824-A2 allows a wrapped payload carrying through, issue, and New-Object with no gh issue sequence
PASSED: P824-A3 allows gh --repo o/r issue list
PASSED: P824-D1 denies gh issue create --title x
PASSED: P824-D2 denies gh issue new --title x
PASSED: P824-D3 denies GH  Issue  Create
PASSED: P824-D4 denies pwsh -NoProfile -Command 'gh issue create --title x'
PASSED: P824-D5 denies pwsh -c "& gh issue new"
PASSED: P824-D6 denies bash -c "gh issue create"
PASSED: P824-D7 denies gh api repos/o/r/issues -X POST
PASSED: P824-D8 denies bash -c "gh -R o/r issue create"
PASSED: P824-D9 denies bash -c 'x=create; gh issue $x'
PASSED: P824-D10 denies bash -c 'c=gh; $c issue create'
PASSED: P824-D11 denies the unbalanced segment echo unterminated
PASSED: P824-D12 denies bash -c 'cmd="issue create"; gh $cmd'
PASSED: P824-D13 denies pwsh -c '$a = "issue","create"; gh @a'
PASSED: P824-D14 denies bash -c 'args=(issue create); gh "${args[@]}"'
PASSED: P824-D15 denies bash -c with a backslash-newline between issue and create
PASSED: P824-A4 allows a wrapped Write-Output whose expansion precedes issue create
PASSED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-WT3 allows the addendum reproduction even though raw containment matches it
PASSED: A824-WT4-1 denies git worktree remove /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-2 denies git worktree remove --force /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-3 denies git -C /repo/main worktree remove /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-4 denies pwsh -Command 'git worktree remove /repo/worktrees/item-a-101' without an authorizing record
PASSED: A824-WT4-5 denies bash -c "git worktree remove /repo/worktrees/item-a-101" without an authorizing record
PASSED: A824-WT6 allows a wrapped removal that names no operand
PASSED: A824-WT9 allows a wrapped Write-Host whose expansion precedes worktree remove
PASSED: A824-WT5-1 allows git worktree remove /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-2 allows git worktree remove --force /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-3 allows git -C /repo/main worktree remove /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-4 allows pwsh -Command 'git worktree remove /repo/worktrees/item-a-101' with an authorizing record
PASSED: A824-WT5-5 allows bash -c "git worktree remove /repo/worktrees/item-a-101" with an authorizing record
PASSED: A824-WT7 denies an unbalanced wrapped removal even with an authorizing record
PASSED: A824-WT8 denies a removal whose subcommand is carried by an expansion even with an authorizing record
PASSED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-WT3 allows the addendum reproduction even though raw containment matches it
PASSED: A824-WT4-1 denies git worktree remove /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-2 denies git worktree remove --force /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-3 denies git -C /repo/main worktree remove /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-4 denies pwsh -Command 'git worktree remove /repo/worktrees/item-a-101' without an authorizing record
PASSED: A824-WT4-5 denies bash -c "git worktree remove /repo/worktrees/item-a-101" without an authorizing record
PASSED: A824-WT6 allows a wrapped removal that names no operand
PASSED: A824-WT9 allows a wrapped Write-Host whose expansion precedes worktree remove
PASSED: A824-WT5-1 allows git worktree remove /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-2 allows git worktree remove --force /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-3 allows git -C /repo/main worktree remove /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-4 allows pwsh -Command 'git worktree remove /repo/worktrees/item-a-101' with an authorizing record
PASSED: A824-WT5-5 allows bash -c "git worktree remove /repo/worktrees/item-a-101" with an authorizing record
PASSED: A824-WT7 denies an unbalanced wrapped removal even with an authorizing record
PASSED: A824-WT8 denies a removal whose subcommand is carried by an expansion even with an authorizing record
PASSED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-WT3 allows the addendum reproduction even though raw containment matches it
PASSED: A824-WT4-1 denies git worktree remove worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-2 denies git worktree remove --force worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-3 denies git -C /repo/main worktree remove worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-4 denies pwsh -Command 'git worktree remove worktrees/item-a-101' without an authorizing record
PASSED: A824-WT4-5 denies bash -c "git worktree remove worktrees/item-a-101" without an authorizing record
PASSED: A824-WT6 allows a wrapped removal that names no operand
PASSED: A824-WT9 allows a wrapped Write-Host whose expansion precedes worktree remove
PASSED: A824-WT5-1 allows git worktree remove worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-2 allows git worktree remove --force worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-3 allows git -C /repo/main worktree remove worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-4 allows pwsh -Command 'git worktree remove worktrees/item-a-101' with an authorizing record
PASSED: A824-WT5-5 allows bash -c "git worktree remove worktrees/item-a-101" with an authorizing record
PASSED: A824-WT7 denies an unbalanced wrapped removal even with an authorizing record
PASSED: A824-WT8 denies a removal whose subcommand is carried by an expansion even with an authorizing record
PASSED: R824-P1 classifies adjacent words
PASSED: R824-P2 classifies extra whitespace
PASSED: R824-P3 classifies mixed case
PASSED: R824-P4 classifies a leading ampersand
PASSED: R824-P5 classifies a leading semicolon
PASSED: R824-P6 classifies a leading pipe
PASSED: R824-P7 classifies a leading parenthesis
PASSED: R824-P8 classifies a leading double quote
PASSED: R824-P9 classifies a leading single quote
PASSED: R824-P10 classifies a leading newline
PASSED: R824-P11 classifies a /usr/bin path
PASSED: R824-P12 classifies a Windows exe path
PASSED: R824-P13 classifies a quoted exe path
PASSED: R824-P14 classifies escaped quotes
PASSED: R824-P15 classifies a short repo option
PASSED: R824-P16 classifies a repo option in equals form
PASSED: R824-P17 classifies a quoted directory option
PASSED: R824-P18 classifies an unmodeled dash option
PASSED: R824-P19 classifies an expansion in the command position
PASSED: R824-P20 classifies an expansion in a subcommand position
PASSED: R824-N1 rejects through issue New-Object
PASSED: R824-N2 rejects legit push
PASSED: R824-N3 rejects a worktree list filtered on removed
PASSED: R824-N4 rejects high priority create
PASSED: R824-N5 rejects gh issue newline
PASSED: R824-N6 rejects gh issue list
PASSED: R824-N7 rejects an all-expansion sequence
PASSED: R824-P21 classifies a variable holding both subcommand words
PASSED: R824-P22 classifies a PowerShell array splat
PASSED: R824-P23 classifies a bash array expansion
PASSED: R824-P24 classifies a backslash-newline inside double quotes
PASSED: R824-P25 classifies a variable holding worktree remove
PASSED: R824-N8 rejects an expansion after gh with neither subcommand word present
PASSED: R824-N9 rejects an expansion before issue create with no gh token
PASSED: R824-N10 rejects an expansion before worktree remove with no git token
PASSED: R824-O1 reads a bash -c operand
PASSED: R824-O2 reads an operand after --force
PASSED: R824-O3 reads an operand after a quoted -C option
PASSED: R824-O4 reads an operand after the -- separator
PASSED: R824-O5 reads an escaped-quote operand
PASSED: R824-O6 reads a wrapped removal naming no operand
PASSED: R824-O7 reads a removal whose subcommand is an expansion
PASSED: R824-O8 reads two removals naming different operands
PASSED: R824-O9 reads an unmodeled dash option before the operand
PASSED: R824-O10 reads an operand that is an expansion
PASSED: R824-O11 reads a worktree list
PASSED: R824-W1 resolves a non-matching command
PASSED: R824-W2 resolves a structural removal
PASSED: R824-W3 resolves an unbalanced wrapped removal
PASSED: R824-W4 resolves a structural removal with an unmodeled option
PASSED: R824-W5 resolves a wrapped removal
PASSED: R824-P1 classifies adjacent words
PASSED: R824-P2 classifies extra whitespace
PASSED: R824-P3 classifies mixed case
PASSED: R824-P4 classifies a leading ampersand
PASSED: R824-P5 classifies a leading semicolon
PASSED: R824-P6 classifies a leading pipe
PASSED: R824-P7 classifies a leading parenthesis
PASSED: R824-P8 classifies a leading double quote
PASSED: R824-P9 classifies a leading single quote
PASSED: R824-P10 classifies a leading newline
PASSED: R824-P11 classifies a /usr/bin path
PASSED: R824-P12 classifies a Windows exe path
PASSED: R824-P13 classifies a quoted exe path
PASSED: R824-P14 classifies escaped quotes
PASSED: R824-P15 classifies a short repo option
PASSED: R824-P16 classifies a repo option in equals form
PASSED: R824-P17 classifies a quoted directory option
PASSED: R824-P18 classifies an unmodeled dash option
PASSED: R824-P19 classifies an expansion in the command position
PASSED: R824-P20 classifies an expansion in a subcommand position
PASSED: R824-N1 rejects through issue New-Object
PASSED: R824-N2 rejects legit push
PASSED: R824-N3 rejects a worktree list filtered on removed
PASSED: R824-N4 rejects high priority create
PASSED: R824-N5 rejects gh issue newline
PASSED: R824-N6 rejects gh issue list
PASSED: R824-N7 rejects an all-expansion sequence
PASSED: R824-P21 classifies a variable holding both subcommand words
PASSED: R824-P22 classifies a PowerShell array splat
PASSED: R824-P23 classifies a bash array expansion
PASSED: R824-P24 classifies a backslash-newline inside double quotes
PASSED: R824-P25 classifies a variable holding worktree remove
PASSED: R824-N8 rejects an expansion after gh with neither subcommand word present
PASSED: R824-N9 rejects an expansion before issue create with no gh token
PASSED: R824-N10 rejects an expansion before worktree remove with no git token
PASSED: R824-O1 reads a bash -c operand
PASSED: R824-O2 reads an operand after --force
PASSED: R824-O3 reads an operand after a quoted -C option
PASSED: R824-O4 reads an operand after the -- separator
PASSED: R824-O5 reads an escaped-quote operand
PASSED: R824-O6 reads a wrapped removal naming no operand
PASSED: R824-O7 reads a removal whose subcommand is an expansion
PASSED: R824-O8 reads two removals naming different operands
PASSED: R824-O9 reads an unmodeled dash option before the operand
PASSED: R824-O10 reads an operand that is an expansion
PASSED: R824-O11 reads a worktree list
PASSED: R824-W1 resolves a non-matching command
PASSED: R824-W2 resolves a structural removal
PASSED: R824-W3 resolves an unbalanced wrapped removal
PASSED: R824-W4 resolves a structural removal with an unmodeled option
PASSED: R824-W5 resolves a wrapped removal
PASSED: F824-1 applies lower line and branch thresholds stated in the root CLAUDE.md
PASSED: F824-2 falls back to the default floors when the root CLAUDE.md states no figures
PASSED: F824-3 applies a line-only figure and keeps the default branch floor
PASSED: F824-4 reads PowerShell line coverage from the JaCoCo report
PASSED: F824-5 reads branch coverage from the JaCoCo report
PASSED: F824-6 rejects a coverage row that narrows scope
PASSED: F824-7 rejects an audit that does not mention a changed language
PASSED: F824-8 rejects a language mention with no coverage-scoped row
PASSED: F824-9 reads a tracked file and reports a missing one
PASSED: F824-V1 blocks an empty payload
PASSED: F824-V2 blocks a malformed payload
PASSED: F824-V3 blocks an empty agent output
PASSED: F824-V4 blocks an artifact outside the active-feature location
PASSED: F824-V5 blocks an advertised artifact that does not exist
PASSED: F824-V6 blocks a remediation-inputs path outside the location
PASSED: F824-V7 blocks a remediation-inputs timestamp that differs
PASSED: F824-V8 blocks a remediation-inputs file that does not exist
PASSED: T824-1 resolves no root CLAUDE.md text
PASSED: T824-2 resolves text without figures
PASSED: T824-3 resolves lower line and branch figures
PASSED: T824-4 resolves a line-only figure
PASSED: T824-5 resolves a branch-only figure
PASSED: T824-6 resolves a decimal figure
PASSED: T824-7 resolves a figure above 100
