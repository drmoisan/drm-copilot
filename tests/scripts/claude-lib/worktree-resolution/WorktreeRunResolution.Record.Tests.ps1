#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Record, operand, result-contract, purity, and export tests for the run resolver (issue #690).

.DESCRIPTION
    Covers Resolve-WorktreeRunTargetByRecord (pull request number and worktree path, epic
    and parallel), Resolve-WorktreeOperandTarget, the shared result shape and reason
    codes, the delegation of SessionRoot/OtherWorktree labelling to
    ConvertTo-WorktreeItemResolvedResult, a parse-tree purity scan of the module, and the
    export lists of the run resolver and the item resolver.

    The purity scan is an allow-list: every command the module invokes must be one of its
    own functions, a function its sibling modules export, or one of a fixed set of
    built-in cmdlets. A process launcher, an interpreter, or a web cmdlet is therefore
    rejected without this file naming one.

    Every enumeration and text read is mocked with -ModuleName 'WorktreeRunResolution'.
    Synthetic roots use the /synthetic-worktrees/<name> form. No test creates or writes a
    file, reads a wall clock, starts a process, or touches the network.
#>

BeforeAll {
    $script:LibRoot = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/worktree-resolution").Path
    $script:ModulePath = Join-Path $script:LibRoot 'WorktreeRunResolution.psm1'
    Import-Module $script:ModulePath
    Import-Module (Join-Path $script:LibRoot 'WorktreeItemResolution.psm1')
    Import-Module (Join-Path $script:LibRoot 'WorktreeResolution.psm1')
    Import-Module (Join-Path $script:LibRoot 'WorktreeTargetResolution.psm1')

    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
    $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode
    $script:Session = '/synthetic-worktrees/session'

    # Register the module-scoped seam mocks. Epic and Parallel map a root to the text of
    # that root's epic or parallel checkpoint; an absent key models no checkpoint.
    function Set-RecordTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string[]] $Live = @(), [hashtable] $Epic = @{}, [hashtable] $Parallel = @{})
        $liveSet = $Live
        $textMap = @{}
        foreach ($root in $Epic.Keys) { $textMap["$root/artifacts/orchestration/epic-orchestrator-state.json"] = $Epic[$root] }
        foreach ($root in $Parallel.Keys) { $textMap["$root/artifacts/orchestration/parallel-orchestrator-state.json"] = $Parallel[$root] }
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -MockWith {
            return , [string[]] $liveSet
        }.GetNewClosure()
        Mock -CommandName Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution -MockWith {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
    }

    # Place operands by prefix: a path under a listed root ascends to that root.
    function Set-OperandTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string[]] $Root = @())
        $roots = $Root
        Mock -CommandName Find-WorktreeResolutionRoot -ModuleName WorktreeRunResolution -MockWith {
            param([string] $Path)
            foreach ($candidate in $roots) {
                if ($Path -eq $candidate -or $Path.StartsWith($candidate + '/')) { return $candidate }
            }
            return $null
        }.GetNewClosure()
    }

    $script:ModuleAst = [System.Management.Automation.Language.Parser]::ParseFile($script:ModulePath, [ref] $null, [ref] $null)
    $script:CommandNodes = @($script:ModuleAst.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true))

    # Return the name of the function enclosing a parse-tree node, or $null at module scope.
    function Get-EnclosingFunctionName {
        param($Node)
        $parent = $Node.Parent
        while ($null -ne $parent) {
            if ($parent -is [System.Management.Automation.Language.FunctionDefinitionAst]) { return $parent.Name }
            $parent = $parent.Parent
        }
        return $null
    }

    # Return the invoked command names that are neither the module's own functions, a
    # sibling module's exports, nor one of the fixed built-in cmdlets the module needs.
    function Get-DisallowedCommandName {
        $own = @($script:ModuleAst.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) |
                ForEach-Object { $_.Name })
        $siblings = foreach ($name in @('WorktreeResolution', 'WorktreeTargetResolution', 'WorktreeItemResolution')) {
            (Get-Module -Name $name | Select-Object -First 1).ExportedFunctions.Keys
        }
        $builtins = @('Set-StrictMode', 'Import-Module', 'Join-Path', 'Test-Path', 'ConvertFrom-Json', 'Where-Object', 'Export-ModuleMember')
        $allowed = @($own) + @($siblings) + $builtins
        return @($script:CommandNodes | ForEach-Object { $_.GetCommandName() } | Where-Object { $_ -and ($allowed -notcontains $_) } | Sort-Object -Unique)
    }
}

