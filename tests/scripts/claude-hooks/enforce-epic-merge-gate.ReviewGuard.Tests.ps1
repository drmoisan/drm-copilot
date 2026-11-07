#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Decision rows of the review guard through the Claude merge gate (issue #1097).

.DESCRIPTION
    Drives every row of EpicMergeGateReview.Cases.Helpers.ps1 through Invoke-EpicMergeGateDecision
    with mocked target resolvers, checkpoint read seams, and process seams. No row starts a process,
    runs git or gh, or writes a file.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'EpicMergeGateReview.Cases.Helpers.ps1')
    $script:ReviewCaseRow = @(Get-EpicMergeGateReviewCaseRow)
    $script:ReviewDenyRow = @($script:ReviewCaseRow | Where-Object { $_.Expected -cne 'allow' })
}

Describe 'enforce-epic-merge-gate review guard (issue #1097)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        . (Join-Path $PSScriptRoot 'EpicMergeGateReview.Cases.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        Mock Get-ChildOrchestratorCheckpointContent { $null }
        Mock Get-EpicOrchestratorCheckpointContent { $null }
        Mock Get-ParallelOrchestratorCheckpointContent { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }

        $script:ItemRoot = Join-Path '/synthetic-worktrees' 'item-1097'
        $script:SessionRoot = Join-Path '/synthetic-worktrees' 'session-1097'
        $sessionRootValue = $script:SessionRoot
        $itemRootValue = $script:ItemRoot
        Mock Get-EpicMergeGateSessionWorktreeRoot -MockWith ({ $sessionRootValue }.GetNewClosure())
        Mock Resolve-EpicMergeGateItemTarget -MockWith ({ [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = $itemRootValue; ReasonCode = $null; Detail = 'item OtherWorktree (issue #1097)' } }.GetNewClosure())
        Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'run NoTarget (issue #1097)' } }

        function Invoke-ReviewGuardRow {
            <#
            .SYNOPSIS
                Run one row through the gate and return the decision text and its reason.
            #>
            [CmdletBinding()]
            param([Parameter(Mandatory)][hashtable] $Row)

            $checkpoint = ConvertTo-EpicMergeGateReviewCheckpointJson -Override $Row.Override -Remove $Row.Remove
            Mock Get-ChildOrchestratorCheckpointContent -MockWith ({ $checkpoint }.GetNewClosure())
            Register-EpicMergeGateReviewRowSeam -Row $Row
            $envelope = @{ session_id = 'session-1097'; tool_name = 'Bash'; tool_input = @{ command = $Row.Command } } | ConvertTo-Json -Depth 5 -Compress
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            return [pscustomobject]@{ Decision = [string]$decision.hookSpecificOutput.permissionDecision; Reason = [string]$decision.hookSpecificOutput.permissionDecisionReason }
        }

        function Get-ReviewGuardRow {
            <#
            .SYNOPSIS
                Return the shared row with the given name.
            #>
            [CmdletBinding()]
            [OutputType([hashtable])]
            param([Parameter(Mandatory)][string] $Name)

            return (Get-EpicMergeGateReviewCaseRow | Where-Object { $_.Name -ceq $Name })
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'RG-<Name>' -ForEach $script:ReviewCaseRow {
        # Arrange and act
        $result = Invoke-ReviewGuardRow -Row $_

        # Assert
        if ($Expected -ceq 'allow') {
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
        } else {
            $result.Decision | Should -Be 'deny'
            $result.Reason.StartsWith("EPIC_MERGE_GATE_BLOCKED: ${Expected}: ", [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
        }
        if ($ReasonNames) { $result.Reason.Contains($ReasonNames) | Should -BeTrue -Because $result.Reason }
        Assert-EpicMergeGateReviewRowProcessCount -Row $_
    }

    It 'RG-LIVE-HEAD-SEAM-USES-ONE-GH-CALL' {
        # Arrange: the seam itself runs, so only the process wrapper is mocked.
        $row = Get-ReviewGuardRow -Name 'head-equal'
        $row.GhResult = @{ ExitCode = 0; Output = ('{"headRefOid":"' + (Get-EpicMergeGateReviewHead -Kind Reviewed) + '"}') }

        # Act
        $result = Invoke-ReviewGuardRow -Row $row

        # Assert
        $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
        Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly
        Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 42 --json headRefOid' }
    }

    It 'RG-GIT-RUNS-IN-ITEM-WORKTREE' {
        # Arrange
        $row = Get-ReviewGuardRow -Name 'predecessor-feature-folder-only'
        $row.GhResult = @{ ExitCode = 0; Output = ('{"headRefOid":"' + (Get-EpicMergeGateReviewHead -Kind Live) + '"}') }
        $sessionRoot = $script:SessionRoot
        $itemRoot = $script:ItemRoot

        # Act
        $null = Invoke-ReviewGuardRow -Row $row

        # Assert: gh runs in the session worktree; both git calls run in the item worktree.
        Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { $WorkingRoot -ceq $sessionRoot }
        Should -Invoke Invoke-DocsOnlyGitExe -Times 2 -Exactly -ParameterFilter { $WorktreeRoot -ceq $itemRoot }
    }

    It 'RG-GATE-TOKEN-LEADS-EVERY-DENY (<Name>)' -ForEach $script:ReviewDenyRow {
        # Act
        $result = Invoke-ReviewGuardRow -Row $_

        # Assert: the gate returns the guard's reason unchanged, with its token first.
        $result.Decision | Should -Be 'deny'
        $result.Reason.StartsWith('EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
    }

    It 'RG-TWIN-IS-BYTE-IDENTICAL' {
        # Arrange
        $root = (Resolve-Path "$PSScriptRoot/../../..").Path

        # Act
        $claudeHash = (Get-FileHash -LiteralPath (Join-Path $root '.claude/hooks/enforce-epic-merge-gate-review.ps1') -Algorithm SHA256).Hash
        $codexHash = (Get-FileHash -LiteralPath (Join-Path $root '.codex/hooks/enforce-epic-merge-gate-review.ps1') -Algorithm SHA256).Hash

        # Assert
        $codexHash | Should -BeExactly $claudeHash
    }
}
