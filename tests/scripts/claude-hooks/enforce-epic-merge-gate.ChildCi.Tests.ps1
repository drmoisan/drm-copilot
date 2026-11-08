#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Epic-child CI verification rows for the Claude merge gate's branch 1 (issue #1130).

.DESCRIPTION
    Branch 1 of Invoke-EpicMergeGateDecision allows an epic-child merge only when the existing child
    predicates hold and Get-EpicMergeGateChildCiDecision verifies a green CI run on the live head of
    the child pull request. The gate rows drive Invoke-EpicMergeGateDecision with mocked
    checkpoint-content, resolution, and child-CI seams; the direct rows drive the helper's pure
    functions and both seams with Invoke-DocsOnlyGhExe mocked. No row starts a process, runs git or
    gh, or writes a file.
#>

BeforeDiscovery {
    $head = 'abcdef0123456789abcdef0123456789abcdef01'
    $otherHead = '1111111111111111111111111111111111111111'
    $older = [DateTime]::new(2026, 11, 8, 10, 0, 0, [DateTimeKind]::Utc)
    $newer = [DateTime]::new(2026, 11, 8, 11, 0, 0, [DateTimeKind]::Utc)
    $green = '"ci_gate":{"conclusion":"success","head_sha":"' + $head + '"}'
    $pullRun = [pscustomobject]@{ databaseId = 901; event = 'pull_request'; status = 'completed'; conclusion = 'success'; headSha = $head; workflowName = 'CI'; createdAt = $older }

    # One gate deny row per verification stage; Runs is $null when the run-list seam fails.
    $script:StageDenyRows = @(
        @{ Name = 'CHILD-CI-STAGE1-BARE-NO-PR-GATE'; Command = 'gh pr merge --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed",' + $green + '}'; LiveHead = $head; Runs = @($pullRun); Detail = 'stage 1 \(PR number\): the command names no pull request' }
        @{ Name = 'CHILD-CI-STAGE1-NON-INTEGER-PR-GATE'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":"42"},' + $green + '}'; LiveHead = $head; Runs = @($pullRun); Detail = 'stage 1 \(PR number\): pr_gate.pr_number is not a positive JSON integer' }
        @{ Name = 'CHILD-CI-STAGE2-CONCLUSION-FAILURE'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},"ci_gate":{"conclusion":"failure","head_sha":"' + $head + '"}}'; LiveHead = $head; Runs = @($pullRun); Detail = 'stage 2 \(ci_gate\): the checkpoint records no ci_gate with conclusion' }
        @{ Name = 'CHILD-CI-STAGE2-UPPERCASE-HEAD'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},"ci_gate":{"conclusion":"success","head_sha":"' + $head.ToUpperInvariant() + '"}}'; LiveHead = $head; Runs = @($pullRun); Detail = 'stage 2 \(ci_gate\): ci_gate.head_sha is not a lowercase' }
        @{ Name = 'CHILD-CI-STAGE2-SHORT-HEAD'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},"ci_gate":{"conclusion":"success","head_sha":"abcdef0"}}'; LiveHead = $head; Runs = @($pullRun); Detail = 'stage 2 \(ci_gate\): ci_gate.head_sha is not a lowercase' }
        @{ Name = 'CHILD-CI-STAGE3-LIVE-HEAD-UNRESOLVED'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},' + $green + '}'; LiveHead = $null; Runs = @($pullRun); Detail = 'stage 3 \(live head\): the live head of pull request 42 could not be resolved' }
        @{ Name = 'CHILD-CI-STAGE3-LIVE-HEAD-DIFFERENT'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},' + $green + '}'; LiveHead = $otherHead; Runs = @($pullRun); Detail = 'stage 3 \(live head\): the live head 1{40} differs' }
        @{ Name = 'CHILD-CI-STAGE4-RUN-LIST-UNAVAILABLE'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},' + $green + '}'; LiveHead = $head; Runs = $null; Detail = 'stage 4 \(run list\): the workflow runs for [0-9a-f]{40} could not be listed' }
        @{ Name = 'CHILD-CI-STAGE4-NO-CI-RUN-ON-HEAD'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},' + $green + '}'; LiveHead = $head; Runs = @([pscustomobject]@{ databaseId = 902; event = 'pull_request'; status = 'completed'; conclusion = 'success'; headSha = $head; workflowName = 'Build'; createdAt = $newer }, [pscustomobject]@{ databaseId = 903; event = 'pull_request'; status = 'completed'; conclusion = 'success'; headSha = $otherHead; workflowName = 'CI'; createdAt = $newer }); Detail = 'stage 4 \(run list\): no run of the workflow named CI exists' }
        @{ Name = 'CHILD-CI-STAGE5-PUSH-EVENT'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},' + $green + '}'; LiveHead = $head; Runs = @([pscustomobject]@{ databaseId = 904; event = 'push'; status = 'completed'; conclusion = 'success'; headSha = $head; workflowName = 'CI'; createdAt = $newer }); Detail = "stage 5 \(run result\): the newest CI run on [0-9a-f]{40} has event 'push'" }
        @{ Name = 'CHILD-CI-STAGE5-NEWEST-FAILED'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},' + $green + '}'; LiveHead = $head; Runs = @($pullRun, [pscustomobject]@{ databaseId = 905; event = 'pull_request'; status = 'completed'; conclusion = 'failure'; headSha = $head; workflowName = 'CI'; createdAt = $newer }); Detail = "stage 5 \(run result\): .* status 'completed' and conclusion 'failure'" }
        @{ Name = 'CHILD-CI-STAGE5-NEWEST-IN-PROGRESS'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},' + $green + '}'; LiveHead = $head; Runs = @($pullRun, [pscustomobject]@{ databaseId = 906; event = 'pull_request'; status = 'in_progress'; conclusion = ''; headSha = $head; workflowName = 'CI'; createdAt = $newer }); Detail = "stage 5 \(run result\): .* status 'in_progress'" }
        @{ Name = 'CHILD-CI-STAGE6-UNRECORDED-DISPATCH'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},' + $green + '}'; LiveHead = $head; Runs = @([pscustomobject]@{ databaseId = 907; event = 'workflow_dispatch'; status = 'completed'; conclusion = 'success'; headSha = $head; workflowName = 'CI'; createdAt = $newer }); Detail = 'stage 6 \(dispatch run\): the workflow_dispatch run 907 is not the run recorded' }
        @{ Name = 'CHILD-CI-STAGE6-DIFFERENT-DISPATCH-ID'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},"ci_gate":{"conclusion":"success","head_sha":"' + $head + '","dispatch_run_id":999}}'; LiveHead = $head; Runs = @([pscustomobject]@{ databaseId = 907; event = 'workflow_dispatch'; status = 'completed'; conclusion = 'success'; headSha = $head; workflowName = 'CI'; createdAt = $newer }); Detail = 'stage 6 \(dispatch run\): the workflow_dispatch run 907 is not the run recorded' }
    )
    $script:AllowRows = @(
        @{ Name = 'CHILD-CI-ALLOW-PULL-REQUEST-RUN'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},' + $green + '}'; Runs = @($pullRun) }
        @{ Name = 'CHILD-CI-ALLOW-RECORDED-DISPATCH-RUN'; Command = 'gh pr merge 42 --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},"ci_gate":{"conclusion":"success","head_sha":"' + $head + '","dispatch_run_id":908}}'; Runs = @([pscustomobject]@{ databaseId = 908; event = 'workflow_dispatch'; status = 'completed'; conclusion = 'success'; headSha = $head; workflowName = 'CI'; createdAt = $newer }, $pullRun) }
        @{ Name = 'CHILD-CI-ALLOW-BARE-COMMAND-RECORDED-PR'; Command = 'gh pr merge --merge'; Checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},' + $green + '}'; Runs = @($pullRun) }
    )
}

