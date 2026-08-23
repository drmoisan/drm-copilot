# Validates and persists one parallel item's main-only PR, CI, merge, and worktree-removal result.

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'epic-child-launch-runtime.ps1')
. (Join-Path $PSScriptRoot 'codex-child-launch-persistence.ps1')

function Invoke-CodexParallelGh {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][string[]] $GhArgs)

    $output = @(& gh @GhArgs 2>&1)
    return [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        StdOut   = ($output -join [Environment]::NewLine)
        StdErr   = ''
    }
}

function Get-CodexParallelPostSessionCommandResult {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][scriptblock] $Invoker,
        [Parameter(Mandatory)][string[]] $Arguments,
        [Parameter(Mandatory)][string] $Label
    )

    $result = & $Invoker $Arguments
    if ($null -eq $result -or $null -eq $result.PSObject.Properties['ExitCode']) {
        throw "PARALLEL_POST_SESSION_BLOCKED: $Label did not return an ExitCode."
    }
    if ([int]$result.ExitCode -ne 0) {
        $detail = @([string]$result.StdErr, [string]$result.StdOut) |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        throw "PARALLEL_POST_SESSION_BLOCKED: $Label failed: $($detail -join ' ')"
    }
    return $result
}

function ConvertFrom-CodexParallelPostSessionJson {
    [CmdletBinding()]
    param(
        [AllowEmptyString()][string] $Json,
        [Parameter(Mandatory)][string] $Label
    )

    if ([string]::IsNullOrWhiteSpace($Json)) {
        throw "PARALLEL_POST_SESSION_BLOCKED: $Label returned empty JSON."
    }
    try {
        return $Json | ConvertFrom-Json -Depth 64 -ErrorAction Stop
    } catch {
        throw "PARALLEL_POST_SESSION_BLOCKED: $Label returned invalid JSON: $($_.Exception.Message)"
    }
}

function Test-CodexParallelPostSessionForbiddenState {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)] $Value)

    $forbidden = @('integration_branch', 'integration_pr', 'epic_merge_pr', 'fan_in', 'waves')
    foreach ($property in @($Value.PSObject.Properties)) {
        if ([string]$property.Name -in $forbidden) {
            return $true
        }
        if ($null -ne $property.Value -and
            $property.Value -isnot [string] -and
            ($property.Value -is [System.Collections.IEnumerable] -or
            $property.Value -is [psobject])) {
            foreach ($entry in @($property.Value)) {
                if ($null -ne $entry -and $entry -isnot [string] -and
                    (Test-CodexParallelPostSessionForbiddenState -Value $entry)) {
                    return $true
                }
            }
        }
    }
    return $false
}

function Get-CodexParallelPostSessionItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $Checkpoint,
        [Parameter(Mandatory)][ValidateRange(1, [int]::MaxValue)][int] $ItemKey
    )

    if ([string]$Checkpoint.route_id -ne 'parallel' -or
        (Test-CodexParallelPostSessionForbiddenState -Value $Checkpoint)) {
        throw 'PARALLEL_POST_SESSION_BLOCKED: parallel state must not contain integration or fan-in fields.'
    }
    $matchingItems = @($Checkpoint.items | Where-Object { [int]$_.issue_num -eq $ItemKey })
    if ($matchingItems.Count -ne 1) {
        throw "PARALLEL_POST_SESSION_BLOCKED: item $ItemKey must resolve exactly once in the checkpoint."
    }
    $item = $matchingItems[0]
    if ([string]$item.base_branch -ne 'main') {
        throw "PARALLEL_POST_SESSION_BLOCKED: item $ItemKey PR base branch must be main."
    }
    if ([string]::IsNullOrWhiteSpace([string]$item.branch_name) -or
        [string]::IsNullOrWhiteSpace([string]$item.worktree_path)) {
        throw "PARALLEL_POST_SESSION_BLOCKED: item $ItemKey requires branch_name and worktree_path."
    }
    return $item
}

function Test-CodexParallelPostSessionReceiptPath {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][string] $Path)

    return -not [string]::IsNullOrWhiteSpace($Path) -and
    -not [IO.Path]::IsPathRooted($Path) -and
    $Path -notmatch '\\' -and
    $Path -notmatch '(^|/)\.\.(/|$)'
}

