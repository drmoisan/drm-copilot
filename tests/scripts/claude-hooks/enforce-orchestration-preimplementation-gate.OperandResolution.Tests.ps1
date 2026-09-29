#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Operand resolution, import-failure, and read-literal rows for the preimplementation gate (issue #690).

.DESCRIPTION
    Covers the Write/Edit path leg and the Bash command leg, whose checkpoint is read
    beneath the worktree that contains the operand; the fail-closed import guard for the
    worktree-resolution modules; and a parse-tree scan showing that no checkpoint read in
    the gate or its siblings uses a relative literal.

    The outermost BeforeAll follows the epic-state isolation pattern: the hook is
    dot-sourced first, then EpicScopeResolution.psm1 and WorktreeRunResolution.psm1 are
    imported without -Force and their checkpoint-text seams are mocked $null, so no row
    reads an epic checkpoint on the host. Every checkpoint read seam is mocked; no test
    creates or writes a file, reads a wall clock, starts a process, or touches the network.
#>

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
    Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/EpicScopeResolution.psm1").Path
    Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
    Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1").Path
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    $libRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution").Path
    Import-Module (Join-Path $libRoot 'WorktreeTargetResolution.psm1')
    Import-Module (Join-Path $libRoot 'WorktreeResolution.psm1')
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')

    $script:Session = (Get-Location).Path.Replace([string][char]92, '/')
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks").Path
    $script:ItemRelative = 'artifacts/orchestration/orchestrator-state.json'
    $script:ReadyItem = '{"issue-num":"301","feature-folder":"docs/features/active/child-b-301","route_id":"large","lifecycle_ready":true}'
    $script:UnreadyItem = '{"issue-num":"301","feature-folder":"docs/features/active/child-b-301","route_id":"large","lifecycle_ready":false}'

    function ConvertTo-WritePayload {
        param([string] $FilePath)
        return (@{ tool_name = 'Write'; tool_input = @{ file_path = $FilePath; content = 'x' } } | ConvertTo-Json -Compress -Depth 5)
    }

    function ConvertTo-BashPayload {
        param([string] $Command)
        return (@{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5)
    }

    # Replace the gate's resolution seam with a fixed target.
    function Set-GateSeamTarget {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string] $Status, [string] $WorktreeRoot = '')
        $target = New-WorktreeResolutionFixtureTarget -Status $Status -WorktreeRoot $WorktreeRoot -Candidate @('/synthetic-worktrees/a', '/synthetic-worktrees/b')
        Mock -CommandName Resolve-OrchestrationGateTarget -MockWith { $target }.GetNewClosure()
    }

    # Place operands by prefix for the real operand resolver: a path under w-item ascends
    # to w-item, and any other path to the session worktree.
    function Set-OperandPlacement {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param()
        $session = $script:Session
        Mock -CommandName Find-WorktreeResolutionRoot -ModuleName WorktreeRunResolution -MockWith {
            param([string] $Path)
            if ($Path.StartsWith('/synthetic-worktrees/w-item')) { return '/synthetic-worktrees/w-item' }
            return $session
        }.GetNewClosure()
    }
}

Describe 'preimplementation gate path leg' {
    It 'O1 admits a Write inside another worktree whose checkpoint is ready, reading that checkpoint' {
        # Arrange
        Set-GateSeamTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-item'
        $ready = $script:ReadyItem
        Mock -CommandName Get-CheckpointContent -MockWith { $ready }.GetNewClosure()

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-WritePayload -FilePath '/synthetic-worktrees/w-item/scripts/Sample.ps1')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq "/synthetic-worktrees/w-item/$script:ItemRelative" }
    }

    It 'O2 denies a Write inside another worktree whose checkpoint is not ready' {
        # Arrange
        Set-GateSeamTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-item'
        $unready = $script:UnreadyItem
        Mock -CommandName Get-CheckpointContent -MockWith { $unready }.GetNewClosure()

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-WritePayload -FilePath '/synthetic-worktrees/w-item/scripts/Sample.ps1')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'O3 denies a Write inside another worktree whose checkpoint is absent' {
        # Arrange
        Set-GateSeamTarget -Status 'OtherWorktree' -WorktreeRoot '/synthetic-worktrees/w-item'
        Mock -CommandName Get-CheckpointContent -MockWith { '' }

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-WritePayload -FilePath '/synthetic-worktrees/w-item/scripts/Sample.ps1')

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
    }

    It 'O6 decides a Write inside the session worktree exactly as the injected checkpoint' {
        # Arrange
        Set-OperandPlacement
        $ready = $script:ReadyItem
        Mock -CommandName Get-CheckpointContent -MockWith { $ready }.GetNewClosure()
        $payload = ConvertTo-WritePayload -FilePath "$($script:Session)/scripts/Sample.ps1"

        # Act
        $resolved = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload
        $injected = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $ready

        # Assert
        ($resolved | ConvertTo-Json -Compress -Depth 5) | Should -BeExactly ($injected | ConvertTo-Json -Compress -Depth 5)
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq "$($script:Session)/$script:ItemRelative" }
    }

    It 'O9 denies a Write whose target is ambiguous, naming the reason code and the detail' {
        # Arrange
        Set-GateSeamTarget -Status 'Ambiguous'

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-WritePayload -FilePath '/synthetic-worktrees/w-item/scripts/Sample.ps1')

        # Assert
        $reason = $decision.hookSpecificOutput.permissionDecisionReason
        $reason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        $reason | Should -Match (Get-WorktreeResolutionAmbiguityReasonCode)
        $reason | Should -Match 'modelled Ambiguous target'
    }
}

