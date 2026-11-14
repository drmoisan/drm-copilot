<#
.SYNOPSIS
    Regeneration consistency check of the merge gate (issue #1156).

.DESCRIPTION
    Dot-sourced by enforce-epic-merge-gate.ps1 in both runtimes; this file is byte-identical in the
    Claude and Codex hook folders. Each gate calls Get-EpicMergeGateRegenerationDecision with the
    per-feature checkpoint it read, only after the review guard returned no denial.

    The check applies only when the last remediation_loop.review_outcomes entry carries review_kind
    exactly regeneration_delta (ordinal). It then requires a top-level regeneration_events entry
    whose head_sha equals that outcome's head_sha and which records outcome regenerated, the JSON
    booleans idempotent true and confined true, unit_gate pass, and delta_check pass. Otherwise it
    denies with EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_REGENERATION_UNVERIFIED: <detail>, where the
    detail names the first failing field. A checkpoint without review_kind on its last outcome,
    including null and malformed input, is never denied, so the check is inert for every checkpoint
    written before the regenerate path existed.

    Limits: this check is a policy-level control, not a security control. A writer in the same
    session can author both the event and the delta outcome; the check proves internal consistency,
    not origin.

.NOTES
    Compatible with PowerShell 7+. This file defines functions only, dot-sources nothing, imports no
    module, and starts no process.
#>

function Get-EpicMergeGateRegenerationMember {
    <#
    .SYNOPSIS
        Return a named member of a parsed JSON object, or $null when absent (pure).
    .DESCRIPTION
        Accepts a PSCustomObject or a dictionary, so the check reads checkpoints parsed with and
        without -AsHashtable. Any other value returns $null. The member name is compared ordinally.
    .PARAMETER InputObject
        The parsed object.
    .PARAMETER Name
        The member name.
    .OUTPUTS
        System.Object or $null
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [AllowNull()] $InputObject,
        [Parameter(Mandatory)][string] $Name
    )

    if ($InputObject -is [System.Collections.IDictionary]) {
        foreach ($key in $InputObject.Keys) {
            if ($key -is [string] -and $key -ceq $Name) { return , $InputObject[$key] }
        }
        return $null
    }
    if ($InputObject -is [System.Management.Automation.PSCustomObject]) {
        foreach ($property in $InputObject.PSObject.Properties) {
            if ($property.Name -ceq $Name) { return , $property.Value }
        }
    }
    return $null
}

function Test-EpicMergeGateRegenerationObject {
    <#
    .SYNOPSIS
        True when a value is a parsed JSON object (PSCustomObject or dictionary) (pure).
    .PARAMETER Value
        The candidate value.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Value)

    return ($Value -is [System.Management.Automation.PSCustomObject]) -or ($Value -is [System.Collections.IDictionary])
}

function Get-EpicMergeGateRegenerationEventFailure {
    <#
    .SYNOPSIS
        Return the name of the first field of an event that fails the check, or $null (pure).
    .DESCRIPTION
        Fields are checked in the order outcome, idempotent, confined, unit_gate, delta_check.
        idempotent and confined must be the JSON boolean true; a string such as true fails.
    .PARAMETER RegenerationEvent
        One regeneration_events entry whose head_sha already matched.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] $RegenerationEvent)

    $outcome = Get-EpicMergeGateRegenerationMember -InputObject $RegenerationEvent -Name 'outcome'
    if ($outcome -isnot [string] -or $outcome -cne 'regenerated') { return 'outcome' }
    foreach ($name in @('idempotent', 'confined')) {
        $flag = Get-EpicMergeGateRegenerationMember -InputObject $RegenerationEvent -Name $name
        if ($flag -isnot [bool] -or -not $flag) { return $name }
    }
    foreach ($name in @('unit_gate', 'delta_check')) {
        $value = Get-EpicMergeGateRegenerationMember -InputObject $RegenerationEvent -Name $name
        if ($value -isnot [string] -or $value -cne 'pass') { return $name }
    }
    return $null
}

function Get-EpicMergeGateRegenerationDecision {
    <#
    .SYNOPSIS
        Evaluate the regeneration consistency check for one checkpoint and return Denied and Reason.
    .DESCRIPTION
        Not denied unless the last remediation_loop.review_outcomes entry carries review_kind exactly
        regeneration_delta. Then denied unless a regeneration_events entry with the same head_sha
        passes every field check. Every deny reason reads
        EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_REGENERATION_UNVERIFIED: <detail>. Runs no process.
    .PARAMETER Checkpoint
        The parsed per-feature checkpoint, or $null.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Denied and Reason.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([AllowNull()] $Checkpoint)

    $pass = [ordered]@{ Denied = $false; Reason = $null }
    $prefix = 'EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_REGENERATION_UNVERIFIED: '

    $loop = Get-EpicMergeGateRegenerationMember -InputObject $Checkpoint -Name 'remediation_loop'
    $outcomes = Get-EpicMergeGateRegenerationMember -InputObject $loop -Name 'review_outcomes'
    if ($outcomes -isnot [System.Collections.IList] -or $outcomes.Count -eq 0) { return $pass }
    $last = $outcomes[$outcomes.Count - 1]
    if (-not (Test-EpicMergeGateRegenerationObject -Value $last)) { return $pass }
    $kind = Get-EpicMergeGateRegenerationMember -InputObject $last -Name 'review_kind'
    if ($kind -isnot [string] -or $kind -cne 'regeneration_delta') { return $pass }

    $headSha = Get-EpicMergeGateRegenerationMember -InputObject $last -Name 'head_sha'
    if ($headSha -isnot [string] -or [string]::IsNullOrWhiteSpace($headSha)) {
        return [ordered]@{ Denied = $true; Reason = $prefix + 'the regeneration_delta review outcome carries no head_sha.' }
    }

    $events = Get-EpicMergeGateRegenerationMember -InputObject $Checkpoint -Name 'regeneration_events'
    if ($events -isnot [System.Collections.IList]) {
        return [ordered]@{ Denied = $true; Reason = $prefix + 'the checkpoint carries no regeneration_events list for the regeneration_delta review outcome.' }
    }

    $failure = $null
    foreach ($candidate in $events) {
        if (-not (Test-EpicMergeGateRegenerationObject -Value $candidate)) { continue }
        $eventHead = Get-EpicMergeGateRegenerationMember -InputObject $candidate -Name 'head_sha'
        if ($eventHead -isnot [string] -or $eventHead -cne $headSha) { continue }
        $field = Get-EpicMergeGateRegenerationEventFailure -RegenerationEvent $candidate
        if ($null -eq $field) { return $pass }
        if ($null -eq $failure) { $failure = $field }
    }

    if ($null -eq $failure) {
        return [ordered]@{ Denied = $true; Reason = $prefix + "no regeneration_events entry has head_sha $headSha." }
    }
    return [ordered]@{ Denied = $true; Reason = $prefix + "the regeneration_events entry with head_sha $headSha fails the $failure check." }
}
