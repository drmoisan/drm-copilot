<#
.SYNOPSIS
    The issue #1031 Python-native analyzers: interpreter start through the command context,
    result classification, the four native analyzer functions and the inventory integration.

.DESCRIPTION
    Invoke-DocsPythonNativeInterpreter is the only interpreter-start function: it makes the
    three seam calls python3, python and py -3 through the InvokeProcess [scriptblock]
    parameter, each with -I -B -X utf8 and the repository-relative helper path
    .claude/lib/docs/python/run_docs_python_native.py. Get-DocsPythonNativeResult tests the
    pack with Context.TestFile, tries the candidates in order, classifies each failure
    (pack-absent, interpreter-not-found, version-below-floor, timeout, exit-nonzero,
    start-error, output-invalid) and returns the converted native output or the
    PYTHON_NATIVE_UNAVAILABLE diagnostic (and, under -AnalysisMethod native, the
    DOCS_PYTHON_NATIVE_UNAVAILABLE finding). The analyzer functions
    Invoke-DocsAnalyzerPythonNativeCli, ...Http, ...Api and ...Architecture are pure and read
    the converted output from Selection.python_native. Invoke-DocsPythonNativeInventory
    selects the native rows when the helper is available, runs them through 1020
    Invoke-DocsAnalyzer, and runs each identifier's scanner row for the non-.py inputs and the
    parse-failed files. No test starts a process: the context members are test seams.

.NOTES
    Issue #1031. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsAnalyzerRegistry.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPythonNativeProtocol.psm1') -ErrorAction Stop

$script:DocsPythonNativeHelperPath = '.claude/lib/docs/python/run_docs_python_native.py'
$script:DocsPythonNativeTimeoutSeconds = 120
$script:DocsPythonNativeCandidate = [string[]]@('python3', 'python', 'py')
$script:DocsPythonNativeStartFailure = 'DOCS_PROCESS_START_FAILED'

function Invoke-DocsPythonNativeMember {
    <#
    .SYNOPSIS
        Invokes one command-context member with positional arguments (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object], [object[]])]
    param(
        [Parameter(Mandatory = $true)] [scriptblock] $Member,
        [AllowEmptyCollection()] [object[]] $ArgumentList = @()
    )

    return , (& $Member @ArgumentList)
}

function Invoke-DocsPythonNativeInterpreter {
    <#
    .SYNOPSIS
        Starts the helper with one interpreter candidate through the InvokeProcess seam.
    .DESCRIPTION
        Candidate is python3, python or py (py receives a leading -3). The argument list is -I,
        -B, -X, utf8 and the helper path; StdinText is the request and TimeoutSeconds the bound.
        Returns the seam result @{ ExitCode; Stdout; Stderr; TimedOut }; a start failure throws
        from the seam. Another candidate throws DOCS_PYTHON_NATIVE_CANDIDATE_INVALID.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $Candidate,
        [Parameter(Mandatory = $true)] [scriptblock] $InvokeProcess,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $StdinText,
        [Parameter(Mandatory = $true)] [int] $TimeoutSeconds
    )

    [string[]] $arguments = @('-I', '-B', '-X', 'utf8', $script:DocsPythonNativeHelperPath)
    switch -CaseSensitive ($Candidate) {
        'python3' { return & $InvokeProcess 'python3' $arguments $StdinText $TimeoutSeconds }
        'python' { return & $InvokeProcess 'python' $arguments $StdinText $TimeoutSeconds }
        'py' { return & $InvokeProcess 'py' ([string[]]@('-3') + $arguments) $StdinText $TimeoutSeconds }
    }
    throw "DOCS_PYTHON_NATIVE_CANDIDATE_INVALID: '$Candidate' is not one of python3, python, py."
}

