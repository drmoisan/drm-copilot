#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Pester tests for .claude/lib/worktree-resolution/AgentTargetWorktree.psm1 (issue #1163).

.DESCRIPTION
    Runs the shared rows of AgentTargetWorktree.Rows.Helpers.ps1 against the imported module
    (D2 precedence, the coordinator-root set, the restored-host set, prunable exclusion, and
    both policies), the parity rows that replay every Resolve-HookTargetWorktree row of
    HookTargetWorktree.Rows.Helpers.ps1 through both resolvers, the porcelain filter rows,
    and the AST checks of the module source. Every worktree list is in-memory porcelain text
    supplied through an injected invoker; no test runs git, creates a file, or reads
    gitignored state.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'AgentTargetWorktree.Rows.Helpers.ps1')
    . (Join-Path $PSScriptRoot 'HookTargetWorktree.Rows.Helpers.ps1')
    $script:AgentRows = @(Get-AgentTargetWorktreeRows)
    $script:ParityRows = @(@(Get-HookTargetWorktreeResolverRows) + @(Get-HookTargetWorktreeIdentityRows) | Where-Object { -not $_.ContainsKey('Check') })
}

BeforeAll {
    . (Join-Path $PSScriptRoot 'AgentTargetWorktree.Rows.Helpers.ps1')
    . (Join-Path $PSScriptRoot 'HookTargetWorktree.Rows.Helpers.ps1')
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
    $script:ModulePath = Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/AgentTargetWorktree.psm1'
    $script:HookTargetPath = Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/HookTargetWorktree.psm1'
    Import-Module $script:ModulePath -Force -ErrorAction Stop
    Import-Module $script:HookTargetPath -ErrorAction Stop
}

AfterAll {
    Remove-Module -Name AgentTargetWorktree -ErrorAction SilentlyContinue
    Remove-Module -Name HookTargetWorktree -ErrorAction SilentlyContinue
}

Describe 'AgentTargetWorktree module implementation guard' {
    It 'answers every row from the imported AgentTargetWorktree module' {
        (Get-Command -Name Resolve-AgentTargetWorktree).Source | Should -Be 'AgentTargetWorktree'
        (Get-Command -Name ConvertTo-AgentTargetLiveWorktreeListText).Source | Should -Be 'AgentTargetWorktree'
    }
}

Describe 'Resolve-AgentTargetWorktree shared rows' {
    It '<Name>' -ForEach $script:AgentRows {
        Assert-AgentTargetWorktreeRow -Row $_
    }
}

Describe 'Resolve-AgentTargetWorktree restored-host companion' {
    It 'Resolve-HookTargetWorktree returns TARGET_WORKTREE_AMBIGUOUS for the restored-host branch input' {
        # Arrange
        $row = @{ InvokerKind = 'Porcelain'; Porcelain = (Get-AgentTargetWorktreePorcelain -Topology Restored); Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = 'branch: bug/item' } }

        # Act
        $outcome = Invoke-AgentTargetWorktreeRow -Row $row -Function 'Resolve-HookTargetWorktree'

        # Assert
        $outcome.Output[0].ReasonCode | Should -BeExactly 'TARGET_WORKTREE_AMBIGUOUS'
        $outcome.Output[0].WorktreeRoot | Should -BeNullOrEmpty
    }
}

Describe 'Resolve-AgentTargetWorktree parity with Resolve-HookTargetWorktree' {
    It 'parity <Name>' -ForEach $script:ParityRows {
        # Arrange: the same arguments and invoker through both resolvers.
        $hookOutcome = Invoke-HookTargetWorktreeRow -Row $_
        $agentRow = @{} + $_
        $agentRow.Arguments = @{} + $_.Arguments
        $agentRow.Arguments['Policy'] = 'FailClosedOnIdentity'

        # Act
        $agentRow.Function = 'Resolve-AgentTargetWorktree'
        $agentOutcome = Invoke-HookTargetWorktreeRow -Row $agentRow

        # Assert
        $hook = $hookOutcome.Output[0]
        $agent = $agentOutcome.Output[0]
        $agent.WorktreeRoot | Should -Be $hook.WorktreeRoot
        $agent.ReasonCode | Should -Be $hook.ReasonCode
        $agent.Source | Should -BeExactly $hook.Source
        $agent.Unresolved | Should -Be ($null -ne $hook.ReasonCode)
    }
}

