<#
.SYNOPSIS
    Shared pure helpers for the TypeScript and .NET lexical scanners of the documentation
    library: input selection, module paths, token-span helpers, literal extraction, route
    template joining, diagnostic aggregation, the precision-limit marker and the
    machine-readable precision-limit table.

.DESCRIPTION
    Analyzers aggregate diagnostics in a set keyed by (code, path) and convert them with
    ConvertTo-DocsScannerDiagnostic, which routes every (analyzer_id, code) pair that is a row of
    Get-DocsScannerPrecisionLimit through New-DocsScannerPrecisionLimitDiagnostic (marker
    docs.precision-limit with the row's element_kind) and every other code through
    New-DocsDiagnostic without the marker. Codes follow the docs common diagnostic grammar
    ^[A-Z][A-Z0-9_]*$. Every function is pure: no filesystem, clock, process, environment or
    module-scope mutable state; inputs are not mutated.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Get-DocsScannerPrecisionLimit is the shipped statement of the scanner precision limit.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

function Get-DocsScannerRecordValue {
    <#
    .SYNOPSIS
        Returns a member of a hashtable or object record, or $null when absent (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [AllowNull()] [object] $Record,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    if ($null -eq $Record) { return $null }
    if ($Record -is [System.Collections.IDictionary]) { if ($Record.Contains($Name)) { return $Record[$Name] } return $null }
    $property = $Record.PSObject.Properties[$Name]
    if ($null -eq $property) { return $null }
    return $property.Value
}

function Get-DocsScannerSortedItem {
    <#
    .SYNOPSIS
        Returns Item ordered by the parallel Key array with ordinal comparison, stable for equal keys (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Item,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Key
    )

    $map = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
    for ($index = 0; $index -lt $Item.Count; $index++) { $map[$Key[$index] + "`n" + $index.ToString('D9')] = $Item[$index] }
    [object[]] $sorted = @($map.Values)
    return , $sorted
}

function Select-DocsScannerInput {
    <#
    .SYNOPSIS
        Returns the captured inputs whose path matches a suffix (and basename pattern), sorted by path.
    .DESCRIPTION
        Suffix matching is ordinal and case-insensitive on the POSIX path; ExcludeSuffix drops a
        match; BasenamePattern is a case-insensitive regular expression over the last segment.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowNull()] [object[]] $CapturedInput,
        [AllowEmptyCollection()] [AllowNull()] [string[]] $Suffix,
        [AllowEmptyCollection()] [AllowNull()] [string[]] $ExcludeSuffix,
        [AllowNull()] [string] $BasenamePattern
    )

    $selected = [System.Collections.Generic.List[object]]::new()
    $suffixes = @($Suffix | Where-Object { -not [string]::IsNullOrEmpty($_) })
    $excluded = @($ExcludeSuffix | Where-Object { -not [string]::IsNullOrEmpty($_) })
    foreach ($captured in @($CapturedInput)) {
        $path = Get-DocsScannerRecordValue -Record $captured -Name 'path'
        if ($path -isnot [string] -or [string]::IsNullOrEmpty($path)) { continue }
        $isMatch = ($suffixes.Count -eq 0)
        foreach ($candidate in $suffixes) { if ($path.EndsWith($candidate, [System.StringComparison]::OrdinalIgnoreCase)) { $isMatch = $true } }
        if (-not $isMatch) { continue }
        $isExcluded = $false
        foreach ($candidate in $excluded) { if ($path.EndsWith($candidate, [System.StringComparison]::OrdinalIgnoreCase)) { $isExcluded = $true } }
        if ($isExcluded) { continue }
        if (-not [string]::IsNullOrEmpty($BasenamePattern)) {
            $basename = $path.Substring($path.LastIndexOf('/') + 1)
            if (-not [regex]::IsMatch($basename, $BasenamePattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::CultureInvariant)) { continue }
        }
        $selected.Add($captured)
    }
    [object[]] $items = $selected.ToArray()
    [string[]] $keys = @($items | ForEach-Object { [string] (Get-DocsScannerRecordValue -Record $_ -Name 'path') })
    return Get-DocsScannerSortedItem -Item $items -Key $keys
}

