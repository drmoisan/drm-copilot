<#
.SYNOPSIS
    The python-http analyzer of issue #1022: two passes over the Python inputs that collect
    FastAPI and Flask route, receiver and mount sites, resolve mounts across inputs through the
    import alias tables, compose route templates and emit http-route elements.

.DESCRIPTION
    Invoke-DocsAnalyzerPythonHttp -CapturedInput -Selection returns @{ Elements; Diagnostics }
    (1020 analyzer contract). Pass 1 runs the shared front-end and the pass-1 recognizers of
    DocsPythonHttpSites.psm1 per input; pass 2 resolves include_router and register_blueprint
    children (a receiver of the same input, a name bound by from pkg.mod import router, or
    mod.router through from . import mod) and composes one element per include chain and per
    distinct method. Resolve-DocsHttpTemplate composes a FastAPI template verbatim (include
    prefixes outermost first, then the router prefix, then the path) and a Flask template with
    prefix.TrimEnd('/') + '/' + rule.TrimStart('/'). A router included n times yields n
    elements; a router never included keeps its own prefix with mounted: false; an
    unresolvable prefix is rendered <dynamic> with prefix_resolved: false and
    HTTP_PREFIX_DYNAMIC; an untracked inclusion is HTTP_MOUNT_UNRESOLVED; an inclusion cycle
    or a composition depth above 16 is HTTP_INCLUDE_UNRESOLVED with the route keeping its own
    prefix and mounted: false. Every element is built through 1020 New-DocsSurfaceElement
    -SourceText -LineRange by Select-DocsUniqueElement; this module computes no digest.

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
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPythonBindings.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPythonHttpSites.psm1') -ErrorAction Stop

$script:DocsHttpAnalyzerId = 'python-http'
$script:DocsHttpDepthLimit = 16
$script:DocsHttpDynamicSegment = '<dynamic>'

function Resolve-DocsHttpTemplate {
    <#
    .SYNOPSIS
        Composes a route template from the prefixes (outermost first) and the path or rule.
    .DESCRIPTION
        FastAPI: the verbatim concatenation of every prefix and the path. Flask: the prefixes
        are folded with prefix.TrimEnd('/') + '/' + next.TrimStart('/'), and the rule is joined
        the same way when a prefix applies; without a prefix the rule is returned as written.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [ValidateSet('fastapi', 'flask')] [string] $Framework,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowEmptyString()] [AllowNull()] [string[]] $Prefix,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path
    )

    $segments = @($Prefix | Where-Object { $null -ne $_ })
    if ($Framework -ceq 'fastapi') { return ($segments -join '') + $Path }
    $combined = ''
    foreach ($segment in $segments) {
        if ($segment.Length -eq 0) { continue }
        $combined = if ($combined.Length -eq 0) { $segment } else { $combined.TrimEnd('/') + '/' + $segment.TrimStart('/') }
    }
    if ($combined.Length -eq 0) { return $Path }
    return $combined.TrimEnd('/') + '/' + $Path.TrimStart('/')
}

function Resolve-DocsHttpRelativeModule {
    <#
    .SYNOPSIS
        Resolves a possibly relative dotted module against a package, or returns $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Module, [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $Package)

    $level = 0
    while ($level -lt $Module.Length -and $Module[$level] -eq '.') { $level++ }
    if ($level -eq 0) { return $Module }
    if ([string]::IsNullOrEmpty($Package)) { return $null }
    $parts = [System.Collections.Generic.List[string]]::new([string[]] $Package.Split('.'))
    if ($level - 1 -gt $parts.Count) { return $null }
    for ($drop = 1; $drop -lt $level; $drop++) { $parts.RemoveAt($parts.Count - 1) }
    $rest = $Module.Substring($level)
    if ($rest.Length -gt 0) { $parts.Add($rest) }
    if ($parts.Count -eq 0) { return $null }
    return ($parts -join '.')
}

function Resolve-DocsHttpChild {
    <#
    .SYNOPSIS
        Resolves a mount child expression to a receiver key 'path|name', or $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [hashtable] $File, [Parameter(Mandatory = $true)] [string] $Child, [Parameter(Mandatory = $true)] [System.Collections.Generic.Dictionary[string, object]] $ReceiverByKey, [Parameter(Mandatory = $true)] [System.Collections.Generic.Dictionary[string, object]] $FileByModule)

    if (-not $Child.Contains('.') -and $File['Receiver'].ContainsKey($Child)) { return $File['Path'] + '|' + $Child }
    $qualified = Resolve-DocsPythonQualifiedName -Name $Child -Import $File['Import']
    if ($null -eq $qualified -or $qualified -ceq $Child -or -not $qualified.Contains('.')) { return $null }
    $separator = $qualified.LastIndexOf('.')
    $member = $qualified.Substring($separator + 1)
    $module = Resolve-DocsHttpRelativeModule -Module $qualified.Substring(0, $separator) -Package $File['Package']
    $target = $null
    if ($null -eq $module -or -not $FileByModule.TryGetValue($module, [ref] $target)) { return $null }
    $key = $target['Path'] + '|' + $member
    if ($ReceiverByKey.ContainsKey($key)) { return $key }
    return $null
}

