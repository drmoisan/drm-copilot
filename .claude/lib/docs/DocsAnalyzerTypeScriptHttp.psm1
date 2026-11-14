<#
.SYNOPSIS
    typescript-http scanner: Express and Fastify route registrations in TypeScript sources,
    emitted as http-route elements with mount and plugin prefixes composed across files.

.DESCRIPTION
    Invoke-DocsAnalyzerTypeScriptHttp selects *.ts, *.mts and *.cts inputs (declaration files
    excluded) and runs two passes. Pass 1 (DocsTypeScriptHttpSupport.psm1) tokenizes each file
    and records its receivers, routes, mounts and exports. Pass 2 resolves every mount to a
    receiver in the same file or in a captured relative import, then walks from each receiver
    that nothing mounts: routes of an app or of a reached router or plugin are emitted with the
    composed prefix (a router mounted n times yields n elements; a dynamic prefix renders as the
    segment <dynamic> with prefix_resolved false), and routes of a router or plugin that is never
    mounted keep their own template with mounted false. The method is upper-case, all/ANY carries
    framework_method, and no implicit HEAD is emitted. Elements are built only through
    New-DocsSurfaceElement -AnalysisMethod scanner -SourceText; the digest is never computed
    here. Every function is pure.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Get-DocsScannerPrecisionLimit is the shipped statement of this scanner's precision limit
    (HTTP_DYNAMIC_ROUTE, HTTP_PREFIX_DYNAMIC, HTTP_MOUNT_UNRESOLVED).
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsTypeScriptTokens.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsTypeScriptHttpSupport.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsScannerCommon.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

$script:DocsHttpAnalyzerId = 'typescript-http'
$script:DocsHttpMountDepth = 16

function Resolve-DocsHttpMount {
    <#
    .SYNOPSIS
        Sets TargetKey on every mount that resolves to a known receiver and counts incoming mounts; an unresolved mount records HTTP_MOUNT_UNRESOLVED (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Receiver,
        [Parameter(Mandatory = $true)] [hashtable] $Export,
        [Parameter(Mandatory = $true)] [hashtable] $Incoming,
        [Parameter(Mandatory = $true)] [hashtable] $Set
    )

    foreach ($key in $Receiver.Keys) {
        $owner = $Receiver[$key]
        foreach ($mount in $owner['Mount']) {
            $targetKey = $null
            if ($null -ne $mount['Local']) { $targetKey = [string] $owner['Path'] + '#' + [string] $mount['Local'] }
            elseif ($Export.ContainsKey([string] $mount['ImportPath'])) {
                $fileExport = $Export[[string] $mount['ImportPath']]
                $targetName = if ([string] $mount['ImportName'] -ceq 'default' -or [string] $mount['ImportName'] -ceq '*') { $fileExport['Default'] } elseif ($fileExport['Named'].ContainsKey([string] $mount['ImportName'])) { $fileExport['Named'][[string] $mount['ImportName']] } else { $null }
                if ($null -ne $targetName) { $targetKey = [string] $mount['ImportPath'] + '#' + [string] $targetName }
            }
            if ($null -eq $targetKey -or -not $Receiver.ContainsKey($targetKey)) {
                Add-DocsScannerDiagnostic -Set $Set -Code 'HTTP_MOUNT_UNRESOLVED' -Path ([string] $owner['Path']) -Line ([int] $mount['Line'])
                $mount['TargetKey'] = $null
                continue
            }
            $mount['TargetKey'] = $targetKey
            $Incoming[$targetKey] = [int] $Incoming[$targetKey] + 1
        }
    }
}

function Add-DocsHttpElement {
    <#
    .SYNOPSIS
        Emits the routes of a receiver under a prefix and recurses into its resolved mounts (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Receiver,
        [Parameter(Mandatory = $true)] [string] $Key,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Prefix,
        [Parameter(Mandatory = $true)] [bool] $PrefixResolved,
        [Parameter(Mandatory = $true)] [bool] $Mounted,
        [Parameter(Mandatory = $true)] [int] $Depth,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.HashSet[string]] $Visited,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.HashSet[string]] $Reached,
        [Parameter(Mandatory = $true)] [hashtable] $Text,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.List[object]] $Element,
        [Parameter(Mandatory = $true)] [hashtable] $Set
    )

    [void]$Reached.Add($Key)
    $current = $Receiver[$Key]
    $path = [string] $current['Path']
    foreach ($route in $current['Route']) {
        $template = Join-DocsRouteTemplate -Prefix $Prefix -Template ([string] $route['Template'])
        $declaration = [string] $route['Method'] + ' ' + $template
        $name = if (-not [string]::IsNullOrEmpty([string] $route['Handler'])) { [string] $route['Handler'] } else { $template }
        $property = [ordered]@{}
        if ([string] $route['Method'] -ceq 'ANY') { $property['framework_method'] = [string] $route['FrameworkMethod'] }
        if (-not $PrefixResolved) { $property['prefix_resolved'] = $false }
        if (-not $Mounted) { $property['mounted'] = $false }
        try {
            $Element.Add((New-DocsSurfaceElement -Kind 'http-route' -Path $path -Declaration $declaration -Name $name -AnalyzerId $script:DocsHttpAnalyzerId -AnalysisMethod 'scanner' -SourceText ([string] $Text[$path]) -LineRange @([int] $route['Line'], [int] $route['EndLine']) -Property $property))
        } catch { Add-DocsScannerDiagnostic -Set $Set -Code 'DECLARATION_INVALID' -Path $path -Line ([int] $route['Line']) }
    }
    if ($Depth -ge $script:DocsHttpMountDepth) { return }
    foreach ($mount in $current['Mount']) {
        $targetKey = $mount['TargetKey']
        if ($null -eq $targetKey -or $Visited.Contains([string] $targetKey)) { continue }
        $part = if ($null -eq $mount['Prefix']) { '<dynamic>' } else { [string] $mount['Prefix'] }
        $nextPrefix = Join-DocsRouteTemplate -Prefix $Prefix -Template $part
        $nextVisited = [System.Collections.Generic.HashSet[string]]::new($Visited, [System.StringComparer]::Ordinal)
        [void]$nextVisited.Add([string] $targetKey)
        Add-DocsHttpElement -Receiver $Receiver -Key ([string] $targetKey) -Prefix $nextPrefix -PrefixResolved ($PrefixResolved -and $null -ne $mount['Prefix']) -Mounted $Mounted -Depth ($Depth + 1) -Visited $nextVisited -Reached $Reached -Text $Text -Element $Element -Set $Set
    }
}

