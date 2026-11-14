<#
.SYNOPSIS
    Pure predicates shared by the parallel records legs of two Claude gates (issue #1182).

.DESCRIPTION
    Dot-sourced by enforce-model-routing-receipt.ps1 and by
    enforce-orchestration-preimplementation-gate.ps1. Their parallel records legs
    (enforce-model-routing-receipt-parallel.ps1 and
    enforce-orchestration-preimplementation-gate-parallel-records.ps1) call these two functions
    and re-implement none of the identity, closed, or receipt predicates.

    Get-ParallelRecordsSlug returns the slug of a parallel plan branch
    (parallel/<slug>-plan, matched case-sensitively), or $null.

    Get-ParallelRecordsCheckpointDecision evaluates the text of a parallel-orchestrator checkpoint
    against a slug, in order, and returns the first failure:
      1. Parse     - non-blank text that parses to a JSON object
                     (PARALLEL_RECORDS_CHECKPOINT_UNREADABLE).
      2. Identity  - route_id is parallel and parallel_slug is the slug, both case-sensitive
                     (PARALLEL_RECORDS_SLUG_MISMATCH).
      3. Closed    - items is a non-empty list and every item is an object whose state is
                     withdrawn or whose merge_status is merged or worktree_removed; an absent
                     merge_status reads as not_started (PARALLEL_RECORDS_RUN_NOT_CLOSED).
      4. Present   - model_routing_receipts is present and holds an object whose agent is
                     pr-author (PARALLEL_RECORDS_RECEIPT_MISSING).
      5. Valid     - model_routing_receipts is a list and at least one pr-author entry yields no
                     error from Get-OrchestratorStateModelRoutingReceiptError applied to a
                     one-element list holding that entry (PARALLEL_RECORDS_RECEIPT_INVALID).

.NOTES
    PowerShell 7+. Claude only; mirrored byte-identically under
    extensions/drm-copilot/resources/claude-customizations/. Pure: reads no file, starts no
    process, reads no clock, and never throws. Both legs are policy-level controls, not security
    controls: a writer in the same session can forge the parallel checkpoint and its receipt
    (same-session forgery), as for the epic receipt and the standalone-merge authorization.
    Call-time dependency: Get-OrchestratorStateModelRoutingReceiptError
    (OrchestratorStateModelReceipts.psm1, which each gate imports).
#>

$script:ParallelRecordsPlanBranchPattern = '^parallel/(?<slug>[A-Za-z0-9][A-Za-z0-9._-]*)-plan$'
$script:ParallelRecordsTerminalMergeStatus = @('merged', 'worktree_removed')

function Get-ParallelRecordsSlug {
    <#
    .SYNOPSIS
        Return the slug of a parallel plan branch name, or $null.
    .PARAMETER BranchName
        The branch name, for example parallel/demo-run-plan.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()][AllowEmptyString()][string] $BranchName)

    $match = [regex]::Match([string]$BranchName, $script:ParallelRecordsPlanBranchPattern)
    if (-not $match.Success) {
        return $null
    }
    return $match.Groups['slug'].Value
}

function Get-ParallelRecordsProperty {
    <#
    .SYNOPSIS
        Return @{ Present; Value } for a named property of a parsed JSON object.
    .PARAMETER InputObject
        The parsed JSON value.
    .PARAMETER Name
        The property name, compared case-sensitively.
    .OUTPUTS
        System.Collections.Hashtable
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([AllowNull()][object] $InputObject, [Parameter(Mandatory)][string] $Name)

    if ($InputObject -isnot [System.Management.Automation.PSCustomObject] -or @($InputObject.PSObject.Properties.Name) -cnotcontains $Name) {
        return @{ Present = $false; Value = $null }
    }
    return @{ Present = $true; Value = $InputObject.$Name }
}

function Get-ParallelRecordsClosedFailure {
    <#
    .SYNOPSIS
        Condition 3: return $null when the run is closed, else the detail text.
    .PARAMETER Checkpoint
        The parsed parallel checkpoint.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()][object] $Checkpoint)

    $items = Get-ParallelRecordsProperty -InputObject $Checkpoint -Name 'items'
    if (-not $items.Present -or $items.Value -isnot [System.Array] -or @($items.Value).Count -eq 0) {
        return 'items must be a non-empty list.'
    }
    foreach ($item in @($items.Value)) {
        if ($item -isnot [System.Management.Automation.PSCustomObject]) {
            return 'an items entry is not an object.'
        }
        $state = Get-ParallelRecordsProperty -InputObject $item -Name 'state'
        if ($state.Present -and [string]$state.Value -ceq 'withdrawn') {
            continue
        }
        $status = Get-ParallelRecordsProperty -InputObject $item -Name 'merge_status'
        $mergeStatus = if ($status.Present -and $null -ne $status.Value) { [string]$status.Value } else { 'not_started' }
        if ($script:ParallelRecordsTerminalMergeStatus -cnotcontains $mergeStatus) {
            $issue = Get-ParallelRecordsProperty -InputObject $item -Name 'issue_num'
            return "item $([string]$issue.Value) has merge_status '$mergeStatus'; every item that is not withdrawn must be merged or worktree_removed."
        }
    }
    return $null
}

