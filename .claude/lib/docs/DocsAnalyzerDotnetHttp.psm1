<#
.SYNOPSIS
    dotnet-http scanner: ASP.NET Core attribute routes and minimal-API Map* routes in C#
    sources, emitted as http-route elements.

.DESCRIPTION
    Invoke-DocsAnalyzerDotnetHttp selects *.cs inputs, tokenizes each with
    ConvertTo-DocsCSharpToken and classifies two construct families. Attribute routing: a
    controller class (name ending in Controller, [ApiController] or [Controller], or a
    Controller or ControllerBase base) with class [Route] prefixes and literal [Area]; actions
    with [HttpGet] .. [HttpOptions] (with or without a template), [Route] and [AcceptVerbs],
    one element per verb and template combination, '/' and '~/' templates overriding the
    prefix, [controller], [action] (without Async) and [area] tokens replaced, literal-only '+'
    folded. Minimal APIs: receiver.MapGet .. MapPatch, MapMethods with array or collection
    expressions, Map as ANY, MapGroup variables and chains composing prefixes. Elements are
    built only through New-DocsSurfaceElement -AnalysisMethod scanner -SourceText; the digest
    is never computed here. Attribute and Map* names match by exact case, as C# names are
    case-sensitive. Every function is pure.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Get-DocsScannerPrecisionLimit is the shipped statement of this scanner's precision limit
    (HTTP_DYNAMIC_ROUTE, HTTP_PREFIX_DYNAMIC, HTTP_RECEIVER_UNRESOLVED,
    HTTP_ROUTE_TOKEN_UNRESOLVED, HTTP_ENDPOINT_KIND_UNSUPPORTED,
    DOTNET_ROUTE_INHERITED_UNRESOLVED, DOTNET_CONVENTIONAL_ROUTING_UNRESOLVED,
    CSHARP_CONDITIONAL_COMPILATION).
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsCSharpTokens.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsCSharpSyntax.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsScannerCommon.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

$script:DocsDotnetHttpAnalyzerId = 'dotnet-http'
# Ordinal comparers: C# attribute and method names are case-sensitive, so a wrong-case name is not a route.
$script:DocsDotnetVerbAttribute = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::Ordinal)
foreach ($pair in @(@('HttpGet', 'GET'), @('HttpPost', 'POST'), @('HttpPut', 'PUT'), @('HttpDelete', 'DELETE'), @('HttpPatch', 'PATCH'), @('HttpHead', 'HEAD'), @('HttpOptions', 'OPTIONS'))) { $script:DocsDotnetVerbAttribute.Add($pair[0], $pair[1]) }
$script:DocsDotnetMapMethod = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::Ordinal)
foreach ($pair in @(@('MapGet', 'GET'), @('MapPost', 'POST'), @('MapPut', 'PUT'), @('MapDelete', 'DELETE'), @('MapPatch', 'PATCH'))) { $script:DocsDotnetMapMethod.Add($pair[0], $pair[1]) }
$script:DocsDotnetUnsupportedMap = [string[]]@('MapHub', 'MapGrpcService', 'MapHealthChecks', 'MapFallback', 'MapRazorPages')
$script:DocsDotnetConventionalMap = [string[]]@('MapControllerRoute', 'MapDefaultControllerRoute')

function Get-DocsDotnetAttributeTemplate {
    <#
    .SYNOPSIS
        Returns @{ Present; Literal } for an attribute's first positional argument: Present when a positional argument exists, Literal its folded string or $null when dynamic (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [hashtable] $Attribute
    )

    [object[]] $arguments = @($Attribute['Argument'])
    if ($arguments.Count -eq 0) { return @{ Present = $false; Literal = $null } }
    $first = $arguments[0]
    for ($scan = [int] $first['Start']; $scan -le [int] $first['End']; $scan++) {
        if ((Test-DocsCSharpToken -Tokens $Tokens -Index $scan -Kind 'punct' -Text @('=')) -and [int] $Tokens[$scan]['Depth'] -eq [int] $Tokens[[int] $first['Start']]['Depth']) { return @{ Present = $false; Literal = $null } }
    }
    return @{ Present = $true; Literal = (Get-DocsScannerLiteral -Tokens $Tokens -Span $first) }
}

