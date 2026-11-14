<#
.SYNOPSIS
    Page planning for the documentation reference generator: snapshot conversion, path coverage,
    the reference output directory, the family page paths and the per-page element plan.

.DESCRIPTION
    ConvertFrom-DocsReferenceSnapshotText validates a surface inventory snapshot against its
    composed schema, rebuilds every element with ConvertFrom-DocsSurfaceElement and sorts the
    elements by element_id. Test-DocsReferencePathCovered applies the profile path_or_glob rule:
    equality, a prefix followed by '/', or an anchored case-sensitive glob in which '*' becomes
    '.*', '?' becomes '.', '[...]' becomes a character class with a leading '!' mapped to '^',
    and every other character is escaped.

    Get-DocsReferencePagePlan assigns rendered elements to the four fixed family pages, orders
    them per page, and resolves the directory mode, owner, documentation root and audience of
    every planned page. Owner and audience are carried as plan values; the findings for an
    unresolved owner or a missing audience are decided with the existing front matter.

    Every comparison is ordinal and every match case-sensitive. Every function is pure: no
    filesystem, clock, process, environment or module-scope mutable state; inputs are not
    mutated.

.NOTES
    Issue #1024. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSchema.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

function Get-DocsReferenceFamily {
    <#
    .SYNOPSIS
        Returns the fixed family table: file name, title and element kinds per page (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param()

    return , [object[]]@(
        [ordered]@{ FileName = 'api-reference.md'; Title = 'API reference'; Kind = [string[]]@('public-symbol') }
        [ordered]@{ FileName = 'cli-reference.md'; Title = 'CLI reference'; Kind = [string[]]@('cli-command', 'cli-option') }
        [ordered]@{ FileName = 'config-reference.md'; Title = 'Configuration reference'; Kind = [string[]]@('config-key') }
        [ordered]@{ FileName = 'http-reference.md'; Title = 'HTTP reference'; Kind = [string[]]@('http-route') }
    )
}

function New-DocsReferencePlanFinding {
    <#
    .SYNOPSIS
        Builds one error, warning or info finding of the page plan (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $Message,
        [AllowNull()] [string] $ArtifactPath,
        [AllowEmptyString()] [string] $Pointer = '',
        [string] $Severity = 'error',
        [AllowNull()] [AllowEmptyCollection()] [string[]] $RelatedId,
        [AllowNull()] [string] $RelatedPath
    )

    $nextAction = switch -CaseSensitive ($Code) {
        'REFERENCE_SNAPSHOT_INVALID' { 'Regenerate the surface inventory snapshot so every element is valid and unique.' }
        'REFERENCE_OUTPUT_DIR_UNRESOLVED' { 'Pass -OutputDirectory or declare exactly one non-glob reference entry in diataxis_policy.directory_modes.' }
        'REFERENCE_MODE_CONFLICT' { 'Declare the reference mode for the reference output directory in the docs profile.' }
        'REFERENCE_OUTPUT_OUTSIDE_ROOTS' { 'Place the reference output directory inside a documentation root of the docs profile.' }
        default { 'Add the parent command to the snapshot or remove the option.' }
    }
    [string[]] $related = @()
    if (-not [string]::IsNullOrEmpty($RelatedPath)) { $related = @($RelatedPath) }
    return New-DocsFinding -Code $Code -Severity $Severity -Message $Message -NextAction $nextAction -ArtifactPath $ArtifactPath -Pointer $Pointer -RelatedId $RelatedId -RelatedPath $related
}

function ConvertFrom-DocsReferenceSnapshotText {
    <#
    .SYNOPSIS
        Validates and converts surface inventory snapshot text; returns @{ Snapshot; Element; Finding }.
    .DESCRIPTION
        Schema findings of Test-DocsArtifactText -ArtifactKind 'surface-inventory-snapshot' are
        returned unchanged. A schema-valid snapshot then yields REFERENCE_SNAPSHOT_INVALID for a
        repeated element_id, a repeated property name within one element, and an element that
        ConvertFrom-DocsSurfaceElement rejects. Element holds the rebuilt elements ordered by
        element_id; Snapshot and Element are $null and empty whenever a finding exists.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [Parameter(Mandatory = $true)] [AllowNull()] [string] $ArtifactPath,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet
    )

    # Test-DocsArtifactText returns its array with the unary comma; a direct assignment keeps it flat.
    [object[]] $schemaFinding = Test-DocsArtifactText -ArtifactKind 'surface-inventory-snapshot' -JsonText $Text -ComposedSchemaSet $ComposedSchemaSet -ArtifactPath $ArtifactPath
    if ($schemaFinding.Count -gt 0) { return @{ Snapshot = $null; Element = [object[]]@(); Finding = $schemaFinding } }
    $snapshot = (ConvertFrom-DocsJsonText -Text $Text -ArtifactPath $ArtifactPath).Value
    $findings = [System.Collections.Generic.List[object]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $byId = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $records = @($snapshot['elements'])
    for ($index = 0; $index -lt $records.Count; $index++) {
        $record = $records[$index]
        $pointer = "/elements/$index"
        $id = [string] $record['element_id']
        if (-not $seen.Add($id)) {
            $findings.Add((New-DocsReferencePlanFinding -Code 'REFERENCE_SNAPSHOT_INVALID' -Message "element_id '$id' repeats an earlier element." -ArtifactPath $ArtifactPath -Pointer "$pointer/element_id"))
            continue
        }
        $names = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        $properties = @($record['properties'])
        for ($at = 0; $at -lt $properties.Count; $at++) {
            $name = [string] $properties[$at]['name']
            if (-not $names.Add($name)) {
                $findings.Add((New-DocsReferencePlanFinding -Code 'REFERENCE_SNAPSHOT_INVALID' -Message "property name '$name' repeats within element '$id'." -ArtifactPath $ArtifactPath -Pointer "$pointer/properties/$at/name"))
            }
        }
        try {
            $byId[$id] = ConvertFrom-DocsSurfaceElement -Record $record
        } catch {
            $findings.Add((New-DocsReferencePlanFinding -Code 'REFERENCE_SNAPSHOT_INVALID' -Message "element '$id' cannot be rebuilt: $($_.Exception.Message)" -ArtifactPath $ArtifactPath -Pointer $pointer))
        }
    }
    if ($findings.Count -gt 0) { return @{ Snapshot = $null; Element = [object[]]@(); Finding = [object[]] (Get-DocsOrderedFinding -Finding $findings.ToArray()) } }
    return @{ Snapshot = $snapshot; Element = [object[]] @($byId.Values); Finding = [object[]]@() }
}

function ConvertTo-DocsReferenceGlobPattern {
    <#
    .SYNOPSIS
        Translates a profile glob to an anchored regular expression (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [string] $Pattern)

    $builder = [System.Text.StringBuilder]::new('\A')
    $index = 0
    while ($index -lt $Pattern.Length) {
        $char = $Pattern[$index]
        if ($char -eq [char]'*') { [void]$builder.Append('.*'); $index++; continue }
        if ($char -eq [char]'?') { [void]$builder.Append('.'); $index++; continue }
        if ($char -eq [char]'[') {
            $first = $index + 1
            $negate = $first -lt $Pattern.Length -and $Pattern[$first] -eq [char]'!'
            if ($negate) { $first++ }
            $close = $Pattern.IndexOf([char]']', $first)
            if ($close -gt $first) {
                $content = $Pattern.Substring($first, $close - $first).Replace('\', '\\').Replace('[', '\[').Replace('^', '\^')
                [void]$builder.Append('[').Append($(if ($negate) { '^' } else { '' })).Append($content).Append(']')
                $index = $close + 1
                continue
            }
        }
        [void]$builder.Append([regex]::Escape([string] $char))
        $index++
    }
    return $builder.Append('\z').ToString()
}

function Test-DocsReferencePathCovered {
    <#
    .SYNOPSIS
        Returns $true when the profile path_or_glob Pattern covers the page path Path.
    .DESCRIPTION
        Pattern covers Path when they are equal, when Path starts with Pattern followed by '/',
        or when Path matches Pattern as an anchored case-sensitive glob ('*' crosses '/').
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Pattern
    )

    if ($Pattern.Length -eq 0) { return $false }
    if ($Path -ceq $Pattern) { return $true }
    if ($Path.StartsWith($Pattern + '/', [System.StringComparison]::Ordinal)) { return $true }
    return [regex]::IsMatch($Path, (ConvertTo-DocsReferenceGlobPattern -Pattern $Pattern), [System.Text.RegularExpressions.RegexOptions]::CultureInvariant)
}

function Resolve-DocsReferenceOutputDirectory {
    <#
    .SYNOPSIS
        Returns @{ OutputDirectory; Finding } for the reference output directory.
    .DESCRIPTION
        reference must be a member of diataxis_policy.modes (else REFERENCE_MODE_CONFLICT at
        /diataxis_policy/modes). OutputDirectory, when given, is returned unchanged. Otherwise the
        single directory_modes entry with mode reference whose path_or_glob contains none of '*',
        '?' and '[' is used; zero or several such entries give REFERENCE_OUTPUT_DIR_UNRESOLVED.
        OutputDirectory is $null whenever a finding exists.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Profile,
        [Parameter(Mandatory = $true)] [AllowNull()] [string] $ProfilePath,
        [AllowNull()] [string] $OutputDirectory
    )

    $policy = $Profile['diataxis_policy']
    if (@($policy['modes']) -cnotcontains 'reference') {
        $finding = New-DocsReferencePlanFinding -Code 'REFERENCE_MODE_CONFLICT' -Message 'diataxis_policy.modes does not contain the reference mode.' -ArtifactPath $ProfilePath -Pointer '/diataxis_policy/modes'
        return @{ OutputDirectory = $null; Finding = [object[]]@($finding) }
    }
    if (-not [string]::IsNullOrEmpty($OutputDirectory)) { return @{ OutputDirectory = $OutputDirectory; Finding = [object[]]@() } }
    $candidate = [System.Collections.Generic.List[string]]::new()
    foreach ($entry in @($policy['directory_modes'])) {
        $path = [string] $entry['path_or_glob']
        if ([string] $entry['mode'] -ceq 'reference' -and $path.IndexOfAny([char[]]@('*', '?', '[')) -lt 0) { $candidate.Add($path) }
    }
    if ($candidate.Count -eq 1) { return @{ OutputDirectory = $candidate[0]; Finding = [object[]]@() } }
    $finding = New-DocsReferencePlanFinding -Code 'REFERENCE_OUTPUT_DIR_UNRESOLVED' -Message "diataxis_policy.directory_modes has $($candidate.Count) non-glob reference entries; exactly one is required." -ArtifactPath $ProfilePath -Pointer '/diataxis_policy/directory_modes'
    return @{ OutputDirectory = $null; Finding = [object[]]@($finding) }
}

function Get-DocsReferenceCandidatePagePath {
    <#
    .SYNOPSIS
        Returns the four family page paths under OutputDirectory and the listed split pages, in ordinal order.
    .DESCRIPTION
        ListedPath (default empty) holds paths listed under OutputDirectory. Each listed path of
        the form <OutputDirectory>/<family-stem>/<name>.md, one segment beneath a family stem, is
        added, so that existing split pages are read (issue #1173 B5). The result has no duplicate.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param(
        [Parameter(Mandatory = $true)] [string] $OutputDirectory,
        [AllowEmptyCollection()] [string[]] $ListedPath = @()
    )

    $set = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    $stems = [System.Collections.Generic.List[string]]::new()
    foreach ($family in (Get-DocsReferenceFamily)) {
        [void] $set.Add($OutputDirectory + '/' + $family['FileName'])
        $stems.Add($OutputDirectory + '/' + [System.IO.Path]::GetFileNameWithoutExtension([string] $family['FileName']) + '/')
    }
    foreach ($path in $ListedPath) {
        foreach ($stem in $stems) {
            if (-not $path.StartsWith($stem, [System.StringComparison]::Ordinal)) { continue }
            $leaf = $path.Substring($stem.Length)
            if ($leaf.Length -gt 3 -and $leaf.EndsWith('.md', [System.StringComparison]::Ordinal) -and -not $leaf.Contains('/')) { [void] $set.Add($path) }
        }
    }
    [string[]] $paths = @($set)
    return , $paths
}

function Get-DocsReferenceSortedElement {
    <#
    .SYNOPSIS
        Orders elements by the ordinal tuple that KeyScript returns per element (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Element,
        [Parameter(Mandatory = $true)] [scriptblock] $KeyScript
    )

    # A SortedDictionary keyed by the joined tuple and the input index gives a stable ordinal sort.
    $sorted = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
    for ($index = 0; $index -lt $Element.Count; $index++) {
        $key = ((& $KeyScript $Element[$index]) -join [string][char]0) + [string][char]0 + $index.ToString('D9')
        $sorted[$key] = $Element[$index]
    }
    return , [object[]] @($sorted.Values)
}

function Get-DocsReferencePageElement {
    <#
    .SYNOPSIS
        Returns @{ Element; Finding } with the ordered elements of one family page (private helper).
    .DESCRIPTION
        CLI page: commands by (declaration, element_id), each followed by its options by
        (declaration, element_id); options whose parent is not in the snapshot follow all
        commands with REFERENCE_PARENT_MISSING. HTTP page: by (template, method, element_id).
        Other pages: by (declaration, path, element_id).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $FileName,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Element
    )

    $byDeclaration = { param($Item) @([string] $Item['declaration'], [string] $Item['element_id']) }
    $findings = [System.Collections.Generic.List[object]]::new()
    if ($FileName -ceq 'http-reference.md') {
        $byRoute = {
            param($Item)
            $declaration = [string] $Item['declaration']
            $space = $declaration.IndexOf(' ')
            if ($space -lt 0) { return @($declaration, '', [string] $Item['element_id']) }
            return @($declaration.Substring($space + 1), $declaration.Substring(0, $space), [string] $Item['element_id'])
        }
        return @{ Element = (Get-DocsReferenceSortedElement -Element $Element -KeyScript $byRoute); Finding = [object[]]@() }
    }
    if ($FileName -cne 'cli-reference.md') {
        $byPath = { param($Item) @([string] $Item['declaration'], [string] $Item['path'], [string] $Item['element_id']) }
        return @{ Element = (Get-DocsReferenceSortedElement -Element $Element -KeyScript $byPath); Finding = [object[]]@() }
    }
    $commands = Get-DocsReferenceSortedElement -Element @($Element | Where-Object { [string] $_['kind'] -ceq 'cli-command' }) -KeyScript $byDeclaration
    $options = Get-DocsReferenceSortedElement -Element @($Element | Where-Object { [string] $_['kind'] -ceq 'cli-option' }) -KeyScript $byDeclaration
    # Every cli-command of the snapshot is on this page, so a parent outside this set is not in the snapshot.
    $commandId = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $ordered = [System.Collections.Generic.List[object]]::new()
    foreach ($command in $commands) {
        [void]$commandId.Add([string] $command['element_id'])
        $ordered.Add($command)
        foreach ($option in $options) { if ([string] $option['parent_id'] -ceq [string] $command['element_id']) { $ordered.Add($option) } }
    }
    foreach ($option in $options) {
        $parent = [string] $option['parent_id']
        if ($commandId.Contains($parent)) { continue }
        $ordered.Add($option)
        $id = [string] $option['element_id']
        $findings.Add((New-DocsReferencePlanFinding -Code 'REFERENCE_PARENT_MISSING' -Severity 'warning' -Message "cli-option '$id' names parent '$parent', which is not a command in the snapshot; it is rendered after all commands." -ArtifactPath $PagePath -RelatedId @($id)))
    }
    return @{ Element = [object[]] $ordered.ToArray(); Finding = [object[]] $findings.ToArray() }
}

function Get-DocsReferencePageContext {
    <#
    .SYNOPSIS
        Returns @{ Owner; RootId; Audience; Finding } for one page path from the profile (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Profile,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [AllowNull()] [string] $ProfilePath
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in @($Profile['diataxis_policy']['directory_modes'])) {
        if (-not (Test-DocsReferencePathCovered -Path $PagePath -Pattern ([string] $entry['path_or_glob']))) { continue }
        $mode = [string] $entry['mode']
        if ($mode -cne 'reference') {
            $findings.Add((New-DocsReferencePlanFinding -Code 'REFERENCE_MODE_CONFLICT' -Message "the first directory_modes entry covering the page ('$($entry['path_or_glob'])') declares mode '$mode', not reference." -ArtifactPath $PagePath -RelatedPath $ProfilePath))
        }
        break
    }
    $owner = $null
    foreach ($entry in @($Profile['page_owners'])) {
        if (Test-DocsReferencePathCovered -Path $PagePath -Pattern ([string] $entry['path_or_glob'])) { $owner = [string] $entry['owner']; break }
    }
    $root = $null
    foreach ($entry in @($Profile['documentation_roots'])) {
        if (-not (Test-DocsReferencePathCovered -Path $PagePath -Pattern ([string] $entry['path']))) { continue }
        if ($null -eq $root -or ([string] $entry['path']).Length -gt ([string] $root['path']).Length) { $root = $entry }
    }
    [string[]] $audience = @()
    $rootId = $null
    if ($null -eq $root) {
        $findings.Add((New-DocsReferencePlanFinding -Code 'REFERENCE_OUTPUT_OUTSIDE_ROOTS' -Message 'no documentation_roots entry covers the page path.' -ArtifactPath $PagePath -RelatedPath $ProfilePath))
    } else {
        $rootId = [string] $root['id']
        $audience = @(@($root['audience_ids']) | Where-Object { $null -ne $_ } | ForEach-Object { [string] $_ })
        [Array]::Sort($audience, [System.StringComparer]::Ordinal)
    }
    return @{ Owner = $owner; RootId = $rootId; Audience = $audience; Finding = [object[]] $findings.ToArray() }
}

function Get-DocsReferencePagePlan {
    <#
    .SYNOPSIS
        Returns @{ Page; Unrendered; Finding } for the family pages under OutputDirectory.
    .DESCRIPTION
        A family page is planned when its family has at least one element or its path is listed
        in ExistingPagePath. Page records, ordinal by Path, carry Path, Title, the ordered
        Element array, Owner ($null when no page_owners entry covers the path), RootId, Audience
        (the ordinal-sorted audience_ids of the longest covering root) and the page-scoped
        Finding array. Unrendered is the number of architecture-component elements. The top-level
        Finding holds every page finding in Get-DocsOrderedFinding order.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Profile,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Element,
        [Parameter(Mandatory = $true)] [string] $OutputDirectory,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $ExistingPagePath,
        [Parameter(Mandatory = $true)] [AllowNull()] [string] $ProfilePath
    )

    $unrendered = @($Element | Where-Object { [string] $_['kind'] -ceq 'architecture-component' }).Count
    $pages = [System.Collections.Generic.List[object]]::new()
    $all = [System.Collections.Generic.List[object]]::new()
    foreach ($family in (Get-DocsReferenceFamily)) {
        $path = $OutputDirectory + '/' + $family['FileName']
        $members = @($Element | Where-Object { $family['Kind'] -ccontains [string] $_['kind'] })
        if ($members.Count -eq 0 -and $ExistingPagePath -cnotcontains $path) { continue }
        $ordered = Get-DocsReferencePageElement -FileName $family['FileName'] -PagePath $path -Element $members
        $pageContext = Get-DocsReferencePageContext -Profile $Profile -PagePath $path -ProfilePath $ProfilePath
        [object[]] $pageFinding = @($ordered.Finding) + @($pageContext.Finding)
        $all.AddRange($pageFinding)
        $pages.Add([ordered]@{
                Path     = $path
                Title    = $family['Title']
                Element  = [object[]] $ordered.Element
                Owner    = $pageContext.Owner
                RootId   = $pageContext.RootId
                Audience = [string[]] $pageContext.Audience
                Finding  = $pageFinding
            })
    }
    [object[]] $ordering = @()
    if ($all.Count -gt 0) { $ordering = Get-DocsOrderedFinding -Finding $all.ToArray() }
    return @{ Page = [object[]] $pages.ToArray(); Unrendered = $unrendered; Finding = $ordering }
}

Export-ModuleMember -Function `
    ConvertFrom-DocsReferenceSnapshotText, `
    Test-DocsReferencePathCovered, `
    Resolve-DocsReferenceOutputDirectory, `
    Get-DocsReferenceCandidatePagePath, `
    Get-DocsReferencePagePlan
