<#
.SYNOPSIS
    Pass-1 route, receiver and mount recognizers for the issue #1022 python-http scanner:
    FastAPI and Flask applications, routers and blueprints, their route decorators and call
    forms, and include_router, register_blueprint and mount calls.

.DESCRIPTION
    Get-DocsFastApiRouteSite and Get-DocsFlaskRouteSite take the logical lines, import table
    and receiver table of one input and return @{ Site; Receiver; Diagnostics }. A receiver is
    @{ Name; Kind (app, router, blueprint); Framework; Prefix; PrefixDynamic; Line }; a route
    site is @{ Receiver; Method (upper-case tokens, one element per distinct method, WEBSOCKET
    for .websocket); Path (the literal rule); Name (handler name for a decorator, template for a
    call); Span (header span from the route decorator, or the statement span of a call); Line;
    Protocol; Framework }. Get-DocsHttpMountSite returns @{ Site; Diagnostics } where a mount
    site is @{ Parent; Child (dotted expression); Prefix; PrefixDynamic; PrefixGiven; Line;
    Framework; Kind (include, register) }. Diagnostics are records with Code, Severity, Blocking
    and Line: HTTP_DYNAMIC_ROUTE, HTTP_ROUTE_IN_LOOP, HTTP_UNBOUND_ROUTE,
    HTTP_METHOD_VIEW_UNRESOLVED and the .mount(...) case of HTTP_MOUNT_UNRESOLVED (site level,
    non-blocking). Default method GET; converters are kept verbatim; no automatic HEAD or
    OPTIONS. Names are compared ordinally.

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
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPythonSyntax.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPythonBindings.psm1') -ErrorAction Stop

$script:DocsHttpFramework = @{
    fastapi = @{
        Constructor = @{ 'fastapi.FastAPI' = 'app'; 'fastapi.APIRouter' = 'router' }
        PrefixKey   = 'prefix'
        Shortcut    = [string[]]@('get', 'post', 'put', 'patch', 'delete', 'options', 'head', 'trace')
        Generic     = 'api_route'
        Call        = 'add_api_route'
        Mount       = 'include_router'
        MountKey    = 'prefix'
    }
    flask   = @{
        Constructor = @{ 'flask.Flask' = 'app'; 'flask.Blueprint' = 'blueprint' }
        PrefixKey   = 'url_prefix'
        Shortcut    = [string[]]@('get', 'post', 'put', 'patch', 'delete')
        Generic     = 'route'
        Call        = 'add_url_rule'
        Mount       = 'register_blueprint'
        MountKey    = 'url_prefix'
    }
}

function Get-DocsHttpReceiver {
    <#
    .SYNOPSIS
        Returns the receivers of one framework from the receiver table in binding order (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [hashtable] $Receiver, [Parameter(Mandatory = $true)] [hashtable] $Import, [Parameter(Mandatory = $true)] [string] $Framework)

    $definition = $script:DocsHttpFramework[$Framework]
    $ordered = [System.Collections.Generic.List[object]]::new()
    foreach ($key in $Receiver['Receiver'].Keys) { $ordered.Add(@{ Name = [string] $key; Index = [int] $Receiver['Receiver'][$key]['Index'] }) }
    $result = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in @($ordered | Sort-Object -Property @{ Expression = 'Index' })) {
        $binding = $Receiver['Receiver'][$entry['Name']]
        $qualified = Resolve-DocsPythonQualifiedName -Name $binding['Callee'] -Import $Import
        if ($null -eq $qualified -or -not $definition['Constructor'].ContainsKey($qualified)) { continue }
        $kind = $definition['Constructor'][$qualified]
        $prefix = ''
        $dynamic = $false
        if ($kind -cne 'app' -and $binding['Call']['Keyword'].ContainsKey($definition['PrefixKey'])) {
            $argument = $binding['Call']['Keyword'][$definition['PrefixKey']]
            if ($argument['Kind'] -ceq 'string' -and $null -ne $argument['Value']) { $prefix = [string] $argument['Value'] } else { $dynamic = $true }
        }
        $result.Add(@{ Name = $entry['Name']; Kind = $kind; Framework = $Framework; Prefix = $prefix; PrefixDynamic = $dynamic; Line = $binding['Line'] })
    }
    return , $result.ToArray()
}

