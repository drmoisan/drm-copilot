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

    Context 'shape rule checkpoint reads' {
        BeforeAll {
            $script:Wrapper = 'if gh pr checks 42; then gh pr merge 42 --merge; fi'
            $script:KeyJson = ConvertTo-EpicMergeGateReviewCheckpointJson
            $script:NoKeyJson = ConvertTo-EpicMergeGateReviewCheckpointJson -Remove 'review_mode', 'remediation_loop'

            function Invoke-ShapeRead {
                <#
                .SYNOPSIS
                    Run one command through the gate with separate session and item checkpoints.
                #>
                [CmdletBinding()]
                param(
                    [Parameter(Mandatory)][string] $Command,
                    [Parameter(Mandatory)][string] $SessionCheckpoint,
                    [Parameter(Mandatory)][string] $ItemCheckpoint
                )

                $sessionValue = $SessionCheckpoint
                $itemValue = $ItemCheckpoint
                Mock Get-ChildOrchestratorCheckpointContent -ParameterFilter { $Path -like '*session-1097*' } -MockWith ({ $sessionValue }.GetNewClosure())
                Mock Get-ChildOrchestratorCheckpointContent -ParameterFilter { $Path -like '*item-1097*' } -MockWith ({ $itemValue }.GetNewClosure())
                $envelope = @{ session_id = 'session-1097'; tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress
                $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
                return [pscustomobject]@{ Decision = [string]$decision.hookSpecificOutput.permissionDecision; Reason = [string]$decision.hookSpecificOutput.permissionDecisionReason }
            }

            function Assert-ShapeDenied {
                <#
                .SYNOPSIS
                    Assert the shape rule's denial, with no live-head read.
                #>
                [CmdletBinding()]
                param([Parameter(Mandatory)] $Result)

                $Result.Decision | Should -Be 'deny'
                $Result.Reason.StartsWith('EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_HEAD_UNRESOLVED: ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $Result.Reason
                Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
            }
        }

        It 'RG-SHAPE-KEY-IN-ITEM-WORKTREE-ONLY' {
            # Act: the session carries no key, and the unread merge names an item that does.
            $result = Invoke-ShapeRead -Command $script:Wrapper -SessionCheckpoint $script:NoKeyJson -ItemCheckpoint $script:KeyJson

            # Assert
            Assert-ShapeDenied -Result $result
        }

        It 'RG-SHAPE-SECOND-NUMBER-ITEM-CARRIES-KEY' {
            # Arrange: pull request 42 resolves to a keyless item, and 41 to an item with the key.
            $secondRoot = Join-Path '/synthetic-worktrees' 'second-1097'
            $keyJson = $script:KeyJson
            Mock Resolve-EpicMergeGateItemTarget -ParameterFilter { $PrNumber -eq 41 } -MockWith ({ [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = $secondRoot; ReasonCode = $null; Detail = 'second item (issue #1097)' } }.GetNewClosure())
            Mock Get-ChildOrchestratorCheckpointContent -ParameterFilter { $Path -like '*second-1097*' } -MockWith ({ $keyJson }.GetNewClosure())

            # Act
            $result = Invoke-ShapeRead -Command 'gh pr merge 42 --merge && gh pr merge 41 --merge' -SessionCheckpoint $script:NoKeyJson -ItemCheckpoint $script:NoKeyJson

            # Assert
            Assert-ShapeDenied -Result $result
        }

        It 'RG-SHAPE-SESSION-KEY-WITH-FIRST-ITEM-KEYLESS' {
            # Act
            $result = Invoke-ShapeRead -Command 'gh pr merge 42 --merge && git push' -SessionCheckpoint $script:KeyJson -ItemCheckpoint $script:NoKeyJson

            # Assert
            Assert-ShapeDenied -Result $result
        }

        It 'RG-SHAPE-NUMBERLESS-WRAPPER-SESSION-KEY' {
            # Act
            $result = Invoke-ShapeRead -Command 'if true; then gh pr merge --merge; fi' -SessionCheckpoint $script:KeyJson -ItemCheckpoint $script:NoKeyJson

            # Assert
            Assert-ShapeDenied -Result $result
        }

        It 'RG-SHAPE-BOUND-COMMAND-READS-NO-EXTRA-CHECKPOINT' {
            # Act
            $result = Invoke-ShapeRead -Command 'gh pr merge 42 --merge' -SessionCheckpoint $script:NoKeyJson -ItemCheckpoint $script:NoKeyJson

            # Assert: only the gate's own item read ran.
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
            Should -Invoke Get-ChildOrchestratorCheckpointContent -Times 1 -Exactly
            Should -Invoke Resolve-EpicMergeGateItemTarget -Times 1 -Exactly
        }

        It 'RG-SHAPE-NOKEY-RESOLUTION-FAILURE-KEEPS-DECISION (<Case>)' -ForEach @(
            @{ Case = 'git failure'; Fail = { throw 'git worktree list failed' } }
            @{ Case = 'timeout'; Fail = { throw [System.TimeoutException]::new('git worktree list timed out') } }
            @{ Case = 'no target'; Fail = { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'no target (issue #1097)' } } }
            @{ Case = 'ambiguous target'; Fail = { [pscustomobject]@{ Status = 'Ambiguous'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'; Detail = 'ambiguous (issue #1097)' } } }
        ) {
            # Arrange
            Mock Resolve-EpicMergeGateItemTarget -MockWith $Fail

            # Act
            $result = Invoke-ShapeRead -Command $script:Wrapper -SessionCheckpoint $script:NoKeyJson -ItemCheckpoint $script:NoKeyJson

            # Assert: today's out-of-scope allow, with the failed read attempted and no process.
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
            Should -Invoke Resolve-EpicMergeGateItemTarget -Times 1 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }

        It 'RG-SHAPE-NOKEY-RESOLUTION-FAILURE-KEEPS-DECISION (session root failure)' {
            # Arrange
            Mock Get-EpicMergeGateSessionWorktreeRoot { throw 'git rev-parse failed' }

            # Act
            $result = Invoke-ShapeRead -Command 'if true; then gh pr merge --merge; fi' -SessionCheckpoint $script:NoKeyJson -ItemCheckpoint $script:NoKeyJson

            # Assert
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
        }

        It 'RG-SHAPE-NOKEY-RESOLUTION-FAILURE-KEEPS-DECISION (in-scope candidate failure)' {
            # Arrange: the gate's own read of 42 succeeds, and only the extra read of 41 fails.
            Mock Resolve-EpicMergeGateItemTarget -ParameterFilter { $PrNumber -eq 41 } -MockWith { throw 'git worktree list failed' }

            # Act
            $result = Invoke-ShapeRead -Command 'gh pr merge 42 --merge && echo 41' -SessionCheckpoint $script:NoKeyJson -ItemCheckpoint $script:NoKeyJson

            # Assert: the ready child keeps today's allow.
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
        }

        It 'RG-SHAPE-RESOLUTION-FAILURE-KEEPS-SESSION-KEY-DENY' {
            # Arrange
            Mock Resolve-EpicMergeGateItemTarget { throw 'git worktree list failed' }

            # Act
            $result = Invoke-ShapeRead -Command $script:Wrapper -SessionCheckpoint $script:KeyJson -ItemCheckpoint $script:NoKeyJson

            # Assert: a key that was read still denies, so the best-effort read weakens nothing.
            Assert-ShapeDenied -Result $result
        }
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
