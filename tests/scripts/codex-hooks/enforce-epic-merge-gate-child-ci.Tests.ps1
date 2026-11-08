#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Epic-child CI verification rows for the Codex epic merge gate (issue #1130).
.DESCRIPTION
    When Test-CodexChildMergeReady holds, Invoke-CodexEpicMergeDecision allows the merge only when
    Get-EpicMergeGateChildCiDecision (the Codex copy of enforce-epic-merge-gate-child-ci.ps1) verifies a
    green CI run on the live head. Checkpoint text arrives through the decision seam's parameters, an
    allow is asserted as $null, and the child-CI seams are mocked by name. Every deny row also supplies
    an epic checkpoint that would allow the same PR, so a fall-through to a later branch would show as
    an allow. The direct rows drive the pure helpers and both seams with Invoke-DocsOnlyGhExe mocked.
    No row writes to disk, starts a process, or reads a clock; roots are synthetic forward-slash paths.
#>

BeforeDiscovery {
    $head = 'abcdef0123456789abcdef0123456789abcdef01'
    $otherHead = '2222222222222222222222222222222222222222'
    $older = [DateTime]::new(2026, 11, 8, 10, 0, 0, [DateTimeKind]::Utc)
    $newer = [DateTime]::new(2026, 11, 8, 11, 0, 0, [DateTimeKind]::Utc)
    $green = '"ci_gate":{"conclusion":"success","head_sha":"' + $head + '"}'
    $child = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},'
    $pullRun = [pscustomobject]@{ databaseId = 901; event = 'pull_request'; status = 'completed'; conclusion = 'success'; headSha = $head; workflowName = 'CI'; createdAt = $older }

    $script:StageDenyRows = @(
        @{ Name = 'RGC-CHILD-CI-STAGE1-PR-MISMATCH'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":43},' + $green + '}'; LiveHead = $head; Runs = @($pullRun); Detail = 'stage 1 \(PR number\): the command names pull request 42 but pr_gate.pr_number records 43' }
        @{ Name = 'RGC-CHILD-CI-STAGE1-BARE-NO-PR-GATE'; Command = 'gh pr merge --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed",' + $green + '}'; LiveHead = $head; Runs = @($pullRun); Detail = 'stage 1 \(PR number\): the command names no pull request' }
        @{ Name = 'RGC-CHILD-CI-STAGE1-NON-INTEGER-PR-GATE'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"verified","pr_gate":{"pr_number":"42"},' + $green + '}'; LiveHead = $head; Runs = @($pullRun); Detail = 'stage 1 \(PR number\): pr_gate.pr_number is not a positive JSON integer' }
        @{ Name = 'RGC-CHILD-CI-STAGE2-NO-CI-GATE'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42}}'; LiveHead = $head; Runs = @($pullRun); Detail = 'stage 2 \(ci_gate\): the checkpoint records no ci_gate' }
        @{ Name = 'RGC-CHILD-CI-STAGE2-CONCLUSION-FAILURE'; Command = 'gh pr merge 42 --merge'; Checkpoint = $child + '"ci_gate":{"conclusion":"failure","head_sha":"' + $head + '"}}'; LiveHead = $head; Runs = @($pullRun); Detail = 'stage 2 \(ci_gate\): the checkpoint records no ci_gate' }
        @{ Name = 'RGC-CHILD-CI-STAGE2-UPPERCASE-HEAD'; Command = 'gh pr merge 42 --merge'; Checkpoint = $child + '"ci_gate":{"conclusion":"success","head_sha":"' + $head.ToUpperInvariant() + '"}}'; LiveHead = $head; Runs = @($pullRun); Detail = 'stage 2 \(ci_gate\): ci_gate.head_sha is not a lowercase' }
        @{ Name = 'RGC-CHILD-CI-STAGE2-SHORT-HEAD'; Command = 'gh pr merge 42 --merge'; Checkpoint = $child + '"ci_gate":{"conclusion":"success","head_sha":"abcdef0"}}'; LiveHead = $head; Runs = @($pullRun); Detail = 'stage 2 \(ci_gate\): ci_gate.head_sha is not a lowercase' }
        @{ Name = 'RGC-CHILD-CI-STAGE3-LIVE-HEAD-UNRESOLVED'; Command = 'gh pr merge 42 --merge'; Checkpoint = $child + $green + '}'; LiveHead = $null; Runs = @($pullRun); Detail = 'stage 3 \(live head\): the live head of pull request 42 could not be resolved' }
        @{ Name = 'RGC-CHILD-CI-STAGE3-LIVE-HEAD-DIFFERENT'; Command = 'gh pr merge 42 --merge'; Checkpoint = $child + $green + '}'; LiveHead = $otherHead; Runs = @($pullRun); Detail = 'stage 3 \(live head\): the live head 2{40} differs' }
        @{ Name = 'RGC-CHILD-CI-STAGE4-RUN-LIST-UNAVAILABLE'; Command = 'gh pr merge 42 --merge'; Checkpoint = $child + $green + '}'; LiveHead = $head; Runs = $null; Detail = 'stage 4 \(run list\): the workflow runs for [0-9a-f]{40} could not be listed' }
        @{ Name = 'RGC-CHILD-CI-STAGE4-NO-CI-RUN-ON-HEAD'; Command = 'gh pr merge 42 --merge'; Checkpoint = $child + $green + '}'; LiveHead = $head; Runs = @([pscustomobject]@{ databaseId = 902; event = 'pull_request'; status = 'completed'; conclusion = 'success'; headSha = $head; workflowName = 'Build'; createdAt = $newer }, [pscustomobject]@{ databaseId = 903; event = 'pull_request'; status = 'completed'; conclusion = 'success'; headSha = $otherHead; workflowName = 'CI'; createdAt = $newer }); Detail = 'stage 4 \(run list\): no run of the workflow named CI exists' }
        @{ Name = 'RGC-CHILD-CI-STAGE5-PUSH-EVENT'; Command = 'gh pr merge 42 --merge'; Checkpoint = $child + $green + '}'; LiveHead = $head; Runs = @([pscustomobject]@{ databaseId = 904; event = 'push'; status = 'completed'; conclusion = 'success'; headSha = $head; workflowName = 'CI'; createdAt = $newer }); Detail = "stage 5 \(run result\): the newest CI run on [0-9a-f]{40} has event 'push'" }
        @{ Name = 'RGC-CHILD-CI-STAGE5-NEWEST-FAILED'; Command = 'gh pr merge 42 --merge'; Checkpoint = $child + $green + '}'; LiveHead = $head; Runs = @($pullRun, [pscustomobject]@{ databaseId = 905; event = 'pull_request'; status = 'completed'; conclusion = 'failure'; headSha = $head; workflowName = 'CI'; createdAt = $newer }); Detail = "stage 5 \(run result\): .* conclusion 'failure'" }
        @{ Name = 'RGC-CHILD-CI-STAGE5-NEWEST-IN-PROGRESS'; Command = 'gh pr merge 42 --merge'; Checkpoint = $child + $green + '}'; LiveHead = $head; Runs = @($pullRun, [pscustomobject]@{ databaseId = 906; event = 'pull_request'; status = 'in_progress'; conclusion = ''; headSha = $head; workflowName = 'CI'; createdAt = $newer }); Detail = "stage 5 \(run result\): .* status 'in_progress'" }
        @{ Name = 'RGC-CHILD-CI-STAGE6-UNRECORDED-DISPATCH'; Command = 'gh pr merge 42 --merge'; Checkpoint = $child + $green + '}'; LiveHead = $head; Runs = @([pscustomobject]@{ databaseId = 907; event = 'workflow_dispatch'; status = 'completed'; conclusion = 'success'; headSha = $head; workflowName = 'CI'; createdAt = $newer }); Detail = 'stage 6 \(dispatch run\): the workflow_dispatch run 907 is not the run recorded' }
    )
    $script:AllowRows = @(
        @{ Name = 'RGC-CHILD-CI-ALLOW-PULL-REQUEST-RUN'; Command = 'gh pr merge 42 --merge'; Checkpoint = $child + $green + '}'; Runs = @($pullRun) }
        @{ Name = 'RGC-CHILD-CI-ALLOW-RECORDED-DISPATCH-RUN'; Command = 'gh pr merge 42 --squash'; Checkpoint = $child + '"ci_gate":{"conclusion":"success","head_sha":"' + $head + '","dispatch_run_id":908}}'; Runs = @([pscustomobject]@{ databaseId = 908; event = 'workflow_dispatch'; status = 'completed'; conclusion = 'success'; headSha = $head; workflowName = 'CI'; createdAt = $newer }) }
        @{ Name = 'RGC-CHILD-CI-ALLOW-BARE-COMMAND-RECORDED-PR'; Command = 'gh pr merge --merge'; Checkpoint = $child + $green + '}'; Runs = @($pullRun) }
    )
}

