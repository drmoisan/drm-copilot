<#
.SYNOPSIS
    Request, response validation and element conversion for the issue #1031 Python-native
    analyzer protocol.

.DESCRIPTION
    Get-DocsPythonNativeConsoleScript maps the script tables of every pyproject.toml input to
    request entries. New-DocsPythonNativeRequest builds the canonical request text from the .py
    inputs (ordinal by path, one leading U+FEFF removed), the analyzer identifiers, the source
    roots, the console scripts and the fixed limits. Test-DocsPythonNativeResponse validates a
    helper response against the request (stdout bound, JSON, closed key sets, protocol
    version, file set, status, identifiers, kinds, line bounds, diagnostic code grammar,
    parent shape). ConvertFrom-DocsPythonNativeResponse builds every element with 1020
    New-DocsSurfaceElement -AnalysisMethod native -SourceText -LineRange and every diagnostic
    through the 1022 diagnostic aggregate; this module computes no identifier, digest or
    canonical JSON of its own.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1031. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSourceText.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsTomlKeys.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerRegistry.psm1') -ErrorAction Stop

$script:DocsPythonNativeStdoutBound = 67108864
$script:DocsPythonNativeCodePattern = '^[A-Z][A-Z0-9_]*$(?![\s\S])'

function Get-DocsPythonNativeKind {
    <#
    .SYNOPSIS
        Returns the element kinds of an analyzer identifier from its committed scanner row, or an empty array.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] [string] $AnalyzerId)

    # Get-DocsAnalyzerRegistration returns a comma-wrapped array: assign it first, never pipe it directly.
    $registration = Get-DocsAnalyzerRegistration
    foreach ($row in $registration) {
        if ([string] $row.Id -ceq $AnalyzerId -and [string] $row.AnalysisMethod -ceq 'scanner') { return , [string[]]@($row.ElementKinds) }
    }
    return , [string[]]@()
}

function Get-DocsPythonNativeSortedInput {
    <#
    .SYNOPSIS
        Returns the captured inputs with text, ordinal by path (private helper).
    .DESCRIPTION
        A SortedDictionary keyed by path plus the input index gives a stable ordinal order; the
        paired-array overload of [Array]::Sort is not used because it leaves the items unsorted
        when called from PowerShell.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput)

    $sorted = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $index = 0
    foreach ($captured in $CapturedInput) {
        if ($null -eq $captured -or $null -eq $captured['text']) { continue }
        $sorted[[string] $captured['path'] + "`n" + $index.ToString('D9')] = $captured
        $index++
    }
    return , [object[]]@($sorted.Values)
}

function Get-DocsPythonNativeConsoleScript {
    <#
    .SYNOPSIS
        Returns one @{ name; table; path; target } entry per script-table entry of every pyproject.toml input.
    .DESCRIPTION
        Inputs are visited ordinally by path and entries keep their order within a file. The
        entries come from 1022 Get-DocsTomlScriptEntry; its diagnostics are reported by the
        scanner and are not returned here.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput)

    [object[]] $inputs = Get-DocsPythonNativeSortedInput -CapturedInput $CapturedInput
    $scripts = [System.Collections.Generic.List[object]]::new()
    foreach ($captured in $inputs) {
        $path = [string] $captured['path']
        if ($path -cne 'pyproject.toml' -and -not $path.EndsWith('/pyproject.toml', [System.StringComparison]::Ordinal)) { continue }
        foreach ($entry in (Get-DocsTomlScriptEntry -Text ([string] $captured['text']))['Entries']) {
            $scripts.Add([ordered]@{ name = [string] $entry['Name']; table = [string] $entry['Table']; path = $path; target = [string] $entry['Target'] })
        }
    }
    return , $scripts.ToArray()
}

