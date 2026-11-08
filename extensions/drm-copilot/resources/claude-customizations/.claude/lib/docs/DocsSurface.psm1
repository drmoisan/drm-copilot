<#
.SYNOPSIS
    Surface element model for the documentation library: element kinds, analysis methods, path
    and revision grammar, stable and element identifiers, the declaration-lines digest, and
    element and diagnostic records.

.DESCRIPTION
    An element identifier is '<kind>-' plus the lowercase hex SHA-256 of the canonical JSON of
    {declaration, kind, path} followed by LF, so it depends only on those three values and never
    on the analysis method, digest, line range, name or properties. The declaration-lines digest
    (source_sha256) covers the normalized source lines selected by the element's line range, not
    the whole file. Arguments outside their grammar throw DOCS_IDENTITY_INPUT_INVALID naming the
    argument; a line range outside the text throws DOCS_DIGEST_RANGE_INVALID.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1020. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop

# Grammar shared with the docs common schema definitions. The (?![\s\S]) suffix keeps .NET from
# accepting a value with a trailing newline.
$script:DocsSurfaceIdentifierPattern = '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])'
# The relative-path pattern excludes U+2028 and U+2029; they are inserted from their code points
# so that this source file stays ASCII.
$script:DocsSurfaceRelativePathPattern = '^(?!/)(?!.*(?:^|/)\.{1,2}(?:/|$))[^/\\:\x00-\x1fSEPARATORS*?<>|]+(?:/[^/\\:\x00-\x1fSEPARATORS*?<>|]+)*$(?![\s\S])'.Replace('SEPARATORS', [string][char]0x2028 + [char]0x2029)
$script:DocsSurfaceElementIdPattern = '^(?:cli-command|cli-option|http-route|config-key|public-symbol|architecture-component)-[0-9a-f]{64}$(?![\s\S])'
$script:DocsSurfaceCodePattern = '^[A-Z][A-Z0-9_]*$(?![\s\S])'
$script:DocsSurfaceExtensionKeyPattern = '^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)+$(?![\s\S])'

function Get-DocsElementKind {
    <#
    .SYNOPSIS
        Returns the six element kinds in contract order.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()

    return [string[]]@('cli-command', 'cli-option', 'http-route', 'config-key', 'public-symbol', 'architecture-component')
}

function Test-DocsElementKind {
    <#
    .SYNOPSIS
        Returns $true when Kind is one of the element kinds (case-sensitive).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Kind)

    return (Get-DocsElementKind) -ccontains $Kind
}

function Get-DocsAnalysisMethod {
    <#
    .SYNOPSIS
        Returns the analysis methods in contract order: native, scanner.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()

    return [string[]]@('native', 'scanner')
}

function Test-DocsRelativePath {
    <#
    .SYNOPSIS
        Returns $true when Path is a workspace-relative POSIX path (docs common relative-path).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Path)

    return ($null -ne $Path) -and ($Path -cmatch $script:DocsSurfaceRelativePathPattern)
}

function Test-DocsFullRevision {
    <#
    .SYNOPSIS
        Returns $true when Revision is 40 or 64 lowercase hex characters.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Revision)

    return ($null -ne $Revision) -and ($Revision -cmatch '^(?:[0-9a-f]{40}|[0-9a-f]{64})$(?![\s\S])')
}

function Test-DocsElementId {
    <#
    .SYNOPSIS
        Returns $true when ElementId matches the docs common element-id pattern.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $ElementId)

    return ($null -ne $ElementId) -and ($ElementId -cmatch $script:DocsSurfaceElementIdPattern)
}