Describe 'enforce-epic-merge-gate epic-child CI verification (issue #1130)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
        . $script:UnderTest
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

        $script:Head = 'abcdef0123456789abcdef0123456789abcdef01'
        $itemRootValue = Join-Path '/synthetic-worktrees' 'item-1130'
        $sessionRootValue = Join-Path '/synthetic-worktrees' 'session-1130'
        Mock Get-EpicMergeGateSessionWorktreeRoot -MockWith ({ $sessionRootValue }.GetNewClosure())
        Mock Resolve-EpicMergeGateItemTarget -MockWith ({ [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $itemRootValue; ReasonCode = $null; Detail = 'item SessionRoot (issue #1130)' } }.GetNewClosure())
        Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'run NoTarget (issue #1130)' } }
        Mock Get-EpicMergeGateLivePrHeadSha { 'abcdef0123456789abcdef0123456789abcdef01' }

        function Invoke-ChildCiDecision {
            <#
            .SYNOPSIS
                Run the gate decision for one command with session id session-1130.
            #>
            param([Parameter(Mandatory)][string] $Command)

            $envelope = @{ session_id = 'session-1130'; tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress
            return Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
        }
    }

    Context 'regression: epic child with no CI record' {
        It 'CHILD-CI-NO-CI-GATE denies gh pr merge 42 --merge for an epic child with step9_status passed and no ci_gate' {
            # Arrange: the checkpoint satisfies every pre-#1130 branch-1 predicate but records no CI run.
            Mock Get-ChildOrchestratorCheckpointContent { '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42}}' }

            # Act
            $decision = Invoke-ChildCiDecision -Command 'gh pr merge 42 --merge'

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because "an epic child needs a verified CI run (observed decision: $($decision.hookSpecificOutput.permissionDecision); reason: $reason)"
            $reason | Should -Match 'EPIC_CHILD_CI_NOT_VERIFIED'
        }
    }

    Context 'gate rows: one deny per verification stage' {
        It '<Name> denies with its stage detail and reaches no later branch' -ForEach $script:StageDenyRows {
            # Arrange
            $checkpointText = $Checkpoint
            $liveHeadValue = $LiveHead
            $runsValue = $Runs
            Mock Get-ChildOrchestratorCheckpointContent -MockWith ({ $checkpointText }.GetNewClosure())
            Mock Get-EpicMergeGateChildCiLiveHeadSha -MockWith ({ $liveHeadValue }.GetNewClosure())
            Mock Get-EpicMergeGateChildCiRunList -MockWith ({ if ($null -eq $runsValue) { return $null }; , @($runsValue) }.GetNewClosure())

            # Act
            $decision = Invoke-ChildCiDecision -Command $Command

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because "reason: $reason"
            $reason.StartsWith('EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $reason
            $reason | Should -Match $Detail
            Should -Invoke Get-EpicOrchestratorCheckpointContent -Times 0 -Exactly -Scope It
            Should -Invoke Get-ParallelOrchestratorCheckpointContent -Times 0 -Exactly -Scope It
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly -Scope It
        }

        It 'CHILD-CI-STAGE4-NON-ARRAY-RUN-LIST denies when gh run list prints a JSON object' {
            # Arrange: the real run-list seam reads a non-array document from the gh wrapper.
            Mock Get-ChildOrchestratorCheckpointContent { '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":42},"ci_gate":{"conclusion":"success","head_sha":"abcdef0123456789abcdef0123456789abcdef01"}}' }
            Mock Get-EpicMergeGateChildCiLiveHeadSha { 'abcdef0123456789abcdef0123456789abcdef01' }
            Mock Invoke-DocsOnlyGhExe -ParameterFilter { $GhArgs[0] -eq 'run' } { [pscustomobject]@{ ExitCode = 0; Output = '{"databaseId":1}' } }

            # Act
            $decision = Invoke-ChildCiDecision -Command 'gh pr merge 42 --merge'

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because "reason: $reason"
            $reason | Should -Match 'stage 4 \(run list\): the workflow runs for [0-9a-f]{40} could not be listed'
            Should -Invoke Get-EpicOrchestratorCheckpointContent -Times 0 -Exactly -Scope It
        }
    }

    Context 'gate rows: verified runs allow' {
        It '<Name> allows without the green-CI live-head lookup' -ForEach $script:AllowRows {
            # Arrange
            $checkpointText = $Checkpoint
            $runsValue = $Runs
            Mock Get-ChildOrchestratorCheckpointContent -MockWith ({ $checkpointText }.GetNewClosure())
            Mock Get-EpicMergeGateChildCiLiveHeadSha { 'abcdef0123456789abcdef0123456789abcdef01' }
            Mock Get-EpicMergeGateChildCiRunList -MockWith ({ , @($runsValue) }.GetNewClosure())

            # Act
            $decision = Invoke-ChildCiDecision -Command $Command

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $reason"
            Should -Invoke Get-EpicMergeGateChildCiLiveHeadSha -Times 1 -Exactly -Scope It -ParameterFilter { $PrNumber -eq 42 }
            Should -Invoke Get-EpicMergeGateChildCiRunList -Times 1 -Exactly -Scope It -ParameterFilter { $HeadSha -eq 'abcdef0123456789abcdef0123456789abcdef01' }
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly -Scope It
        }
    }

    Context 'Get-EpicMergeGateChildCiDecision direct rows' {
        It 'CHILD-CI-STAGE1-PR-MISMATCH denies when the command number differs from pr_gate.pr_number' {
            # Arrange: through the gate Test-ChildCheckpointPrGateBinding rejects this first, so the helper is driven directly.
            $checkpoint = '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":43},"ci_gate":{"conclusion":"success","head_sha":"abcdef0123456789abcdef0123456789abcdef01"}}' | ConvertFrom-Json
            Mock Get-EpicMergeGateChildCiLiveHeadSha { 'abcdef0123456789abcdef0123456789abcdef01' }

            # Act
            $result = Get-EpicMergeGateChildCiDecision -Checkpoint $checkpoint -CommandPrNumber 42 -GhRoot '/synthetic-worktrees/session-1130'

            # Assert
            $result.Verified | Should -BeFalse
            $result.Reason | Should -Match 'stage 1 \(PR number\): the command names pull request 42 but pr_gate.pr_number records 43'
            Should -Invoke Get-EpicMergeGateChildCiLiveHeadSha -Times 0 -Exactly -Scope It
        }

        It 'denies a null checkpoint at stage 1' {
            # Act
            $result = Get-EpicMergeGateChildCiDecision -Checkpoint $null -CommandPrNumber $null -GhRoot ''

            # Assert
            $result.Verified | Should -BeFalse
            $result.Reason | Should -Match 'stage 1'
        }

        It 'denies with the error message when a seam throws, so the helper never throws' {
            # Arrange
            $checkpoint = '{"pr_gate":{"pr_number":42},"ci_gate":{"conclusion":"success","head_sha":"abcdef0123456789abcdef0123456789abcdef01"}}' | ConvertFrom-Json
            Mock Get-EpicMergeGateChildCiLiveHeadSha { throw 'simulated seam failure' }

            # Act
            $result = Get-EpicMergeGateChildCiDecision -Checkpoint $checkpoint -CommandPrNumber 42 -GhRoot ''

            # Assert
            $result.Verified | Should -BeFalse
            $result.Reason | Should -BeExactly 'EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: verification failed with an error: simulated seam failure'
        }

        It 'returns Verified with an empty Reason for a green pull_request run' {
            # Arrange
            $checkpoint = '{"pr_gate":{"pr_number":42},"ci_gate":{"conclusion":"success","head_sha":"abcdef0123456789abcdef0123456789abcdef01"}}' | ConvertFrom-Json
            Mock Get-EpicMergeGateChildCiLiveHeadSha { 'abcdef0123456789abcdef0123456789abcdef01' }
            Mock Get-EpicMergeGateChildCiRunList { , @([pscustomobject]@{ databaseId = 1; event = 'pull_request'; status = 'completed'; conclusion = 'success'; headSha = 'abcdef0123456789abcdef0123456789abcdef01'; workflowName = 'CI'; createdAt = '2026-11-08T10:00:00Z' }) }

            # Act
            $result = Get-EpicMergeGateChildCiDecision -Checkpoint $checkpoint -CommandPrNumber $null -GhRoot ''

            # Assert
            $result.Verified | Should -BeTrue
            $result.Reason | Should -BeExactly ''
        }
    }

    Context 'pure helpers' {
        It 'Test-EpicMergeGateChildCiObjectId returns <Expected> for <Label>' -ForEach @(
            @{ Label = 'a 40-character lowercase id'; Value = ('a' * 40); Expected = $true }
            @{ Label = 'a 64-character lowercase id'; Value = ('0' * 64); Expected = $true }
            @{ Label = 'an uppercase id'; Value = ('A' * 40); Expected = $false }
            @{ Label = 'a short id'; Value = 'abcdef0'; Expected = $false }
            @{ Label = 'a 41-character id'; Value = ('a' * 41); Expected = $false }
            @{ Label = 'a non-string value'; Value = 42; Expected = $false }
            @{ Label = 'null'; Value = $null; Expected = $false }
        ) {
            # Act / Assert
            Test-EpicMergeGateChildCiObjectId -Value $Value | Should -Be $Expected
        }

        It 'Get-EpicMergeGateChildCiPrNumber resolves <Label>' -ForEach @(
            @{ Label = 'the command number alone'; Json = '{}'; Command = 42; PrNumber = 42; Detail = $null }
            @{ Label = 'the recorded number alone'; Json = '{"pr_gate":{"pr_number":42}}'; Command = $null; PrNumber = 42; Detail = $null }
            @{ Label = 'matching numbers'; Json = '{"pr_gate":{"pr_number":42}}'; Command = 42; PrNumber = 42; Detail = $null }
            @{ Label = 'a mismatch'; Json = '{"pr_gate":{"pr_number":43}}'; Command = 42; PrNumber = $null; Detail = 'records 43' }
            @{ Label = 'neither number'; Json = '{"pr_gate":{}}'; Command = $null; PrNumber = $null; Detail = 'names no pull request' }
            @{ Label = 'a string number'; Json = '{"pr_gate":{"pr_number":"42"}}'; Command = $null; PrNumber = $null; Detail = 'not a positive JSON integer' }
            @{ Label = 'a zero number'; Json = '{"pr_gate":{"pr_number":0}}'; Command = 42; PrNumber = $null; Detail = 'not a positive JSON integer' }
        ) {
            # Act
            $result = Get-EpicMergeGateChildCiPrNumber -Checkpoint ($Json | ConvertFrom-Json) -CommandPrNumber $Command

            # Assert
            $result.PrNumber | Should -Be $PrNumber
            if ($null -eq $Detail) { $result.Detail | Should -BeNullOrEmpty } else { $result.Detail | Should -Match $Detail }
        }

        It 'Get-EpicMergeGateChildCiProperty returns null for a non-object value' {
            Get-EpicMergeGateChildCiProperty -InputObject 'text' -Name 'pr_gate' | Should -BeNullOrEmpty
        }

        It 'Select-EpicMergeGateChildCiRun picks the newest CI run on the head by createdAt, then databaseId' {
            # Arrange
            $runs = @(
                [pscustomobject]@{ databaseId = 1; workflowName = 'CI'; headSha = $script:Head; createdAt = '2026-11-08T09:00:00Z' }
                [pscustomobject]@{ databaseId = 3; workflowName = 'CI'; headSha = $script:Head; createdAt = [DateTime]::new(2026, 11, 8, 11, 0, 0, [DateTimeKind]::Utc) }
                [pscustomobject]@{ databaseId = 4; workflowName = 'CI'; headSha = $script:Head; createdAt = '2026-11-08T11:00:00Z' }
                [pscustomobject]@{ databaseId = 9; workflowName = 'ci'; headSha = $script:Head; createdAt = '2026-11-08T12:00:00Z' }
                'not an object'
            )

            # Act
            $selected = Select-EpicMergeGateChildCiRun -Runs $runs -HeadSha $script:Head

            # Assert
            $selected.databaseId | Should -Be 4
        }

        It 'Select-EpicMergeGateChildCiRun returns null when a matching run has an unreadable createdAt' {
            # Arrange
            $runs = @(
                [pscustomobject]@{ databaseId = 1; workflowName = 'CI'; headSha = $script:Head; createdAt = '2026-11-08T09:00:00Z' }
                [pscustomobject]@{ databaseId = 2; workflowName = 'CI'; headSha = $script:Head; createdAt = 'not a date' }
            )

            # Act / Assert
            Select-EpicMergeGateChildCiRun -Runs $runs -HeadSha $script:Head | Should -BeNullOrEmpty
        }

        It 'Select-EpicMergeGateChildCiRun returns null for an empty list' {
            Select-EpicMergeGateChildCiRun -Runs @() -HeadSha $script:Head | Should -BeNullOrEmpty
        }
    }

    Context 'seams with Invoke-DocsOnlyGhExe mocked' {
        It 'Get-EpicMergeGateChildCiLiveHeadSha returns <Label>' -ForEach @(
            @{ Label = 'the head on success'; ExitCode = 0; Output = '{"headRefOid":"abcdef0123456789abcdef0123456789abcdef01"}'; Expected = 'abcdef0123456789abcdef0123456789abcdef01' }
            @{ Label = 'null on a non-zero exit'; ExitCode = 1; Output = '{"headRefOid":"abcdef0123456789abcdef0123456789abcdef01"}'; Expected = $null }
            @{ Label = 'null on malformed output'; ExitCode = 0; Output = 'not json'; Expected = $null }
            @{ Label = 'null on a malformed head'; ExitCode = 0; Output = '{"headRefOid":"ABC"}'; Expected = $null }
        ) {
            # Arrange
            $result = [pscustomobject]@{ ExitCode = $ExitCode; Output = $Output }
            Mock Invoke-DocsOnlyGhExe -MockWith ({ $result }.GetNewClosure())

            # Act
            $head = Get-EpicMergeGateChildCiLiveHeadSha -PrNumber 42 -WorktreeRoot '/synthetic-worktrees/session-1130'

            # Assert
            $head | Should -Be $Expected
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -Scope It -ParameterFilter { ($GhArgs -join ' ') -eq 'pr view 42 --json headRefOid' -and $WorkingRoot -eq '/synthetic-worktrees/session-1130' }
        }

        It 'Get-EpicMergeGateChildCiRunList returns the parsed array on success with one bounded call' {
            # Arrange
            Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 0; Output = '[{"databaseId":7,"workflowName":"CI"},{"databaseId":8,"workflowName":"CI"}]' } }

            # Act
            $runs = Get-EpicMergeGateChildCiRunList -HeadSha $script:Head -WorktreeRoot '/synthetic-worktrees/session-1130'

            # Assert
            @($runs).Count | Should -Be 2
            $runs[1].databaseId | Should -Be 8
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -Scope It -ParameterFilter { ($GhArgs -join ' ') -eq 'run list --commit abcdef0123456789abcdef0123456789abcdef01 --limit 100 --json databaseId,event,status,conclusion,headSha,workflowName,createdAt' }
        }

        It 'Get-EpicMergeGateChildCiRunList returns an empty array for an empty list' {
            # Arrange
            Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 0; Output = '[]' } }

            # Act
            $runs = Get-EpicMergeGateChildCiRunList -HeadSha $script:Head -WorktreeRoot ''

            # Assert
            $null -eq $runs | Should -BeFalse
            @($runs).Count | Should -Be 0
        }

        It 'Get-EpicMergeGateChildCiRunList returns null on <Label>' -ForEach @(
            @{ Label = 'a non-zero exit'; ExitCode = 1; Output = '[]' }
            @{ Label = 'malformed output'; ExitCode = 0; Output = '[not json' }
            @{ Label = 'a non-array document'; ExitCode = 0; Output = '{"databaseId":1}' }
        ) {
            # Arrange
            $result = [pscustomobject]@{ ExitCode = $ExitCode; Output = $Output }
            Mock Invoke-DocsOnlyGhExe -MockWith ({ $result }.GetNewClosure())

            # Act / Assert
            Get-EpicMergeGateChildCiRunList -HeadSha $script:Head -WorktreeRoot '' | Should -BeNullOrEmpty
        }
    }

    Context 'helper twins' {
        It 'keeps the Claude and Codex helper copies byte-identical' {
            # Arrange
            $claudeCopy = Join-Path $PSScriptRoot '../../../.claude/hooks/enforce-epic-merge-gate-child-ci.ps1'
            $codexCopy = Join-Path $PSScriptRoot '../../../.codex/hooks/enforce-epic-merge-gate-child-ci.ps1'

            # Act / Assert
            (Get-FileHash -LiteralPath $codexCopy -Algorithm SHA256).Hash | Should -Be (Get-FileHash -LiteralPath $claudeCopy -Algorithm SHA256).Hash
        }
    }
}