function New-DocsPythonNativeUnavailable {
    <#
    .SYNOPSIS
        Builds the unavailable result for a reason token (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [string] $Reason, [Parameter(Mandatory = $true)] [string] $AnalysisMethod)

    $diagnostic = $null
    if ($Reason -cne 'pack-absent') {
        $diagnostic = New-DocsDiagnostic -Code 'PYTHON_NATIVE_UNAVAILABLE' -Path $null -AnalyzerId 'docs-inventory' -Severity 'information' -Message "The Python-native analyzers are unavailable (reason: $Reason); the scanner analyzers were used."
    }
    $finding = $null
    if ($AnalysisMethod -ceq 'native') {
        $finding = New-DocsFinding -Code 'DOCS_PYTHON_NATIVE_UNAVAILABLE' -Severity 'error' -Message "The Python-native analyzers are unavailable (reason: $Reason)." -NextAction 'Install the python pack and Python 3.11 or later, or run with -AnalysisMethod auto or scanner.'
    }
    return @{ Available = $false; Reason = $Reason; Native = $null; Diagnostic = $diagnostic; Finding = $finding }
}

function Get-DocsPythonNativeResult {
    <#
    .SYNOPSIS
        Runs the helper for the selected identifiers: @{ Available; Reason; Native; Diagnostic; Finding }.
    .DESCRIPTION
        AnalysisMethod scanner returns at once (no TestFile or InvokeProcess call), as does an
        empty identifier list or the absence of .py inputs. The pack is tested with
        Context.TestFile on the helper path (pack-absent when false). Each candidate is started
        in order through Context.InvokeProcess: a DOCS_PROCESS_START_FAILED throw means not
        started; another throw start-error; TimedOut timeout; exit 4 version-below-floor; another
        non-zero exit exit-nonzero; exit 0 with a response that fails
        Test-DocsPythonNativeResponse or ConvertFrom-DocsPythonNativeResponse output-invalid.
        The first valid response is used. Otherwise Reason is the last started candidate's token,
        or interpreter-not-found when none started.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $AnalyzerId,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $SourceRoot,
        [Parameter(Mandatory = $true)] [ValidateSet('auto', 'native', 'scanner')] [string] $AnalysisMethod,
        [Parameter(Mandatory = $true)] [object] $Context
    )

    $none = @{ Available = $false; Reason = $null; Native = $null; Diagnostic = $null; Finding = $null }
    if ($AnalysisMethod -ceq 'scanner' -or $AnalyzerId.Count -eq 0) { return $none }
    $request = New-DocsPythonNativeRequest -CapturedInput $CapturedInput -AnalyzerId $AnalyzerId -SourceRoot $SourceRoot -ConsoleScript (Get-DocsPythonNativeConsoleScript -CapturedInput $CapturedInput)
    if (@($request.Paths).Count -eq 0) { return $none }
    if (-not [bool] (Invoke-DocsPythonNativeMember -Member $Context.TestFile -ArgumentList @($script:DocsPythonNativeHelperPath))) {
        return New-DocsPythonNativeUnavailable -Reason 'pack-absent' -AnalysisMethod $AnalysisMethod
    }
    $reason = 'interpreter-not-found'
    foreach ($candidate in $script:DocsPythonNativeCandidate) {
        try {
            $result = Invoke-DocsPythonNativeInterpreter -Candidate $candidate -InvokeProcess $Context.InvokeProcess -StdinText $request.Text -TimeoutSeconds $script:DocsPythonNativeTimeoutSeconds
        } catch {
            if (-not $_.Exception.Message.StartsWith($script:DocsPythonNativeStartFailure, [System.StringComparison]::Ordinal)) { $reason = 'start-error' }
            continue
        }
        if ($result -isnot [System.Collections.IDictionary]) { $reason = 'start-error'; continue }
        if ([bool] $result['TimedOut']) { $reason = 'timeout'; continue }
        if ($result['ExitCode'] -eq 4) { $reason = 'version-below-floor'; continue }
        if ($result['ExitCode'] -ne 0) { $reason = 'exit-nonzero'; continue }
        $check = Test-DocsPythonNativeResponse -ResponseText ([string] $result['Stdout']) -Request $request
        if (-not $check.Valid) { $reason = 'output-invalid'; continue }
        try {
            $native = ConvertFrom-DocsPythonNativeResponse -Response $check.Response -CapturedInput $CapturedInput
        } catch {
            $reason = 'output-invalid'
            continue
        }
        return @{ Available = $true; Reason = $null; Native = $native; Diagnostic = $null; Finding = $null }
    }
    return New-DocsPythonNativeUnavailable -Reason $reason -AnalysisMethod $AnalysisMethod
}

