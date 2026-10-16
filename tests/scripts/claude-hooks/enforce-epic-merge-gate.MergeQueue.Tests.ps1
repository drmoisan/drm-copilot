#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Merge-queue scope tests for .claude/hooks/enforce-epic-merge-gate.ps1 (issue #952).
.DESCRIPTION
    Under a merge queue on main, every gh pr merge spelling (any merge method, --auto,
    --admin, or no method flag) enqueues the pull request, and a gh api merge or enqueue
    mutation reaches the base branch the same way. This suite pins that the gate treats
    all of them alike:

      B-1  every gh pr merge spelling is gated (AC-6);
      B-2  non-merge commands, including a pure --disable-auto, stay allowed (AC-6);
      B-3  gh api merge and enqueue mutations are gated, a read query is not (AC-7);
      B-4  the PR selector reader resolves every spelling (AC-8);
      B-5  a matching authorization record allows every gated spelling (AC-8);
      B-6  the deny text names the method-agnostic scope (AC-11);
      B-7  the scope predicate Test-EpicMergeGateCommandInScope.

    Determinism rules for this suite:
      - Every case drives a pure decision seam or a pure string function directly. No
        temporary file, no child process, and no live executable is used.
      - Every decision-level case mocks all three checkpoint read seams, so no case reads
        live orchestration state from disk.
      - The session_id and every record field are fixed literals; no clock is read.
#>

