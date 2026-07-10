Set-StrictMode -Version Latest

Describe "claude-settings" {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..')).Path
    }

    It "requires .claude/settings.json to omit a default agent and declare canonical worker hook coverage" {
        $settingsPath = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'settings.json'
        $settings = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json

        # Commit ecc9ced5 removed orchestrator as the session default agent;
        # the key must stay absent so sessions do not silently re-acquire one.
        @($settings.PSObject.Properties.Name) | Should -Not -Contain 'agent'
        $settings.hooks.PreToolUse | Should -Not -BeNullOrEmpty
        $settings.hooks.SubagentStop | Should -Not -BeNullOrEmpty

        $hookCoverage = @(
            $settings.hooks.PreToolUse | ConvertTo-Json -Depth 10 -Compress
            $settings.hooks.SubagentStop | ConvertTo-Json -Depth 10 -Compress
        ) -join "`n"

        $requiredWorkers = @(
            'atomic-planner',
            'atomic-executor',
            'feature-review',
            'task-researcher',
            'prd-feature',
            'staged-review',
            'epic-review',
            'status-updater'
        )

        foreach ($worker in $requiredWorkers) {
            $hookCoverage | Should -Match ([regex]::Escape($worker))
        }
    }

    It "requires .claude/settings.json to use the active PowerShell MCP contract" {
        $settingsPath = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'settings.json'
        $content = Get-Content -Path $settingsPath -Raw

        $content | Should -Match 'mcp__drm-copilot__run_poshqc_format'
        $content | Should -Match 'mcp__drm-copilot__run_poshqc_analyze'
        $content | Should -Match 'mcp__drm-copilot__run_poshqc_test'
        $content | Should -Match 'mcp__drm-copilot__run_poshqc_analyze_autofix'
        $content | Should -Not -Match 'mcp_drmcopilotext_run_poshqc_test'
    }

    It "requires the Bash PreToolUse hook chain to include validate-bash and enforce-promotion-mcp-only" {
        $settingsPath = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'settings.json'
        $settings = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json

        $bashHookCoverage = @(
            $settings.hooks.PreToolUse |
                Where-Object { $_.matcher -eq 'Bash' } |
                    ConvertTo-Json -Depth 10 -Compress
        ) -join "`n"

        $bashHookCoverage | Should -Match ([regex]::Escape('.claude/hooks/validate-bash.ps1'))
        $bashHookCoverage | Should -Match ([regex]::Escape('.claude/hooks/enforce-promotion-mcp-only.ps1'))
    }
}

