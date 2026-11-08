<#
.SYNOPSIS
    Shared early-start rows for the Claude and Codex epic wave-barrier gate suites (issue #1097).

.DESCRIPTION
    Get-EpicWaveEarlyStartCase returns one row per case: Name, the epic checkpoint JSON text,
    and the expected decision ('allow' or 'deny'). Each checkpoint holds the upstream feature
    2026-11-08-upstream-901 (issue 901), the dependent 2026-11-08-dependent-902 (issue 902),
    and, where a row needs it, 2026-11-08-other-903 (issue 903). The text is produced by
    ConvertTo-Json so the gates read it through their own ConvertFrom-Json parse. The default
    record carries an ISO-8601 interface_settled_at, which ConvertFrom-Json turns into a
    [datetime]. Pure: no file, clock, process, or network is touched.
#>

function Get-EpicWaveEarlyStartRecord {
    <#
    .SYNOPSIS
        Returns a valid early_start record, with the named fields replaced or removed.
    .PARAMETER Override
        Field values to set; a value equal to the string '<remove>' removes the field.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([hashtable] $Override = @{})

    $record = [ordered]@{
        dependency           = 901
        upstream_branch      = 'feature/upstream-901'
        interface_settled_at = '2026-11-08T09:30:00Z'
        interface_evidence   = 'docs/features/active/2026-11-08-upstream-901/evidence/other/interface-settled.2026-11-08T09-30.md'
    }
    foreach ($key in $Override.Keys) {
        if ($Override[$key] -is [string] -and $Override[$key] -ceq '<remove>') { $record.Remove($key) }
        else { $record[$key] = $Override[$key] }
    }
    return $record
}

function ConvertTo-EpicWaveEarlyStartCheckpoint {
    <#
    .SYNOPSIS
        Returns the checkpoint JSON text for an upstream status, a dependent, and optional extras.
    .PARAMETER UpstreamStatus
        The upstream merge_status, or '<remove>' to omit it.
    .PARAMETER Dependent
        Extra or replacement fields of the dependent feature record.
    .PARAMETER Other
        The merge_status of feature 903, or $null to omit that feature.
    .PARAMETER OmitUpstream
        Omit the upstream feature record entirely.
    .PARAMETER CaseVariantKey
        Store the dependent's record under Early_Start instead of early_start. Ordered
        dictionaries ignore key case, so the rename is a remove followed by an add.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string] $UpstreamStatus = 'pr_open',
        [hashtable] $Dependent = @{},
        [AllowNull()] [string] $Other = $null,
        [switch] $OmitUpstream,
        [switch] $CaseVariantKey
    )

    $upstream = [ordered]@{ feature_folder = '2026-11-08-upstream-901'; issue_num = 901; depends_on = @(); merge_status = $UpstreamStatus }
    if ($UpstreamStatus -ceq '<remove>') { $upstream.Remove('merge_status') }
    $dependentRecord = [ordered]@{ feature_folder = '2026-11-08-dependent-902'; issue_num = 902; depends_on = @(901); merge_status = 'not_started'; early_start = (Get-EpicWaveEarlyStartRecord) }
    foreach ($key in $Dependent.Keys) {
        if ($Dependent[$key] -is [string] -and $Dependent[$key] -ceq '<remove>') { $dependentRecord.Remove($key) }
        else { $dependentRecord[$key] = $Dependent[$key] }
    }
    if ($CaseVariantKey) {
        $record = $dependentRecord['early_start']
        $dependentRecord.Remove('early_start')
        $dependentRecord['Early_Start'] = $record
    }
    $features = [System.Collections.Generic.List[object]]::new()
    if (-not $OmitUpstream) { $features.Add($upstream) }
    if (-not [string]::IsNullOrEmpty($Other)) {
        $features.Add([ordered]@{ feature_folder = '2026-11-08-other-903'; issue_num = 903; depends_on = @(); merge_status = $Other })
    }
    $features.Add($dependentRecord)
    return (ConvertTo-Json -InputObject ([ordered]@{ route_id = 'epic'; features = $features.ToArray() }) -Depth 8 -Compress)
}

