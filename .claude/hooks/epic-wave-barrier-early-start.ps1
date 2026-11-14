<#
.SYNOPSIS
    Pure early-start predicates shared by both epic wave-barrier gates (issue #1097).

.DESCRIPTION
    Defines functions only; it dot-sources nothing, imports nothing, and sets no variable at
    script scope. The Claude gate (.claude/hooks/enforce-epic-wave-barrier.ps1) and the Codex
    gate (.codex/hooks/enforce-epic-wave-barrier.ps1) dot-source this file, which is
    byte-identical in both folders. A gate skips the one dependency edge for which
    Test-EpicWaveEarlyStartEdge is true; every deny string of both gates is unchanged.

    The records are features[] entries parsed by ConvertFrom-Json. ConvertFrom-Json turns an
    ISO-8601 string into [datetime], so interface_settled_at is accepted as a non-empty string
    or a [datetime]. Property names are tested with -ccontains, because PSObject.Properties
    ignores case.
#>

function Test-EpicWaveEarlyStartText {
    <#
    .SYNOPSIS
        Returns $true when a value is a string of length above zero (no trimming).
    .PARAMETER Value
        Any value read from a parsed record.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Value)

    return ($Value -is [string] -and $Value.Length -gt 0)
}

function Get-EpicWaveEarlyStartReference {
    <#
    .SYNOPSIS
        Returns the dependency of a feature's valid early_start record, or $null.
    .DESCRIPTION
        The record is valid only when the feature has a property named exactly early_start
        whose value is an object; its dependency is a non-empty string or a number (a boolean
        is invalid); upstream_branch and interface_evidence are non-empty strings; and
        interface_settled_at is a non-empty string or a [datetime]. An invalid record returns
        $null, the same as no key.
    .PARAMETER Feature
        A features[] record parsed by ConvertFrom-Json, or $null.
    .OUTPUTS
        System.Object (a string or a number) or $null
    #>
    [CmdletBinding()]
    [OutputType([string], [long], [double])]
    param([AllowNull()] $Feature)

    if ($null -eq $Feature -or @($Feature.PSObject.Properties.Name) -cnotcontains 'early_start') {
        return $null
    }
    $record = $Feature.PSObject.Properties['early_start'].Value
    if ($record -isnot [System.Management.Automation.PSCustomObject]) {
        return $null
    }
    $names = @($record.PSObject.Properties.Name)
    if ($names -cnotcontains 'dependency' -or $names -cnotcontains 'interface_settled_at') {
        return $null
    }
    $dependency = $record.PSObject.Properties['dependency'].Value
    $isNumber = $dependency -is [int] -or $dependency -is [long] -or $dependency -is [double] -or
    $dependency -is [decimal] -or $dependency -is [System.Numerics.BigInteger]
    if (-not $isNumber -and -not (Test-EpicWaveEarlyStartText -Value $dependency)) {
        return $null
    }
    # Both descriptive text fields must be present under their exact names with usable text.
    foreach ($name in @('upstream_branch', 'interface_evidence')) {
        if ($names -cnotcontains $name -or -not (Test-EpicWaveEarlyStartText -Value $record.PSObject.Properties[$name].Value)) {
            return $null
        }
    }
    $settled = $record.PSObject.Properties['interface_settled_at'].Value
    if ($settled -isnot [datetime] -and -not (Test-EpicWaveEarlyStartText -Value $settled)) {
        return $null
    }
    return $dependency
}

function Test-EpicWaveEarlyStartEdge {
    <#
    .SYNOPSIS
        Returns $true only when a dependency edge is the one a valid early_start record names
        and its upstream has a usable branch.
    .DESCRIPTION
        Both records must be non-null, their feature_folder values non-empty strings that are
        equal (ordinal), and the upstream merge_status one of worktree_created, pr_open,
        ci_green, or merge_conflict. Records are compared by feature_folder, not identity. A
        merged upstream returns $false, so the gate's existing merged check passes the edge.
    .PARAMETER ExemptRecord
        The features[] record the early_start dependency resolves to, or $null.
    .PARAMETER DependencyRecord
        The features[] record of the depends_on edge under evaluation, or $null.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $ExemptRecord, [AllowNull()] $DependencyRecord)

    if ($null -eq $ExemptRecord -or $null -eq $DependencyRecord) {
        return $false
    }
    $exemptFolder = $ExemptRecord.PSObject.Properties['feature_folder']
    $dependencyFolder = $DependencyRecord.PSObject.Properties['feature_folder']
    if ($null -eq $exemptFolder -or $null -eq $dependencyFolder -or
        -not (Test-EpicWaveEarlyStartText -Value $exemptFolder.Value) -or
        -not [string]::Equals($exemptFolder.Value, $dependencyFolder.Value, [System.StringComparison]::Ordinal)) {
        return $false
    }
    $status = $DependencyRecord.PSObject.Properties['merge_status']
    $usable = @('worktree_created', 'pr_open', 'ci_green', 'merge_conflict')
    return ($null -ne $status -and $status.Value -is [string] -and $usable -ccontains $status.Value)
}
