<#
.SYNOPSIS
    Click command-tree recognizer for the issue #1022 python-cli scanner: alias-aware
    @click.command and @click.group decorators, @G.command and @G.group on a tracked group,
    G.add_command, @click.option and @click.argument.

.DESCRIPTION
    Get-DocsClickCommandSite takes the logical lines, import table and receiver table of one
    input and returns @{ Site; Diagnostics }. A site is @{ Kind (root, command, option);
    Framework; Id; ParentId; Name (literal only); DefaultName (function name lower-cased, '_'
    to '-', one trailing -command, -cmd, -group or -grp removed); NameSource; Span; Line;
    Property; Attach; IsGroup }: a command spans its header from the topmost decorator to the
    ':' line and an option spans its decorator. Diagnostics are records with Code, Severity,
    Blocking and Line: CLI_CUSTOM_CLASS, CLI_DECORATOR_INDIRECT, CLI_UNBOUND_REGISTRATION,
    CLI_DYNAMIC_REGISTRATION, CLI_REGISTRATION_IN_LOOP and PYTHON_IDENTIFIER_NON_ASCII (site
    level, non-blocking; the other sites survive). Names are compared ordinally.

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

$script:DocsClickDecoratorList = [string[]]@('click.command', 'click.group')
$script:DocsClickParameterList = [string[]]@('click.option', 'click.argument')
$script:DocsClickCustomClassList = [string[]]@('click.Group', 'click.Command', 'click.CommandCollection')
$script:DocsClickSuffixList = [string[]]@('-command', '-cmd', '-group', '-grp')

function ConvertTo-DocsClickDefaultName {
    <#
    .SYNOPSIS
        Applies the Click default command name rule to a function name (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $FunctionName)

    $name = $FunctionName.ToLowerInvariant().Replace('_', '-')
    foreach ($suffix in $script:DocsClickSuffixList) {
        if ($name.EndsWith($suffix, [System.StringComparison]::Ordinal) -and $name.Length -gt $suffix.Length) { return $name.Substring(0, $name.Length - $suffix.Length) }
    }
    return $name
}

function Test-DocsClickBoundExpression {
    <#
    .SYNOPSIS
        Returns $true when a logical line binds a name to a click attribute, call or list of them (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Token, [Parameter(Mandatory = $true)] [hashtable] $Import)

    if ($Token.Count -lt 3 -or $Token[0]['Type'] -cne 'NAME' -or $Token[0]['IsKeyword'] -or $Token[1]['Type'] -cne 'OP' -or $Token[1]['Text'] -cne '=') { return $false }
    for ($cursor = 2; $cursor -lt $Token.Count; $cursor++) {
        $chain = Read-DocsPythonDottedChain -Token $Token -Index $cursor
        if ($null -eq $chain) { continue }
        $qualified = Resolve-DocsPythonQualifiedName -Name $chain['Text'] -Import $Import
        if ($null -ne $qualified -and ($qualified -ceq 'click' -or $qualified.StartsWith('click.', [System.StringComparison]::Ordinal))) { return $true }
        $cursor = $chain['End'] - 1
    }
    return $false
}

function Read-DocsClickParameter {
    <#
    .SYNOPSIS
        Builds the option or argument name and properties of a click.option or click.argument call, or $null when dynamic (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [hashtable] $Call, [Parameter(Mandatory = $true)] [bool] $IsArgument)

    if ($Call['HasStar'] -or $Call['Positional'].Count -eq 0) { return $null }
    $strings = [System.Collections.Generic.List[string]]::new()
    foreach ($argument in $Call['Positional']) {
        if ($argument['Kind'] -cne 'string' -or $null -eq $argument['Value']) { return $null }
        foreach ($piece in ([string] $argument['Value']).Split('/')) { if ($piece.Length -gt 0) { $strings.Add($piece) } }
    }
    if ($strings.Count -eq 0) { return $null }
    $property = @{ framework = 'click'; has_default = $Call['Keyword'].ContainsKey('default') }
    if ($IsArgument) {
        $name = $strings[0]
        $property['positional'] = $true
    } else {
        $long = @($strings | Where-Object { $_.StartsWith('--', [System.StringComparison]::Ordinal) })
        $short = @($strings | Where-Object { $_.StartsWith('-', [System.StringComparison]::Ordinal) -and -not $_.StartsWith('--', [System.StringComparison]::Ordinal) })
        $name = if ($long.Count -gt 0) { $long[0] } elseif ($short.Count -gt 0) { $short[0] } else { $strings[0] }
        $property['positional'] = $false
        if ($long.Count -gt 0 -and $short.Count -gt 0) { $property['short'] = $short[0] }
    }
    $keyword = $Call['Keyword']
    if ($keyword.ContainsKey('required') -and $keyword['required']['Kind'] -ceq 'name') {
        if ($keyword['required']['Value'] -ceq 'True') { $property['required'] = $true } elseif ($keyword['required']['Value'] -ceq 'False') { $property['required'] = $false }
    }
    if ($keyword.ContainsKey('help') -and $keyword['help']['Kind'] -ceq 'string' -and $null -ne $keyword['help']['Value']) { $property['help'] = [string] $keyword['help']['Value'] }
    return @{ Name = $name; Property = $property }
}

