Set-StrictMode -Version Latest

Describe "claude-settings" {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..')).Path
        $script:PrdFeatureMatcher = 'prd-feature'
        $script:PrdFeatureCommand = 'pwsh -NoProfile -File .claude/hooks/validate-prd-feature-output.ps1'

        function Test-PrdFeatureRegistrationContract {
            param(
                [Parameter(Mandatory)]
                [string]$CanonicalContent,

                [Parameter(Mandatory)]
                [string]$BundleContent
            )

            $settingsBySource = @(
                @{ Name = 'canonical'; Value = ($CanonicalContent | ConvertFrom-Json) },
                @{ Name = 'bundled'; Value = ($BundleContent | ConvertFrom-Json) }
            )

            foreach ($settingsBySourceItem in $settingsBySource) {
                $entries = @($settingsBySourceItem.Value.hooks.SubagentStop | Where-Object { $_.matcher -ceq $script:PrdFeatureMatcher })
                if ($entries.Count -ne 1) {
                    return "Expected exactly one dedicated $script:PrdFeatureMatcher entry in $($settingsBySourceItem.Name); found $($entries.Count)."
                }

                $hooks = @($entries[0].hooks)
                if ($hooks.Count -ne 1) {
                    return "Expected exactly one hook command in $($settingsBySourceItem.Name); found $($hooks.Count)."
                }

                if ($hooks[0].type -cne 'command') {
                    return "Expected the hook type to be command in $($settingsBySourceItem.Name)."
                }

                if ($hooks[0].command -cne $script:PrdFeatureCommand) {
                    return "Expected exact command $script:PrdFeatureCommand in $($settingsBySourceItem.Name)."
                }
            }

            if ($CanonicalContent -cne $BundleContent) {
                return 'The canonical and bundled settings files differ.'
            }

            return $null
        }
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

    It "requires one dedicated prd-feature stop-hook registration in byte-identical settings files" {
        $canonicalPath = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'settings.json'
        $bundlePath = Join-Path -Path $script:RepoRoot -ChildPath 'extensions', 'drm-copilot', 'resources', 'claude-customizations', '.claude', 'settings.json'
        $canonicalContent = Get-Content -Path $canonicalPath -Raw
        $bundleContent = Get-Content -Path $bundlePath -Raw

        (Test-PrdFeatureRegistrationContract -CanonicalContent $canonicalContent -BundleContent $bundleContent) | Should -BeNullOrEmpty
    }

    It "rejects complete omission, broad-only, duplicate, extra-command, wrong-command, wrong-type, wrong-matcher, and divergent prd-feature registration fixtures" {
        $canonicalPath = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'settings.json'
        $content = Get-Content -Path $canonicalPath -Raw
        $settings = $content | ConvertFrom-Json
        $dedicated = @($settings.hooks.SubagentStop | Where-Object { $_.matcher -ceq $script:PrdFeatureMatcher })[0]

        $omitted = $settings | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        $omitted.hooks.SubagentStop = @($omitted.hooks.SubagentStop | Where-Object { $_.matcher -notmatch [regex]::Escape($script:PrdFeatureMatcher) })
        (Test-PrdFeatureRegistrationContract -CanonicalContent ($omitted | ConvertTo-Json -Depth 20) -BundleContent ($omitted | ConvertTo-Json -Depth 20)) | Should -Match 'exactly one'

        $broadOnly = $settings | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        $broadOnly.hooks.SubagentStop = @($broadOnly.hooks.SubagentStop | Where-Object { $_.matcher -cne $script:PrdFeatureMatcher })
        @($broadOnly.hooks.SubagentStop | Where-Object { $_.matcher -match [regex]::Escape($script:PrdFeatureMatcher) }).Count | Should -BeGreaterThan 0
        $broadOnly = $broadOnly | ConvertTo-Json -Depth 20
        (Test-PrdFeatureRegistrationContract -CanonicalContent $broadOnly -BundleContent $broadOnly) | Should -Match 'exactly one'

        $duplicate = $settings | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        $duplicate.hooks.SubagentStop = @($duplicate.hooks.SubagentStop) + $dedicated
        (Test-PrdFeatureRegistrationContract -CanonicalContent ($duplicate | ConvertTo-Json -Depth 20) -BundleContent ($duplicate | ConvertTo-Json -Depth 20)) | Should -Match 'exactly one'

        $extraCommand = $settings | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        $entry = @($extraCommand.hooks.SubagentStop | Where-Object { $_.matcher -ceq $script:PrdFeatureMatcher })[0]
        $entry.hooks = @($entry.hooks) + [pscustomobject]@{ type = 'command'; command = 'pwsh -NoProfile -File .claude/hooks/unrelated.ps1' }
        (Test-PrdFeatureRegistrationContract -CanonicalContent ($extraCommand | ConvertTo-Json -Depth 20) -BundleContent ($extraCommand | ConvertTo-Json -Depth 20)) | Should -Match 'exactly one hook'

        $wrongCommand = $settings | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        (@($wrongCommand.hooks.SubagentStop | Where-Object { $_.matcher -ceq $script:PrdFeatureMatcher })[0].hooks[0]).command = 'pwsh -NoProfile -File .claude/hooks/wrong.ps1'
        (Test-PrdFeatureRegistrationContract -CanonicalContent ($wrongCommand | ConvertTo-Json -Depth 20) -BundleContent ($wrongCommand | ConvertTo-Json -Depth 20)) | Should -Match 'Expected exact command'

        $wrongType = $settings | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        (@($wrongType.hooks.SubagentStop | Where-Object { $_.matcher -ceq $script:PrdFeatureMatcher })[0].hooks[0]).type = 'prompt'
        (Test-PrdFeatureRegistrationContract -CanonicalContent ($wrongType | ConvertTo-Json -Depth 20) -BundleContent ($wrongType | ConvertTo-Json -Depth 20)) | Should -Match 'type to be command'

        $wrongMatcher = $settings | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        (@($wrongMatcher.hooks.SubagentStop | Where-Object { $_.matcher -ceq $script:PrdFeatureMatcher })[0]).matcher = 'prd-feature-worker'
        (Test-PrdFeatureRegistrationContract -CanonicalContent ($wrongMatcher | ConvertTo-Json -Depth 20) -BundleContent ($wrongMatcher | ConvertTo-Json -Depth 20)) | Should -Match 'exactly one'

        (Test-PrdFeatureRegistrationContract -CanonicalContent $content -BundleContent "$content ") | Should -Match 'differ'
    }
}
