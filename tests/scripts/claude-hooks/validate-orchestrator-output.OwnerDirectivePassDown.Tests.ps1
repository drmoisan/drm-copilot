#Requires -Version 7.0

<#
.SYNOPSIS
    Relay-check tests for validate-orchestrator-output-owner-pass-down.ps1 (issue #1157).

.DESCRIPTION
    The sibling is dot-sourced after the modules it calls, and its seams are mocked: the file read
    returns in-memory text keyed by /synthetic-worktrees/ paths, the clock returns a fixed value,
    and the parent resolver, child resolver, and item-branch reader return fixed results. Call
    counts of the parent seam and the clock prove the key gate. No test touches the file system,
    git, or the wall clock.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/HookTargetWorktree.psm1') -Force -ErrorAction Stop
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeItemResolution.psm1') -Force -ErrorAction Stop
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeRunResolution.psm1') -Force -ErrorAction Stop
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1') -Force -ErrorAction Stop
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectiveSelection.psm1') -Force -ErrorAction Stop
    . (Join-Path $script:RepoRoot '.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1')
    Mock Read-OrchestratorOutputOwnerPassDownText { $null }

    $script:Item = '/synthetic-worktrees/item-1157'
    $script:Epic = '/synthetic-worktrees/epic'
    $script:Parallel = '/synthetic-worktrees/parallel'

    function Get-PassDownStopEntry {
        param([string] $Id = 'OD-1', [long] $Issue = 1157, [string] $Branch = 'feature/owner-directive-pass-down-1157', [string] $Expires = '2026-11-11T00:00:00Z', [string] $Text = 'Run the features in parallel where the merge cost is lower.')
        $digest = [System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData([System.Text.UTF8Encoding]::new($false).GetBytes($Text))).ToLowerInvariant()
        return ([ordered]@{
                id = $Id; text = $Text; text_sha256 = $digest; class = 'scheduling'; recorded_at = '2026-11-01T00:00:00Z'; expires_at = $Expires
                scope = [ordered]@{ issue = $Issue; branch = $Branch; step = 'any' }; issued_by_session = 'coordinator-session-1157'
            } | ConvertTo-Json -Compress -Depth 4)
    }

    function Get-PassDownStopParent {
        param([ValidateSet('epic', 'parallel')] [string] $Kind, [string] $Status = 'pr_open', [string[]] $Directive = @())
        $child = '{"issue_num":1157,"branch_name":"feature/owner-directive-pass-down-1157","merge_status":"' + $Status + '"}'
        $text = if ($Kind -eq 'epic') { '{"route_id":"epic","integration_branch":"epic/pass-down-integration","epic_issue_num":900,"features":[' + $child + ']' }
        else { '{"route_id":"parallel","parallel_slug":"harness","items":[' + $child + ']' }
        if ($Directive.Count -gt 0) { $text += ',"owner_directives":[' + ($Directive -join ',') + ']' }
        return $text + '}'
    }

    function Get-PassDownStopItem {
        param([string[]] $Directive = @(), [ValidateSet('', 'epic', 'parallel')] [string] $Link = '')
        $text = '{"issue-num":"1157","next_step":"S5","route_id":"large"'
        if ($Link -eq 'epic') { $text += ',"epic_context":{"integration_branch":"epic/pass-down-integration"}' }
        if ($Link -eq 'parallel') { $text += ',"parallel_slug":"harness"' }
        if ($Directive.Count -gt 0) { $text += ',"owner_directives":[' + ($Directive -join ',') + ']' }
        return $text + '}'
    }

    # Register the seam mocks over a file map; returns nothing. The parent result defaults to the epic worktree.
    function Register-PassDownStopSeam {
        param([hashtable] $Files, [object] $Parent, [object] $Child)
        $script:Map = @{}
        foreach ($key in $Files.Keys) { $script:Map[$key] = $Files[$key] }
        $script:ParentResult = $Parent
        $script:ChildResult = if ($null -ne $Child) { $Child } else { [pscustomobject]@{ Status = 'Resolved'; WorktreeRoot = '/synthetic-worktrees/item-1157' } }
        Mock Read-OrchestratorOutputOwnerPassDownText { $script:Map[([string] $Path).Replace('\', '/')] }
        Mock Get-OrchestratorOutputOwnerPassDownClock { [datetime]::new(2026, 11, 10, 12, 0, 0, [System.DateTimeKind]::Utc) }
        Mock Resolve-OrchestratorOutputOwnerPassDownChild { $script:ChildResult }
        Mock Get-OrchestratorOutputOwnerPassDownItemBranch { 'feature/owner-directive-pass-down-1157' }
        Mock Resolve-OrchestratorOutputOwnerPassDownParent {
            if ($script:ParentResult -is [scriptblock]) { return (& $script:ParentResult) }
            return $script:ParentResult
        }
    }

    function Invoke-PassDownStop {
        param([string] $ArtifactType, [string] $Root, [string] $CheckpointText)
        return (Get-OrchestratorOutputOwnerPassDownDecision -ArtifactType $ArtifactType -CheckpointText $CheckpointText -WorktreeRoot $Root -SessionRoot '/synthetic-worktrees/main')
    }

    $script:EpicParent = [pscustomobject]@{ Kind = 'epic'; Status = 'OtherWorktree'; WorktreeRoot = '/synthetic-worktrees/epic'; IntegrationBranch = 'epic/pass-down-integration'; ParallelSlug = $null }
    $script:ItemCheckpointPath = "$script:Item/artifacts/orchestration/orchestrator-state.json"
}

Describe 'epic parent running-child check (AC-30)' {
    It 'reports a child with merge_status <Status> that lacks the entry and does not link back' -ForEach @(
        @{ Status = 'worktree_created' }, @{ Status = 'pr_open' }, @{ Status = 'ci_green' }, @{ Status = 'merge_conflict' }
    ) {
        Register-PassDownStopSeam -Files @{ $script:ItemCheckpointPath = (Get-PassDownStopItem) }
        $decision = Invoke-PassDownStop -ArtifactType 'epic-orchestrator-state' -Root $script:Epic -CheckpointText (Get-PassDownStopParent -Kind epic -Status $Status -Directive @(Get-PassDownStopEntry))
        $decision.Ok | Should -BeFalse
        $decision.Repairable | Should -BeTrue
        $decision.Message | Should -BeLike 'OWNER_DIRECTIVE_BLOCKED: OWNER_DIRECTIVE_RELAY_MISSING: *child #1157*OD-1*'
    }

    It 'does not check a child with merge_status <Status>' -ForEach @(
        @{ Status = 'not_started' }, @{ Status = 'blocked_conflict_loop_limit' }, @{ Status = 'merged' }, @{ Status = 'worktree_removed' }
    ) {
        Register-PassDownStopSeam -Files @{ $script:ItemCheckpointPath = (Get-PassDownStopItem) }
        Invoke-PassDownStop -ArtifactType 'epic-orchestrator-state' -Root $script:Epic -CheckpointText (Get-PassDownStopParent -Kind epic -Status $Status -Directive @(Get-PassDownStopEntry)) | Should -BeNullOrEmpty
        Should -Invoke Resolve-OrchestratorOutputOwnerPassDownChild -Times 0 -Exactly
    }
}

Describe 'parallel parent running-child check (AC-31)' {
    It 'reports a child with merge_status <Status> that lacks the entry' -ForEach @(@{ Status = 'worktree_created' }, @{ Status = 'pr_open' }, @{ Status = 'ci_green' }) {
        Register-PassDownStopSeam -Files @{ $script:ItemCheckpointPath = (Get-PassDownStopItem) }
        $decision = Invoke-PassDownStop -ArtifactType 'parallel-orchestrator-state' -Root $script:Parallel -CheckpointText (Get-PassDownStopParent -Kind parallel -Status $Status -Directive @(Get-PassDownStopEntry))
        $decision.Message | Should -BeLike 'OWNER_DIRECTIVE_BLOCKED: OWNER_DIRECTIVE_RELAY_MISSING: *'
        $decision.Repairable | Should -BeTrue
    }

    It 'does not check a child with merge_status <Status>' -ForEach @(
        @{ Status = 'not_started' }, @{ Status = 'merged' }, @{ Status = 'worktree_removed' }, @{ Status = 'blocked_drift' }, @{ Status = 'blocked_ci_loop_limit' }
    ) {
        Register-PassDownStopSeam -Files @{ $script:ItemCheckpointPath = (Get-PassDownStopItem) }
        Invoke-PassDownStop -ArtifactType 'parallel-orchestrator-state' -Root $script:Parallel -CheckpointText (Get-PassDownStopParent -Kind parallel -Status $Status -Directive @(Get-PassDownStopEntry)) | Should -BeNullOrEmpty
    }
}

Describe 'running-child compliance (AC-32)' {
    It 'allows a child whose checkpoint holds the same id and text_sha256' {
        Register-PassDownStopSeam -Files @{ $script:ItemCheckpointPath = (Get-PassDownStopItem -Directive @(Get-PassDownStopEntry)) }
        Invoke-PassDownStop -ArtifactType 'epic-orchestrator-state' -Root $script:Epic -CheckpointText (Get-PassDownStopParent -Kind epic -Directive @(Get-PassDownStopEntry)) | Should -BeNullOrEmpty
    }

    It 'allows a resolved <Kind> child whose checkpoint links back' -ForEach @(@{ Kind = 'epic'; Type = 'epic-orchestrator-state' }, @{ Kind = 'parallel'; Type = 'parallel-orchestrator-state' }) {
        Register-PassDownStopSeam -Files @{ $script:ItemCheckpointPath = (Get-PassDownStopItem -Link $Kind) }
        Invoke-PassDownStop -ArtifactType $Type -Root $script:Epic -CheckpointText (Get-PassDownStopParent -Kind $Kind -Directive @(Get-PassDownStopEntry)) | Should -BeNullOrEmpty
    }

    It 'reports <Case>' -ForEach @(
        @{ Case = 'an unresolvable child'; Child = [pscustomobject]@{ Status = 'TARGET_WORKTREE_NOT_DERIVABLE'; WorktreeRoot = $null }; Files = @{}; Expected = '*TARGET_WORKTREE_NOT_DERIVABLE*' }
        @{ Case = 'an unreadable child checkpoint'; Child = $null; Files = @{}; Expected = '*Unreadable*' }
        @{ Case = 'a child that does not link back'; Child = $null; Files = @{ '/synthetic-worktrees/item-1157/artifacts/orchestration/orchestrator-state.json' = '{"issue-num":"1157","parallel_slug":"other"}' }; Expected = '*Resolved*does not link back*' }
    ) {
        Register-PassDownStopSeam -Files $Files -Child $Child
        $decision = Invoke-PassDownStop -ArtifactType 'epic-orchestrator-state' -Root $script:Epic -CheckpointText (Get-PassDownStopParent -Kind epic -Directive @(Get-PassDownStopEntry))
        $decision.Message | Should -BeLike "OWNER_DIRECTIVE_BLOCKED: OWNER_DIRECTIVE_RELAY_MISSING: $Expected"
    }

    It 'reports an id conflict between parent and child even when the child links back' {
        Register-PassDownStopSeam -Files @{ $script:ItemCheckpointPath = (Get-PassDownStopItem -Link epic -Directive @(Get-PassDownStopEntry -Text 'The child text of the same id.')) }
        $decision = Invoke-PassDownStop -ArtifactType 'epic-orchestrator-state' -Root $script:Epic -CheckpointText (Get-PassDownStopParent -Kind epic -Directive @(Get-PassDownStopEntry))
        $decision.Message | Should -BeLike '*OWNER_DIRECTIVE_RELAY_MISSING:*different text_sha256*'
    }

    It 'does not require an expired parent entry' {
        Register-PassDownStopSeam -Files @{ $script:ItemCheckpointPath = (Get-PassDownStopItem) }
        Invoke-PassDownStop -ArtifactType 'epic-orchestrator-state' -Root $script:Epic -CheckpointText (Get-PassDownStopParent -Kind epic -Directive @(Get-PassDownStopEntry -Expires '2026-11-10T12:00:00Z')) | Should -BeNullOrEmpty
    }

    It 'reports an invalid parent ledger line as OWNER_DIRECTIVE_LEDGER_INVALID' {
        Register-PassDownStopSeam -Files @{ "$script:Epic/artifacts/orchestration/owner-directives.jsonl" = '{"id":"OD-1"}' }
        $decision = Invoke-PassDownStop -ArtifactType 'epic-orchestrator-state' -Root $script:Epic -CheckpointText (Get-PassDownStopParent -Kind epic)
        $decision.Message | Should -BeLike 'OWNER_DIRECTIVE_BLOCKED: OWNER_DIRECTIVE_LEDGER_INVALID: parent-ledger: Ledger line #1 *'
    }
}

Describe 'item stop (AC-33)' {
    It 'blocks an item checkpoint missing an entry selected from <Source>' -ForEach @(
        @{ Source = 'its own ledger'; Key = '/synthetic-worktrees/item-1157/artifacts/orchestration/owner-directives.jsonl'; Value = 'ledger'; Link = '' }
        @{ Source = 'the parent checkpoint'; Key = '/synthetic-worktrees/epic/artifacts/orchestration/epic-orchestrator-state.json'; Value = 'checkpoint'; Link = 'epic' }
        @{ Source = 'the parent ledger'; Key = '/synthetic-worktrees/epic/artifacts/orchestration/owner-directives.jsonl'; Value = 'ledger'; Link = 'epic' }
    ) {
        $value = if ($Value -eq 'ledger') { Get-PassDownStopEntry } else { Get-PassDownStopParent -Kind epic -Directive @(Get-PassDownStopEntry) }
        Register-PassDownStopSeam -Files @{ $Key = $value } -Parent $script:EpicParent
        $decision = Invoke-PassDownStop -ArtifactType 'orchestrator-state' -Root $script:Item -CheckpointText (Get-PassDownStopItem -Link $Link)
        $decision.Message | Should -BeLike 'OWNER_DIRECTIVE_BLOCKED: OWNER_DIRECTIVE_RELAY_MISSING: *lacks OD-1*'
        $decision.Repairable | Should -BeTrue
    }

    It 'allows an item checkpoint that holds every selected entry' {
        Register-PassDownStopSeam -Files @{ "$script:Item/artifacts/orchestration/owner-directives.jsonl" = (Get-PassDownStopEntry) }
        Invoke-PassDownStop -ArtifactType 'orchestrator-state' -Root $script:Item -CheckpointText (Get-PassDownStopItem -Directive @(Get-PassDownStopEntry)) | Should -BeNullOrEmpty
    }

    It 'reports an invalid item ledger line as OWNER_DIRECTIVE_LEDGER_INVALID' {
        Register-PassDownStopSeam -Files @{ "$script:Item/artifacts/orchestration/owner-directives.jsonl" = 'not json' }
        $decision = Invoke-PassDownStop -ArtifactType 'orchestrator-state' -Root $script:Item -CheckpointText (Get-PassDownStopItem)
        $decision.Message | Should -BeExactly 'OWNER_DIRECTIVE_BLOCKED: OWNER_DIRECTIVE_LEDGER_INVALID: item-ledger: Ledger line #1 is not a JSON object.'
    }

    It 'reports a conflict between the item checkpoint and the parent ledger' {
        Register-PassDownStopSeam -Files @{ "$script:Epic/artifacts/orchestration/owner-directives.jsonl" = (Get-PassDownStopEntry -Text 'The parent text of the same id.') } -Parent $script:EpicParent
        $decision = Invoke-PassDownStop -ArtifactType 'orchestrator-state' -Root $script:Item -CheckpointText (Get-PassDownStopItem -Link epic -Directive @(Get-PassDownStopEntry))
        $decision.Message | Should -BeLike '*OD-1 in parent-ledger has a different text_sha256 than in item-checkpoint*'
    }
}

Describe 'key gate and clock (AC-34, AC-25 stop part)' {
    It 'keeps today''s decision for an unlinked item without owner_directives or ledger, with no parent call and no clock read' {
        Register-PassDownStopSeam -Files @{}
        Invoke-PassDownStop -ArtifactType 'orchestrator-state' -Root $script:Item -CheckpointText (Get-PassDownStopItem) | Should -BeNullOrEmpty
        Should -Invoke Resolve-OrchestratorOutputOwnerPassDownParent -Times 0 -Exactly
        Should -Invoke Get-OrchestratorOutputOwnerPassDownClock -Times 0 -Exactly
    }

    It 'keeps today''s decision for a linked item whose parent has no source, with one parent call and no clock read' {
        Register-PassDownStopSeam -Files @{ "$script:Epic/artifacts/orchestration/epic-orchestrator-state.json" = (Get-PassDownStopParent -Kind epic) } -Parent $script:EpicParent
        Invoke-PassDownStop -ArtifactType 'orchestrator-state' -Root $script:Item -CheckpointText (Get-PassDownStopItem -Link epic) | Should -BeNullOrEmpty
        Should -Invoke Resolve-OrchestratorOutputOwnerPassDownParent -Times 1 -Exactly
        Should -Invoke Get-OrchestratorOutputOwnerPassDownClock -Times 0 -Exactly
    }

    It 'blocks a linked item whose resolved parent <Where> holds a selected entry, with one parent call and one clock read' -ForEach @(
        @{ Where = 'checkpoint'; Key = '/synthetic-worktrees/epic/artifacts/orchestration/epic-orchestrator-state.json' }
        @{ Where = 'ledger'; Key = '/synthetic-worktrees/epic/artifacts/orchestration/owner-directives.jsonl' }
    ) {
        $value = if ($Where -eq 'ledger') { Get-PassDownStopEntry } else { Get-PassDownStopParent -Kind epic -Directive @(Get-PassDownStopEntry) }
        Register-PassDownStopSeam -Files @{ $Key = $value } -Parent $script:EpicParent
        (Invoke-PassDownStop -ArtifactType 'orchestrator-state' -Root $script:Item -CheckpointText (Get-PassDownStopItem -Link epic)).Message | Should -BeLike '*OWNER_DIRECTIVE_RELAY_MISSING:*'
        Should -Invoke Resolve-OrchestratorOutputOwnerPassDownParent -Times 1 -Exactly
        Should -Invoke Get-OrchestratorOutputOwnerPassDownClock -Times 1 -Exactly
    }

    It 'keeps today''s decision when the parent seam <Case>' -ForEach @(
        @{ Case = 'returns NoTarget'; Parent = [pscustomobject]@{ Kind = 'epic'; Status = 'NoTarget'; WorktreeRoot = $null; IntegrationBranch = 'epic/pass-down-integration' } }
        @{ Case = 'returns Ambiguous'; Parent = [pscustomobject]@{ Kind = 'epic'; Status = 'Ambiguous'; WorktreeRoot = $null; IntegrationBranch = 'epic/pass-down-integration' } }
        @{ Case = 'throws'; Parent = { throw 'listing failed' } }
    ) {
        Register-PassDownStopSeam -Files @{ "$script:Epic/artifacts/orchestration/owner-directives.jsonl" = (Get-PassDownStopEntry) } -Parent $Parent
        Invoke-PassDownStop -ArtifactType 'orchestrator-state' -Root $script:Item -CheckpointText (Get-PassDownStopItem -Link epic) | Should -BeNullOrEmpty
        Should -Invoke Get-OrchestratorOutputOwnerPassDownClock -Times 0 -Exactly
    }

    It 'keeps today''s decision for <Type> without owner_directives or ledger, with no clock read' -ForEach @(
        @{ Type = 'epic-orchestrator-state'; Kind = 'epic' }, @{ Type = 'parallel-orchestrator-state'; Kind = 'parallel' }
    ) {
        Register-PassDownStopSeam -Files @{}
        Invoke-PassDownStop -ArtifactType $Type -Root $script:Epic -CheckpointText (Get-PassDownStopParent -Kind $Kind) | Should -BeNullOrEmpty
        Should -Invoke Get-OrchestratorOutputOwnerPassDownClock -Times 0 -Exactly
    }

    It 'keeps today''s decision for unparseable checkpoint text and for an item without an issue number' {
        Register-PassDownStopSeam -Files @{ "$script:Item/artifacts/orchestration/owner-directives.jsonl" = (Get-PassDownStopEntry) }
        Invoke-PassDownStop -ArtifactType 'orchestrator-state' -Root $script:Item -CheckpointText 'not json' | Should -BeNullOrEmpty
        Invoke-PassDownStop -ArtifactType 'orchestrator-state' -Root $script:Item -CheckpointText '{"next_step":"S5"}' | Should -BeNullOrEmpty
    }
}

Describe 'default seams' {
    It 'reads nothing for an absent path and returns a UTC clock value' {
        Read-OrchestratorOutputOwnerPassDownText -Path '/synthetic-worktrees/absent/file.json' | Should -BeNullOrEmpty
        (Get-OrchestratorOutputOwnerPassDownClock).Kind | Should -Be ([System.DateTimeKind]::Utc)
    }

    It 'the parent seam reports the resolver status of an epic and a parallel link' {
        Mock Resolve-WorktreeEpicTarget { [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = '/synthetic-worktrees/epic' } }
        Mock Resolve-WorktreeParallelTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null } }
        $epic = Resolve-OrchestratorOutputOwnerPassDownParent -Checkpoint ('{"epic_context":{"integration_branch":"epic/x"}}' | ConvertFrom-Json) -SessionRoot '/synthetic-worktrees/main'
        $epic.Kind | Should -BeExactly 'epic'
        $epic.WorktreeRoot | Should -BeExactly '/synthetic-worktrees/epic'
        $parallel = Resolve-OrchestratorOutputOwnerPassDownParent -Checkpoint ('{"parallel_slug":"harness"}' | ConvertFrom-Json) -SessionRoot '/synthetic-worktrees/main'
        $parallel.Kind | Should -BeExactly 'parallel'
        $parallel.Status | Should -BeExactly 'NoTarget'
    }

    It 'the child seam reports the resolution of a delegation identity' {
        Mock Resolve-HookTargetWorktree { [pscustomobject]@{ WorktreeRoot = '/synthetic-worktrees/item-1157'; ReasonCode = $null } }
        (Resolve-OrchestratorOutputOwnerPassDownChild -Issue '1157' -SessionRoot '/synthetic-worktrees/main').Status | Should -BeExactly 'Resolved'
        Mock Resolve-HookTargetWorktree { [pscustomobject]@{ WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS' } }
        (Resolve-OrchestratorOutputOwnerPassDownChild -Issue '1157' -SessionRoot '/synthetic-worktrees/main').Status | Should -BeExactly 'TARGET_WORKTREE_AMBIGUOUS'
    }
}