Describe 'Codex enforce-epic-merge-gate epic-child CI verification (issue #1130)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        if (Get-Command Get-ChildOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ChildOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-EpicOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-EpicOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-ParallelOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ParallelOrchestratorCheckpointContent { $null } }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }

        $script:Head = 'abcdef0123456789abcdef0123456789abcdef01'
        $script:RepositoryRoot = Join-Path '/synthetic-worktrees' 'codex-1130'
        # An epic checkpoint that would allow PR 42, so any fall-through past the child branch allows.
        $script:EpicReady = '{"epic_merge_pr":{"pr_number":42,"ci_gate":{"conclusion":"success"}}}'

        function Invoke-CodexChildCiDecision {
            <#
            .SYNOPSIS
                Run the Codex decision for one command and child checkpoint text.
            #>
            [CmdletBinding()]
            param([Parameter(Mandatory)][string] $Command, [Parameter(Mandatory)][string] $Checkpoint, [AllowEmptyString()][string] $Epic = '')

            $payload = @{ session_id = 'session-1130'; tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress
            return Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw $Checkpoint -EpicCheckpointRaw $Epic -RepositoryRoot $script:RepositoryRoot
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'gate rows: one deny per verification stage' {
        It '<Name> denies with its stage detail and does not fall through' -ForEach $script:StageDenyRows {
            # Arrange
            $liveHeadValue = $LiveHead
            $runsValue = $Runs
            Mock Get-EpicMergeGateChildCiLiveHeadSha -MockWith ({ $liveHeadValue }.GetNewClosure())
            Mock Get-EpicMergeGateChildCiRunList -MockWith ({ if ($null -eq $runsValue) { return $null }; , @($runsValue) }.GetNewClosure())

            # Act
            $decision = Invoke-CodexChildCiDecision -Command $Command -Checkpoint $Checkpoint -Epic $script:EpicReady

            # Assert
            $decision | Should -Not -BeNullOrEmpty -Because 'a stage failure denies even when the epic checkpoint would allow'
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason.StartsWith('EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
            $reason | Should -Match $Detail
        }

        It 'RGC-CHILD-CI-GH-FAILURE denies when every gh call fails and runs gh in the repository root' {
            # Arrange: the real seams read the default failing gh wrapper mock.
            $checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},"ci_gate":{"conclusion":"success","head_sha":"abcdef0123456789abcdef0123456789abcdef01"}}'

            # Act
            $decision = Invoke-CodexChildCiDecision -Command 'gh pr merge 42 --merge' -Checkpoint $checkpoint -Epic $script:EpicReady

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'stage 3 \(live head\)'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -Scope It -ParameterFilter { $WorkingRoot -eq $script:RepositoryRoot -and $GhArgs[0] -eq 'pr' }
        }
    }

    Context 'gate rows: verified runs allow' {
        It '<Name> allows' -ForEach $script:AllowRows {
            # Arrange
            $runsValue = $Runs
            Mock Get-EpicMergeGateChildCiLiveHeadSha { 'abcdef0123456789abcdef0123456789abcdef01' }
            Mock Get-EpicMergeGateChildCiRunList -MockWith ({ , @($runsValue) }.GetNewClosure())

            # Act
            $decision = Invoke-CodexChildCiDecision -Command $Command -Checkpoint $Checkpoint

            # Assert
            $decision | Should -BeNullOrEmpty
            Should -Invoke Get-EpicMergeGateChildCiLiveHeadSha -Times 1 -Exactly -Scope It -ParameterFilter { $PrNumber -eq 42 -and $WorktreeRoot -eq $script:RepositoryRoot }
            Should -Invoke Get-EpicMergeGateChildCiRunList -Times 1 -Exactly -Scope It
        }
    }

    Context 'pure helpers of the Codex copy' {
        It 'Test-EpicMergeGateChildCiObjectId returns <Expected> for <Label>' -ForEach @(
            @{ Label = 'a 40-character lowercase id'; Value = ('b' * 40); Expected = $true }
            @{ Label = 'a 64-character lowercase id'; Value = ('9' * 64); Expected = $true }
            @{ Label = 'an uppercase id'; Value = ('B' * 40); Expected = $false }
            @{ Label = 'a short id'; Value = 'abc'; Expected = $false }
            @{ Label = 'null'; Value = $null; Expected = $false }
        ) {
            Test-EpicMergeGateChildCiObjectId -Value $Value | Should -Be $Expected
        }

        It 'Get-EpicMergeGateChildCiPrNumber resolves <Label>' -ForEach @(
            @{ Label = 'the command number alone'; Json = '{}'; Command = 7; PrNumber = 7 }
            @{ Label = 'the recorded number alone'; Json = '{"pr_gate":{"pr_number":7}}'; Command = $null; PrNumber = 7 }
            @{ Label = 'a mismatch as no number'; Json = '{"pr_gate":{"pr_number":8}}'; Command = 7; PrNumber = $null }
            @{ Label = 'neither number as no number'; Json = '{}'; Command = $null; PrNumber = $null }
        ) {
            (Get-EpicMergeGateChildCiPrNumber -Checkpoint ($Json | ConvertFrom-Json) -CommandPrNumber $Command).PrNumber | Should -Be $PrNumber
        }

        It 'Select-EpicMergeGateChildCiRun picks the newest CI run on the head' {
            # Arrange
            $runs = @(
                [pscustomobject]@{ databaseId = 1; workflowName = 'CI'; headSha = $script:Head; createdAt = '2026-11-08T12:00:00Z' }
                [pscustomobject]@{ databaseId = 2; workflowName = 'CI'; headSha = $script:Head; createdAt = '2026-11-08T09:00:00Z' }
                [pscustomobject]@{ databaseId = 3; workflowName = 'CI'; headSha = ('3' * 40); createdAt = '2026-11-08T13:00:00Z' }
            )

            # Act / Assert
            (Select-EpicMergeGateChildCiRun -Runs $runs -HeadSha $script:Head).databaseId | Should -Be 1
        }
    }

    Context 'seams of the Codex copy with Invoke-DocsOnlyGhExe mocked' {
        It 'Get-EpicMergeGateChildCiLiveHeadSha returns <Label>' -ForEach @(
            @{ Label = 'the head on success'; ExitCode = 0; Output = '{"headRefOid":"abcdef0123456789abcdef0123456789abcdef01"}'; Expected = 'abcdef0123456789abcdef0123456789abcdef01' }
            @{ Label = 'null on a non-zero exit'; ExitCode = 2; Output = ''; Expected = $null }
            @{ Label = 'null on malformed output'; ExitCode = 0; Output = '{oops'; Expected = $null }
        ) {
            # Arrange
            $result = [pscustomobject]@{ ExitCode = $ExitCode; Output = $Output }
            Mock Invoke-DocsOnlyGhExe -MockWith ({ $result }.GetNewClosure())

            # Act / Assert
            Get-EpicMergeGateChildCiLiveHeadSha -PrNumber 42 -WorktreeRoot $script:RepositoryRoot | Should -Be $Expected
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -Scope It
        }

        It 'Get-EpicMergeGateChildCiRunList returns <Label>' -ForEach @(
            @{ Label = 'two runs on success'; ExitCode = 0; Output = '[{"databaseId":1},{"databaseId":2}]'; Count = 2 }
            @{ Label = 'null on a non-zero exit'; ExitCode = 1; Output = '[]'; Count = -1 }
            @{ Label = 'null on malformed output'; ExitCode = 0; Output = 'nope'; Count = -1 }
            @{ Label = 'null on a non-array document'; ExitCode = 0; Output = '{"databaseId":1}'; Count = -1 }
        ) {
            # Arrange
            $result = [pscustomobject]@{ ExitCode = $ExitCode; Output = $Output }
            Mock Invoke-DocsOnlyGhExe -MockWith ({ $result }.GetNewClosure())

            # Act
            $runs = Get-EpicMergeGateChildCiRunList -HeadSha $script:Head -WorktreeRoot $script:RepositoryRoot

            # Assert
            if ($Count -lt 0) { $runs | Should -BeNullOrEmpty } else { @($runs).Count | Should -Be $Count }
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -Scope It -ParameterFilter { $GhArgs[0] -eq 'run' -and $GhArgs[1] -eq 'list' -and $GhArgs[3] -eq $script:Head }
        }
    }
}