Describe 'preimplementation gate command leg' {
    It 'O4 reads the checkpoint of the worktree a git -C selector names' {
        # Arrange
        Set-OperandPlacement
        $ready = $script:ReadyItem
        Mock -CommandName Get-CheckpointContent -MockWith { $ready }.GetNewClosure()

        # Act
        $null = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-BashPayload -Command 'git -C /synthetic-worktrees/w-item add scripts/Sample.ps1')

        # Assert
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq "/synthetic-worktrees/w-item/$script:ItemRelative" }
    }

    It 'O5 reads the session worktree checkpoint for a command with no selector' {
        # Arrange
        Set-OperandPlacement
        $ready = $script:ReadyItem
        Mock -CommandName Get-CheckpointContent -MockWith { $ready }.GetNewClosure()

        # Act
        $null = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-BashPayload -Command 'git add scripts/Sample.ps1')

        # Assert
        Should -Invoke Get-CheckpointContent -Times 1 -Exactly -ParameterFilter { $Path -eq "$($script:Session)/$script:ItemRelative" }
    }
}

Describe 'preimplementation gate import failure' {
    It 'O7 denies naming WorktreeRunResolution.psm1 when that import failed, and the entry point exits 0' {
        # Arrange
        $payload = ConvertTo-BashPayload -Command 'git add scripts/Sample.ps1'
        $script:OrchestrationGateResolutionImportFailure = 'WorktreeRunResolution.psm1'
        try {
            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload
            $output = @(Invoke-OrchestrationPreimplementationGateEntryPoint -ToolInputRaw $payload)
        }
        finally {
            $script:OrchestrationGateResolutionImportFailure = $null
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'WorktreeRunResolution\.psm1'
        $output[-1] | Should -Be 0
        ($output[0..($output.Count - 2)] -join "`n") | Should -Match 'deny'
    }

    It 'O8 denies naming WorktreeItemResolution.psm1 when that import failed' {
        # Arrange
        $script:OrchestrationGateResolutionImportFailure = 'WorktreeItemResolution.psm1'
        try {
            # Act
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-BashPayload -Command 'git add scripts/Sample.ps1')
        }
        finally {
            $script:OrchestrationGateResolutionImportFailure = $null
        }

        # Assert
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'WorktreeItemResolution\.psm1'
    }
}

Describe 'preimplementation gate read literals (parse-tree scan)' {
    It 'O10 passes no relative checkpoint literal to Test-Path or Get-Content, and every read seam takes a mandatory Path' {
        # Arrange
        $files = @(
            'enforce-orchestration-preimplementation-gate.ps1'
            'enforce-orchestration-preimplementation-gate-epic-scope.ps1'
            'enforce-orchestration-preimplementation-gate-modes.ps1'
            'enforce-orchestration-preimplementation-gate-helpers.ps1'
        )
        $offenders = [System.Collections.Generic.List[string]]::new()
        $seams = @{}

        # Act
        foreach ($file in $files) {
            $ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $script:HookRoot $file), [ref] $null, [ref] $null)
            $reads = @($ast.FindAll({
                        $args[0] -is [System.Management.Automation.Language.CommandAst] -and
                        @('Test-Path', 'Get-Content') -contains $args[0].GetCommandName()
                    }, $true))
            foreach ($read in $reads) {
                foreach ($element in @($read.CommandElements | Select-Object -Skip 1)) {
                    $isLiteral = $element -is [System.Management.Automation.Language.StringConstantExpressionAst] -and $element.Value.StartsWith('artifacts/')
                    $isScriptPath = $element -is [System.Management.Automation.Language.VariableExpressionAst] -and $element.VariablePath.UserPath -match '^script:.*CheckpointPath$'
                    if ($isLiteral -or $isScriptPath) { $offenders.Add("${file}: $($read.Extent.Text)") }
                }
            }
            foreach ($function in @($ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true))) {
                if (@('Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent') -notcontains $function.Name) { continue }
                $parameter = @($function.Body.ParamBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'Path' })
                $mandatory = $parameter.Count -eq 1 -and ($parameter[0].Attributes.Extent.Text -join ' ') -match 'Mandatory'
                $seams[$function.Name] = $mandatory
            }
        }

        # Assert
        $offenders | Should -BeNullOrEmpty -Because ($offenders -join '; ')
        $seams.Count | Should -Be 3
        @($seams.Values | Where-Object { -not $_ }).Count | Should -Be 0
    }
}
