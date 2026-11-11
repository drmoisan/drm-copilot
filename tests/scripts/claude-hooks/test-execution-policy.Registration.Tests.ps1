#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Registration contract for the enforce-test-execution-policy hook (issue #1158, spec D23, D31,
    registration branch A).

.DESCRIPTION
    Reads only committed files: .claude/settings.json and its bundle copy (parsed JSON), and
    .codex/config.toml and its bundle copy (line scan in the Get-CodexHookRegistration pattern of
    codex-bundle-hook-probe.Tests.ps1).
#>

BeforeDiscovery {
    $script:SettingsFiles = @(
        @{ Path = '.claude/settings.json' }
        @{ Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/settings.json' }
    )
    $script:ConfigFiles = @(
        @{ Path = '.codex/config.toml' }
        @{ Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml' }
    )
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:ClaudeCommand = 'pwsh -NoProfile -File .claude/hooks/enforce-test-execution-policy.ps1'
    $script:ClaudeMcpMatcher = 'mcp__drm-copilot__run_poshqc_test|mcp__drm-copilot__run_poshqc_suite'
    $script:CodexMcpMatcher = '^(mcp__drm-copilot__run_poshqc_test|mcp__drm-copilot__run_poshqc_suite)$'

    function Get-CodexRegistrationEntry {
        # One record per [[hooks.PreToolUse.hooks]] table: its group matcher, command, command_windows, and timeout.
        param([Parameter(Mandatory)][string] $ConfigPath)
        $entries = [System.Collections.Generic.List[object]]::new()
        $eventName = $null
        $matcher = $null
        $current = $null
        foreach ($line in (Get-Content -LiteralPath $ConfigPath)) {
            if ($line -match '^\[\[hooks\.(?<event>[A-Za-z]+)\]\]$') { $eventName = $Matches['event']; $matcher = $null; $current = $null; continue }
            if ($line -match '^\[\[hooks\.[A-Za-z]+\.hooks\]\]$') {
                $current = [pscustomobject]@{ Event = $eventName; Matcher = $matcher; Command = ''; CommandWindows = ''; Timeout = '' }
                $entries.Add($current)
                continue
            }
            if ($null -eq $current -and $line -match '^matcher\s*=\s*"(?<matcher>.+)"\s*$') { $matcher = $Matches['matcher']; continue }
            if ($null -ne $current -and $line -match '^command\s*=\s*(?<value>.+)$') { $current.Command = $Matches['value']; continue }
            if ($null -ne $current -and $line -match '^command_windows\s*=\s*(?<value>.+)$') { $current.CommandWindows = $Matches['value']; continue }
            if ($null -ne $current -and $line -match '^timeout\s*=\s*(?<value>\d+)\s*$') { $current.Timeout = $Matches['value']; continue }
        }
        return $entries.ToArray()
    }
}

Describe 'Claude registration of enforce-test-execution-policy (<Path>)' -ForEach $script:SettingsFiles {
    BeforeAll {
        $settings = Get-Content -LiteralPath (Join-Path $script:RepoRoot $Path) -Raw | ConvertFrom-Json
        $script:Groups = @($settings.hooks.PreToolUse)
    }

    It 'registers the hook as the last command of the Bash group' {
        # Act
        $bash = @($script:Groups | Where-Object { $_.matcher -ceq 'Bash' })

        # Assert
        $bash.Count | Should -Be 1
        @($bash[0].hooks)[-1].command | Should -BeExactly $script:ClaudeCommand
    }

    It 'registers exactly one PoshQC MCP group that holds the hook' {
        # Act
        $mcp = @($script:Groups | Where-Object { $_.matcher -ceq $script:ClaudeMcpMatcher })

        # Assert
        $mcp.Count | Should -Be 1
        @($mcp[0].hooks | Where-Object { $_.command -ceq $script:ClaudeCommand }).Count | Should -Be 1
    }
}

Describe 'Codex registration of enforce-test-execution-policy (<Path>)' -ForEach $script:ConfigFiles {
    BeforeAll {
        $script:Entries = @(Get-CodexRegistrationEntry -ConfigPath (Join-Path $script:RepoRoot $Path) | Where-Object { $_.Event -eq 'PreToolUse' })
    }

    It 'registers the twin in the ^Bash$ group with command_windows and timeout 30' {
        # Act
        $bash = @($script:Entries | Where-Object { $_.Matcher -ceq '^Bash$' -and $_.Command -like '*/.codex/hooks/enforce-test-execution-policy.ps1*' })

        # Assert
        $bash.Count | Should -Be 1
        $bash[0].CommandWindows | Should -BeLike '*git rev-parse --show-toplevel*/.codex/hooks/enforce-test-execution-policy.ps1*'
        $bash[0].Timeout | Should -Be '30'
    }

    It 'registers exactly one PoshQC MCP group that holds the twin' {
        # Act
        $mcp = @($script:Entries | Where-Object { $_.Matcher -ceq $script:CodexMcpMatcher })

        # Assert
        $mcp.Count | Should -Be 1
        $mcp[0].Command | Should -BeLike '*/.codex/hooks/enforce-test-execution-policy.ps1*'
    }
}
