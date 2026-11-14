<#
.SYNOPSIS
    Per-file recognition for the typescript-http scanner (pass 1): Express and Fastify route
    registrations, router mounts and plugin registrations on the receivers that
    DocsTypeScriptHttpDeclaration.psm1 declares.

.DESCRIPTION
    Get-DocsHttpFileScan reads a token stream, records the file's imports, runs the declaration
    pre-pass and then walks every member chain whose receiver resolves. A route is
    @{ Method; FrameworkMethod; Template; Line; EndLine; Handler } (method upper-case, all as
    ANY); a mount is @{ Prefix ($null when dynamic); Local; ImportPath; ImportName; Line } and
    is resolved across files by the analyzer (pass 2). Express use() takes literal or array
    prefixes and tracked or captured-import routers; Fastify register() takes inline, same-file
    and captured-import plugins (fp(fn) unwrapped) with a { prefix } option. Diagnostics
    HTTP_DYNAMIC_ROUTE, HTTP_PREFIX_DYNAMIC and HTTP_MOUNT_UNRESOLVED are added to the shared
    aggregation set. Every function is pure apart from the explicit State it is given.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Split from DocsAnalyzerTypeScriptHttp.psm1 under the plan's 500-logical-line rule.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsTypeScriptSyntax.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsTypeScriptHttpDeclaration.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsScannerCommon.psm1') -ErrorAction Stop

$script:DocsHttpMethod = [string[]]@('get', 'post', 'put', 'delete', 'patch', 'options', 'head', 'all')

function Add-DocsHttpMountTarget {
    <#
    .SYNOPSIS
        Adds a mount for the bare identifier at Index when it denotes a local receiver or a captured relative import, else records HTTP_MOUNT_UNRESOLVED; returns $true when a mount was added (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [hashtable] $Receiver,
        [Parameter(Mandatory = $true)] [int] $Index,
        [AllowNull()] [object] $Prefix,
        [Parameter(Mandatory = $true)] [int] $Line
    )

    # Prefix is typed as object: a [string] parameter would turn the $null that marks a dynamic prefix into ''.
    $name = [string] $State['Tokens'][$Index]['Text']
    $local = Resolve-DocsHttpReceiver -State $State -Name $name -Index $Index
    if ($null -ne $local -and [string] $local['Name'] -ceq $name) {
        $Receiver['Mount'].Add(@{ Prefix = $Prefix; Local = $name; ImportPath = $null; ImportName = $null; Line = $Line })
        return $true
    }
    if ($State['Import'].ContainsKey($name)) {
        $binding = $State['Import'][$name]
        $resolved = Resolve-DocsTypeScriptRelativeModule -FromPath $State['Path'] -Specifier ([string] $binding['Module']) -CapturedPath $State['CapturedPath']
        if ($null -ne $resolved) {
            $Receiver['Mount'].Add(@{ Prefix = $Prefix; Local = $null; ImportPath = $resolved; ImportName = [string] $binding['Imported']; Line = $Line })
            return $true
        }
    }
    Add-DocsScannerDiagnostic -Set $State['Set'] -Code 'HTTP_MOUNT_UNRESOLVED' -Path $State['Path'] -Line $Line
    return $false
}

function Get-DocsHttpHandlerName {
    <#
    .SYNOPSIS
        Returns the bare identifier of the last argument span when it is one, else $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Argument
    )

    if ($Argument.Count -eq 0) { return $null }
    $last = $Argument[$Argument.Count - 1]
    $start = [int] $last['Start']
    if ($start -ne [int] $last['End'] -or -not (Test-DocsTypeScriptToken -Tokens $State['Tokens'] -Index $start -Kind 'identifier')) { return $null }
    return [string] $State['Tokens'][$start]['Text']
}

