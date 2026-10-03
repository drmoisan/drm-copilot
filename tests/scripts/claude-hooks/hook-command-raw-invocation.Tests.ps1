#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Unit cases for the token-aware raw-text invocation matcher (issue #824).

.DESCRIPTION
    Drives .claude/hooks/hook-command-raw-invocation.ps1 directly through
    Test-CommandLineRawInvocation. The positive rows (R824-P) are spellings in which the
    command word and every subcommand element appear as a token-bounded, ordered sequence
    and must classify. The negative rows (R824-N) carry the same words only as substrings,
    out of order, with a different subcommand, or only as shell expansions, and must not
    classify.

    Determinism: every case is a pure string case. No temporary file, no child process, no
    live executable, no clock, and no disk read beyond dot-sourcing the file under test.
#>

Describe 'hook-command-raw-invocation (issue #824)' {
    BeforeAll {
        $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks").Path
        . (Join-Path $script:HookRoot 'hook-command-raw-invocation.ps1')
    }

    Context 'positive rows - a token-bounded ordered sequence classifies' {
        It 'R824-P<Id> classifies <Label>' -Tag 'Issue824' -ForEach @(
            @{ Id = 1; Label = 'adjacent words'; RawText = 'gh issue create --title x'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 2; Label = 'extra whitespace'; RawText = 'gh   issue    create'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 3; Label = 'mixed case'; RawText = 'GH Issue CREATE'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 4; Label = 'a leading ampersand'; RawText = '& gh issue create'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 5; Label = 'a leading semicolon'; RawText = 'echo a;gh issue create'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 6; Label = 'a leading pipe'; RawText = 'echo a|gh issue create'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 7; Label = 'a leading parenthesis'; RawText = '(gh issue create)'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 8; Label = 'a leading double quote'; RawText = 'bash -c "gh issue create"'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 9; Label = 'a leading single quote'; RawText = 'bash -c ''gh issue create'''; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 10; Label = 'a leading newline'; RawText = "echo a`ngh issue create"; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 11; Label = 'a /usr/bin path'; RawText = '/usr/bin/gh issue create'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 12; Label = 'a Windows exe path'; RawText = 'C:\tools\gh.exe issue create'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 13; Label = 'a quoted exe path'; RawText = '& "C:\Program Files\GitHub CLI\gh.exe" issue create'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 14; Label = 'escaped quotes'; RawText = 'pwsh -c "& \"gh\" issue create"'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 15; Label = 'a short repo option'; RawText = 'gh -R o/r issue create'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 16; Label = 'a repo option in equals form'; RawText = 'gh --repo=o/r issue create'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 17; Label = 'a quoted directory option'; RawText = 'git -C "../my wt" worktree remove ../x'; CommandWord = 'git'; SubcommandPath = @('worktree', 'remove') }
            @{ Id = 18; Label = 'an unmodeled dash option'; RawText = 'gh --future-flag issue create'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 19; Label = 'an expansion in the command position'; RawText = 'c=gh; $c issue create'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 20; Label = 'an expansion in a subcommand position'; RawText = 'x=create; gh issue $x'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
        ) {
            # Arrange: the row supplies RawText, CommandWord, and SubcommandPath.

            # Act
            $result = Test-CommandLineRawInvocation -RawText $RawText -CommandWord $CommandWord -SubcommandPath $SubcommandPath

            # Assert
            $result | Should -BeTrue -Because "'$RawText' carries $CommandWord $($SubcommandPath -join ' ') as a token-bounded ordered sequence"
        }
    }

    Context 'negative rows - substrings, other subcommands, and all-expansion sequences do not classify' {
        It 'R824-N<Id> rejects <Label>' -Tag 'Issue824' -ForEach @(
            @{ Id = 1; Label = 'through issue New-Object'; RawText = 'through issue New-Object'; CommandWord = 'gh'; SubcommandPath = @('issue', 'new') }
            @{ Id = 2; Label = 'legit push'; RawText = 'legit push'; CommandWord = 'git'; SubcommandPath = @('push') }
            @{ Id = 3; Label = 'a worktree list filtered on removed'; RawText = 'git worktree list --porcelain | Select-String -NotMatch "removed"'; CommandWord = 'git'; SubcommandPath = @('worktree', 'remove') }
            @{ Id = 4; Label = 'high priority create'; RawText = 'Select-String -Pattern "high priority" | ForEach-Object { "create" }'; CommandWord = 'gh'; SubcommandPath = @('pr', 'create') }
            @{ Id = 5; Label = 'gh issue newline'; RawText = 'gh issue newline'; CommandWord = 'gh'; SubcommandPath = @('issue', 'new') }
            @{ Id = 6; Label = 'gh issue list'; RawText = 'gh issue list'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 7; Label = 'an all-expansion sequence'; RawText = '$a $b $c'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
        ) {
            # Arrange: the row supplies RawText, CommandWord, and SubcommandPath.

            # Act
            $result = Test-CommandLineRawInvocation -RawText $RawText -CommandWord $CommandWord -SubcommandPath $SubcommandPath

            # Assert
            $result | Should -BeFalse -Because "'$RawText' carries no token-bounded $CommandWord $($SubcommandPath -join ' ') sequence with a literal position"
        }
    }
}
