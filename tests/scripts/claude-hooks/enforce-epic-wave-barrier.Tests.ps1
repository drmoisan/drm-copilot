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

    Context 'allow (no-op) when the prompt lacks the epic-mode marker' {
        It 'allows when CLAUDE_TOOL_INPUT is empty' {
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a non-orchestrator subagent delegation' {
            $json = '{"subagent_type":"atomic-planner","prompt":"Epic mode: true. docs/features/active/child-b/spec.md"}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows an orchestrator delegation whose prompt has no epic-mode marker' {
            $json = '{"subagent_type":"orchestrator","prompt":"Canonical issue number for this feature is 300. docs/features/active/child-a-300/spec.md"}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'throws on malformed JSON so the hook exits 1' {
            { Invoke-EpicWaveBarrierDecision -ToolInputRaw '{not-json' } | Should -Throw
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
            $json = '{"subagent_type":"orchestrator","prompt":"Epic mode: true. epic_feature_folder: epic-orchestrate-275. Upstream context for 2026-07-02-child-b-301: docs/features/active/2026-07-02-child-b-301/spec.md"}'
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
            $json = '{"subagent_type":"orchestrator","prompt":"Epic mode: true. docs/features/active/2026-07-02-child-b-301/spec.md"}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a wave-0 feature with an empty depends_on list' {
            Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith {
                '{"features":[{"feature_folder":"2026-07-02-child-a-300","depends_on":[],"merge_status":"not_started"}]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Epic mode: true. docs/features/active/2026-07-02-child-a-300/spec.md"}'
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
            $json = '{"subagent_type":"orchestrator","prompt":"Epic mode: true. docs/features/active/2026-07-02-child-b-301/spec.md"}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WAVE_BARRIER_BLOCKED'
        }

        It 'denies when a depends_on entry has no matching features[] record' {
            Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith {
                '{"features":[{"feature_folder":"2026-07-02-child-b-301","depends_on":["2026-07-02-child-a-300"],"merge_status":"not_started"}]}'
            }
            $json = '{"subagent_type":"orchestrator","prompt":"Epic mode: true. docs/features/active/2026-07-02-child-b-301/spec.md"}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WAVE_BARRIER_BLOCKED'
        }

        It 'denies when the prompt cannot be resolved to a feature folder' {
            $json = '{"subagent_type":"orchestrator","prompt":"Epic mode: true. no path token here"}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WAVE_BARRIER_BLOCKED'
        }
    }

    Context 'deny on unreadable epic checkpoint' {
        It 'denies when the epic checkpoint file is absent' {
            Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith { $null }
            $json = '{"subagent_type":"orchestrator","prompt":"Epic mode: true. docs/features/active/2026-07-02-child-b-301/spec.md"}'
            $decision = Invoke-EpicWaveBarrierDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WAVE_BARRIER_BLOCKED'
        }

        It 'denies when the epic checkpoint content is malformed JSON' {
            Mock -CommandName Get-EpicWaveBarrierCheckpointContent -MockWith { '{ broken json' }
            $json = '{"subagent_type":"orchestrator","prompt":"Epic mode: true. docs/features/active/2026-07-02-child-b-301/spec.md"}'
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

    Context 'script entrypoint (end-to-end)' {
        BeforeAll {
            $script:HookPath = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-wave-barrier.ps1").Path
            $script:PwshExe = if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSEdition -eq 'Core') {
                (Get-Process -Id $PID).Path
            } else {
                (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source
            }
        }

        It 'allows when CLAUDE_TOOL_INPUT is empty (exit 0, allow)' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = ''
                $out = & $script:PwshExe -NoProfile -File $script:HookPath
                $LASTEXITCODE | Should -Be 0
                ($out | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
            } finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }

        It 'exits 1 on malformed JSON' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = '{not-json'
                $null = & $script:PwshExe -NoProfile -File $script:HookPath 2>&1
                $LASTEXITCODE | Should -Be 1
            } finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }
    }
}
