#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Unit cases for the token-aware raw-text invocation matcher (issue #824).

.DESCRIPTION
    Drives .codex/hooks/hook-command-raw-invocation.ps1 directly through
    Test-CommandLineRawInvocation. The positive rows (R824-P) are spellings in which the
    command word and every subcommand element each occur as whole tokens, in any order,
    and must classify. The negative rows (R824-N) lack at least one of the words as a
    whole token (it occurs only inside a longer word, only through a shell expansion, or
    not at all) and must not classify. The R824-O and R824-W rows cover operand extraction.

    Determinism: every case is a pure string case. No temporary file, no child process, no
    live executable, no clock, and no disk read beyond dot-sourcing the file under test.
#>

Describe 'hook-command-raw-invocation, Codex copy (issue #824)' {
    BeforeAll {
        $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.codex/hooks").Path
        . (Join-Path $script:HookRoot 'hook-command-raw-invocation.ps1')
    }

    Context 'positive rows - every word occurs as a whole token' {
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
            $result | Should -BeTrue -Because "'$RawText' carries $CommandWord $($SubcommandPath -join ' ') as whole tokens"
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
            $result | Should -BeFalse -Because "'$RawText' lacks $CommandWord or a subcommand word as a whole token"
        }
    }

    Context 'issue #824 cycle 1 - wrapped bypass forms classify' {
        It 'R824-P<Id> classifies <Label>' -Tag 'Issue824' -ForEach @(
            @{ Id = 21; Label = 'a variable holding both subcommand words'; RawText = 'bash -c ''cmd="issue create"; gh $cmd'''; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 22; Label = 'a PowerShell array splat'; RawText = 'pwsh -c ''$a = "issue","create"; gh @a'''; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 23; Label = 'a bash array expansion'; RawText = 'bash -c ''args=(issue create); gh "${args[@]}"'''; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 24; Label = 'a backslash-newline inside double quotes'; RawText = ('bash -c "gh issue \' + "`n" + 'create"'); CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 25; Label = 'a variable holding worktree remove'; RawText = 'bash -c ''a="worktree remove"; git $a ../x'''; CommandWord = 'git'; SubcommandPath = @('worktree', 'remove') }
        ) {
            # Arrange: the row supplies RawText, CommandWord, and SubcommandPath.

            # Act
            $result = Test-CommandLineRawInvocation -RawText $RawText -CommandWord $CommandWord -SubcommandPath $SubcommandPath

            # Assert
            $result | Should -BeTrue -Because "'$RawText' carries the literal $CommandWord with every subcommand word reachable through an expansion or a line continuation"
        }
    }

    Context 'issue #824 cycle 1 - absorption and command-position expansions need the literal words' {
        It 'R824-N<Id> rejects <Label>' -Tag 'Issue824' -ForEach @(
            @{ Id = 8; Label = 'an expansion after gh with neither subcommand word present'; RawText = 'gh $x'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 9; Label = 'an expansion before issue create with no gh token'; RawText = 'pwsh -c ''Write-Output "$prefix issue create"'''; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 10; Label = 'an expansion before worktree remove with no git token'; RawText = 'pwsh -c ''Write-Host "$path worktree remove"'''; CommandWord = 'git'; SubcommandPath = @('worktree', 'remove') }
        ) {
            # Arrange: the row supplies RawText, CommandWord, and SubcommandPath.

            # Act
            $result = Test-CommandLineRawInvocation -RawText $RawText -CommandWord $CommandWord -SubcommandPath $SubcommandPath

            # Assert
            $result | Should -BeFalse -Because "'$RawText' lacks a token-bounded $CommandWord or a token-bounded subcommand word"
        }
    }

    Context 'issue #824 cycle 1 - wrapped removal operand' {
        It 'R824-O<Id> reads <Label>' -Tag 'Issue824' -ForEach @(
            @{ Id = 1; Label = 'a bash -c operand'; RawText = 'bash -c "git worktree remove ../x"'; Status = 'Operand'; Operand = '../x' }
            @{ Id = 2; Label = 'an operand after --force'; RawText = 'pwsh -Command ''git worktree remove --force C:/w/a'''; Status = 'Operand'; Operand = 'C:/w/a' }
            @{ Id = 3; Label = 'an operand after a quoted -C option'; RawText = 'pwsh -Command ''git -C "a b" worktree remove ../x'''; Status = 'Operand'; Operand = '../x' }
            @{ Id = 4; Label = 'an operand after the -- separator'; RawText = 'bash -c ''git worktree remove -- ../x'''; Status = 'Operand'; Operand = '../x' }
            @{ Id = 5; Label = 'an escaped-quote operand'; RawText = 'bash -c "git worktree remove \"../x\""'; Status = 'Operand'; Operand = '../x' }
            @{ Id = 6; Label = 'a wrapped removal naming no operand'; RawText = 'bash -c "git worktree remove"'; Status = 'NoOperand'; Operand = $null }
            @{ Id = 7; Label = 'a removal whose subcommand is an expansion'; RawText = 'bash -c ''a="worktree remove"; git $a ../x'''; Status = 'Indeterminate'; Operand = $null }
            @{ Id = 8; Label = 'two removals naming different operands'; RawText = 'bash -c ''git worktree remove ../a; git worktree remove ../b'''; Status = 'Indeterminate'; Operand = $null }
            @{ Id = 9; Label = 'an unmodeled dash option before the operand'; RawText = 'bash -c ''git worktree remove --unknown ../x'''; Status = 'Indeterminate'; Operand = $null }
            @{ Id = 10; Label = 'an operand that is an expansion'; RawText = 'bash -c ''git worktree remove "$target"'''; Status = 'Indeterminate'; Operand = $null }
            @{ Id = 11; Label = 'a worktree list'; RawText = 'pwsh -Command ''git worktree list'''; Status = 'NoMatch'; Operand = $null }
        ) {
            # Arrange: the row supplies RawText and the expected Status and Operand.

            # Act
            $result = Get-CommandLineRawInvocationOperand -RawText $RawText -CommandWord 'git' -SubcommandPath @('worktree', 'remove')

            # Assert
            $result.Status | Should -Be $Status -Because "'$RawText' must resolve to $Status"
            $result.Operand | Should -Be $Operand -Because "'$RawText' must report the operand only when it is literal and unique"
        }
    }

    Context 'issue #824 cycle 1 - wrapped removal operand resolution' {
        BeforeAll {
            . (Join-Path $script:HookRoot 'hook-command-invocation.ps1')
        }

        It 'R824-W<Id> resolves <Label>' -Tag 'Issue824' -ForEach @(
            @{ Id = 1; Label = 'a non-matching command'; CommandText = 'git worktree list'; Status = 'NotApplicable'; Operand = $null }
            @{ Id = 2; Label = 'a structural removal'; CommandText = 'git worktree remove ../x'; Status = 'NotApplicable'; Operand = $null }
            @{ Id = 3; Label = 'an unbalanced wrapped removal'; CommandText = 'bash -c "git worktree remove ../x'; Status = 'NotApplicable'; Operand = $null }
            @{ Id = 4; Label = 'a structural removal with an unmodeled option'; CommandText = 'git --bogus-option worktree remove ../x'; Status = 'NotApplicable'; Operand = $null }
            @{ Id = 5; Label = 'a wrapped removal'; CommandText = 'bash -c "git worktree remove ../x"'; Status = 'Operand'; Operand = '../x' }
        ) {
            # Arrange: the row supplies CommandText and the expected Status and Operand.

            # Act
            $result = Resolve-CommandLineWrappedInvocationOperand -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove')

            # Assert
            $result.Status | Should -Be $Status -Because "'$CommandText' must resolve to $Status"
            $result.Operand | Should -Be $Operand -Because "'$CommandText' must report a raw operand only for a wrapped removal"
        }
    }

    Context 'issue #824 cycle 2 - whole-token order-independent classification' {
        It 'R824-P<Id> classifies <Label>' -Tag 'Issue824' -ForEach @(
            @{ Id = 26; Label = 'every word named in another order'; RawText = 'pwsh -c ''Write-Output "create an issue with gh"'''; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 27; Label = 'a positional-parameter list after the command word'; RawText = 'bash -c ''gh "$@"'' _ issue create'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 28; Label = 'a special-parameter expansion after the command word'; RawText = 'bash -c ''gh $*'' _ issue create'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 29; Label = 'an xargs-led command word'; RawText = 'bash -c ''echo issue create | xargs gh'''; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 30; Label = 'numbered positional parameters'; RawText = 'bash -c ''gh $1 $2'' _ issue create'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
        ) {
            # Arrange: the row supplies RawText, CommandWord, and SubcommandPath. Row 26 pins the
            # accepted false-positive trade recorded in the spec's Risks and Mitigations section.

            # Act
            $result = Test-CommandLineRawInvocation -RawText $RawText -CommandWord $CommandWord -SubcommandPath $SubcommandPath

            # Assert
            $result | Should -BeTrue -Because "'$RawText' names $CommandWord and every word of $($SubcommandPath -join ' ') as a whole token, in some order"
        }

        It 'R824-N<Id> rejects <Label>' -Tag 'Issue824' -ForEach @(
            @{ Id = 11; Label = 'a positional-parameter list whose trailing words name another subcommand'; RawText = 'bash -c ''gh "$@"'' _ pr list'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
            @{ Id = 12; Label = 'an xargs-led command word with one subcommand word absent'; RawText = 'echo issue | xargs gh'; CommandWord = 'gh'; SubcommandPath = @('issue', 'create') }
        ) {
            # Arrange: the row supplies RawText, CommandWord, and SubcommandPath.

            # Act
            $result = Test-CommandLineRawInvocation -RawText $RawText -CommandWord $CommandWord -SubcommandPath $SubcommandPath

            # Assert
            $result | Should -BeFalse -Because "'$RawText' lacks at least one of $CommandWord $($SubcommandPath -join ' ') as a whole token"
        }
    }
}
