<#
.SYNOPSIS
    The python-architecture analyzer of issue #1022: one architecture-component per package
    and per module among the Python inputs, with internal import edges as indexed scalar
    properties.

.DESCRIPTION
    Invoke-DocsAnalyzerPythonArchitecture -CapturedInput -Selection returns @{ Elements;
    Diagnostics } (1020 analyzer contract). A package is a directory holding __init__.py among
    the inputs (its component uses the __init__.py text); every other *.py input is a module
    component. The declaration is the dotted name relative to the source root; property
    component_kind is package or module. Each component is built through 1020
    New-DocsSurfaceElement -SourceText with no -LineRange, so line_range is null and
    source_sha256 is the whole-file declaration digest (an edit anywhere in the module text
    changes it); this module computes no digest. Get-DocsPythonImportEdge resolves internal
    edges from import and from-import statements at any indentation, relative imports against
    the module's package, by longest dotted-prefix match against the input modules and
    packages; edges are stored as import_count plus ordinally sorted import-0001, import-0002,
    ... properties, bounded at 1000 (ARCHITECTURE_EDGE_LIMIT keeps import_count only).
    ARCHITECTURE_DYNAMIC_IMPORT marks importlib.import_module(, __import__( and
    importlib.util.spec_from_file_location( sites; ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED a
    relative import above the source root or in a module outside any package;
    ARCHITECTURE_MODULE_NAME_INVALID a path segment that is not a Python identifier. Namespace
    directories and external distributions yield no component.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1022. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSourceText.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPythonSyntax.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPythonBindings.psm1') -ErrorAction Stop

$script:DocsArchitectureAnalyzerId = 'python-architecture'
$script:DocsArchitectureEdgeLimit = 1000
$script:DocsArchitectureIdentifierPattern = '^[\p{L}\p{Nl}_][\p{L}\p{Nl}\p{Mn}\p{Mc}\p{Nd}\p{Pc}]*$(?![\s\S])'
$script:DocsArchitectureDynamicCalleeList = [string[]]@('importlib.import_module', 'importlib.util.spec_from_file_location', '__import__')

function Find-DocsArchitectureKnownPrefix {
    <#
    .SYNOPSIS
        Returns the longest dotted prefix of Candidate that is a known module or package, or $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Candidate, [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.HashSet[string]] $Known)

    $parts = $Candidate.Split('.')
    for ($length = $parts.Count; $length -ge 1; $length--) {
        $prefix = ($parts[0..($length - 1)]) -join '.'
        if ($Known.Contains($prefix)) { return $prefix }
    }
    return $null
}

function Get-DocsPythonImportEdge {
    <#
    .SYNOPSIS
        Returns @{ Edge; Diagnostics }: the internal import edges of one module from its import statements.
    .DESCRIPTION
        Statement is the Statements list of Get-DocsPythonImportTable (import and from forms at
        any indentation). Module is the importing module's dotted name and Package its package
        (the module itself for __init__.py, the parent for a module, an empty string outside any
        package). Known lists every input module and package dotted name. An absolute target is
        matched by its longest dotted prefix in Known; a relative target is resolved against
        Package first, and a level that climbs above the top-level package, or a relative import
        in a module outside any package, yields ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED (the
        edge is not recorded). Edge is the ordinally sorted unique target list without the
        module itself.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowNull()] [object[]] $Statement,
        [Parameter(Mandatory = $true)] [string] $Module,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Package,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Known
    )

    $knownSet = [System.Collections.Generic.HashSet[string]]::new([string[]] $Known, [System.StringComparer]::Ordinal)
    $edges = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $diagnostics = [System.Collections.Generic.List[object]]::new()
    [string[]] $packageParts = @(if (-not [string]::IsNullOrEmpty($Package)) { $Package.Split('.') })
    foreach ($entry in $Statement) {
        $candidates = [System.Collections.Generic.List[string]]::new()
        if ($entry['Kind'] -ceq 'import') {
            foreach ($name in $entry['Names']) { $candidates.Add([string] $name['Name']) }
        } else {
            $level = [int] $entry['Level']
            $base = [string] $entry['Module']
            if ($level -gt 0) {
                if ($packageParts.Count -eq 0 -or $level - 1 -gt $packageParts.Count) {
                    $diagnostics.Add(@{ Code = 'ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED'; Severity = 'warning'; Blocking = $false; Line = $entry['Line'] })
                    continue
                }
                $kept = $packageParts.Count - ($level - 1)
                if ($kept -eq 0) {
                    $diagnostics.Add(@{ Code = 'ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED'; Severity = 'warning'; Blocking = $false; Line = $entry['Line'] })
                    continue
                }
                $root = ($packageParts[0..($kept - 1)]) -join '.'
                $base = if ($base.Length -gt 0) { $root + '.' + $base } else { $root }
            }
            if ($entry['Star'] -or $entry['Names'].Count -eq 0) { $candidates.Add($base) }
            foreach ($name in $entry['Names']) { $candidates.Add($base + '.' + [string] $name['Name']) }
        }
        foreach ($candidate in $candidates) {
            $target = Find-DocsArchitectureKnownPrefix -Candidate $candidate -Known $knownSet
            if ($null -ne $target -and $target -cne $Module) { [void] $edges.Add($target) }
        }
    }
    [string[]] $sorted = @($edges)
    [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
    return @{ Edge = $sorted; Diagnostics = $diagnostics.ToArray() }
}

function Invoke-DocsAnalyzerPythonArchitecture {
    <#
    .SYNOPSIS
        Runs the python-architecture scanner over the captured inputs and returns @{ Elements; Diagnostics }.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Selection
    )

    $sourceRoots = [string[]]@('.')
    if ($Selection -is [System.Collections.IDictionary] -and $Selection.Contains('source_roots') -and $null -ne $Selection['source_roots']) { $sourceRoots = [string[]]@($Selection['source_roots']) }
    $aggregate = New-DocsDiagnosticAggregate
    [object[]] $inputs = @($CapturedInput | Where-Object { $null -ne $_ -and $null -ne $_['text'] -and ([string] $_['path']).EndsWith('.py', [System.StringComparison]::Ordinal) })
    [string[]] $inputKeys = @($inputs | ForEach-Object { [string] $_['path'] })
    [Array]::Sort($inputKeys, $inputs, [System.StringComparer]::Ordinal)
    $files = [System.Collections.Generic.List[object]]::new()
    $known = [System.Collections.Generic.List[string]]::new()
    foreach ($captured in $inputs) {
        $path = [string] $captured['path']
        $text = [string] $captured['text']
        $frontEnd = Get-DocsPythonFrontEnd -Text $text
        foreach ($entry in $frontEnd['Diagnostics']) { Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsArchitectureAnalyzerId -Code $entry['Code'] -Path $path -Line ([int] $entry['Line']) -Severity ([string] $entry['Severity']) }
        if ($frontEnd['Blocked']) { continue }
        $module = Get-DocsModuleDottedName -Path $path -SourceRoot $sourceRoots
        if ($null -eq $module) { continue }
        if (@($module.Split('.') | Where-Object { $_ -cnotmatch $script:DocsArchitectureIdentifierPattern }).Count -gt 0) {
            Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsArchitectureAnalyzerId -Code 'ARCHITECTURE_MODULE_NAME_INVALID' -Path $path -Line 1 -Severity 'warning'
            continue
        }
        $isPackage = $path.EndsWith('/__init__.py', [System.StringComparison]::Ordinal)
        $package = if ($isPackage) { $module } elseif ($module.Contains('.')) { $module.Substring(0, $module.LastIndexOf('.')) } else { '' }
        $files.Add(@{ Path = $path; Text = $text; Module = $module; Package = $package; IsPackage = $isPackage; FrontEnd = $frontEnd })
        $known.Add($module)
    }

    $candidates = [System.Collections.Generic.List[object]]::new()
    foreach ($file in $files) {
        $path = $file['Path']
        $frontEnd = $file['FrontEnd']
        $resolved = Get-DocsPythonImportEdge -Statement $frontEnd['Import']['Statements'] -Module $file['Module'] -Package $file['Package'] -Known $known.ToArray()
        foreach ($entry in $resolved['Diagnostics']) { Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsArchitectureAnalyzerId -Code $entry['Code'] -Path $path -Line ([int] $entry['Line']) -Severity ([string] $entry['Severity']) }
        foreach ($logical in $frontEnd['Lines']) {
            $tokens = $logical['Tokens']
            for ($cursor = 0; $cursor -lt $tokens.Count; $cursor++) {
                if ($tokens[$cursor]['Type'] -cne 'NAME' -or $tokens[$cursor]['IsKeyword']) { continue }
                $call = Read-DocsPythonCall -Token $tokens -Index $cursor
                if ($null -eq $call) { continue }
                $qualified = Resolve-DocsPythonQualifiedName -Name $call['Callee'] -Import $frontEnd['Import']
                if ($null -ne $qualified -and $script:DocsArchitectureDynamicCalleeList -ccontains $qualified) {
                    Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsArchitectureAnalyzerId -Code 'ARCHITECTURE_DYNAMIC_IMPORT' -Path $path -Line ([int] $logical['StartLine']) -Severity 'warning'
                }
                $cursor = $call['OpenIndex']
            }
        }
        [string[]] $edges = @($resolved['Edge'])
        $property = @{ component_kind = $(if ($file['IsPackage']) { 'package' } else { 'module' }); import_count = [long] $edges.Count }
        if ($edges.Count -gt $script:DocsArchitectureEdgeLimit) {
            Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsArchitectureAnalyzerId -Code 'ARCHITECTURE_EDGE_LIMIT' -Path $path -Line 1 -Severity 'warning'
        } else {
            for ($index = 0; $index -lt $edges.Count; $index++) { $property['import-' + ($index + 1).ToString('0000')] = $edges[$index] }
        }
        $candidates.Add(@{
                Line      = 1
                Parameter = @{
                    Kind           = 'architecture-component'
                    Path           = $path
                    Declaration    = $file['Module']
                    Name           = ([string] $file['Module']).Split('.')[-1]
                    AnalyzerId     = $script:DocsArchitectureAnalyzerId
                    AnalysisMethod = 'scanner'
                    SourceText     = $file['Text']
                    ParentId       = $null
                    Property       = $property
                }
            })
    }
    $elements = Select-DocsUniqueElement -Candidate $candidates.ToArray() -Aggregate $aggregate
    return @{ Elements = [object[]]@($elements); Diagnostics = [object[]]@($aggregate.Diagnostics) }
}

Export-ModuleMember -Function Invoke-DocsAnalyzerPythonArchitecture, Get-DocsPythonImportEdge