Describe 'ConvertTo-AgentTargetLiveWorktreeListText' {
    It 'drops a prunable record, keeps the live records, and returns the dropped record' {
        # Act
        $live = ConvertTo-AgentTargetLiveWorktreeListText -Text (Get-AgentTargetWorktreePorcelain -Topology Restored)

        # Assert
        $live.Text | Should -BeExactly "worktree /repo`nbranch refs/heads/main`n`nworktree /repo/.claude/worktrees/item`nbranch refs/heads/bug/item`n"
        @($live.Dropped).Count | Should -Be 1
        $live.Dropped[0].Root | Should -BeExactly '/host-a/repo/.claude/worktrees/item'
        $live.Dropped[0].Branch | Should -BeExactly 'bug/item'
    }

    It 'renders a detached record with a detached line' {
        # Act
        $live = ConvertTo-AgentTargetLiveWorktreeListText -Text "worktree /repo-wt/detached`nHEAD 4444444444444444444444444444444444444444`ndetached`n"

        # Assert
        $live.Text | Should -BeExactly "worktree /repo-wt/detached`ndetached`n"
        @($live.Dropped).Count | Should -Be 0
    }

    It 'returns empty text and no dropped record for empty input' {
        # Act
        $live = ConvertTo-AgentTargetLiveWorktreeListText -Text ''

        # Assert
        $live.Text | Should -BeExactly ''
        @($live.Dropped).Count | Should -Be 0
    }

    It 'round-trips the live text through the porcelain parser' {
        # Act
        $live = ConvertTo-AgentTargetLiveWorktreeListText -Text (Get-AgentTargetWorktreePorcelain -Topology Live)
        $records = @(ConvertFrom-HookTargetWorktreePorcelain -Text $live.Text)

        # Assert
        ($records.Root -join ',') | Should -BeExactly '/repo,/repo/.claude/worktrees/item,/repo-wt/sibling'
        ($records.Branch -join ',') | Should -BeExactly 'main,bug/item,bug/sibling'
    }
}

Describe 'Resolve-AgentTargetWorktree parameters' {
    It 'declares the nine parameters with SessionRoot mandatory and the two policies' {
        # Arrange
        $command = Get-Command -Name Resolve-AgentTargetWorktree -CommandType Function
        $common = @([System.Management.Automation.PSCmdlet]::CommonParameters) + @([System.Management.Automation.PSCmdlet]::OptionalCommonParameters)

        # Act
        $declared = @($command.Parameters.Keys | Where-Object { $common -notcontains $_ })
        $policy = $command.Parameters['Policy'].Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }

        # Assert
        ($declared -join ',') | Should -BeExactly 'SessionRoot,FilePath,CommandOperandPath,CommandBranch,DelegationPrompt,AgentWorkingDirectory,Policy,WorktreeListInvoker,CheckpointIssueReader'
        $command.Parameters['SessionRoot'].Attributes.Where({ $_ -is [System.Management.Automation.ParameterAttribute] })[0].Mandatory | Should -BeTrue
        ($policy.ValidValues -join ',') | Should -BeExactly 'SessionFallback,FailClosedOnIdentity'
    }
}