function Get-ParallelRecordsReceiptFailure {
    <#
    .SYNOPSIS
        Conditions 4 and 5: return $null when a valid pr-author receipt exists, else @{ SubCode; Detail }.
    .PARAMETER Checkpoint
        The parsed parallel checkpoint.
    .OUTPUTS
        System.Collections.Hashtable or $null
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([AllowNull()][object] $Checkpoint)

    $receipts = Get-ParallelRecordsProperty -InputObject $Checkpoint -Name 'model_routing_receipts'
    $authorEntries = @(@($receipts.Value) | Where-Object { $_ -is [System.Management.Automation.PSCustomObject] -and (Get-ParallelRecordsProperty -InputObject $_ -Name 'agent').Value -ceq 'pr-author' })
    if (-not $receipts.Present -or $authorEntries.Count -eq 0) {
        return @{ SubCode = 'PARALLEL_RECORDS_RECEIPT_MISSING'; Detail = 'model_routing_receipts holds no entry whose agent is pr-author.' }
    }
    if ($receipts.Value -isnot [System.Array]) {
        return @{ SubCode = 'PARALLEL_RECORDS_RECEIPT_INVALID'; Detail = [string]@(Get-OrchestratorStateModelRoutingReceiptError -Value $receipts.Value)[0] }
    }
    $firstError = $null
    foreach ($entry in $authorEntries) {
        $errors = @(Get-OrchestratorStateModelRoutingReceiptError -Value ([object[]]@($entry)))
        if ($errors.Count -eq 0) {
            return $null
        }
        if ($null -eq $firstError) {
            $firstError = [string]$errors[0]
        }
    }
    return @{ SubCode = 'PARALLEL_RECORDS_RECEIPT_INVALID'; Detail = $firstError }
}

function Get-ParallelRecordsCheckpointDecision {
    <#
    .SYNOPSIS
        Decide whether a parallel checkpoint text admits the Run Closing records pull request.
    .DESCRIPTION
        Applies conditions 1 to 5 of the file header in order. Never throws: an unexpected error
        answers Allowed $false with PARALLEL_RECORDS_CHECKPOINT_UNREADABLE.
    .PARAMETER CheckpointText
        The raw parallel checkpoint text, or $null when the file is absent.
    .PARAMETER Slug
        The slug read from the plan branch.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with Allowed, SubCode, and Detail.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $CheckpointText,
        [AllowNull()][AllowEmptyString()][string] $Slug
    )

    $unreadable = [pscustomobject]@{ Allowed = $false; SubCode = 'PARALLEL_RECORDS_CHECKPOINT_UNREADABLE'; Detail = 'the parallel checkpoint is absent, blank, not valid JSON, or not a JSON object.' }
    try {
        if ([string]::IsNullOrWhiteSpace($CheckpointText)) {
            return $unreadable
        }
        try { $checkpoint = ConvertFrom-Json -InputObject $CheckpointText -NoEnumerate -ErrorAction Stop } catch { return $unreadable }
        if ($checkpoint -isnot [System.Management.Automation.PSCustomObject]) {
            return $unreadable
        }
        foreach ($field in @(@{ Name = 'route_id'; Expected = 'parallel' }, @{ Name = 'parallel_slug'; Expected = [string]$Slug })) {
            $value = Get-ParallelRecordsProperty -InputObject $checkpoint -Name $field.Name
            if (-not $value.Present -or $value.Value -isnot [string] -or [string]$value.Value -cne $field.Expected) {
                return [pscustomobject]@{ Allowed = $false; SubCode = 'PARALLEL_RECORDS_SLUG_MISMATCH'; Detail = "$($field.Name) records '$([string]$value.Value)', not '$($field.Expected)'." }
            }
        }
        $closedFailure = Get-ParallelRecordsClosedFailure -Checkpoint $checkpoint
        if ($null -ne $closedFailure) {
            return [pscustomobject]@{ Allowed = $false; SubCode = 'PARALLEL_RECORDS_RUN_NOT_CLOSED'; Detail = $closedFailure }
        }
        $receiptFailure = Get-ParallelRecordsReceiptFailure -Checkpoint $checkpoint
        if ($null -ne $receiptFailure) {
            return [pscustomobject]@{ Allowed = $false; SubCode = $receiptFailure.SubCode; Detail = $receiptFailure.Detail }
        }
        return [pscustomobject]@{ Allowed = $true; SubCode = $null; Detail = '' }
    }
    catch {
        Write-Debug "PARALLEL_RECORDS_DECISION_ERROR: $($_.Exception.Message)"
        return [pscustomobject]@{ Allowed = $false; SubCode = 'PARALLEL_RECORDS_CHECKPOINT_UNREADABLE'; Detail = 'the parallel checkpoint could not be evaluated.' }
    }
}