function Test-DocsStrictUtf8Text {
    <#
    .SYNOPSIS
        Returns $true when Text encodes to UTF-8 without an unpaired surrogate (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    try {
        [void][System.Text.UTF8Encoding]::new($false, $true).GetByteCount($Text)
        return $true
    } catch [System.Text.EncoderFallbackException] {
        return $false
    }
}

function Assert-DocsIdentityText {
    <#
    .SYNOPSIS
        Throws DOCS_IDENTITY_INPUT_INVALID naming Name when Value is not identity text (private helper).
    .DESCRIPTION
        Identity text is non-blank, has no leading or trailing whitespace, no C0 control character
        and no unpaired UTF-16 surrogate. No Unicode normalization is applied.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $Name,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) { throw "DOCS_IDENTITY_INPUT_INVALID: $Name must not be blank." }
    if ($Value.Trim() -cne $Value) { throw "DOCS_IDENTITY_INPUT_INVALID: $Name must not have leading or trailing whitespace." }
    if ($Value -match '[\x00-\x1f]') { throw "DOCS_IDENTITY_INPUT_INVALID: $Name must not contain a control character." }
    if (-not (Test-DocsStrictUtf8Text -Text $Value)) { throw "DOCS_IDENTITY_INPUT_INVALID: $Name contains an unpaired UTF-16 surrogate." }
}

function ConvertTo-DocsDeclarationText {
    <#
    .SYNOPSIS
        Returns the canonical declaration text: the selected normalized lines, each ending in LF.
    .DESCRIPTION
        Removes one leading U+FEFF, converts CRLF and then CR to LF, removes exactly one trailing
        LF, and splits on LF into lines numbered from 1 (the empty text has zero lines). With
        LineRange @(start, end) it requires 1 <= start <= end <= line count and selects that
        inclusive range; without it every line is selected. No trimming or normalization of the
        line content is applied.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [AllowNull()] [int[]] $LineRange
    )

    $normalized = $Text
    if ($normalized.StartsWith([char]0xFEFF)) { $normalized = $normalized.Substring(1) }
    $normalized = $normalized.Replace("`r`n", "`n").Replace("`r", "`n")
    if ($normalized.EndsWith("`n")) { $normalized = $normalized.Substring(0, $normalized.Length - 1) }
    [string[]] $lines = [string[]]@()
    if ($normalized.Length -gt 0) { $lines = $normalized.Split("`n") }

    $first = 1
    $last = $lines.Count
    if ($null -ne $LineRange) {
        $rangeText = '@(' + (@($LineRange) -join ', ') + ')'
        if ($LineRange.Count -ne 2) { throw "DOCS_DIGEST_RANGE_INVALID: LineRange $rangeText must hold exactly a start and an end." }
        $first = $LineRange[0]
        $last = $LineRange[1]
        if ($first -lt 1 -or $first -gt $last -or $last -gt $lines.Count) {
            throw "DOCS_DIGEST_RANGE_INVALID: LineRange $rangeText is outside the $($lines.Count) lines of the text."
        }
    }

    $builder = [System.Text.StringBuilder]::new()
    for ($index = $first; $index -le $last; $index++) {
        [void]$builder.Append($lines[$index - 1]).Append("`n")
    }
    return $builder.ToString()
}

function Get-DocsDeclarationSha256 {
    <#
    .SYNOPSIS
        Returns the declaration-lines digest: the SHA-256 of the canonical declaration text.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [AllowNull()] [int[]] $LineRange
    )

    return Get-DocsSha256Hex -Text (ConvertTo-DocsDeclarationText -Text $Text -LineRange $LineRange)
}

function Get-DocsStableId {
    <#
    .SYNOPSIS
        Returns '<Prefix>-' plus the lowercase hex SHA-256 of the canonical JSON of Value.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $Prefix,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Value
    )

    if ($Prefix -cnotmatch '^[a-z][a-z0-9]*(?:-[a-z0-9]+)*$(?![\s\S])') { throw "DOCS_IDENTITY_INPUT_INVALID: Prefix '$Prefix' is not a lower-case hyphenated name." }
    try {
        $canonical = ConvertTo-DocsCanonicalJson -Value $Value
    } catch {
        $message = $_.Exception.Message
        if ($message.StartsWith('AUTHORIZATION_INPUT_INVALID: ')) { throw ('DOCS_IDENTITY_INPUT_INVALID: ' + $message.Substring('AUTHORIZATION_INPUT_INVALID: '.Length)) }
        throw
    }
    return $Prefix + '-' + (Get-DocsSha256Hex -Text $canonical)
}

