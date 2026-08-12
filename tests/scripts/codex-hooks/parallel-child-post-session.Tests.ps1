# Contract tests for main-only per-item PR, CI, merge, and worktree-removal handling.

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    $script:AdapterPath = Join-Path $script:RepoRoot '.codex/scripts/parallel-child-post-session.ps1'
    . $script:AdapterPath

    function Get-TestPostSessionCommandResult {
        param(
            [int]$ExitCode = 0,
            [string]$StdOut = '',
            [string]$StdErr = ''
        )

        return [pscustomobject]@{
            ExitCode = $ExitCode
            StdOut   = $StdOut
            StdErr   = $StdErr
        }
    }

    function Get-TestParallelPostSessionCheckpoint {
        param(
            [string]$BaseBranch = 'main',
            [string]$HeadSha = ('a' * 40)
        )

        return [pscustomobject]@{
            route_id       = 'parallel'
            parallel_slug  = 'post-session-contract'
            mode           = 'closed'
            current_cohort = 0
            items          = @(
                [pscustomobject]@{
                    issue_num      = 101
                    feature_folder = '2026-08-10-parallel-item-101'
                    state          = 'in_flight'
                    merge_status   = 'pr_open'
                    branch_name    = 'feature/parallel-item-101'
                    base_branch    = $BaseBranch
                    worktree_path  = $script:Worktree
                    checked_head   = $HeadSha
                }
            )
        }
    }

    function Invoke-TestParallelPostSession {
        param([pscustomobject]$Checkpoint = (Get-TestParallelPostSessionCheckpoint))

        return Invoke-CodexParallelChildPostSession `
            -Checkpoint $Checkpoint `
            -ItemKey 101 `
            -RepositoryRoot $script:RepoRoot `
            -CompletionReceiptPath 'artifacts/orchestration/parallel/item-101-completion.json' `
            -InvokeGit $script:InvokeGit `
            -InvokeGh $script:InvokeGh `
            -PersistReceipt $script:PersistReceipt `
            -PersistCheckpoint $script:PersistCheckpoint `
            -Clock { '2026-08-10T21:31:00Z' }
    }
}

Describe 'Codex parallel child post-session contract' {
    BeforeEach {
        $script:Worktree = Join-Path $script:RepoRoot 'worktrees/parallel-item-101'
        $script:HeadSha = 'a' * 40
        $script:MergeSha = 'b' * 40
        $script:GitCalls = [System.Collections.Generic.List[object]]::new()
        $script:GhCalls = [System.Collections.Generic.List[object]]::new()
        $script:PersistedReceipts = [System.Collections.Generic.List[object]]::new()
        $script:PersistedCheckpoints = [System.Collections.Generic.List[object]]::new()
        $script:WorktreeRemoved = $false
        $script:KeepWorktreeAfterRemoval = $false
        $script:PrList = @(
            [pscustomobject]@{
                number      = 42
                url         = 'https://github.example/pull/42'
                baseRefName = 'main'
                headRefName = 'feature/parallel-item-101'
                headRefOid  = $script:HeadSha
                state       = 'OPEN'
                mergedAt    = $null
                mergeCommit = $null
            }
        )
        $script:CheckList = @(
            [pscustomobject]@{
                bucket   = 'pass'
                name     = 'unit'
                state    = 'SUCCESS'
                link     = 'https://ci.example/unit'
                workflow = 'CI'
            }
        )
        $script:FinalPr = [pscustomobject]@{
            number      = 42
            url         = 'https://github.example/pull/42'
            baseRefName = 'main'
            headRefName = 'feature/parallel-item-101'
            headRefOid  = $script:HeadSha
            state       = 'MERGED'
            mergedAt    = '2026-08-10T21:30:00Z'
            mergeCommit = [pscustomobject]@{ oid = $script:MergeSha }
        }

        $script:InvokeGit = {
            param([string[]]$Arguments)

            $script:GitCalls.Add(@($Arguments))
            $joined = $Arguments -join ' '
            if ($joined -match 'rev-parse HEAD$') {
                return Get-TestPostSessionCommandResult -StdOut $script:HeadSha
            }
            if ($joined -match 'rev-parse --abbrev-ref HEAD$') {
                return Get-TestPostSessionCommandResult -StdOut 'feature/parallel-item-101'
            }
            if ($joined -match 'worktree list --porcelain$') {
                $output = if ($script:WorktreeRemoved) { '' } else { "worktree $script:Worktree" }
                return Get-TestPostSessionCommandResult -StdOut $output
            }
            if ($joined -match 'worktree remove') {
                if (-not $script:KeepWorktreeAfterRemoval) {
                    $script:WorktreeRemoved = $true
                }
                return Get-TestPostSessionCommandResult
            }
            return Get-TestPostSessionCommandResult
        }
        $script:InvokeGh = {
            param([string[]]$Arguments)

            $script:GhCalls.Add(@($Arguments))
            $joined = $Arguments -join ' '
            if ($joined -match '^pr list ') {
                return Get-TestPostSessionCommandResult -StdOut ($script:PrList | ConvertTo-Json -Depth 8 -Compress)
            }
            if ($joined -match '^pr checks ') {
                return Get-TestPostSessionCommandResult -StdOut ($script:CheckList | ConvertTo-Json -Depth 8 -Compress -AsArray)
            }
            if ($joined -match '^pr merge ') {
                return Get-TestPostSessionCommandResult
            }
            if ($joined -match '^pr view ') {
                return Get-TestPostSessionCommandResult -StdOut ($script:FinalPr | ConvertTo-Json -Depth 8 -Compress)
            }
            return Get-TestPostSessionCommandResult -ExitCode 2 -StdErr "unexpected gh call: $joined"
        }
        $script:PersistReceipt = {
            param([string]$ReceiptPath, [pscustomobject]$Receipt)

            $script:PersistedReceipts.Add([pscustomobject]@{
                    Path    = $ReceiptPath
                    Receipt = $Receipt
                })
        }
        $script:PersistCheckpoint = {
            param([pscustomobject]$Checkpoint)

            $script:PersistedCheckpoints.Add($Checkpoint)
        }
    }

    It 'binds one main-only PR to the exact current head and persists terminal receipts' {
        $result = Invoke-TestParallelPostSession

        $result.ItemKey | Should -Be 101
        $result.BaseBranch | Should -BeExactly 'main'
        $result.HeadSha | Should -BeExactly $script:HeadSha
        $result.PrNumber | Should -Be 42
        $result.MergeCommitSha | Should -BeExactly $script:MergeSha
        $result.WorktreeRemoved | Should -BeTrue
        $script:PersistedReceipts.Count | Should -Be 1
        $script:PersistedCheckpoints.Count | Should -Be 1
        $receipt = $script:PersistedReceipts[0].Receipt
        $receipt.schema_version | Should -Be 1
        $receipt.surface | Should -BeExactly 'parallel'
        $receipt.item_key | Should -Be 101
        $receipt.pr.base_branch | Should -BeExactly 'main'
        $receipt.pr.head_sha | Should -BeExactly $script:HeadSha
        $receipt.checks.head_sha | Should -BeExactly $script:HeadSha
        $receipt.checks.conclusion | Should -BeExactly 'success'
        $receipt.merge.merge_commit_sha | Should -BeExactly $script:MergeSha
        $receipt.worktree_removal.worktree_path | Should -BeExactly $script:Worktree
        $updatedItem = $result.UpdatedCheckpoint.items[0]
        $updatedItem.pr_state | Should -BeExactly 'MERGED'
        $updatedItem.checks_conclusion | Should -BeExactly 'success'
        $updatedItem.merged_at | Should -BeExactly $script:FinalPr.mergedAt
        $updatedItem.worktree_removed_at | Should -BeExactly '2026-08-10T21:31:00Z'
        $receipt.PSObject.Properties.Name | Should -Not -Contain 'integration_branch'
        $receipt.PSObject.Properties.Name | Should -Not -Contain 'fan_in'
    }

    It 'uses the exact main/head PR query, required checks, merge, and matching worktree removal' {
        $null = Invoke-TestParallelPostSession

        ($script:GhCalls | ForEach-Object { $_ -join ' ' }) |
            Should -Contain 'pr list --head feature/parallel-item-101 --base main --state all --json number,url,baseRefName,headRefName,headRefOid,state,mergedAt,mergeCommit'
        ($script:GhCalls | ForEach-Object { $_ -join ' ' }) |
            Should -Contain 'pr checks 42 --required --json bucket,name,state,link,workflow'
        ($script:GhCalls | ForEach-Object { $_ -join ' ' }) |
            Should -Contain 'pr merge 42 --merge'
        ($script:GitCalls | ForEach-Object { $_ -join ' ' }) |
            Should -Contain "-C $script:RepoRoot worktree remove -- $script:Worktree"

        $script:WorktreeRemoved = $false
        $script:KeepWorktreeAfterRemoval = $true
        { Invoke-TestParallelPostSession } | Should -Throw '*worktree remains after removal*'
        $script:PersistedReceipts.Count | Should -Be 1
    }

    It 'rejects zero or multiple matching PRs without merging or removing the worktree' {
        foreach ($prList in @(@(), @($script:PrList[0], $script:PrList[0]))) {
            $script:PrList = $prList
            { Invoke-TestParallelPostSession } | Should -Throw '*exactly one PR*'
        }

        @($script:GhCalls | ForEach-Object { $_ -join ' ' } | Where-Object { $_ -match '^pr merge ' }) |
            Should -BeNullOrEmpty
        @($script:GitCalls | ForEach-Object { $_ -join ' ' } | Where-Object { $_ -match 'worktree remove' }) |
            Should -BeNullOrEmpty
        $script:PersistedReceipts.Count | Should -Be 0
    }

    It 'rejects a stale PR head before checks, merge, removal, or persistence' {
        $script:PrList[0].headRefOid = 'c' * 40

        { Invoke-TestParallelPostSession } | Should -Throw '*PR head SHA must match the checked worktree HEAD*'

        @($script:GhCalls | ForEach-Object { $_ -join ' ' } | Where-Object { $_ -match '^pr checks ' }) |
            Should -BeNullOrEmpty
        @($script:GhCalls | ForEach-Object { $_ -join ' ' } | Where-Object { $_ -match '^pr merge ' }) |
            Should -BeNullOrEmpty
        @($script:GitCalls | ForEach-Object { $_ -join ' ' } | Where-Object { $_ -match 'worktree remove' }) |
            Should -BeNullOrEmpty
        $script:PersistedReceipts.Count | Should -Be 0
    }

    It 'rejects non-green required checks for the exact head before merge or removal' {
        $script:CheckList[0].bucket = 'fail'
        $script:CheckList[0].state = 'FAILURE'

        { Invoke-TestParallelPostSession } | Should -Throw '*required checks must all be green for the checked head*'

        @($script:GhCalls | ForEach-Object { $_ -join ' ' } | Where-Object { $_ -match '^pr merge ' }) |
            Should -BeNullOrEmpty
        @($script:GitCalls | ForEach-Object { $_ -join ' ' } | Where-Object { $_ -match 'worktree remove' }) |
            Should -BeNullOrEmpty
        $script:PersistedReceipts.Count | Should -Be 0
    }

    It 'rejects integration, fan-in, non-main base, and mismatched item worktree state' {
        $cases = @(
            { $checkpoint = Get-TestParallelPostSessionCheckpoint; $checkpoint | Add-Member integration_branch 'epic/fan-in'; $checkpoint },
            { $checkpoint = Get-TestParallelPostSessionCheckpoint; $checkpoint | Add-Member fan_in $true; $checkpoint },
            { Get-TestParallelPostSessionCheckpoint -BaseBranch 'epic/integration' },
            { $checkpoint = Get-TestParallelPostSessionCheckpoint; $checkpoint.items[0].worktree_path = 'C:/wrong'; $checkpoint }
        )

        foreach ($builder in $cases) {
            $script:GhCalls.Clear()
            $script:GitCalls.Clear()
            { Invoke-TestParallelPostSession -Checkpoint (& $builder) } | Should -Throw
            $script:PersistedReceipts.Count | Should -Be 0
        }
    }

    It 'rejects a merge response that does not confirm the same PR merged to main' {
        $script:FinalPr.state = 'OPEN'
        $script:FinalPr.mergedAt = $null
        $script:FinalPr.mergeCommit = $null

        { Invoke-TestParallelPostSession } | Should -Throw '*PR 42 is not merged to main*'

        @($script:GitCalls | ForEach-Object { $_ -join ' ' } | Where-Object { $_ -match 'worktree remove' }) |
            Should -BeNullOrEmpty
        $script:PersistedReceipts.Count | Should -Be 0
    }
}