function Invoke-DocsAnalyzerTypeScriptHttp {
    <#
    .SYNOPSIS
        Scans the captured TypeScript inputs for Express and Fastify routes and returns @{ Elements; Diagnostics }.
    .DESCRIPTION
        Selection is accepted for the 1020 analyzer contract and not read. Every element is
        built by New-DocsSurfaceElement with -AnalysisMethod scanner and the captured text of the
        file that registers the route; diagnostics are aggregated per (code, path) and emitted
        through ConvertTo-DocsScannerDiagnostic under typescript-http.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Paths and receiver keys are case-sensitive; ordinal-comparer hashtables are required.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Selection', Justification = 'The 1020 analyzer contract passes -Selection to every analyzer; this scanner reads no selection key.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [AllowNull()] [object] $Selection
    )

    $set = New-DocsScannerDiagnosticSet
    $selected = Select-DocsScannerInput -CapturedInput $CapturedInput -Suffix @('.ts', '.mts', '.cts') -ExcludeSuffix @('.d.ts', '.d.mts', '.d.cts')
    [string[]] $capturedPath = @($selected | ForEach-Object { [string] $_['path'] })
    $text = [hashtable]::new([System.StringComparer]::Ordinal)
    $receiver = [hashtable]::new([System.StringComparer]::Ordinal)
    $export = [hashtable]::new([System.StringComparer]::Ordinal)
    $order = [System.Collections.Generic.List[string]]::new()
    foreach ($captured in $selected) {
        $path = [string] $captured['path']
        if ($null -eq $captured['text']) { Add-DocsScannerDiagnostic -Set $set -Code (Get-DocsScannerInputDiagnosticCode -CapturedInput $captured) -Path $path -Line 0 -Blocking $true; continue }
        $lexed = ConvertTo-DocsTypeScriptToken -Text ([string] $captured['text'])
        if ($lexed['Diagnostics'].Count -gt 0) {
            foreach ($diagnostic in $lexed['Diagnostics']) { Add-DocsScannerDiagnostic -Set $set -Code ([string] $diagnostic['Code']) -Path $path -Line ([int] $diagnostic['Line']) -Blocking $true }
            continue
        }
        $scan = Get-DocsHttpFileScan -Tokens $lexed['Tokens'] -Path $path -CapturedPath $capturedPath -Set $set
        if (-not $scan['HasFramework']) { continue }
        $text[$path] = [string] $captured['text']
        $export[$path] = $scan['Export']
        foreach ($entry in $scan['Receiver']) {
            $key = $path + '#' + [string] $entry['Name']
            if ($receiver.ContainsKey($key)) { continue }
            $receiver[$key] = $entry
            $order.Add($key)
        }
    }
    $incoming = [hashtable]::new([System.StringComparer]::Ordinal)
    Resolve-DocsHttpMount -Receiver $receiver -Export $export -Incoming $incoming -Set $set
    $elements = [System.Collections.Generic.List[object]]::new()
    $reached = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($pass in @('root', 'unreached')) {
        foreach ($key in $order) {
            if ($pass -ceq 'root' -and [int] $incoming[$key] -gt 0) { continue }
            if ($reached.Contains($key)) { continue }
            $visited = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
            [void]$visited.Add($key)
            Add-DocsHttpElement -Receiver $receiver -Key $key -Prefix '' -PrefixResolved $true -Mounted ($pass -ceq 'root' -and [string] $receiver[$key]['Kind'] -ceq 'app') -Depth 0 -Visited $visited -Reached $reached -Text $text -Element $elements -Set $set
        }
    }
    [object[]] $sorted = ConvertTo-DocsScannerElementList -Element $elements.ToArray() -Set $set
    return @{ Elements = $sorted; Diagnostics = [object[]] (ConvertTo-DocsScannerDiagnostic -Set $set -AnalyzerId $script:DocsHttpAnalyzerId) }
}

Export-ModuleMember -Function Invoke-DocsAnalyzerTypeScriptHttp
