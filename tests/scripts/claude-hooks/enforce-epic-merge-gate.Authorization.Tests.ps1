#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Decision-level tests for the standalone-merge authorization branch of
    .claude/hooks/enforce-epic-merge-gate.ps1 (issue #670).
.DESCRIPTION
    Pins the fourth allow condition of the merge gate: a PR-specific authorization record,
    bound to the live session, carried in any one of the three orchestrator checkpoints.

    Determinism rules for this suite:
      - Every case drives the pure decision seam Invoke-EpicMergeGateDecision, or the pure
        string function Get-EpicMergeGateCommandPrNumber, directly.
      - Every decision-level case mocks all three checkpoint read seams, so no case reads
        live orchestration state from disk.
      - Every case writes nothing to disk, starts no process, and reads no clock.
      - authorized_at and session_id values are fixed literals.
#>

Describe 'enforce-epic-merge-gate.ps1 standalone authorization (issue #670)' {
    BeforeAll {
        # Both files are dot-sourced on purpose. The parent hook already dot-sources the
        # helpers file, so the second load is deliberately redundant and idempotent; it
        # guarantees the helper functions come from the helpers file even if the parent's
        # dot-source line changes.
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate-authorization.ps1").Path

        $script:SessionId = 'session-670-a1b2'

        function New-RecordJson {
            <#
            .SYNOPSIS
                Build a checkpoint JSON text carrying one well-formed record for a PR.
            #>
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory)][int] $PrNumber, [string] $Prefix = '')

            $record = '{"pr_number":' + $PrNumber +
            ',"pr_url":"https://github.com/drmoisan/drm-copilot/pull/' + $PrNumber +
            '","issue_num":670,"branch_name":"fix/epic-merge-gate-authorization-record-670"' +
            ',"authorized_by":"parallel-orchestrator","authorized_at":"2026-09-13T21:04:00Z"' +
            ',"session_id":"' + $script:SessionId + '"' +
            ',"basis":"Standalone fix for #670 unblocks the run; all required checks passed."}'
            return '{' + $Prefix + '"standalone_merge_authorizations":[' + $record + ']}'
        }

        $script:Fixtures = @{
            'none'                     = $null
            'record-691'               = (New-RecordJson -PrNumber 691)
            'record-777'               = (New-RecordJson -PrNumber 777)
            'record-501'               = (New-RecordJson -PrNumber 501)
            'blanket-true'             = '{"standalone_merge_authorizations":true}'
            'green-501-and-record-777' = (New-RecordJson -PrNumber 777 -Prefix '"route_id":"parallel","items":[{"pr_number":501,"merge_status":"ci_green"}],')
        }

        function ConvertTo-AuthorizationEnvelope {
            <#
            .SYNOPSIS
                Wrap a Bash command in a PreToolUse envelope, with or without a session_id.
            #>
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory)][string] $Command, [Parameter(Mandatory)][string] $Session)

            $envelope = [ordered]@{ tool_name = 'Bash'; tool_input = @{ command = $Command } }
            if ($Session -ne 'absent') {
                $envelope['session_id'] = $Session
            }
            return ($envelope | ConvertTo-Json -Depth 5 -Compress)
        }

        $script:Line433Text = 'EPIC_MERGE_GATE_BLOCKED: gh pr merge --merge requires either a per-feature checkpoint with epic_mode == true and step9_status == "passed", an epic checkpoint with epic_merge_pr.ci_gate.conclusion == "success" and a matching pr_number, or a parallel-orchestrator checkpoint with route_id == "parallel" whose target item (matched by pr_number) has merge_status == "ci_green". No checkpoint satisfied this gate.'
    }

    Context 'decision matrix' {
        It 'decides <Expected> for <Name>' -ForEach @(
            @{ Name = 'a valid 691 record in the per-feature checkpoint'; Command = 'gh pr merge 691 --merge'; Child = 'record-691'; Epic = 'none'; Parallel = 'none'; Session = 'session-670-a1b2'; Expected = 'allow'; Token = '' }
            @{ Name = 'a valid 691 record in the epic checkpoint'; Command = 'gh pr merge 691 --merge'; Child = 'none'; Epic = 'record-691'; Parallel = 'none'; Session = 'session-670-a1b2'; Expected = 'allow'; Token = '' }
            @{ Name = 'a valid 691 record in the parallel checkpoint'; Command = 'gh pr merge 691 --merge'; Child = 'none'; Epic = 'none'; Parallel = 'record-691'; Session = 'session-670-a1b2'; Expected = 'allow'; Token = '' }
            @{ Name = 'a record naming 777 only'; Command = 'gh pr merge 691 --merge'; Child = 'record-777'; Epic = 'none'; Parallel = 'none'; Session = 'session-670-a1b2'; Expected = 'deny'; Token = 'STANDALONE_MERGE_AUTHORIZATION_PR_MISMATCH' }
            @{ Name = 'no authorization key on any checkpoint'; Command = 'gh pr merge 691 --merge'; Child = 'none'; Epic = 'none'; Parallel = 'none'; Session = 'session-670-a1b2'; Expected = 'deny'; Token = 'STANDALONE_MERGE_AUTHORIZATION_ABSENT' }
            @{ Name = 'a blanket true flag'; Command = 'gh pr merge 691 --merge'; Child = 'blanket-true'; Epic = 'none'; Parallel = 'none'; Session = 'session-670-a1b2'; Expected = 'deny'; Token = 'STANDALONE_MERGE_AUTHORIZATION_NOT_PR_SPECIFIC' }
            @{ Name = 'a session_id that differs from the envelope'; Command = 'gh pr merge 691 --merge'; Child = 'record-691'; Epic = 'none'; Parallel = 'none'; Session = 'session-other-9z'; Expected = 'deny'; Token = 'STANDALONE_MERGE_AUTHORIZATION_MALFORMED' }
            @{ Name = 'an envelope carrying no session_id'; Command = 'gh pr merge 691 --merge'; Child = 'record-691'; Epic = 'none'; Parallel = 'none'; Session = 'absent'; Expected = 'deny'; Token = 'STANDALONE_MERGE_AUTHORIZATION_MALFORMED' }
            @{ Name = 'the discriminator merging unauthorized 777 after a cd into 501'; Command = 'cd /repo/worktrees/501 && gh pr merge --merge 777'; Child = 'none'; Epic = 'record-501'; Parallel = 'none'; Session = 'session-670-a1b2'; Expected = 'deny'; Token = 'STANDALONE_MERGE_AUTHORIZATION_PR_MISMATCH' }
            @{ Name = 'the paired positive merging authorized 501 after a cd into 501'; Command = 'cd /repo/worktrees/501 && gh pr merge --merge 501'; Child = 'none'; Epic = 'record-501'; Parallel = 'none'; Session = 'session-670-a1b2'; Expected = 'allow'; Token = '' }
            @{ Name = 'a squash merge of 691 with a valid 691 record'; Command = 'gh pr merge 691 --squash'; Child = 'record-691'; Epic = 'none'; Parallel = 'none'; Session = 'session-670-a1b2'; Expected = 'allow'; Token = '' }
        ) {
            $childRaw = $script:Fixtures[$Child]
            $epicRaw = $script:Fixtures[$Epic]
            $parallelRaw = $script:Fixtures[$Parallel]
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $childRaw }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $epicRaw }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $parallelRaw }

            $envelope = ConvertTo-AuthorizationEnvelope -Command $Command -Session $Session
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope

            $decision.hookSpecificOutput.permissionDecision | Should -Be $Expected
            if ($Expected -eq 'deny') {
                $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
                $reason | Should -BeLike ('EPIC_MERGE_GATE_BLOCKED: ' + $Token + ': *')
                if ($Token -eq 'STANDALONE_MERGE_AUTHORIZATION_MALFORMED') {
                    $reason | Should -Match "'session_id'"
                }
            }
            else {
                $decision.hookSpecificOutput.Keys | Should -Not -Contain 'permissionDecisionReason'
            }
        }
    }

    Context 'reason text and branch order' {
        It 'denies an explicit PR with no record using both the gate token and the absent code' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }

            $envelope = ConvertTo-AuthorizationEnvelope -Command 'gh pr merge 691 --merge' -Session $script:SessionId
            $reason = [string](Invoke-EpicMergeGateDecision -ToolInputRaw $envelope).hookSpecificOutput.permissionDecisionReason

            $reason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
            $reason | Should -Match 'STANDALONE_MERGE_AUTHORIZATION_ABSENT'
            $reason | Should -Match 'orchestrator-state\.md' -Because 'the absent message must state how to take the authorized path'
        }

        It 'keeps the existing fall-through text for a bare merge even with a valid record present' {
            $recordRaw = $script:Fixtures['record-691']
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $recordRaw }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }

            $envelope = ConvertTo-AuthorizationEnvelope -Command 'gh pr merge --merge' -Session $script:SessionId
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:Line433Text
        }

        It 'allows parallel item 501 through branch 3 before the standalone branch is consulted' {
            $parallelRaw = $script:Fixtures['green-501-and-record-777']
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $parallelRaw }
            Mock -CommandName Test-StandaloneCheckpointAllowsMerge -MockWith { throw 'branch 4 must not run' }

            $envelope = ConvertTo-AuthorizationEnvelope -Command 'gh pr merge 501 --merge' -Session $script:SessionId
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            ($decision | ConvertTo-Json -Depth 5 -Compress) | Should -Not -Match 'STANDALONE_MERGE_AUTHORIZATION'
            Should -Invoke -CommandName Test-StandaloneCheckpointAllowsMerge -Times 0 -Exactly
        }
    }

    Context 'the pr_number matcher is unchanged' {
        It 'extracts the same numbers for the six existing spellings' {
            Get-EpicMergeGateCommandPrNumber -CommandText 'gh pr merge 410 --merge' | Should -Be 410
            Get-EpicMergeGateCommandPrNumber -CommandText 'gh pr merge --merge 410' | Should -Be 410
            Get-EpicMergeGateCommandPrNumber -CommandText 'gh pr merge --merge=410' | Should -Be 410
            Get-EpicMergeGateCommandPrNumber -CommandText 'cd C:\Users\DanMoisan\repos\TaskMaster-wt\2026-08-29T00-11 && gh pr merge --merge 688' | Should -Be 688
            Get-EpicMergeGateCommandPrNumber -CommandText 'cd /repo/worktrees/501 && gh pr merge --merge 777' | Should -Be 777
            Get-EpicMergeGateCommandPrNumber -CommandText 'gh pr merge --merge' | Should -BeNullOrEmpty
        }
    }
}
