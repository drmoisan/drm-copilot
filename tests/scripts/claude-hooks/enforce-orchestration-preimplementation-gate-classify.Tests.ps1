#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Stage-1 classification supplement rows for the Claude preimplementation gate (issue #1188).

.DESCRIPTION
    The classification rows drive Test-ImplementationCommand of
    .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 for the two supplement forms
    (a joined shell word split at $(, ${, or a backtick, and npx options before the tool word), their
    near misses, and controls. The function rows drive Get-OrchestrationGateSupplementalPatternIndex
    from .claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1 alone; their Context
    dot-sources that file in its own BeforeAll. I2 asserts the fail-closed deny for a failed
    dot-source of the classify sibling. The tables live in
    enforce-orchestration-preimplementation-gate-classify.Cases.ps1, which the Codex suite shares.

    The outermost BeforeAll follows the epic-state isolation pattern of
    enforce-orchestration-preimplementation-gate-operands.Tests.ps1. No row creates a file, reads a
    clock, starts git, or touches the network.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-classify.Cases.ps1')
}

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-EpicScopeCheckpointText' -Surface 'Claude'
    Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent' -Surface 'Codex'
    Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/EpicScopeResolution.psm1").Path
    Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
    Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1").Path
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }

    function ConvertTo-ToolPayload {
        param([string] $Command)
        return (@{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5)
    }
}

Describe 'Claude gate stage-1 classification supplement (issue #1188)' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'classifies <Kind> row <Command> as <Expected>' -ForEach $script:ClassifyGateRows {
        # Act
        $result = Test-ImplementationCommand -Command $Command

        # Assert
        $result | Should -Be $Expected -Because "the $Kind row's classification is pinned by issue #1188"
    }

    Context 'Get-OrchestrationGateSupplementalPatternIndex alone (function rows)' {
        BeforeAll {
            . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1").Path
        }

        It 'F <Name>' -ForEach $script:ClassifyFunctionRows {
            # Act
            $result = @(Get-OrchestrationGateSupplementalPatternIndex -CommandText $Command)

            # Assert
            ($result -join ',') | Should -BeExactly (@($Indexes) -join ',') -Because 'the supplement returns exactly the stage-1 indexes its two forms match'
        }
    }

    It 'I2 denies naming enforce-orchestration-preimplementation-gate-classify.ps1 when its dot-source failed' {
        # Arrange
        Add-HookDependencyFailure -Name 'enforce-orchestration-preimplementation-gate-classify.ps1'
        try {
            # Act
            $gateResult = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw (ConvertTo-ToolPayload -Command 'npm run lint')
        }
        finally {
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
        }

        # Assert
        $gateResult.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $gateResult.hookSpecificOutput.permissionDecisionReason | Should -Match 'enforce-orchestration-preimplementation-gate-classify\.ps1'
    }
}