function Get-DocsHttpChain {
    <#
    .SYNOPSIS
        Returns @{ Chains; Cycle } for a receiver key: every include chain to an application as a segment list, outermost first (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [string] $Key, [Parameter(Mandatory = $true)] [System.Collections.Generic.Dictionary[string, object]] $ReceiverByKey, [Parameter(Mandatory = $true)] [System.Collections.Generic.Dictionary[string, object]] $IncludedBy, [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.HashSet[string]] $Stack, [int] $Depth = 0)

    $record = $ReceiverByKey[$Key]
    $receiver = $record['Receiver']
    if ($receiver['Kind'] -ceq 'app') { return @{ Chains = @(, [object[]]@()); Cycle = $false } }
    if ($Depth -gt $script:DocsHttpDepthLimit -or -not $Stack.Add($Key)) { return @{ Chains = @(); Cycle = $true } }
    $chains = [System.Collections.Generic.List[object]]::new()
    $cycle = $false
    $edges = $null
    if ($IncludedBy.TryGetValue($Key, [ref] $edges)) {
        foreach ($edge in $edges) {
            $own = [System.Collections.Generic.List[object]]::new()
            if ($receiver['Framework'] -ceq 'fastapi') {
                if ($edge['PrefixGiven']) { $own.Add(@{ Text = $edge['Prefix']; Dynamic = $edge['PrefixDynamic']; Path = $edge['Path']; Line = $edge['Line'] }) }
                $own.Add(@{ Text = $receiver['Prefix']; Dynamic = $receiver['PrefixDynamic']; Path = $record['Path']; Line = $receiver['Line'] })
            } elseif ($edge['PrefixGiven']) { $own.Add(@{ Text = $edge['Prefix']; Dynamic = $edge['PrefixDynamic']; Path = $edge['Path']; Line = $edge['Line'] }) }
            else { $own.Add(@{ Text = $receiver['Prefix']; Dynamic = $receiver['PrefixDynamic']; Path = $record['Path']; Line = $receiver['Line'] }) }
            $parent = Get-DocsHttpChain -Key $edge['ParentKey'] -ReceiverByKey $ReceiverByKey -IncludedBy $IncludedBy -Stack $Stack -Depth ($Depth + 1)
            if ($parent['Cycle']) { $cycle = $true }
            foreach ($chain in $parent['Chains']) { $chains.Add([object[]]@(@($chain) + $own.ToArray())) }
        }
    }
    [void] $Stack.Remove($Key)
    return @{ Chains = $chains.ToArray(); Cycle = $cycle }
}

