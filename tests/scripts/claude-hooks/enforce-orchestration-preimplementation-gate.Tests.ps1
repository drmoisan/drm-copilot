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

            return (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = $FilePath; content = $Content }
                } | ConvertTo-Json -Compress -Depth 5)
        }

        function ConvertTo-CommandToolInput {
            param([Parameter(Mandatory)] [string] $Command)

            return (@{
                    tool_name  = 'Bash'
                    tool_input = @{ command = $Command }
                } | ConvertTo-Json -Compress -Depth 5)
        }

        function ConvertTo-DelegationToolInput {
            param([string] $AgentName = 'powershell-typed-engineer')

            return (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = $AgentName; prompt = 'Implement Issue #232 remediation.' }
                } | ConvertTo-Json -Compress -Depth 5)
        }

        function ConvertTo-CheckpointRaw {
            param(
                [string] $IssueNum = '253',
                [string] $FeatureFolder = 'docs/features/active/2026-06-26-orchestration-enforcement-hardening-253',
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
        It 'blocks implementation writes when route metadata and lifecycle readiness are absent (generalized message)' {
            $json = ConvertTo-ImplementationWriteToolInput
            $checkpoint = ConvertTo-CheckpointRaw -RouteId '' -LifecycleReady $false

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $checkpoint

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Not -Match '#232'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'route metadata'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'lifecycle readiness'
        }

        It 'emits the PreToolUse deny schema (hookEventName + permissionDecision=deny) after serialize-then-parse' {
            $json = ConvertTo-ImplementationWriteToolInput
            $checkpoint = ConvertTo-CheckpointRaw -RouteId '' -LifecycleReady $false

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $checkpoint
            $parsed = $decision | ConvertTo-Json -Depth 5 | ConvertFrom-Json

            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'allows feature documentation writes' {
            $json = ConvertTo-ImplementationWriteToolInput -FilePath 'docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/spec.md'

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows evidence writes' {
            $json = ConvertTo-ImplementationWriteToolInput -FilePath 'docs/features/active/2026-06-26-orchestration-enforcement-hardening-253/evidence/qa-gates/example.md'

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows implementation writes when checkpoint readiness is present, regardless of issue number' {
            $json = ConvertTo-ImplementationWriteToolInput
            $checkpoint = @{
                'issue-num'      = '424'
                'feature-folder' = 'docs/features/active/some-feature-424'
                route_id         = 'large'
                lifecycle_ready  = $true
            } | ConvertTo-Json -Compress

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $checkpoint

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'blocks implementation command payloads before readiness (generalized message)' {
            $json = ConvertTo-CommandToolInput -Command 'poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state.py'
            $checkpoint = ConvertTo-CheckpointRaw -LifecycleReady $false

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $checkpoint

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Not -Match '#232'
        }

        It 'blocks staging and commit command payloads before readiness' {
            $checkpoint = ConvertTo-CheckpointRaw -LifecycleReady $false
            $commands = @('git add .', 'git commit -m "test"')

            foreach ($command in $commands) {
                $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-CommandToolInput -Command $command) -CheckpointRaw $checkpoint

                $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
                $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
            }
        }

        It 'blocks formatter and test command payloads before readiness' {
            $checkpoint = ConvertTo-CheckpointRaw -LifecycleReady $false
            $commands = @(
                'poetry run black scripts/dev_tools/validate_orchestrator_state.py --check',
                'npm --prefix extensions/drm-copilot run test:unit -- --coverage',
                'pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"'
            )

            foreach ($command in $commands) {
                $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-CommandToolInput -Command $command) -CheckpointRaw $checkpoint

                $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
                $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
            }
        }

        It 'blocks implementation delegation payloads before readiness (generalized message)' {
            $json = ConvertTo-DelegationToolInput
            $checkpoint = ConvertTo-CheckpointRaw -LifecycleReady $false

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $checkpoint

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Not -Match '#232'
        }

        It 'allows implementation operations for any ready workflow state regardless of issue number' {
            $json = ConvertTo-ImplementationWriteToolInput -FilePath 'scripts/dev_tools/validate_orchestration_artifacts.py'
            $checkpoint = ConvertTo-CheckpointRaw -IssueNum '233' -FeatureFolder 'docs/features/active/2026-06-25-other-feature-233'

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $checkpoint

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'tool input parsing and checkpoint resolution' {
        It 'denies an empty payload as an envelope anomaly (fail closed)' {
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies unparseable top-level JSON instead of throwing (exit 1 is non-blocking)' {
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw '{not json'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }

        It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
            $flat = (@{ file_path = 'scripts/dev_tools/x.py'; content = 'c' } | ConvertTo-Json -Compress)
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $flat
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'no tool_input key'
        }

        It 'allows a well-formed nested Bash envelope whose tool_input carries no file_path (AC-6)' {
            # Property-level tolerance: this hook is registered on Bash, Write|Edit, and
            # Agent, so a Bash call legitimately carries no file_path. The scope-filter
            # early return must survive the strict envelope reader.
            $nested = '{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $nested
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a non-implementation file write (documentation path) without a checkpoint' {
            $json = ConvertTo-ImplementationWriteToolInput -FilePath 'docs/features/active/feature-x/notes.md'
            (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'blocks an implementation write when the resolved checkpoint is malformed JSON' {
            $json = ConvertTo-ImplementationWriteToolInput
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw '{broken'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'allows an implementation write when readiness is supplied via path_selected fallback' {
            $json = ConvertTo-ImplementationWriteToolInput
            $checkpoint = @{
                'issue-num'      = '500'
                'feature-folder' = 'docs/features/active/feature-500'
                path_selected    = 'small'
                lifecycle_ready  = $true
            } | ConvertTo-Json -Compress
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $checkpoint
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'blocks an implementation write when the checkpoint omits the feature folder' {
            $json = ConvertTo-ImplementationWriteToolInput
            $checkpoint = @{
                'issue-num'      = '500'
                'feature-folder' = ''
                route_id         = 'large'
                lifecycle_ready  = $true
            } | ConvertTo-Json -Compress
            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $checkpoint
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'Test-OrchestrationReady returns false for a null payload' {
            Test-OrchestrationReady -Payload $null | Should -BeFalse
        }

        It 'Test-ImplementationDelegation returns false for a null tool input' {
            Test-ImplementationDelegation -ToolInput $null | Should -BeFalse
        }
    }

    Context 'Entrypoint (exit code seam, no child process)' {
        It 'returns exit code 0 and emits a deny when every transport is empty' {
            $emptyReader = {
                Read-ClaudeHookRawPayload `
                    -ReadStandardInput { '' } `
                    -TestStandardInputRedirected { $true } `
                    -HookInputFallback '' `
                    -ToolInputFallback ''
            }
            $emitted = Invoke-OrchestrationPreimplementationGateEntryPoint -ReadPayload $emptyReader
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            $emitted[0] | Should -Match '"permissionDecision"\s*:\s*"deny"'
        }

        It 'returns exit code 0 and emits an allow decision JSON for a documentation write' {
            $nested = ConvertTo-ImplementationWriteToolInput -FilePath 'docs/features/active/feature-x/notes.md' -Content 'x'
            $emitted = Invoke-OrchestrationPreimplementationGateEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            $emitted[0] | Should -Match '"permissionDecision"\s*:\s*"allow"'
        }

        It 'returns exit code 0 and never 1 for unparseable JSON' {
            $emitted = Invoke-OrchestrationPreimplementationGateEntryPoint -ToolInputRaw '{not json'
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            $emitted[0] | Should -Match '"permissionDecision"\s*:\s*"deny"'
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
