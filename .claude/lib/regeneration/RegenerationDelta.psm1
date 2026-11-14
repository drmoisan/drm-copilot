<#
.SYNOPSIS
    Confinement, idempotency, and delta decisions plus the record builders of the regenerate path.

.DESCRIPTION
    Pure functions for issue #1156. The decisions judge the output of the declared
    regeneration command (confinement and idempotency) and the staged merge result
    against both reviewed parents (delta verification). The builders produce the
    regeneration_events[] entry, the delta review outcome, the
    integration_regenerations[] entry, the evidence text, the invocation text,
    and the evidence path, each taking every value, including the timestamp, as an
    argument.

    Every function is pure: no filesystem, process, network, or clock access.
    The module imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'RegenerationClassifier.psm1') -Force -ErrorAction Stop

$script:EventTrigger = @('integration_sync', 'main_sync')
$script:EventOutcome = @('regenerated', 'fell_back')
$script:GateValue = @('pass', 'fail', 'not_run')
$script:EntryTrigger = @('post_feature_merge', 'main_sync')
$script:EntryOutcome = @('applied', 'not_applied')
$script:InvocationPrefix = 'pwsh -NoProfile -File .claude/lib/regeneration/Invoke-RegenerationPath.ps1 -Mode Merge'

function Assert-RegenerationEnumValue {
    <#
    .SYNOPSIS
        Throw when a value is not one of the allowed ordinal values.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $Name,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $Value,
        [Parameter(Mandatory = $true)] [string[]] $Allowed
    )

    if ($Allowed -cnotcontains $Value) {
        throw "$Name '$Value' is not one of: $($Allowed -join ', ')"
    }
}

function Get-RegenerationConfinementDecision {
    <#
    .SYNOPSIS
        Report whether every path the command changed matches a declared pattern.

    .PARAMETER ChangedPath
        C1: the union of unstaged changes and untracked files after run 1.

    .PARAMETER Pattern
        Declared path patterns.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $ChangedPath,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Pattern
    )

    foreach ($path in $ChangedPath) {
        if (-not (Test-RegenerationPathMatch -Path $path -Pattern $Pattern)) { return $false }
    }
    return $true
}

function Test-RegenerationSnapshotEqual {
    <#
    .SYNOPSIS
        Report whether two path-to-blob snapshots hold the same paths and blob ids.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $First,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Second
    )

    if ($First.Count -ne $Second.Count) { return $false }
    foreach ($key in $First.Keys) {
        if (-not $Second.Contains($key)) { return $false }
        if ([string] $First[$key] -cne [string] $Second[$key]) { return $false }
    }
    return $true
}

function Get-RegenerationIdempotencyDecision {
    <#
    .SYNOPSIS
        Report whether the second command run changed nothing further.

    .DESCRIPTION
        Merge mode: idempotent when C2 (unstaged plus untracked after run 2) is
        empty and the idempotency check, when declared, exited 0. Tip mode:
        idempotent when the changed-path set and every blob id after run 2 equal
        the run-1 snapshot and the check, when declared, exited 0. CheckExitCode is
        $null when idempotency_check is not declared.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Merge')]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Merge')]
        [AllowEmptyCollection()]
        [string[]] $SecondRunChange,
        [Parameter(Mandatory = $true, ParameterSetName = 'Tip')]
        [System.Collections.IDictionary] $FirstSnapshot,
        [Parameter(Mandatory = $true, ParameterSetName = 'Tip')]
        [System.Collections.IDictionary] $SecondSnapshot,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object] $CheckExitCode
    )

    if ($null -ne $CheckExitCode -and [int] $CheckExitCode -ne 0) { return $false }
    if ($PSCmdlet.ParameterSetName -eq 'Merge') { return ($SecondRunChange.Count -eq 0) }
    return (Test-RegenerationSnapshotEqual -First $FirstSnapshot -Second $SecondSnapshot)
}

function Get-RegenerationDeltaDecision {
    <#
    .SYNOPSIS
        Verify the staged result against both reviewed parents.

    .DESCRIPTION
        Every non-generated path in the staged diff against the feature head must
        be in diff(B, incoming tip), and every non-generated path in the staged
        diff against the incoming tip must be in diff(B, feature head). Returns
        pass when both relations hold and fail otherwise.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $StagedAgainstFeatureHead,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $StagedAgainstIncomingTip,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $BaseToFeatureHead,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $BaseToIncomingTip,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Pattern
    )

    foreach ($path in $StagedAgainstFeatureHead) {
        if ((Test-RegenerationPathMatch -Path $path -Pattern $Pattern)) { continue }
        if ($BaseToIncomingTip -cnotcontains $path) { return 'fail' }
    }
    foreach ($path in $StagedAgainstIncomingTip) {
        if ((Test-RegenerationPathMatch -Path $path -Pattern $Pattern)) { continue }
        if ($BaseToFeatureHead -cnotcontains $path) { return 'fail' }
    }
    return 'pass'
}