function Read-DocsHttpMethodList {
    <#
    .SYNOPSIS
        Returns the upper-case literal methods= list of a call, @('GET') when absent, or $null when dynamic (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([Parameter(Mandatory = $true)] [hashtable] $Call)

    if (-not $Call['Keyword'].ContainsKey('methods')) { return , [string[]]@('GET') }
    $argument = $Call['Keyword']['methods']
    if ($argument['Kind'] -cnotin @('list', 'tuple') -or $null -eq $argument['Items']) { return $null }
    $items = @($argument['Items'])
    if ($items.Count -eq 0) { return $null }
    $methods = [System.Collections.Generic.List[string]]::new()
    foreach ($item in $items) { $text = ([string] $item).ToUpperInvariant(); if (-not $methods.Contains($text)) { $methods.Add($text) } }
    return , $methods.ToArray()
}

function Get-DocsHttpRouteSiteCore {
    <#
    .SYNOPSIS
        Collects the route sites of one framework (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Line, [Parameter(Mandatory = $true)] [hashtable] $Import, [Parameter(Mandatory = $true)] [hashtable] $Receiver, [Parameter(Mandatory = $true)] [string] $Framework)

    $definition = $script:DocsHttpFramework[$Framework]
    $receivers = Get-DocsHttpReceiver -Receiver $Receiver -Import $Import -Framework $Framework
    $tracked = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($entry in $receivers) { [void] $tracked.Add([string] $entry['Name']) }
    $definitions = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    for ($index = 0; $index -lt $Line.Count; $index++) {
        $header = Get-DocsPythonDefinitionHeader -Line $Line -Index $index
        if ($null -ne $header) { [void] $definitions.Add([string] $header['Name']) }
    }
    $methodNames = [string[]]@($definition['Shortcut'] + @($definition['Generic']) + $(if ($Framework -ceq 'fastapi') { @('websocket') } else { @() }))
    $sites = [System.Collections.Generic.List[object]]::new()
    $diagnostics = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $Line.Count; $index++) {
        $tokens = $Line[$index]['Tokens']
        $siteLine = $Line[$index]['StartLine']
        $header = Get-DocsPythonDefinitionHeader -Line $Line -Index $index
        if ($null -ne $header -and $header['Kind'] -cne 'class') {
            foreach ($decorator in $header['Decorator']) {
                $callee = $decorator['Callee']
                if ($null -eq $callee) { continue }
                $parts = $callee.Split('.')
                if ($parts.Count -ne 2 -or $methodNames -cnotcontains $parts[1]) { continue }
                $call = $decorator['Call']
                $firstLiteral = $null -ne $call -and $call['Positional'].Count -gt 0 -and $call['Positional'][0]['Kind'] -ceq 'string' -and $null -ne $call['Positional'][0]['Value']
                if (-not $tracked.Contains($parts[0])) {
                    if (-not $Receiver['Receiver'].ContainsKey($parts[0]) -and -not $definitions.Contains($parts[0]) -and -not $Import['Alias'].ContainsKey($parts[0]) -and $firstLiteral -and ([string] $call['Positional'][0]['Value']).StartsWith('/', [System.StringComparison]::Ordinal)) {
                        $diagnostics.Add(@{ Code = 'HTTP_UNBOUND_ROUTE'; Severity = 'warning'; Blocking = $false; Line = $decorator['StartLine'] })
                    }
                    continue
                }
                if ((Get-DocsPythonEnclosingBlock -Line $Line -Index $index)['InLoop']) { $diagnostics.Add(@{ Code = 'HTTP_ROUTE_IN_LOOP'; Severity = 'warning'; Blocking = $false; Line = $decorator['StartLine'] }); continue }
                $methods = if ($parts[1] -ceq $definition['Generic']) { $(if ($null -ne $call) { Read-DocsHttpMethodList -Call $call } else { $null }) } elseif ($parts[1] -ceq 'websocket') { [string[]]@('WEBSOCKET') } else { [string[]]@($parts[1].ToUpperInvariant()) }
                if (-not $firstLiteral -or $null -eq $methods) { $diagnostics.Add(@{ Code = 'HTTP_DYNAMIC_ROUTE'; Severity = 'warning'; Blocking = $false; Line = $decorator['StartLine'] }); continue }
                $sites.Add(@{ Receiver = $parts[0]; Method = $methods; Path = [string] $call['Positional'][0]['Value']; Name = $header['Name']; Span = @($decorator['StartLine'], $header['HeaderEnd']); Line = $decorator['StartLine']; Protocol = $(if ($parts[1] -ceq 'websocket') { 'websocket' } else { 'http' }); Framework = $Framework })
            }
            continue
        }
        if ($tokens[0]['Type'] -ceq 'OP' -and $tokens[0]['Text'] -ceq '@') { continue }
        $cursor = 0
        while ($cursor -lt $tokens.Count) {
            if ($tokens[$cursor]['Type'] -cne 'NAME' -or $tokens[$cursor]['IsKeyword']) { $cursor++; continue }
            $call = Read-DocsPythonCall -Token $tokens -Index $cursor
            if ($null -eq $call) { $cursor++; continue }
            $cursor = $call['OpenIndex'] + 1
            $parts = $call['CalleeParts']
            if ($parts.Count -ne 2 -or $parts[1] -cne $definition['Call'] -or -not $tracked.Contains($parts[0])) { continue }
            if ((Get-DocsPythonEnclosingBlock -Line $Line -Index $index -TokenIndex $call['Start'])['InLoop']) { $diagnostics.Add(@{ Code = 'HTTP_ROUTE_IN_LOOP'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); continue }
            $literalMethods = $call['Keyword'].ContainsKey('methods') -and $null -ne (Read-DocsHttpMethodList -Call $call)
            if ($Framework -ceq 'flask' -and -not $literalMethods -and $call['Keyword'].ContainsKey('view_func') -and $call['Keyword']['view_func']['Kind'] -ceq 'call' -and ([string] $call['Keyword']['view_func']['Value']).EndsWith('.as_view', [System.StringComparison]::Ordinal)) {
                $diagnostics.Add(@{ Code = 'HTTP_METHOD_VIEW_UNRESOLVED'; Severity = 'warning'; Blocking = $false; Line = $siteLine })
                continue
            }
            $methods = Read-DocsHttpMethodList -Call $call
            $firstLiteral = $call['Positional'].Count -gt 0 -and $call['Positional'][0]['Kind'] -ceq 'string' -and $null -ne $call['Positional'][0]['Value']
            if (-not $firstLiteral -or $null -eq $methods) { $diagnostics.Add(@{ Code = 'HTTP_DYNAMIC_ROUTE'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); continue }
            $path = [string] $call['Positional'][0]['Value']
            $sites.Add(@{ Receiver = $parts[0]; Method = $methods; Path = $path; Name = $path; Span = @($siteLine, $Line[$index]['EndLine']); Line = $siteLine; Protocol = 'http'; Framework = $Framework })
        }
    }
    return @{ Site = $sites.ToArray(); Receiver = $receivers; Diagnostics = $diagnostics.ToArray() }
}

function Get-DocsFastApiRouteSite {
    <#
    .SYNOPSIS
        Returns @{ Site; Receiver; Diagnostics } for the FastAPI receivers and routes of one input.
    .DESCRIPTION
        Receivers are FastAPI(...) applications and APIRouter(prefix=...) routers. Routes are
        the get, post, put, patch, delete, options, head and trace decorators (literal path),
        api_route(path, methods=[...]), websocket(path) (WEBSOCKET, protocol websocket) and
        add_api_route(path, endpoint, methods=[...]) on a tracked receiver.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Line,
        [Parameter(Mandatory = $true)] [hashtable] $Import,
        [Parameter(Mandatory = $true)] [hashtable] $Receiver
    )

    return Get-DocsHttpRouteSiteCore -Line $Line -Import $Import -Receiver $Receiver -Framework 'fastapi'
}

function Get-DocsFlaskRouteSite {
    <#
    .SYNOPSIS
        Returns @{ Site; Receiver; Diagnostics } for the Flask receivers and routes of one input.
    .DESCRIPTION
        Receivers are Flask(...) applications and Blueprint("name", __name__, url_prefix=...)
        blueprints. Routes are .route(path, methods=[...]), the .get .post .put .patch .delete
        shortcuts and .add_url_rule(path, ..., methods=[...]) on a tracked receiver; an
        add_url_rule whose view_func is an X.as_view(...) call without literal methods yields
        HTTP_METHOD_VIEW_UNRESOLVED. Converters such as <int:id> are kept verbatim.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Line,
        [Parameter(Mandatory = $true)] [hashtable] $Import,
        [Parameter(Mandatory = $true)] [hashtable] $Receiver
    )

    return Get-DocsHttpRouteSiteCore -Line $Line -Import $Import -Receiver $Receiver -Framework 'flask'
}

