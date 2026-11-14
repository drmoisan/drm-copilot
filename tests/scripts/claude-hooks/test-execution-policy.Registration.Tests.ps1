#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Registration contract for the enforce-test-execution-policy hook (issue #1158, spec D23, D31,
    registration branch B).

.DESCRIPTION
    Issue #1159 moved PreToolUse hooks into the dispatcher registries, so the hook is a member of
    .claude/hooks/pretooluse-dispatch.json, .codex/hooks/pretooluse-dispatch.json, and their bundle
    copies, in one group that admits Bash and the two PoshQC MCP tool names and directly follows the
    Bash group. The settings and config copies keep only the dispatcher entry, and the Codex
    dispatcher timeout equals the sum of the member timeouts of the matching registry copy. Reads
    only committed files: the registries as parsed JSON, the settings copies as parsed JSON, and the
    config copies by line scan.
#>

BeforeDiscovery {
    $script:RegistryFiles = @(
        @{ Runtime = 'claude'; Path = '.claude/hooks/pretooluse-dispatch.json'; BashMatcher = 'Bash'; Matcher = 'Bash|mcp__drm-copilot__run_poshqc_test|mcp__drm-copilot__run_poshqc_suite' }
        @{ Runtime = 'claude'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/pretooluse-dispatch.json'; BashMatcher = 'Bash'; Matcher = 'Bash|mcp__drm-copilot__run_poshqc_test|mcp__drm-copilot__run_poshqc_suite' }
        @{ Runtime = 'codex'; Path = '.codex/hooks/pretooluse-dispatch.json'; BashMatcher = '^Bash$'; Matcher = '^(Bash|mcp__drm-copilot__run_poshqc_test|mcp__drm-copilot__run_poshqc_suite)$' }
        @{ Runtime = 'codex'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/pretooluse-dispatch.json'; BashMatcher = '^Bash$'; Matcher = '^(Bash|mcp__drm-copilot__run_poshqc_test|mcp__drm-copilot__run_poshqc_suite)$' }
    )
    $script:DirectFiles = @(
        @{ Path = '.claude/settings.json' }
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/settings.json' }
        @{ Path = '.codex/config.toml' }
        @{ Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml' }
    )
    $script:TimeoutPairs = @(
        @{ Config = '.codex/config.toml'; Registry = '.codex/hooks/pretooluse-dispatch.json' }
        @{ Config = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml'; Registry = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/pretooluse-dispatch.json' }
    )
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:ClaudeCommand = 'pwsh -NoProfile -File .claude/hooks/enforce-test-execution-policy.ps1'
    $script:CodexCommand = 'pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/enforce-test-execution-policy.ps1"'

    function Get-CodexPreToolUseTimeout {
        # The timeout values of every [[hooks.PreToolUse.hooks]] table of a config.toml copy.
        param([Parameter(Mandatory)][string] $ConfigPath)
        $timeouts = [System.Collections.Generic.List[int]]::new()
        $inPreToolUse = $false
        foreach ($line in (Get-Content -LiteralPath $ConfigPath)) {
            if ($line -match '^\[\[hooks\.(?<table>[A-Za-z.]+)\]\]$') { $inPreToolUse = $Matches['table'] -like 'PreToolUse*'; continue }
            if ($inPreToolUse -and $line -match '^timeout\s*=\s*(?<value>\d+)\s*$') { $timeouts.Add([int]$Matches['value']) }
        }
        return $timeouts.ToArray()
    }
}

Describe 'Registry membership of enforce-test-execution-policy (<Path>)' -ForEach $script:RegistryFiles {
    BeforeAll {
        $script:Groups = @((Get-Content -LiteralPath (Join-Path $script:RepoRoot $Path) -Raw | ConvertFrom-Json).hooks.PreToolUse)
        $script:Expected = if ($Runtime -eq 'claude') { $script:ClaudeCommand } else { $script:CodexCommand }
    }

    It 'holds the hook in exactly one group, the Bash and PoshQC MCP group' {
        # Act
        $holding = @($script:Groups | Where-Object { @($_.hooks | Where-Object { [string]$_.command -like '*enforce-test-execution-policy.ps1*' }).Count -gt 0 })

        # Assert
        $holding.Count | Should -Be 1
        $holding[0].matcher | Should -BeExactly $Matcher
        @($holding[0].hooks).Count | Should -Be 1
        [string]@($holding[0].hooks)[0].command | Should -BeExactly $script:Expected
    }

    It 'places the group directly after the Bash group, so the hook runs after the Bash hooks' {
        # Act
        $matchers = @($script:Groups | ForEach-Object { [string]$_.matcher })
        $bashIndex = [array]::IndexOf($matchers, $BashMatcher)

        # Assert
        $bashIndex | Should -BeGreaterOrEqual 0
        $matchers[$bashIndex + 1] | Should -BeExactly $Matcher
    }

    It 'gives the Codex member command_windows and timeout 30 like its neighbours' -Skip:($Runtime -ne 'codex') {
        # Act
        $member = @(@($script:Groups | Where-Object { $_.matcher -ceq $Matcher })[0].hooks)[0]

        # Assert
        [string]$member.command_windows | Should -BeExactly $script:CodexCommand
        [int]$member.timeout | Should -Be 30
    }
}

Describe 'No direct registration of enforce-test-execution-policy (<Path>)' -ForEach $script:DirectFiles {
    It 'leaves the hook out of the settings or config copy, which registers only the dispatcher' {
        # Act
        $text = Get-Content -LiteralPath (Join-Path $script:RepoRoot $Path) -Raw

        # Assert
        $text | Should -Not -BeLike '*enforce-test-execution-policy.ps1*'
        $text | Should -BeLike '*invoke-pretooluse-dispatch.ps1*'
    }
}

Describe 'Codex dispatcher timeout sum (<Config>)' -ForEach $script:TimeoutPairs {
    It 'equals the sum of the member timeouts of the matching registry copy' {
        # Arrange
        $sum = 0
        foreach ($group in @((Get-Content -LiteralPath (Join-Path $script:RepoRoot $Registry) -Raw | ConvertFrom-Json).hooks.PreToolUse)) {
            foreach ($hook in @($group.hooks)) { $sum += [int]$hook.timeout }
        }

        # Act
        $timeouts = @(Get-CodexPreToolUseTimeout -ConfigPath (Join-Path $script:RepoRoot $Config))

        # Assert
        $timeouts | Should -Be @($sum)
    }
}
