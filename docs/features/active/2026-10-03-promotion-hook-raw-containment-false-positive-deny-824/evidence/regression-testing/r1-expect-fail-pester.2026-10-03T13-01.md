# r1 P1-T10 [expect-fail] — Issue824 Pester rows against the unfixed tree

Timestamp: 2026-10-03T13-01
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p1-t10.ps1 -Worktree WORKTREE; step script runs `` pwsh -NoProfile -Command "& '$Scratch/issue824-pester.ps1' -Path @('tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1', 'tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1', 'tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1', 'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1', 'tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1', 'tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1', 'tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1', 'tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1') -JUnitPath '$Scratch/r1-expect-fail-pester.junit.xml' -Tag 'Issue824' -ExpectPassed 135 -ExpectFailed 73; exit `$LASTEXITCODE"; $LASTEXITCODE ``
EXIT_CODE: 73
ExpectedExitCode: 73
Output Summary:
- TOTALS passed=135 failed=73 skipped=0 notrun=29 total=237 (notrun rows are untagged tests filtered out by -Tag Issue824)
- EXPECTATION-MISMATCHES=0; no CONTAINER-ERROR line; A2 exit code 73 (printed `$LASTEXITCODE` = 73).
- The 73 FAILED names match the plan's failing set: S1/S2 P824-D12 to D15 and P824-A4 (10); S6/S7/S8 A824-WT5-4, A824-WT5-5, A824-WT6, A824-WT8, A824-WT9 (15); U1/U2 R824-P21 to P25, R824-N9, R824-N10, R824-O1 to O11, R824-W1 to W5 (46); NT1 F824-1, F824-3 (2).
- The JUnit file stays at SCRATCH/r1-expect-fail-pester.junit.xml (host-path rule).

FAILED list (73, in run order: S1, S2, S6, S7, S8, U1, U2, NT1):

FAILED: P824-D12 denies bash -c 'cmd="issue create"; gh $cmd'
FAILED: P824-D13 denies pwsh -c '$a = "issue","create"; gh @a'
FAILED: P824-D14 denies bash -c 'args=(issue create); gh "${args[@]}"'
FAILED: P824-D15 denies bash -c with a backslash-newline between issue and create
FAILED: P824-A4 allows a wrapped Write-Output whose expansion precedes issue create
FAILED: P824-D12 denies bash -c 'cmd="issue create"; gh $cmd'
FAILED: P824-D13 denies pwsh -c '$a = "issue","create"; gh @a'
FAILED: P824-D14 denies bash -c 'args=(issue create); gh "${args[@]}"'
FAILED: P824-D15 denies bash -c with a backslash-newline between issue and create
FAILED: P824-A4 allows a wrapped Write-Output whose expansion precedes issue create
FAILED: A824-WT6 allows a wrapped removal that names no operand
FAILED: A824-WT9 allows a wrapped Write-Host whose expansion precedes worktree remove
FAILED: A824-WT5-4 allows pwsh -Command 'git worktree remove /repo/worktrees/item-a-101' with an authorizing record
FAILED: A824-WT5-5 allows bash -c "git worktree remove /repo/worktrees/item-a-101" with an authorizing record
FAILED: A824-WT8 denies a removal whose subcommand is carried by an expansion even with an authorizing record
FAILED: A824-WT6 allows a wrapped removal that names no operand
FAILED: A824-WT9 allows a wrapped Write-Host whose expansion precedes worktree remove
FAILED: A824-WT5-4 allows pwsh -Command 'git worktree remove /repo/worktrees/item-a-101' with an authorizing record
FAILED: A824-WT5-5 allows bash -c "git worktree remove /repo/worktrees/item-a-101" with an authorizing record
FAILED: A824-WT8 denies a removal whose subcommand is carried by an expansion even with an authorizing record
FAILED: A824-WT6 allows a wrapped removal that names no operand
FAILED: A824-WT9 allows a wrapped Write-Host whose expansion precedes worktree remove
FAILED: A824-WT5-4 allows pwsh -Command 'git worktree remove worktrees/item-a-101' with an authorizing record
FAILED: A824-WT5-5 allows bash -c "git worktree remove worktrees/item-a-101" with an authorizing record
FAILED: A824-WT8 denies a removal whose subcommand is carried by an expansion even with an authorizing record
FAILED: R824-P21 classifies a variable holding both subcommand words
FAILED: R824-P22 classifies a PowerShell array splat
FAILED: R824-P23 classifies a bash array expansion
FAILED: R824-P24 classifies a backslash-newline inside double quotes
FAILED: R824-P25 classifies a variable holding worktree remove
FAILED: R824-N9 rejects an expansion before issue create with no gh token
FAILED: R824-N10 rejects an expansion before worktree remove with no git token
FAILED: R824-O1 reads a bash -c operand
FAILED: R824-O2 reads an operand after --force
FAILED: R824-O3 reads an operand after a quoted -C option
FAILED: R824-O4 reads an operand after the -- separator
FAILED: R824-O5 reads an escaped-quote operand
FAILED: R824-O6 reads a wrapped removal naming no operand
FAILED: R824-O7 reads a removal whose subcommand is an expansion
FAILED: R824-O8 reads two removals naming different operands
FAILED: R824-O9 reads an unmodeled dash option before the operand
FAILED: R824-O10 reads an operand that is an expansion
FAILED: R824-O11 reads a worktree list
FAILED: R824-W1 resolves a non-matching command
FAILED: R824-W2 resolves a structural removal
FAILED: R824-W3 resolves an unbalanced wrapped removal
FAILED: R824-W4 resolves a structural removal with an unmodeled option
FAILED: R824-W5 resolves a wrapped removal
FAILED: R824-P21 classifies a variable holding both subcommand words
FAILED: R824-P22 classifies a PowerShell array splat
FAILED: R824-P23 classifies a bash array expansion
FAILED: R824-P24 classifies a backslash-newline inside double quotes
FAILED: R824-P25 classifies a variable holding worktree remove
FAILED: R824-N9 rejects an expansion before issue create with no gh token
FAILED: R824-N10 rejects an expansion before worktree remove with no git token
FAILED: R824-O1 reads a bash -c operand
FAILED: R824-O2 reads an operand after --force
FAILED: R824-O3 reads an operand after a quoted -C option
FAILED: R824-O4 reads an operand after the -- separator
FAILED: R824-O5 reads an escaped-quote operand
FAILED: R824-O6 reads a wrapped removal naming no operand
FAILED: R824-O7 reads a removal whose subcommand is an expansion
FAILED: R824-O8 reads two removals naming different operands
FAILED: R824-O9 reads an unmodeled dash option before the operand
FAILED: R824-O10 reads an operand that is an expansion
FAILED: R824-O11 reads a worktree list
FAILED: R824-W1 resolves a non-matching command
FAILED: R824-W2 resolves a structural removal
FAILED: R824-W3 resolves an unbalanced wrapped removal
FAILED: R824-W4 resolves a structural removal with an unmodeled option
FAILED: R824-W5 resolves a wrapped removal
FAILED: F824-1 applies lower line and branch thresholds stated in the root CLAUDE.md
FAILED: F824-3 applies a line-only figure and keeps the default branch floor