function Invoke-DocsAnalyzerPythonHttp {
    <#
    .SYNOPSIS
        Runs the python-http scanner over the captured inputs and returns @{ Elements; Diagnostics }.
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
    $receiverByKey = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $fileByModule = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    foreach ($captured in $inputs) {
        $path = [string] $captured['path']
        $text = [string] $captured['text']
        $frontEnd = Get-DocsPythonFrontEnd -Text $text
        foreach ($entry in $frontEnd['Diagnostics']) { Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsHttpAnalyzerId -Code $entry['Code'] -Path $path -Line ([int] $entry['Line']) -Severity ([string] $entry['Severity']) }
        if ($frontEnd['Blocked']) { continue }
        $module = Get-DocsModuleDottedName -Path $path -SourceRoot $sourceRoots
        $package = if ($null -eq $module) { $null } elseif ($path.EndsWith('/__init__.py', [System.StringComparison]::Ordinal)) { $module } elseif ($module.Contains('.')) { $module.Substring(0, $module.LastIndexOf('.')) } else { '' }
        $receivers = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
        $routes = [System.Collections.Generic.List[object]]::new()
        foreach ($result in @((Get-DocsFastApiRouteSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']), (Get-DocsFlaskRouteSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']))) {
            foreach ($entry in $result['Diagnostics']) { Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsHttpAnalyzerId -Code $entry['Code'] -Path $path -Line ([int] $entry['Line']) -Severity ([string] $entry['Severity']) }
            foreach ($receiver in $result['Receiver']) { $receivers[[string] $receiver['Name']] = $receiver }
            foreach ($site in $result['Site']) { $routes.Add($site) }
        }
        $mounts = Get-DocsHttpMountSite -Line $frontEnd['Lines'] -Import $frontEnd['Import'] -Receiver $frontEnd['Receiver']
        foreach ($entry in $mounts['Diagnostics']) { Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsHttpAnalyzerId -Code $entry['Code'] -Path $path -Line ([int] $entry['Line']) -Severity ([string] $entry['Severity']) }
        $file = @{ Path = $path; Text = $text; Module = $module; Package = $package; Import = $frontEnd['Import']; Receiver = $receivers; Route = $routes.ToArray(); Mount = $mounts['Site'] }
        $files.Add($file)
        foreach ($name in $receivers.Keys) { $receiverByKey[$path + '|' + $name] = @{ Receiver = $receivers[$name]; Path = $path } }
        if ($null -ne $module -and -not $fileByModule.ContainsKey($module)) { $fileByModule[$module] = $file }
    }

    $includedBy = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    foreach ($file in $files) {
        foreach ($mount in $file['Mount']) {
            $childKey = Resolve-DocsHttpChild -File $file -Child ([string] $mount['Child']) -ReceiverByKey $receiverByKey -FileByModule $fileByModule
            if ($null -eq $childKey -or $receiverByKey[$childKey]['Receiver']['Kind'] -ceq 'app') {
                Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsHttpAnalyzerId -Code 'HTTP_MOUNT_UNRESOLVED' -Path $file['Path'] -Line ([int] $mount['Line']) -Severity 'warning'
                continue
            }
            if (-not $includedBy.ContainsKey($childKey)) { $includedBy[$childKey] = [System.Collections.Generic.List[object]]::new() }
            $includedBy[$childKey].Add(@{ ParentKey = $file['Path'] + '|' + [string] $mount['Parent']; Prefix = $mount['Prefix']; PrefixDynamic = $mount['PrefixDynamic']; PrefixGiven = $mount['PrefixGiven']; Path = $file['Path']; Line = $mount['Line'] })
        }
    }

    $candidates = [System.Collections.Generic.List[object]]::new()
    foreach ($file in $files) {
        foreach ($route in $file['Route']) {
            $key = $file['Path'] + '|' + [string] $route['Receiver']
            $receiver = $receiverByKey[$key]['Receiver']
            $resolved = Get-DocsHttpChain -Key $key -ReceiverByKey $receiverByKey -IncludedBy $includedBy -Stack ([System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal))
            $chains = [System.Collections.Generic.List[object]]::new()
            foreach ($chain in $resolved['Chains']) { $chains.Add(@{ Segment = @($chain); Mounted = $true }) }
            if ($resolved['Cycle']) { Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsHttpAnalyzerId -Code 'HTTP_INCLUDE_UNRESOLVED' -Path $file['Path'] -Line ([int] $route['Line']) -Severity 'warning' }
            if ($chains.Count -eq 0) { $chains.Add(@{ Segment = @(, @{ Text = $receiver['Prefix']; Dynamic = $receiver['PrefixDynamic']; Path = $file['Path']; Line = $receiver['Line'] }); Mounted = $false }) }
            foreach ($chain in $chains) {
                $prefixes = [System.Collections.Generic.List[string]]::new()
                $prefixResolved = $true
                foreach ($segment in $chain['Segment']) {
                    if ($segment['Dynamic']) {
                        $prefixResolved = $false
                        $prefixes.Add($script:DocsHttpDynamicSegment)
                        Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsHttpAnalyzerId -Code 'HTTP_PREFIX_DYNAMIC' -Path ([string] $segment['Path']) -Line ([int] $segment['Line']) -Severity 'warning'
                    } else { $prefixes.Add([string] $segment['Text']) }
                }
                $template = Resolve-DocsHttpTemplate -Framework $route['Framework'] -Prefix $prefixes.ToArray() -Path ([string] $route['Path'])
                [string[]] $methods = @($route['Method'])
                [Array]::Sort($methods, [System.StringComparer]::Ordinal)
                foreach ($method in $methods) {
                    $candidates.Add(@{
                            Line      = [int] $route['Line']
                            Parameter = @{
                                Kind           = 'http-route'
                                Path           = $file['Path']
                                Declaration    = $method + ' ' + $template
                                Name           = [string] $route['Name']
                                AnalyzerId     = $script:DocsHttpAnalyzerId
                                AnalysisMethod = 'scanner'
                                SourceText     = $file['Text']
                                ParentId       = $null
                                LineRange      = (ConvertTo-DocsLineRange -Span @(, $route['Span']))
                                Property       = @{ framework = [string] $route['Framework']; mounted = [bool] $chain['Mounted']; prefix_resolved = $prefixResolved; protocol = [string] $route['Protocol'] }
                            }
                        })
                }
            }
        }
    }
    $elements = Select-DocsUniqueElement -Candidate $candidates.ToArray() -Aggregate $aggregate
    return @{ Elements = [object[]]@($elements); Diagnostics = [object[]]@($aggregate.Diagnostics) }
}

Export-ModuleMember -Function Invoke-DocsAnalyzerPythonHttp, Resolve-DocsHttpTemplate