Describe 'Resolve-WorktreeRunTargetByRecord' {
    It 'B1 resolves an epic run by epic_merge_pr.pr_number' {
        # Arrange
        Set-RecordTopology -Live @('/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = '{"route_id":"epic","epic_merge_pr":{"pr_number":812}}' }

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind epic -RecordField pr_number -Value '812' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be '/synthetic-worktrees/w-epic'
    }

    It 'B2 resolves an epic run by features[].pr_number' {
        # Arrange
        Set-RecordTopology -Live @('/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = '{"route_id":"epic","features":[{"pr_number":"812"}]}' }

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind epic -RecordField pr_number -Value '812' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
    }

    It 'B3 resolves an epic run by features[].worktree_path across separator style and trailing slash' {
        # Arrange: the checkpoint records a backslash path with a trailing separator.
        Set-RecordTopology -Live @('/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = '{"route_id":"epic","features":[{"worktree_path":"C:\\wt\\child\\"}]}' }

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind epic -RecordField worktree_path -Value 'C:/wt/child' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
    }

    It 'B4 resolves a parallel run by items[].pr_number' {
        # Arrange
        Set-RecordTopology -Live @('/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = '{"route_id":"parallel","items":[{"pr_number":812}]}' }

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField pr_number -Value '812' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be '/synthetic-worktrees/w-par'
    }

    It 'B5 resolves a parallel run by items[].worktree_path' {
        # Arrange
        Set-RecordTopology -Live @('/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = '{"route_id":"parallel","items":[{"worktree_path":"/wt/item-a"}]}' }

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField worktree_path -Value '/wt/item-a/' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
    }

    It 'B6 resolves NoTarget when no live root records the value' {
        # Arrange
        Set-RecordTopology -Live @('/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = '{"route_id":"parallel","items":[{"pr_number":811}]}' }

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField pr_number -Value '812' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
        $target.ReasonCode | Should -Be $script:NoTargetCode
    }

    It 'B7 resolves Ambiguous when two live roots record the value' {
        # Arrange
        $json = '{"route_id":"parallel","items":[{"pr_number":812}]}'
        Set-RecordTopology -Live @('/synthetic-worktrees/a', '/synthetic-worktrees/b') -Parallel @{ '/synthetic-worktrees/a' = $json; '/synthetic-worktrees/b' = $json }

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField pr_number -Value '812' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'Ambiguous'
        $target.Detail | Should -Match 'pr_number'
        $target.Detail | Should -Match '812'
    }

    It 'B8 resolves NoTarget for a blank value without enumerating live roots' {
        # Arrange
        Set-RecordTopology -Live @('/synthetic-worktrees/w-par')

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField worktree_path -Value '' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
        Should -Invoke Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -Times 0 -Exactly
    }

    It 'B9 resolves NoTarget for a non-numeric pull request value without enumerating live roots' {
        # Arrange
        Set-RecordTopology -Live @('/synthetic-worktrees/w-par')

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind epic -RecordField pr_number -Value '12a' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
        Should -Invoke Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -Times 0 -Exactly
    }

    It 'B10 does not match an epic lookup against a checkpoint whose route_id is parallel' {
        # Arrange: the epic checkpoint path holds a parallel-route record.
        Set-RecordTopology -Live @('/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = '{"route_id":"parallel","features":[{"pr_number":812}]}' }

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind epic -RecordField pr_number -Value '812' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
    }

    It 'B11 compares drive-letter paths case-insensitively' {
        # Arrange
        Set-RecordTopology -Live @('/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = '{"route_id":"parallel","items":[{"worktree_path":"c:\\wt\\a\\"}]}' }

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField worktree_path -Value 'C:/Wt/A' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
    }

    It 'B12 compares slash-rooted paths case-sensitively' {
        # Arrange
        Set-RecordTopology -Live @('/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = '{"route_id":"parallel","items":[{"worktree_path":"/wt/a"}]}' }

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField worktree_path -Value '/wt/A' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
    }

    It 'B13 resolves NoTarget for a pull request value too large for a 64-bit integer without enumerating live roots' {
        # Arrange: a recorded checkpoint would make an unguarded conversion throw.
        Set-RecordTopology -Live @('/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = '{"route_id":"epic","features":[{"pr_number":812}]}' }

        # Act
        $target = Resolve-WorktreeRunTargetByRecord -Kind epic -RecordField pr_number -Value '12345678901234567890' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'NoTarget'
        $target.ReasonCode | Should -Be $script:NoTargetCode
        Should -Invoke Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -Times 0 -Exactly
    }
}

Describe 'Resolve-WorktreeOperandTarget' {
    It 'Q1 places an absolute operand inside another worktree in that worktree' {
        # Arrange
        Set-OperandTopology -Root @($script:Session, '/synthetic-worktrees/w-item')

        # Act
        $target = Resolve-WorktreeOperandTarget -Path '/synthetic-worktrees/w-item/scripts/Sample.ps1' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'OtherWorktree'
        $target.WorktreeRoot | Should -Be '/synthetic-worktrees/w-item'
    }

    It 'Q2 places an operand inside the session worktree at the session root' {
        # Arrange
        Set-OperandTopology -Root @($script:Session, '/synthetic-worktrees/w-item')

        # Act
        $target = Resolve-WorktreeOperandTarget -Path "$($script:Session)/scripts/Sample.ps1" -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'SessionRoot'
    }

    It 'Q3 evaluates an operand in no worktree against the session worktree' {
        # Arrange
        Set-OperandTopology -Root @($script:Session)

        # Act
        $target = Resolve-WorktreeOperandTarget -Path '/elsewhere/scripts/Sample.ps1' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'SessionRoot'
        $target.WorktreeRoot | Should -Be $script:Session
        $target.Detail | Should -Match 'lies in no worktree'
    }

    It 'Q4 evaluates a blank operand against the session worktree' {
        # Arrange
        Set-OperandTopology -Root @($script:Session)

        # Act
        $target = Resolve-WorktreeOperandTarget -Path '' -SessionRoot $script:Session

        # Assert
        $target.Status | Should -Be 'SessionRoot'
    }

    It 'Q5 joins a relative operand to the session root before placing it' {
        # Arrange
        Set-OperandTopology -Root @($script:Session)

        # Act
        $null = Resolve-WorktreeOperandTarget -Path 'scripts/Sample.ps1' -SessionRoot $script:Session

        # Assert
        Should -Invoke Find-WorktreeResolutionRoot -ModuleName WorktreeRunResolution -Times 1 -Exactly -ParameterFilter {
            $Path -eq '/synthetic-worktrees/session/scripts/Sample.ps1'
        }
    }
}

Describe 'Run resolver result contract' {
    It 'C1 returns the full result shape and accessor reason code for <Label>' -ForEach @(
        @{ Label = 'an epic NoTarget'; Case = 'epic'; ExpectedStatus = 'NoTarget' }
        @{ Label = 'a parallel Ambiguous'; Case = 'parallel'; ExpectedStatus = 'Ambiguous' }
        @{ Label = 'a record OtherWorktree'; Case = 'record'; ExpectedStatus = 'OtherWorktree' }
        @{ Label = 'an operand SessionRoot'; Case = 'operand'; ExpectedStatus = 'SessionRoot' }
    ) {
        # Arrange: two parallel checkpoints share the slug, and only one records PR 812.
        $json = '{"route_id":"parallel","parallel_slug":"wave-a","items":[{"pr_number":812}]}'
        Set-RecordTopology -Live @('/synthetic-worktrees/a', '/synthetic-worktrees/b') -Parallel @{ '/synthetic-worktrees/a' = $json; '/synthetic-worktrees/b' = $json.Replace('812', '900') }
        Set-OperandTopology -Root @($script:Session)

        # Act
        $target = switch ($Case) {
            'epic' { Resolve-WorktreeEpicTarget -IntegrationBranch 'epic/none-integration' -SessionRoot $script:Session }
            'parallel' { Resolve-WorktreeParallelTarget -ParallelSlug 'wave-a' -SessionRoot $script:Session }
            'record' { Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField pr_number -Value '812' -SessionRoot $script:Session }
            'operand' { Resolve-WorktreeOperandTarget -Path '' -SessionRoot $script:Session }
        }

        # Assert
        $target.Status | Should -Be $ExpectedStatus
        foreach ($name in @('Status', 'WorktreeRoot', 'SessionRoot', 'Signal', 'SignalValue', 'Candidates', 'ReasonCode', 'Detail')) {
            $target.PSObject.Properties.Name | Should -Contain $name
        }
        $expectedCode = switch ($ExpectedStatus) {
            'NoTarget' { $script:NoTargetCode }
            'Ambiguous' { $script:AmbiguityCode }
            default { $null }
        }
        $target.ReasonCode | Should -Be $expectedCode
    }

    It 'C2 delegates SessionRoot and OtherWorktree labelling to ConvertTo-WorktreeItemResolvedResult' {
        # Arrange
        Set-RecordTopology -Live @('/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = '{"route_id":"epic","integration_branch":"epic/repro-integration"}' }
        Mock -CommandName ConvertTo-WorktreeItemResolvedResult -ModuleName WorktreeRunResolution -MockWith {
            [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/stub'; ReasonCode = $null; Detail = 'stub' }
        }

        # Act
        $target = Resolve-WorktreeEpicTarget -IntegrationBranch 'epic/repro-integration' -SessionRoot $script:Session

        # Assert: the stub comes back unchanged, so the labelling is not reimplemented here.
        $target.WorktreeRoot | Should -Be '/synthetic-worktrees/stub'
        Should -Invoke ConvertTo-WorktreeItemResolvedResult -ModuleName WorktreeRunResolution -Times 1 -Exactly
    }
}

Describe 'Run resolver purity (parse-tree scan)' {
    It 'U1 confines every filesystem read to Get-WorktreeRunCheckpointText' {
        # Arrange
        $readCommands = @('Test-Path', 'Get-Content', 'Get-ChildItem', 'Get-Item')
        $commands = @($script:CommandNodes | Where-Object { $readCommands -contains $_.GetCommandName() })
        $members = @($script:ModuleAst.FindAll({
                    $args[0] -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and
                    $args[0].Expression -is [System.Management.Automation.Language.TypeExpressionAst] -and
                    $args[0].Expression.TypeName.FullName -match '^(System\.)?IO\.File$'
                }, $true))

        # Act
        $outside = @(@($commands) + @($members) | Where-Object { (Get-EnclosingFunctionName -Node $_) -ne 'Get-WorktreeRunCheckpointText' })

        # Assert
        ($commands.Count + $members.Count) | Should -BeGreaterThan 0
        $outside.Count | Should -Be 0
    }

    It 'U2 invokes only allow-listed commands and never a string as a command' {
        # Arrange / Act
        $disallowed = @(Get-DisallowedCommandName)
        $stringCalls = @($script:CommandNodes | Where-Object {
                $_.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Ampersand -and
                $_.CommandElements[0] -is [System.Management.Automation.Language.StringConstantExpressionAst]
            })

        # Assert: a process launcher, an interpreter, or git is outside the allow-list.
        $disallowed | Should -BeNullOrEmpty -Because ($disallowed -join ', ')
        $stringCalls.Count | Should -Be 0
    }

    It 'U3 reads no environment variable, clock, location, or network type' {
        # Arrange
        $clockOrLocation = @($script:CommandNodes | Where-Object { @('Get-Date', 'Get-Location') -contains $_.GetCommandName() })
        $environment = @($script:ModuleAst.FindAll({
                    $args[0] -is [System.Management.Automation.Language.VariableExpressionAst] -and
                    $args[0].VariablePath.DriveName -eq 'env'
                }, $true))
        $types = @($script:ModuleAst.FindAll({ $args[0] -is [System.Management.Automation.Language.TypeExpressionAst] }, $true))

        # Act
        $clock = @($types | Where-Object { $_.TypeName.FullName -match 'DateTime' -and $_.Parent.Member.Value -eq 'Now' })
        $network = @($types | Where-Object { $_.TypeName.FullName -match '^System\.Net' })

        # Assert: web cmdlets are excluded by the U2 allow-list, which this row re-asserts.
        $clockOrLocation.Count | Should -Be 0
        $environment.Count | Should -Be 0
        $clock.Count | Should -Be 0
        $network.Count | Should -Be 0
        @(Get-DisallowedCommandName) | Should -BeNullOrEmpty
    }
}

Describe 'Resolver module exports' {
    It 'X1 exports exactly the seven run-resolver functions' {
        # Arrange
        $expected = @(
            'Find-WorktreeRunIdentitySignal', 'Get-WorktreeRunCheckpointPath', 'Get-WorktreeRunCheckpointText',
            'Resolve-WorktreeEpicTarget', 'Resolve-WorktreeOperandTarget', 'Resolve-WorktreeParallelTarget',
            'Resolve-WorktreeRunTargetByRecord'
        )

        # Act
        $exported = @((Get-Module -Name WorktreeRunResolution | Select-Object -First 1).ExportedFunctions.Keys | Sort-Object)

        # Assert
        $exported | Should -Be ($expected | Sort-Object)
    }

    It 'X2 exports ConvertTo-WorktreeItemResolvedResult from the item resolver' {
        # Arrange / Act
        $exported = @((Get-Module -Name WorktreeItemResolution | Select-Object -First 1).ExportedFunctions.Keys)

        # Assert
        $exported | Should -Contain 'ConvertTo-WorktreeItemResolvedResult'
    }
}
