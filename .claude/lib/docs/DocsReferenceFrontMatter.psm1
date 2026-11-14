<#
.SYNOPSIS
    Front matter of generated reference pages: delimiter split, conversion of an existing page,
    resolution of the generated values and the canonical front-matter block.

.DESCRIPTION
    Existing front matter is recognized only when line 1, after removal of one byte order mark and
    CRLF normalization, is exactly '---'; it ends at the next line that is exactly '---' or '...'.
    Field values are parsed by the 1021 parser ConvertFrom-DocsPageFrontMatter and validated by
    1021 Test-DocsPageFrontMatter over the composed schema set, with an empty RequiredField list
    (the generator fills missing fields) and the profile audience identifiers. Each 1021 finding
    becomes one REFERENCE_FRONT_MATTER_INVALID finding whose message names the 1021 code; this
    module emits no code of the 1021 page checker itself, and it defines no pattern for any
    front-matter field, because every field constraint comes from the page-metadata schema.

    The rendered block is '---', one '<key>: <JSON value>' line per field in the order owner,
    last_reviewed, audience, diataxis_mode, surface_refs, title, extensions, then '---'. JSON
    values are canonical JSON without the trailing LF, with U+0085, U+2028 and U+2029 written as
    \u escapes so that every value stays on one line. The one exception is an extensions value
    that holds a number canonical JSON rejects (a non-integral number or one beyond the
    safe-integer bound): that value is written by ConvertTo-DocsJsonText. A canonical-serializer
    failure for any other value propagates to the caller.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state; inputs are not mutated.

.NOTES
    Issue #1024. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageFrontMatter.psm1') -ErrorAction Stop

function New-DocsReferenceFrontMatterFinding {
    <#
    .SYNOPSIS
        Builds one page-scoped front-matter finding with the fixed next action of its code (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $Message,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [AllowEmptyString()] [string] $Pointer = ''
    )

    $nextAction = switch -CaseSensitive ($Code) {
        'REFERENCE_FRONT_MATTER_INVALID' { 'Correct or remove the front matter field so the page conforms to the page-metadata schema.' }
        'REFERENCE_MARKER_IN_FRONT_MATTER' { 'Remove the generated-block marker line from the front matter block.' }
        'REFERENCE_OWNER_UNRESOLVED' { 'Add an owner to the page front matter or a page_owners entry covering the page to the docs profile.' }
        'REFERENCE_AUDIENCE_MISSING' { 'Add an audience to the page front matter or audience_ids to the covering documentation root.' }
        default { 'Set diataxis_mode to reference or move the page out of the reference output directory.' }
    }
    return New-DocsFinding -Code $Code -Severity 'error' -Message $Message -NextAction $nextAction -ArtifactPath $PagePath -Pointer $Pointer
}

function ConvertTo-DocsReferenceLfText {
    <#
    .SYNOPSIS
        Removes one leading U+FEFF and converts CRLF to LF (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    $body = if ($Text.StartsWith([char]0xFEFF)) { $Text.Substring(1) } else { $Text }
    return $body.Replace("`r`n", "`n")
}

function Split-DocsReferenceFrontMatter {
    <#
    .SYNOPSIS
        Splits page text into front matter and body; returns @{ HasFrontMatter; Terminated; FrontMatterLine; ClosingDelimiter; BodyLine; BodyLineOffset }.
    .DESCRIPTION
        One leading U+FEFF is removed and CRLF becomes LF before the text is split on LF.
        FrontMatterLine holds the lines between the delimiters and ClosingDelimiter the closing
        line ('---' or '...', or $null). BodyLineOffset is the number of lines before the body,
        delimiters included. Without front matter the whole text is the body; an unterminated
        block holds every line after line 1 and an empty body.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    [string[]] $lines = (ConvertTo-DocsReferenceLfText -Text $Text).Split("`n")
    if ($lines[0] -cne '---') {
        return @{ HasFrontMatter = $false; Terminated = $false; FrontMatterLine = [string[]]@(); ClosingDelimiter = $null; BodyLine = $lines; BodyLineOffset = 0 }
    }
    for ($end = 1; $end -lt $lines.Count; $end++) {
        if ($lines[$end] -ceq '---' -or $lines[$end] -ceq '...') {
            [string[]] $inner = @($lines | Select-Object -Skip 1 -First ($end - 1))
            [string[]] $body = @($lines | Select-Object -Skip ($end + 1))
            return @{ HasFrontMatter = $true; Terminated = $true; FrontMatterLine = $inner; ClosingDelimiter = $lines[$end]; BodyLine = $body; BodyLineOffset = $end + 1 }
        }
    }
    [string[]] $rest = @($lines | Select-Object -Skip 1)
    return @{ HasFrontMatter = $true; Terminated = $false; FrontMatterLine = $rest; ClosingDelimiter = $null; BodyLine = [string[]]@(); BodyLineOffset = $lines.Count }
}

function ConvertTo-DocsReferenceInvalidFinding {
    <#
    .SYNOPSIS
        Maps one 1021 parse or validation finding to REFERENCE_FRONT_MATTER_INVALID (private helper).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Finding,
        [Parameter(Mandatory = $true)] [string] $PagePath
    )

    $message = "front matter is invalid ($($Finding['code'])): $($Finding['message'])"
    return New-DocsReferenceFrontMatterFinding -Code 'REFERENCE_FRONT_MATTER_INVALID' -Message $message -PagePath $PagePath -Pointer ([string] $Finding['pointer'])
}

