<#
.SYNOPSIS
    Reader for an item's optional access lists during drift detection (issue #1164).

.DESCRIPTION
    PowerShell port of item_access in scripts/dev_tools/_parallel_drift_scheduling.py.
    An item record may carry read_paths and separable_paths beside its
    blast_radius block. Drift detection reports an observed write to a
    read-declared path as an escape (spec B5.5) and passes each peer's lists
    into the pair weight when it re-evaluates the peer (spec B5.6).

    A list that is absent, or that is not a list of non-empty strings, reads as
    empty: the validators report the malformed value, and an empty list removes
    a cost reduction, which is the fail-closed direction. The function is pure:
    no filesystem, subprocess, network, or clock access, and no input is mutated.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# The two optional access lists, recorded beside an item's blast_radius block.
$script:AccessListName = @('read_paths', 'separable_paths')

function Get-ParallelDriftAccessList {
    <#
    .SYNOPSIS
        Return an item's read_paths and separable_paths, empty when absent or malformed.
    .PARAMETER Item
        The item record, or null for an absent item.
    .OUTPUTS
        System.Collections.Hashtable. Keys read_paths and separable_paths, each a
        string array.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([AllowNull()][object] $Item)

    $access = @{}
    foreach ($name in $script:AccessListName) {
        $access[$name] = [string[]]@()
        if ($Item -isnot [System.Collections.IDictionary] -or -not $Item.Contains($name)) { continue }
        $value = $Item[$name]
        # A string is IEnumerable but is not a list; it is malformed like any other scalar.
        if ($value -is [string] -or $value -isnot [System.Collections.IList]) { continue }
        $entries = @($value)
        $valid = @($entries | Where-Object { $_ -is [string] -and $_.Length -gt 0 }).Count -eq $entries.Count
        if ($valid) { $access[$name] = [string[]]$entries }
    }
    return $access
}

Export-ModuleMember -Function Get-ParallelDriftAccessList