function Get-DocsPythonNativeSelectionOutput {
    <#
    .SYNOPSIS
        Returns the converted native output of one identifier from Selection.python_native (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([AllowNull()] [object] $Selection, [Parameter(Mandatory = $true)] [string] $AnalyzerId)

    $empty = @{ Elements = [object[]]@(); Diagnostics = [object[]]@() }
    if ($Selection -isnot [System.Collections.IDictionary] -or -not $Selection.Contains('python_native')) { return $empty }
    $native = $Selection['python_native']
    if ($native -isnot [System.Collections.IDictionary] -or -not $native.Contains($AnalyzerId)) { return $empty }
    $output = $native[$AnalyzerId]
    return @{ Elements = [object[]]@($output['Elements']); Diagnostics = [object[]]@($output['Diagnostics']) }
}

function Invoke-DocsAnalyzerPythonNativeCli {
    <#
    .SYNOPSIS
        The python-cli native analyzer: returns @{ Elements; Diagnostics } from Selection.python_native.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput, [Parameter(Mandatory = $true)] [AllowNull()] [object] $Selection)

    return Get-DocsPythonNativeSelectionOutput -Selection $Selection -AnalyzerId 'python-cli'
}

function Invoke-DocsAnalyzerPythonNativeHttp {
    <#
    .SYNOPSIS
        The python-http native analyzer: returns @{ Elements; Diagnostics } from Selection.python_native.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput, [Parameter(Mandatory = $true)] [AllowNull()] [object] $Selection)

    return Get-DocsPythonNativeSelectionOutput -Selection $Selection -AnalyzerId 'python-http'
}

function Invoke-DocsAnalyzerPythonNativeApi {
    <#
    .SYNOPSIS
        The python-public-api native analyzer: returns @{ Elements; Diagnostics } from Selection.python_native.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput, [Parameter(Mandatory = $true)] [AllowNull()] [object] $Selection)

    return Get-DocsPythonNativeSelectionOutput -Selection $Selection -AnalyzerId 'python-public-api'
}

function Invoke-DocsAnalyzerPythonNativeArchitecture {
    <#
    .SYNOPSIS
        The python-architecture native analyzer: returns @{ Elements; Diagnostics } from Selection.python_native.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput, [Parameter(Mandatory = $true)] [AllowNull()] [object] $Selection)

    return Get-DocsPythonNativeSelectionOutput -Selection $Selection -AnalyzerId 'python-architecture'
}

function Test-DocsPythonNativeScannerPath {
    <#
    .SYNOPSIS
        True when a scanner record path is a non-.py input or a parse-failed file (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] [AllowEmptyString()] [string] $Path, [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.HashSet[string]] $ParseFailed)

    $text = [string] $Path
    return (-not $text.EndsWith('.py', [System.StringComparison]::Ordinal)) -or $ParseFailed.Contains($text)
}