function New-DocsPythonNativeRequest {
    <#
    .SYNOPSIS
        Builds the helper request: @{ Text; Paths; AnalyzerId; LineCount }.
    .DESCRIPTION
        Files are the .py inputs with text, ordinal by path, each text with one leading U+FEFF
        removed. Analyzer identifiers are sorted ordinally. Limits are fixed at 50000 files and
        1048576 bytes per file. Text is the 1020 ConvertTo-DocsCanonicalJson serialization, so it
        does not depend on input order. LineCount maps each requested path to its 1020 line
        count, the bound Test-DocsPythonNativeResponse applies to the reported line ranges.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $AnalyzerId,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $SourceRoot,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $ConsoleScript
    )

    [object[]] $inputs = @(Get-DocsPythonNativeSortedInput -CapturedInput $CapturedInput | ForEach-Object { $_ } | Where-Object { ([string] $_['path']).EndsWith('.py', [System.StringComparison]::Ordinal) })
    [string[]] $paths = @($inputs | ForEach-Object { [string] $_['path'] })
    $files = [System.Collections.Generic.List[object]]::new()
    $lineCount = [hashtable]::new([System.StringComparer]::Ordinal)
    foreach ($captured in $inputs) {
        $text = [string] $captured['text']
        $lineCount[[string] $captured['path']] = Get-DocsPythonNativeLineCount -Text $text
        if ($text.StartsWith([char]0xFEFF)) { $text = $text.Substring(1) }
        $files.Add([ordered]@{ path = [string] $captured['path']; text = $text })
    }
    [string[]] $analyzers = @($AnalyzerId)
    [Array]::Sort($analyzers, [System.StringComparer]::Ordinal)
    $request = [ordered]@{
        analyzers        = $analyzers
        console_scripts  = @($ConsoleScript)
        files            = $files.ToArray()
        limits           = [ordered]@{ max_file_bytes = 1048576; max_files = 50000 }
        protocol_version = 1
        source_roots     = @($SourceRoot)
    }
    return @{ Text = (ConvertTo-DocsCanonicalJson -Value $request); Paths = $paths; AnalyzerId = $analyzers; LineCount = $lineCount }
}

function Get-DocsPythonNativeLineCount {
    <#
    .SYNOPSIS
        Returns the 1020 line count of a text: BOM removed, CRLF and CR to LF, one trailing LF removed (private helper).
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    $normalized = $Text
    if ($normalized.StartsWith([char]0xFEFF)) { $normalized = $normalized.Substring(1) }
    $normalized = $normalized.Replace("`r`n", "`n").Replace("`r", "`n")
    if ($normalized.EndsWith("`n")) { $normalized = $normalized.Substring(0, $normalized.Length - 1) }
    if ($normalized.Length -eq 0) { return 0 }
    return $normalized.Split("`n").Count
}

function Test-DocsPythonNativeKeySet {
    <#
    .SYNOPSIS
        Throws when a value is not an object with exactly the named keys (private helper).
    #>
    [CmdletBinding()]
    param([AllowNull()] [object] $Value, [Parameter(Mandatory = $true)] [string[]] $Key, [Parameter(Mandatory = $true)] [string] $Where)

    if ($Value -isnot [System.Collections.IDictionary]) { throw "$Where is not an object" }
    [string[]] $present = @($Value.Keys | ForEach-Object { [string] $_ })
    [Array]::Sort($present, [System.StringComparer]::Ordinal)
    [string[]] $expected = @($Key)
    [Array]::Sort($expected, [System.StringComparer]::Ordinal)
    if (($present -join "`n") -cne ($expected -join "`n")) { throw "$Where does not have exactly the keys $($expected -join ', ')" }
}

function Test-DocsPythonNativeFact {
    <#
    .SYNOPSIS
        Throws when one fact is outside the protocol (private helper).
    #>
    [CmdletBinding()]
    param([AllowNull()] [object] $Fact, [Parameter(Mandatory = $true)] [string[]] $AnalyzerId, [Parameter(Mandatory = $true)] [int] $LineCount)

    Test-DocsPythonNativeKeySet -Value $Fact -Key @('analyzer_id', 'kind', 'declaration', 'name', 'parent', 'line_start', 'line_end', 'properties') -Where 'a fact'
    $analyzer = $Fact['analyzer_id']
    if ($analyzer -isnot [string] -or $AnalyzerId -cnotcontains $analyzer) { throw 'a fact names an analyzer outside the request' }
    if ((Get-DocsPythonNativeKind -AnalyzerId $analyzer) -cnotcontains [string] $Fact['kind']) { throw 'a fact kind is outside its analyzer kinds' }
    foreach ($field in 'declaration', 'name') { if ($Fact[$field] -isnot [string]) { throw "a fact $field is not a string" } }
    $start = $Fact['line_start']
    $end = $Fact['line_end']
    if ([string] $Fact['kind'] -ceq 'architecture-component') {
        if ($null -ne $start -or $null -ne $end) { throw 'an architecture-component fact carries line bounds' }
    } elseif ($start -isnot [long] -or $end -isnot [long] -or $start -lt 1 -or $start -gt $end -or $end -gt $LineCount) {
        throw 'a fact line range is outside the file'
    }
    $parent = $Fact['parent']
    if ($null -ne $parent) {
        Test-DocsPythonNativeKeySet -Value $parent -Key @('kind', 'declaration', 'path') -Where 'a fact parent'
        if ([string] $parent['kind'] -cne 'cli-command' -or $parent['declaration'] -isnot [string] -or $parent['path'] -isnot [string]) { throw 'a fact parent is not a cli-command reference' }
    }
    if ($Fact['properties'] -isnot [System.Collections.IDictionary]) { throw 'fact properties are not an object' }
}

