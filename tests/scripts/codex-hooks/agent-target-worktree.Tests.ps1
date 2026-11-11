#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity and behavior tests for the Codex twin .codex/hooks/agent-target-worktree.ps1 (issue #1163).

.DESCRIPTION
    Asserts that the twin defines the same function names as
    .claude/lib/worktree-resolution/AgentTargetWorktree.psm1 with byte-identical function text
    (both files are parsed from the repository), and runs the shared rows of
    tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Rows.Helpers.ps1 against the
    dot-sourced twin. A guard row proves the twin, not the module, answers the rows. Every
    worktree list is in-memory porcelain text; no test runs git, creates a file, or reads
    gitignored state. The suite runs on the Linux hook-suite job, so every path is joined with
    Join-Path and spelled with forward slashes in exact case.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot '../claude-lib/worktree-resolution/AgentTargetWorktree.Rows.Helpers.ps1')
    $script:AgentRows = @(Get-AgentTargetWorktreeRows)
}

BeforeAll {
    . (Join-Path $PSScriptRoot '../claude-lib/worktree-resolution/AgentTargetWorktree.Rows.Helpers.ps1')
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    $script:TwinPath = Join-Path $script:RepoRoot '.codex/hooks/agent-target-worktree.ps1'
    $script:ModulePath = Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/AgentTargetWorktree.psm1'
    Remove-Module -Name AgentTargetWorktree -ErrorAction SilentlyContinue
    . $script:TwinPath

    function Get-AgentTargetWorktreeFunctionText {
        param([Parameter(Mandatory)] [string] $Path)
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref] $null, [ref] $null)
        $map = [ordered]@{}
        foreach ($function in @($ast.EndBlock.Statements | Where-Object { $_ -is [System.Management.Automation.Language.FunctionDefinitionAst] })) {
            $map[$function.Name] = $function.Extent.Text
        }
        return $map
    }
}

Describe 'agent-target-worktree.ps1 parity with AgentTargetWorktree.psm1' {
    It 'defines the same function names as the module' {
        $twin = Get-AgentTargetWorktreeFunctionText -Path $script:TwinPath
        $module = Get-AgentTargetWorktreeFunctionText -Path $script:ModulePath
        (@($twin.Keys) -join ',') | Should -BeExactly (@($module.Keys) -join ',')
    }

    It 'carries byte-identical function text for <_>' -ForEach @('ConvertTo-AgentTargetLiveWorktreeListText', 'Resolve-AgentTargetWorktree') {
        $twin = Get-AgentTargetWorktreeFunctionText -Path $script:TwinPath
        $module = Get-AgentTargetWorktreeFunctionText -Path $script:ModulePath
        $twin[$_] | Should -BeExactly $module[$_]
    }

    It 'answers the rows from the dot-sourced twin' {
        $command = Get-Command -Name Resolve-AgentTargetWorktree -CommandType Function
        $command.Source | Should -BeNullOrEmpty
        ($command.ScriptBlock.File -replace '\\', '/') | Should -BeLike '*/.codex/hooks/agent-target-worktree.ps1'
    }
}

Describe 'agent-target-worktree.ps1 shared rows' {
    It '<Name>' -ForEach $script:AgentRows {
        Assert-AgentTargetWorktreeRow -Row $_
    }
}