function Get-DocsElementId {
    <#
    .SYNOPSIS
        Returns the element identifier for a kind, path and declaration.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Kind,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Declaration
    )

    if (-not (Test-DocsElementKind -Kind $Kind)) { throw "DOCS_IDENTITY_INPUT_INVALID: Kind '$Kind' is not an element kind." }
    if (-not (Test-DocsRelativePath -Path $Path) -or -not (Test-DocsStrictUtf8Text -Text $Path)) { throw "DOCS_IDENTITY_INPUT_INVALID: Path '$Path' is not a relative POSIX path." }
    Assert-DocsIdentityText -Name 'Declaration' -Value $Declaration
    return Get-DocsStableId -Prefix $Kind -Value ([ordered]@{ kind = $Kind; path = $Path; declaration = $Declaration })
}

function ConvertTo-DocsElementPropertyList {
    <#
    .SYNOPSIS
        Converts a name-to-value map to the sorted element properties array (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([AllowNull()] [System.Collections.IDictionary] $Property)

    $list = [System.Collections.Generic.List[object]]::new()
    if ($null -eq $Property) { return , $list.ToArray() }
    [string[]] $names = @($Property.Keys | ForEach-Object { [string] $_ })
    [Array]::Sort($names, [System.StringComparer]::Ordinal)
    foreach ($propertyName in $names) {
        if ($propertyName -cnotmatch $script:DocsSurfaceIdentifierPattern) { throw "DOCS_IDENTITY_INPUT_INVALID: Property name '$propertyName' is not an identifier." }
        $propertyValue = $Property[$propertyName]
        $isScalar = ($null -eq $propertyValue) -or ($propertyValue -is [string]) -or ($propertyValue -is [bool]) -or ($propertyValue -is [int]) -or ($propertyValue -is [long]) -or ($propertyValue -is [double])
        if (-not $isScalar) { throw "DOCS_IDENTITY_INPUT_INVALID: Property '$propertyName' must be a string, number, boolean or null." }
        $list.Add([ordered]@{ name = $propertyName; value = $propertyValue })
    }
    return , $list.ToArray()
}

function ConvertTo-DocsExtensionTable {
    <#
    .SYNOPSIS
        Copies a namespaced extension map into an ordered table (private helper).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([AllowNull()] [System.Collections.IDictionary] $Extension)

    $table = [ordered]@{}
    if ($null -eq $Extension) { return $table }
    [string[]] $keys = @($Extension.Keys | ForEach-Object { [string] $_ })
    [Array]::Sort($keys, [System.StringComparer]::Ordinal)
    foreach ($key in $keys) {
        if ($key -cnotmatch $script:DocsSurfaceExtensionKeyPattern) { throw "DOCS_IDENTITY_INPUT_INVALID: Extension key '$key' is not a namespaced name." }
        $table[$key] = $Extension[$key]
    }
    return $table
}

function New-DocsSurfaceElement {
    <#
    .SYNOPSIS
        Returns one snapshot element with a computed element_id and declaration-lines digest.
    .DESCRIPTION
        AnalysisMethod is one of Get-DocsAnalysisMethod. SourceText is the strict-UTF-8 text of the
        captured input for Path; source_sha256 is Get-DocsDeclarationSha256 over it and LineRange,
        and a caller cannot supply a digest. LineRange is required for every kind except
        architecture-component. A cli-option requires a ParentId beginning 'cli-command-'.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state; the exported name is fixed by the issue #1020 contract.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Kind,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Declaration,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Name,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $AnalyzerId,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $AnalysisMethod,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $SourceText,
        [AllowNull()] [string] $ParentId,
        [AllowNull()] [int[]] $LineRange,
        [AllowNull()] [System.Collections.IDictionary] $Property,
        [AllowNull()] [System.Collections.IDictionary] $Extension
    )

    $elementId = Get-DocsElementId -Kind $Kind -Path $Path -Declaration $Declaration
    if ((Get-DocsAnalysisMethod) -cnotcontains $AnalysisMethod) { throw "DOCS_IDENTITY_INPUT_INVALID: AnalysisMethod '$AnalysisMethod' is not one of $((Get-DocsAnalysisMethod) -join ', ')." }
    if ([string]::IsNullOrWhiteSpace($Name)) { throw 'DOCS_IDENTITY_INPUT_INVALID: Name must not be blank.' }
    if ($AnalyzerId -cnotmatch $script:DocsSurfaceIdentifierPattern) { throw "DOCS_IDENTITY_INPUT_INVALID: AnalyzerId '$AnalyzerId' is not an identifier." }
    $parent = if ([string]::IsNullOrEmpty($ParentId)) { $null } else { $ParentId }
    if ($Kind -ceq 'cli-option' -and ($null -eq $parent -or -not $parent.StartsWith('cli-command-', [System.StringComparison]::Ordinal))) {
        throw 'DOCS_IDENTITY_INPUT_INVALID: ParentId of a cli-option must be a cli-command element identifier.'
    }
    if ($null -ne $parent -and -not (Test-DocsElementId -ElementId $parent)) { throw "DOCS_IDENTITY_INPUT_INVALID: ParentId '$parent' is not an element identifier." }
    if ($null -eq $LineRange -and $Kind -cne 'architecture-component') { throw "DOCS_IDENTITY_INPUT_INVALID: LineRange is required for kind '$Kind'." }

    $digest = Get-DocsDeclarationSha256 -Text $SourceText -LineRange $LineRange
    $range = if ($null -eq $LineRange) { $null } else { [ordered]@{ start = [long] $LineRange[0]; end = [long] $LineRange[1] } }
    return [ordered]@{
        element_id      = $elementId
        kind            = $Kind
        path            = $Path
        declaration     = $Declaration
        name            = $Name
        parent_id       = $parent
        analyzer_id     = $AnalyzerId
        analysis_method = $AnalysisMethod
        source_sha256   = $digest
        line_range      = $range
        properties      = (ConvertTo-DocsElementPropertyList -Property $Property)
        extensions      = (ConvertTo-DocsExtensionTable -Extension $Extension)
    }
}

