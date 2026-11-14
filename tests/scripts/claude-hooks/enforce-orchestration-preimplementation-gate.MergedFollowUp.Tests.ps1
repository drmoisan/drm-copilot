#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Preimplementation gate merged-feature follow-up allowance rows (issue #1141).

.DESCRIPTION
    Drives Invoke-OrchestrationPreimplementationGateDecision in epic scope on the integration
    branch while fan-in is incomplete: no merge is in progress, so the readiness predicate
    fails with 'merge-in-progress'. A follow-up on a child feature whose epic entry records a
    terminal merge_status, a merge_commit_sha, and a pr_number is admitted when every path lies
    under that feature's docs folders or is the epic status document; every other call keeps
    its unchanged deny text.

    The fixtures follow enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1: the
    gate is dot-sourced first, EpicScopeResolution.psm1 is imported without -Force, the
    resolver seams are mocked inside that module, and the staged index is read through the
    mocked Get-OrchestrationGateStagedIndex seam. Every gate call passes -CheckpointRaw. No row
    creates a file or changes the working directory.
#>

BeforeAll {
    $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude").Path
    . (Join-Path $script:HookRoot 'hooks/enforce-orchestration-preimplementation-gate.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' -Surface 'Claude'
    if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
    Mock Get-CheckpointContent { $null }
    Mock Get-EpicCheckpointContent { $null }
    Mock Get-ParallelCheckpointContent { $null }
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/EpicScopeResolution.psm1')
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeResolution.psm1')

    $script:ChildA = 'docs/features/active/2026-09-25-child-a-901'
    $script:ChildACompleted = 'docs/features/completed/2026-09-25-child-a-901'
    $script:ChildCCompleted = 'docs/features/completed/2026-09-25-child-c-903'
    $script:StatusDoc = 'docs/features/epics/sample-epic/epic-status.md'
    $script:FailBeforeCommand = "git commit -F /scratch/msg.txt -- $script:ChildA/evidence/other/x.md"
    $script:NotReadySingleFeature = '{"issue-num":"1141","route_id":"large","lifecycle_ready":false}'
    $script:SingleFeatureReason = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'
    $script:EpicCheckpointPath = '/synthetic-worktrees/epic-coordinator/artifacts/orchestration/epic-orchestrator-state.json'

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
            Mock the resolver seams inside EpicScopeResolution. The bodies close over local
            copies because a module-scoped mock body cannot see this scope otherwise.
        #>
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([AllowNull()] [string] $CheckpointText, [string] $HeadBranch = 'epic/sample-epic-integration')
        $text = $CheckpointText
        $head = $HeadBranch
        Mock Find-WorktreeResolutionRoot -ModuleName EpicScopeResolution {
            if ($Path -like '/synthetic-worktrees/epic-coordinator*') { return '/synthetic-worktrees/epic-coordinator' }
            if ($Path -like '/synthetic-worktrees/*') { return $Path }
            return '/synthetic-worktrees/epic-coordinator'
        }
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $text }.GetNewClosure()
        Mock Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution { $head }.GetNewClosure()
        Mock Test-EpicScopeMergeInProgress -ModuleName EpicScopeResolution { $false }
    }

    function Set-StagedIndexSeam {
        # Mock the staged-index read to return the given names, each NUL-terminated.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
        param([AllowEmptyCollection()] [string[]] $Name = @())
        $text = -join @($Name | ForEach-Object { $_ + [char]0 })
        Mock Get-OrchestrationGateStagedIndex { [pscustomobject]@{ ExitCode = 0; Output = $text } }.GetNewClosure()
    }

    function Set-FollowUpDefaultSeam {
        # Mock the follow-up fixture on the integration branch with a staged index under child-a.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param()
        Set-EpicScopeSeam -CheckpointText (Get-FollowUpFixtureText)
        Set-StagedIndexSeam -Name @("$script:ChildA/evidence/other/x.md")
    }

    function Invoke-FollowUpGate {
        # Run the gate for one Bash command or one Write/Edit path against the follow-up fixture.
        param([string] $Tool = 'Bash', [Parameter(Mandatory)] [string] $Operand, [string] $CheckpointRaw = $script:NotReadySingleFeature)
        $toolInput = if ($Tool -eq 'Bash') { @{ command = $Operand } } else { @{ file_path = $Operand } }
        $payload = @{ tool_name = $Tool; tool_input = $toolInput } | ConvertTo-Json -Depth 5 -Compress
        return (Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $payload -CheckpointRaw $CheckpointRaw)
    }

    function Get-EpicScopeDenyReason {
        # Return the unchanged session-root epic-scope deny text for one failed predicate, built by the production outcome function.
        param([Parameter(Mandatory)] [string] $Failure)
        $failed = $Failure
        $verdict = [pscustomobject]@{
            Verdict     = 'evaluate'
            Evaluations = @([pscustomobject]@{ Target = '/synthetic-worktrees/epic-coordinator'; IsSessionRoot = $true; Scope = [pscustomobject]@{ CheckpointPath = $script:EpicCheckpointPath } })
        }
        return (Resolve-OrchestrationEpicTargetOutcome -Verdict $verdict -ReadinessFailure { $failed }.GetNewClosure()).Reason
    }

    Mock Resolve-OrchestrationGateTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
    Import-Module (Join-Path $script:HookRoot 'lib/worktree-resolution/WorktreeRunResolution.psm1')
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    Mock Resolve-WorktreeEpicTarget -ModuleName EpicScopeResolution { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $SessionRoot; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
}

