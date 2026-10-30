#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity and behavior tests for the Codex twin .codex/hooks/hook-target-worktree.ps1 (issue #1009).

.DESCRIPTION
    Asserts that the twin defines the same function names as
    .claude/lib/worktree-resolution/HookTargetWorktree.psm1 with byte-identical function
    text (both files are parsed from the repository), and runs the four shared row lists of
    tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Rows.Helpers.ps1 against
    the dot-sourced twin, so every exported function and every resolver source branch runs
    against the twin. A guard row proves the twin, not the module, answers the rows. Every
    worktree list is in-memory porcelain text; no test runs git, creates a file, or reads
    gitignored state. The suite runs on the Linux hook-suite job, so every path is joined
    with Join-Path and spelled with forward slashes in exact case.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot '../claude-lib/worktree-resolution/HookTargetWorktree.Rows.Helpers.ps1')
    $script:HelperRows = @(Get-HookTargetWorktreeHelperRows)
    $script:PorcelainRows = @(Get-HookTargetWorktreePorcelainRows)
    $script:ResolverRows = @(Get-HookTargetWorktreeResolverRows)
    $script:IdentityRows = @(Get-HookTargetWorktreeIdentityRows)
}

BeforeAll {
    . (Join-Path $PSScriptRoot '../claude-lib/worktree-resolution/HookTargetWorktree.Rows.Helpers.ps1')
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    $script:TwinPath = Join-Path $script:RepoRoot '.codex/hooks/hook-target-worktree.ps1'
    $script:ModulePath = Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/HookTargetWorktree.psm1'
    . $script:TwinPath

    function Get-HookTargetWorktreeFunctionText {
        param([Parameter(Mandatory)] [string] $Path)
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref] $null, [ref] $null)
        $map = [ordered]@{}
        foreach ($function in @($ast.EndBlock.Statements | Where-Object { $_ -is [System.Management.Automation.Language.FunctionDefinitionAst] })) {
            $map[$function.Name] = $function.Extent.Text
        }
        return $map
    }

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

Describe 'hook-target-worktree.ps1 parity with HookTargetWorktree.psm1' {
    It 'answers every row from the dot-sourced twin, not the module' {
        # The hosting runner can attach dot-sourced functions to its own session-state module
        # (PoshQC under Invoke-PoshQCTest), so the guard asserts the module is not the
        # resolver module and that the twin file defines the answering function.
        $command = Get-Command -Name Resolve-HookTargetWorktree
        $moduleName = if ($null -ne $command.Module) { $command.Module.Name } else { '' }
        $moduleName | Should -Not -Be 'HookTargetWorktree'
        Split-Path -Path $command.ScriptBlock.File -Leaf | Should -BeExactly 'hook-target-worktree.ps1'
    }

    It 'defines the same function names as the module' {
        $twin = Get-HookTargetWorktreeFunctionText -Path $script:TwinPath
        $module = Get-HookTargetWorktreeFunctionText -Path $script:ModulePath
        (@($twin.Keys) | Sort-Object) -join ',' | Should -BeExactly ((@($module.Keys) | Sort-Object) -join ',')
        $twin.Count | Should -Be 6
    }

    It 'carries byte-identical text for <_>' -ForEach @(
        'Resolve-HookTargetWorktree'
        'ConvertFrom-HookTargetWorktreePorcelain'
        'Get-HookTargetWorktreeEnclosingRoot'
        'ConvertTo-HookTargetWorktreeNormalizedPath'
        'Get-HookTargetWorktreeRelativePath'
        'Get-HookTargetWorktreeKey'
    ) {
        $twin = Get-HookTargetWorktreeFunctionText -Path $script:TwinPath
        $module = Get-HookTargetWorktreeFunctionText -Path $script:ModulePath
        $twin[$_] | Should -BeExactly $module[$_]
    }

    It 'has no statement outside the function definitions' {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:TwinPath, [ref] $null, [ref] $null)
        @($ast.EndBlock.Statements | Where-Object { $_ -isnot [System.Management.Automation.Language.FunctionDefinitionAst] }).Count | Should -Be 0
        $ast.Extent.Text | Should -Not -Match '\$env:CLAUDE_'
    }
}

Describe 'hook-target-worktree.ps1 helper rows' {
    It '<Name>' -ForEach $script:HelperRows {
        Assert-HookTargetWorktreeScalarRow -Row $_
    }
}

Describe 'hook-target-worktree.ps1 porcelain rows' {
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

Describe 'hook-target-worktree.ps1 resolver rows' {
    It '<Name>' -ForEach $script:ResolverRows {
        Assert-HookTargetWorktreeResolverRow -Row $_
    }
}

Describe 'hook-target-worktree.ps1 ambiguity and identity rows' {
    It '<Name>' -ForEach $script:IdentityRows {
        Assert-HookTargetWorktreeResolverRow -Row $_
    }
}