function Test-DocsPythonNativeResponseCore {
    <#
    .SYNOPSIS
        Parses and validates a response; returns the parsed value or throws (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $ResponseText, [Parameter(Mandatory = $true)] [hashtable] $Request, [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $LineCount)

    if ($null -eq $ResponseText -or $ResponseText.Length -gt $script:DocsPythonNativeStdoutBound) { throw 'the response is empty or above the stdout bound' }
    $parsed = ConvertFrom-DocsJsonText -Text $ResponseText
    if (@($parsed.Findings).Count -gt 0) { throw 'the response is not valid JSON' }
    $response = $parsed.Value
    Test-DocsPythonNativeKeySet -Value $response -Key @('protocol_version', 'files') -Where 'the response'
    if ($response['protocol_version'] -isnot [long] -or $response['protocol_version'] -ne 1) { throw 'protocol_version is not 1' }
    $files = $response['files']
    if ($files -isnot [object[]]) { throw 'files is not an array' }
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    [string[]] $analyzers = @($Request['AnalyzerId'])
    foreach ($file in $files) {
        Test-DocsPythonNativeKeySet -Value $file -Key @('path', 'status', 'facts', 'diagnostics') -Where 'a file entry'
        $path = $file['path']
        if ($path -isnot [string] -or -not $LineCount.Contains($path) -or -not $seen.Add($path)) { throw 'a file path is outside the request or repeated' }
        if (@('ok', 'parse-error') -cnotcontains [string] $file['status']) { throw 'a file status is invalid' }
        if ($file['facts'] -isnot [object[]] -or $file['diagnostics'] -isnot [object[]]) { throw 'facts or diagnostics is not an array' }
        if ([string] $file['status'] -ceq 'parse-error' -and $file['facts'].Count -gt 0) { throw 'a parse-error file carries facts' }
        foreach ($fact in $file['facts']) { Test-DocsPythonNativeFact -Fact $fact -AnalyzerId $analyzers -LineCount ([int] $LineCount[$path]) }
        foreach ($diagnostic in $file['diagnostics']) {
            Test-DocsPythonNativeKeySet -Value $diagnostic -Key @('analyzer_id', 'code', 'line', 'blocking') -Where 'a diagnostic'
            if ($analyzers -cnotcontains [string] $diagnostic['analyzer_id']) { throw 'a diagnostic names an analyzer outside the request' }
            if ($diagnostic['code'] -isnot [string] -or $diagnostic['code'] -cnotmatch $script:DocsPythonNativeCodePattern) { throw 'a diagnostic code does not match the code grammar' }
            if ($diagnostic['line'] -isnot [long] -or $diagnostic['line'] -lt 1 -or $diagnostic['blocking'] -isnot [bool]) { throw 'a diagnostic line or blocking flag is invalid' }
        }
    }
    if ($seen.Count -ne $LineCount.Count) { throw 'the response file set differs from the request file set' }
    return $response
}

function Test-DocsPythonNativeResponse {
    <#
    .SYNOPSIS
        Validates a helper response against its request: @{ Valid; Response; Problem }.
    .DESCRIPTION
        Request is the New-DocsPythonNativeRequest result, whose LineCount supplies the 1020
        line bound of each requested file. Valid is $false, with Problem naming the first
        defect, for: text above 67108864 characters, invalid JSON, a key set that is not exactly
        the protocol's at any level, protocol_version other than 1, a file set that differs from
        the request's, an invalid status, an analyzer or kind outside the request, a line range
        outside 1 <= line_start <= line_end <= line count (null only for
        architecture-component), a diagnostic code outside ^[A-Z][A-Z0-9_]*$, and a parent that
        is not {kind cli-command, declaration, path}.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $ResponseText,
        [Parameter(Mandatory = $true)] [hashtable] $Request
    )

    try {
        $response = Test-DocsPythonNativeResponseCore -ResponseText $ResponseText -Request $Request -LineCount $Request['LineCount']
        return @{ Valid = $true; Response = $response; Problem = $null }
    } catch {
        return @{ Valid = $false; Response = $null; Problem = $_.Exception.Message }
    }
}

