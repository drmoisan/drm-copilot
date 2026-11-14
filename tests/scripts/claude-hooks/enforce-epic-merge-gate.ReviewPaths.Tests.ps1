#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Merge-path rows of the review guard through the Claude merge gate (issue #1097).

.DESCRIPTION
    Proves, for each path the gate can allow, that review and CI are both required under the key,
    and that a checkpoint without the key keeps today's decision, makes no new gh call, and starts
    no guard git call. Rows that prove the process wrapper, and the no-key rows, mock
    Invoke-DocsOnlyGhExe; the rest mock the guard's live-head seam. No row starts a process, runs git
    or gh, or writes a file.
#>

Describe 'enforce-epic-merge-gate review paths (issue #1097)' {
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

        $script:Reviewed = Get-EpicMergeGateReviewHead -Kind Reviewed
        $reviewedValue = $script:Reviewed
        $itemRootValue = Join-Path '/synthetic-worktrees' 'item-1097'
        $sessionRootValue = Join-Path '/synthetic-worktrees' 'session-1097'
        $script:AllowJson = '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
        $script:NoRun = [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'run NoTarget (issue #1097)' }
        $noRunValue = $script:NoRun
        Mock Get-EpicMergeGateSessionWorktreeRoot -MockWith ({ $sessionRootValue }.GetNewClosure())
        Mock Resolve-EpicMergeGateItemTarget -MockWith ({ [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = $itemRootValue; ReasonCode = $null; Detail = 'item OtherWorktree (issue #1097)' } }.GetNewClosure())
        Mock Resolve-EpicMergeGateRunTarget -MockWith ({ $noRunValue }.GetNewClosure())
        Mock Resolve-EpicMergeGateParallelItemByWorktree -MockWith ({ $noRunValue }.GetNewClosure())
        Mock Get-EpicMergeGateReviewLiveHeadSha -MockWith ({ $reviewedValue }.GetNewClosure())

        function Get-ReviewPathChildJson {
            <#
            .SYNOPSIS
                Return a child checkpoint for one path, with review and CI state chosen by the row.
            .PARAMETER Path
                PATH1, PATH3, PATH3B, or PATH4.
            .PARAMETER ReviewPending
                Drop the review record.
            .PARAMETER CiPending
                Leave the path's own CI control unsatisfied.
            .PARAMETER NoKey
                Drop review_mode.
            #>
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory)][string] $Path, [switch] $ReviewPending, [switch] $CiPending, [switch] $NoKey)

            $override = @{}
            $remove = [System.Collections.Generic.List[string]]::new()
            if ($ReviewPending) { $remove.Add('remediation_loop') }
            if ($NoKey) { $remove.Add('review_mode') }
            if ($Path -cne 'PATH1') { $remove.Add('epic_mode') }
            if ($Path -ceq 'PATH1' -and $CiPending) { $override['step9_status'] = 'pending' }
            if ($Path -ceq 'PATH3B') { $override['ci_gate'] = [ordered]@{ conclusion = $(if ($CiPending) { 'pending' } else { 'success' }); head_sha = $script:Reviewed } }
            if ($Path -ceq 'PATH3' -or $Path -ceq 'PATH4') { $override['step9_status'] = 'pending' }
            if ($Path -ceq 'PATH4') {
                $override['standalone_merge_authorizations'] = @([ordered]@{
                        pr_number     = 42
                        pr_url        = 'https://github.com/drmoisan/drm-copilot/pull/42'
                        issue_num     = 1097
                        branch_name   = 'feature/item-42'
                        authorized_by = 'orchestrator'
                        authorized_at = '2026-11-06T21:04:00Z'
                        session_id    = 'session-1097'
                        basis         = 'Fixture record for the authorization path of the review guard.'
                    })
            }
            return (ConvertTo-EpicMergeGateReviewCheckpointJson -Override $override -Remove $remove.ToArray())
        }

        function Register-ReviewPathRunCheckpoint {
            <#
            .SYNOPSIS
                Record the parallel or epic run checkpoint for pull request 42.
            .PARAMETER Kind
                parallel or epic.
            .PARAMETER Text
                The run checkpoint text.
            #>
            [CmdletBinding()]
            param([Parameter(Mandatory)][string] $Kind, [Parameter(Mandatory)][string] $Text)

            $runText = $Text
            $target = [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = (Join-Path '/synthetic-worktrees' 'run-1097'); ReasonCode = $null; Detail = 'run SessionRoot (issue #1097)' }
            if ($Kind -ceq 'parallel') {
                Mock Resolve-EpicMergeGateRunTarget -ParameterFilter { $Kind -ceq 'parallel' } -MockWith ({ $target }.GetNewClosure())
                Mock Get-ParallelOrchestratorCheckpointContent -MockWith ({ $runText }.GetNewClosure())
            } else {
                Mock Resolve-EpicMergeGateRunTarget -ParameterFilter { $Kind -ceq 'epic' } -MockWith ({ $target }.GetNewClosure())
                Mock Get-EpicOrchestratorCheckpointContent -MockWith ({ $runText }.GetNewClosure())
            }
        }

        function Register-ReviewPathDocsOnlySeam {
            <#
            .SYNOPSIS
                Mock the docs-only process seams and the targets of a pull request no checkpoint records.
            #>
            [CmdletBinding()]
            param()

            $listing = Get-EpicMergeGateReviewListing -Path 'docs/guide.md'
            $root = $PSScriptRoot
            $noRun = $script:NoRun
            Mock Get-EpicMergeGateSessionWorktreeRoot -MockWith ({ $root }.GetNewClosure())
            Mock Resolve-EpicMergeGateItemTarget -MockWith ({ $noRun }.GetNewClosure())
            Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 0; Output = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'fedcba9876543210fedcba9876543210fedcba98' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq '0123456789abcdef0123456789abcdef01234567^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '0123456789abcdef0123456789abcdef01234567' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $listing } }.GetNewClosure())
        }

        function Invoke-ReviewPathDecision {
            <#
            .SYNOPSIS
                Run the gate for pull request 42 over a child checkpoint and return decision and reason.
            .PARAMETER Child
                The child checkpoint text, or $null when no child checkpoint is read.
            #>
            [CmdletBinding()]
            param([AllowNull()][string] $Child)

            $childText = $Child
            Mock Get-ChildOrchestratorCheckpointContent -MockWith ({ $childText }.GetNewClosure())
            $envelope = @{ session_id = 'session-1097'; tool_name = 'Bash'; tool_input = @{ command = 'gh pr merge 42 --merge' } } | ConvertTo-Json -Depth 5 -Compress
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            return [pscustomobject]@{ Decision = [string]$decision.hookSpecificOutput.permissionDecision; Reason = [string]$decision.hookSpecificOutput.permissionDecisionReason; Json = ($decision | ConvertTo-Json -Compress -Depth 5) }
        }

        function Assert-ReviewPathDeniedByCi {
            <#
            .SYNOPSIS
                Assert a deny that comes from the path's CI control, not from the guard.
            .PARAMETER Result
                The result of Invoke-ReviewPathDecision.
            #>
            [CmdletBinding()]
            param([Parameter(Mandatory)] $Result)

            $Result.Decision | Should -Be 'deny'
            $Result.Reason.StartsWith('EPIC_MERGE_GATE_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $Result.Reason
            $Result.Reason.Contains('REVIEW_GATE_') | Should -BeFalse -Because $Result.Reason
        }

        function Assert-ReviewPathDeniedByReview {
            <#
            .SYNOPSIS
                Assert a deny that comes from the guard with REVIEW_GATE_NOT_PASSED.
            .PARAMETER Result
                The result of Invoke-ReviewPathDecision.
            #>
            [CmdletBinding()]
            param([Parameter(Mandatory)] $Result)

            $Result.Decision | Should -Be 'deny'
            $Result.Reason.StartsWith('EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_NOT_PASSED: ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $Result.Reason
        }

        function Assert-ReviewPathNoGuardProcess {
            <#
            .SYNOPSIS
                Assert a no-key row: today's allow text, the branch's own gh count, and no guard git call.
            .PARAMETER Result
                The result of Invoke-ReviewPathDecision.
            .PARAMETER GhCount
                The number of gh calls the branch itself makes.
            #>
            [CmdletBinding()]
            param([Parameter(Mandatory)] $Result, [Parameter(Mandatory)][int] $GhCount)

            $Result.Json | Should -BeExactly $script:AllowJson
            Should -Invoke Invoke-DocsOnlyGhExe -Times $GhCount -Exactly
            Should -Invoke Get-EpicMergeGateReviewLiveHeadSha -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -ParameterFilter { $GitArgs -contains '--is-ancestor' }
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -ParameterFilter { $GitArgs -contains '--name-only' -and $GitArgs -contains $script:Reviewed }
        }

        $script:ParallelGreen = '{"route_id":"parallel","items":[{"pr_number":42,"merge_status":"ci_green"}]}'
        $script:ParallelPending = '{"route_id":"parallel","items":[{"pr_number":42,"merge_status":"pr_open"}]}'
        $script:EpicGreen = '{"epic_merge_pr":{"pr_number":42,"ci_gate":{"conclusion":"success"}}}'
        $script:EpicPending = '{"epic_merge_pr":{"pr_number":42,"ci_gate":{"conclusion":"pending"}}}'
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'path 1, epic child' {
        It 'RGP-PATH1-REVIEW-PASSED-CI-PENDING-DENIED' {
            $result = Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH1 -CiPending)
            Assert-ReviewPathDeniedByCi -Result $result
            Should -Invoke Get-EpicMergeGateReviewLiveHeadSha -Times 1 -Exactly
        }
        It 'RGP-PATH1-CI-GREEN-REVIEW-PENDING-DENIED' {
            Assert-ReviewPathDeniedByReview -Result (Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH1 -ReviewPending))
        }
        It 'RGP-PATH1-BOTH-ALLOWED' {
            # An allowed epic-child merge needs a verified CI run (issue #1130); the child-CI seams are mocked green by name.
            Register-EpicMergeGateReviewChildCiSeam -HeadSha $script:Reviewed
            (Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH1)).Json | Should -BeExactly $script:AllowJson
        }
    }

    Context 'path 3, parallel item through the item target' {
        It 'RGP-PATH3-REVIEW-PASSED-CI-PENDING-DENIED' {
            Register-ReviewPathRunCheckpoint -Kind parallel -Text $script:ParallelPending
            Assert-ReviewPathDeniedByCi -Result (Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH3))
        }
        It 'RGP-PATH3-CI-GREEN-REVIEW-PENDING-DENIED' {
            Register-ReviewPathRunCheckpoint -Kind parallel -Text $script:ParallelGreen
            Assert-ReviewPathDeniedByReview -Result (Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH3 -ReviewPending))
        }
        It 'RGP-PATH3-BOTH-ALLOWED' {
            # Issue #1130: the child-CI seams are mocked green by name so no allow row depends on a live CI lookup.
            Register-EpicMergeGateReviewChildCiSeam -HeadSha $script:Reviewed
            Register-ReviewPathRunCheckpoint -Kind parallel -Text $script:ParallelGreen
            (Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH3)).Json | Should -BeExactly $script:AllowJson
        }
    }

    Context 'path 3b, standalone green CI' {
        BeforeEach {
            $head = $script:Reviewed
            Mock Get-EpicMergeGateLivePrHeadSha -MockWith ({ $head }.GetNewClosure())
        }
        It 'RGP-PATH3B-REVIEW-PASSED-CI-PENDING-DENIED' {
            Assert-ReviewPathDeniedByCi -Result (Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH3B -CiPending))
        }
        It 'RGP-PATH3B-CI-GREEN-REVIEW-PENDING-DENIED' {
            Assert-ReviewPathDeniedByReview -Result (Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH3B -ReviewPending))
        }
        It 'RGP-PATH3B-BOTH-ALLOWED' {
            # Issue #1130: the child-CI seams are mocked green by name so no allow row depends on a live CI lookup.
            Register-EpicMergeGateReviewChildCiSeam -HeadSha $script:Reviewed
            (Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH3B)).Json | Should -BeExactly $script:AllowJson
            Should -Invoke Get-EpicMergeGateReviewLiveHeadSha -Times 1 -Exactly
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 1 -Exactly
        }
    }

    Context 'path 2, epic integration, which the guard does not read without a child key' {
        It 'RGP-PATH2-CI-PENDING-DENIED' {
            Register-ReviewPathRunCheckpoint -Kind epic -Text $script:EpicPending
            Assert-ReviewPathDeniedByCi -Result (Invoke-ReviewPathDecision -Child $null)
        }
        It 'RGP-PATH2-CI-GREEN-NO-CHILD-KEY-ALLOWED' {
            Register-ReviewPathRunCheckpoint -Kind epic -Text $script:EpicGreen
            (Invoke-ReviewPathDecision -Child $null).Json | Should -BeExactly $script:AllowJson
            Should -Invoke Get-EpicMergeGateReviewLiveHeadSha -Times 0 -Exactly
        }
        It 'RGP-PATH2-CHILD-KEY-REVIEW-PENDING-DENIED' {
            Register-ReviewPathRunCheckpoint -Kind epic -Text $script:EpicGreen
            Assert-ReviewPathDeniedByReview -Result (Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH3 -ReviewPending))
        }
    }

    Context 'path 4, authorization record' {
        It 'RGP-PATH4-CI-GREEN-REVIEW-PENDING-DENIED' {
            Assert-ReviewPathDeniedByReview -Result (Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH4 -ReviewPending))
        }
        It 'RGP-PATH4-REVIEW-PASSED-CI-NOT-READ-ALLOWED-D10-LIMIT' {
            # The record path reads no CI result; the required CI context is the control (D10).
            (Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH4)).Json | Should -BeExactly $script:AllowJson
        }
    }

    Context 'docs-only branch, where no recording checkpoint can carry the key' {
        It 'RGP-DOCS-ONLY-UNCHANGED' {
            Register-ReviewPathDocsOnlySeam
            (Invoke-ReviewPathDecision -Child $null).Json | Should -BeExactly $script:AllowJson
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 42 --json baseRefName,headRefOid' }
            Should -Invoke Get-EpicMergeGateReviewLiveHeadSha -Times 0 -Exactly
        }
    }

    Context 'a checkpoint without the key' {
        It 'RGP-NOKEY-PATH1-NO-GH-NO-DENIAL-UNCHANGED' {
            # An allowed epic-child merge needs a verified CI run (issue #1130); the seams are mocked by name, so the gh count stays 0.
            Register-EpicMergeGateReviewChildCiSeam -HeadSha $script:Reviewed
            Assert-ReviewPathNoGuardProcess -GhCount 0 -Result (Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH1 -NoKey -ReviewPending))
        }
        It 'RGP-NOKEY-PATH2-NO-GH-NO-DENIAL-UNCHANGED' {
            Register-ReviewPathRunCheckpoint -Kind epic -Text $script:EpicGreen
            Assert-ReviewPathNoGuardProcess -GhCount 0 -Result (Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH3 -NoKey -ReviewPending))
        }
        It 'RGP-NOKEY-PATH3-NO-GH-NO-DENIAL-UNCHANGED' {
            Register-ReviewPathRunCheckpoint -Kind parallel -Text $script:ParallelGreen
            Assert-ReviewPathNoGuardProcess -GhCount 0 -Result (Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH3 -NoKey -ReviewPending))
        }
        It 'RGP-NOKEY-PATH3B-NO-GH-NO-DENIAL-UNCHANGED' {
            # The green-CI branch makes its own single lookup, through its real seam in this row.
            $head = $script:Reviewed
            Mock Invoke-DocsOnlyGhExe -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = ('{"headRefOid":"' + $head + '"}') } }.GetNewClosure())
            Assert-ReviewPathNoGuardProcess -GhCount 1 -Result (Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH3B -NoKey -ReviewPending))
        }
        It 'RGP-NOKEY-PATH4-NO-GH-NO-DENIAL-UNCHANGED' {
            Assert-ReviewPathNoGuardProcess -GhCount 0 -Result (Invoke-ReviewPathDecision -Child (Get-ReviewPathChildJson -Path PATH4 -NoKey -ReviewPending))
        }
        It 'RGP-NOKEY-DOCS-ONLY-NO-GH-NO-DENIAL-UNCHANGED' {
            Register-ReviewPathDocsOnlySeam
            Assert-ReviewPathNoGuardProcess -GhCount 1 -Result (Invoke-ReviewPathDecision -Child $null)
        }
    }
}
