#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Registration and packaging of the owner-directive pass-down hook (issue #1157).

.DESCRIPTION
    Reads both committed PreToolUse registry copies and both settings copies, and classifies the ledger and decision-file paths through
    the preimplementation gate. No test writes a file or starts a process.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    $script:SettingsCopies = @('.claude/settings.json', 'extensions/drm-copilot/resources/claude-customizations/.claude/settings.json')
    $script:PassDownMatcher = 'Bash|Write|Edit|MultiEdit|NotebookEdit|Agent|Task|mcp__.*'
    $script:PassDownCommand = 'pwsh -NoProfile -File .claude/hooks/enforce-owner-directive-pass-down.ps1'

    function Get-PassDownHookGroupCount {
        # Counts the PreToolUse groups whose matcher and single command equal the pass-down registration.
        param([Parameter(Mandatory = $true)] $Settings)
        return @($Settings.hooks.PreToolUse | Where-Object { $_.matcher -ceq $script:PassDownMatcher -and @($_.hooks).Count -eq 1 -and $_.hooks[0].command -ceq $script:PassDownCommand }).Count
    }
}

AfterAll {
    Remove-Item -LiteralPath 'function:Get-PassDownHookGroupCount' -ErrorAction SilentlyContinue
}

Describe 'owner-directive pass-down hook registration' {
    It 'registers exactly one PreToolUse pass-down group in <Path>' -ForEach @(
        # Issue #1159: PreToolUse hooks are registered in the dispatcher registry, not in settings.json.
        @{ Path = '.claude/hooks/pretooluse-dispatch.json' }
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/pretooluse-dispatch.json' }
    ) {
        # Arrange
        $text = Get-Content -LiteralPath (Join-Path $script:RepoRoot $Path) -Raw

        # Act
        $settings = $text | ConvertFrom-Json

        # Assert
        Get-PassDownHookGroupCount -Settings $settings | Should -Be 1 -Because "$Path must register the pass-down hook once"
    }

    It 'keeps the two settings copies byte-identical' {
        # Act
        $hashes = @($script:SettingsCopies | ForEach-Object { (Get-FileHash -LiteralPath (Join-Path $script:RepoRoot $_) -Algorithm SHA256).Hash } | Sort-Object -Unique)

        # Assert
        $hashes.Count | Should -Be 1
    }
}

Describe 'owner-directive pass-down core.json packaging' {
    BeforeAll {
        $manifestText = Get-Content -LiteralPath (Join-Path $script:RepoRoot 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json') -Raw
        $script:CorePaths = @(($manifestText | ConvertFrom-Json).paths)
    }

    It 'lists <Path> in core.json paths' -ForEach @(
        @{ Path = '.claude/hooks/enforce-owner-directive-pass-down.ps1' }
        @{ Path = '.claude/hooks/owner-directive-pass-down-target.ps1' }
        @{ Path = '.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1' }
        @{ Path = '.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1' }
        @{ Path = '.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1' }
    ) {
        # Act
        $count = @($script:CorePaths | Where-Object { $_ -ceq $Path }).Count

        # Assert
        $count | Should -Be 1 -Because "$Path must be listed once in core.json"
    }
}

Describe 'preimplementation gate classification of pass-down paths' {
    BeforeAll {
        . (Join-Path $script:RepoRoot '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1')
    }

    It 'does not classify <Name> as an implementation path' -ForEach @(
        @{ Name = 'the ledger'; Path = 'artifacts/orchestration/owner-directives.jsonl' }
        @{ Name = 'a decision file'; Path = 'artifacts/orchestration/owner-directive-decisions/agent-a1b2/OD-1.md' }
    ) {
        # Act
        $result = Test-ImplementationPath -NormalizedPath $Path

        # Assert
        $result | Should -BeFalse -Because "$Path must not require the preimplementation checkpoint"
    }
}
