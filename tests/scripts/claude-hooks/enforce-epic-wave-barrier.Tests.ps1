#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the enforce-epic-wave-barrier.ps1 PreToolUse hook (Layer 1 deterrent).
#>

Describe 'enforce-epic-wave-barrier.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-wave-barrier.ps1").Path
        . $script:UnderTest
    }

    Context 'envelope anomalies and out-of-scope delegations' {
        It 'denies an empty payload as an envelope anomaly (fail closed)' {
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WAVE_BARRIER_BLOCKED'
        }

        It 'allows a non-orchestrator subagent delegation' {
            $json = '{"tool_name":"Agent","tool_input":{"subagent_type":"atomic-planner","prompt":"Epic mode: true. docs/features/active/child-b/spec.md"}}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows an orchestrator delegation whose prompt has no epic-mode marker' {
            $json = '{"tool_name":"Agent","tool_input":{"subagent_type":"orchestrator","prompt":"Canonical issue number for this feature is 300. docs/features/active/child-a-300/spec.md"}}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies unparseable JSON instead of throwing (exit 1 is non-blocking)' {
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw '{not-json'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }

        It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
            $flat = '{"subagent_type":"orchestrator","prompt":"Epic mode: true."}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $flat
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'no tool_input key'
        }
    }

    Context 'allow when all dependencies are merged/worktree_removed' {
        It 'allows when every depends_on entry has merge_status merged' {
            Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith {
                '{"features":[' +
                '{"feature_folder":"2026-07-02-child-a-300","depends_on":[],"merge_status":"merged"},' +
                '{"feature_folder":"2026-07-02-child-b-301","depends_on":["2026-07-02-child-a-300"],"merge_status":"not_started"}' +
                ']}'
            }
            $json = '{"tool_name":"Agent","tool_input":{"subagent_type":"orchestrator","prompt":"Epic mode: true. epic_feature_folder: epic-orchestrate-275. Upstream context for 2026-07-02-child-b-301: docs/features/active/2026-07-02-child-b-301/spec.md"}}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when a dependency has merge_status worktree_removed' {
            Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith {
                '{"features":[' +
                '{"feature_folder":"2026-07-02-child-a-300","depends_on":[],"merge_status":"worktree_removed"},' +
                '{"feature_folder":"2026-07-02-child-b-301","depends_on":["2026-07-02-child-a-300"],"merge_status":"not_started"}' +
                ']}'
            }
            $json = '{"tool_name":"Agent","tool_input":{"subagent_type":"orchestrator","prompt":"Epic mode: true. docs/features/active/2026-07-02-child-b-301/spec.md"}}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a wave-0 feature with an empty depends_on list' {
            Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith {
                '{"features":[{"feature_folder":"2026-07-02-child-a-300","depends_on":[],"merge_status":"not_started"}]}'
            }
            $json = '{"tool_name":"Agent","tool_input":{"subagent_type":"orchestrator","prompt":"Epic mode: true. docs/features/active/2026-07-02-child-a-300/spec.md"}}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'deny EPIC_WAVE_BARRIER_BLOCKED when a dependency is not yet merged' {
        It 'denies when a depends_on entry has merge_status pr_open' {
            Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith {
                '{"features":[' +
                '{"feature_folder":"2026-07-02-child-a-300","depends_on":[],"merge_status":"pr_open"},' +
                '{"feature_folder":"2026-07-02-child-b-301","depends_on":["2026-07-02-child-a-300"],"merge_status":"not_started"}' +
                ']}'
            }
            $json = '{"tool_name":"Agent","tool_input":{"subagent_type":"orchestrator","prompt":"Epic mode: true. docs/features/active/2026-07-02-child-b-301/spec.md"}}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WAVE_BARRIER_BLOCKED'
        }

        It 'denies when a depends_on entry has no matching features[] record' {
            Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith {
                '{"features":[{"feature_folder":"2026-07-02-child-b-301","depends_on":["2026-07-02-child-a-300"],"merge_status":"not_started"}]}'
            }
            $json = '{"tool_name":"Agent","tool_input":{"subagent_type":"orchestrator","prompt":"Epic mode: true. docs/features/active/2026-07-02-child-b-301/spec.md"}}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WAVE_BARRIER_BLOCKED'
        }

        It 'denies when the prompt cannot be resolved to a feature folder' {
            $json = '{"tool_name":"Agent","tool_input":{"subagent_type":"orchestrator","prompt":"Epic mode: true. no path token here"}}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WAVE_BARRIER_BLOCKED'
        }
    }

    Context 'deny on unreadable epic checkpoint' {
        It 'denies when the epic checkpoint file is absent' {
            Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith { $null }
            $json = '{"tool_name":"Agent","tool_input":{"subagent_type":"orchestrator","prompt":"Epic mode: true. docs/features/active/2026-07-02-child-b-301/spec.md"}}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WAVE_BARRIER_BLOCKED'
        }

        It 'denies when the epic checkpoint content is malformed JSON' {
            Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith { '{ broken json' }
            $json = '{"tool_name":"Agent","tool_input":{"subagent_type":"orchestrator","prompt":"Epic mode: true. docs/features/active/2026-07-02-child-b-301/spec.md"}}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WAVE_BARRIER_BLOCKED'
        }
    }

    Context 'Find-EpicWaveBarrierFeatureFolderFromPrompt helper' {
        It 'returns $null for an empty prompt' {
            Find-EpicWaveBarrierFeatureFolderFromPrompt -Prompt '' | Should -BeNullOrEmpty
        }

        It 'resolves a .md-suffixed match to its parent directory basename' {
            Find-EpicWaveBarrierFeatureFolderFromPrompt -Prompt 'see docs/features/active/2026-07-02-child-b-301/spec.md for details' |
                Should -Be '2026-07-02-child-b-301'
        }

        It 'returns $null when no path token is present' {
            Find-EpicWaveBarrierFeatureFolderFromPrompt -Prompt 'no path token here' | Should -BeNullOrEmpty
        }
    }

    Context 'Find-EpicWaveBarrierFeatureRecord helper' {
        It 'returns $null when Checkpoint is $null' {
            Find-EpicWaveBarrierFeatureRecord -Checkpoint $null -FeatureFolder 'a' | Should -BeNullOrEmpty
        }

        It 'returns $null when features key is absent' {
            $checkpoint = '{}' | ConvertFrom-Json
            Find-EpicWaveBarrierFeatureRecord -Checkpoint $checkpoint -FeatureFolder 'a' | Should -BeNullOrEmpty
        }
    }

    Context 'Test-EpicWaveBarrierDependenciesMerged helper' {
        It 'returns $false when Checkpoint is $null' {
            Test-EpicWaveBarrierDependenciesMerged -Checkpoint $null -FeatureRecord $null | Should -BeFalse
        }

        It 'returns $true when depends_on key is absent from the feature record' {
            $checkpoint = '{"features":[]}' | ConvertFrom-Json
            $feature = '{"feature_folder":"a"}' | ConvertFrom-Json
            Test-EpicWaveBarrierDependenciesMerged -Checkpoint $checkpoint -FeatureRecord $feature | Should -BeTrue
        }

        It 'returns $false when a dependency record has no merge_status key' {
            $checkpoint = '{"features":[{"feature_folder":"dep-a"}]}' | ConvertFrom-Json
            $feature = '{"feature_folder":"b","depends_on":["dep-a"]}' | ConvertFrom-Json
            Test-EpicWaveBarrierDependenciesMerged -Checkpoint $checkpoint -FeatureRecord $feature | Should -BeFalse
        }
    }

    Context 'real Test-Path read seam' {
        It 'Get-EpicWaveBarrierCheckpointContent returns $null when the checkpoint file does not exist' {
            Mock -CommandName Test-Path -MockWith { $false } -ParameterFilter { $LiteralPath -eq $script:EpicCheckpointPath }
            Get-EpicWaveBarrierCheckpointContent | Should -BeNullOrEmpty
        }

        It 'Get-EpicWaveBarrierCheckpointContent reads real content when the file exists' {
            Mock -CommandName Test-Path -MockWith { $true } -ParameterFilter { $LiteralPath -eq $script:EpicCheckpointPath }
            Mock -CommandName Get-Content -MockWith { '{"features":[]}' } -ParameterFilter { $LiteralPath -eq $script:EpicCheckpointPath }
            Get-EpicWaveBarrierCheckpointContent | Should -Be '{"features":[]}'
        }
    }

    Context 'entry-point exit code and emitted decision (AC-4, no child process)' {
        BeforeEach {
            Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith { $null }
        }


        It 'returns exit code 0 and emits a deny when every transport is empty' {
            $emptyReader = {
                Read-ClaudeHookRawPayload `
                    -ReadStandardInput { '' } `
                    -TestStandardInputRedirected { $true } `
                    -HookInputFallback '' `
                    -ToolInputFallback ''
            }
            $emitted = Invoke-EpicWaveBarrierEntryPoint -ReadPayload $emptyReader
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            $parsed = $emitted[0] | ConvertFrom-Json
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WAVE_BARRIER_BLOCKED'
        }

        It 'returns exit code 0 and emits a deny for unparseable JSON' {
            $emitted = Invoke-EpicWaveBarrierEntryPoint -ToolInputRaw '{not-json'
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'not parseable JSON'
        }

        It 'returns exit code 0 and emits a deny for JSON with no tool_input key' {
            $emitted = Invoke-EpicWaveBarrierEntryPoint -ToolInputRaw '{"session_id":"s1","tool_name":"Bash"}'
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'no tool_input key'
        }

        It 'returns exit code 0 and emits a deny for a null tool_input' {
            $emitted = Invoke-EpicWaveBarrierEntryPoint -ToolInputRaw '{"tool_name":"Bash","tool_input":null}'
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'tool_input is null'
        }

        It 'returns exit code 0 and emits a deny for a non-object tool_input' {
            $emitted = Invoke-EpicWaveBarrierEntryPoint -ToolInputRaw '{"tool_name":"Bash","tool_input":"text"}'
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'not an object'
        }

        It 'denies the nested envelope when an epic-mode delegation names no feature folder' {
            $nested = '{"tool_name":"Agent","tool_input":{"subagent_type":"orchestrator","prompt":"Epic mode: true. no path token here"}}'
            $emitted = Invoke-EpicWaveBarrierEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            $parsed = $emitted[0] | ConvertFrom-Json
            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WAVE_BARRIER_BLOCKED'
        }

        It 'allows a nested delegation whose prompt lacks the epic-mode marker' {
            $nested = '{"tool_name":"Agent","tool_input":{"subagent_type":"orchestrator","prompt":"plain delegation"}}'
            $emitted = Invoke-EpicWaveBarrierEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
