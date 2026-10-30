#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Pester tests for .claude/lib/worktree-resolution/HookTargetWorktree.psm1 (issue #1009).

.DESCRIPTION
    Runs the shared behavior rows of HookTargetWorktree.Rows.Helpers.ps1 against the
    imported module, and adds the module-only rows: the guard row proving the module
    answers, the reason-code equality with the WorktreeResolution.psm1 accessors, the AST
    checks of the module source, and the equality of Get-HookTargetWorktreeKey with the
    worktree-derived batch-budget session id. Every worktree list is in-memory porcelain
    text supplied through an injected invoker; no test runs git, creates a file, or reads
    gitignored state.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'HookTargetWorktree.Rows.Helpers.ps1')
    $script:HelperRows = @(Get-HookTargetWorktreeHelperRows)
    $script:PorcelainRows = @(Get-HookTargetWorktreePorcelainRows)
    $script:ResolverRows = @(Get-HookTargetWorktreeResolverRows)
    $script:IdentityRows = @(Get-HookTargetWorktreeIdentityRows)
}

BeforeAll {
    . (Join-Path $PSScriptRoot 'HookTargetWorktree.Rows.Helpers.ps1')
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
    $script:ModulePath = Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/HookTargetWorktree.psm1'
    Import-Module $script:ModulePath -Force -ErrorAction Stop

    function Assert-HookTargetWorktreeScalarRow {
        param([Parameter(Mandatory)] [hashtable] $Row)
        $outcome = Invoke-HookTargetWorktreeRow -Row $Row
        $outcome.Output.Count | Should -Be 1 -Because "row '$($Row.Name)' returns one value"
        $actual = $outcome.Output[0]
        if ($Row.ContainsKey('ExpectedPattern')) {
            $actual | Should -MatchExactly $Row.ExpectedPattern
        } elseif ($Row.ContainsKey('SameAs')) {
            $actual | Should -BeExactly (& $Row.Function -WorktreeRoot $Row.SameAs)
        } elseif ($null -eq $Row.Expected) {
            ($null -eq $actual) | Should -BeTrue -Because "row '$($Row.Name)' expects `$null, got '$actual'"
        } else {
            $actual | Should -BeExactly $Row.Expected
        }
    }

    function Assert-HookTargetWorktreeResolverRow {
        param([Parameter(Mandatory)] [hashtable] $Row)
        $outcome = Invoke-HookTargetWorktreeRow -Row $Row
        if ($Row.ContainsKey('Check')) {
            (@($outcome.Output) -join ',') | Should -BeExactly ($Row.ExpectedParameters -join ',')
            (@($outcome.Mandatory) -join ',') | Should -BeExactly ($Row.ExpectedMandatory -join ',')
            return
        }
        $outcome.Output.Count | Should -Be 1 -Because "row '$($Row.Name)' returns one result"
        $result = $outcome.Output[0]
        (@($result.PSObject.Properties.Name) -join ',') | Should -BeExactly 'WorktreeRoot,Source,Ambiguous,ReasonCode,Detail,Candidates'
        @('FilePath', 'CommandOperand', 'DelegationIdentity', 'SessionRoot') | Should -Contain $result.Source
        $result.Ambiguous | Should -BeOfType [bool]
        (@($null, 'TARGET_WORKTREE_AMBIGUOUS', 'TARGET_WORKTREE_NOT_DERIVABLE') -contains $result.ReasonCode) | Should -BeTrue
        $result.Ambiguous | Should -Be ($result.ReasonCode -eq 'TARGET_WORKTREE_AMBIGUOUS')
        if ($null -eq $result.WorktreeRoot) { ($result.Ambiguous -or $result.ReasonCode -eq 'TARGET_WORKTREE_NOT_DERIVABLE') | Should -BeTrue }
        foreach ($field in $Row.Expected.Keys) {
            $actualValue = switch ($field) {
                'InvokerCalls' { $outcome.InvokerCalls }
                'DetailNonEmpty' { -not [string]::IsNullOrEmpty($result.Detail) }
                default { $result.$field }
            }
            (@($actualValue) -join '|') | Should -BeExactly (@($Row.Expected[$field]) -join '|') -Because "field '$field' of row '$($Row.Name)' (detail: $($result.Detail))"
        }
    }
}

AfterAll {
    Remove-Module -Name HookTargetWorktree -Force -ErrorAction SilentlyContinue
}

Describe 'HookTargetWorktree module implementation guard' {
    It 'answers every row from the imported HookTargetWorktree module' {
        (Get-Command -Name Resolve-HookTargetWorktree).Module.Name | Should -Be 'HookTargetWorktree'
    }
}

Describe 'ConvertTo-HookTargetWorktreeNormalizedPath' {
    It '<Name>' -ForEach @($script:HelperRows | Where-Object { $_.Function -eq 'ConvertTo-HookTargetWorktreeNormalizedPath' }) {
        Assert-HookTargetWorktreeScalarRow -Row $_
    }
}