function Get-DocsScannerModulePath {
    <#
    .SYNOPSIS
        Returns the path relative to the longest matching source root with its extension removed.
    .DESCRIPTION
        A root matches when the path begins with the root followed by '/'; '' or '.' matches every
        path without removing a prefix; with no match the repository-relative path is used.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $Path,
        [AllowEmptyCollection()] [AllowNull()] [string[]] $SourceRoot
    )

    $relative = $Path
    $bestLength = -1
    foreach ($root in @($SourceRoot)) {
        if ($null -eq $root) { continue }
        $trimmed = ([string] $root).Trim('/')
        if ($trimmed -ceq '.' -or $trimmed.Length -eq 0) {
            if ($bestLength -lt 0) { $bestLength = 0; $relative = $Path }
            continue
        }
        $prefix = $trimmed + '/'
        if ($Path.StartsWith($prefix, [System.StringComparison]::Ordinal) -and $trimmed.Length -gt $bestLength) {
            $bestLength = $trimmed.Length
            $relative = $Path.Substring($prefix.Length)
        }
    }
    $slash = $relative.LastIndexOf('/')
    $dot = $relative.LastIndexOf('.')
    if ($dot -gt $slash + 1) { $relative = $relative.Substring(0, $dot) }
    return $relative
}

function Test-DocsScannerPunct {
    <#
    .SYNOPSIS
        Returns $true when the token is a punctuator with the given text (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] [object] $Token,
        [Parameter(Mandatory = $true)] [string[]] $Text
    )

    if ($null -eq $Token) { return $false }
    if ([string] (Get-DocsScannerRecordValue -Record $Token -Name 'Kind') -cne 'punct') { return $false }
    return $Text -ccontains [string] (Get-DocsScannerRecordValue -Record $Token -Name 'Text')
}

function Get-DocsScannerMatchingClose {
    <#
    .SYNOPSIS
        Returns the index of the bracket closing the opener at OpenIndex, or -1.
    .DESCRIPTION
        The opener must be a punctuator '(', '[' or '{'; an unbalanced stream or a non-opener gives -1.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $OpenIndex
    )

    if ($OpenIndex -lt 0 -or $OpenIndex -ge $Tokens.Count) { return -1 }
    if (-not (Test-DocsScannerPunct -Token $Tokens[$OpenIndex] -Text @('(', '[', '{'))) { return -1 }
    $depth = 0
    for ($index = $OpenIndex + 1; $index -lt $Tokens.Count; $index++) {
        if (Test-DocsScannerPunct -Token $Tokens[$index] -Text @('(', '[', '{')) { $depth++; continue }
        if (Test-DocsScannerPunct -Token $Tokens[$index] -Text @(')', ']', '}')) {
            if ($depth -eq 0) { return $index }
            $depth--
        }
    }
    return -1
}

function Get-DocsScannerCallArgument {
    <#
    .SYNOPSIS
        Returns the top-level argument spans @{ Start; End } (inclusive token indices) of a call.
    .DESCRIPTION
        Arguments split at depth-zero commas; an empty span and an unbalanced opener yield no entry.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $OpenIndex
    )

    $spans = [System.Collections.Generic.List[object]]::new()
    $close = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $OpenIndex
    if ($close -lt 0) { return , $spans.ToArray() }
    $start = $OpenIndex + 1
    $depth = 0
    for ($index = $OpenIndex + 1; $index -le $close; $index++) {
        $token = $Tokens[$index]
        $isBoundary = ($index -eq $close) -or ($depth -eq 0 -and (Test-DocsScannerPunct -Token $token -Text @(',')))
        if ($isBoundary) {
            if ($index - 1 -ge $start) { $spans.Add(@{ Start = $start; End = $index - 1 }) }
            $start = $index + 1
            continue
        }
        if (Test-DocsScannerPunct -Token $token -Text @('(', '[', '{')) { $depth++ }
        elseif (Test-DocsScannerPunct -Token $token -Text @(')', ']', '}')) { $depth-- }
    }
    return , $spans.ToArray()
}