function Get-CodexParallelPostSessionDefaultGitInvoker {
    [CmdletBinding()]
    [OutputType([scriptblock])]
    param()

    return {
        param([string[]]$Arguments)
        try {
            $output = @(Invoke-CodexChildGit -GitArgs $Arguments)
            [pscustomobject]@{ ExitCode = 0; StdOut = ($output -join [Environment]::NewLine); StdErr = '' }
        } catch {
            [pscustomobject]@{ ExitCode = 1; StdOut = ''; StdErr = $_.Exception.Message }
        }
    }
}

function Get-CodexParallelPostSessionDefaultGhInvoker {
    [CmdletBinding()]
    [OutputType([scriptblock])]
    param()

    return {
        param([string[]]$Arguments)
        Invoke-CodexParallelGh -GhArgs $Arguments
    }
}

function Get-CodexParallelPostSessionPr {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $Item,
        [Parameter(Mandatory)][string] $HeadSha,
        [Parameter(Mandatory)][scriptblock] $InvokeGh
    )

    $ghArgs = @(
        'pr', 'list', '--head', [string]$Item.branch_name, '--base', 'main', '--state', 'all',
        '--json', 'number,url,baseRefName,headRefName,headRefOid,state,mergedAt,mergeCommit'
    )
    $result = Get-CodexParallelPostSessionCommandResult -Invoker $InvokeGh `
        -Arguments $ghArgs -Label 'gh pr list'
    $prs = if ([string]::IsNullOrWhiteSpace([string]$result.StdOut)) {
        @()
    } else {
        @(ConvertFrom-CodexParallelPostSessionJson -Json ([string]$result.StdOut) `
                -Label 'gh pr list')
    }
    if ($prs.Count -ne 1) {
        throw "PARALLEL_POST_SESSION_BLOCKED: item $($Item.issue_num) must own exactly one PR targeting main."
    }
    $pr = $prs[0]
    if ([string]$pr.baseRefName -ne 'main' -or
        [string]$pr.headRefName -ne [string]$Item.branch_name) {
        throw "PARALLEL_POST_SESSION_BLOCKED: PR $($pr.number) must bind the item branch directly to main."
    }
    if ([string]$pr.headRefOid -ne $HeadSha) {
        throw 'PARALLEL_POST_SESSION_BLOCKED: PR head SHA must match the checked worktree HEAD.'
    }
    return $pr
}

function Get-CodexParallelPostSessionCheckReceipt {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int] $PrNumber,
        [Parameter(Mandatory)][string] $HeadSha,
        [Parameter(Mandatory)][scriptblock] $InvokeGh,
        [Parameter(Mandatory)][string] $VerifiedAt
    )

    $ghArgs = @('pr', 'checks', [string]$PrNumber, '--required', '--json', 'bucket,name,state,link,workflow')
    $result = Get-CodexParallelPostSessionCommandResult -Invoker $InvokeGh `
        -Arguments $ghArgs -Label 'gh pr checks'
    $checks = @(ConvertFrom-CodexParallelPostSessionJson -Json ([string]$result.StdOut) `
            -Label 'gh pr checks')
    if ($checks.Count -eq 0 -or @($checks | Where-Object { [string]$_.bucket -ne 'pass' }).Count -gt 0) {
        throw 'PARALLEL_POST_SESSION_BLOCKED: required checks must all be green for the checked head.'
    }
    return [pscustomobject]@{
        head_sha        = $HeadSha
        conclusion      = 'success'
        verified_at     = $VerifiedAt
        required_checks = $checks
    }
}