function Invoke-DocsPythonNativeRow {
    <#
    .SYNOPSIS
        Invokes one registration row through Invoke-DocsAnalyzer, passing ImportModule only when given (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [object] $Row, [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput, [Parameter(Mandatory = $true)] [AllowNull()] [object] $Selection, [AllowNull()] [scriptblock] $ImportModule)

    if ($null -eq $ImportModule) { return Invoke-DocsAnalyzer -Registration $Row -CapturedInput $CapturedInput -Selection $Selection }
    return Invoke-DocsAnalyzer -Registration $Row -CapturedInput $CapturedInput -Selection $Selection -ImportModule $ImportModule
}

function Invoke-DocsPythonNativeInventory {
    <#
    .SYNOPSIS
        Runs the eligible Python identifiers natively or by scanner: @{ Rows; Outputs; Diagnostics; Finding }.
    .DESCRIPTION
        Calls Get-DocsPythonNativeResult and selects rows with Select-DocsAnalyzerRegistration
        -NativeAvailable (the identifiers when the helper is available, none otherwise). Each
        native row is invoked with a copy of Selection carrying python_native; its scanner row is
        then invoked over all captured inputs and keeps only elements and diagnostics whose path
        is a non-.py input or a parse-failed file. A scanner-selected row is invoked unchanged.
        Rows lists every row invoked (native and scanner, unique on Id and AnalysisMethod) and
        Outputs one @{ Elements; Diagnostics } per row. Finding is the unavailability finding
        under -AnalysisMethod native, or the first analyzer-contract finding. ImportModule is
        passed to Invoke-DocsAnalyzer only when given; production passes none.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Registration,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Selection,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $AnalyzerId,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $SourceRoot,
        [Parameter(Mandatory = $true)] [ValidateSet('auto', 'native', 'scanner')] [string] $AnalysisMethod,
        [Parameter(Mandatory = $true)] [object] $Context,
        [AllowNull()] [scriptblock] $ImportModule
    )

    $rows = [System.Collections.Generic.List[object]]::new()
    $outputs = [System.Collections.Generic.List[object]]::new()
    if ($AnalyzerId.Count -eq 0) { return @{ Rows = [object[]]@(); Outputs = [object[]]@(); Diagnostics = [object[]]@(); Finding = $null } }
    $result = Get-DocsPythonNativeResult -CapturedInput $CapturedInput -AnalyzerId $AnalyzerId -SourceRoot $SourceRoot -AnalysisMethod $AnalysisMethod -Context $Context
    $diagnostics = [object[]]@(if ($null -ne $result.Diagnostic) { $result.Diagnostic })
    if ($null -ne $result.Finding) { return @{ Rows = [object[]]@(); Outputs = [object[]]@(); Diagnostics = $diagnostics; Finding = $result.Finding } }
    $available = [string[]]@(if ($result.Available) { $AnalyzerId })
    $selected = Select-DocsAnalyzerRegistration -Registration $Registration -ElementKind ([string[]]@($Selection['element_kinds'])) -AnalyzerId $AnalyzerId -NativeAvailable $available
    $nativeSelection = [hashtable]::new([System.StringComparer]::Ordinal)
    foreach ($key in $Selection.Keys) { $nativeSelection[[string] $key] = $Selection[$key] }
    $failed = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    if ($result.Available) {
        $nativeSelection['python_native'] = $result.Native.Output
        foreach ($path in $result.Native.ParseFailed) { [void] $failed.Add([string] $path) }
    }
    foreach ($row in $selected.Rows) {
        $isNative = [string] $row.AnalysisMethod -ceq 'native'
        $output = Invoke-DocsPythonNativeRow -Row $row -CapturedInput $CapturedInput -Selection $(if ($isNative) { $nativeSelection } else { $Selection }) -ImportModule $ImportModule
        if (@($output.Findings).Count -gt 0) { return @{ Rows = [object[]]@(); Outputs = [object[]]@(); Diagnostics = $diagnostics; Finding = $output.Findings[0] } }
        $rows.Add($row)
        $outputs.Add(@{ Elements = $output.Elements; Diagnostics = $output.Diagnostics })
        if (-not $isNative) { continue }
        $scannerRow = @($Registration | Where-Object { [string] $_.Id -ceq [string] $row.Id -and [string] $_.AnalysisMethod -ceq 'scanner' })[0]
        $scanned = Invoke-DocsPythonNativeRow -Row $scannerRow -CapturedInput $CapturedInput -Selection $Selection -ImportModule $ImportModule
        if (@($scanned.Findings).Count -gt 0) { return @{ Rows = [object[]]@(); Outputs = [object[]]@(); Diagnostics = $diagnostics; Finding = $scanned.Findings[0] } }
        $rows.Add($scannerRow)
        $outputs.Add(@{
                Elements    = [object[]]@($scanned.Elements | Where-Object { Test-DocsPythonNativeScannerPath -Path $_['path'] -ParseFailed $failed })
                Diagnostics = [object[]]@($scanned.Diagnostics | Where-Object { Test-DocsPythonNativeScannerPath -Path $_['path'] -ParseFailed $failed })
            })
    }
    return @{ Rows = $rows.ToArray(); Outputs = $outputs.ToArray(); Diagnostics = $diagnostics; Finding = $null }
}

Export-ModuleMember -Function `
    Invoke-DocsPythonNativeInterpreter, `
    Get-DocsPythonNativeResult, `
    Invoke-DocsAnalyzerPythonNativeCli, `
    Invoke-DocsAnalyzerPythonNativeHttp, `
    Invoke-DocsAnalyzerPythonNativeApi, `
    Invoke-DocsAnalyzerPythonNativeArchitecture, `
    Invoke-DocsPythonNativeInventory