Describe 'preimplementation gate merged-feature follow-up allowance (issue #1141)' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'fail-before' {
        BeforeEach { Set-FollowUpDefaultSeam }

        It 'allows git commit -F with a pathspec under a merged feature folder' {
            # Act
            $decision = Invoke-FollowUpGate -Operand $script:FailBeforeCommand

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "a follow-up commit under a merged feature folder is allowed (decision reason: $reason)"
        }

        It 'allows a pathless git commit -m when the staged index is under a merged feature folder' {
            # Act
            $decision = Invoke-FollowUpGate -Operand 'git commit -m follow-up'

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "a pathless commit of a merged feature folder index is allowed (decision reason: $reason)"
        }
    }

    Context 'allows' {
        BeforeEach { Set-FollowUpDefaultSeam }

        It 'allows <Case>' -ForEach @(
            @{ Case = 'a Write of a json under the completed root of child-a'; Tool = 'Write'; Operand = 'docs/features/completed/2026-09-25-child-a-901/evidence/other/x.json' }
            @{ Case = 'an Edit of a json under the completed root of child-a'; Tool = 'Edit'; Operand = 'docs/features/completed/2026-09-25-child-a-901/state.json' }
            @{ Case = 'an absolute Write into the integration root under the completed root of child-c'; Tool = 'Write'; Operand = '/synthetic-worktrees/epic-coordinator/docs/features/completed/2026-09-25-child-c-903/x.json' }
            @{ Case = 'git add of a child-a and a child-c completed path'; Tool = 'Bash'; Operand = 'git add docs/features/completed/2026-09-25-child-a-901/a.md docs/features/completed/2026-09-25-child-c-903/c.md' }
            @{ Case = 'git add -- of a child-c completed path'; Tool = 'Bash'; Operand = 'git add -- docs/features/completed/2026-09-25-child-c-903/c.md' }
            @{ Case = 'git -C the integration root commit --message with a child-a completed pathspec'; Tool = 'Bash'; Operand = 'git -C /synthetic-worktrees/epic-coordinator commit --message m -- docs/features/completed/2026-09-25-child-a-901/a.md' }
            @{ Case = 'git commit --file --trailer with a child-c completed pathspec'; Tool = 'Bash'; Operand = 'git commit --file /scratch/msg.txt --trailer Co-Authored-By:x -- docs/features/completed/2026-09-25-child-c-903/c.md' }
        ) {
            # Act
            $decision = Invoke-FollowUpGate -Tool $Tool -Operand $Operand

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "$Case is a merged-feature follow-up (decision reason: $reason)"
        }

        It 'allows git commit -F with the epic status document as pathspec' {
            # Act
            $decision = Invoke-FollowUpGate -Operand "git commit -F /scratch/msg.txt -- $script:StatusDoc"

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "the status document is an allowed root while fan-in is incomplete (decision reason: $reason)"
        }

        It 'allows a pathless git commit -m whose index holds a child-a active and a child-c completed path' {
            # Arrange
            Set-StagedIndexSeam -Name @("$script:ChildA/x.md", "$script:ChildCCompleted/c.md")

            # Act
            $decision = Invoke-FollowUpGate -Operand 'git commit -m m'

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "every staged name lies under an allowed root (decision reason: $reason)"
        }
    }

    Context 'already admitted' {
        BeforeEach { Set-FollowUpDefaultSeam }

        It 'keeps allowing <Case>' -ForEach @(
            @{ Case = 'git add of the status doc'; Operand = 'git add docs/features/epics/sample-epic/epic-status.md' }
            @{ Case = 'git commit -m with a child-a active pathspec'; Operand = 'git commit -m m -- docs/features/active/2026-09-25-child-a-901/x.md' }
        ) {
            # Act
            $decision = Invoke-FollowUpGate -Operand $Operand

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "$Case was admitted before the change"
        }
    }

    Context 'denies with unchanged text' {
        BeforeEach { Set-FollowUpDefaultSeam }

        It 'denies <Case>' -ForEach @(
            @{ Case = 'a follow-up for child-b whose merge_status is pr_open'; Tool = 'Bash'; Operand = 'git commit -F /scratch/msg.txt -- docs/features/active/2026-09-25-child-b-902/x.md'; Index = 'child-a' }
            @{ Case = 'a follow-up for child-d with no merge_commit_sha'; Tool = 'Bash'; Operand = 'git commit -F /scratch/msg.txt -- docs/features/active/2026-09-25-child-d-904/x.md'; Index = 'child-a' }
            @{ Case = 'a follow-up for child-e with no pr_number'; Tool = 'Bash'; Operand = 'git commit -F /scratch/msg.txt -- docs/features/active/2026-09-25-child-e-905/x.md'; Index = 'child-a' }
            @{ Case = 'a Write of scripts/x.ps1'; Tool = 'Write'; Operand = 'scripts/x.ps1'; Index = 'child-a' }
            @{ Case = 'a sibling-prefix folder of child-a'; Tool = 'Bash'; Operand = 'git commit -F /scratch/msg.txt -- docs/features/active/2026-09-25-child-a-901-x/y.md'; Index = 'child-a' }
            @{ Case = 'git commit -a'; Tool = 'Bash'; Operand = 'git commit -a -m m'; Index = 'child-a' }
            @{ Case = 'git commit --all'; Tool = 'Bash'; Operand = 'git commit --all -m m'; Index = 'child-a' }
            @{ Case = 'git commit --amend'; Tool = 'Bash'; Operand = 'git commit --amend -m m'; Index = 'child-a' }
            @{ Case = 'git add -A'; Tool = 'Bash'; Operand = 'git add -A'; Index = 'child-a' }
            @{ Case = 'git commit --no-verify with a child-a pathspec'; Tool = 'Bash'; Operand = 'git commit --no-verify -m m -- docs/features/active/2026-09-25-child-a-901/x.md'; Index = 'child-a' }
            @{ Case = 'a pathless commit with an empty index'; Tool = 'Bash'; Operand = 'git commit -m m'; Index = 'empty' }
            @{ Case = 'a pathless commit with a mixed index'; Tool = 'Bash'; Operand = 'git commit -m m'; Index = 'mixed' }
            @{ Case = 'a chained git add and npm run build'; Tool = 'Bash'; Operand = 'git add docs/features/active/2026-09-25-child-a-901/x.md && npm run build'; Index = 'child-a' }
        ) {
            # Arrange
            $names = switch ($Index) { 'empty' { @() } 'mixed' { @("$script:ChildA/x.md", 'scripts/x.ps1') } default { @("$script:ChildA/x.md") } }
            Set-StagedIndexSeam -Name $names

            # Act
            $decision = Invoke-FollowUpGate -Tool $Tool -Operand $Operand

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because $Case
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeExactly (Get-EpicScopeDenyReason -Failure 'merge-in-progress') -Because 'the epic-scope deny text is unchanged'
            $reason | Should -BeLike "*failed readiness predicate is 'merge-in-progress'*"
        }
    }

    Context 'denies' {
        BeforeEach { Set-FollowUpDefaultSeam }

        It 'denies a <Case> operand under child-a' -ForEach @(
            @{ Case = 'dot-dot'; Operand = 'docs/features/active/2026-09-25-child-a-901/../x.md' }
            @{ Case = 'backslash'; Operand = 'docs/features/active/2026-09-25-child-a-901' + [string][char]92 + 'x.md' }
            @{ Case = 'glob'; Operand = 'docs/features/active/2026-09-25-child-a-901/*.md' }
        ) {
            # Act
            $decision = Invoke-FollowUpGate -Operand "git commit -F /scratch/msg.txt -- $Operand"

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because "a $Case operand is never a modelled follow-up path"
            ([string]$decision.hookSpecificOutput.permissionDecisionReason).StartsWith('PREIMPLEMENTATION_GATE_BLOCKED:') | Should -BeTrue
        }

        It 'denies a child-a commit when the readiness failure is epic_manifest_path' {
            # Arrange
            Set-EpicScopeSeam -CheckpointText (Get-FollowUpFixtureText -Kind 'blank-manifest')

            # Act
            $decision = Invoke-FollowUpGate -Operand $script:FailBeforeCommand

            # Assert: the allowance applies only to the exact merge-in-progress failure.
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly (Get-EpicScopeDenyReason -Failure 'epic_manifest_path')
        }

        It 'denies scripts/x.ps1 with the unchanged text when a hand-authored lifecycle_ready checkpoint is supplied' {
            # Arrange
            $handAuthored = '{"issue-num":"901","feature-folder":"docs/features/active/2026-09-25-child-a-901","route_id":"large","lifecycle_ready":true}'

            # Act
            $decision = Invoke-FollowUpGate -Tool 'Write' -Operand 'scripts/x.ps1' -CheckpointRaw $handAuthored

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly (Get-EpicScopeDenyReason -Failure 'merge-in-progress')
        }
    }

    Context 'outside epic scope' {
        BeforeEach { Set-FollowUpDefaultSeam }

        It 'returns the unchanged single-feature deny for the follow-up commit when HEAD is not the integration_branch' {
            # Arrange
            Set-EpicScopeSeam -CheckpointText (Get-FollowUpFixtureText) -HeadBranch 'feature/standalone-item'

            # Act
            $decision = Invoke-FollowUpGate -Operand $script:FailBeforeCommand

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:SingleFeatureReason
        }
    }
}