function Get-DocsScannerLiteral {
    <#
    .SYNOPSIS
        Returns the decoded value of a single non-dynamic string literal or a literal-only '+'
        concatenation within Span, else $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Span
    )

    $start = [int] $Span['Start']
    $end = [int] $Span['End']
    if ($start -lt 0 -or $end -ge $Tokens.Count -or $start -gt $end) { return $null }
    $builder = [System.Text.StringBuilder]::new()
    for ($index = $start; $index -le $end; $index++) {
        $token = $Tokens[$index]
        $expectLiteral = ((($index - $start) % 2) -eq 0)
        if ($expectLiteral) {
            $kind = [string] (Get-DocsScannerRecordValue -Record $token -Name 'Kind')
            $isDynamic = [bool] (Get-DocsScannerRecordValue -Record $token -Name 'Dynamic')
            if (($kind -cne 'string' -and $kind -cne 'template') -or $isDynamic) { return $null }
            $value = Get-DocsScannerRecordValue -Record $token -Name 'Value'
            if ($null -eq $value) { return $null }
            [void]$builder.Append([string] $value)
        } elseif (-not (Test-DocsScannerPunct -Token $token -Text @('+'))) {
            return $null
        }
    }
    if ((($end - $start) % 2) -ne 0) { return $null }
    return $builder.ToString()
}

function Join-DocsRouteTemplate {
    <#
    .SYNOPSIS
        Joins a prefix and a template into one route template beginning with '/'.
    .DESCRIPTION
        Outer slashes are removed, non-empty parts are joined with one '/', runs of '/' collapse,
        case is kept; two empty parts give '/'.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $Prefix,
        [AllowNull()] [AllowEmptyString()] [string] $Template
    )

    $parts = [System.Collections.Generic.List[string]]::new()
    foreach ($part in @($Prefix, $Template)) {
        if ($null -eq $part) { continue }
        $trimmed = $part.Trim('/')
        if ($trimmed.Length -gt 0) { $parts.Add($trimmed) }
    }
    $joined = '/' + ($parts -join '/')
    return [regex]::Replace($joined, '/{2,}', '/')
}

function New-DocsScannerDiagnosticSet {
    <#
    .SYNOPSIS
        Returns an empty ordinal aggregation map keyed by (code, path).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Paths and codes are case-sensitive; an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    return [hashtable]::new([System.StringComparer]::Ordinal)
}

function Add-DocsScannerDiagnostic {
    <#
    .SYNOPSIS
        Records one occurrence of a diagnostic code at a path and line in the aggregation set.
    .DESCRIPTION
        The (Code, Path) entry keeps the count, the lowest line at or above 1, and whether any
        occurrence was blocking.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Set,
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $Path,
        [Parameter(Mandatory = $true)] [int] $Line,
        [bool] $Blocking = $false
    )

    $diagnosticPath = if ([string]::IsNullOrEmpty($Path)) { $null } else { $Path }
    $key = $Code + "`n" + [string] $diagnosticPath
    if (-not $Set.ContainsKey($key)) {
        $Set[$key] = [ordered]@{ Code = $Code; Path = $diagnosticPath; Count = 0; FirstLine = 0; Blocking = $false }
    }
    $entry = $Set[$key]
    $entry['Count'] = [int] $entry['Count'] + 1
    if ($Line -ge 1 -and ([int] $entry['FirstLine'] -eq 0 -or $Line -lt [int] $entry['FirstLine'])) { $entry['FirstLine'] = $Line }
    if ($Blocking) { $entry['Blocking'] = $true }
}

