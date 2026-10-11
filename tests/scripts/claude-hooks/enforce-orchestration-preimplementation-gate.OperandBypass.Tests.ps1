#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #732 - gate-level exempt-operand bypass for the Claude preimplementation gate.
# Every decision is driven through the pure seam Invoke-OrchestrationPreimplementationGateDecision
# with an explicitly not-ready checkpoint, using the setup of the CommandExemption suite. The file
# creates no file and starts no child process. The two rows are the reported bypass shapes: a
# brace expansion and an escaped dot-segment walk out of an exempt tree.

Describe 'enforce-orchestration-preimplementation-gate.ps1 exempt-operand bypass (issue #732)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
        Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-EpicScopeCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent' -Surface 'Codex'
        Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/EpicScopeResolution.psm1").Path
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }

        function ConvertTo-BypassCommandPayload {
            <#
                Builds the Bash PreToolUse envelope the Claude gate reads, carrying the command
                text verbatim.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

            return (@{
                    tool_name  = 'Bash'
                    tool_input = @{ command = $Command }
                } | ConvertTo-Json -Compress -Depth 5)
        }

        function ConvertTo-BypassNotReadyCheckpointRaw {
            <#
                An explicitly NOT-ready checkpoint, so any allow decision could come only from
                the command-branch exemption.
            #>
            param()

            return @{
                'issue-num'      = ''
                'feature-folder' = ''
                route_id         = ''
                lifecycle_ready  = $false
            } | ConvertTo-Json -Compress
        }
        Mock Resolve-OrchestrationGateTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
        Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1").Path
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution { , [string[]] @() }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'denies <Label> without an authorizing checkpoint' -ForEach @(
        @{ Label = 'the issue 732 brace-expansion shape'; Command = 'git add docs/features/active/{..,..}/{..,..}/{..,..}/src/prod.ts' }
        @{ Label = 'the issue 732 escaped dot-segment shape'; Command = 'git add docs/features/active/.\./.\./.\./src/x.ps1' }
    ) {
        # Arrange
        $payload = ConvertTo-BypassCommandPayload -Command $Command

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw (ConvertTo-BypassNotReadyCheckpointRaw)

        # Assert
        $decision.hookSpecificOutput.permissionDecision |
            Should -Be 'deny' -Because "$Label reaches outside the exempt trees under at least one shell"
        $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('PREIMPLEMENTATION_GATE_BLOCKED:') |
            Should -BeTrue -Because 'the denial is the preimplementation gate block'
    }
}