function Get-DocsHttpMountSite {
    <#
    .SYNOPSIS
        Returns @{ Site; Diagnostics } for the include_router, register_blueprint and mount calls of one input.
    .DESCRIPTION
        A mount site records the tracked parent receiver, the child expression (a name or a
        dotted attribute, resolved across inputs in pass 2), and the literal prefix= or
        url_prefix= (PrefixGiven, PrefixDynamic). A .mount(...) call on a tracked receiver and
        an include with a non-name child yield HTTP_MOUNT_UNRESOLVED.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Line,
        [Parameter(Mandatory = $true)] [hashtable] $Import,
        [Parameter(Mandatory = $true)] [hashtable] $Receiver
    )

    $tracked = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::Ordinal)
    foreach ($framework in 'fastapi', 'flask') {
        foreach ($entry in (Get-DocsHttpReceiver -Receiver $Receiver -Import $Import -Framework $framework)) { $tracked[[string] $entry['Name']] = $framework }
    }
    $sites = [System.Collections.Generic.List[object]]::new()
    $diagnostics = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $Line.Count; $index++) {
        $tokens = $Line[$index]['Tokens']
        if ($tokens[0]['Type'] -ceq 'OP' -and $tokens[0]['Text'] -ceq '@') { continue }
        $siteLine = $Line[$index]['StartLine']
        $cursor = 0
        while ($cursor -lt $tokens.Count) {
            if ($tokens[$cursor]['Type'] -cne 'NAME' -or $tokens[$cursor]['IsKeyword']) { $cursor++; continue }
            $call = Read-DocsPythonCall -Token $tokens -Index $cursor
            if ($null -eq $call) { $cursor++; continue }
            $cursor = $call['OpenIndex'] + 1
            $parts = $call['CalleeParts']
            $framework = $null
            if ($parts.Count -ne 2 -or -not $tracked.TryGetValue($parts[0], [ref] $framework)) { continue }
            if ($parts[1] -ceq 'mount') { $diagnostics.Add(@{ Code = 'HTTP_MOUNT_UNRESOLVED'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); continue }
            $definition = $script:DocsHttpFramework[$framework]
            if ($parts[1] -cne $definition['Mount']) { continue }
            if ($call['Positional'].Count -eq 0 -or $call['Positional'][0]['Kind'] -cnotin @('name', 'attribute')) { $diagnostics.Add(@{ Code = 'HTTP_MOUNT_UNRESOLVED'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); continue }
            $prefix = ''
            $dynamic = $false
            $given = $call['Keyword'].ContainsKey($definition['MountKey'])
            if ($given) {
                $argument = $call['Keyword'][$definition['MountKey']]
                if ($argument['Kind'] -ceq 'string' -and $null -ne $argument['Value']) { $prefix = [string] $argument['Value'] } else { $dynamic = $true }
            }
            $sites.Add(@{ Parent = $parts[0]; Child = [string] $call['Positional'][0]['Value']; Prefix = $prefix; PrefixDynamic = $dynamic; PrefixGiven = $given; Line = $siteLine; Framework = $framework; Kind = $(if ($framework -ceq 'fastapi') { 'include' } else { 'register' }) })
        }
    }
    return @{ Site = $sites.ToArray(); Diagnostics = $diagnostics.ToArray() }
}

Export-ModuleMember -Function Get-DocsFastApiRouteSite, Get-DocsFlaskRouteSite, Get-DocsHttpMountSite