function Get-CodexParallelPostSessionMergedPr {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $Pr,
        [Parameter(Mandatory)] $Item,
        [Parameter(Mandatory)][string] $HeadSha,
        [Parameter(Mandatory)][scriptblock] $InvokeGh
    )

    $number = [int]$Pr.number
    $null = Get-CodexParallelPostSessionCommandResult -Invoker $InvokeGh `
        -Arguments @('pr', 'merge', [string]$number, '--merge') -Label 'gh pr merge'
    $viewArgs = @(
        'pr', 'view', [string]$number, '--json',
        'number,url,baseRefName,headRefName,headRefOid,state,mergedAt,mergeCommit'
    )
    $result = Get-CodexParallelPostSessionCommandResult -Invoker $InvokeGh `
        -Arguments $viewArgs -Label 'gh pr view'
    $merged = ConvertFrom-CodexParallelPostSessionJson -Json ([string]$result.StdOut) `
        -Label 'gh pr view'
    if ([string]$merged.state -ne 'MERGED' -or
        [string]$merged.baseRefName -ne 'main' -or
        [string]$merged.headRefName -ne [string]$Item.branch_name -or
        [string]$merged.headRefOid -ne $HeadSha -or
        [string]::IsNullOrWhiteSpace([string]$merged.mergedAt) -or
        [string]::IsNullOrWhiteSpace([string]$merged.mergeCommit.oid)) {
        throw "PARALLEL_POST_SESSION_BLOCKED: PR $number is not merged to main with the checked head."
    }
    return $merged
}

function Invoke-CodexParallelChildPostSession {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] $Checkpoint,
        [Parameter(Mandatory)][ValidateRange(1, [int]::MaxValue)][int] $ItemKey,
        [Parameter(Mandatory)][string] $RepositoryRoot,
        [Parameter(Mandatory)][string] $CompletionReceiptPath,
        [scriptblock] $InvokeGit,
        [scriptblock] $InvokeGh,
        [scriptblock] $PersistReceipt,
        [scriptblock] $PersistCheckpoint,
        [scriptblock] $Clock = { [DateTimeOffset]::UtcNow.ToString('o') }
    )

    if (-not (Test-CodexParallelPostSessionReceiptPath -Path $CompletionReceiptPath)) {
        throw 'PARALLEL_POST_SESSION_BLOCKED: completion receipt path must be repository-relative.'
    }
    $item = Get-CodexParallelPostSessionItem -Checkpoint $Checkpoint -ItemKey $ItemKey
    if ($null -eq $InvokeGit) { $InvokeGit = Get-CodexParallelPostSessionDefaultGitInvoker }
    if ($null -eq $InvokeGh) { $InvokeGh = Get-CodexParallelPostSessionDefaultGhInvoker }
    if ($null -eq $PersistReceipt) {
        $PersistReceipt = {
            param([string]$Path, $Receipt)
            Write-CodexChildJsonCreateNewCore -Path (Join-Path $RepositoryRoot $Path) -Value $Receipt
        }.GetNewClosure()
    }
    if ($null -eq $PersistCheckpoint) {
        throw 'PARALLEL_POST_SESSION_BLOCKED: PersistCheckpoint is required for atomic checkpoint publication.'
    }

    $worktree = [IO.Path]::GetFullPath([string]$item.worktree_path)
    $branchResult = Get-CodexParallelPostSessionCommandResult -Invoker $InvokeGit `
        -Arguments @('-C', $worktree, 'rev-parse', '--abbrev-ref', 'HEAD') -Label 'git branch'
    $branch = ([string]$branchResult.StdOut).Trim()
    if ($branch -ne [string]$item.branch_name) {
        throw "PARALLEL_POST_SESSION_BLOCKED: item $ItemKey live branch does not match the checkpoint."
    }
    $headResult = Get-CodexParallelPostSessionCommandResult -Invoker $InvokeGit `
        -Arguments @('-C', $worktree, 'rev-parse', 'HEAD') -Label 'git head'
    $headSha = ([string]$headResult.StdOut).Trim()
    if ($headSha -notmatch '^[0-9a-fA-F]{40}$' -or [string]$item.checked_head -ne $headSha) {
        throw "PARALLEL_POST_SESSION_BLOCKED: item $ItemKey checked head does not match live HEAD."
    }
    $listResult = Get-CodexParallelPostSessionCommandResult -Invoker $InvokeGit `
        -Arguments @('-C', $RepositoryRoot, 'worktree', 'list', '--porcelain') `
        -Label 'git worktree list'
    if (@(([string]$listResult.StdOut -split "`r?`n") | Where-Object {
                $_ -eq "worktree $worktree"
            }).Count -ne 1) {
        throw "PARALLEL_POST_SESSION_BLOCKED: item $ItemKey worktree does not match live Git state."
    }

    $verifiedAt = [string](& $Clock)
    $pr = Get-CodexParallelPostSessionPr -Item $item -HeadSha $headSha -InvokeGh $InvokeGh
    $checks = Get-CodexParallelPostSessionCheckReceipt -PrNumber ([int]$pr.number) `
        -HeadSha $headSha -InvokeGh $InvokeGh -VerifiedAt $verifiedAt
    $merged = Get-CodexParallelPostSessionMergedPr -Pr $pr -Item $item `
        -HeadSha $headSha -InvokeGh $InvokeGh
    $mergedAt = ([datetimeoffset]$merged.mergedAt).ToUniversalTime().ToString(
        'yyyy-MM-ddTHH:mm:ssZ',
        [Globalization.CultureInfo]::InvariantCulture
    )

    if ($PSCmdlet.ShouldProcess($worktree, "Remove merged parallel item $ItemKey worktree")) {
        $null = Get-CodexParallelPostSessionCommandResult -Invoker $InvokeGit `
            -Arguments @('-C', $RepositoryRoot, 'worktree', 'remove', '--', $worktree) `
            -Label 'git worktree remove'
    }
    $postRemovalResult = Get-CodexParallelPostSessionCommandResult -Invoker $InvokeGit `
        -Arguments @('-C', $RepositoryRoot, 'worktree', 'list', '--porcelain') `
        -Label 'git worktree list after removal'
    if (@(([string]$postRemovalResult.StdOut -split "`r?`n") | Where-Object {
                $_ -eq "worktree $worktree"
            }).Count -ne 0) {
        throw "PARALLEL_POST_SESSION_BLOCKED: item $ItemKey worktree remains after removal."
    }
    $receipt = [pscustomobject]@{
        schema_version   = 1
        surface          = 'parallel'
        item_key         = $ItemKey
        receipt_path     = $CompletionReceiptPath
        recorded_at      = $verifiedAt
        pr               = [pscustomobject]@{
            number      = [int]$merged.number
            url         = [string]$merged.url
            base_branch = 'main'
            head_branch = [string]$merged.headRefName
            head_sha    = $headSha
        }
        checks           = $checks
        merge            = [pscustomobject]@{
            merged_at        = $mergedAt
            merge_commit_sha = [string]$merged.mergeCommit.oid
        }
        worktree_removal = [pscustomobject]@{
            worktree_path = $worktree
            removed_at    = $verifiedAt
        }
    }

    $updated = $Checkpoint | ConvertTo-Json -Depth 64 | ConvertFrom-Json -Depth 64
    $updatedItem = @($updated.items | Where-Object { [int]$_.issue_num -eq $ItemKey })[0]
    $updatedItem.state = 'merged'
    $updatedItem.merge_status = 'worktree_removed'
    $itemUpdates = [ordered]@{
        pr_number                     = [int]$merged.number
        pr_url                        = [string]$merged.url
        pr_base_branch                = 'main'
        pr_head_branch                = [string]$merged.headRefName
        pr_head_sha                   = $headSha
        pr_state                      = [string]$merged.state
        checks_head_sha               = $headSha
        checks_conclusion             = [string]$checks.conclusion
        merged_at                     = $mergedAt
        merge_commit_sha              = [string]$merged.mergeCommit.oid
        merge_receipt_path            = $CompletionReceiptPath
        worktree_removed_at           = $verifiedAt
        worktree_removal_receipt_path = $CompletionReceiptPath
        completion_receipt_path       = $CompletionReceiptPath
    }
    foreach ($entry in $itemUpdates.GetEnumerator()) {
        $updatedItem | Add-Member -NotePropertyName $entry.Key `
            -NotePropertyValue $entry.Value -Force
    }

    & $PersistReceipt $CompletionReceiptPath $receipt
    & $PersistCheckpoint $updated
    return [pscustomobject]@{
        ItemKey           = $ItemKey
        BaseBranch        = 'main'
        HeadSha           = $headSha
        PrNumber          = [int]$merged.number
        MergeCommitSha    = [string]$merged.mergeCommit.oid
        WorktreeRemoved   = $true
        CompletionReceipt = $receipt
        UpdatedCheckpoint = $updated
    }
}