function Add-DocsHttpRoute {
    <#
    .SYNOPSIS
        Adds one route per template for a method call (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Receiver,
        [Parameter(Mandatory = $true)] [string] $Method,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Template,
        [Parameter(Mandatory = $true)] [int] $Line,
        [Parameter(Mandatory = $true)] [int] $EndLine,
        [AllowNull()] [string] $Handler
    )

    $upper = if ($Method -ceq 'all') { 'ANY' } else { $Method.ToUpperInvariant() }
    foreach ($template in $Template) {
        $Receiver['Route'].Add(@{ Method = $upper; FrameworkMethod = $Method; Template = $template; Line = $Line; EndLine = $EndLine; Handler = $Handler })
    }
}

function Invoke-DocsHttpChain {
    <#
    .SYNOPSIS
        Applies the calls of a member chain on a receiver: route methods, route(), use() and register() (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [hashtable] $Receiver,
        [Parameter(Mandatory = $true)] [hashtable] $Chain,
        [Parameter(Mandatory = $true)] [int] $ReceiverIndex
    )

    $tokens = $State['Tokens']
    $set = $State['Set']
    $path = [string] $State['Path']
    $receiverLine = [int] $tokens[$ReceiverIndex]['Line']
    $routeTemplate = $null
    $routeDynamic = $false
    foreach ($call in $Chain['Call']) {
        $name = [string] $call['Name']
        [object[]] $arguments = @($call['Argument'])
        $line = [int] $call['Line']
        $endLine = [int] $call['EndLine']
        if ($script:DocsHttpMethod -ccontains $name) {
            if ($routeDynamic) { continue }
            if ($null -ne $routeTemplate) { Add-DocsHttpRoute -Receiver $Receiver -Method $name -Template @($routeTemplate) -Line $receiverLine -EndLine $endLine -Handler (Get-DocsHttpHandlerName -State $State -Argument $arguments); continue }
            if ($arguments.Count -eq 0) { Add-DocsScannerDiagnostic -Set $set -Code 'HTTP_DYNAMIC_ROUTE' -Path $path -Line $line; continue }
            $literal = Get-DocsScannerLiteral -Tokens $tokens -Span $arguments[0]
            [string[]] $templates = @()
            if ($null -ne $literal) { $templates = @($literal) } else { $array = Get-DocsTypeScriptArrayLiteral -Tokens $tokens -Span $arguments[0]; if ($null -ne $array) { $templates = $array } }
            if ($templates.Count -eq 0) { Add-DocsScannerDiagnostic -Set $set -Code 'HTTP_DYNAMIC_ROUTE' -Path $path -Line $line; continue }
            Add-DocsHttpRoute -Receiver $Receiver -Method $name -Template $templates -Line $receiverLine -EndLine $endLine -Handler (Get-DocsHttpHandlerName -State $State -Argument $arguments)
            continue
        }
        if ($name -ceq 'route') {
            if ([string] $Receiver['Framework'] -ceq 'fastify') { Add-DocsHttpFastifyRoute -State $State -Receiver $Receiver -Call $call -ReceiverLine $receiverLine; continue }
            $routeTemplate = if ($arguments.Count -ge 1) { Get-DocsScannerLiteral -Tokens $tokens -Span $arguments[0] } else { $null }
            if ($null -eq $routeTemplate) { $routeDynamic = $true; Add-DocsScannerDiagnostic -Set $set -Code 'HTTP_DYNAMIC_ROUTE' -Path $path -Line $line }
            continue
        }
        if ($name -ceq 'use' -and [string] $Receiver['Framework'] -ceq 'express') { Add-DocsHttpUse -State $State -Receiver $Receiver -Call $call; continue }
        if ($name -ceq 'register' -and [string] $Receiver['Framework'] -ceq 'fastify') { Add-DocsHttpRegister -State $State -Receiver $Receiver -Call $call }
    }
}

