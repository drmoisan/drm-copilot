# r2 P7-T1 pass-after Issue824 run

Timestamp: 2026-10-03T16-20
Command: pwsh -NoProfile -Command "& '$Scratch/issue824-pester.ps1' ISSUE824-PATHS -JUnitPath '$Scratch/r2-pass-after-pester.junit.xml' -Tag 'Issue824' -ExpectPassed 243 -ExpectFailed 0 FIX-SET; exit `$LASTEXITCODE"; $LASTEXITCODE (ISSUE824-PATHS and FIX-SET written out in full in SCRATCH/steps/r2-p7-t1.ps1)
EXIT_CODE: 0
Output Summary:
- TOTALS passed=243 failed=0 skipped=0 notrun=29 total=272 (notrun are the untagged tests excluded by -Tag 'Issue824')
- EXPECTATION-MISMATCHES=0; no CONTAINER-ERROR line; gating exit 0
- Every P1-T10 failing name now passes in every suite that carries it (FIX-SET satisfied: P824-D16 to P824-D19 x2; A824-X1, X2, X3, X4, X7, X8, X10, A824-WT6, A824-WT11-1 x3; R824-P26 to R824-P30 x2)

Full PASSED list:

```text
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
PASSED: P824-D16 denies bash -c 'gh "$@"' _ issue create
PASSED: P824-D17 denies bash -c 'gh $*' _ issue create
PASSED: P824-D18 denies bash -c 'echo issue create | xargs gh'
PASSED: P824-D19 denies bash -c 'gh $1 $2' _ issue create
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
PASSED: P824-D16 denies bash -c 'gh "$@"' _ issue create
PASSED: P824-D17 denies bash -c 'gh $*' _ issue create
PASSED: P824-D18 denies bash -c 'echo issue create | xargs gh'
PASSED: P824-D19 denies bash -c 'gh $1 $2' _ issue create
PASSED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-WT3 allows the addendum reproduction even though raw containment matches it
PASSED: A824-WT4-1 denies git worktree remove /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-2 denies git worktree remove --force /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-3 denies git -C /repo/main worktree remove /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-4 denies pwsh -Command 'git worktree remove /repo/worktrees/item-a-101' without an authorizing record
PASSED: A824-WT4-5 denies bash -c "git worktree remove /repo/worktrees/item-a-101" without an authorizing record
PASSED: A824-WT6 denies a wrapped removal that names no operand
PASSED: A824-WT9 allows a wrapped Write-Host whose expansion precedes worktree remove
PASSED: A824-WT5-1 allows git worktree remove /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-2 allows git worktree remove --force /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-3 allows git -C /repo/main worktree remove /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-4 allows pwsh -Command 'git worktree remove /repo/worktrees/item-a-101' with an authorizing record
PASSED: A824-WT5-5 allows bash -c "git worktree remove /repo/worktrees/item-a-101" with an authorizing record
PASSED: A824-WT7 denies an unbalanced wrapped removal even with an authorizing record
PASSED: A824-WT8 denies a removal whose subcommand is carried by an expansion even with an authorizing record
PASSED: A824-X1 denies bash -c 'echo /repo/worktrees/item-a-101 | xargs git worktree remove' without an authorizing record
PASSED: A824-X2 denies echo /repo/worktrees/item-a-101 | xargs git worktree remove without an authorizing record
PASSED: A824-X3 denies pwsh -c 'git worktree remove (Join-Path /repo/worktrees item-a-101)' without an authorizing record
PASSED: A824-X4 denies bash -c 'git worktree remove >/dev/null /repo/worktrees/item-a-101' without an authorizing record
PASSED: A824-X7 denies pwsh -c 'git worktree remove --force (Get-Item /repo/worktrees/item-a-101)' without an authorizing record
PASSED: A824-X8 denies bash -c 'printf "%s" /repo/worktrees/item-a-101 | xargs git worktree remove --force' without an authorizing record
PASSED: A824-X10 denies bash -c 'git worktree remove </dev/null /repo/worktrees/item-a-101' without an authorizing record
PASSED: A824-WT10 denies a wrapped removal whose operand is an expansion without an authorizing record
PASSED: A824-WT11-1 denies pwsh -NoProfile -Command 'git worktree remove' even with an authorizing record
PASSED: A824-WT11-2 denies bash -c 'git worktree remove "$target"' even with an authorizing record
PASSED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-WT3 allows the addendum reproduction even though raw containment matches it
PASSED: A824-WT4-1 denies git worktree remove /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-2 denies git worktree remove --force /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-3 denies git -C /repo/main worktree remove /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-4 denies pwsh -Command 'git worktree remove /repo/worktrees/item-a-101' without an authorizing record
PASSED: A824-WT4-5 denies bash -c "git worktree remove /repo/worktrees/item-a-101" without an authorizing record
PASSED: A824-WT6 denies a wrapped removal that names no operand
PASSED: A824-WT9 allows a wrapped Write-Host whose expansion precedes worktree remove
PASSED: A824-WT5-1 allows git worktree remove /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-2 allows git worktree remove --force /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-3 allows git -C /repo/main worktree remove /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-4 allows pwsh -Command 'git worktree remove /repo/worktrees/item-a-101' with an authorizing record
PASSED: A824-WT5-5 allows bash -c "git worktree remove /repo/worktrees/item-a-101" with an authorizing record
PASSED: A824-WT7 denies an unbalanced wrapped removal even with an authorizing record
PASSED: A824-WT8 denies a removal whose subcommand is carried by an expansion even with an authorizing record
PASSED: A824-X1 denies bash -c 'echo /repo/worktrees/item-a-101 | xargs git worktree remove' without an authorizing record
PASSED: A824-X2 denies echo /repo/worktrees/item-a-101 | xargs git worktree remove without an authorizing record
PASSED: A824-X3 denies pwsh -c 'git worktree remove (Join-Path /repo/worktrees item-a-101)' without an authorizing record
PASSED: A824-X4 denies bash -c 'git worktree remove >/dev/null /repo/worktrees/item-a-101' without an authorizing record
PASSED: A824-X7 denies pwsh -c 'git worktree remove --force (Get-Item /repo/worktrees/item-a-101)' without an authorizing record
PASSED: A824-X8 denies bash -c 'printf "%s" /repo/worktrees/item-a-101 | xargs git worktree remove --force' without an authorizing record
PASSED: A824-X10 denies bash -c 'git worktree remove </dev/null /repo/worktrees/item-a-101' without an authorizing record
PASSED: A824-WT10 denies a wrapped removal whose operand is an expansion without an authorizing record
PASSED: A824-WT11-1 denies pwsh -NoProfile -Command 'git worktree remove' even with an authorizing record
PASSED: A824-WT11-2 denies bash -c 'git worktree remove "$target"' even with an authorizing record
PASSED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-WT3 allows the addendum reproduction even though raw containment matches it
PASSED: A824-WT4-1 denies git worktree remove worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-2 denies git worktree remove --force worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-3 denies git -C /repo/main worktree remove worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-4 denies pwsh -Command 'git worktree remove worktrees/item-a-101' without an authorizing record
PASSED: A824-WT4-5 denies bash -c "git worktree remove worktrees/item-a-101" without an authorizing record
PASSED: A824-WT6 denies a wrapped removal that names no operand
PASSED: A824-WT9 allows a wrapped Write-Host whose expansion precedes worktree remove
PASSED: A824-WT5-1 allows git worktree remove worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-2 allows git worktree remove --force worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-3 allows git -C /repo/main worktree remove worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-4 allows pwsh -Command 'git worktree remove worktrees/item-a-101' with an authorizing record
PASSED: A824-WT5-5 allows bash -c "git worktree remove worktrees/item-a-101" with an authorizing record
PASSED: A824-WT7 denies an unbalanced wrapped removal even with an authorizing record
PASSED: A824-WT8 denies a removal whose subcommand is carried by an expansion even with an authorizing record
PASSED: A824-X1 denies bash -c 'echo /repo/worktrees/item-a-101 | xargs git worktree remove' without an authorizing record
PASSED: A824-X2 denies echo /repo/worktrees/item-a-101 | xargs git worktree remove without an authorizing record
PASSED: A824-X3 denies pwsh -c 'git worktree remove (Join-Path /repo/worktrees item-a-101)' without an authorizing record
PASSED: A824-X4 denies bash -c 'git worktree remove >/dev/null /repo/worktrees/item-a-101' without an authorizing record
PASSED: A824-X7 denies pwsh -c 'git worktree remove --force (Get-Item /repo/worktrees/item-a-101)' without an authorizing record
PASSED: A824-X8 denies bash -c 'printf "%s" /repo/worktrees/item-a-101 | xargs git worktree remove --force' without an authorizing record
PASSED: A824-X10 denies bash -c 'git worktree remove </dev/null /repo/worktrees/item-a-101' without an authorizing record
PASSED: A824-WT10 denies a wrapped removal whose operand is an expansion without an authorizing record
PASSED: A824-WT11-1 denies pwsh -NoProfile -Command 'git worktree remove' even with an authorizing record
PASSED: A824-WT11-2 denies bash -c 'git worktree remove "$target"' even with an authorizing record
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
PASSED: R824-P26 classifies every word named in another order
PASSED: R824-P27 classifies a positional-parameter list after the command word
PASSED: R824-P28 classifies a special-parameter expansion after the command word
PASSED: R824-P29 classifies an xargs-led command word
PASSED: R824-P30 classifies numbered positional parameters
PASSED: R824-N11 rejects a positional-parameter list whose trailing words name another subcommand
PASSED: R824-N12 rejects an xargs-led command word with one subcommand word absent
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
PASSED: R824-P26 classifies every word named in another order
PASSED: R824-P27 classifies a positional-parameter list after the command word
PASSED: R824-P28 classifies a special-parameter expansion after the command word
PASSED: R824-P29 classifies an xargs-led command word
PASSED: R824-P30 classifies numbered positional parameters
PASSED: R824-N11 rejects a positional-parameter list whose trailing words name another subcommand
PASSED: R824-N12 rejects an xargs-led command word with one subcommand word absent
```
