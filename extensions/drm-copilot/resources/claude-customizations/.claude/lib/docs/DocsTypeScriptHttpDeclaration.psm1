<#
.SYNOPSIS
    Receiver declarations for the typescript-http scanner: the receiver record, receiver
    resolution by name and plugin body range, function-expression receivers, fp(...)
    unwrapping and the declaration pre-pass that records a file's receivers and exports.

.DESCRIPTION
    A receiver is @{ Name; Path; Kind; Framework; Route; Mount; Parameter; BodyStart; BodyEnd }
    where Kind is app (express() or Fastify()), router (express.Router() or Router()) or plugin
    (a function whose first parameter receives registrations). Register-DocsHttpDeclaration
    reads statement starts for const, let and var declarations, function declarations, export
    default, export { }, module.exports and exports.name, creating receivers and filling the
    export map @{ Default; Named } that pass 2 uses to resolve mounts across files. Every
    function is pure apart from the explicit State it is given.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Split from DocsTypeScriptHttpSupport.psm1 under the plan's 500-logical-line rule.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsTypeScriptSyntax.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsScannerCommon.psm1') -ErrorAction Stop

function New-DocsHttpReceiver {
    <#
    .SYNOPSIS
        Creates one receiver record in State['Receiver'] and returns it.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory record factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [string] $Name,
        [Parameter(Mandatory = $true)] [ValidateSet('app', 'router', 'plugin')] [string] $Kind,
        [Parameter(Mandatory = $true)] [ValidateSet('express', 'fastify')] [string] $Framework,
        [AllowNull()] [string] $Parameter,
        [int] $BodyStart = -1,
        [int] $BodyEnd = -1
    )

    $receiver = @{ Name = $Name; Path = [string] $State['Path']; Kind = $Kind; Framework = $Framework; Route = [System.Collections.Generic.List[object]]::new(); Mount = [System.Collections.Generic.List[object]]::new(); Parameter = $Parameter; BodyStart = $BodyStart; BodyEnd = $BodyEnd }
    $State['Receiver'].Add($receiver)
    return $receiver
}

function Resolve-DocsHttpReceiver {
    <#
    .SYNOPSIS
        Returns the receiver that identifier Name denotes at token Index: the innermost enclosing plugin parameter, else the file-level receiver of that name, else $null.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [string] $Name,
        [Parameter(Mandatory = $true)] [int] $Index
    )

    $best = $null
    foreach ($receiver in $State['Receiver']) {
        if ([string] $receiver['Kind'] -cne 'plugin' -or [string] $receiver['Parameter'] -cne $Name) { continue }
        if ($Index -lt [int] $receiver['BodyStart'] -or $Index -gt [int] $receiver['BodyEnd']) { continue }
        if ($null -eq $best -or [int] $receiver['BodyStart'] -gt [int] $best['BodyStart']) { $best = $receiver }
    }
    if ($null -ne $best) { return $best }
    foreach ($receiver in $State['Receiver']) {
        if ([string] $receiver['Name'] -ceq $Name -and [string] $receiver['Kind'] -cne 'plugin') { return $receiver }
    }
    foreach ($receiver in $State['Receiver']) { if ([string] $receiver['Name'] -ceq $Name) { return $receiver } }
    return $null
}

function Add-DocsHttpFunctionReceiver {
    <#
    .SYNOPSIS
        Creates a plugin receiver for the function expression filling Span, or returns $null when the span is not a function with a parameter.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [string] $Name,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Span
    )

    $function = Get-DocsTypeScriptFunctionParameter -Tokens $State['Tokens'] -Span $Span
    if ($null -eq $function -or $null -eq $function['Parameter']) { return $null }
    return New-DocsHttpReceiver -State $State -Name $Name -Kind 'plugin' -Framework $State['Framework'] -Parameter ([string] $function['Parameter']) -BodyStart ([int] $function['BodyStart']) -BodyEnd ([int] $function['BodyEnd'])
}