function New-DocsScannerPrecisionLimitDiagnostic {
    <#
    .SYNOPSIS
        Returns a non-blocking warning diagnostic carrying the docs.precision-limit marker.
    .DESCRIPTION
        Built by New-DocsDiagnostic -Severity warning; extensions['docs.precision-limit'] is set to
        @{ element_kind = <ElementKind> } (the map is created when absent or $null; other keys are
        kept). Throws for a $null or empty Path and for an ElementKind outside Get-DocsElementKind.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $AnalyzerId,
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $Path,
        [Parameter(Mandatory = $true)] [string] $Message,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $ElementKind
    )

    if ([string]::IsNullOrEmpty($Path)) { throw 'DOCS_SCANNER_INPUT_INVALID: Path of a precision-limit diagnostic must not be null or empty.' }
    if (-not (Test-DocsElementKind -Kind $ElementKind)) { throw "DOCS_SCANNER_INPUT_INVALID: ElementKind '$ElementKind' is not a docs element kind." }
    $record = New-DocsDiagnostic -Code $Code -Path $Path -Message $Message -AnalyzerId $AnalyzerId -Severity 'warning'
    if (-not $record.Contains('extensions') -or $null -eq $record['extensions']) { $record['extensions'] = [ordered]@{} }
    $record['extensions']['docs.precision-limit'] = [ordered]@{ element_kind = $ElementKind }
    return $record
}

function ConvertTo-DocsScannerDiagnostic {
    <#
    .SYNOPSIS
        Converts an aggregation set into diagnostic records under AnalyzerId, sorted by id.
    .DESCRIPTION
        A (AnalyzerId, code) row of Get-DocsScannerPrecisionLimit is built with
        New-DocsScannerPrecisionLimitDiagnostic and that row's element_kind; every other code is
        built with New-DocsDiagnostic (error when blocking, else warning) without the marker. The
        message states the occurrence count and first line and never quotes source text.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Set,
        [Parameter(Mandatory = $true)] [string] $AnalyzerId
    )

    $kindByCode = @{}
    $limitRows = Get-DocsScannerPrecisionLimit
    foreach ($row in $limitRows) {
        if ([string] $row['analyzer_id'] -ceq $AnalyzerId) { $kindByCode[[string] $row['code']] = [string] $row['element_kind'] }
    }
    [string[]] $keys = @($Set.Keys | ForEach-Object { [string] $_ })
    [Array]::Sort($keys, [System.StringComparer]::Ordinal)
    $records = [System.Collections.Generic.List[object]]::new()
    foreach ($key in $keys) {
        $entry = $Set[$key]
        $code = [string] $entry['Code']
        $path = $entry['Path']
        $count = [int] $entry['Count']
        $message = '{0}: {1} occurrence(s); first at line {2}.' -f $code, $count, [int] $entry['FirstLine']
        if ($kindByCode.ContainsKey($code) -and -not [string]::IsNullOrEmpty([string] $path)) {
            $records.Add((New-DocsScannerPrecisionLimitDiagnostic -AnalyzerId $AnalyzerId -Code $code -Path $path -Message $message -ElementKind $kindByCode[$code]))
        } else {
            $severity = if ([bool] $entry['Blocking']) { 'error' } else { 'warning' }
            $records.Add((New-DocsDiagnostic -Code $code -Path $path -Message $message -AnalyzerId $AnalyzerId -Severity $severity))
        }
    }
    [object[]] $items = $records.ToArray()
    [string[]] $ids = @($items | ForEach-Object { [string] $_['id'] })
    return Get-DocsScannerSortedItem -Item $items -Key $ids
}

