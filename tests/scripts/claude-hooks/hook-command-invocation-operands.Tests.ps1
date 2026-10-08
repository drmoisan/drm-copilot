#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Coverage of the operand readers and the removal-target resolver (issue #824, T-OPS).

.DESCRIPTION
    Drives Resolve-CommandLineInvocationTarget, Get-CommandLineOperand,
    Get-CommandLineFlagValue, and Test-CommandLineFlag in hook-command-invocation-operands.ps1,
    loaded through hook-command-invocation.ps1. The resolver returns NoMatch, Targets (never
    empty), or Indeterminate; the worktree-removal gates deny on Indeterminate, so no
    unreadable operand routes to an allow. The prior-run corpus rows X1-X10, W1-W6, and B5
    use the synthetic paths P and Q of plan section 4.

    Every row runs against the Claude and the Codex copy. Each case is a pure string case:
    no temporary file, no child process, no live executable, and no disk read beyond
    dot-sourcing the files under test.
#>

BeforeDiscovery {
    $script:Runtimes = @(
        @{ Runtime = 'claude'; HookRoot = '.claude/hooks' }
        @{ Runtime = 'codex'; HookRoot = '.codex/hooks' }
    )
    $P = '/repo/worktrees/item-a-101'
    $Q = '/repo/worktrees/item-b-102'
    $script:F4F5 = @(
        @{ Name = 'F4'; Command = "pwsh -Command 'git worktree remove $P'" }
        @{ Name = 'F5'; Command = "bash -c ""git worktree remove $P""" }
    )
    $script:Indeterminate = @(
        @{ Command = 'git worktree remove' }
        @{ Command = "git worktree remove $P $Q" }
        @{ Command = 'git worktree remove $p' }
        @{ Command = "bash -c 'git worktree remove >/dev/null $P'" }
        @{ Command = "echo $P | xargs git worktree remove" }
        @{ Command = "pwsh -c 'git worktree remove (Join-Path /repo/worktrees item-a-101)'" }
        @{ Command = "git worktree remove $P --unknown X" }
        @{ Command = "git worktree remove ""$P" }
    )
    $script:XRows = @(
        @{ Name = 'X1'; Command = "bash -c 'echo $P | xargs git worktree remove'" }
        @{ Name = 'X2'; Command = "echo $P | xargs git worktree remove" }
        @{ Name = 'X3'; Command = "pwsh -c 'git worktree remove (Join-Path /repo/worktrees item-a-101)'" }
        @{ Name = 'X4'; Command = "bash -c 'git worktree remove >/dev/null $P'" }
        @{ Name = 'X7'; Command = "pwsh -c 'git worktree remove --force (Get-Item $P)'" }
        @{ Name = 'X8'; Command = "bash -c 'printf ""%s"" $P | xargs git worktree remove --force'" }
        @{ Name = 'X10'; Command = "bash -c 'git worktree remove </dev/null $P'" }
    )
    $script:WIndeterminate = @(
        @{ Name = 'W1'; Command = "bash -c 'git worktree remove $Q; git worktree remove >/dev/null $P'" }
        @{ Name = 'W2'; Command = "bash -c 'git worktree remove $Q; echo $P | xargs git worktree remove'" }
        @{ Name = 'W3'; Command = "pwsh -c 'git worktree remove $Q; git worktree remove (Join-Path /repo/worktrees item-a-101)'" }
        @{ Name = 'W4'; Command = "bash -c 'git worktree remove $Q && git worktree remove </dev/null $P'" }
    )
    $script:WTargets = @(
        @{ Name = 'W5'; Command = "bash -c ""git worktree remove $Q""; bash -c ""git worktree remove $P""" }
        @{ Name = 'W6'; Command = "bash -c ""git worktree remove $Q"" && git worktree remove $P" }
    )
}

