#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Cross-tree identity of the helpers shared by .claude/hooks and .codex/hooks (issue #1030).

.DESCRIPTION
    Pins the byte identity of every same-named .claude/hooks and .codex/hooks helper that the Phase 0 gate
    of issue #1030 found identical by hash (IDENTICAL-HELPERS), following
    codex-batch-budget-route-parity.Tests.ps1. The Codex SubagentStop envelope twin is not byte-identical,
    because its comment header names the Codex payload fields; its function names and function definition
    text must equal the Claude source, and it must read no legacy Claude environment variable. Files are
    read only; no file is created or written.
#>

Set-StrictMode -Version Latest

BeforeDiscovery {
    $script:IdenticalHelpers = @(
        'enforce-batch-budget-route.ps1', 'enforce-completion-helpers.ps1', 'enforce-epic-merge-gate-child-ci.ps1',
        'enforce-epic-merge-gate-command.ps1', 'enforce-epic-merge-gate-regeneration.ps1', 'enforce-epic-merge-gate-review.ps1',
        'enforce-orchestration-preimplementation-gate-bookkeeping.ps1', 'enforce-orchestration-preimplementation-gate-classify.ps1',
        'enforce-orchestration-preimplementation-gate-cleanup.ps1', 'enforce-orchestration-preimplementation-gate-commands.ps1',
        'enforce-orchestration-preimplementation-gate-docs.ps1', 'enforce-orchestration-preimplementation-gate-helpers.ps1',
        'enforce-orchestration-preimplementation-gate-operands.ps1', 'enforce-orchestration-preimplementation-gate-release.ps1',
        'enforce-orchestration-preimplementation-gate-targets.ps1', 'epic-wave-barrier-early-start.ps1', 'feature-folder-resolution.ps1',
        'feature-review-coverage-thresholds.ps1', 'hook-cleanup-context.ps1', 'hook-command-heredoc.ps1', 'hook-command-invocation.ps1',
        'hook-command-invocation-operands.ps1', 'hook-command-payload.ps1', 'hook-command-payload-powershell.ps1', 'hook-command-scanner.ps1',
        'hook-dependency-guard.ps1', 'hook-docs-estate-context.ps1', 'hook-docs-only-diff.ps1', 'hook-epic-fan-in.ps1',
        'hook-epic-regeneration.ps1', 'hook-planner-worktree-removal.ps1', 'hook-release-allowance-context.ps1',
        'test-execution-command-form.ps1', 'test-execution-lock.ps1', 'test-execution-lock-decision.ps1', 'test-execution-policy.ps1',
        'worktree-poetry-venv-policy.ps1'
    ) | ForEach-Object { @{ Helper = $_ } }
}

Describe 'cross-tree helper identity' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path

        function Get-FunctionDefinitionText {
            # Returns an ordered name-to-extent-text table of the top-level function definitions of one file.
            param([Parameter(Mandatory)][string] $Path)
            $tokens = $null
            $errors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors)
            $table = [ordered]@{}
            foreach ($definition in @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false))) {
                $table[$definition.Name] = $definition.Extent.Text -replace "`r`n", "`n"
            }
            return $table
        }
    }

    It 'keeps the Claude and Codex copies of <Helper> byte-identical' -ForEach $script:IdenticalHelpers {
        $claudeHash = (Get-FileHash -LiteralPath (Join-Path $script:RepoRoot (Join-Path '.claude/hooks' $Helper)) -Algorithm SHA256).Hash
        $codexHash = (Get-FileHash -LiteralPath (Join-Path $script:RepoRoot (Join-Path '.codex/hooks' $Helper)) -Algorithm SHA256).Hash

        $codexHash | Should -Be $claudeHash -Because "$Helper is shared by both hook trees"
    }

    Context 'the Codex subagentstop-envelope twin' {
        BeforeAll {
            $script:ClaudeFunctions = Get-FunctionDefinitionText -Path (Join-Path $script:RepoRoot '.claude/hooks/subagentstop-envelope.ps1')
            $script:CodexPath = Join-Path $script:RepoRoot '.codex/hooks/subagentstop-envelope.ps1'
            $script:CodexFunctions = Get-FunctionDefinitionText -Path $script:CodexPath
        }

        It 'defines the same function names as the Claude source' {
            @($script:CodexFunctions.Keys) | Should -Be @($script:ClaudeFunctions.Keys)
            @($script:CodexFunctions.Keys).Count | Should -Be 3
        }

        It 'keeps every function definition text-identical to the Claude source' {
            foreach ($name in $script:ClaudeFunctions.Keys) {
                $script:CodexFunctions[$name] | Should -BeExactly $script:ClaudeFunctions[$name] -Because "$name is a twin-rule function"
            }
        }

        It 'reads no legacy Claude environment variable' {
            Get-Content -Raw -LiteralPath $script:CodexPath | Should -Not -Match '\$env:CLAUDE_'
        }
    }
}
