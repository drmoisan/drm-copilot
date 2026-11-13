#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Codex preimplementation gate merged-feature follow-up allowance rows (issue #1141).

.DESCRIPTION
    Drives Invoke-OrchestrationPreimplementationGateDecision of
    .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 with the mapped Codex
    tool_input JSON in epic scope on the integration branch while fan-in is incomplete, so
    the readiness predicate fails with 'merge-in-progress'. Follow-ups on a child feature
    whose epic entry records a terminal merge_status, a merge_commit_sha, and a pr_number are
    admitted when every path lies under that feature's docs folders or is the epic status
    document; every other call keeps its deny text.

    The fixtures follow enforce-orchestration-preimplementation-gate-epic-fan-in.Tests.ps1:
    the resolver seams are mocked by name and the staged index is read through the mocked
    Get-OrchestrationGateStagedIndex seam. Every gate call passes -CheckpointRaw. No row
    creates a file or changes the working directory.
#>

Describe 'Codex preimplementation gate merged-feature follow-up allowance (issue #1141)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-OrchestrationDocsEstateFileText', 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-EpicScopeCheckpointText', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText' -Surface 'Codex'

        $script:ChildA = 'docs/features/active/2026-09-25-child-a-901'
        $script:NotReadySingleFeature = '{"issue-num":"1141","route_id":"large","lifecycle_ready":false}'
        $script:SingleFeatureReason = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'
        $script:FailBeforeCommand = "git commit -F /scratch/msg.txt -- $script:ChildA/evidence/other/x.md"
        $script:ChildCPatch = "*** Begin Patch`n*** Add File: docs/features/completed/2026-09-25-child-c-903/x.json`n+{}`n*** End Patch"

        function Get-FollowUpFixtureText {
            # Return the five-feature epic checkpoint text; Kind 'blank-manifest' blanks epic_manifest_path.
            param([string] $Kind = 'follow-up')
            $sha40 = 'ab12' * 10
            $sha64 = 'cd34' * 16
            $checkpoint = [ordered]@{
                route_id = 'epic'; epic_feature_folder = 'sample-epic'; epic_manifest_path = 'docs/features/epics/sample-epic/epic.md'
                integration_branch = 'epic/sample-epic-integration'; epic_issue_num = 900
                features = @(
                    [ordered]@{ feature_folder = '2026-09-25-child-a-901'; merge_status = 'merged'; merge_commit_sha = $sha40; pr_number = 901 }
                    [ordered]@{ feature_folder = '2026-09-25-child-b-902'; merge_status = 'pr_open'; merge_commit_sha = $sha40; pr_number = 902 }
                    [ordered]@{ feature_folder = 'docs/features/completed/2026-09-25-child-c-903'; merge_status = 'worktree_removed'; merge_commit_sha = $sha64; pr_number = 903 }
                    [ordered]@{ feature_folder = '2026-09-25-child-d-904'; merge_status = 'merged'; pr_number = 904 }
                    [ordered]@{ feature_folder = '2026-09-25-child-e-905'; merge_status = 'merged'; merge_commit_sha = $sha40 }
                )
            }
            if ($Kind -eq 'blank-manifest') { $checkpoint.epic_manifest_path = '' }
            return ($checkpoint | ConvertTo-Json -Depth 6 -Compress)
        }

        function Set-EpicScopeSeam {
            <#
                Mock the four resolver seams for one test. Value bodies close over local
                copies; the ascent body is plain so it sees the bound -Path argument.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([AllowNull()] [object] $CheckpointText, [string] $HeadBranch = 'epic/sample-epic-integration')
            $text = $CheckpointText
            $head = $HeadBranch
            Mock Find-WorktreeResolutionRoot {
                if ($Path -like '/synthetic-worktrees/epic-coordinator*') { return '/synthetic-worktrees/epic-coordinator' }
                if ($Path -like '/synthetic-worktrees/*') { return $Path }
                return '/synthetic-worktrees/epic-coordinator'
            }
            Mock Get-EpicScopeCheckpointText -MockWith ({ $text }.GetNewClosure())
            Mock Get-EpicScopeWorktreeHeadBranch -MockWith ({ $head }.GetNewClosure())
            Mock Test-EpicScopeMergeInProgress -MockWith { $false }
        }

        function Set-StagedIndexSeam {
            # Mock the staged-index read to return the given names, each NUL-terminated.
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
            param([AllowEmptyCollection()] [string[]] $Name = @())
            $text = -join @($Name | ForEach-Object { $_ + [char]0 })
            Mock Get-OrchestrationGateStagedIndex -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $text } }.GetNewClosure())
        }

        function Invoke-FollowUpGate {
            # Run the gate for one mapped tool_input hashtable.
            param([Parameter(Mandatory)] [hashtable] $ToolInput)
            return (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw ($ToolInput | ConvertTo-Json -Compress) -CheckpointRaw $script:NotReadySingleFeature)
        }

        function Set-FollowUpDefaultSeam {
            # Mock the follow-up fixture on the integration branch with a staged index under child-a.
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param()
            Set-EpicScopeSeam -CheckpointText (Get-FollowUpFixtureText)
            Set-StagedIndexSeam -Name @("$script:ChildA/evidence/other/x.md")
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText' }

    Context 'fail-before' {
        BeforeEach { Set-FollowUpDefaultSeam }

        It 'allows git commit -F with a pathspec under a merged feature folder' {
            $decision = Invoke-FollowUpGate -ToolInput @{ command = $script:FailBeforeCommand }
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "a follow-up commit under a merged feature folder is allowed (decision reason: $reason)"
        }

        It 'allows a pathless git commit -m when the staged index is under a merged feature folder' {
            $decision = Invoke-FollowUpGate -ToolInput @{ command = 'git commit -m follow-up' }
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "a pathless commit of a merged feature folder index is allowed (decision reason: $reason)"
        }
    }

    Context 'allows' {
        BeforeEach { Set-FollowUpDefaultSeam }

        It 'allows <Case>' -ForEach @(
            @{ Case = 'a file_path Write of a json under the completed root of child-a'; ToolInput = @{ file_path = 'docs/features/completed/2026-09-25-child-a-901/x.json' } }
            @{ Case = 'an apply_patch adding a json under the completed root of child-c'; ToolInput = 'child-c-patch' }
            @{ Case = 'git add of a child-a completed path'; ToolInput = @{ command = 'git add docs/features/completed/2026-09-25-child-a-901/a.md' } }
            @{ Case = 'git commit --file with a child-c completed pathspec'; ToolInput = @{ command = 'git commit --file /scratch/msg.txt -- docs/features/completed/2026-09-25-child-c-903/c.md' } }
            @{ Case = 'git commit --file with the epic status document as pathspec'; ToolInput = @{ command = 'git commit --file /scratch/msg.txt -- docs/features/epics/sample-epic/epic-status.md' } }
        ) {
            # Act
            $mapped = if ($ToolInput -eq 'child-c-patch') { @{ command = $script:ChildCPatch } } else { $ToolInput }
            $decision = Invoke-FollowUpGate -ToolInput $mapped

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "$Case is a merged-feature follow-up (decision reason: $reason)"
        }
    }

    Context 'denies' {
        BeforeEach { Set-FollowUpDefaultSeam }

        It 'denies <Case> and names merge-in-progress' -ForEach @(
            @{ Case = 'a follow-up for child-b whose merge_status is pr_open'; Command = 'git commit -F /scratch/msg.txt -- docs/features/active/2026-09-25-child-b-902/x.md'; Mixed = $false }
            @{ Case = 'a follow-up for child-d with no merge_commit_sha'; Command = 'git commit -F /scratch/msg.txt -- docs/features/active/2026-09-25-child-d-904/x.md'; Mixed = $false }
            @{ Case = 'a follow-up for child-e with no pr_number'; Command = 'git commit -F /scratch/msg.txt -- docs/features/active/2026-09-25-child-e-905/x.md'; Mixed = $false }
            @{ Case = 'a Write of scripts/x.ps1'; Command = ''; Mixed = $false }
            @{ Case = 'git commit --amend'; Command = 'git commit --amend -m m'; Mixed = $false }
            @{ Case = 'a pathless commit with a mixed index'; Command = 'git commit -m m'; Mixed = $true }
        ) {
            # Arrange
            if ($Mixed) { Set-StagedIndexSeam -Name @("$script:ChildA/x.md", 'scripts/x.ps1') }
            $toolInput = if ($Command) { @{ command = $Command } } else { @{ file_path = 'scripts/x.ps1' } }

            # Act
            $decision = Invoke-FollowUpGate -ToolInput $toolInput

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because $Case
            $decision.hookSpecificOutput.permissionDecisionReason.Contains("'merge-in-progress'") | Should -BeTrue
        }

        It 'denies a child-a commit when the readiness failure is epic_manifest_path' {
            # Arrange
            Set-EpicScopeSeam -CheckpointText (Get-FollowUpFixtureText -Kind 'blank-manifest')

            # Act
            $decision = Invoke-FollowUpGate -ToolInput @{ command = $script:FailBeforeCommand }

            # Assert: the allowance applies only to the exact merge-in-progress failure.
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason.Contains("'epic_manifest_path'") | Should -BeTrue
            $reason.Contains("'merge-in-progress'") | Should -BeFalse
        }

        It 'returns the unchanged single-feature deny for the follow-up commit when HEAD is not the integration_branch' {
            # Arrange
            Set-EpicScopeSeam -CheckpointText (Get-FollowUpFixtureText) -HeadBranch 'feature/standalone-item'

            # Act
            $decision = Invoke-FollowUpGate -ToolInput @{ command = $script:FailBeforeCommand }

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:SingleFeatureReason
        }
    }
}