function Get-DocsScannerInputDiagnosticCode {
    <#
    .SYNOPSIS
        Returns INPUT_OVER_BOUND or INPUT_UNDECODABLE for a captured input whose text is $null, else $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowNull()] [object] $CapturedInput)

    if ($null -ne (Get-DocsScannerRecordValue -Record $CapturedInput -Name 'text')) { return $null }
    $diagnostic = Get-DocsScannerRecordValue -Record $CapturedInput -Name 'diagnostic'
    if ([string] (Get-DocsScannerRecordValue -Record $diagnostic -Name 'code') -ceq 'DOCS_INPUT_TOO_LARGE') { return 'INPUT_OVER_BOUND' }
    return 'INPUT_UNDECODABLE'
}

function ConvertTo-DocsScannerElementList {
    <#
    .SYNOPSIS
        Removes repeated element identities, recording DUPLICATE_DECLARATION, and sorts by element_id.
    .DESCRIPTION
        For one element_id the first by line_range start (then input order) is kept; every other
        occurrence adds DUPLICATE_DECLARATION at its path and line to Set.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Element identifiers are case-sensitive; an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowNull()] [object[]] $Element,
        [Parameter(Mandatory = $true)] [hashtable] $Set
    )

    $kept = [hashtable]::new([System.StringComparer]::Ordinal)
    $order = [System.Collections.Generic.List[string]]::new()
    foreach ($candidate in @($Element)) {
        if ($null -eq $candidate) { continue }
        $id = [string] $candidate['element_id']
        $line = [int] $candidate['line_range']['start']
        if (-not $kept.ContainsKey($id)) { $kept[$id] = $candidate; $order.Add($id); continue }
        $current = $kept[$id]
        $currentLine = [int] $current['line_range']['start']
        if ($line -lt $currentLine) {
            Add-DocsScannerDiagnostic -Set $Set -Code 'DUPLICATE_DECLARATION' -Path ([string] $current['path']) -Line $currentLine
            $kept[$id] = $candidate
        } else {
            Add-DocsScannerDiagnostic -Set $Set -Code 'DUPLICATE_DECLARATION' -Path ([string] $candidate['path']) -Line $line
        }
    }
    [string[]] $ids = $order.ToArray()
    [Array]::Sort($ids, [System.StringComparer]::Ordinal)
    [object[]] $items = @($ids | ForEach-Object { $kept[$_] })
    return , $items
}

