<#
.SYNOPSIS
    Typer command-tree recognizer for the issue #1022 python-cli scanner: typer.Typer(name=)
    roots, @app.command, @app.callback, app.add_typer, typer.run, and parameters declared
    through typer.Option or typer.Argument as a default or inside Annotated[...], a plain
    default (option) or no default (argument).

.DESCRIPTION
    Get-DocsTyperCommandSite takes the logical lines, import table and receiver table of one
    input and returns @{ Site; Diagnostics }. A site is @{ Kind (root, command, option);
    Framework; Id; ParentId; Name (literal only); DefaultName (function name lower-cased with
    '_' replaced by '-'); NameSource; Span; Line; Property; Attach; IsGroup }. A Typer root
    and an add_typer subgroup span their statement; a command and a typer.run target span the
    header from the topmost decorator (or the def line); a parameter spans from its name token
    to its last token. A boolean option declares --x only. Diagnostics are records with Code,
    Severity, Blocking and Line: CLI_TYPER_PARAMETER_UNRESOLVED, CLI_CUSTOM_CLASS,
    CLI_DYNAMIC_REGISTRATION, CLI_UNBOUND_REGISTRATION, CLI_REGISTRATION_IN_LOOP and
    PYTHON_IDENTIFIER_NON_ASCII (site level, non-blocking). Names are compared ordinally.

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

$script:DocsTyperConstructor = 'typer.Typer'
$script:DocsTyperParameterList = [string[]]@('typer.Option', 'typer.Argument')

function Find-DocsTyperParameterCall {
    <#
    .SYNOPSIS
        Returns the first typer.Option or typer.Argument call among Token, or $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Token, [Parameter(Mandatory = $true)] [hashtable] $Import)

    for ($cursor = 0; $cursor -lt $Token.Count; $cursor++) {
        if ($Token[$cursor]['Type'] -cne 'NAME' -or $Token[$cursor]['IsKeyword']) { continue }
        $call = Read-DocsPythonCall -Token $Token -Index $cursor
        if ($null -eq $call) { continue }
        $qualified = Resolve-DocsPythonQualifiedName -Name $call['Callee'] -Import $Import
        if ($null -ne $qualified -and $script:DocsTyperParameterList -ccontains $qualified) { return @{ Call = $call; IsArgument = ($qualified -ceq 'typer.Argument') } }
    }
    return $null
}

function Test-DocsTyperPlainDefault {
    <#
    .SYNOPSIS
        Returns $true when default tokens are a literal, a name, a bracketed literal or an ellipsis (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Token)

    if ($Token.Count -eq 0) { return $false }
    $first = $Token[0]
    $last = $Token[$Token.Count - 1]
    if ($Token.Count -eq 1) { return ($first['Type'] -cin @('STRING', 'NUMBER') -or ($first['Type'] -ceq 'NAME' -and -not $first['IsKeyword']) -or ($first['Type'] -ceq 'OP' -and $first['Text'] -ceq '...')) }
    if ($first['Type'] -ceq 'OP' -and $first['Text'] -ceq '-' -and $Token.Count -eq 2 -and $last['Type'] -ceq 'NUMBER') { return $true }
    $allStrings = $true
    foreach ($item in $Token) { if ($item['Type'] -cne 'STRING') { $allStrings = $false; break } }
    if ($allStrings) { return $true }
    return ($first['Type'] -ceq 'OP' -and $last['Type'] -ceq 'OP' -and $first['Text'] -cin @('[', '(', '{') -and $last['Level'] -eq $first['Level'])
}