function ConvertFrom-DocsPythonNativeResponse {
    <#
    .SYNOPSIS
        Builds native elements and diagnostics from a validated response: @{ Output; ParseFailed }.
    .DESCRIPTION
        Output maps each analyzer identifier of the response to @{ Elements; Diagnostics }.
        Every element is built with New-DocsSurfaceElement -AnalysisMethod native -SourceText
        (the captured text) -LineRange (null for architecture-component) -ParentId (the
        Get-DocsElementId of the parent reference) -Property; every diagnostic goes through
        Add-DocsDiagnosticOccurrence with severity error when blocking, else warning, and the
        code unchanged. ParseFailed lists the parse-error paths. Any rejection by the 1020
        functions (DOCS_IDENTITY_INPUT_INVALID, DOCS_DIGEST_RANGE_INVALID) is thrown.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Response,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput
    )

    $text = [hashtable]::new([System.StringComparer]::Ordinal)
    foreach ($captured in @($CapturedInput)) { if ($null -ne $captured) { $text[[string] $captured['path']] = $captured['text'] } }
    $elements = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $aggregate = New-DocsDiagnosticAggregate
    $failed = [System.Collections.Generic.List[string]]::new()
    foreach ($file in @($Response['files'])) {
        $path = [string] $file['path']
        if ([string] $file['status'] -ceq 'parse-error') { $failed.Add($path) }
        foreach ($fact in @($file['facts'])) {
            $analyzer = [string] $fact['analyzer_id']
            if (-not $elements.ContainsKey($analyzer)) { $elements[$analyzer] = [System.Collections.Generic.List[object]]::new() }
            $parentId = $null
            if ($null -ne $fact['parent']) { $parentId = Get-DocsElementId -Kind ([string] $fact['parent']['kind']) -Path ([string] $fact['parent']['path']) -Declaration ([string] $fact['parent']['declaration']) }
            $range = if ($null -eq $fact['line_start']) { $null } else { [int[]]@([int] $fact['line_start'], [int] $fact['line_end']) }
            $elements[$analyzer].Add((New-DocsSurfaceElement -Kind ([string] $fact['kind']) -Path $path -Declaration ([string] $fact['declaration']) -Name ([string] $fact['name']) -AnalyzerId $analyzer -AnalysisMethod 'native' -SourceText ([string] $text[$path]) -ParentId $parentId -LineRange $range -Property $fact['properties']))
        }
        foreach ($diagnostic in @($file['diagnostics'])) {
            $severity = if ([bool] $diagnostic['blocking']) { 'error' } else { 'warning' }
            Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId ([string] $diagnostic['analyzer_id']) -Code ([string] $diagnostic['code']) -Path $path -Line ([int] $diagnostic['line']) -Severity $severity
        }
    }
    $output = [hashtable]::new([System.StringComparer]::Ordinal)
    foreach ($file in @($Response['files'])) {
        foreach ($record in @(@($file['facts']) + @($file['diagnostics']))) {
            $analyzer = [string] $record['analyzer_id']
            if (-not $output.ContainsKey($analyzer)) { $output[$analyzer] = @{ Elements = [object[]]@(); Diagnostics = [object[]]@() } }
        }
    }
    foreach ($analyzer in @($output.Keys)) {
        $output[$analyzer] = @{
            Elements    = [object[]]@(if ($elements.ContainsKey($analyzer)) { $elements[$analyzer] })
            Diagnostics = [object[]]@($aggregate.Diagnostics | Where-Object { [string] $_['analyzer_id'] -ceq $analyzer })
        }
    }
    return @{ Output = $output; ParseFailed = $failed.ToArray() }
}

Export-ModuleMember -Function `
    Get-DocsPythonNativeKind, `
    Get-DocsPythonNativeConsoleScript, `
    New-DocsPythonNativeRequest, `
    Test-DocsPythonNativeResponse, `
    ConvertFrom-DocsPythonNativeResponse
