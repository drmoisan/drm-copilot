<#
.SYNOPSIS
    The bind-page-refs update-ledger operation of issue #1173 (B2.4): page reference collection
    from front-matter surface_refs and the pure ledger binding.

.DESCRIPTION
    Get-DocsLedgerPageReference reads each Markdown page of the page-path set through the ReadText
    scriptblock (Context.ReadText), parses its front matter with ConvertFrom-DocsPageFrontMatter of
    DocsPageFrontMatter.psm1, and maps every surface_refs id to the sorted pages that reference it.
    A page that is not Markdown, has no front matter, fails to parse or has no surface_refs list
    contributes nothing.

    Update-DocsLedgerPageBinding binds each referenced element that is in the snapshot (or only
    the element named by ElementId) as documented, with page bindings equal to the union of its
    existing bindings (anchors kept) and one unanchored binding per referencing page not yet
    bound. No binding is removed. An element already documented with every referencing page is
    left unchanged, so a second application gives the same bytes. The rationale, owner and
    target of an entry that was documented are kept; an excluded or deferred entry becomes a
    documented entry without them. Precision-limit entries are never bound.

    Get-DocsLedgerPageReferenceWarning returns one DOCS_LEDGER_BIND_REF_UNKNOWN warning for each
    surface_refs id that is not an element of the snapshot; such an id changes nothing.

    sync-refs is a different operation: it refreshes the snapshot and ledger pins, while
    bind-page-refs creates documented dispositions and page bindings from surface_refs.

.NOTES
    Issue #1173. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageFrontMatter.psm1') -ErrorAction Stop

function Get-DocsLedgerBindRefsMember {
    <#
    .SYNOPSIS
        Returns a dictionary member, or $null when the key is absent (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [AllowNull()] [object] $Table,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    if ($Table -is [System.Collections.IDictionary] -and $Table.Contains($Name)) { return $Table[$Name] }
    return $null
}

function Get-DocsLedgerPageReference {
    <#
    .SYNOPSIS
        Returns an ordinal hashtable from each front-matter surface_refs id to the sorted pages that reference it.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Element ids are case-sensitive; an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowNull()] [string[]] $PagePath,
        [Parameter(Mandatory = $true)] [scriptblock] $ReadText
    )

    $sets = [System.Collections.Generic.SortedDictionary[string, System.Collections.Generic.SortedSet[string]]]::new([System.StringComparer]::Ordinal)
    foreach ($page in @($PagePath)) {
        if ([string]::IsNullOrEmpty($page) -or -not $page.EndsWith('.md', [System.StringComparison]::Ordinal)) { continue }
        $parsed = ConvertFrom-DocsPageFrontMatter -Text ([string] (& $ReadText $page)) -PagePath $page
        # Read directly: returning the list from a helper would unroll a one-item list into a string.
        if ($parsed.Value -isnot [System.Collections.IDictionary] -or -not $parsed.Value.Contains('surface_refs')) { continue }
        $refs = $parsed.Value['surface_refs']
        if ($refs -isnot [System.Array]) { continue }
        foreach ($id in $refs) {
            if ($id -isnot [string] -or $id.Length -eq 0) { continue }
            if (-not $sets.ContainsKey($id)) { $sets[$id] = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal) }
            [void] $sets[$id].Add($page)
        }
    }
    $reference = [hashtable]::new([System.StringComparer]::Ordinal)
    foreach ($id in $sets.Keys) { $reference[$id] = [string[]] @($sets[$id]) }
    return $reference
}

function Get-DocsLedgerPageReferenceWarning {
    <#
    .SYNOPSIS
        Returns one DOCS_LEDGER_BIND_REF_UNKNOWN warning per surface_refs id that is not a snapshot element.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Reference,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $View
    )

    $warnings = [System.Collections.Generic.List[object]]::new()
    foreach ($id in @($Reference.Keys | Sort-Object -CaseSensitive)) {
        if ($View.Element.Contains([string] $id)) { continue }
        $warnings.Add((New-DocsFinding -Code 'DOCS_LEDGER_BIND_REF_UNKNOWN' -Severity 'warning' -Message "The surface_refs id $id is not an element of the current snapshot; no binding was made." -NextAction 'Correct the surface_refs entry of the page, or regenerate the inventory snapshot.' -RelatedPath ([string[]] $Reference[$id])))
    }
    return $warnings.ToArray()
}

function Update-DocsLedgerPageBinding {
    <#
    .SYNOPSIS
        Returns the ledger with each referenced snapshot element bound as documented to the union of its pages.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory transform that returns a new ledger and changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.IDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Ledger,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $View,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Reference,
        [AllowNull()] [AllowEmptyString()] [string] $ElementId,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Actor
    )

    $targets = if ([string]::IsNullOrEmpty($ElementId)) { [string[]] @($Reference.Keys | Sort-Object -CaseSensitive) } else { [string[]] @($ElementId) }
    $result = $Ledger
    foreach ($id in $targets) {
        if (-not $Reference.Contains($id) -or -not $View.Element.Contains($id)) { continue }
        $current = @(@(Get-DocsLedgerBindRefsMember -Table $result -Name 'entries') | Where-Object {
                [string] (Get-DocsLedgerBindRefsMember -Table $_ -Name 'element_id') -ceq $id -and $null -eq (Get-DocsLedgerBindRefsMember -Table (Get-DocsLedgerBindRefsMember -Table $_ -Name 'extensions') -Name 'docs.precision-limit')
            })
        $entry = if ($current.Count -gt 0) { $current[0] } else { $null }
        $documented = $null -ne $entry -and [string] (Get-DocsLedgerBindRefsMember -Table $entry -Name 'disposition') -ceq 'documented'
        $bindings = [System.Collections.Generic.List[object]]::new()
        $bound = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        foreach ($binding in @(Get-DocsLedgerBindRefsMember -Table $entry -Name 'page_bindings')) {
            if ($null -eq $binding) { continue }
            $bindings.Add(@{ page_path = [string] $binding['page_path']; anchor = $binding['anchor'] })
            [void] $bound.Add([string] $binding['page_path'])
        }
        $added = @($Reference[$id] | Where-Object { -not $bound.Contains([string] $_) })
        if ($documented -and $added.Count -eq 0) { continue }
        foreach ($page in $added) { $bindings.Add(@{ page_path = [string] $page; anchor = $null }) }
        $kept = if ($documented) { $entry } else { $null }
        $replacement = New-DocsLedgerEntry -Element $View.Element[$id] -Disposition 'documented' -PageBinding $bindings.ToArray() -Rationale (Get-DocsLedgerBindRefsMember -Table $kept -Name 'rationale') -Owner (Get-DocsLedgerBindRefsMember -Table $kept -Name 'owner') -Target (Get-DocsLedgerBindRefsMember -Table $kept -Name 'target') -Actor $Actor
        $result = Merge-DocsLedgerEntry -Ledger $result -Entry $replacement
    }
    return $result
}

Export-ModuleMember -Function Get-DocsLedgerPageReference, Get-DocsLedgerPageReferenceWarning, Update-DocsLedgerPageBinding