function Get-DocsTyperParameterSite {
    <#
    .SYNOPSIS
        Builds the option sites of one def-based site, adding CLI_TYPER_PARAMETER_UNRESOLVED and PYTHON_IDENTIFIER_NON_ASCII records (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Header,
        [Parameter(Mandatory = $true)] [string] $OwnerId,
        [Parameter(Mandatory = $true)] [hashtable] $Import,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.List[object]] $Diagnostics
    )

    $sites = [System.Collections.Generic.List[object]]::new()
    foreach ($parameter in $Header['Parameter']) {
        if ($parameter['Kind'] -cne 'normal' -or $null -eq $parameter['Name']) { continue }
        if ($parameter['NonAscii']) { $Diagnostics.Add(@{ Code = 'PYTHON_IDENTIFIER_NON_ASCII'; Severity = 'warning'; Blocking = $false; Line = $parameter['StartLine'] }); continue }
        $default = @($parameter['DefaultTokens'])
        $typerCall = $null
        $hasDefault = $false
        $defaultIsTyper = $false
        if ($default.Count -gt 0) {
            $typerCall = if ($default[0]['Type'] -ceq 'NAME' -and -not $default[0]['IsKeyword']) { Find-DocsTyperParameterCall -Token @($default) -Import $Import } else { $null }
            if ($null -ne $typerCall -and $typerCall['Call']['Start'] -eq 0 -and $typerCall['Call']['CloseIndex'] -eq $default.Count - 1) {
                $defaultIsTyper = $true
                $positional = $typerCall['Call']['Positional']
                $hasDefault = $positional.Count -gt 0 -and -not ($positional[0]['Kind'] -ceq 'other' -and $positional[0]['Tokens'].Count -eq 1 -and $positional[0]['Tokens'][0]['Text'] -ceq '...')
            } elseif (Test-DocsTyperPlainDefault -Token $default) {
                $typerCall = $null
                $hasDefault = -not ($default.Count -eq 1 -and $default[0]['Text'] -ceq '...')
            } else {
                $Diagnostics.Add(@{ Code = 'CLI_TYPER_PARAMETER_UNRESOLVED'; Severity = 'warning'; Blocking = $false; Line = $parameter['StartLine'] })
                continue
            }
        }
        if (-not $defaultIsTyper) {
            $annotated = Find-DocsTyperParameterCall -Token @($parameter['AnnotationTokens']) -Import $Import
            if ($null -ne $annotated) { $typerCall = $annotated }
        }
        $isArgument = if ($null -ne $typerCall) { $typerCall['IsArgument'] } else { $default.Count -eq 0 }
        $property = @{ framework = 'typer'; positional = $isArgument; has_default = $hasDefault }
        $name = $parameter['Name']
        if (-not $isArgument) {
            $declarations = [System.Collections.Generic.List[string]]::new()
            if ($null -ne $typerCall) {
                foreach ($argument in $typerCall['Call']['Positional']) {
                    if ($argument['Kind'] -ceq 'string' -and $null -ne $argument['Value'] -and ([string] $argument['Value']).StartsWith('-', [System.StringComparison]::Ordinal)) { $declarations.Add([string] $argument['Value']) }
                }
            }
            $long = @($declarations | Where-Object { $_.StartsWith('--', [System.StringComparison]::Ordinal) })
            $short = @($declarations | Where-Object { -not $_.StartsWith('--', [System.StringComparison]::Ordinal) })
            $name = if ($long.Count -gt 0) { $long[0] } elseif ($short.Count -gt 0) { $short[0] } else { '--' + $parameter['Name'].Replace('_', '-') }
            if ($long.Count -gt 0 -and $short.Count -gt 0) { $property['short'] = $short[0] }
        }
        if ($null -ne $typerCall -and $typerCall['Call']['Keyword'].ContainsKey('help') -and $typerCall['Call']['Keyword']['help']['Kind'] -ceq 'string' -and $null -ne $typerCall['Call']['Keyword']['help']['Value']) { $property['help'] = [string] $typerCall['Call']['Keyword']['help']['Value'] }
        $sites.Add(@{ Kind = 'option'; Framework = 'typer'; Id = '#option-' + $OwnerId + '-' + $parameter['StartLine'] + '-' + $parameter['Name']; ParentId = $OwnerId; Name = $name; DefaultName = $null; NameSource = $null; Span = @($parameter['StartLine'], $parameter['EndLine']); Line = $parameter['StartLine']; Property = $property; Attach = $null; IsGroup = $false })
    }
    return , $sites.ToArray()
}