function Add-DocsHttpFastifyRoute {
    <#
    .SYNOPSIS
        Applies a Fastify route({ method, url | path, handler }) call (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [hashtable] $Receiver,
        [Parameter(Mandatory = $true)] [hashtable] $Call,
        [Parameter(Mandatory = $true)] [int] $ReceiverLine
    )

    $tokens = $State['Tokens']
    [object[]] $arguments = @($Call['Argument'])
    $line = [int] $Call['Line']
    if ($arguments.Count -eq 0 -or -not (Test-DocsTypeScriptToken -Tokens $tokens -Index ([int] $arguments[0]['Start']) -Kind 'punct' -Text @('{'))) { Add-DocsScannerDiagnostic -Set $State['Set'] -Code 'HTTP_DYNAMIC_ROUTE' -Path $State['Path'] -Line $line; return }
    [string[]] $methods = @()
    $url = $null
    $handler = $null
    $members = Get-DocsTypeScriptObjectMember -Tokens $tokens -OpenIndex ([int] $arguments[0]['Start'])
    foreach ($member in $members) {
        if ($null -eq $member['Key'] -or [int] $member['ValueStart'] -lt 0) { continue }
        $span = @{ Start = [int] $member['ValueStart']; End = [int] $member['ValueEnd'] }
        switch ([string] $member['Key']) {
            'method' { $literal = Get-DocsScannerLiteral -Tokens $tokens -Span $span; if ($null -ne $literal) { $methods = @($literal) } else { $array = Get-DocsTypeScriptArrayLiteral -Tokens $tokens -Span $span; if ($null -ne $array) { $methods = $array } } }
            'url' { $url = Get-DocsScannerLiteral -Tokens $tokens -Span $span }
            'path' { if ($null -eq $url) { $url = Get-DocsScannerLiteral -Tokens $tokens -Span $span } }
            'handler' { if ([int] $span['Start'] -eq [int] $span['End'] -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ([int] $span['Start']) -Kind 'identifier')) { $handler = [string] $tokens[[int] $span['Start']]['Text'] } }
        }
    }
    if ($methods.Count -eq 0 -or $null -eq $url) { Add-DocsScannerDiagnostic -Set $State['Set'] -Code 'HTTP_DYNAMIC_ROUTE' -Path $State['Path'] -Line $line; return }
    foreach ($method in $methods) { Add-DocsHttpRoute -Receiver $Receiver -Method $method.ToLowerInvariant() -Template @($url) -Line $ReceiverLine -EndLine ([int] $Call['EndLine']) -Handler $handler }
}

function Add-DocsHttpUse {
    <#
    .SYNOPSIS
        Applies an Express use(prefix?, ...targets) call: literal or array prefixes, tracked or imported router targets, dynamic prefixes (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [hashtable] $Receiver,
        [Parameter(Mandatory = $true)] [hashtable] $Call
    )

    $tokens = $State['Tokens']
    [object[]] $arguments = @($Call['Argument'])
    if ($arguments.Count -eq 0) { return }
    $line = [int] $Call['Line']
    [string[]] $prefixes = @('')
    $prefixDynamic = $false
    $targetStart = 0
    $firstIndex = [int] $arguments[0]['Start']
    $literal = Get-DocsScannerLiteral -Tokens $tokens -Span $arguments[0]
    $array = Get-DocsTypeScriptArrayLiteral -Tokens $tokens -Span $arguments[0]
    $isBare = ($firstIndex -eq [int] $arguments[0]['End']) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index $firstIndex -Kind 'identifier')
    $isKnownTarget = $isBare -and ($null -ne (Resolve-DocsHttpReceiver -State $State -Name ([string] $tokens[$firstIndex]['Text']) -Index $firstIndex) -or $State['Import'].ContainsKey([string] $tokens[$firstIndex]['Text']))
    if ($null -ne $literal) { $prefixes = @($literal); $targetStart = 1 }
    elseif ($null -ne $array) { $prefixes = $array; $targetStart = 1 }
    elseif ($arguments.Count -ge 2 -and -not $isKnownTarget -and -not (Test-DocsTypeScriptToken -Tokens $tokens -Index ($firstIndex + 1) -Kind 'punct' -Text @('('))) { $prefixDynamic = $true; $targetStart = 1 }
    $mounted = 0
    for ($argumentIndex = $targetStart; $argumentIndex -lt $arguments.Count; $argumentIndex++) {
        $span = $arguments[$argumentIndex]
        $start = [int] $span['Start']
        if ($start -ne [int] $span['End'] -or -not (Test-DocsTypeScriptToken -Tokens $tokens -Index $start -Kind 'identifier')) { continue }
        foreach ($prefix in $prefixes) {
            if (Add-DocsHttpMountTarget -State $State -Receiver $Receiver -Index $start -Prefix $(if ($prefixDynamic) { $null } else { $prefix }) -Line $line) { $mounted++ }
        }
    }
    if ($prefixDynamic -and $mounted -gt 0) { Add-DocsScannerDiagnostic -Set $State['Set'] -Code 'HTTP_PREFIX_DYNAMIC' -Path $State['Path'] -Line $line }
}

