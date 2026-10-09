#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Item resolution by pull request number (issue #850).

.DESCRIPTION
    Covers Resolve-WorktreeItemTargetByPrNumber: a pull request number recorded in a live
    worktree's pr_gate.pr_number or in a standalone_merge_authorizations entry resolves
    that worktree; none resolves NoTarget; several resolve Ambiguous with no tie-break.
    A standalone pr_number counts only when it is a positive JSON integer.

    Worktree topologies are modelled by mocks registered with -ModuleName
    'WorktreeItemResolution', because the enumeration and the checkpoint read run inside
    that module. No test creates, writes, or reads a file, reads a wall clock, spawns a
    process, or touches the network. Synthetic roots use the /synthetic-worktrees/<name>
    form, and both reason codes come only from the worktree-resolution accessors.
#>

BeforeAll {
    # Imported without -Force so the suite binds to the instance an earlier loader placed
    # in the session, which is the instance the module-scoped mocks replace.
    $script:LibRoot = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/worktree-resolution").Path
    Import-Module (Join-Path $script:LibRoot 'WorktreeItemResolution.psm1')
    Import-Module (Join-Path $script:LibRoot 'WorktreeResolution.psm1')
    Import-Module (Join-Path $script:LibRoot 'WorktreeTargetResolution.psm1')

    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
    $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode
    $script:Session = '/synthetic-worktrees/session'

    # Model the live worktrees and the orchestrator checkpoint text each one holds.
    function Set-ItemPrTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string[]] $Live = @(), [hashtable] $Text = @{})
        $liveSet = $Live
        $textMap = @{}
        foreach ($root in $Text.Keys) { $textMap["$root/artifacts/orchestration/orchestrator-state.json"] = $Text[$root] }
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution -MockWith { , [string[]] $liveSet }.GetNewClosure()
        Mock -CommandName Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution -MockWith {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
    }
}

Describe 'Resolve-WorktreeItemTargetByPrNumber' {
    It 'resolves the worktree whose pr_gate records the pull request number' {
        # Arrange
        Set-ItemPrTopology -Live @('/synthetic-worktrees/item-a') -Text @{ '/synthetic-worktrees/item-a' = '{"pr_gate":{"pr_number":812}}' }

        # Act
        $target = Resolve-WorktreeItemTargetByPrNumber -PrNumber 812 -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be '/synthetic-worktrees/item-a'
    }

    It 'resolves the worktree whose standalone authorization records the pull request number' {
        # Arrange
        Set-ItemPrTopology -Live @('/synthetic-worktrees/item-a') -Text @{ '/synthetic-worktrees/item-a' = '{"standalone_merge_authorizations":[{"pr_number":812}]}' }

        # Act
        $target = Resolve-WorktreeItemTargetByPrNumber -PrNumber 812 -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be '/synthetic-worktrees/item-a'
    }

    It 'returns NoTarget when no checkpoint records the number' {
        # Arrange
        Set-ItemPrTopology -Live @('/synthetic-worktrees/item-a') -Text @{ '/synthetic-worktrees/item-a' = '{"pr_gate":{"pr_number":700}}' }

        # Act
        $target = Resolve-WorktreeItemTargetByPrNumber -PrNumber 812 -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
        $target.ReasonCode | Should -Be $script:NoTargetCode
    }

    It 'returns Ambiguous when several checkpoints record the number' {
        # Arrange
        Set-ItemPrTopology -Live @('/synthetic-worktrees/item-a', '/synthetic-worktrees/item-b') -Text @{
            '/synthetic-worktrees/item-a' = '{"pr_gate":{"pr_number":812}}'
            '/synthetic-worktrees/item-b' = '{"standalone_merge_authorizations":[{"pr_number":812}]}'
        }

        # Act
        $target = Resolve-WorktreeItemTargetByPrNumber -PrNumber 812 -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'Ambiguous'
        $target.ReasonCode | Should -Be $script:AmbiguityCode
        @($target.Candidates).Count | Should -Be 2
    }

    It 'reads only through the checkpoint-text seam' {
        # Arrange
        Set-ItemPrTopology -Live @('/synthetic-worktrees/item-a', '/synthetic-worktrees/item-b') -Text @{ '/synthetic-worktrees/item-a' = '{"pr_gate":{"pr_number":812}}' }
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $script:LibRoot 'WorktreeItemResolution.psm1'), [ref] $tokens, [ref] $errors)
        $names = @('Resolve-WorktreeItemTargetByPrNumber', 'Test-WorktreeItemCheckpointRecordsPr')
        $bodies = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $names -contains $node.Name }, $true) | ForEach-Object { $_.Extent.Text })

        # Act
        $null = Resolve-WorktreeItemTargetByPrNumber -PrNumber 812 -SessionRoot $script:Session

        # Assert
        Should -Invoke Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution -Times 2 -Exactly
        $bodies.Count | Should -Be 2 -Because 'both new functions are defined in the module'
        foreach ($forbidden in @('Get-Content', 'Test-Path', 'ReadAll')) {
            ($bodies -join "`n").Contains($forbidden) | Should -BeFalse -Because "the new functions must not read files directly ($forbidden)"
        }
    }

    It 'exports the item-by-PR resolver' {
        # Arrange
        $expected = @(
            'ConvertTo-WorktreeItemIssueNumber', 'ConvertTo-WorktreeItemResolvedResult', 'Find-WorktreeItemIssueSignal',
            'Get-WorktreeItemCheckpointIssue', 'Get-WorktreeItemCheckpointPath', 'Get-WorktreeItemCheckpointRelativePath',
            'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Resolve-WorktreeItemTarget',
            'Resolve-WorktreeItemTargetByPrNumber') | Sort-Object

        # Act
        $actual = @((Get-Module -Name WorktreeItemResolution | Select-Object -First 1).ExportedFunctions.Keys) | Sort-Object

        # Assert
        ($actual -join ',') | Should -BeExactly ($expected -join ',')
    }

    It 'ignores a standalone pr_number that is <Name>' -ForEach @(
        @{ Name = 'string'; Value = '"812"' }
        @{ Name = 'zero'; Value = '0' }
        @{ Name = 'negative'; Value = '-812' }
        @{ Name = 'fractional'; Value = '812.5' }
    ) {
        # Arrange
        Set-ItemPrTopology -Live @('/synthetic-worktrees/item-a') -Text @{ '/synthetic-worktrees/item-a' = ('{"standalone_merge_authorizations":[{"pr_number":' + $Value + '}]}') }

        # Act
        $target = Resolve-WorktreeItemTargetByPrNumber -PrNumber 812 -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget' -Because "a standalone pr_number that is $Name is not a positive JSON integer"
    }

    It 'skips an absent, empty, or unparseable checkpoint' {
        # Arrange
        Set-ItemPrTopology -Live @('/synthetic-worktrees/item-a', '/synthetic-worktrees/item-b', '/synthetic-worktrees/item-c') -Text @{
            '/synthetic-worktrees/item-b' = ''
            '/synthetic-worktrees/item-c' = '{ broken'
        }

        # Act
        $target = Resolve-WorktreeItemTargetByPrNumber -PrNumber 812 -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
        $target.ReasonCode | Should -Be $script:NoTargetCode
    }
}