function New-RegenerationEvent {
    <#
    .SYNOPSIS
        Build one regeneration_events[] entry.

    .DESCRIPTION
        Every key is taken from the parameter of the same name; classifier is
        built from Decision, Reason, and UnmatchedPaths. head_sha is $null unless
        outcome is regenerated.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory builder that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $At,
        [Parameter(Mandatory = $true)] [string] $Trigger,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $FeatureHeadSha,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $MergeHeadSha,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $MergeBaseSha,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $Decision,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $Reason,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $UnmatchedPaths,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $CommandExitCode,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Confined,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Idempotent,
        [Parameter(Mandatory = $true)] [string] $UnitGate,
        [Parameter(Mandatory = $true)] [string] $DeltaCheck,
        [Parameter(Mandatory = $true)] [string] $Outcome,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $HeadSha,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $EvidencePath
    )

    Assert-RegenerationEnumValue -Name 'trigger' -Value $Trigger -Allowed $script:EventTrigger
    Assert-RegenerationEnumValue -Name 'outcome' -Value $Outcome -Allowed $script:EventOutcome
    Assert-RegenerationEnumValue -Name 'unit_gate' -Value $UnitGate -Allowed $script:GateValue
    Assert-RegenerationEnumValue -Name 'delta_check' -Value $DeltaCheck -Allowed $script:GateValue

    $classifier = [ordered]@{
        decision        = ConvertTo-RegenerationNullableString -Value $Decision
        reason          = ConvertTo-RegenerationNullableString -Value $Reason
        unmatched_paths = [string[]] @($UnmatchedPaths)
    }
    $headValue = if ($Outcome -ceq 'regenerated') { ConvertTo-RegenerationNullableString -Value $HeadSha } else { $null }
    return [ordered]@{
        at                = ConvertTo-RegenerationNullableString -Value $At
        trigger           = $Trigger
        feature_head_sha  = ConvertTo-RegenerationNullableString -Value $FeatureHeadSha
        merge_head_sha    = ConvertTo-RegenerationNullableString -Value $MergeHeadSha
        merge_base_sha    = ConvertTo-RegenerationNullableString -Value $MergeBaseSha
        classifier        = $classifier
        command_exit_code = $CommandExitCode
        confined          = $Confined
        idempotent        = $Idempotent
        unit_gate         = $UnitGate
        delta_check       = $DeltaCheck
        head_sha          = $headValue
        evidence_path     = ConvertTo-RegenerationNullableString -Value $EvidencePath
        outcome           = $Outcome
    }
}

function ConvertTo-RegenerationNullableString {
    <#
    .SYNOPSIS
        Map an empty string (the binding of a $null string argument) back to $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $Value
    )

    if ([string]::IsNullOrEmpty($Value)) { return $null }
    return $Value
}

function New-RegenerationDeltaReviewOutcome {
    <#
    .SYNOPSIS
        Build the remediation_loop.review_outcomes[] entry of a completed regenerate path.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory builder that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $HeadSha,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $EvidencePath
    )

    return [ordered]@{
        verdict       = 'PASS'
        findings      = [object[]] @()
        head_sha      = ConvertTo-RegenerationNullableString -Value $HeadSha
        review_kind   = 'regeneration_delta'
        evidence_path = ConvertTo-RegenerationNullableString -Value $EvidencePath
    }
}

function New-IntegrationRegenerationEntry {
    <#
    .SYNOPSIS
        Build one integration_regenerations[] entry of the epic checkpoint.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory builder that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Trigger,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $AfterFeatureIssueNum,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $MergeCommitSha,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $RegenerationCommitSha,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $CommandExitCode,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Confined,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Idempotent,
        [Parameter(Mandatory = $true)] [string] $Outcome,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $CiRunId,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $CiConclusion,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $VerifiedAt
    )

    Assert-RegenerationEnumValue -Name 'trigger' -Value $Trigger -Allowed $script:EntryTrigger
    Assert-RegenerationEnumValue -Name 'outcome' -Value $Outcome -Allowed $script:EntryOutcome

    $issueValue = if ($Trigger -ceq 'main_sync') { $null } else { $AfterFeatureIssueNum }
    return [ordered]@{
        trigger                 = $Trigger
        after_feature_issue_num = $issueValue
        merge_commit_sha        = ConvertTo-RegenerationNullableString -Value $MergeCommitSha
        regeneration_commit_sha = ConvertTo-RegenerationNullableString -Value $RegenerationCommitSha
        command_exit_code       = $CommandExitCode
        confined                = $Confined
        idempotent              = $Idempotent
        outcome                 = $Outcome
        ci_run_id               = $CiRunId
        ci_conclusion           = ConvertTo-RegenerationNullableString -Value $CiConclusion
        verified_at             = ConvertTo-RegenerationNullableString -Value $VerifiedAt
    }
}