function ConvertFrom-DocsSurfaceElement {
    <#
    .SYNOPSIS
        Rebuilds an element record after re-verifying its element_id and analysis_method.
    .DESCRIPTION
        Throws DOCS_IDENTITY_INPUT_INVALID naming a missing identity field or an analysis_method
        outside Get-DocsAnalysisMethod, and DOCS_ELEMENT_ID_MISMATCH when element_id differs from the
        identifier recomputed from kind, path and declaration.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Record)

    foreach ($field in 'element_id', 'kind', 'path', 'declaration', 'analysis_method') {
        if (-not $Record.Contains($field) -or $null -eq $Record[$field]) { throw "DOCS_IDENTITY_INPUT_INVALID: field $field is required in an element record." }
    }
    $method = [string] $Record['analysis_method']
    if ((Get-DocsAnalysisMethod) -cnotcontains $method) { throw "DOCS_IDENTITY_INPUT_INVALID: analysis_method '$method' is not one of $((Get-DocsAnalysisMethod) -join ', ')." }
    $expected = Get-DocsElementId -Kind ([string] $Record['kind']) -Path ([string] $Record['path']) -Declaration ([string] $Record['declaration'])
    if ([string] $Record['element_id'] -cne $expected) {
        throw "DOCS_ELEMENT_ID_MISMATCH: element_id '$($Record['element_id'])' differs from the recomputed identifier '$expected'."
    }

    $rebuilt = [ordered]@{}
    $defaults = [ordered]@{ element_id = $null; kind = $null; path = $null; declaration = $null; name = $null; parent_id = $null; analyzer_id = $null; analysis_method = $null; source_sha256 = $null; line_range = $null; properties = [object[]]@(); extensions = [ordered]@{} }
    foreach ($key in $defaults.Keys) {
        $rebuilt[$key] = if ($Record.Contains($key)) { $Record[$key] } else { $defaults[$key] }
    }
    return $rebuilt
}