function ConvertFrom-DocsReferencePageText {
    <#
    .SYNOPSIS
        Converts existing page text; returns @{ Value; HasFrontMatter; BodyLine; BodyLineOffset; Finding }.
    .DESCRIPTION
        A front-matter line whose trimmed text starts with '<!-- docs:generated:' yields
        REFERENCE_MARKER_IN_FRONT_MATTER with its page line number, and no further check runs.
        Otherwise the block is parsed by ConvertFrom-DocsPageFrontMatter and the values are
        validated by Test-DocsPageFrontMatter with ComposedSchemaSet, an empty RequiredField and
        AudienceId; every 1021 finding becomes REFERENCE_FRONT_MATTER_INVALID. Value is the
        parsed ordinal hashtable, or $null without front matter or with any finding. No read is
        performed.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $AudienceId
    )

    $split = Split-DocsReferenceFrontMatter -Text $Text
    $result = @{ Value = $null; HasFrontMatter = $split.HasFrontMatter; BodyLine = $split.BodyLine; BodyLineOffset = $split.BodyLineOffset; Finding = [object[]]@() }
    if (-not $split.HasFrontMatter) { return $result }
    $markers = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $split.FrontMatterLine.Count; $index++) {
        if ($split.FrontMatterLine[$index].Trim().StartsWith('<!-- docs:generated:', [System.StringComparison]::Ordinal)) {
            $markers.Add((New-DocsReferenceFrontMatterFinding -Code 'REFERENCE_MARKER_IN_FRONT_MATTER' -Message "line $($index + 2): a generated-block marker line is inside the front matter block." -PagePath $PagePath))
        }
    }
    if ($markers.Count -gt 0) { $result.Finding = [object[]] $markers.ToArray(); return $result }
    $normalized = ConvertTo-DocsReferenceLfText -Text $Text
    $parsed = ConvertFrom-DocsPageFrontMatter -Text $normalized -PagePath $PagePath
    [object[]] $upstream = $parsed.Findings
    if ($upstream.Count -eq 0) {
        $upstream = Test-DocsPageFrontMatter -FrontMatter $parsed.Value -PagePath $PagePath -ComposedSchemaSet $ComposedSchemaSet -RequiredField @() -AudienceId $AudienceId -FieldLine $parsed.FieldLine
    }
    if ($upstream.Count -eq 0) { $result.Value = $parsed.Value; return $result }
    $mapped = [System.Collections.Generic.List[object]]::new()
    foreach ($finding in $upstream) { $mapped.Add((ConvertTo-DocsReferenceInvalidFinding -Finding $finding -PagePath $PagePath)) }
    $result.Finding = [object[]] (Get-DocsOrderedFinding -Finding $mapped.ToArray())
    return $result
}