function Add-DocsHttpRegister {
    <#
    .SYNOPSIS
        Applies a Fastify register(plugin, { prefix }) call: inline, same-file and captured-import plugins, fp(fn) unwrapping, dynamic prefixes (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [hashtable] $Receiver,
        [Parameter(Mandatory = $true)] [hashtable] $Call
    )

    $tokens = $State['Tokens']
    [object[]] $arguments = @($Call['Argument'])
    if ($arguments.Count -eq 0) { return }
    $line = [int] $Call['Line']
    $prefix = ''
    $prefixDynamic = $false
    if ($arguments.Count -ge 2 -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ([int] $arguments[1]['Start']) -Kind 'punct' -Text @('{'))) {
        $members = Get-DocsTypeScriptObjectMember -Tokens $tokens -OpenIndex ([int] $arguments[1]['Start'])
        foreach ($member in $members) {
            if ([string] $member['Key'] -cne 'prefix' -or [int] $member['ValueStart'] -lt 0) { continue }
            $prefix = Get-DocsScannerLiteral -Tokens $tokens -Span @{ Start = [int] $member['ValueStart']; End = [int] $member['ValueEnd'] }
            if ($null -eq $prefix) { $prefixDynamic = $true }
        }
    }
    $span = Get-DocsHttpUnwrappedSpan -State $State -Span $arguments[0]
    $start = [int] $span['Start']
    $mounted = $false
    if ($start -eq [int] $span['End'] -and (Test-DocsTypeScriptToken -Tokens $tokens -Index $start -Kind 'identifier')) {
        $mounted = Add-DocsHttpMountTarget -State $State -Receiver $Receiver -Index $start -Prefix $prefix -Line $line
    } elseif ((Test-DocsTypeScriptToken -Tokens $tokens -Index $start -Kind 'identifier' -Text @('require')) -or (Test-DocsTypeScriptToken -Tokens $tokens -Index $start -Kind 'keyword' -Text @('import'))) {
        Add-DocsScannerDiagnostic -Set $State['Set'] -Code 'HTTP_MOUNT_UNRESOLVED' -Path $State['Path'] -Line $line
    } else {
        $State['InlineCount'] = [int] $State['InlineCount'] + 1
        $inline = Add-DocsHttpFunctionReceiver -State $State -Name ('#plugin' + [string] $State['InlineCount']) -Span $span
        if ($null -ne $inline) {
            $Receiver['Mount'].Add(@{ Prefix = $prefix; Local = [string] $inline['Name']; ImportPath = $null; ImportName = $null; Line = $line })
            $mounted = $true
            Invoke-DocsHttpWalk -State $State -Start ([int] $inline['BodyStart']) -End ([int] $inline['BodyEnd'])
        }
    }
    if ($prefixDynamic -and $mounted) { Add-DocsScannerDiagnostic -Set $State['Set'] -Code 'HTTP_PREFIX_DYNAMIC' -Path $State['Path'] -Line $line }
}