Describe 'Get-HookTargetWorktreeRelativePath' {
    It '<Name>' -ForEach @($script:HelperRows | Where-Object { $_.Function -eq 'Get-HookTargetWorktreeRelativePath' }) {
        Assert-HookTargetWorktreeScalarRow -Row $_
    }
}

Describe 'Get-HookTargetWorktreeEnclosingRoot' {
    It '<Name>' -ForEach @($script:HelperRows | Where-Object { $_.Function -eq 'Get-HookTargetWorktreeEnclosingRoot' }) {
        Assert-HookTargetWorktreeScalarRow -Row $_
    }
}

Describe 'Get-HookTargetWorktreeKey' {
    It '<Name>' -ForEach @($script:HelperRows | Where-Object { $_.Function -eq 'Get-HookTargetWorktreeKey' }) {
        Assert-HookTargetWorktreeScalarRow -Row $_
    }
}

Describe 'ConvertFrom-HookTargetWorktreePorcelain' {
    It '<Name>' -ForEach $script:PorcelainRows {
        $outcome = Invoke-HookTargetWorktreeRow -Row $_
        $outcome.Output.Count | Should -Be @($ExpectedRecords).Count
        for ($index = 0; $index -lt @($ExpectedRecords).Count; $index++) {
            $expected = @($ExpectedRecords)[$index]
            $record = $outcome.Output[$index]
            $record.Root | Should -BeExactly $expected.Root
            ($null -eq $record.Branch) | Should -Be ($null -eq $expected.Branch)
            if ($null -ne $expected.Branch) { $record.Branch | Should -BeExactly $expected.Branch }
            $record.Prunable | Should -Be $expected.Prunable
            $record.Bare | Should -BeFalse
        }
    }
}

Describe 'Resolve-HookTargetWorktree' {
    It '<Name>' -ForEach $script:ResolverRows {
        Assert-HookTargetWorktreeResolverRow -Row $_
    }
}

Describe 'Resolve-HookTargetWorktree ambiguity and identity' {
    It '<Name>' -ForEach $script:IdentityRows {
        Assert-HookTargetWorktreeResolverRow -Row $_
    }

    It 'emits reason codes equal to Get-WorktreeResolutionAmbiguityReasonCode and Get-WorktreeResolutionNoTargetReasonCode' {
        Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeResolution.psm1') -Force -ErrorAction Stop
        try {
            $porcelain = { param($SessionRoot) [void] $SessionRoot; "worktree /repo`nbranch refs/heads/main`n`nworktree /repo-wt/a`nbranch refs/heads/a`n" }
            $ambiguous = Resolve-HookTargetWorktree -SessionRoot '/repo' -FilePath '/repo/x.py', '/repo-wt/a/y.py' -WorktreeListInvoker $porcelain
            $notDerivable = Resolve-HookTargetWorktree -SessionRoot '/repo' -CommandBranch 'none' -WorktreeListInvoker $porcelain

            $ambiguous.ReasonCode | Should -BeExactly (Get-WorktreeResolutionAmbiguityReasonCode)
            $notDerivable.ReasonCode | Should -BeExactly (Get-WorktreeResolutionNoTargetReasonCode)
            'TARGET_WORKTREE_AMBIGUOUS' | Should -BeExactly (Get-WorktreeResolutionAmbiguityReasonCode)
            'TARGET_WORKTREE_NOT_DERIVABLE' | Should -BeExactly (Get-WorktreeResolutionNoTargetReasonCode)
        } finally {
            Remove-Module -Name WorktreeResolution -Force -ErrorAction SilentlyContinue
        }
    }
}