function Resolve-DocsReferenceFrontMatterValue {
    <#
    .SYNOPSIS
        Returns @{ Value; Finding } with the front-matter values of one generated page.
    .DESCRIPTION
        Existing is the validated front matter of the page, or $null. PagePlan is a page record
        of Get-DocsReferencePagePlan (Path, Title, Owner, Audience). diataxis_mode is reference;
        surface_refs is the ordinal-sorted SurfaceRef list. owner, audience, last_reviewed, title
        and extensions are preserved when present; a missing owner comes from PagePlan.Owner
        (REFERENCE_OWNER_UNRESOLVED when absent), a missing audience from PagePlan.Audience
        (REFERENCE_AUDIENCE_MISSING when empty), a missing last_reviewed from the first ten
        characters of CapturedAt, and a missing title from PagePlan.Title on a new page only. An
        existing diataxis_mode other than reference yields REFERENCE_MODE_CONFLICT.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [System.Collections.IDictionary] $Existing,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $PagePlan,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $SurfaceRef,
        [Parameter(Mandatory = $true)] [string] $CapturedAt,
        [Parameter(Mandatory = $true)] [bool] $IsNewPage
    )

    $current = if ($null -eq $Existing) { @{} } else { $Existing }
    $path = [string] $PagePlan['Path']
    $findings = [System.Collections.Generic.List[object]]::new()
    $value = [ordered]@{}
    $owner = if ($current.Contains('owner')) { $current['owner'] } else { $PagePlan['Owner'] }
    if ([string]::IsNullOrEmpty([string] $owner)) {
        $findings.Add((New-DocsReferenceFrontMatterFinding -Code 'REFERENCE_OWNER_UNRESOLVED' -Message 'the page has no valid owner and no page_owners entry covers it.' -PagePath $path -Pointer '/owner'))
    } else {
        $value['owner'] = [string] $owner
    }
    $value['last_reviewed'] = if ($current.Contains('last_reviewed')) { [string] $current['last_reviewed'] } else { $CapturedAt.Substring(0, [math]::Min(10, $CapturedAt.Length)) }
    [string[]] $audience = @($PagePlan['Audience'] | Where-Object { $null -ne $_ })
    if ($current.Contains('audience')) { $audience = @($current['audience'] | ForEach-Object { [string] $_ }) }
    if ($audience.Count -eq 0) {
        $findings.Add((New-DocsReferenceFrontMatterFinding -Code 'REFERENCE_AUDIENCE_MISSING' -Message 'the page has no valid audience and the covering documentation root has no audience_ids.' -PagePath $path -Pointer '/audience'))
    } else {
        $value['audience'] = $audience
    }
    if ($current.Contains('diataxis_mode') -and [string] $current['diataxis_mode'] -cne 'reference') {
        $findings.Add((New-DocsReferenceFrontMatterFinding -Code 'REFERENCE_MODE_CONFLICT' -Message "the page declares diataxis_mode '$($current['diataxis_mode'])', not reference." -PagePath $path -Pointer '/diataxis_mode'))
    }
    $value['diataxis_mode'] = 'reference'
    $refs = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($ref in $SurfaceRef) { [void]$refs.Add($ref) }
    $value['surface_refs'] = [string[]] @($refs)
    if ($current.Contains('title')) { $value['title'] = $current['title'] } elseif ($IsNewPage) { $value['title'] = [string] $PagePlan['Title'] }
    if ($current.Contains('extensions')) { $value['extensions'] = $current['extensions'] }
    return @{ Value = $value; Finding = [object[]] $findings.ToArray() }
}

function Test-DocsReferenceCanonicalNumberRejected {
    <#
    .SYNOPSIS
        Returns $true when Value holds a number that canonical JSON rejects (private helper).
    .DESCRIPTION
        A [double], [single] or [decimal] is rejected when it is non-integral or its magnitude
        exceeds 9007199254740991, the safe-integer bound of ConvertTo-DiscoveryCanonicalFragment.
        IDictionary values, PSCustomObject property values and the items of a non-string
        IEnumerable are walked recursively. Every other value, including $null and strings,
        returns $false.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] [object] $Value)

    if ($Value -is [double] -or $Value -is [single] -or $Value -is [decimal]) {
        return ([math]::Floor([double] $Value) -ne [double] $Value) -or ([math]::Abs([double] $Value) -gt 9007199254740991)
    }
    # A list keeps a nested container as one child; pipeline output would unroll it.
    $children = [System.Collections.Generic.List[object]]::new()
    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($item in $Value.Values) { $children.Add($item) }
    } elseif ($Value -is [System.Management.Automation.PSCustomObject]) {
        foreach ($property in $Value.PSObject.Properties) { $children.Add($property.Value) }
    } elseif ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        foreach ($item in $Value) { $children.Add($item) }
    }
    foreach ($child in $children) {
        if (Test-DocsReferenceCanonicalNumberRejected -Value $child) { return $true }
    }
    return $false
}

function ConvertTo-DocsReferenceFrontMatterText {
    <#
    .SYNOPSIS
        Returns the canonical front-matter block of Value, LF-terminated.
    .DESCRIPTION
        Fields present in Value are written in the fixed order owner, last_reviewed, audience,
        diataxis_mode, surface_refs, title, extensions as '<key>: <JSON value>'. Only an
        extensions value holding a number that canonical JSON rejects (non-integral, or above the
        safe-integer bound; see Test-DocsReferenceCanonicalNumberRejected) is written with
        ConvertTo-DocsJsonText. Every other value is written with ConvertTo-DocsCanonicalJson,
        and any exception from that call propagates unchanged.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Value)

    $builder = [System.Text.StringBuilder]::new("---`n")
    foreach ($key in @('owner', 'last_reviewed', 'audience', 'diataxis_mode', 'surface_refs', 'title', 'extensions')) {
        if (-not $Value.Contains($key)) { continue }
        $field = $Value[$key]
        $json = if ($key -ceq 'extensions' -and (Test-DocsReferenceCanonicalNumberRejected -Value $field)) {
            ConvertTo-DocsJsonText -Value $field
        } else {
            ConvertTo-DocsCanonicalJson -Value $field
        }
        $json = [regex]::Replace($json.TrimEnd("`n"), '[\x85\p{Zl}\p{Zp}]', { param($Match) '\u{0:x4}' -f [int] $Match.Value[0] })
        [void]$builder.Append($key).Append(': ').Append($json).Append("`n")
    }
    return $builder.Append("---`n").ToString()
}

Export-ModuleMember -Function `
    Split-DocsReferenceFrontMatter, `
    ConvertFrom-DocsReferencePageText, `
    Resolve-DocsReferenceFrontMatterValue, `
    ConvertTo-DocsReferenceFrontMatterText