function Add-DocsDotnetRoute {
    <#
    .SYNOPSIS
        Adds one http-route element record to State['Route'] (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [string] $Method,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Template,
        [Parameter(Mandatory = $true)] [string] $Name,
        [Parameter(Mandatory = $true)] [int] $Line,
        [Parameter(Mandatory = $true)] [int] $EndLine,
        [AllowNull()] [string] $FrameworkMethod,
        [bool] $PrefixResolved = $true
    )

    $State['Route'].Add(@{ Method = $Method; Template = $Template; Name = $Name; Line = $Line; EndLine = $EndLine; FrameworkMethod = $FrameworkMethod; PrefixResolved = $PrefixResolved })
}

function Add-DocsDotnetControllerAction {
    <#
    .SYNOPSIS
        Adds the routes of one controller action from its attributes and method header (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [hashtable] $Controller,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Attribute,
        [Parameter(Mandatory = $true)] [string] $MethodName,
        [Parameter(Mandatory = $true)] [int] $Line,
        [Parameter(Mandatory = $true)] [int] $EndLine
    )

    $tokens = $State['Tokens']
    $set = $State['Set']
    $path = [string] $State['Path']
    $verbs = [System.Collections.Generic.List[object]]::new()
    $routeTemplates = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $Attribute) {
        $name = [string] $entry['Name']
        if ($name -ceq 'NonAction') { return }
        if ($script:DocsDotnetVerbAttribute.ContainsKey($name)) { $verbs.Add(@{ Verb = [string] $script:DocsDotnetVerbAttribute[$name]; Template = (Get-DocsDotnetAttributeTemplate -Tokens $tokens -Attribute $entry); Line = [int] $entry['Line'] }); continue }
        if ($name -ceq 'AcceptVerbs') {
            foreach ($span in @($entry['Argument'])) {
                $start = [int] $span['Start']
                if ((Test-DocsCSharpToken -Tokens $tokens -Index $start -Kind 'identifier') -and (Test-DocsCSharpToken -Tokens $tokens -Index ($start + 1) -Kind 'punct' -Text @('='))) {
                    if ([string] $tokens[$start]['Text'] -ceq 'Route' -and $start + 2 -le [int] $span['End']) { $routeTemplates.Add(@{ Template = @{ Present = $true; Literal = (Get-DocsScannerLiteral -Tokens $tokens -Span @{ Start = $start + 2; End = [int] $span['End'] }) }; Line = [int] $entry['Line'] }) }
                    continue
                }
                $literal = Get-DocsScannerLiteral -Tokens $tokens -Span $span
                if ($null -eq $literal) { Add-DocsScannerDiagnostic -Set $set -Code 'HTTP_DYNAMIC_ROUTE' -Path $path -Line ([int] $entry['Line']); continue }
                $verbs.Add(@{ Verb = $literal.ToUpperInvariant(); Template = @{ Present = $false; Literal = $null }; Line = [int] $entry['Line'] })
            }
            continue
        }
        if ($name -ceq 'Route') { $routeTemplates.Add(@{ Template = (Get-DocsDotnetAttributeTemplate -Tokens $tokens -Attribute $entry); Line = [int] $entry['Line'] }) }
    }
    if ($verbs.Count -eq 0) { return }
    if ($Controller['InheritedUnresolved']) { foreach ($verb in $verbs) { Add-DocsScannerDiagnostic -Set $set -Code 'DOTNET_ROUTE_INHERITED_UNRESOLVED' -Path $path -Line ([int] $verb['Line']) }; return }
    foreach ($verb in $verbs) {
        $templates = [System.Collections.Generic.List[object]]::new()
        if ($verb['Template']['Present']) { $templates.Add(@{ Template = $verb['Template']; Line = [int] $verb['Line'] }) }
        foreach ($entry in $routeTemplates) { $templates.Add($entry) }
        if ($templates.Count -eq 0) { $templates.Add(@{ Template = @{ Present = $false; Literal = '' }; Line = [int] $verb['Line'] }) }
        foreach ($entry in $templates) {
            $literal = $entry['Template']['Literal']
            if ($null -eq $literal) { Add-DocsScannerDiagnostic -Set $set -Code 'HTTP_DYNAMIC_ROUTE' -Path $path -Line ([int] $entry['Line']); continue }
            [object[]] $prefixes = @($Controller['Prefix'])
            if ($literal.StartsWith('/') -or $literal.StartsWith('~/')) { $prefixes = @(@{ Template = ''; Dynamic = $false }); $literal = $literal.TrimStart('~') }
            foreach ($prefix in $prefixes) {
                if ($prefix['Dynamic']) { Add-DocsScannerDiagnostic -Set $set -Code 'HTTP_DYNAMIC_ROUTE' -Path $path -Line ([int] $entry['Line']); continue }
                $template = Join-DocsRouteTemplate -Prefix ([string] $prefix['Template']) -Template $literal
                if ([regex]::IsMatch($template, '\[area\]', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
                    if ($null -eq $Controller['Area']) { Add-DocsScannerDiagnostic -Set $set -Code 'HTTP_ROUTE_TOKEN_UNRESOLVED' -Path $path -Line ([int] $entry['Line']); continue }
                    $template = [regex]::Replace($template, '\[area\]', [string] $Controller['Area'], [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
                }
                $template = [regex]::Replace($template, '\[controller\]', [string] $Controller['Name'], [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
                $template = [regex]::Replace($template, '\[action\]', [regex]::Replace($MethodName, 'Async$', ''), [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
                Add-DocsDotnetRoute -State $State -Method ([string] $verb['Verb']) -Template $template -Name $MethodName -Line $Line -EndLine $EndLine
            }
        }
    }
}

function Add-DocsDotnetController {
    <#
    .SYNOPSIS
        Classifies one class declaration as a controller and adds its action routes (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Attribute,
        [Parameter(Mandatory = $true)] [hashtable] $Declaration
    )

    $tokens = $State['Tokens']
    $name = [string] $Declaration['Name']
    $attributeNames = @($Attribute | ForEach-Object { [string] $_['Name'] })
    [string[]] $bases = @($Declaration['Base'] | ForEach-Object { $text = [string] $_; $dot = $text.LastIndexOf('.'); $text = $text.Substring($dot + 1); $angle = $text.IndexOf('<'); if ($angle -ge 0) { $text.Substring(0, $angle) } else { $text } })
    $isFrameworkBase = ($bases.Count -gt 0) -and @('Controller', 'ControllerBase') -ccontains $bases[0]
    $isController = $name.EndsWith('Controller') -or ($attributeNames -ccontains 'ApiController') -or ($attributeNames -ccontains 'Controller') -or $isFrameworkBase
    if (-not $isController -or [int] $Declaration['BodyOpen'] -lt 0) { return }
    $prefixes = [System.Collections.Generic.List[object]]::new()
    $area = $null
    foreach ($entry in $Attribute) {
        if ([string] $entry['Name'] -ceq 'Route') { $template = Get-DocsDotnetAttributeTemplate -Tokens $tokens -Attribute $entry; $prefixes.Add(@{ Template = $template['Literal']; Dynamic = ($null -eq $template['Literal']) }) }
        elseif ([string] $entry['Name'] -ceq 'Area') { $template = Get-DocsDotnetAttributeTemplate -Tokens $tokens -Attribute $entry; if ($null -ne $template['Literal']) { $area = [string] $template['Literal'] } }
    }
    if ($prefixes.Count -eq 0) { $prefixes.Add(@{ Template = ''; Dynamic = $false }) }
    $controller = @{ Name = [regex]::Replace($name, 'Controller$', ''); Prefix = [object[]] $prefixes.ToArray(); Area = $area; InheritedUnresolved = ($bases.Count -gt 0 -and -not $isFrameworkBase -and -not ($attributeNames -ccontains 'Route')) }
    $index = [int] $Declaration['BodyOpen'] + 1
    $end = [int] $Declaration['BodyClose'] - 1
    $depth = [int] $tokens[[int] $Declaration['BodyOpen']]['Depth'] + 1
    while ($index -le $end) {
        if ([int] $tokens[$index]['Depth'] -ne $depth) { $index++; continue }
        $section = Get-DocsCSharpAttributeSection -Tokens $tokens -Index $index
        $modifier = Get-DocsCSharpModifier -Tokens $tokens -Index ([int] $section['EndIndex'])
        $cursor = [int] $modifier['EndIndex']
        $nested = Get-DocsCSharpTypeDeclaration -Tokens $tokens -Index $cursor
        if ($null -ne $nested) { $index = $(if ([int] $nested['BodyClose'] -ge 0) { [int] $nested['BodyClose'] + 1 } else { [int] $nested['HeaderEnd'] + 1 }); continue }
        $returnType = Get-DocsCSharpTypeText -Tokens $tokens -Index $cursor
        if ($null -eq $returnType -or -not (Test-DocsCSharpToken -Tokens $tokens -Index ([int] $returnType['EndIndex'] + 1) -Kind 'identifier')) { $index++; continue }
        $nameIndex = [int] $returnType['EndIndex'] + 1
        $open = $nameIndex + 1
        if (Test-DocsCSharpToken -Tokens $tokens -Index $open -Kind 'punct' -Text @('<')) { $generic = Get-DocsCSharpTypeText -Tokens $tokens -Index $nameIndex; if ($null -eq $generic) { $index++; continue }; $open = [int] $generic['EndIndex'] + 1 }
        if (-not (Test-DocsCSharpToken -Tokens $tokens -Index $open -Kind 'punct' -Text @('('))) { $index++; continue }
        $close = Get-DocsScannerMatchingClose -Tokens $tokens -OpenIndex $open
        if ($close -lt 0) { $index++; continue }
        $line = if ($section['Attribute'].Count -gt 0) { [int] $section['Attribute'][0]['Line'] } else { [int] $tokens[$index]['Line'] }
        Add-DocsDotnetControllerAction -State $State -Controller $controller -Attribute $section['Attribute'] -MethodName ([string] $tokens[$nameIndex]['Text']) -Line $line -EndLine ([int] $tokens[$close]['Line'])
        $index = $close + 1
    }
}

function Add-DocsDotnetMinimalChain {
    <#
    .SYNOPSIS
        Applies a Map* member chain on a receiver and returns the prefix state the chain evaluates to (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [hashtable] $Chain,
        [Parameter(Mandatory = $true)] [int] $ReceiverIndex
    )

    $tokens = $State['Tokens']
    $set = $State['Set']
    $path = [string] $State['Path']
    $receiverName = [string] $tokens[$ReceiverIndex]['Text']
    $receiverLine = [int] $tokens[$ReceiverIndex]['Line']
    $prefix = ''
    $resolved = $true
    $receiverUnresolved = $false
    if ($State['Group'].ContainsKey($receiverName)) { $prefix = [string] $State['Group'][$receiverName]['Prefix']; $resolved = [bool] $State['Group'][$receiverName]['Resolved'] }
    else {
        foreach ($scope in $State['Scope']) { if ([string] $scope['Name'] -ceq $receiverName -and $ReceiverIndex -ge [int] $scope['Start'] -and $ReceiverIndex -le [int] $scope['End']) { $receiverUnresolved = $true; break } }
    }
    foreach ($call in $Chain['Call']) {
        $name = [string] $call['Name']
        [object[]] $arguments = @($call['Argument'])
        $line = [int] $call['Line']
        if ($name -ceq 'MapGroup') {
            $literal = if ($arguments.Count -ge 1) { Get-DocsScannerLiteral -Tokens $tokens -Span $arguments[0] } else { $null }
            if ($null -eq $literal) { $prefix = Join-DocsRouteTemplate -Prefix $prefix -Template '<dynamic>'; $resolved = $false; Add-DocsScannerDiagnostic -Set $set -Code 'HTTP_PREFIX_DYNAMIC' -Path $path -Line $line }
            else { $prefix = Join-DocsRouteTemplate -Prefix $prefix -Template $literal }
            continue
        }
        if ($script:DocsDotnetUnsupportedMap -ccontains $name) { Add-DocsScannerDiagnostic -Set $set -Code 'HTTP_ENDPOINT_KIND_UNSUPPORTED' -Path $path -Line $line; continue }
        if ($script:DocsDotnetConventionalMap -ccontains $name) { Add-DocsScannerDiagnostic -Set $set -Code 'DOTNET_CONVENTIONAL_ROUTING_UNRESOLVED' -Path $path -Line $line; continue }
        $isMethodCall = $script:DocsDotnetMapMethod.ContainsKey($name)
        if (-not $isMethodCall -and $name -cne 'MapMethods' -and $name -cne 'Map') { continue }
        $template = if ($arguments.Count -ge 1) { Get-DocsScannerLiteral -Tokens $tokens -Span $arguments[0] } else { $null }
        [object[]] $methods = @()
        if ($isMethodCall) { $methods = @([string] $script:DocsDotnetMapMethod[$name]) }
        elseif ($name -ceq 'Map') { $methods = @('ANY') }
        elseif ($arguments.Count -ge 2) { $list = Get-DocsCSharpStringList -Tokens $tokens -Span $arguments[1]; if ($null -ne $list) { $methods = @($list | ForEach-Object { ([string] $_).ToUpperInvariant() }) } }
        if ($null -eq $template -or $methods.Count -eq 0) { Add-DocsScannerDiagnostic -Set $set -Code 'HTTP_DYNAMIC_ROUTE' -Path $path -Line $line; continue }
        if ($receiverUnresolved) { Add-DocsScannerDiagnostic -Set $set -Code 'HTTP_RECEIVER_UNRESOLVED' -Path $path -Line $line }
        $handler = $null
        $last = $arguments[$arguments.Count - 1]
        if ([int] $last['Start'] -eq [int] $last['End'] -and (Test-DocsCSharpToken -Tokens $tokens -Index ([int] $last['Start']) -Kind 'identifier')) { $handler = [string] $tokens[[int] $last['Start']]['Text'] }
        $full = Join-DocsRouteTemplate -Prefix $prefix -Template $template
        foreach ($method in $methods) {
            Add-DocsDotnetRoute -State $State -Method $method -Template $full -Name $(if ($null -ne $handler) { $handler } else { $full }) -Line $receiverLine -EndLine ([int] $call['EndLine']) -FrameworkMethod $(if ($method -ceq 'ANY') { $name } else { $null }) -PrefixResolved ($resolved -and -not $receiverUnresolved)
        }
    }
    return @{ Prefix = $prefix; Resolved = $resolved }
}

function Invoke-DocsDotnetFileScan {
    <#
    .SYNOPSIS
        Scans one tokenized C# file for controllers and minimal-API chains, filling State['Route'] (private helper).
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] [hashtable] $State)

    $tokens = $State['Tokens']
    $index = 0
    while ($index -lt $tokens.Count) {
        $isMember = Test-DocsCSharpToken -Tokens $tokens -Index ($index - 1) -Kind 'punct' -Text @('.', '?.')
        if (-not $isMember -and (Test-DocsCSharpToken -Tokens $tokens -Index $index -Kind 'identifier') -and (Test-DocsCSharpToken -Tokens $tokens -Index ($index + 1) -Kind 'punct' -Text @('.', '?.'))) {
            $chain = Get-DocsCSharpMemberChain -Tokens $tokens -StartIndex $index
            if ($null -ne $chain -and $chain['Call'].Count -gt 0 -and @($chain['Call'] | Where-Object { ([string] $_['Name']).StartsWith('Map') }).Count -gt 0) {
                $result = Add-DocsDotnetMinimalChain -State $State -Chain $chain -ReceiverIndex $index
                if ((Test-DocsCSharpToken -Tokens $tokens -Index ($index - 1) -Kind 'punct' -Text @('=')) -and (Test-DocsCSharpToken -Tokens $tokens -Index ($index - 2) -Kind 'identifier')) { $State['Group'][[string] $tokens[$index - 2]['Text']] = $result }
                $index = [int] $chain['EndIndex'] + 1
                continue
            }
        }
        $startsDeclaration = (Test-DocsCSharpToken -Tokens $tokens -Index $index -Kind 'punct' -Text @('[')) -and -not (Test-DocsCSharpName -Tokens $tokens -Index ($index - 1)) -and -not (Test-DocsCSharpToken -Tokens $tokens -Index ($index - 1) -Kind 'punct' -Text @(')', ']'))
        if (-not $startsDeclaration -and -not $isMember -and (Test-DocsCSharpName -Tokens $tokens -Index $index)) { $startsDeclaration = $true }
        if ($startsDeclaration) {
            $section = Get-DocsCSharpAttributeSection -Tokens $tokens -Index $index
            $modifier = Get-DocsCSharpModifier -Tokens $tokens -Index ([int] $section['EndIndex'])
            $declaration = Get-DocsCSharpTypeDeclaration -Tokens $tokens -Index ([int] $modifier['EndIndex'])
            if ($null -ne $declaration) {
                if ([string] $declaration['Kind'] -ceq 'class') { Add-DocsDotnetController -State $State -Attribute $section['Attribute'] -Declaration $declaration }
                $index = [int] $declaration['HeaderEnd'] + 1
                continue
            }
        }
        $index++
    }
}

function Invoke-DocsAnalyzerDotnetHttp {
    <#
    .SYNOPSIS
        Scans the captured C# inputs for attribute and minimal-API routes and returns @{ Elements; Diagnostics }.
    .DESCRIPTION
        Selection is accepted for the 1020 analyzer contract and not read. Every element is
        built by New-DocsSurfaceElement with -AnalysisMethod scanner and the captured text;
        diagnostics are aggregated per (code, path) and emitted through
        ConvertTo-DocsScannerDiagnostic under dotnet-http. A file containing #if also yields
        CSHARP_CONDITIONAL_COMPILATION at its first directive line.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Identifiers are case-sensitive; an ordinal-comparer hashtable is required.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Selection', Justification = 'The 1020 analyzer contract passes -Selection to every analyzer; this scanner reads no selection key.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [AllowNull()] [object] $Selection
    )

    $set = New-DocsScannerDiagnosticSet
    $elements = [System.Collections.Generic.List[object]]::new()
    $selected = Select-DocsScannerInput -CapturedInput $CapturedInput -Suffix @('.cs')
    foreach ($captured in $selected) {
        $path = [string] $captured['path']
        $text = $captured['text']
        if ($null -eq $text) { Add-DocsScannerDiagnostic -Set $set -Code (Get-DocsScannerInputDiagnosticCode -CapturedInput $captured) -Path $path -Line 0 -Blocking $true; continue }
        $lexed = ConvertTo-DocsCSharpToken -Text $text
        if ($lexed['Diagnostics'].Count -gt 0) {
            foreach ($diagnostic in $lexed['Diagnostics']) { Add-DocsScannerDiagnostic -Set $set -Code ([string] $diagnostic['Code']) -Path $path -Line ([int] $diagnostic['Line']) -Blocking $true }
            continue
        }
        if ($lexed['HasConditional']) {
            $match = [regex]::Match($text, '(?m)^[ \t]*#[ \t]*if\b')
            $line = if ($match.Success) { [regex]::Matches($text.Substring(0, $match.Index), '\r\n|\r|\n').Count + 1 } else { 1 }
            Add-DocsScannerDiagnostic -Set $set -Code 'CSHARP_CONDITIONAL_COMPILATION' -Path $path -Line $line
        }
        [object[]] $scopes = Get-DocsCSharpParameterScope -Tokens $lexed['Tokens']
        $state = @{ Tokens = $lexed['Tokens']; Path = $path; Set = $set; Route = [System.Collections.Generic.List[object]]::new(); Group = [hashtable]::new([System.StringComparer]::Ordinal); Scope = $scopes }
        Invoke-DocsDotnetFileScan -State $state
        foreach ($route in $state['Route']) {
            $property = [ordered]@{}
            if (-not [string]::IsNullOrEmpty([string] $route['FrameworkMethod'])) { $property['framework_method'] = [string] $route['FrameworkMethod'] }
            if (-not [bool] $route['PrefixResolved']) { $property['prefix_resolved'] = $false }
            try {
                $elements.Add((New-DocsSurfaceElement -Kind 'http-route' -Path $path -Declaration ([string] $route['Method'] + ' ' + [string] $route['Template']) -Name ([string] $route['Name']) -AnalyzerId $script:DocsDotnetHttpAnalyzerId -AnalysisMethod 'scanner' -SourceText $text -LineRange @([int] $route['Line'], [int] $route['EndLine']) -Property $property))
            } catch { Add-DocsScannerDiagnostic -Set $set -Code 'DECLARATION_INVALID' -Path $path -Line ([int] $route['Line']) }
        }
    }
    [object[]] $sorted = ConvertTo-DocsScannerElementList -Element $elements.ToArray() -Set $set
    return @{ Elements = $sorted; Diagnostics = [object[]] (ConvertTo-DocsScannerDiagnostic -Set $set -AnalyzerId $script:DocsDotnetHttpAnalyzerId) }
}

Export-ModuleMember -Function Invoke-DocsAnalyzerDotnetHttp