function Get-EpicWaveEarlyStartCase {
    <#
    .SYNOPSIS
        Returns the shared early-start rows: Name, Json, and Expected ('allow' or 'deny').
    .OUTPUTS
        System.Object[] (one hashtable per row)
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param()

    $both = @(901, 903)
    return @(
        @{ Name = 'no-key-unmerged'; Expected = 'deny'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -Dependent @{ early_start = '<remove>' }) }
        @{ Name = 'no-key-merged'; Expected = 'allow'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -UpstreamStatus 'merged' -Dependent @{ early_start = '<remove>' }) }
        @{ Name = 'no-key-no-depends-on'; Expected = 'allow'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -Dependent @{ early_start = '<remove>'; depends_on = '<remove>' }) }
        @{ Name = 'valid-upstream-worktree-created'; Expected = 'allow'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -UpstreamStatus 'worktree_created') }
        @{ Name = 'valid-upstream-pr-open'; Expected = 'allow'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -UpstreamStatus 'pr_open') }
        @{ Name = 'valid-upstream-ci-green'; Expected = 'allow'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -UpstreamStatus 'ci_green') }
        @{ Name = 'valid-upstream-merge-conflict'; Expected = 'allow'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -UpstreamStatus 'merge_conflict') }
        @{ Name = 'valid-upstream-merged'; Expected = 'allow'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -UpstreamStatus 'merged') }
        @{ Name = 'settled-at-plain-string'; Expected = 'allow'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -Dependent @{ early_start = (Get-EpicWaveEarlyStartRecord -Override @{ interface_settled_at = 'settled after review' }) }) }
        @{ Name = 'other-dependency-unmerged'; Expected = 'deny'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -Other 'pr_open' -Dependent @{ depends_on = $both }) }
        @{ Name = 'other-dependency-merged'; Expected = 'allow'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -Other 'merged' -Dependent @{ depends_on = $both }) }
        @{ Name = 'key-names-non-dependency'; Expected = 'deny'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -Other 'pr_open' -Dependent @{ early_start = (Get-EpicWaveEarlyStartRecord -Override @{ dependency = 903 }) }) }
        @{ Name = 'upstream-not-started'; Expected = 'deny'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -UpstreamStatus 'not_started') }
        @{ Name = 'upstream-blocked'; Expected = 'deny'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -UpstreamStatus 'blocked_conflict_loop_limit') }
        @{ Name = 'upstream-status-absent'; Expected = 'deny'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -UpstreamStatus '<remove>') }
        @{ Name = 'upstream-record-missing'; Expected = 'deny'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -OmitUpstream) }
        @{ Name = 'value-null'; Expected = 'deny'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -Dependent @{ early_start = $null }) }
        @{ Name = 'value-string'; Expected = 'deny'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -Dependent @{ early_start = '901' }) }
        @{ Name = 'empty-upstream-branch'; Expected = 'deny'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -Dependent @{ early_start = (Get-EpicWaveEarlyStartRecord -Override @{ upstream_branch = '' }) }) }
        @{ Name = 'missing-interface-evidence'; Expected = 'deny'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -Dependent @{ early_start = (Get-EpicWaveEarlyStartRecord -Override @{ interface_evidence = '<remove>' }) }) }
        @{ Name = 'missing-interface-settled-at'; Expected = 'deny'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -Dependent @{ early_start = (Get-EpicWaveEarlyStartRecord -Override @{ interface_settled_at = '<remove>' }) }) }
        @{ Name = 'empty-interface-settled-at'; Expected = 'deny'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -Dependent @{ early_start = (Get-EpicWaveEarlyStartRecord -Override @{ interface_settled_at = '' }) }) }
        @{ Name = 'numeric-interface-settled-at'; Expected = 'deny'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -Dependent @{ early_start = (Get-EpicWaveEarlyStartRecord -Override @{ interface_settled_at = 5 }) }) }
        @{ Name = 'case-variant-key'; Expected = 'deny'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -CaseVariantKey) }
        @{ Name = 'boolean-dependency'; Expected = 'deny'; Json = (ConvertTo-EpicWaveEarlyStartCheckpoint -Dependent @{ early_start = (Get-EpicWaveEarlyStartRecord -Override @{ dependency = $true }) }) }
    )
}