function Read-DocsClickLiteralName {
    <#
    .SYNOPSIS
        Returns @{ Name; Dynamic } from a command decorator call: name= or the first positional string (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([AllowNull()] [hashtable] $Call)

    if ($null -eq $Call) { return @{ Name = $null; Dynamic = $false } }
    $argument = $null
    if ($Call['Keyword'].ContainsKey('name')) { $argument = $Call['Keyword']['name'] }
    elseif ($Call['Positional'].Count -gt 0) { $argument = $Call['Positional'][0] }
    if ($null -eq $argument) { return @{ Name = $null; Dynamic = $Call['HasStar'] } }
    if ($argument['Kind'] -cne 'string' -or $null -eq $argument['Value']) { return @{ Name = $null; Dynamic = $true } }
    return @{ Name = [string] $argument['Value']; Dynamic = $false }
}

function Get-DocsClickCommandSite {
    <#
    .SYNOPSIS
        Returns @{ Site; Diagnostics } for the Click registrations of one input.
    .DESCRIPTION
        A def decorated with click.command or click.group (bare or called, through any alias) is
        a root; a def decorated with G.command or G.group on a tracked group def is a command of
        G; G.add_command(F) and G.add_command(F, name="x") re-parent the def F under G. The
        literal name is name= or the first positional string; the default name follows the
        Click rule. click.option and click.argument decorators yield option sites spanning the
        decorator, with option strings split at '/'. cls= on a decorator and a constructed
        click.Group, click.Command or click.CommandCollection yield CLI_CUSTOM_CLASS; a decorator
        name bound in the input to a click attribute, call or list, or a decorator applied by
        call, yields CLI_DECORATOR_INDIRECT; a decorator or add_command on an untracked receiver
        yields CLI_UNBOUND_REGISTRATION; a non-literal name or option string yields
        CLI_DYNAMIC_REGISTRATION; a registration in a loop yields CLI_REGISTRATION_IN_LOOP; a
        non-ASCII function name used as the default name yields PYTHON_IDENTIFIER_NON_ASCII.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Line,
        [Parameter(Mandatory = $true)] [hashtable] $Import,
        [Parameter(Mandatory = $true)] [hashtable] $Receiver
    )

    $diagnostics = [System.Collections.Generic.List[object]]::new()
    $indirect = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $definitions = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $headers = [System.Collections.Generic.List[object]]::new()
    $adds = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $Line.Count; $index++) {
        $tokens = $Line[$index]['Tokens']
        $header = Get-DocsPythonDefinitionHeader -Line $Line -Index $index
        if ($null -ne $header -and $header['Kind'] -cne 'class') {
            $headers.Add(@{ Index = $index; Header = $header })
            if (-not $definitions.ContainsKey($header['Name'])) { $definitions[$header['Name']] = $index }
            continue
        }
        if ($tokens[0]['Type'] -ceq 'OP' -and $tokens[0]['Text'] -ceq '@') { continue }
        if (Test-DocsClickBoundExpression -Token $tokens -Import $Import) { [void] $indirect.Add([string] $tokens[0]['Text']) }
        $cursor = 0
        while ($cursor -lt $tokens.Count) {
            if ($tokens[$cursor]['Type'] -cne 'NAME' -or $tokens[$cursor]['IsKeyword']) { $cursor++; continue }
            $call = Read-DocsPythonCall -Token $tokens -Index $cursor
            if ($null -eq $call) { $cursor++; continue }
            $qualified = Resolve-DocsPythonQualifiedName -Name $call['Callee'] -Import $Import
            $parts = $call['CalleeParts']
            $siteLine = $Line[$index]['StartLine']
            if ($null -ne $qualified -and $script:DocsClickCustomClassList -ccontains $qualified) {
                $diagnostics.Add(@{ Code = 'CLI_CUSTOM_CLASS'; Severity = 'warning'; Blocking = $false; Line = $siteLine })
            } elseif ($null -ne $qualified -and $script:DocsClickDecoratorList -ccontains $qualified -and $call['CloseIndex'] + 1 -lt $tokens.Count -and $tokens[$call['CloseIndex'] + 1]['Text'] -ceq '(') {
                $diagnostics.Add(@{ Code = 'CLI_DECORATOR_INDIRECT'; Severity = 'warning'; Blocking = $false; Line = $siteLine })
            } elseif ($parts.Count -eq 2 -and $parts[1] -ceq 'add_command') {
                $adds.Add(@{ Index = $index; Call = $call; Group = $parts[0]; Line = $siteLine })
            }
            $cursor = $call['OpenIndex'] + 1
        }
    }

    $groups = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $pending = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $headers) {
        $header = $entry['Header']
        $command = $null
        $options = [System.Collections.Generic.List[object]]::new()
        foreach ($decorator in $header['Decorator']) {
            $callee = $decorator['Callee']
            if ($null -eq $callee) { continue }
            $parts = $callee.Split('.')
            if ($indirect.Contains($parts[0])) { $command = @{ Code = 'CLI_DECORATOR_INDIRECT' }; break }
            $qualified = Resolve-DocsPythonQualifiedName -Name $callee -Import $Import
            if ($null -eq $qualified) { continue }
            if ($script:DocsClickDecoratorList -ccontains $qualified) { $command = @{ Group = $null; IsGroup = ($qualified -ceq 'click.group'); Call = $decorator['Call'] }; continue }
            if ($script:DocsClickParameterList -ccontains $qualified) { $options.Add(@{ Decorator = $decorator; IsArgument = ($qualified -ceq 'click.argument') }); continue }
            if ($parts.Count -eq 2 -and ($parts[1] -ceq 'command' -or $parts[1] -ceq 'group')) {
                $command = @{ Group = $parts[0]; IsGroup = ($parts[1] -ceq 'group'); Call = $decorator['Call'] }
            }
        }
        if ($null -eq $command) { continue }
        $pending.Add(@{ Entry = $entry; Command = $command; Option = $options.ToArray() })
        if ($command.ContainsKey('IsGroup') -and $command['IsGroup'] -and $null -eq $command['Group']) { [void] $groups.Add($header['Name']) }
    }
    $changed = $true
    while ($changed) {
        $changed = $false
        foreach ($item in $pending) {
            $command = $item['Command']
            if ($command.ContainsKey('Group') -and $null -ne $command['Group'] -and $command['IsGroup'] -and $groups.Contains($command['Group']) -and $groups.Add($item['Entry']['Header']['Name'])) { $changed = $true }
        }
    }

    $sites = [System.Collections.Generic.List[object]]::new()
    $byId = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $optionIndex = 0
    foreach ($item in $pending) {
        $entry = $item['Entry']
        $header = $entry['Header']
        $command = $item['Command']
        $siteLine = $header['HeaderStart']
        if ($command.ContainsKey('Code')) { $diagnostics.Add(@{ Code = $command['Code']; Severity = 'warning'; Blocking = $false; Line = $siteLine }); continue }
        $group = $command['Group']
        if ($null -ne $group -and -not $groups.Contains($group)) {
            if (-not $Receiver['Receiver'].ContainsKey($group) -and -not $definitions.ContainsKey($group) -and -not $Import['Alias'].ContainsKey($group)) { $diagnostics.Add(@{ Code = 'CLI_UNBOUND_REGISTRATION'; Severity = 'warning'; Blocking = $false; Line = $siteLine }) }
            continue
        }
        if ((Get-DocsPythonEnclosingBlock -Line $Line -Index $entry['Index'])['InLoop']) { $diagnostics.Add(@{ Code = 'CLI_REGISTRATION_IN_LOOP'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); continue }
        $call = $command['Call']
        if ($null -ne $call -and $call['Keyword'].ContainsKey('cls')) { $diagnostics.Add(@{ Code = 'CLI_CUSTOM_CLASS'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); continue }
        $literal = Read-DocsClickLiteralName -Call $call
        if ($literal['Dynamic']) { $diagnostics.Add(@{ Code = 'CLI_DYNAMIC_REGISTRATION'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); continue }
        if ($null -eq $literal['Name'] -and $header['NameNonAscii']) { $diagnostics.Add(@{ Code = 'PYTHON_IDENTIFIER_NON_ASCII'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); continue }
        $site = @{
            Kind        = $(if ($null -eq $group) { 'root' } else { 'command' })
            Framework   = 'click'
            Id          = $header['Name']
            ParentId    = $group
            Name        = $literal['Name']
            DefaultName = (ConvertTo-DocsClickDefaultName -FunctionName $header['Name'])
            NameSource  = $(if ($null -eq $group -and $null -ne $literal['Name']) { 'literal' } else { $null })
            Span        = @($header['HeaderStart'], $header['HeaderEnd'])
            Line        = $siteLine
            Property    = @{ framework = 'click' }
            Attach      = $(if ($null -eq $group) { $header['Name'] } else { $null })
            IsGroup     = $command['IsGroup']
        }
        $sites.Add($site)
        $byId[$site['Id']] = $site
        foreach ($option in $item['Option']) {
            $decorator = $option['Decorator']
            $parameter = if ($null -ne $decorator['Call']) { Read-DocsClickParameter -Call $decorator['Call'] -IsArgument $option['IsArgument'] } else { $null }
            if ($null -eq $parameter) { $diagnostics.Add(@{ Code = 'CLI_DYNAMIC_REGISTRATION'; Severity = 'warning'; Blocking = $false; Line = $decorator['StartLine'] }); continue }
            $optionIndex++
            $sites.Add(@{ Kind = 'option'; Framework = 'click'; Id = '#option-' + $optionIndex; ParentId = $site['Id']; Name = $parameter['Name']; DefaultName = $null; NameSource = $null; Span = @($decorator['StartLine'], $decorator['EndLine']); Line = $decorator['StartLine']; Property = $parameter['Property']; Attach = $null; IsGroup = $false })
        }
    }

    foreach ($add in $adds) {
        $call = $add['Call']
        if ((Get-DocsPythonEnclosingBlock -Line $Line -Index $add['Index'] -TokenIndex $call['Start'])['InLoop']) { $diagnostics.Add(@{ Code = 'CLI_REGISTRATION_IN_LOOP'; Severity = 'warning'; Blocking = $false; Line = $add['Line'] }); continue }
        if (-not $groups.Contains($add['Group'])) {
            if (-not $Receiver['Receiver'].ContainsKey($add['Group']) -and -not $definitions.ContainsKey($add['Group']) -and -not $Import['Alias'].ContainsKey($add['Group'])) { $diagnostics.Add(@{ Code = 'CLI_UNBOUND_REGISTRATION'; Severity = 'warning'; Blocking = $false; Line = $add['Line'] }) }
            continue
        }
        $target = $null
        if ($call['Positional'].Count -eq 0 -or $call['Positional'][0]['Kind'] -cne 'name' -or -not $byId.TryGetValue([string] $call['Positional'][0]['Value'], [ref] $target) -or $target['Kind'] -ceq 'option') { continue }
        if ($call['Keyword'].ContainsKey('name')) {
            $argument = $call['Keyword']['name']
            if ($argument['Kind'] -cne 'string' -or $null -eq $argument['Value']) { $diagnostics.Add(@{ Code = 'CLI_DYNAMIC_REGISTRATION'; Severity = 'warning'; Blocking = $false; Line = $add['Line'] }); continue }
            $target['Name'] = [string] $argument['Value']
        }
        $target['Kind'] = 'command'
        $target['ParentId'] = $add['Group']
        $target['NameSource'] = $null
        $target['Attach'] = $null
    }
    return @{ Site = $sites.ToArray(); Diagnostics = $diagnostics.ToArray() }
}

Export-ModuleMember -Function Get-DocsClickCommandSite