function ConvertTo-RegenerationBooleanText {
    <#
    .SYNOPSIS
        Render a boolean as the lowercase JSON literal.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowNull()] [object] $Value)

    if ($null -eq $Value) { return 'null' }
    if ([bool] $Value) { return 'true' }
    return 'false'
}

function New-RegenerationEvidenceText {
    <#
    .SYNOPSIS
        Build the five LF-terminated lines of the regeneration-delta evidence file.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory builder that changes no system state.')]
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $Timestamp,
        [Parameter(Mandatory = $true)] [string] $Command,
        [Parameter(Mandatory = $true)] [int] $ExitCode,
        [Parameter(Mandatory = $true)] [string] $Reason,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Confined,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Idempotent,
        [Parameter(Mandatory = $true)] [string] $UnitGate,
        [Parameter(Mandatory = $true)] [string] $DeltaCheck
    )

    $summary = 'reason={0}; confined={1}; idempotent={2}; unit_gate={3}; delta_check={4}' -f $Reason,
    (ConvertTo-RegenerationBooleanText -Value $Confined), (ConvertTo-RegenerationBooleanText -Value $Idempotent), $UnitGate, $DeltaCheck
    $lines = @(
        '# Regeneration Delta'
        "Timestamp: $Timestamp"
        "Command: $Command"
        "EXIT_CODE: $ExitCode"
        "Output Summary: $summary"
    )
    return (($lines -join "`n") + "`n")
}

function Get-RegenerationInvocationText {
    <#
    .SYNOPSIS
        Return the Merge-mode invocation text recorded in the evidence Command line.

    .DESCRIPTION
        The suffix -ConfigPath <value> is appended only when ConfigPath is not
        $null, that is, when the caller bound the parameter.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $MergeRef,
        [Parameter(Mandatory = $true)] [string] $Trigger,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $ConfigPath
    )

    $text = "$script:InvocationPrefix -MergeRef $MergeRef -Trigger $Trigger"
    if ($null -ne $ConfigPath) { $text = "$text -ConfigPath $ConfigPath" }
    return $text
}

function ConvertTo-RegenerationUtcValue {
    <#
    .SYNOPSIS
        Treat a Local value as local time and every other kind as UTC.
    #>
    [CmdletBinding()]
    [OutputType([datetime])]
    param([Parameter(Mandatory = $true)] [datetime] $Value)

    if ($Value.Kind -eq [System.DateTimeKind]::Local) { return $Value.ToUniversalTime() }
    return [datetime]::SpecifyKind($Value, [System.DateTimeKind]::Utc)
}

function ConvertTo-RegenerationIsoUtc {
    <#
    .SYNOPSIS
        Render a clock value as ISO-8601 UTC ending in Z (yyyy-MM-ddTHH:mm:ssZ).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [datetime] $Value)

    $utc = ConvertTo-RegenerationUtcValue -Value $Value
    return $utc.ToString('yyyy-MM-ddTHH:mm:ssZ', [System.Globalization.CultureInfo]::InvariantCulture)
}

function ConvertTo-RegenerationStamp {
    <#
    .SYNOPSIS
        Render a clock value as the evidence stamp shape yyyy-MM-ddTHH-mm.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [datetime] $Value)

    $utc = ConvertTo-RegenerationUtcValue -Value $Value
    return $utc.ToString('yyyy-MM-ddTHH-mm', [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-RegenerationEvidencePath {
    <#
    .SYNOPSIS
        Return the feature-relative path of a regeneration-delta evidence file.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $FeatureFolder,
        [Parameter(Mandatory = $true)] [string] $Timestamp
    )

    if ($Timestamp -cnotmatch '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$') {
        throw "Timestamp '$Timestamp' is not in the yyyy-MM-ddTHH-mm shape"
    }
    $folder = $FeatureFolder.TrimEnd('/')
    return "$folder/evidence/qa-gates/regeneration-delta.$Timestamp.md"
}

Export-ModuleMember -Function Get-RegenerationConfinementDecision, Get-RegenerationIdempotencyDecision,
Get-RegenerationDeltaDecision, New-RegenerationEvent, New-RegenerationDeltaReviewOutcome,
New-IntegrationRegenerationEntry, New-RegenerationEvidenceText, Get-RegenerationInvocationText,
ConvertTo-RegenerationIsoUtc, ConvertTo-RegenerationStamp, Get-RegenerationEvidencePath