Describe 'hook-command-invocation-operands, <Runtime> copy (issue #824)' -ForEach $script:Runtimes {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $repoRoot "$HookRoot/hook-command-invocation.ps1")
        $script:P = '/repo/worktrees/item-a-101'
        $script:Q = '/repo/worktrees/item-b-102'

        function Resolve-RemovalTarget {
            <# Resolve the git worktree remove targets of one command text. #>
            param([Parameter(Mandatory)][AllowEmptyString()][string] $CommandText)
            return Resolve-CommandLineInvocationTarget -CommandText $CommandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove')
        }

        function Get-DeclaredParameterName {
            <# Return a function's declared parameter names, common parameters removed. #>
            param([Parameter(Mandatory)][string] $Name)
            $command = Get-Command -Name $Name -CommandType Function
            $common = @([System.Management.Automation.PSCmdlet]::CommonParameters) +
            @([System.Management.Automation.PSCmdlet]::OptionalCommonParameters)
            return @($command.Parameters.Keys | Where-Object { $common -notcontains $_ } | Sort-Object)
        }
    }

    It 'OP-01 pins the resolver parameter list, OutputType, and result shape' -Tag 'Issue824' {
        $command = Get-Command -Name 'Resolve-CommandLineInvocationTarget' -CommandType Function
        $result = Resolve-RemovalTarget -CommandText "git worktree remove $script:P"

        (Get-DeclaredParameterName -Name 'Resolve-CommandLineInvocationTarget') -join ',' | Should -Be 'CommandText,CommandWord,SubcommandPath'
        $command.OutputType[0].Type | Should -Be ([pscustomobject])
        (@($result.PSObject.Properties.Name) | Sort-Object) -join ',' | Should -Be 'Status,Targets'
    }

    It 'OP-02 returns NoMatch for git status' -Tag 'Issue824' {
        $result = Resolve-RemovalTarget -CommandText 'git status'

        $result.Status | Should -Be 'NoMatch'
        @($result.Targets).Count | Should -Be 0
    }

    It 'OP-03 resolves F1, the bare removal' -Tag 'Issue824' {
        $result = Resolve-RemovalTarget -CommandText "git worktree remove $script:P"

        $result.Status | Should -Be 'Targets'
        ($result.Targets -join ',') | Should -Be $script:P
    }

    It 'OP-04 resolves F2, the --force removal' -Tag 'Issue824' {
        $result = Resolve-RemovalTarget -CommandText "git worktree remove --force $script:P"

        $result.Status | Should -Be 'Targets'
        ($result.Targets -join ',') | Should -Be $script:P
    }

    It 'OP-05 resolves F3, the relocated -C removal' -Tag 'Issue824' {
        $result = Resolve-RemovalTarget -CommandText "git -C /repo/main worktree remove $script:P"

        $result.Status | Should -Be 'Targets'
        ($result.Targets -join ',') | Should -Be $script:P
    }

    It 'OP-06 resolves the wrapped removal <Name>' -Tag 'Issue824' -ForEach $script:F4F5 {
        $result = Resolve-RemovalTarget -CommandText $Command

        $result.Status | Should -Be 'Targets'
        ($result.Targets -join ',') | Should -Be '/repo/worktrees/item-a-101'
    }

    It 'OP-07 returns every target of a chained removal in source order' -Tag 'Issue824' {
        $result = Resolve-RemovalTarget -CommandText "git worktree remove $script:Q && git worktree remove $script:P"

        $result.Status | Should -Be 'Targets'
        ($result.Targets -join ',') | Should -Be "$script:Q,$script:P"
    }

    It 'OP-08 returns a repeated target once' -Tag 'Issue824' {
        $result = Resolve-RemovalTarget -CommandText "git worktree remove $script:P; git worktree remove $script:P"

        ($result.Targets -join ',') | Should -Be $script:P
    }

    It 'OP-09 returns Indeterminate for <Command>' -Tag 'Issue824' -ForEach $script:Indeterminate {
        $result = Resolve-RemovalTarget -CommandText $Command

        $result.Status | Should -Be 'Indeterminate'
        @($result.Targets).Count | Should -Be 0
    }

    It 'OP-10 never returns Status Targets with an empty target list' -Tag 'Issue824' {
        $inputs = @('git status', "git worktree remove $script:P", "git worktree remove --force $script:P",
            "git -C /repo/main worktree remove $script:P", "pwsh -Command 'git worktree remove $script:P'",
            "bash -c ""git worktree remove $script:P""", "git worktree remove $script:Q && git worktree remove $script:P",
            "git worktree remove $script:P; git worktree remove $script:P", 'git worktree remove', "git worktree remove $script:P $script:Q",
            'git worktree remove $p', "echo $script:P | xargs git worktree remove", "git worktree remove ""$script:P")

        foreach ($text in $inputs) {
            $result = Resolve-RemovalTarget -CommandText $text
            ($result.Status -eq 'Targets' -and @($result.Targets).Count -eq 0) | Should -BeFalse -Because "input: $text"
        }
    }

    It 'OP-11 reads the operand of F5 from the wrapper payload' -Tag 'Issue824' {
        $operands = @(Get-CommandLineOperand -CommandText "bash -c ""git worktree remove $script:P""" -CommandWord 'git' -SubcommandPath @('worktree', 'remove'))

        ($operands -join ',') | Should -Be $script:P
    }

    It 'OP-12 reads flag values and flag presence from the wrapper payload' -Tag 'Issue824' {
        Get-CommandLineFlagValue -CommandText 'bash -c "gh pr merge --merge 688"' -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge' |
            Should -Be '688'
        Test-CommandLineFlag -CommandText 'bash -c "gh pr create --body x"' -CommandWord 'gh' -SubcommandPath @('pr', 'create') -FlagName '--body' |
            Should -BeTrue
    }

    It 'OP-13 reads nothing from an Indeterminate-only match' -Tag 'Issue824' {
        $text = 'git "x'

        @(Get-CommandLineOperand -CommandText $text -CommandWord 'git' -SubcommandPath @('worktree', 'remove')).Count | Should -Be 0
        Get-CommandLineFlagValue -CommandText $text -CommandWord 'git' -SubcommandPath @('worktree', 'remove') -FlagName '--force' | Should -BeNullOrEmpty
        Test-CommandLineFlag -CommandText $text -CommandWord 'git' -SubcommandPath @('worktree', 'remove') -FlagName '--force' | Should -BeFalse
    }

    It 'OP-14 returns Indeterminate for the prior-run row <Name>' -Tag 'Issue824' -ForEach $script:XRows {
        (Resolve-RemovalTarget -CommandText $Command).Status | Should -Be 'Indeterminate'
    }

    It 'OP-15 returns Indeterminate for the prior-run row <Name>' -Tag 'Issue824' -ForEach $script:WIndeterminate {
        (Resolve-RemovalTarget -CommandText $Command).Status | Should -Be 'Indeterminate'
    }

    It 'OP-15 returns both targets for the prior-run row <Name>' -Tag 'Issue824' -ForEach $script:WTargets {
        $result = Resolve-RemovalTarget -CommandText $Command

        $result.Status | Should -Be 'Targets'
        ($result.Targets -join ',') | Should -Be '/repo/worktrees/item-b-102,/repo/worktrees/item-a-101'
    }

    It 'OP-16 returns Indeterminate for the prior-run row B5' -Tag 'Issue824' {
        (Resolve-RemovalTarget -CommandText 'bash -c ''a="worktree remove"; git $a ../x''').Status | Should -Be 'Indeterminate'
    }
}
