#Requires -Version 7.0

<#
.SYNOPSIS
    Resolution and source-read tests for owner-directive-pass-down-target.ps1 (issue #1157).

.DESCRIPTION
    The sibling is dot-sourced after the modules it calls. Every file read, the worktree listing,
    the transcript reader, and the parent resolvers are injected script blocks over in-memory
    content keyed by /synthetic-worktrees/ paths, so no test touches the file system, git, or
    a clock.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    $hooks = Join-Path $script:RepoRoot '.claude/hooks'
    . (Join-Path $hooks 'hook-dependency-guard.ps1')
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeRunResolution.psm1') -Force -ErrorAction Stop
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1') -Force -ErrorAction Stop
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1') -Force -ErrorAction Stop
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.psm1') -Force -ErrorAction Stop
    . (Join-Path $hooks 'subagentstop-target-worktree.ps1')
    . (Join-Path $hooks 'owner-directive-pass-down-target.ps1')

    $script:Session = '/synthetic-worktrees/main'
    $script:Item = '/synthetic-worktrees/item-1157'
    $porcelain = @(
        'worktree /synthetic-worktrees/main', 'HEAD 1111111', 'branch refs/heads/main', ''
        'worktree /synthetic-worktrees/item-1157', 'HEAD 2222222', 'branch refs/heads/feature/owner-directive-pass-down-1157', ''
        'worktree /synthetic-worktrees/detached', 'HEAD 3333333', 'detached', ''
    ) -join "`n"
    $script:List = { param($SessionRoot) $porcelain }.GetNewClosure()

    function New-TargetTestReader {
        param([hashtable] $Files)
        $map = @{}
        foreach ($key in $Files.Keys) { $map[$key.Replace('\', '/')] = $Files[$key] }
        return { param($Path) $map[([string] $Path).Replace('\', '/')] }.GetNewClosure()
    }

    function Get-TargetTestPath {
        param([string] $Root, [string] $Relative)
        return ((Join-Path $Root $Relative).Replace('\', '/'))
    }

    $script:ItemCheckpointPath = Get-TargetTestPath -Root $script:Item -Relative 'artifacts/orchestration/orchestrator-state.json'
}

Describe 'Get-OwnerDirectiveSubagentTranscriptPath' {
    It 'uses transcript_path directly when its file name is agent-<agent_id>.jsonl' {
        Get-OwnerDirectiveSubagentTranscriptPath -TranscriptPath '/synthetic-home/session/subagents/agent-a1.jsonl' -AgentId 'a1' | Should -BeExactly '/synthetic-home/session/subagents/agent-a1.jsonl'
    }

    It 'derives the subagents layout from a root session transcript' {
        Get-OwnerDirectiveSubagentTranscriptPath -TranscriptPath '/synthetic-home/session.jsonl' -AgentId 'a1' | Should -BeExactly '/synthetic-home/session/subagents/agent-a1.jsonl'
    }

    It 'returns $null for <Case>' -ForEach @(
        @{ Case = 'no transcript path'; Path = ''; AgentId = 'a1' }
        @{ Case = 'no agent id'; Path = '/synthetic-home/session.jsonl'; AgentId = '' }
        @{ Case = 'a path that is not a transcript'; Path = '/synthetic-home/session.txt'; AgentId = 'a1' }
    ) {
        Get-OwnerDirectiveSubagentTranscriptPath -TranscriptPath $Path -AgentId $AgentId | Should -BeNullOrEmpty
    }
}

Describe 'Resolve-OwnerDirectiveItemRoot (AC-23)' {
    It 'resolves the cwd worktree when it holds the item checkpoint' {
        $reader = New-TargetTestReader -Files @{ $script:ItemCheckpointPath = '{"issue-num":"1157"}' }
        $result = Resolve-OwnerDirectiveItemRoot -Cwd "$script:Item/src" -SessionRoot $script:Session -ReadText $reader -WorktreeListInvoker $script:List
        $result.Root | Should -BeExactly $script:Item
        $result.Source | Should -BeExactly 'Cwd'
    }

    It 'falls back to the delegation prompt of the subagent transcript when the cwd worktree holds no checkpoint' {
        $reader = New-TargetTestReader -Files @{}
        $prompt = 'Task. branch: feature/owner-directive-pass-down-1157'
        $head = { param($Path) if ($Path -eq '/synthetic-home/session/subagents/agent-a1.jsonl') { @(([ordered]@{ type = 'user'; message = @{ content = $prompt } } | ConvertTo-Json -Compress -Depth 4)) } }.GetNewClosure()
        $result = Resolve-OwnerDirectiveItemRoot -Cwd "$script:Session" -TranscriptPath '/synthetic-home/session.jsonl' -AgentId 'a1' -SessionRoot $script:Session -ReadText $reader -ReadTranscriptHead $head -WorktreeListInvoker $script:List
        $result.Root | Should -BeExactly $script:Item
        $result.Source | Should -BeExactly 'Transcript'
    }

    It 'places an issue-only prompt through the worktree checkpoints' {
        $reader = New-TargetTestReader -Files @{ $script:ItemCheckpointPath = '{"issue-num":"1157"}' }
        $prompt = 'Canonical issue number for this feature is 1157.'
        $head = { param($Path) @(([ordered]@{ type = 'user'; message = @{ content = $prompt } } | ConvertTo-Json -Compress -Depth 4)) }.GetNewClosure()
        $result = Resolve-OwnerDirectiveItemRoot -TranscriptPath '/synthetic-home/session/subagents/agent-a1.jsonl' -AgentId 'a1' -SessionRoot $script:Session -ReadText $reader -ReadTranscriptHead $head -WorktreeListInvoker $script:List
        $result.Root | Should -BeExactly $script:Item
    }

    It 'returns $null when <Case>' -ForEach @(
        @{ Case = 'no cwd and no transcript'; Transcript = ''; Head = $null }
        @{ Case = 'the transcript is absent'; Transcript = '/synthetic-home/session.jsonl'; Head = { param($Path) $null } }
        @{ Case = 'the transcript reader throws'; Transcript = '/synthetic-home/session.jsonl'; Head = { param($Path) throw 'unreadable' } }
        @{ Case = 'the prompt carries no identity'; Transcript = '/synthetic-home/session.jsonl'; Head = { param($Path) @('{"type":"user","message":{"content":"no identity here"}}') } }
        @{ Case = 'the prompt names an unregistered branch'; Transcript = '/synthetic-home/session.jsonl'; Head = { param($Path) @('{"type":"user","message":{"content":"branch: feature/unknown"}}') } }
    ) {
        $arguments = @{ TranscriptPath = $Transcript; AgentId = 'a1'; SessionRoot = $script:Session; ReadText = (New-TargetTestReader -Files @{}); WorktreeListInvoker = $script:List }
        if ($null -ne $Head) { $arguments['ReadTranscriptHead'] = $Head }
        Resolve-OwnerDirectiveItemRoot @arguments | Should -BeNullOrEmpty
    }
}

Describe 'Resolve-OwnerDirectiveParentRoot (AC-24 resolution part)' {
    It 'resolves an epic parent through epic_context.integration_branch' {
        $checkpoint = '{"epic_context":{"integration_branch":"epic/pass-down-integration"}}' | ConvertFrom-Json
        $epic = { param($IntegrationBranch, $SessionRoot) [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = "/synthetic-worktrees/epic-$($IntegrationBranch.Length)" } }
        $result = Resolve-OwnerDirectiveParentRoot -Checkpoint $checkpoint -SessionRoot $script:Session -EpicResolver $epic -ParallelResolver { throw 'not called' }
        $result.Kind | Should -BeExactly 'epic'
        $result.Root | Should -BeExactly '/synthetic-worktrees/epic-26'
        $result.IntegrationBranch | Should -BeExactly 'epic/pass-down-integration'
    }

    It 'resolves a parallel parent through parallel_slug' {
        $checkpoint = '{"parallel_slug":"harness-learnings"}' | ConvertFrom-Json
        $parallel = { param($ParallelSlug, $SessionRoot) [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/main' } }
        $result = Resolve-OwnerDirectiveParentRoot -Checkpoint $checkpoint -SessionRoot $script:Session -EpicResolver { throw 'not called' } -ParallelResolver $parallel
        $result.Kind | Should -BeExactly 'parallel'
        $result.ParallelSlug | Should -BeExactly 'harness-learnings'
    }

    It 'returns $null for <Case>' -ForEach @(
        @{ Case = 'an unlinked checkpoint'; Json = '{"issue-num":"1157"}'; Resolver = { param($a, $b) throw 'not called' } }
        @{ Case = 'an unresolved parent'; Json = '{"parallel_slug":"x"}'; Resolver = { param($a, $b) [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null } } }
        @{ Case = 'a throwing resolver'; Json = '{"parallel_slug":"x"}'; Resolver = { param($a, $b) throw 'listing failed' } }
    ) {
        Resolve-OwnerDirectiveParentRoot -Checkpoint ($Json | ConvertFrom-Json) -SessionRoot $script:Session -ParallelResolver $Resolver | Should -BeNullOrEmpty
    }
}

Describe 'Get-OwnerDirectiveItemBranch (AC-1 item-branch input)' {
    It 'returns the short branch of the item record' {
        Get-OwnerDirectiveItemBranch -ItemRoot $script:Item -SessionRoot $script:Session -WorktreeListInvoker $script:List | Should -BeExactly 'feature/owner-directive-pass-down-1157'
    }

    It 'returns $null for <Case>' -ForEach @(
        @{ Case = 'a detached record'; Root = '/synthetic-worktrees/detached'; List = $null }
        @{ Case = 'a root no record names'; Root = '/synthetic-worktrees/elsewhere'; List = $null }
        @{ Case = 'a throwing listing'; Root = '/synthetic-worktrees/item-1157'; List = { param($SessionRoot) throw 'git failed' } }
    ) {
        $list = if ($null -eq $List) { $script:List } else { $List }
        Get-OwnerDirectiveItemBranch -ItemRoot $Root -SessionRoot $script:Session -WorktreeListInvoker $list | Should -BeNullOrEmpty
    }
}

Describe 'Get-OwnerDirectiveSourceSet and Get-OwnerDirectiveItemContext' {
    It 'reads the item checkpoint block, the item ledger, and both parent sources of an epic parent' {
        $epicRoot = '/synthetic-worktrees/epic'
        $reader = New-TargetTestReader -Files @{
            (Get-TargetTestPath -Root $script:Item -Relative 'artifacts/orchestration/owner-directives.jsonl')       = '{"id":"OD-2"}'
            (Get-TargetTestPath -Root $epicRoot -Relative 'artifacts/orchestration/epic-orchestrator-state.json')    = '{"epic_issue_num":900,"owner_directives":[{"id":"OD-3"}]}'
            (Get-TargetTestPath -Root $epicRoot -Relative 'artifacts/orchestration/owner-directives.jsonl')          = '{"id":"OD-4"}'
        }
        $parent = [pscustomobject]@{ Kind = 'epic'; Root = $epicRoot; IntegrationBranch = 'epic/x'; ParallelSlug = '' }
        $sources = Get-OwnerDirectiveSourceSet -ItemRoot $script:Item -ItemCheckpointText '{"owner_directives":[{"id":"OD-1"}]}' -Parent $parent -ReadText $reader
        @($sources | ForEach-Object Name) | Should -Be @('item-checkpoint', 'item-ledger', 'parent-checkpoint', 'parent-ledger')
        $sources[0].Text | Should -BeExactly '[{"id":"OD-1"}]'
        $sources[1].Text | Should -BeExactly '{"id":"OD-2"}'
        $sources[2].Text | Should -BeExactly '[{"id":"OD-3"}]'
        $sources[2].IsEpicParent | Should -BeTrue
        $sources[3].Text | Should -BeExactly '{"id":"OD-4"}'
        Get-OwnerDirectiveParentIssue -Parent $parent -ReadText $reader | Should -Be 900
    }

    It 'leaves an absent ledger as $null text and reads no parent source without a parent' {
        $sources = Get-OwnerDirectiveSourceSet -ItemRoot $script:Item -ItemCheckpointText '{}' -Parent $null -ReadText (New-TargetTestReader -Files @{})
        $sources.Count | Should -Be 2
        $sources[1].Text | Should -BeNullOrEmpty
        Get-OwnerDirectiveParentIssue -Parent $null | Should -BeNullOrEmpty
    }

    It 'builds the item context from the checkpoint issue, step, and branch' {
        $reader = New-TargetTestReader -Files @{ $script:ItemCheckpointPath = '{"issue-num":"1157","next_step":"S5_atomic_execution"}' }
        $context = Get-OwnerDirectiveItemContext -ItemRoot $script:Item -SessionRoot $script:Session -ReadText $reader -WorktreeListInvoker $script:List
        $context.Issue | Should -Be 1157
        $context.Step | Should -BeExactly 'S5_atomic_execution'
        $context.Branch | Should -BeExactly 'feature/owner-directive-pass-down-1157'
        $context.Parent | Should -BeNullOrEmpty
    }

    It 'uses the fallback issue when the checkpoint records none, and returns $null without either' {
        $reader = New-TargetTestReader -Files @{}
        (Get-OwnerDirectiveItemContext -ItemRoot $script:Item -SessionRoot $script:Session -FallbackIssue '1157' -ReadText $reader -WorktreeListInvoker $script:List).Issue | Should -Be 1157
        Get-OwnerDirectiveItemContext -ItemRoot $script:Item -SessionRoot $script:Session -ReadText $reader -WorktreeListInvoker $script:List | Should -BeNullOrEmpty
    }

    It 'lists the decision ids whose files exist for the agent' {
        $selected = @([pscustomobject]@{ Id = 'OD-1' }, [pscustomobject]@{ Id = 'OD-2' })
        $test = { param($Path) ([string] $Path).Replace('\', '/').EndsWith('/a1/OD-2.md') }
        Get-OwnerDirectiveExistingDecisionId -ItemRoot $script:Item -AgentId 'a1' -Selected $selected -TestFile $test | Should -Be @('OD-2')
    }

    It 'the default seams read nothing for an absent path and return a UTC clock' {
        Read-OwnerDirectiveFileText -Path '/synthetic-worktrees/absent/file.json' | Should -BeNullOrEmpty
        Test-OwnerDirectiveFileExist -Path '/synthetic-worktrees/absent/file.json' | Should -BeFalse
        (Get-OwnerDirectiveClock).Kind | Should -Be ([System.DateTimeKind]::Utc)
    }
}