function Invoke-DocsHttpWalk {
    <#
    .SYNOPSIS
        Walks the token range and applies every member chain whose receiver resolves (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [int] $Start,
        [Parameter(Mandatory = $true)] [int] $End
    )

    $tokens = $State['Tokens']
    $index = $Start
    while ($index -le $End) {
        if (-not (Test-DocsTypeScriptToken -Tokens $tokens -Index $index -Kind 'identifier') -or (Test-DocsTypeScriptToken -Tokens $tokens -Index ($index - 1) -Kind 'punct' -Text @('.', '?.')) -or -not (Test-DocsTypeScriptToken -Tokens $tokens -Index ($index + 1) -Kind 'punct' -Text @('.', '?.'))) { $index++; continue }
        $receiver = Resolve-DocsHttpReceiver -State $State -Name ([string] $tokens[$index]['Text']) -Index $index
        if ($null -eq $receiver) { $index++; continue }
        $chain = Get-DocsTypeScriptMemberChain -Tokens $tokens -StartIndex $index
        if ($null -eq $chain -or $chain['Call'].Count -eq 0) { $index++; continue }
        Invoke-DocsHttpChain -State $State -Receiver $receiver -Chain $chain -ReceiverIndex $index
        $index = [int] $chain['EndIndex'] + 1
    }
}

function Get-DocsHttpFileScan {
    <#
    .SYNOPSIS
        Scans one tokenized TypeScript file and returns @{ HasFramework; Receiver; Export } (pass 1 of typescript-http).
    .DESCRIPTION
        HasFramework is $false, with no receiver, when the file imports neither express nor
        fastify (nor fastify-plugin). Export is @{ Default = <receiver name or $null>; Named =
        <exported name to receiver name> }. Diagnostics are added to Set at Path.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Identifiers are case-sensitive; ordinal-comparer hashtables are required.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $CapturedPath,
        [Parameter(Mandatory = $true)] [hashtable] $Set
    )

    $import = [hashtable]::new([System.StringComparer]::Ordinal)
    $state = @{ Tokens = $Tokens; Path = $Path; CapturedPath = $CapturedPath; Set = $Set; Import = $import; Receiver = [System.Collections.Generic.List[object]]::new(); Export = @{ Default = $null; Named = [hashtable]::new([System.StringComparer]::Ordinal) }; ExpressName = $null; RouterName = $null; FastifyName = $null; FpName = $null; Framework = $null; InlineCount = 0 }
    $bindings = Get-DocsTypeScriptImport -Tokens $Tokens
    foreach ($binding in $bindings) {
        $import[[string] $binding['Local']] = $binding
        $module = [string] $binding['Module']
        $imported = [string] $binding['Imported']
        if ($module -ceq 'express') {
            if ($null -eq $state['Framework']) { $state['Framework'] = 'express' }
            if ($imported -ceq 'default' -or $imported -ceq '*') { $state['ExpressName'] = [string] $binding['Local'] }
            if ($imported -ceq 'Router') { $state['RouterName'] = [string] $binding['Local'] }
        } elseif ($module -ceq 'fastify') {
            $state['Framework'] = 'fastify'
            if ($imported -ceq 'default' -or $imported -ceq '*' -or $imported -ceq 'fastify') { $state['FastifyName'] = [string] $binding['Local'] }
        } elseif ($module -ceq 'fastify-plugin') {
            $state['Framework'] = 'fastify'
            if ($imported -ceq 'default' -or $imported -ceq '*') { $state['FpName'] = [string] $binding['Local'] }
        }
    }
    if ($null -eq $state['Framework']) { return @{ HasFramework = $false; Receiver = [object[]]@(); Export = $state['Export'] } }
    Register-DocsHttpDeclaration -State $state
    Invoke-DocsHttpWalk -State $state -Start 0 -End ($Tokens.Count - 1)
    return @{ HasFramework = $true; Receiver = [object[]] $state['Receiver'].ToArray(); Export = $state['Export'] }
}

Export-ModuleMember -Function Get-DocsHttpFileScan