Describe 'enforce-epic-merge-gate.ps1 merge-queue scope (issue #952)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        Mock Get-ChildOrchestratorCheckpointContent { $null }
        Mock Get-EpicOrchestratorCheckpointContent { $null }
        Mock Get-ParallelOrchestratorCheckpointContent { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
        Mock Resolve-EpicMergeGateItemTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #850)' } }

        $script:SessionId = 'session-952-q1'
        $script:Record5 = '{"standalone_merge_authorizations":[{"pr_number":5,"pr_url":"https://github.com/drmoisan/drm-copilot/pull/5","issue_num":952,"branch_name":"bug/ci-merge-queue-for-main-952","authorized_by":"parallel-orchestrator","authorized_at":"2026-10-16T02:00:00Z","session_id":"session-952-q1","basis":"Merge-queue scope regression fixture for issue #952."}]}'
        $script:ClaudeDenyText = 'EPIC_MERGE_GATE_BLOCKED: a pull-request merge or merge-queue enqueue (gh pr merge with any method, --auto, or --admin, or a gh api merge or enqueue mutation) requires either a per-feature checkpoint with epic_mode == true and step9_status == "passed", an epic checkpoint with epic_merge_pr.ci_gate.conclusion == "success" and a matching pr_number, or a parallel-orchestrator checkpoint with route_id == "parallel" whose target item (matched by pr_number) has merge_status == "ci_green". No checkpoint satisfied this gate.'

        function ConvertTo-MergeQueueEnvelope {
            <#
            .SYNOPSIS
                Wrap a Bash command in the PreToolUse envelope the hook reads, with the fixed session id.
            #>
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory)][AllowEmptyString()][string] $Command)

            return ([ordered]@{ tool_name = 'Bash'; tool_input = @{ command = $Command }; session_id = $script:SessionId } | ConvertTo-Json -Depth 5 -Compress)
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'every gh pr merge spelling is gated (AC-6)' {
        # All three checkpoint seams return null, so an in-scope command necessarily denies.
        It 'denies <Command> without an authorization record' -ForEach @(
            @{ Command = 'gh pr merge 5 --merge' }
            @{ Command = 'gh pr merge 5 -m' }
            @{ Command = 'gh pr merge 5 --squash' }
            @{ Command = 'gh pr merge 5 -s' }
            @{ Command = 'gh pr merge 5 --rebase' }
            @{ Command = 'gh pr merge 5 -r' }
            @{ Command = 'gh pr merge 5 --auto' }
            @{ Command = 'gh pr merge 5 --admin' }
            @{ Command = 'gh pr merge 5' }
            @{ Command = 'bash -c "gh pr merge 5 --squash"' }
        ) {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }

            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergeQueueEnvelope -Command $Command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because "$Command enqueues or merges the pull request under a merge queue"
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match '^EPIC_MERGE_GATE_BLOCKED: '
        }
    }

    Context 'non-merge commands stay allowed (AC-6)' {
        It 'allows <Command>' -ForEach @(
            @{ Command = 'gh pr merge 5 --disable-auto' }
            @{ Command = 'git commit -m "gh pr merge 5 --squash"' }
            @{ Command = 'printf ''%s\n'' "gh api graphql enqueuePullRequest" >> notes.md' }
        ) {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }

            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergeQueueEnvelope -Command $Command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "$Command neither merges nor enqueues a pull request"
        }
    }

    Context 'gh api merge and enqueue mutations are gated (AC-7)' {
        It 'decides <Expected> for <Name>' -ForEach @(
            @{ Name = 'an enqueuePullRequest mutation'; Expected = 'deny'; Command = 'gh api graphql -f query=''mutation { enqueuePullRequest(input: {pullRequestId: "PR_kwDO"}) { clientMutationId } }''' }
            @{ Name = 'an enablePullRequestAutoMerge mutation'; Expected = 'deny'; Command = 'gh api graphql -f query=''mutation { enablePullRequestAutoMerge(input: {pullRequestId: "PR_kwDO"}) { clientMutationId } }''' }
            @{ Name = 'a mergePullRequest mutation'; Expected = 'deny'; Command = 'gh api graphql -f query=''mutation { mergePullRequest(input: {pullRequestId: "PR_kwDO"}) { clientMutationId } }''' }
            @{ Name = 'a REST PUT to the pulls merge endpoint'; Expected = 'deny'; Command = 'gh api -X PUT repos/drmoisan/drm-copilot/pulls/5/merge' }
            @{ Name = 'the procedure merge-state read query'; Expected = 'allow'; Command = 'gh api graphql -f query=''query($owner:String!,$name:String!,$number:Int!){repository(owner:$owner,name:$name){pullRequest(number:$number){state mergedAt isInMergeQueue mergeCommit{oid} autoMergeRequest{enabledAt}}}}'' -F owner=''{owner}'' -F name=''{repo}'' -F number=5 --jq .data.repository.pullRequest' }
        ) {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }

            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergeQueueEnvelope -Command $Command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be $Expected -Because "$Name must be decided $Expected"
            if ($Expected -eq 'deny') {
                $decision.hookSpecificOutput.permissionDecisionReason | Should -Match '^EPIC_MERGE_GATE_BLOCKED: '
            }
        }
    }

    Context 'the PR selector reader resolves every spelling (AC-8)' {
        It 'resolves 5 for <Command>' -ForEach @(
            @{ Command = 'gh pr merge --merge --auto 5' }
            @{ Command = 'gh pr merge --subject x 5 --merge' }
            @{ Command = 'gh pr merge -R o/r 5 --squash' }
            @{ Command = 'gh pr merge --body-file f 5 -m' }
            @{ Command = 'gh pr merge https://github.com/o/r/pull/5 --merge' }
            @{ Command = 'gh api -X PUT repos/o/r/pulls/5/merge' }
        ) {
            # Act: the reader is a pure string function and reads nothing from disk.
            $prNumber = Get-EpicMergeGateCommandPrNumber -CommandText $Command

            # Assert: the selector is the pull request 5 in every spelling.
            $prNumber | Should -Be 5 -Because "the selector of $Command is pull request 5"
        }

        It 'returns <Label> for <Command>' -ForEach @(
            @{ Command = 'gh pr merge -- 5'; Expected = 5; Label = '5' }
            @{ Command = 'gh pr merge --merge --'; Expected = $null; Label = 'no number' }
            @{ Command = 'gh pr merge feature-branch --merge'; Expected = $null; Label = 'no number' }
            @{ Command = 'gh pr merge --merge=true 5'; Expected = 5; Label = '5' }
        ) {
            # Act: the reader is a pure string function and reads nothing from disk.
            $prNumber = Get-EpicMergeGateCommandPrNumber -CommandText $Command

            # Assert: a bare '--' passes the next token as the selector, a branch name carries no
            # number, and a non-numeric --merge=<value> does not end the scan (issue #952 CR-2, CR-4).
            $prNumber | Should -Be $Expected -Because "the selector of $Command resolves to $Label"
        }
    }

    Context 'a matching authorization record allows every gated spelling (AC-8)' {
        It 'decides <Expected> for <Command> with a pull request 5 record' -ForEach @(
            @{ Command = 'gh pr merge --merge --auto 5'; Expected = 'allow'; Token = '' }
            @{ Command = 'gh pr merge 5 --squash'; Expected = 'allow'; Token = '' }
            @{ Command = 'gh pr merge https://github.com/drmoisan/drm-copilot/pull/5 --merge'; Expected = 'allow'; Token = '' }
            @{ Command = 'gh pr merge --subject x 5 --merge'; Expected = 'allow'; Token = '' }
            @{ Command = 'gh api -X PUT repos/drmoisan/drm-copilot/pulls/5/merge'; Expected = 'allow'; Token = '' }
            @{ Command = 'gh pr merge 6 --auto'; Expected = 'deny'; Token = 'STANDALONE_MERGE_AUTHORIZATION_PR_MISMATCH' }
        ) {
            $recordRaw = $script:Record5
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $recordRaw }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }

            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergeQueueEnvelope -Command $Command)

            $decision.hookSpecificOutput.permissionDecision | Should -Be $Expected -Because "the record authorizes pull request 5 only"
            if ($Expected -eq 'deny') {
                [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ('EPIC_MERGE_GATE_BLOCKED: ' + $Token + ': *')
            }
        }
    }

    Context 'deny text names the method-agnostic scope (AC-11)' {
        It 'denies a bare gh pr merge --squash with the method-agnostic message' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }

            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergeQueueEnvelope -Command 'gh pr merge --squash')

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:ClaudeDenyText
        }
    }

    Context 'scope predicate (issue #952)' {
        It 'returns <Expected> for <Command>' -ForEach @(
            @{ Command = 'gh pr merge 5 --disable-auto'; Expected = $false }
            @{ Command = 'gh pr merge 5 --squash'; Expected = $true }
            @{ Command = 'gh api graphql -f query=''query { viewer { login } }'''; Expected = $false }
            @{ Command = 'bash -c "gh pr merge 5 --squash"'; Expected = $true }
        ) {
            $inScope = Test-EpicMergeGateCommandInScope -CommandText $Command

            $inScope | Should -Be $Expected -Because "the scope of $Command is $Expected"
        }
    }
}