Describe 'AgentTargetWorktree module source (AST)' {
    BeforeAll {
        $tokens = $null
        $parseErrors = $null
        $script:Ast = [System.Management.Automation.Language.Parser]::ParseFile($script:ModulePath, [ref] $tokens, [ref] $parseErrors)
        $script:ParseErrors = $parseErrors
        $script:Functions = @($script:Ast.EndBlock.Statements | Where-Object { $_ -is [System.Management.Automation.Language.FunctionDefinitionAst] })
        $resolver = $script:Functions | Where-Object { $_.Name -eq 'Resolve-AgentTargetWorktree' }
        $invokerParameter = $resolver.Body.ParamBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'WorktreeListInvoker' }
        $script:Invoker = $invokerParameter.DefaultValue
        $script:Commands = @($script:Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))
    }

    It 'parses without error and sets Set-StrictMode -Version Latest at module scope' {
        @($script:ParseErrors).Count | Should -Be 0
        @($script:Ast.EndBlock.Statements | Where-Object { $_.Extent.Text -ceq 'Set-StrictMode -Version Latest' }).Count | Should -Be 1
    }

    It 'imports only HookTargetWorktree.psm1, with -ErrorAction Stop' {
        $imports = @($script:Commands | Where-Object { $_.GetCommandName() -eq 'Import-Module' })
        $imports.Count | Should -Be 1
        $imports[0].Extent.Text | Should -Match 'HookTargetWorktree\.psm1'
        $imports[0].Extent.Text | Should -Match '-ErrorAction Stop'
    }

    It 'references no script-scope variable inside any function' {
        $scriptReferences = foreach ($function in $script:Functions) {
            $function.FindAll({ param($node) $node -is [System.Management.Automation.Language.VariableExpressionAst] -and $node.VariablePath.IsScript }, $true)
        }
        @($scriptReferences).Count | Should -Be 0
    }

    It 'exports exactly the two functions through Export-ModuleMember' {
        $export = @($script:Commands | Where-Object { $_.GetCommandName() -eq 'Export-ModuleMember' })
        $export.Count | Should -Be 1
        $names = @($export[0].CommandElements | Select-Object -Skip 2 | ForEach-Object { $_.Extent.Text.Split(',') } | ForEach-Object { $_.Trim().Trim('`').Trim() } | Where-Object { $_ })
        ($names | Sort-Object) -join ',' | Should -BeExactly 'ConvertTo-AgentTargetLiveWorktreeListText,Resolve-AgentTargetWorktree'
        ($script:Functions.Name | Sort-Object) -join ',' | Should -BeExactly (($names | Sort-Object) -join ',')
    }

    It 'performs no process, file, environment, or clock call outside the default invoker body' {
        $invokerExtent = $script:Invoker.Extent
        $outside = { param($node) $node.Extent.StartOffset -lt $invokerExtent.StartOffset -or $node.Extent.EndOffset -gt $invokerExtent.EndOffset }
        $bannedCommands = @('Get-Content', 'Set-Content', 'Add-Content', 'Out-File', 'Test-Path', 'Get-Item', 'Get-ChildItem', 'Resolve-Path', 'New-Item', 'Remove-Item', 'Copy-Item', 'Move-Item', 'Get-Date', 'Get-Location', 'Set-Location', 'Import-PowerShellDataFile', 'Start-Process', 'Invoke-Expression', 'git')
        $functionCommands = foreach ($function in $script:Functions) { $function.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true) }
        $commandHits = @($functionCommands | Where-Object { (& $outside $_) -and $bannedCommands -contains $_.GetCommandName() })
        $environmentHits = @($script:Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.VariableExpressionAst] -and $node.VariablePath.DriveName -eq 'env' }, $true))
        $typeHits = @($script:Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.TypeExpressionAst] -and $node.TypeName.FullName -match '^(System\.)?(IO\.|Environment$|DateTime|DateTimeOffset$|Diagnostics\.|TimeProvider)' }, $true) | Where-Object { & $outside $_ })

        $commandHits.Count | Should -Be 0 -Because ($commandHits.Extent.Text -join '; ')
        $environmentHits.Count | Should -Be 0
        $typeHits.Count | Should -Be 0 -Because ($typeHits.Extent.Text -join '; ')
    }

    It 'runs git -C SessionRoot worktree list --porcelain in the default invoker with an empty result on non-zero exit' {
        $gitCommands = @($script:Invoker.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))
        $gitCommands.Count | Should -Be 1
        ($gitCommands[0].CommandElements.Extent.Text -join ' ') | Should -BeExactly 'git -C $SessionRoot worktree list --porcelain'
        $exitCheck = @($script:Invoker.FindAll({ param($node) $node -is [System.Management.Automation.Language.IfStatementAst] }, $true))
        $exitCheck.Count | Should -Be 1
        $exitCheck[0].Clauses[0].Item1.Extent.Text | Should -BeExactly '$LASTEXITCODE -ne 0'
    }
}