function Get-DocsHttpUnwrappedSpan {
    <#
    .SYNOPSIS
        Returns the first argument span of an fp(...) call filling Span (State['FpName']), else Span itself.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Span
    )

    $tokens = $State['Tokens']
    $start = [int] $Span['Start']
    $fpName = $State['FpName']
    if ($null -ne $fpName -and (Test-DocsTypeScriptToken -Tokens $tokens -Index $start -Kind 'identifier' -Text @($fpName)) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ($start + 1) -Kind 'punct' -Text @('('))) {
        [object[]] $inner = Get-DocsScannerCallArgument -Tokens $tokens -OpenIndex ($start + 1)
        if ($inner.Count -ge 1) { return @{ Start = [int] $inner[0]['Start']; End = [int] $inner[0]['End'] } }
    }
    return @{ Start = $start; End = [int] $Span['End'] }
}

function Register-DocsHttpDeclaration {
    <#
    .SYNOPSIS
        Pre-pass: records the receivers declared by statements and fills the file's export map in State['Export'].
    .DESCRIPTION
        State carries Tokens, Path, Framework, ExpressName, RouterName, FastifyName, FpName,
        Receiver and Export. Declarations recognized: const, let or var bound to express(),
        express.Router(), Router(), Fastify() or a function expression (optionally through
        fp(...)); function declarations with a first parameter; export default of an identifier,
        a function or fp(...) around either; export { a, b as c }; module.exports = x;
        exports.name = x.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] [hashtable] $State)

    $tokens = $State['Tokens']
    $export = $State['Export']
    for ($index = 0; $index -lt $tokens.Count; $index++) {
        if (-not (Test-DocsTypeScriptStatementStart -Tokens $tokens -Index $index)) { continue }
        $cursor = $index
        $isExport = $false
        $isDefault = $false
        if (Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'keyword' -Text @('export')) {
            $isExport = $true
            $cursor++
            if (Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'keyword' -Text @('default')) { $isDefault = $true; $cursor++ }
        }
        $end = Get-DocsTypeScriptStatementEnd -Tokens $tokens -Index $index
        if ($isExport -and -not $isDefault -and (Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'punct' -Text @('{'))) {
            if (-not (Test-DocsTypeScriptToken -Tokens $tokens -Index ((Get-DocsScannerMatchingClose -Tokens $tokens -OpenIndex $cursor) + 1) -Kind 'identifier' -Text @('from'))) {
                [object[]] $spans = Get-DocsScannerCallArgument -Tokens $tokens -OpenIndex $cursor
                foreach ($span in $spans) {
                    $local = [string] $tokens[[int] $span['Start']]['Text']
                    $exported = $local
                    if ((Test-DocsTypeScriptToken -Tokens $tokens -Index ([int] $span['Start'] + 1) -Kind 'identifier' -Text @('as')) -and ([int] $span['Start'] + 2) -le [int] $span['End']) { $exported = [string] $tokens[[int] $span['Start'] + 2]['Text'] }
                    $export['Named'][$exported] = $local
                }
            }
            continue
        }
        $isAsync = Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'identifier' -Text @('async')
        $functionIndex = if ($isAsync) { $cursor + 1 } else { $cursor }
        if (Test-DocsTypeScriptToken -Tokens $tokens -Index $functionIndex -Kind 'keyword' -Text @('function')) {
            $nameIndex = $functionIndex + 1
            if (Test-DocsTypeScriptToken -Tokens $tokens -Index $nameIndex -Kind 'punct' -Text @('*')) { $nameIndex++ }
            $name = if (Test-DocsTypeScriptName -Tokens $tokens -Index $nameIndex) { [string] $tokens[$nameIndex]['Text'] } else { '#default' }
            $receiver = Add-DocsHttpFunctionReceiver -State $State -Name $name -Span @{ Start = $cursor; End = $end }
            if ($null -ne $receiver) {
                if ($isDefault) { $export['Default'] = $name } elseif ($isExport) { $export['Named'][$name] = $name }
            }
            continue
        }
        if ($isDefault) {
            $span = Get-DocsHttpUnwrappedSpan -State $State -Span @{ Start = $cursor; End = $end }
            $valueStart = [int] $span['Start']
            if ((Test-DocsTypeScriptName -Tokens $tokens -Index $valueStart) -and ($valueStart -eq [int] $span['End'] -or (Test-DocsTypeScriptToken -Tokens $tokens -Index ($valueStart + 1) -Kind 'punct' -Text @(';')))) { $export['Default'] = [string] $tokens[$valueStart]['Text'] }
            elseif ($null -ne (Add-DocsHttpFunctionReceiver -State $State -Name '#default' -Span $span)) { $export['Default'] = '#default' }
            continue
        }
        if (Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'keyword' -Text @('const', 'let', 'var')) {
            if (-not (Test-DocsTypeScriptName -Tokens $tokens -Index ($cursor + 1)) -or -not (Test-DocsTypeScriptToken -Tokens $tokens -Index ($cursor + 2) -Kind 'punct' -Text @('=', ':'))) { continue }
            $name = [string] $tokens[$cursor + 1]['Text']
            $valueStart = $cursor + 3
            if (Test-DocsTypeScriptToken -Tokens $tokens -Index ($cursor + 2) -Kind 'punct' -Text @(':')) {
                for ($valueStart = $cursor + 3; $valueStart -le $end; $valueStart++) { if ((Test-DocsTypeScriptToken -Tokens $tokens -Index $valueStart -Kind 'punct' -Text @('=')) -and [int] $tokens[$valueStart]['Depth'] -eq [int] $tokens[$cursor]['Depth']) { break } }
                $valueStart++
            }
            if ($valueStart -gt $end) { continue }
            $created = $null
            $first = [string] $tokens[$valueStart]['Text']
            $isCall = Test-DocsTypeScriptToken -Tokens $tokens -Index ($valueStart + 1) -Kind 'punct' -Text @('(')
            if ($isCall -and $null -ne $State['ExpressName'] -and $first -ceq $State['ExpressName']) { $created = New-DocsHttpReceiver -State $State -Name $name -Kind 'app' -Framework 'express' }
            elseif ($isCall -and $null -ne $State['RouterName'] -and $first -ceq $State['RouterName']) { $created = New-DocsHttpReceiver -State $State -Name $name -Kind 'router' -Framework 'express' }
            elseif ($null -ne $State['ExpressName'] -and $first -ceq $State['ExpressName'] -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ($valueStart + 2) -Kind 'identifier' -Text @('Router')) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ($valueStart + 3) -Kind 'punct' -Text @('('))) { $created = New-DocsHttpReceiver -State $State -Name $name -Kind 'router' -Framework 'express' }
            elseif ($isCall -and $null -ne $State['FastifyName'] -and $first -ceq $State['FastifyName']) { $created = New-DocsHttpReceiver -State $State -Name $name -Kind 'app' -Framework 'fastify' }
            else { $created = Add-DocsHttpFunctionReceiver -State $State -Name $name -Span (Get-DocsHttpUnwrappedSpan -State $State -Span @{ Start = $valueStart; End = $end }) }
            if ($null -ne $created -and $isExport) { $export['Named'][$name] = $name }
            continue
        }
        if ((Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'identifier' -Text @('module')) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ($cursor + 2) -Kind 'identifier' -Text @('exports')) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ($cursor + 3) -Kind 'punct' -Text @('='))) {
            $span = Get-DocsHttpUnwrappedSpan -State $State -Span @{ Start = $cursor + 4; End = $end }
            if (Test-DocsTypeScriptName -Tokens $tokens -Index ([int] $span['Start'])) { $export['Default'] = [string] $tokens[[int] $span['Start']]['Text'] }
            continue
        }
        if ((Test-DocsTypeScriptToken -Tokens $tokens -Index $cursor -Kind 'identifier' -Text @('exports')) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ($cursor + 1) -Kind 'punct' -Text @('.')) -and (Test-DocsTypeScriptName -Tokens $tokens -Index ($cursor + 2)) -and (Test-DocsTypeScriptToken -Tokens $tokens -Index ($cursor + 3) -Kind 'punct' -Text @('=')) -and (Test-DocsTypeScriptName -Tokens $tokens -Index ($cursor + 4))) {
            $export['Named'][[string] $tokens[$cursor + 2]['Text']] = [string] $tokens[$cursor + 4]['Text']
        }
    }
}

Export-ModuleMember -Function `
    New-DocsHttpReceiver, `
    Resolve-DocsHttpReceiver, `
    Add-DocsHttpFunctionReceiver, `
    Get-DocsHttpUnwrappedSpan, `
    Register-DocsHttpDeclaration