PASSED list (135, in run order: S1 14, S2 14, S6 12, S7 12, S8 12, U1 28, U2 28, NT1 15):

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
PASSED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-WT3 allows the addendum reproduction even though raw containment matches it
PASSED: A824-WT4-1 denies git worktree remove /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-2 denies git worktree remove --force /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-3 denies git -C /repo/main worktree remove /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-4 denies pwsh -Command 'git worktree remove /repo/worktrees/item-a-101' without an authorizing record
PASSED: A824-WT4-5 denies bash -c "git worktree remove /repo/worktrees/item-a-101" without an authorizing record
PASSED: A824-WT5-1 allows git worktree remove /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-2 allows git worktree remove --force /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-3 allows git -C /repo/main worktree remove /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT7 denies an unbalanced wrapped removal even with an authorizing record
PASSED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-WT3 allows the addendum reproduction even though raw containment matches it
PASSED: A824-WT4-1 denies git worktree remove /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-2 denies git worktree remove --force /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-3 denies git -C /repo/main worktree remove /repo/worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-4 denies pwsh -Command 'git worktree remove /repo/worktrees/item-a-101' without an authorizing record
PASSED: A824-WT4-5 denies bash -c "git worktree remove /repo/worktrees/item-a-101" without an authorizing record
PASSED: A824-WT5-1 allows git worktree remove /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-2 allows git worktree remove --force /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-3 allows git -C /repo/main worktree remove /repo/worktrees/item-a-101 with an authorizing record
PASSED: A824-WT7 denies an unbalanced wrapped removal even with an authorizing record
PASSED: A824-WT1 allows a wrapped git worktree list whose filter text carries removed
PASSED: A824-WT2 still denies git worktree remove carried inside a bash -c argument
PASSED: A824-WT3 allows the addendum reproduction even though raw containment matches it
PASSED: A824-WT4-1 denies git worktree remove worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-2 denies git worktree remove --force worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-3 denies git -C /repo/main worktree remove worktrees/item-a-101 without an authorizing record
PASSED: A824-WT4-4 denies pwsh -Command 'git worktree remove worktrees/item-a-101' without an authorizing record
PASSED: A824-WT4-5 denies bash -c "git worktree remove worktrees/item-a-101" without an authorizing record
PASSED: A824-WT5-1 allows git worktree remove worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-2 allows git worktree remove --force worktrees/item-a-101 with an authorizing record
PASSED: A824-WT5-3 allows git -C /repo/main worktree remove worktrees/item-a-101 with an authorizing record
PASSED: A824-WT7 denies an unbalanced wrapped removal even with an authorizing record
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
PASSED: R824-N8 rejects an expansion after gh with neither subcommand word present
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
PASSED: R824-N8 rejects an expansion after gh with neither subcommand word present
PASSED: F824-2 falls back to the default floors when the root CLAUDE.md states no figures
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
