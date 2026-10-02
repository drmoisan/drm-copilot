#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity tests for the Claude and Codex copies of the batch-budget route helper.

.DESCRIPTION
    Binds .claude/hooks/enforce-batch-budget-route.ps1 and
    .codex/hooks/enforce-batch-budget-route.ps1: the two copies must be byte-identical,
    and each copy, dot-sourced from its own file, must define exactly the three
    language-neutral route functions and satisfy the same route-predicate and
    selected-route cases. Both files are read only; no file is created or written.
#>

Set-StrictMode -Version Latest

Describe 'batch-budget route helper parity' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    }

    It 'keeps the Claude and Codex route helpers byte-identical' {
        $claudeHash = (Get-FileHash -LiteralPath (Join-Path $script:RepoRoot '.claude/hooks/enforce-batch-budget-route.ps1') -Algorithm SHA256).Hash
        $codexHash = (Get-FileHash -LiteralPath (Join-Path $script:RepoRoot '.codex/hooks/enforce-batch-budget-route.ps1') -Algorithm SHA256).Hash

        $codexHash | Should -Be $claudeHash
    }

    Context 'the <Runtime> route helper' -ForEach @(
        @{ Runtime = 'Claude'; RelativePath = '.claude/hooks/enforce-batch-budget-route.ps1' }
        @{ Runtime = 'Codex'; RelativePath = '.codex/hooks/enforce-batch-budget-route.ps1' }
    ) {
        BeforeAll {
            $script:HelperPath = (Resolve-Path -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -ErrorAction Stop).Path
            . $script:HelperPath
        }

        It 'loads the route functions from its own file' {
            (Get-Command Test-BatchBudgetLargePathRoute).ScriptBlock.File | Should -Be $script:HelperPath
        }

        It 'defines exactly the three neutral route functions' {
            $tokens = $null
            $errors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:HelperPath, [ref]$tokens, [ref]$errors)
            $names = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | ForEach-Object { $_.Name } | Sort-Object)

            $names | Should -Be @('ConvertFrom-BatchBudgetCheckpoint', 'Get-BatchBudgetSelectedRoute', 'Test-BatchBudgetLargePathRoute')
        }

        It '<Name>' -ForEach @(
            @{ Name = 'route_id large'; Text = '{"route_id":"large","next_step":"S5_atomic_execution"}'; Expected = $true }
            @{ Name = 'route_id remediation'; Text = '{"route_id":"remediation"}'; Expected = $true }
            @{ Name = 'route_id preparation'; Text = '{"route_id":"preparation"}'; Expected = $true }
            @{ Name = 'route_id small'; Text = '{"route_id":"small"}'; Expected = $false }
            @{ Name = 'route_id blank'; Text = '{"route_id":"   "}'; Expected = $false }
            @{ Name = 'route_id unknown'; Text = '{"route_id":"epic"}'; Expected = $false }
            @{ Name = 'route_id wrong case'; Text = '{"route_id":"LARGE"}'; Expected = $false }
            @{ Name = 'no route keys'; Text = '{"next_step":"S5_atomic_execution"}'; Expected = $false }
            @{ Name = 'route_id null with path_selected large'; Text = '{"route_id":null,"path_selected":"large"}'; Expected = $false }
            @{ Name = 'route_id non-string with path_selected large'; Text = '{"route_id":5,"path_selected":"large"}'; Expected = $false }
            @{ Name = 'route_id small wins over path_selected large'; Text = '{"route_id":"small","path_selected":"large"}'; Expected = $false }
            @{ Name = 'path_selected large without route_id'; Text = '{"path_selected":"large"}'; Expected = $true }
            @{ Name = 'path_selected small without route_id'; Text = '{"path_selected":"small"}'; Expected = $false }
            @{ Name = 'terminal next_step complete'; Text = '{"route_id":"large","next_step":"complete"}'; Expected = $false }
            @{ Name = 'terminal S12_complete'; Text = '{"route_id":"large","completed_steps":["S11_pr_created","S12_complete"]}'; Expected = $false }
            @{ Name = 'non-terminal completed steps'; Text = '{"route_id":"large","next_step":"S5_atomic_execution","completed_steps":["S4_atomic_planning"]}'; Expected = $true }
            @{ Name = 'malformed JSON'; Text = '{not-json'; Expected = $false }
            @{ Name = 'array JSON'; Text = '[1,2]'; Expected = $false }
            @{ Name = 'string JSON'; Text = '"large"'; Expected = $false }
            @{ Name = 'empty text'; Text = ''; Expected = $false }
            @{ Name = 'whitespace text'; Text = '   '; Expected = $false }
        ) {
            Test-BatchBudgetLargePathRoute -CheckpointText $Text | Should -Be $Expected
        }

        It 'selects <Expected> from <Text>' -ForEach @(
            @{ Text = '{"route_id":"large","path_selected":"small"}'; Expected = 'large' }
            @{ Text = '{"route_id":null,"path_selected":"large"}'; Expected = '' }
            @{ Text = '{"path_selected":"remediation"}'; Expected = 'remediation' }
            @{ Text = '{not-json'; Expected = '' }
        ) {
            Get-BatchBudgetSelectedRoute -CheckpointText $Text | Should -Be $Expected
        }
    }
}
