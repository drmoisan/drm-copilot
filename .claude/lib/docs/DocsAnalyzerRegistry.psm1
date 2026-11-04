<#
.SYNOPSIS
    Analyzer contract, registration tables, selection, captured inputs and analyzer invocation
    for the documentation library.

.DESCRIPTION
    Two committed provider tables hold analyzer registrations: the scanner table
    $script:DocsAnalyzerRow (scanner rows of 1022 and 1033) and the native table
    $script:DocsAnalyzerNativeRow (native rows of 1031). Get-DocsAnalyzerRegistration returns the
    scanner rows followed by the native rows. Rows are unique on (Id, AnalysisMethod), and a
    native row requires a scanner row with the same Id, because the scanner baseline is always
    available.

    Invoke-DocsAnalyzer imports the registered module through the -ImportModule seam, calls the
    analyzer function and validates its output: kinds within the registration, analyzer_id and
    analysis_method equal to the row, recomputed element identifiers, and source_sha256 equal to
    the declaration-lines digest of the captured input. Output that fails a check is rejected.

    Row form, one row per line:
    [pscustomobject]@{ Id = '<identifier>'; Version = '1.0.0'; AnalysisMethod = '<scanner|native>'; ElementKinds = @('<kind>'); Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzer<Name>.psm1'); Function = 'Invoke-DocsAnalyzer<Name>' }

.NOTES
    Issue #1020. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

$script:DocsAnalyzerRow = @(
    # --- 1022: Python and configuration analyzers ---
    [pscustomobject]@{ Id = 'config-files'; Version = '1.0.0'; AnalysisMethod = 'scanner'; ElementKinds = @('config-key'); Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerConfigFiles.psm1'); Function = 'Invoke-DocsAnalyzerConfigFiles' }
    [pscustomobject]@{ Id = 'python-architecture'; Version = '1.0.0'; AnalysisMethod = 'scanner'; ElementKinds = @('architecture-component'); Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerArchitecture.psm1'); Function = 'Invoke-DocsAnalyzerPythonArchitecture' }
    [pscustomobject]@{ Id = 'python-cli'; Version = '1.0.0'; AnalysisMethod = 'scanner'; ElementKinds = @('cli-command', 'cli-option'); Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerPythonCli.psm1'); Function = 'Invoke-DocsAnalyzerPythonCli' }
    [pscustomobject]@{ Id = 'python-http'; Version = '1.0.0'; AnalysisMethod = 'scanner'; ElementKinds = @('http-route'); Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerPythonHttp.psm1'); Function = 'Invoke-DocsAnalyzerPythonHttp' }
    [pscustomobject]@{ Id = 'python-public-api'; Version = '1.0.0'; AnalysisMethod = 'scanner'; ElementKinds = @('public-symbol'); Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerPythonApi.psm1'); Function = 'Invoke-DocsAnalyzerPythonApi' }
    # --- 1033: TypeScript and .NET analyzers ---
)

$script:DocsAnalyzerNativeRow = @(
    # --- 1031: Python-native analyzers ---
    [pscustomobject]@{ Id = 'python-architecture'; Version = '1.0.0'; AnalysisMethod = 'native'; ElementKinds = @('architecture-component'); Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerPythonNative.psm1'); Function = 'Invoke-DocsAnalyzerPythonNativeArchitecture' }
    [pscustomobject]@{ Id = 'python-cli'; Version = '1.0.0'; AnalysisMethod = 'native'; ElementKinds = @('cli-command', 'cli-option'); Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerPythonNative.psm1'); Function = 'Invoke-DocsAnalyzerPythonNativeCli' }
    [pscustomobject]@{ Id = 'python-http'; Version = '1.0.0'; AnalysisMethod = 'native'; ElementKinds = @('http-route'); Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerPythonNative.psm1'); Function = 'Invoke-DocsAnalyzerPythonNativeHttp' }
    [pscustomobject]@{ Id = 'python-public-api'; Version = '1.0.0'; AnalysisMethod = 'native'; ElementKinds = @('public-symbol'); Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerPythonNative.psm1'); Function = 'Invoke-DocsAnalyzerPythonNativeApi' }
)

$script:DocsAnalyzerIdentifierPattern = '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])'
$script:DocsAnalyzerFunctionPattern = '^Invoke-DocsAnalyzer[A-Za-z]+$(?![\s\S])'
$script:DocsAnalyzerDefaultMaxBytes = 1048576

function Get-DocsAnalyzerRowValue {
    <#
    .SYNOPSIS
        Returns a row property value, or $null when the row lacks it (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [AllowNull()] [object] $Row,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    if ($null -eq $Row) { return $null }
    if ($Row -is [System.Collections.IDictionary]) { if ($Row.Contains($Name)) { return $Row[$Name] } return $null }
    $property = $Row.PSObject.Properties[$Name]
    if ($null -eq $property) { return $null }
    return $property.Value
}

function Get-DocsAnalyzerRegistration {
    <#
    .SYNOPSIS
        Returns the scanner provider rows followed by the native provider rows.
    .DESCRIPTION
        ScannerRow and NativeRow default to the committed tables; tests pass in-memory rows to
        prove the order without changing module state.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [AllowNull()] [AllowEmptyCollection()] [object[]] $ScannerRow = $script:DocsAnalyzerRow,
        [AllowNull()] [AllowEmptyCollection()] [object[]] $NativeRow = $script:DocsAnalyzerNativeRow
    )

    $rows = [System.Collections.Generic.List[object]]::new()
    foreach ($row in @($ScannerRow) + @($NativeRow)) { if ($null -ne $row) { $rows.Add($row) } }
    return , $rows.ToArray()
}

function New-DocsRegistrationFinding {
    <#
    .SYNOPSIS
        Builds one DOCS_ANALYZER_REGISTRATION_INVALID finding (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [int] $Index,
        [Parameter(Mandatory = $true)] [string] $Field,
        [Parameter(Mandatory = $true)] [string] $Message
    )

    return New-DocsFinding -Code 'DOCS_ANALYZER_REGISTRATION_INVALID' -Severity 'error' -Pointer "/$Index/$Field" -Message $Message -NextAction "Correct the $Field of analyzer registration row $Index."
}

function Test-DocsAnalyzerModulePath {
    <#
    .SYNOPSIS
        Returns $true when Module resolves inside this directory with a DocsAnalyzer*.psm1 leaf (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] [object] $Module,
        [string] $ScriptRoot = $PSScriptRoot
    )

    if ($Module -isnot [string] -or [string]::IsNullOrWhiteSpace($Module)) { return $false }
    $root = [System.IO.Path]::GetFullPath($ScriptRoot).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    $full = [System.IO.Path]::GetFullPath($Module)
    $comparison = if ($IsWindows) { [System.StringComparison]::OrdinalIgnoreCase } else { [System.StringComparison]::Ordinal }
    return $full.StartsWith($root, $comparison) -and ([System.IO.Path]::GetFileName($full) -like 'DocsAnalyzer*.psm1')
}

function Test-DocsAnalyzerRegistration {
    <#
    .SYNOPSIS
        Validates analyzer registration rows and returns ordered findings.
    .DESCRIPTION
        Each finding is DOCS_ANALYZER_REGISTRATION_INVALID at /<row index>/<field>, where the row
        index is the position in Registration (for the committed registry, the scanner table
        followed by the native table).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyCollection()] [object[]] $Registration)

    $findings = [System.Collections.Generic.List[object]]::new()
    $rows = @($Registration)
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $scannerIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($row in $rows) {
        if ([string] (Get-DocsAnalyzerRowValue -Row $row -Name 'AnalysisMethod') -ceq 'scanner') { [void]$scannerIds.Add([string] (Get-DocsAnalyzerRowValue -Row $row -Name 'Id')) }
    }
    for ($index = 0; $index -lt $rows.Count; $index++) {
        $row = $rows[$index]
        $id = [string] (Get-DocsAnalyzerRowValue -Row $row -Name 'Id')
        $method = [string] (Get-DocsAnalyzerRowValue -Row $row -Name 'AnalysisMethod')
        $kinds = @(Get-DocsAnalyzerRowValue -Row $row -Name 'ElementKinds' | Where-Object { $null -ne $_ })
        if ($id -cnotmatch $script:DocsAnalyzerIdentifierPattern) { $findings.Add((New-DocsRegistrationFinding -Index $index -Field 'Id' -Message "Analyzer Id '$id' is not an identifier.")) }
        if ((Get-DocsAnalysisMethod) -cnotcontains $method) {
            $findings.Add((New-DocsRegistrationFinding -Index $index -Field 'AnalysisMethod' -Message "AnalysisMethod '$method' is not one of $((Get-DocsAnalysisMethod) -join ', ')."))
        } elseif (-not $seen.Add("$id`n$method")) {
            $findings.Add((New-DocsRegistrationFinding -Index $index -Field 'Id' -Message "The pair (Id '$id', AnalysisMethod '$method') is registered more than once."))
        }
        if ($method -ceq 'native' -and -not $scannerIds.Contains($id)) {
            $findings.Add((New-DocsRegistrationFinding -Index $index -Field 'AnalysisMethod' -Message "The native row '$id' has no scanner row with the same Id; the scanner baseline is required."))
        }
        if ($kinds.Count -eq 0 -or @($kinds | Where-Object { -not (Test-DocsElementKind -Kind ([string] $_)) }).Count -gt 0) {
            $findings.Add((New-DocsRegistrationFinding -Index $index -Field 'ElementKinds' -Message "ElementKinds of '$id' must list one or more element kinds."))
        }
        if (-not (Test-DocsAnalyzerModulePath -Module (Get-DocsAnalyzerRowValue -Row $row -Name 'Module'))) {
            $findings.Add((New-DocsRegistrationFinding -Index $index -Field 'Module' -Message "Module of '$id' must resolve inside .claude/lib/docs/ with a DocsAnalyzer*.psm1 leaf."))
        }
        if ([string] (Get-DocsAnalyzerRowValue -Row $row -Name 'Function') -cnotmatch $script:DocsAnalyzerFunctionPattern) {
            $findings.Add((New-DocsRegistrationFinding -Index $index -Field 'Function' -Message "Function of '$id' must match ^Invoke-DocsAnalyzer[A-Za-z]+$."))
        }
        if ([string]::IsNullOrWhiteSpace([string] (Get-DocsAnalyzerRowValue -Row $row -Name 'Version'))) {
            $findings.Add((New-DocsRegistrationFinding -Index $index -Field 'Version' -Message "Version of '$id' must not be blank."))
        }
    }
    return Get-DocsOrderedFinding -Finding $findings.ToArray()
}

function Select-DocsAnalyzerRegistration {
    <#
    .SYNOPSIS
        Selects one registration row per analyzer Id for the requested element kinds.
    .DESCRIPTION
        Returns @{ Rows; Findings }. The whole request is validated first: each unknown AnalyzerId
        yields DOCS_ANALYZER_UNKNOWN and no row is returned. Without AnalyzerId every Id with a row
        covering one of ElementKind is selected. The native row is returned for an Id in
        NativeAvailable when one exists, otherwise the scanner row. Rows are sorted by Id, so the
        output does not depend on input order.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyCollection()] [object[]] $Registration,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $ElementKind,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $AnalyzerId,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $NativeAvailable
    )

    $rows = @($Registration | Where-Object { $null -ne $_ })
    $known = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($row in $rows) { [void]$known.Add([string] (Get-DocsAnalyzerRowValue -Row $row -Name 'Id')) }
    $findings = [System.Collections.Generic.List[object]]::new()
    $requested = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    if ($null -ne $AnalyzerId -and $AnalyzerId.Count -gt 0) {
        foreach ($candidate in $AnalyzerId) {
            if ($known.Contains($candidate)) { [void]$requested.Add($candidate); continue }
            $findings.Add((New-DocsFinding -Code 'DOCS_ANALYZER_UNKNOWN' -Severity 'error' -Message "Analyzer '$candidate' is not registered." -NextAction 'Select a registered analyzer identifier.'))
        }
    } else {
        foreach ($row in $rows) {
            $kinds = @(Get-DocsAnalyzerRowValue -Row $row -Name 'ElementKinds')
            if (@($kinds | Where-Object { $ElementKind -ccontains [string] $_ }).Count -gt 0) { [void]$requested.Add([string] (Get-DocsAnalyzerRowValue -Row $row -Name 'Id')) }
        }
    }
    if ($findings.Count -gt 0) { return @{ Rows = [object[]]@(); Findings = (Get-DocsOrderedFinding -Finding $findings.ToArray()) } }

    $native = @($NativeAvailable | Where-Object { $null -ne $_ })
    $selected = [System.Collections.Generic.List[object]]::new()
    foreach ($id in $requested) {
        $method = if ($native -ccontains $id) { 'native' } else { 'scanner' }
        $match = @($rows | Where-Object { [string] (Get-DocsAnalyzerRowValue -Row $_ -Name 'Id') -ceq $id -and [string] (Get-DocsAnalyzerRowValue -Row $_ -Name 'AnalysisMethod') -ceq $method })
        if ($match.Count -eq 0) { $match = @($rows | Where-Object { [string] (Get-DocsAnalyzerRowValue -Row $_ -Name 'Id') -ceq $id -and [string] (Get-DocsAnalyzerRowValue -Row $_ -Name 'AnalysisMethod') -ceq 'scanner' }) }
        if ($match.Count -gt 0) { $selected.Add($match[0]) }
    }
    return @{ Rows = $selected.ToArray(); Findings = [object[]]@() }
}

function New-DocsCapturedInput {
    <#
    .SYNOPSIS
        Returns one captured analyzer input: @{ path; sha256; size; text; diagnostic }.
    .DESCRIPTION
        Decodes strictly as UTF-8. An input above MaxBytes or with invalid UTF-8 carries a
        warning diagnostic and text $null. A non-relative Path throws DOCS_IDENTITY_INPUT_INVALID.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state; the exported name is fixed by the issue #1020 contract.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [byte[]] $Bytes,
        [ValidateRange(0, 1073741824)] [int] $MaxBytes = $script:DocsAnalyzerDefaultMaxBytes
    )

    if (-not (Test-DocsRelativePath -Path $Path)) { throw "DOCS_IDENTITY_INPUT_INVALID: Path '$Path' is not a relative POSIX path." }
    $text = $null
    $diagnostic = $null
    if ($Bytes.Length -gt $MaxBytes) {
        $diagnostic = New-DocsDiagnostic -Code 'DOCS_INPUT_TOO_LARGE' -Path $Path -Severity 'warning' -AnalyzerId 'docs-capture' -Message "The input has $($Bytes.Length) bytes, above the bound of $MaxBytes."
    } else {
        try {
            $text = ConvertFrom-DocsUtf8Bytes -Bytes $Bytes
        } catch [System.Text.DecoderFallbackException] {
            $diagnostic = New-DocsDiagnostic -Code 'DOCS_INPUT_NOT_UTF8' -Path $Path -Severity 'warning' -AnalyzerId 'docs-capture' -Message 'The input is not valid UTF-8.'
        }
    }
    return @{ path = $Path; sha256 = (Get-DocsBytesSha256Hex -Bytes $Bytes); size = [long] $Bytes.Length; text = $text; diagnostic = $diagnostic }
}

function Get-DocsAnalyzerOutputFinding {
    <#
    .SYNOPSIS
        Validates one analyzer output element against its row and the captured inputs (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Element,
        [Parameter(Mandatory = $true)] [int] $Index,
        [Parameter(Mandatory = $true)] [object] $Registration,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $InputText
    )

    $problems = [System.Collections.Generic.List[string]]::new()
    if ($Element -isnot [System.Collections.IDictionary]) { $problems.Add('the element is not an object') }
    else {
        $kind = [string] (Get-DocsAnalyzerRowValue -Row $Element -Name 'kind')
        if (@(Get-DocsAnalyzerRowValue -Row $Registration -Name 'ElementKinds') -cnotcontains $kind) { $problems.Add("kind '$kind' is outside the registration") }
        if ([string] (Get-DocsAnalyzerRowValue -Row $Element -Name 'analyzer_id') -cne [string] (Get-DocsAnalyzerRowValue -Row $Registration -Name 'Id')) { $problems.Add('analyzer_id differs from the registration Id') }
        if ([string] (Get-DocsAnalyzerRowValue -Row $Element -Name 'analysis_method') -cne [string] (Get-DocsAnalyzerRowValue -Row $Registration -Name 'AnalysisMethod')) { $problems.Add('analysis_method differs from the registration AnalysisMethod') }
        try { [void](ConvertFrom-DocsSurfaceElement -Record $Element) } catch { $problems.Add($_.Exception.Message) }
        $path = [string] (Get-DocsAnalyzerRowValue -Row $Element -Name 'path')
        $range = Get-DocsAnalyzerRowValue -Row $Element -Name 'line_range'
        $lineRange = if ($range -is [System.Collections.IDictionary]) { [int[]]@([int] $range['start'], [int] $range['end']) } else { $null }
        if (-not $InputText.Contains($path) -or $null -eq $InputText[$path]) { $problems.Add("no captured input text exists for path '$path'") }
        else {
            try { $expected = Get-DocsDeclarationSha256 -Text $InputText[$path] -LineRange $lineRange } catch { $expected = $null }
            if ([string] (Get-DocsAnalyzerRowValue -Row $Element -Name 'source_sha256') -cne [string] $expected) { $problems.Add('source_sha256 differs from the digest recomputed from the captured input and line_range') }
        }
    }
    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($problem in $problems) {
        $findings.Add((New-DocsFinding -Code 'DOCS_ANALYZER_OUTPUT_INVALID' -Severity 'error' -Pointer "/elements/$Index" -Message "Analyzer output element $Index is rejected: $problem." -NextAction 'Correct the analyzer so that its output satisfies the analyzer contract.'))
    }
    return , $findings.ToArray()
}

function Invoke-DocsAnalyzer {
    <#
    .SYNOPSIS
        Imports and calls one registered analyzer and validates its output.
    .DESCRIPTION
        Returns @{ Elements; Diagnostics; Findings }. Elements are sorted by element_id and
        diagnostics by id; when any output check fails, Findings holds one
        DOCS_ANALYZER_OUTPUT_INVALID finding per failure and no element or diagnostic is returned.
        ImportModule receives the registration Module path (default: Import-Module -Force).
        AnalyzerFunction defaults to the function named by the registration row.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Repository paths are case-sensitive; an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [object] $Registration,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Selection,
        [AllowNull()] [scriptblock] $ImportModule,
        [AllowNull()] [scriptblock] $AnalyzerFunction
    )

    if ($null -eq $ImportModule) {
        $ImportModule = { param($Path) Import-Module -Name $Path -Force -ErrorAction Stop }
    }
    & $ImportModule (Get-DocsAnalyzerRowValue -Row $Registration -Name 'Module')
    if ($null -eq $AnalyzerFunction) {
        $AnalyzerFunction = (Get-Command -Name ([string] (Get-DocsAnalyzerRowValue -Row $Registration -Name 'Function')) -CommandType Function -ErrorAction Stop).ScriptBlock
    }
    $output = & $AnalyzerFunction -CapturedInput $CapturedInput -Selection $Selection

    $inputText = [hashtable]::new([System.StringComparer]::Ordinal)
    foreach ($captured in @($CapturedInput)) { if ($null -ne $captured) { $inputText[[string] $captured['path']] = $captured['text'] } }
    $elements = @(if ($output -is [System.Collections.IDictionary] -and $output.Contains('Elements')) { $output['Elements'] })
    $diagnostics = @(if ($output -is [System.Collections.IDictionary] -and $output.Contains('Diagnostics')) { $output['Diagnostics'] })
    $findings = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $elements.Count; $index++) {
        $findings.AddRange((Get-DocsAnalyzerOutputFinding -Element $elements[$index] -Index $index -Registration $Registration -InputText $inputText))
    }
    if ($findings.Count -gt 0) { return @{ Elements = [object[]]@(); Diagnostics = [object[]]@(); Findings = (Get-DocsOrderedFinding -Finding $findings.ToArray()) } }
    $sortedElements = Get-DocsOrdinalSortedRecord -Record $elements -Key 'element_id'
    $sortedDiagnostics = Get-DocsOrdinalSortedRecord -Record @($diagnostics | Where-Object { $null -ne $_ }) -Key 'id'
    return @{ Elements = $sortedElements; Diagnostics = $sortedDiagnostics; Findings = [object[]]@() }
}

function Get-DocsOrdinalSortedRecord {
    <#
    .SYNOPSIS
        Returns records sorted by one string field with ordinal comparison (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Record,
        [Parameter(Mandatory = $true)] [string] $Key
    )

    [object[]] $items = @($Record)
    [string[]] $keys = @($items | ForEach-Object { [string] (Get-DocsAnalyzerRowValue -Row $_ -Name $Key) })
    [Array]::Sort($keys, $items, [System.StringComparer]::Ordinal)
    return , $items
}

Export-ModuleMember -Function `
    Get-DocsAnalyzerRegistration, `
    Test-DocsAnalyzerRegistration, `
    Select-DocsAnalyzerRegistration, `
    New-DocsCapturedInput, `
    Invoke-DocsAnalyzer