function New-DocsDiagnostic {
    <#
    .SYNOPSIS
        Returns one analyzer diagnostic in the docs common diagnostic shape.
    .DESCRIPTION
        The id is Get-DocsStableId -Prefix 'diagnostic' over {analyzer, code, path}. Severity and
        blocking are coupled: blocking is true exactly when severity is error. With -Severity
        (error, warning or information) blocking follows the severity, and an explicit -Blocking
        that disagrees throws DOCS_IDENTITY_INPUT_INVALID naming Blocking. Without -Severity,
        -Blocking (default true) selects error or warning.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state; the exported name is fixed by the issue #1020 contract.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $Path,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Message,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $AnalyzerId,
        [string] $Severity,
        [bool] $Blocking = $true
    )

    if ($Code -cnotmatch $script:DocsSurfaceCodePattern) { throw "DOCS_IDENTITY_INPUT_INVALID: Code '$Code' does not match ^[A-Z][A-Z0-9_]*$." }
    $diagnosticPath = if ([string]::IsNullOrEmpty($Path)) { $null } else { $Path }
    if ($null -ne $diagnosticPath -and -not (Test-DocsRelativePath -Path $diagnosticPath)) { throw "DOCS_IDENTITY_INPUT_INVALID: Path '$diagnosticPath' is not a relative POSIX path." }
    if ([string]::IsNullOrWhiteSpace($Message)) { throw 'DOCS_IDENTITY_INPUT_INVALID: Message must not be blank.' }
    if ($AnalyzerId -cnotmatch $script:DocsSurfaceIdentifierPattern) { throw "DOCS_IDENTITY_INPUT_INVALID: AnalyzerId '$AnalyzerId' is not an identifier." }

    if ($PSBoundParameters.ContainsKey('Severity')) {
        if (@('error', 'warning', 'information') -cnotcontains $Severity) { throw "DOCS_IDENTITY_INPUT_INVALID: Severity '$Severity' is not one of error, warning, information." }
        $isBlocking = ($Severity -ceq 'error')
        if ($PSBoundParameters.ContainsKey('Blocking') -and $Blocking -ne $isBlocking) {
            throw "DOCS_IDENTITY_INPUT_INVALID: Blocking $Blocking disagrees with Severity '$Severity'; blocking is true exactly when severity is error."
        }
        $level = $Severity
    } else {
        $isBlocking = $Blocking
        $level = if ($Blocking) { 'error' } else { 'warning' }
    }

    $id = Get-DocsStableId -Prefix 'diagnostic' -Value ([ordered]@{ analyzer = $AnalyzerId; code = $Code; path = $diagnosticPath })
    return [ordered]@{
        id          = $id
        code        = $Code
        severity    = $level
        path        = $diagnosticPath
        message     = $Message
        analyzer_id = $AnalyzerId
        blocking    = $isBlocking
        extensions  = [ordered]@{}
    }
}

Export-ModuleMember -Function `
    Get-DocsElementKind, `
    Test-DocsElementKind, `
    Get-DocsAnalysisMethod, `
    ConvertTo-DocsDeclarationText, `
    Get-DocsDeclarationSha256, `
    Test-DocsRelativePath, `
    Test-DocsFullRevision, `
    Get-DocsStableId, `
    Get-DocsElementId, `
    Test-DocsElementId, `
    New-DocsSurfaceElement, `
    ConvertFrom-DocsSurfaceElement, `
    New-DocsDiagnostic
