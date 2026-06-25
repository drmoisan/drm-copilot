#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'enforce-orchestration-preimplementation-gate.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
        . $script:UnderTest

        function ConvertTo-ImplementationWriteToolInput {
            param(
                [string] $FilePath = 'scripts/dev_tools/validate_orchestrator_state.py',
                [string] $Content = 'implementation change'
            )

            return (@{ file_path = $FilePath; content = $Content } | ConvertTo-Json -Compress)
        }

        function ConvertTo-CommandToolInput {
            param([Parameter(Mandatory)] [string] $Command)

            return (@{ command = $Command } | ConvertTo-Json -Compress)
        }

        function ConvertTo-DelegationToolInput {
            param([string] $AgentName = 'powershell-typed-engineer')

            return (@{ subagent_type = $AgentName; prompt = 'Implement Issue #232 remediation.' } | ConvertTo-Json -Compress)
        }

        function ConvertTo-CheckpointRaw {
            param(
                [string] $IssueNum = '232',
                [string] $FeatureFolder = 'docs/features/active/2026-06-24-harden-orchestrate-skill-232',
                [string] $RouteId = 'large',
                [bool] $LifecycleReady = $true
            )

            return @{
                'issue-num'      = $IssueNum
                'feature-folder' = $FeatureFolder
                route_id         = $RouteId
                lifecycle_ready  = $LifecycleReady
            } | ConvertTo-Json -Compress
        }
    }

    Context 'implementation writes before orchestration readiness' {
        It 'blocks Issue #232 implementation writes when route metadata and lifecycle readiness are absent' {
            $json = ConvertTo-ImplementationWriteToolInput
            $checkpoint = ConvertTo-CheckpointRaw -RouteId '' -LifecycleReady $false

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $checkpoint

            $decision['decision'] | Should -Be 'block'
            $decision['reason'] | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
            $decision['reason'] | Should -Match 'Issue #232'
            $decision['reason'] | Should -Match 'route metadata'
            $decision['reason'] | Should -Match 'lifecycle readiness'
        }

        It 'allows Issue #232 feature documentation writes' {
            $json = ConvertTo-ImplementationWriteToolInput -FilePath 'docs/features/active/2026-06-24-harden-orchestrate-skill-232/spec.md'

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json

            $decision['decision'] | Should -Be 'allow'
        }

        It 'allows Issue #232 evidence writes' {
            $json = ConvertTo-ImplementationWriteToolInput -FilePath 'docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/qa-gates/example.md'

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json

            $decision['decision'] | Should -Be 'allow'
        }

        It 'allows implementation writes when Issue #232 readiness is present' {
            $json = ConvertTo-ImplementationWriteToolInput
            $checkpoint = @{
                'issue-num'      = '232'
                'feature-folder' = 'docs/features/active/2026-06-24-harden-orchestrate-skill-232'
                route_id         = 'large'
                lifecycle_ready  = $true
            } | ConvertTo-Json -Compress

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $checkpoint

            $decision['decision'] | Should -Be 'allow'
        }

        It 'blocks implementation command payloads before Issue #232 readiness' {
            $json = ConvertTo-CommandToolInput -Command 'poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state.py'
            $checkpoint = ConvertTo-CheckpointRaw -LifecycleReady $false

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $checkpoint

            $decision['decision'] | Should -Be 'block'
            $decision['reason'] | Should -Match 'Issue #232'
        }

        It 'blocks staging and commit command payloads before Issue #232 readiness' {
            $checkpoint = ConvertTo-CheckpointRaw -LifecycleReady $false
            $commands = @('git add .', 'git commit -m "test"')

            foreach ($command in $commands) {
                $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-CommandToolInput -Command $command) -CheckpointRaw $checkpoint

                $decision['decision'] | Should -Be 'block'
                $decision['reason'] | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
            }
        }

        It 'blocks formatter and test command payloads before Issue #232 readiness' {
            $checkpoint = ConvertTo-CheckpointRaw -LifecycleReady $false
            $commands = @(
                'poetry run black scripts/dev_tools/validate_orchestrator_state.py --check',
                'npm --prefix extensions/drm-copilot run test:unit -- --coverage',
                'pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"'
            )

            foreach ($command in $commands) {
                $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-CommandToolInput -Command $command) -CheckpointRaw $checkpoint

                $decision['decision'] | Should -Be 'block'
                $decision['reason'] | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
            }
        }

        It 'blocks implementation delegation payloads before Issue #232 readiness' {
            $json = ConvertTo-DelegationToolInput
            $checkpoint = ConvertTo-CheckpointRaw -LifecycleReady $false

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $checkpoint

            $decision['decision'] | Should -Be 'block'
            $decision['reason'] | Should -Match 'Issue #232'
        }

        It 'allows implementation operations for a ready non-232 workflow state' {
            $json = ConvertTo-ImplementationWriteToolInput -FilePath 'scripts/dev_tools/validate_orchestration_artifacts.py'
            $checkpoint = ConvertTo-CheckpointRaw -IssueNum '233' -FeatureFolder 'docs/features/active/2026-06-25-other-feature-233'

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $checkpoint

            $decision['decision'] | Should -Be 'allow'
        }
    }

    Context 'Claude runtime registration' {
        BeforeAll {
            $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        }

        It 'registers the preimplementation gate in active and tracked Claude settings' {
            $settingsPaths = @(
                Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'settings.json'
                Join-Path -Path $script:RepoRoot -ChildPath 'extensions', 'drm-copilot', 'resources', 'claude-customizations', '.claude', 'settings.json'
            )
            $requiredMatchers = @('Bash', 'Write|Edit', 'Agent')
            $expectedCommand = 'pwsh -NoProfile -File .claude/hooks/enforce-orchestration-preimplementation-gate.ps1'

            foreach ($settingsPath in $settingsPaths) {
                $settings = Get-Content -Raw -LiteralPath $settingsPath | ConvertFrom-Json

                foreach ($matcher in $requiredMatchers) {
                    $matchingHooks = @(
                        $settings.hooks.PreToolUse |
                            Where-Object { $_.matcher -eq $matcher } |
                                ForEach-Object { $_.hooks } |
                                    Where-Object { $_.command -eq $expectedCommand }
                    )

                    $matchingHooks.Count | Should -Be 1 -Because "$settingsPath must register $expectedCommand for $matcher"
                }
            }
        }
    }
}
