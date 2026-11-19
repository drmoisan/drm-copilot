Set-StrictMode -Version Latest

# Hook parity rules (issue #1030): pure functions over parity-matrix hook-registration entries. They read
# no file and no network; the caller loads the matrix (Import-HarnessParityMatrix) and passes the entries.
# Rules: H1 a Claude group without a Codex member carries a gap class on every Claude member; H2 a Codex
# group without a Claude member carries CODEX-NATIVE on every Codex member; H3 every entry is native and a
# provisional entry names the decision reference; H4 Copilot entries belong to child 6; H5 a Claude entry
# whose stem is in the deferred set carries DEFER.

$script:HarnessHookGapPrefix = [ordered]@{
    'GAP:NOT-APPLICABLE: '  = 'NOT-APPLICABLE'
    'GAP:NOT-EXPRESSIBLE: ' = 'NOT-EXPRESSIBLE'
    'GAP:DEFER: '           = 'DEFER'
    'CODEX-NATIVE: '        = 'CODEX-NATIVE'
}

function Get-HarnessHookEntryField {
    <#
    .SYNOPSIS
        Returns the string value of one entry property, or an empty string when the property is absent.
    .PARAMETER Entry
        The matrix entry.
    .PARAMETER Name
        The property name.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)] $Entry, [Parameter(Mandatory)][string] $Name)
    if (@($Entry.PSObject.Properties.Name) -notcontains $Name) { return '' }
    return [string]$Entry.$Name
}

function Get-HarnessHookRegistrationStem {
    <#
    .SYNOPSIS
        Returns the command stem of a hook-registration entry: the text after the last '/' of its name.
    .DESCRIPTION
        The stem is read from name, never from id, so an opaque id does not change the result. A matcher
        that contains '/' does not change the result either, because the stem is the last component.
    .PARAMETER Entry
        The matrix entry.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)] $Entry)
    $name = Get-HarnessHookEntryField -Entry $Entry -Name 'name'
    return $name.Substring($name.LastIndexOf('/') + 1)
}

function Get-HarnessHookGapClass {
    <#
    .SYNOPSIS
        Returns the gap class and reason recorded in an entry's notes, or $null when notes carry no gap prefix.
    .DESCRIPTION
        Recognized prefixes are 'GAP:NOT-APPLICABLE: ', 'GAP:NOT-EXPRESSIBLE: ', 'GAP:DEFER: ' and
        'CODEX-NATIVE: ' (ordinal). A recognized prefix followed by an empty or blank reason, and a notes
        value that starts with 'GAP:' but carries no recognized class, return Class INVALID.
    .PARAMETER Entry
        The matrix entry.
    .OUTPUTS
        PSCustomObject with Class and Reason, or $null.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)] $Entry)
    $notes = Get-HarnessHookEntryField -Entry $Entry -Name 'notes'
    foreach ($prefix in $script:HarnessHookGapPrefix.Keys) {
        if ($notes.StartsWith($prefix, [System.StringComparison]::Ordinal)) {
            $reason = $notes.Substring($prefix.Length)
            if ([string]::IsNullOrWhiteSpace($reason)) { return [pscustomobject]@{ Class = 'INVALID'; Reason = $reason } }
            return [pscustomobject]@{ Class = $script:HarnessHookGapPrefix[$prefix]; Reason = $reason }
        }
    }
    if ($notes.StartsWith('GAP:', [System.StringComparison]::Ordinal)) { return [pscustomobject]@{ Class = 'INVALID'; Reason = $notes } }
    return $null
}

function Get-HarnessHookParityViolation {
    <#
    .SYNOPSIS
        Returns the H1 to H5 violations of a set of matrix entries; only hook-registration entries are judged.
    .PARAMETER Entry
        The matrix entries (other kinds are ignored).
    .PARAMETER DeferStem
        Claude command stems whose entries must carry the DEFER gap class (H5).
    .PARAMETER DecisionRef
        The decision reference every provisional entry must name (H3).
    .OUTPUTS
        PSCustomObject per violation with Rule, Subject and Message.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]] $Entry,
        [AllowEmptyCollection()][string[]] $DeferStem = @(),
        [Parameter(Mandatory)][string] $DecisionRef
    )
    $hooks = @($Entry | Where-Object { (Get-HarnessHookEntryField -Entry $_ -Name 'kind') -ceq 'hook-registration' })
    $found = [System.Collections.Generic.List[object]]::new()
    $add = { param([string] $Rule, $Item, [string] $Detail) $found.Add([pscustomobject]@{ Rule = $Rule; Subject = (Get-HarnessHookEntryField -Entry $Item -Name 'name'); Message = "[$Rule] $(Get-HarnessHookEntryField -Entry $Item -Name 'ecosystem') $(Get-HarnessHookEntryField -Entry $Item -Name 'name'): $Detail" }) }
    # Group membership decides H1 and H2: a group is judged by which ecosystems it holds.
    foreach ($group in @($hooks | Group-Object { Get-HarnessHookEntryField -Entry $_ -Name 'parity_group' })) {
        $members = @($group.Group)
        $claude = @($members | Where-Object { (Get-HarnessHookEntryField -Entry $_ -Name 'ecosystem') -ceq 'claude' })
        $codex = @($members | Where-Object { (Get-HarnessHookEntryField -Entry $_ -Name 'ecosystem') -ceq 'codex' })
        if ($claude.Count -gt 0 -and $codex.Count -eq 0) {
            foreach ($item in $claude) {
                $gap = Get-HarnessHookGapClass -Entry $item
                if ($null -eq $gap -or @('NOT-APPLICABLE', 'NOT-EXPRESSIBLE', 'DEFER') -cnotcontains $gap.Class) { & $add 'H1' $item "group '$($group.Name)' has no codex member and the entry carries no gap class" }
            }
        }
        if ($codex.Count -gt 0 -and $claude.Count -eq 0) {
            foreach ($item in $codex) {
                $gap = Get-HarnessHookGapClass -Entry $item
                if ($null -eq $gap -or $gap.Class -cne 'CODEX-NATIVE') { & $add 'H2' $item "group '$($group.Name)' has no claude member and the entry carries no CODEX-NATIVE note" }
            }
        }
    }
    # Per-entry rules H3 to H5.
    foreach ($item in $hooks) {
        if ((Get-HarnessHookEntryField -Entry $item -Name 'disposition') -cne 'native') { & $add 'H3' $item 'disposition is not native' }
        if ((Get-HarnessHookEntryField -Entry $item -Name 'decision_status') -ceq 'provisional' -and (Get-HarnessHookEntryField -Entry $item -Name 'decision_ref') -cne $DecisionRef) { & $add 'H3' $item "provisional entry does not name decision_ref '$DecisionRef'" }
        $ecosystem = Get-HarnessHookEntryField -Entry $item -Name 'ecosystem'
        if ($ecosystem -ceq 'copilot' -and (Get-HarnessHookEntryField -Entry $item -Name 'owner_child') -cne '6') { & $add 'H4' $item 'copilot entry does not have owner_child 6' }
        if ($ecosystem -ceq 'claude' -and $DeferStem -ccontains (Get-HarnessHookRegistrationStem -Entry $item)) {
            $gap = Get-HarnessHookGapClass -Entry $item
            if ($null -eq $gap -or $gap.Class -cne 'DEFER') { & $add 'H5' $item 'deferred stem does not carry the DEFER gap class' }
        }
    }
    return $found.ToArray()
}

Export-ModuleMember -Function Get-HarnessHookRegistrationStem, Get-HarnessHookGapClass, Get-HarnessHookParityViolation