function Read-DocsTyperLiteralName {
    <#
    .SYNOPSIS
        Returns @{ Name; Dynamic } from a call: name= or, when Positional is allowed, the first positional string (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([AllowNull()] [hashtable] $Call, [bool] $Positional = $true)

    if ($null -eq $Call) { return @{ Name = $null; Dynamic = $false } }
    $argument = $null
    if ($Call['Keyword'].ContainsKey('name')) { $argument = $Call['Keyword']['name'] }
    elseif ($Positional -and $Call['Positional'].Count -gt 0) { $argument = $Call['Positional'][0] }
    if ($null -eq $argument) { return @{ Name = $null; Dynamic = $Call['HasStar'] } }
    if ($argument['Kind'] -cne 'string' -or $null -eq $argument['Value']) { return @{ Name = $null; Dynamic = $true } }
    return @{ Name = [string] $argument['Value']; Dynamic = $false }
}

function Get-DocsTyperCommandSite {
    <#
    .SYNOPSIS
        Returns @{ Site; Diagnostics } for the Typer registrations of one input.
    .DESCRIPTION
        Roots are receivers bound to typer.Typer(...) (literal name=; cls= yields
        CLI_CUSTOM_CLASS); app.add_typer(sub, name="x") makes the sub receiver a command of app
        spanning the add_typer statement; @app.command(...) on a def is a command of app (literal
        first positional or name=, else the default name); @app.callback(...) contributes its
        parameters as options of app; typer.run(func) makes func a root named by the module.
        Parameters follow the classified forms: typer.Option or typer.Argument as the default or
        inside Annotated[...], a plain default (option, has_default) or no default (argument); any
        other default yields CLI_TYPER_PARAMETER_UNRESOLVED for that parameter only. A
        non-literal name yields CLI_DYNAMIC_REGISTRATION, a decorator or add_typer on an
        untracked receiver CLI_UNBOUND_REGISTRATION, a registration in a loop
        CLI_REGISTRATION_IN_LOOP, and a non-ASCII declaration-forming identifier
        PYTHON_IDENTIFIER_NON_ASCII.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Line,
        [Parameter(Mandatory = $true)] [hashtable] $Import,
        [Parameter(Mandatory = $true)] [hashtable] $Receiver
    )

    $diagnostics = [System.Collections.Generic.List[object]]::new()
    $sites = [System.Collections.Generic.List[object]]::new()
    $roots = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $definitions = [System.Collections.Generic.Dictionary[string, int]]::new([System.StringComparer]::Ordinal)
    for ($index = 0; $index -lt $Line.Count; $index++) {
        $header = Get-DocsPythonDefinitionHeader -Line $Line -Index $index
        if ($null -ne $header -and $header['Kind'] -cne 'class' -and -not $definitions.ContainsKey($header['Name'])) { $definitions[$header['Name']] = $index }
    }
    $ordered = [System.Collections.Generic.List[object]]::new()
    foreach ($key in $Receiver['Receiver'].Keys) { $ordered.Add(@{ Name = [string] $key; Index = [int] $Receiver['Receiver'][$key]['Index'] }) }
    foreach ($entry in @($ordered | Sort-Object -Property @{ Expression = 'Index' })) {
        $name = [string] $entry['Name']
        $binding = $Receiver['Receiver'][$name]
        if ((Resolve-DocsPythonQualifiedName -Name $binding['Callee'] -Import $Import) -cne $script:DocsTyperConstructor) { continue }
        $call = $binding['Call']
        $siteLine = $binding['Line']
        if ($call['Keyword'].ContainsKey('cls')) { $diagnostics.Add(@{ Code = 'CLI_CUSTOM_CLASS'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); continue }
        if ((Get-DocsPythonEnclosingBlock -Line $Line -Index $binding['Index'])['InLoop']) { $diagnostics.Add(@{ Code = 'CLI_REGISTRATION_IN_LOOP'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); continue }
        $literal = Read-DocsTyperLiteralName -Call $call -Positional $false
        if ($literal['Dynamic']) { $diagnostics.Add(@{ Code = 'CLI_DYNAMIC_REGISTRATION'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); continue }
        $site = @{ Kind = 'root'; Framework = 'typer'; Id = $name; ParentId = $null; Name = $literal['Name']; DefaultName = $null; NameSource = $(if ($null -ne $literal['Name']) { 'literal' } else { $null }); Span = @($Line[$binding['Index']]['StartLine'], $Line[$binding['Index']]['EndLine']); Line = $siteLine; Property = @{ framework = 'typer' }; Attach = $name; IsGroup = $true }
        $sites.Add($site)
        $roots[$name] = $site
    }

    for ($index = 0; $index -lt $Line.Count; $index++) {
        $tokens = $Line[$index]['Tokens']
        $siteLine = $Line[$index]['StartLine']
        $header = Get-DocsPythonDefinitionHeader -Line $Line -Index $index
        if ($null -ne $header -and $header['Kind'] -cne 'class') {
            foreach ($decorator in $header['Decorator']) {
                $callee = $decorator['Callee']
                if ($null -eq $callee) { continue }
                $parts = $callee.Split('.')
                if ($parts.Count -ne 2 -or ($parts[1] -cne 'command' -and $parts[1] -cne 'callback')) { continue }
                $owner = $null
                if (-not $roots.TryGetValue($parts[0], [ref] $owner)) {
                    if (-not $Receiver['Receiver'].ContainsKey($parts[0]) -and -not $definitions.ContainsKey($parts[0]) -and -not $Import['Alias'].ContainsKey($parts[0])) { $diagnostics.Add(@{ Code = 'CLI_UNBOUND_REGISTRATION'; Severity = 'warning'; Blocking = $false; Line = $header['HeaderStart'] }) }
                    continue
                }
                $call = $decorator['Call']
                if ($null -ne $call -and $call['Keyword'].ContainsKey('cls')) { $diagnostics.Add(@{ Code = 'CLI_CUSTOM_CLASS'; Severity = 'warning'; Blocking = $false; Line = $header['HeaderStart'] }); continue }
                if ((Get-DocsPythonEnclosingBlock -Line $Line -Index $index)['InLoop']) { $diagnostics.Add(@{ Code = 'CLI_REGISTRATION_IN_LOOP'; Severity = 'warning'; Blocking = $false; Line = $header['HeaderStart'] }); continue }
                if ($parts[1] -ceq 'callback') {
                    $sites.AddRange((Get-DocsTyperParameterSite -Header $header -OwnerId $owner['Id'] -Import $Import -Diagnostics $diagnostics))
                    continue
                }
                $literal = Read-DocsTyperLiteralName -Call $call
                if ($literal['Dynamic']) { $diagnostics.Add(@{ Code = 'CLI_DYNAMIC_REGISTRATION'; Severity = 'warning'; Blocking = $false; Line = $header['HeaderStart'] }); continue }
                if ($null -eq $literal['Name'] -and $header['NameNonAscii']) { $diagnostics.Add(@{ Code = 'PYTHON_IDENTIFIER_NON_ASCII'; Severity = 'warning'; Blocking = $false; Line = $header['HeaderStart'] }); continue }
                $sites.Add(@{ Kind = 'command'; Framework = 'typer'; Id = $header['Name']; ParentId = $owner['Id']; Name = $literal['Name']; DefaultName = $header['Name'].ToLowerInvariant().Replace('_', '-'); NameSource = $null; Span = @($header['HeaderStart'], $header['HeaderEnd']); Line = $header['HeaderStart']; Property = @{ framework = 'typer' }; Attach = $null; IsGroup = $false })
                $sites.AddRange((Get-DocsTyperParameterSite -Header $header -OwnerId $header['Name'] -Import $Import -Diagnostics $diagnostics))
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
            $qualified = Resolve-DocsPythonQualifiedName -Name $call['Callee'] -Import $Import
            if ($qualified -ceq 'typer.run') {
                $target = $null
                if ($call['Positional'].Count -eq 0 -or $call['Positional'][0]['Kind'] -cne 'name' -or -not $definitions.TryGetValue([string] $call['Positional'][0]['Value'], [ref] $target)) { continue }
                $targetHeader = Get-DocsPythonDefinitionHeader -Line $Line -Index $target
                if ((Get-DocsPythonEnclosingBlock -Line $Line -Index $index -TokenIndex $call['Start'])['InLoop']) { $diagnostics.Add(@{ Code = 'CLI_REGISTRATION_IN_LOOP'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); continue }
                if ($targetHeader['NameNonAscii']) { $diagnostics.Add(@{ Code = 'PYTHON_IDENTIFIER_NON_ASCII'; Severity = 'warning'; Blocking = $false; Line = $targetHeader['HeaderStart'] }); continue }
                $sites.Add(@{ Kind = 'root'; Framework = 'typer'; Id = $targetHeader['Name']; ParentId = $null; Name = $null; DefaultName = $null; NameSource = $null; Span = @($targetHeader['HeaderStart'], $targetHeader['HeaderEnd']); Line = $targetHeader['HeaderStart']; Property = @{ framework = 'typer' }; Attach = $targetHeader['Name']; IsGroup = $false })
                $sites.AddRange((Get-DocsTyperParameterSite -Header $targetHeader -OwnerId $targetHeader['Name'] -Import $Import -Diagnostics $diagnostics))
                continue
            }
            if ($parts.Count -ne 2 -or $parts[1] -cne 'add_typer') { continue }
            $owner = $null
            if (-not $roots.TryGetValue($parts[0], [ref] $owner)) {
                if (-not $Receiver['Receiver'].ContainsKey($parts[0]) -and -not $definitions.ContainsKey($parts[0]) -and -not $Import['Alias'].ContainsKey($parts[0])) { $diagnostics.Add(@{ Code = 'CLI_UNBOUND_REGISTRATION'; Severity = 'warning'; Blocking = $false; Line = $siteLine }) }
                continue
            }
            if ((Get-DocsPythonEnclosingBlock -Line $Line -Index $index -TokenIndex $call['Start'])['InLoop']) { $diagnostics.Add(@{ Code = 'CLI_REGISTRATION_IN_LOOP'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); continue }
            $child = $null
            if ($call['Positional'].Count -eq 0 -or $call['Positional'][0]['Kind'] -cne 'name' -or -not $roots.TryGetValue([string] $call['Positional'][0]['Value'], [ref] $child)) { continue }
            $literal = Read-DocsTyperLiteralName -Call $call -Positional $false
            if ($literal['Dynamic']) { $diagnostics.Add(@{ Code = 'CLI_DYNAMIC_REGISTRATION'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); continue }
            $child['Kind'] = 'command'
            $child['ParentId'] = $owner['Id']
            if ($null -ne $literal['Name']) { $child['Name'] = $literal['Name'] }
            $child['NameSource'] = $null
            $child['Attach'] = $null
            $child['Span'] = @($siteLine, $Line[$index]['EndLine'])
            $child['Line'] = $siteLine
        }
    }
    return @{ Site = $sites.ToArray(); Diagnostics = $diagnostics.ToArray() }
}

Export-ModuleMember -Function Get-DocsTyperCommandSite