function Get-DocsScannerPrecisionLimit {
    <#
    .SYNOPSIS
        Returns the scanner precision-limit table: one row per (analyzer_id, code).
    .DESCRIPTION
        Each row carries analyzer_id, code, element_kind, construct and consequence, ordered by
        analyzer_id then code (ordinal); the coverage ledger records an emitted row as deferred.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param()

    $rows = @(
        @('typescript-cli', 'CLI_DYNAMIC_REGISTRATION', 'cli-command', 'Non-literal or template-with-substitution command or option names, registration in a loop body, spread arguments, computed object keys', 'No element'),
        @('typescript-cli', 'CLI_UNBOUND_REGISTRATION', 'cli-command', '.addCommand or .command on a receiver that is not tracked in the file', 'No element'),
        @('typescript-cli', 'CLI_COMMAND_MODULE_UNRESOLVED', 'cli-command', 'yargs .command(require(...)), .command(importedModule), .commandDir(...)', 'No element'),
        @('typescript-http', 'HTTP_DYNAMIC_ROUTE', 'http-route', 'Regex or non-literal path, non-literal method or url', 'No element'),
        @('typescript-http', 'HTTP_PREFIX_DYNAMIC', 'http-route', 'Mount or plugin prefix that is not a literal', 'Element with a <dynamic> segment and prefix_resolved: false'),
        @('typescript-http', 'HTTP_MOUNT_UNRESOLVED', 'http-route', 'use with an untracked router, plugin from a package import', 'Routes of the mounted router keep their own template (mounted: false) or are absent when the router is not captured'),
        @('typescript-exports', 'TS_REEXPORT_UNRESOLVED', 'public-symbol', 'export * from a package, an unresolvable relative specifier, a cycle, depth above 16', 'Re-exported names absent; other exports kept'),
        @('typescript-exports', 'TS_EXPORT_PATTERN_UNSUPPORTED', 'public-symbol', 'Exported destructuring with defaults, rest or nested patterns', 'No element for the pattern'),
        @('typescript-exports', 'TS_EXPORT_ASSIGNMENT', 'public-symbol', 'export =', 'Element default with export_form: assignment'),
        @('typescript-exports', 'TS_AMBIENT_MODULE', 'public-symbol', 'declare module and declare global bodies', 'No element'),
        @('typescript-exports', 'TS_COMMONJS_EXPORT', 'public-symbol', 'module.exports or exports.x in a TypeScript file', 'No element'),
        @('dotnet-http', 'HTTP_DYNAMIC_ROUTE', 'http-route', '[Route(Constants.X)], nameof(...), interpolated templates with holes, non-literal minimal-API template or method list', 'No element'),
        @('dotnet-http', 'HTTP_PREFIX_DYNAMIC', 'http-route', 'MapGroup with a non-literal prefix', 'Element with a <dynamic> segment and prefix_resolved: false'),
        @('dotnet-http', 'HTTP_RECEIVER_UNRESOLVED', 'http-route', 'Map* on a method parameter', 'Element without prefix, prefix_resolved: false'),
        @('dotnet-http', 'HTTP_ROUTE_TOKEN_UNRESOLVED', 'http-route', '[area] without a literal [Area]', 'No element'),
        @('dotnet-http', 'HTTP_ENDPOINT_KIND_UNSUPPORTED', 'http-route', 'MapHub<T>, MapGrpcService<T>, MapHealthChecks, MapFallback, MapRazorPages', 'No element'),
        @('dotnet-http', 'DOTNET_ROUTE_INHERITED_UNRESOLVED', 'http-route', 'Verb attribute in a class with no route whose base is not Controller or ControllerBase', 'No element'),
        @('dotnet-http', 'DOTNET_CONVENTIONAL_ROUTING_UNRESOLVED', 'http-route', 'MapControllerRoute, MapDefaultControllerRoute', 'No element'),
        @('dotnet-http', 'CSHARP_CONDITIONAL_COMPILATION', 'http-route', 'File containing #if', 'Elements from both branches; duplicates reported as DUPLICATE_DECLARATION'),
        @('dotnet-public-api', 'CSHARP_DECLARATION_UNRECOGNIZED', 'public-symbol', 'Declaration the scanner cannot delimit', 'No element for that declaration'),
        @('dotnet-public-api', 'CSHARP_CONDITIONAL_COMPILATION', 'public-symbol', 'File containing #if', 'Elements from both branches; duplicates reported as DUPLICATE_DECLARATION')
    )
    [object[]] $records = @($rows | ForEach-Object { [ordered]@{ analyzer_id = $_[0]; code = $_[1]; element_kind = $_[2]; construct = $_[3]; consequence = $_[4] } })
    [string[]] $keys = @($records | ForEach-Object { [string] $_['analyzer_id'] + "`n" + [string] $_['code'] })
    return Get-DocsScannerSortedItem -Item $records -Key $keys
}

Export-ModuleMember -Function `
    Select-DocsScannerInput, `
    Get-DocsScannerModulePath, `
    Get-DocsScannerMatchingClose, `
    Get-DocsScannerCallArgument, `
    Get-DocsScannerLiteral, `
    Join-DocsRouteTemplate, `
    New-DocsScannerDiagnosticSet, `
    Add-DocsScannerDiagnostic, `
    ConvertTo-DocsScannerDiagnostic, `
    New-DocsScannerPrecisionLimitDiagnostic, `
    Get-DocsScannerInputDiagnosticCode, `
    ConvertTo-DocsScannerElementList, `
    Get-DocsScannerPrecisionLimit