Describe 'HookTargetWorktree module source (AST)' {
    BeforeAll {
        $tokens = $null
        $parseErrors = $null
        $script:Ast = [System.Management.Automation.Language.Parser]::ParseFile($script:ModulePath, [ref] $tokens, [ref] $parseErrors)
        $script:ParseErrors = $parseErrors
        # Top-level functions only; the resolver's nested helpers are internal to its body.
        $script:Functions = @($script:Ast.EndBlock.Statements | Where-Object { $_ -is [System.Management.Automation.Language.FunctionDefinitionAst] })
        $resolver = $script:Functions | Where-Object { $_.Name -eq 'Resolve-HookTargetWorktree' }
        $invokerParameter = $resolver.Body.ParamBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'WorktreeListInvoker' }
        $script:Invoker = $invokerParameter.DefaultValue
        $script:Commands = @($script:Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))
    }

    It 'parses without error and sets Set-StrictMode -Version Latest at module scope' {
        @($script:ParseErrors).Count | Should -Be 0
        $strict = @($script:Ast.EndBlock.Statements | Where-Object { $_.Extent.Text -ceq 'Set-StrictMode -Version Latest' })
        $strict.Count | Should -Be 1
    }

    It 'imports no module and dot-sources no file' {
        @($script:Commands | Where-Object { $_.GetCommandName() -eq 'Import-Module' -or $_.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Dot }).Count | Should -Be 0
    }

    It 'references no script-scope variable inside any function' {
        $scriptReferences = foreach ($function in $script:Functions) {
            $function.FindAll({ param($node) $node -is [System.Management.Automation.Language.VariableExpressionAst] -and $node.VariablePath.IsScript }, $true)
        }
        @($scriptReferences).Count | Should -Be 0
    }

    It 'exports exactly the six functions through Export-ModuleMember' {
        $export = @($script:Commands | Where-Object { $_.GetCommandName() -eq 'Export-ModuleMember' })
        $export.Count | Should -Be 1
        $names = @($export[0].CommandElements | Select-Object -Skip 2 | ForEach-Object { $_.Extent.Text.Split(',') } | ForEach-Object { $_.Trim().Trim('`').Trim() } | Where-Object { $_ })
        ($names | Sort-Object) -join ',' | Should -BeExactly 'ConvertFrom-HookTargetWorktreePorcelain,ConvertTo-HookTargetWorktreeNormalizedPath,Get-HookTargetWorktreeEnclosingRoot,Get-HookTargetWorktreeKey,Get-HookTargetWorktreeRelativePath,Resolve-HookTargetWorktree'
        ($script:Functions.Name | Sort-Object) -join ',' | Should -BeExactly (($names | Sort-Object) -join ',')
    }

    It 'performs no file, environment, or clock read outside the default invoker body' {
        $invokerExtent = $script:Invoker.Extent
        $outside = { param($node) $node.Extent.StartOffset -lt $invokerExtent.StartOffset -or $node.Extent.EndOffset -gt $invokerExtent.EndOffset }
        $bannedCommands = @('Get-Content', 'Set-Content', 'Add-Content', 'Out-File', 'Test-Path', 'Get-Item', 'Get-ChildItem', 'Resolve-Path', 'New-Item', 'Remove-Item', 'Copy-Item', 'Move-Item', 'Get-Date', 'Get-Location', 'Set-Location', 'Import-PowerShellDataFile', 'git')
        $commandHits = @($script:Commands | Where-Object { (& $outside $_) -and $bannedCommands -contains $_.GetCommandName() })
        $environmentHits = @($script:Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.VariableExpressionAst] -and $node.VariablePath.DriveName -eq 'env' }, $true))
        $typeHits = @($script:Ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.TypeExpressionAst] -and $node.TypeName.FullName -match '^(System\.)?(IO\.|Environment$|DateTime|DateTimeOffset$|Diagnostics\.|TimeProvider)' }, $true) | Where-Object { & $outside $_ })

        $commandHits.Count | Should -Be 0 -Because ($commandHits.Extent.Text -join '; ')
        $environmentHits.Count | Should -Be 0
        $typeHits.Count | Should -Be 0 -Because ($typeHits.Extent.Text -join '; ')
    }

    It 'runs git -C SessionRoot worktree list --porcelain in the default invoker with no timeout and an empty result on non-zero exit' {
        $gitCommands = @($script:Invoker.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))
        $gitCommands.Count | Should -Be 1
        ($gitCommands[0].CommandElements.Extent.Text -join ' ') | Should -BeExactly 'git -C $SessionRoot worktree list --porcelain'
        $script:Invoker.Extent.Text | Should -Not -Match '(?i)timeout|Wait-|Start-Job|WaitForExit'
        $exitCheck = @($script:Invoker.FindAll({ param($node) $node -is [System.Management.Automation.Language.IfStatementAst] }, $true))
        $exitCheck.Count | Should -Be 1
        $exitCheck[0].Clauses[0].Item1.Extent.Text | Should -BeExactly '$LASTEXITCODE -ne 0'
        $exitCheck[0].Clauses[0].Item2.Extent.Text | Should -BeExactly "{ return '' }"
    }

    It 'keys a worktree root with the worktree-derived batch-budget session id algorithm' {
        $hookPath = Join-Path $script:RepoRoot '.claude/hooks/enforce-python-batch-budget.ps1'
        $hookAst = [System.Management.Automation.Language.Parser]::ParseFile($hookPath, [ref] $null, [ref] $null)
        $definitions = $hookAst.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and @('Get-PythonBatchBudgetSessionId', 'ConvertTo-PythonBatchBudgetSafeSegment') -contains $node.Name }, $true)
        . ([scriptblock]::Create((@($definitions) | ForEach-Object { $_.Extent.Text }) -join "`n"))
        $savedSessionId = $env:CLAUDE_SESSION_ID
        try {
            $env:CLAUDE_SESSION_ID = $null
            foreach ($root in @('/repo/.claude/worktrees/item', 'C:/Users/dev/repo-wt/my wt', '/repo')) {
                $sessionId = Get-PythonBatchBudgetSessionId -SessionId '' -Root $root -SessionIdFilePath "$root/.claude/state/current-session-id" -ReadSessionIdFile { param([string] $Path) [void] $Path; '' }
                $sessionId | Should -BeExactly ('worktree-' + (Get-HookTargetWorktreeKey -WorktreeRoot $root))
            }
        } finally {
            $env:CLAUDE_SESSION_ID = $savedSessionId
        }
    }
}
