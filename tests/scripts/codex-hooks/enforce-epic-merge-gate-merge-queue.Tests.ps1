#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Merge-queue scope tests for the Codex epic merge gate (issue #952).
.DESCRIPTION
    The Codex-side sibling of
    tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1. Under a merge
    queue on main, every gh pr merge spelling (any merge method, --auto, --admin, or no
    method flag) enqueues the pull request, and a gh api merge or enqueue mutation reaches
    the base branch the same way. This suite pins that the Codex gate treats all of them
    alike:

      C-1  every gh pr merge spelling is gated (AC-6, AC-9);
      C-2  non-merge commands, including a pure --disable-auto, stay allowed;
      C-3  gh api merge and enqueue mutations are gated, a read query is not (AC-7);
      C-4  the PR selector reader resolves every spelling (AC-8);
      C-5  a matching authorization record allows every gated spelling (AC-8);
      C-6  the deny text names the method-agnostic scope (AC-11);
      C-7  the shared scope predicate Test-EpicMergeGateCommandInScope.

    Codex decision-entry idiom: Invoke-CodexEpicMergeDecision takes the full Codex stdin
    payload plus the child and epic checkpoint texts as parameters, and returns $null for
    allow rather than an allow decision object.

    Determinism: every case drives the pure decision seam or a pure string function with
    literal fixtures, and both checkpoints arrive as parameters rather than from disk. No
    disk I/O, no child process, no temporary file, and no clock read.

    Coverage attribution note (issue #952 R1). The reader row for
    https://github.com/o/r/pull/5 executes Codex helper lines 67-68, and the REST rows
    (gh api -X PUT .../pulls/5/merge, as reader and as decision) execute lines 182-186,
    in-process. Full-run CI coverage can still report those lines as uncovered through the
    issue #936 mechanism (line breakpoints bound to an earlier compiled instance of the
    helper code); enforce-epic-merge-gate-command.Tests.ps1 in this folder names the
    assertion for each line.
#>

Describe 'Codex enforce-epic-merge-gate merge-queue scope (issue #952)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.codex/hooks/enforce-epic-merge-gate.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        if (Get-Command Get-ChildOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ChildOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-EpicOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-EpicOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-ParallelOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ParallelOrchestratorCheckpointContent { $null } }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }

        $script:Record5 = '{"standalone_merge_authorizations":[{"pr_number":5,"pr_url":"https://github.com/drmoisan/drm-copilot/pull/5","issue_num":952,"branch_name":"bug/ci-merge-queue-for-main-952","authorized_by":"parallel-orchestrator","authorized_at":"2026-10-16T02:00:00Z","session_id":"session-952-q1","basis":"Merge-queue scope regression fixture for issue #952."}]}'
        $script:CodexDenyText = 'EPIC_MERGE_GATE_BLOCKED: a pull-request merge or merge-queue enqueue (gh pr merge with any method, --auto, or --admin, or a gh api merge or enqueue mutation) requires a safe epic child checkpoint or a successful final epic CI gate with a matching PR number.'

        function ConvertTo-CodexMergeTriggerScopingPayload {
            <#
                Builds the full Codex stdin payload the decision seam consumes, with the fixed
                session id. The command text is carried verbatim so a fixture can exercise
                quoting exactly as the shell would present it.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

            return (@{
                    tool_name  = 'Bash'
                    tool_input = @{ command = $Command }
                    session_id = 'session-952-q1'
                } | ConvertTo-Json -Compress -Depth 4)
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'resolves the selector helper functions from the Codex helper file' {
        # The Codex gate dot-sources the selector helper from its own directory, so each
        # function must be defined by the Codex helper file (issue #952 R1 provenance check).
        foreach ($name in @('Get-EpicMergeGateSelectorPrNumber', 'ConvertFrom-EpicMergeGateSelector', 'Test-EpicMergeGateCommandInScope')) {
            $definitionFile = [string](Get-Command -Name $name -CommandType Function).ScriptBlock.File
            ($definitionFile -replace '\\', '/') | Should -BeLike '*/.codex/hooks/enforce-epic-merge-gate-command.ps1' -Because "$name must be defined by the Codex helper copy"
        }
    }

    Context 'every gh pr merge spelling is gated (AC-6)' {
        # Both checkpoints are empty, so an in-scope command necessarily denies.
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
            $payload = ConvertTo-CodexMergeTriggerScopingPayload -Command $Command

            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw ''

            $decision | Should -Not -BeNullOrEmpty -Because "$Command enqueues or merges the pull request under a merge queue"
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match '^EPIC_MERGE_GATE_BLOCKED: '
        }
    }

    Context 'non-merge commands stay allowed (AC-6)' {
        It 'allows <Command>' -ForEach @(
            @{ Command = 'gh pr merge 5 --disable-auto' }
            @{ Command = 'git commit -m "gh pr merge 5 --squash"' }
            @{ Command = 'printf ''%s\n'' "gh api graphql enqueuePullRequest" >> notes.md' }
        ) {
            $payload = ConvertTo-CodexMergeTriggerScopingPayload -Command $Command

            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw ''

            $decision | Should -BeNullOrEmpty -Because "$Command neither merges nor enqueues a pull request"
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
            $payload = ConvertTo-CodexMergeTriggerScopingPayload -Command $Command

            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw ''

            if ($Expected -eq 'deny') {
                $decision | Should -Not -BeNullOrEmpty -Because "$Name must be denied"
                $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
                $decision.hookSpecificOutput.permissionDecisionReason | Should -Match '^EPIC_MERGE_GATE_BLOCKED: '
            }
            else {
                $decision | Should -BeNullOrEmpty -Because "$Name must be allowed"
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
            $prNumber = Get-CodexMergeCommandPrNumber -Command $Command

            # Assert: the selector is the pull request 5 in every spelling.
            $prNumber | Should -Be 5 -Because "the selector of $Command is pull request 5"
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
            $payload = ConvertTo-CodexMergeTriggerScopingPayload -Command $Command

            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw $script:Record5 -EpicCheckpointRaw ''

            if ($Expected -eq 'deny') {
                $decision | Should -Not -BeNullOrEmpty -Because 'the record authorizes pull request 5 only'
                $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
                [string]$decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike ('EPIC_MERGE_GATE_BLOCKED: ' + $Token + ': *')
            }
            else {
                $decision | Should -BeNullOrEmpty -Because 'the record authorizes pull request 5'
            }
        }
    }

    Context 'deny text names the method-agnostic scope (AC-11)' {
        It 'denies a bare gh pr merge --squash with the method-agnostic message' {
            $payload = ConvertTo-CodexMergeTriggerScopingPayload -Command 'gh pr merge --squash'

            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw '' -EpicCheckpointRaw ''

            $decision | Should -Not -BeNullOrEmpty
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:CodexDenyText
        }
    }

    Context 'scope predicate loaded through the Codex hook (issue #952)' {
        It 'returns <Expected> for <Command>' -ForEach @(
            @{ Command = 'gh pr merge 5 --disable-auto'; Expected = $false }
            @{ Command = 'bash -c "gh pr merge 5 --squash"'; Expected = $true }
        ) {
            $inScope = Test-EpicMergeGateCommandInScope -CommandText $Command

            $inScope | Should -Be $Expected -Because "the scope of $Command is $Expected"
        }
    }
}
