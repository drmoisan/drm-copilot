<#
.SYNOPSIS
    argparse command-tree recognizer for the issue #1022 python-cli scanner: parser roots,
    nested add_parser subcommands, add_argument options and the group receivers that map to
    their parser.

.DESCRIPTION
    Get-DocsArgparseCommandSite takes the logical lines, import table and receiver table of one
    input and returns @{ Site; Diagnostics }. A site is @{ Kind (root, command, option);
    Framework; Id; ParentId; Name; NameSource; Span; Line; Property; Attach }: the span is the
    statement span of the ArgumentParser, add_parser or add_argument statement, Attach names the
    function that constructs a root (for console-script attachment), and Property carries names
    and shapes only (no default value). Diagnostics are records with Code, Severity, Blocking and
    Line: CLI_DYNAMIC_REGISTRATION, CLI_REGISTRATION_IN_LOOP, CLI_UNBOUND_REGISTRATION and
    CLI_PARENTS_UNRESOLVED (site level, non-blocking; the other sites survive). Names are
    compared ordinally.

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

$script:DocsArgparseConstructor = 'argparse.ArgumentParser'
$script:DocsArgparseMethodList = [string[]]@('add_argument', 'add_parser', 'add_subparsers', 'add_argument_group', 'add_mutually_exclusive_group')
$script:DocsArgparseGroupMethodList = [string[]]@('add_argument_group', 'add_mutually_exclusive_group')

function Get-DocsArgparseEnclosingFunction {
    <#
    .SYNOPSIS
        Returns the name of the nearest def enclosing logical line Index, or $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Line, [Parameter(Mandatory = $true)] [int] $Index)

    $indent = $Line[$Index]['Indent']
    for ($cursor = $Index - 1; $cursor -ge 0 -and $indent -gt 0; $cursor--) {
        if ($Line[$cursor]['Indent'] -ge $indent) { continue }
        $indent = $Line[$cursor]['Indent']
        $header = Get-DocsPythonDefinitionHeader -Line $Line -Index $cursor
        if ($null -ne $header -and $header['Kind'] -cne 'class') { return $header['Name'] }
    }
    return $null
}

function Resolve-DocsArgparseReceiver {
    <#
    .SYNOPSIS
        Classifies a tracked receiver as root, command, subparsers or group with memoization (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $Name,
        [Parameter(Mandatory = $true)] [hashtable] $Receiver,
        [Parameter(Mandatory = $true)] [hashtable] $Import,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.Dictionary[string, object]] $Memo,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.HashSet[string]] $Visiting
    )

    $known = $null
    if ($Memo.TryGetValue($Name, [ref] $known)) { return $known }
    $binding = $null
    if (-not $Receiver['Receiver'].TryGetValue($Name, [ref] $binding) -or -not $Visiting.Add($Name)) { return $null }
    $call = $binding['Call']
    $parts = $call['CalleeParts']
    $node = $null
    if ((Resolve-DocsPythonQualifiedName -Name $call['Callee'] -Import $Import) -ceq $script:DocsArgparseConstructor) {
        $node = @{ Kind = 'root'; Parser = $Name; Parent = $null }
    } elseif ($parts.Count -eq 2 -and $script:DocsArgparseMethodList -ccontains $parts[1]) {
        $parent = Resolve-DocsArgparseReceiver -Name $parts[0] -Receiver $Receiver -Import $Import -Memo $Memo -Visiting $Visiting
        if ($null -ne $parent) {
            $method = $parts[1]
            if ($method -ceq 'add_subparsers' -and $parent['Kind'] -cin @('root', 'command')) { $node = @{ Kind = 'subparsers'; Parser = $parent['Parser']; Parent = $parts[0] } }
            elseif ($method -ceq 'add_parser' -and $parent['Kind'] -ceq 'subparsers') { $node = @{ Kind = 'command'; Parser = $Name; Parent = $parent['Parser'] } }
            elseif ($script:DocsArgparseGroupMethodList -ccontains $method -and $parent['Kind'] -cin @('root', 'command')) { $node = @{ Kind = 'group'; Parser = $parent['Parser']; Parent = $parts[0] } }
        }
    }
    [void] $Visiting.Remove($Name)
    $Memo[$Name] = $node
    return $node
}

function Read-DocsArgparseOption {
    <#
    .SYNOPSIS
        Builds the option name and properties of an add_argument call, or $null when dynamic (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [hashtable] $Call)

    if ($Call['HasStar'] -or $Call['Positional'].Count -eq 0) { return $null }
    $strings = [System.Collections.Generic.List[string]]::new()
    foreach ($argument in $Call['Positional']) {
        if ($argument['Kind'] -cne 'string' -or $null -eq $argument['Value']) { return $null }
        $strings.Add([string] $argument['Value'])
    }
    $long = @($strings | Where-Object { $_.StartsWith('--', [System.StringComparison]::Ordinal) })
    $short = @($strings | Where-Object { $_.StartsWith('-', [System.StringComparison]::Ordinal) -and -not $_.StartsWith('--', [System.StringComparison]::Ordinal) })
    $name = if ($long.Count -gt 0) { $long[0] } elseif ($short.Count -gt 0) { $short[0] } else { $strings[0] }
    $property = @{ framework = 'argparse'; positional = (-not $name.StartsWith('-', [System.StringComparison]::Ordinal)); has_default = $Call['Keyword'].ContainsKey('default') }
    if ($long.Count -gt 0 -and $short.Count -gt 0) { $property['short'] = $short[0] }
    $keyword = $Call['Keyword']
    foreach ($entry in @(@{ Key = 'required'; Kind = 'name' }, @{ Key = 'action'; Kind = 'string' }, @{ Key = 'help'; Kind = 'string' })) {
        if (-not $keyword.ContainsKey($entry['Key'])) { continue }
        $argument = $keyword[$entry['Key']]
        if ($argument['Kind'] -cne $entry['Kind'] -or $null -eq $argument['Value']) { continue }
        if ($entry['Key'] -ceq 'required') {
            if ($argument['Value'] -ceq 'True') { $property['required'] = $true } elseif ($argument['Value'] -ceq 'False') { $property['required'] = $false }
        } else { $property[$entry['Key']] = [string] $argument['Value'] }
    }
    return @{ Name = $name; Property = $property }
}

function Get-DocsArgparseCommandSite {
    <#
    .SYNOPSIS
        Returns @{ Site; Diagnostics } for the argparse registrations of one input.
    .DESCRIPTION
        Roots are receivers bound to ArgumentParser(...) (literal prog= names the root; parents=
        yields CLI_PARENTS_UNRESOLVED while the parser is classified). Subcommands are
        add_parser("name") calls on a tracked add_subparsers receiver, nested to any depth, with a
        literal help= property. Options are add_argument calls on a tracked parser or on a group
        receiver mapped to its parser; the first "--" string, else the first "-" string, else the
        positional name is the option, a "-x" string beside a "--x" one is short, and literal
        required=, action= and help= are properties; default values yield has_default only.
        aliases= is not read. A registration in a for or while body or a comprehension yields
        CLI_REGISTRATION_IN_LOOP; a non-literal name yields CLI_DYNAMIC_REGISTRATION; a
        registration on an untracked receiver (parameter, attribute, call result) yields
        CLI_UNBOUND_REGISTRATION. Each diagnostic removes only its own site.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Line,
        [Parameter(Mandatory = $true)] [hashtable] $Import,
        [Parameter(Mandatory = $true)] [hashtable] $Receiver
    )

    $sites = [System.Collections.Generic.List[object]]::new()
    $diagnostics = [System.Collections.Generic.List[object]]::new()
    $memo = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    $visiting = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $optionIndex = 0
    for ($index = 0; $index -lt $Line.Count; $index++) {
        $tokens = $Line[$index]['Tokens']
        $boundName = if ($tokens.Count -gt 2 -and $tokens[0]['Type'] -ceq 'NAME' -and -not $tokens[0]['IsKeyword']) { [string] $tokens[0]['Text'] } else { $null }
        $receiverBinding = $null
        $isBinding = $null -ne $boundName -and $Receiver['Receiver'].TryGetValue($boundName, [ref] $receiverBinding) -and $receiverBinding['Index'] -eq $index
        $cursor = 0
        while ($cursor -lt $tokens.Count) {
            if ($tokens[$cursor]['Type'] -cne 'NAME' -or $tokens[$cursor]['IsKeyword']) { $cursor++; continue }
            $call = Read-DocsPythonCall -Token $tokens -Index $cursor
            if ($null -eq $call) { $cursor++; continue }
            $parts = $call['CalleeParts']
            $isConstructor = (Resolve-DocsPythonQualifiedName -Name $call['Callee'] -Import $Import) -ceq $script:DocsArgparseConstructor
            $method = if ($parts.Count -ge 2 -and $script:DocsArgparseMethodList -ccontains $parts[$parts.Count - 1]) { $parts[$parts.Count - 1] } else { $null }
            $siteLine = $Line[$index]['StartLine']
            if ($parts.Count -eq 1 -and $script:DocsArgparseMethodList -ccontains $parts[0] -and $cursor -gt 0 -and $tokens[$cursor - 1]['Text'] -ceq '.') {
                $diagnostics.Add(@{ Code = 'CLI_UNBOUND_REGISTRATION'; Severity = 'warning'; Blocking = $false; Line = $siteLine })
                $cursor = $call['CloseIndex'] + 1
                continue
            }
            if (-not $isConstructor -and $null -eq $method) { $cursor = $call['OpenIndex'] + 1; continue }
            $span = @($siteLine, $Line[$index]['EndLine'])
            $cursorAfter = $call['CloseIndex'] + 1
            $node = $null
            if ($isConstructor) {
                if (-not $isBinding -or $receiverBinding['Call']['Start'] -ne $call['Start']) { $cursor = $cursorAfter; continue }
            } else {
                if ($parts.Count -ne 2) { $diagnostics.Add(@{ Code = 'CLI_UNBOUND_REGISTRATION'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); $cursor = $cursorAfter; continue }
                $node = Resolve-DocsArgparseReceiver -Name $parts[0] -Receiver $Receiver -Import $Import -Memo $memo -Visiting $visiting
                if ($null -eq $node) {
                    $other = $null
                    $trackedOther = $Receiver['Receiver'].TryGetValue($parts[0], [ref] $other) -and $script:DocsArgparseMethodList -cnotcontains $other['Call']['CalleeParts'][$other['Call']['CalleeParts'].Count - 1] -and (Resolve-DocsPythonQualifiedName -Name $other['Callee'] -Import $Import) -cne $script:DocsArgparseConstructor
                    if (-not $trackedOther) { $diagnostics.Add(@{ Code = 'CLI_UNBOUND_REGISTRATION'; Severity = 'warning'; Blocking = $false; Line = $siteLine }) }
                    $cursor = $cursorAfter; continue
                }
                if ($method -ceq 'add_subparsers' -or $script:DocsArgparseGroupMethodList -ccontains $method) { $cursor = $cursorAfter; continue }
            }
            $block = Get-DocsPythonEnclosingBlock -Line $Line -Index $index -TokenIndex $call['Start']
            if ($block['InLoop'] -or $block['InComprehension']) { $diagnostics.Add(@{ Code = 'CLI_REGISTRATION_IN_LOOP'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); $cursor = $cursorAfter; continue }
            $keyword = $call['Keyword']
            if ($isConstructor -or $method -ceq 'add_parser') {
                $name = $null
                $nameSource = $null
                if ($isConstructor) {
                    if ($keyword.ContainsKey('prog')) {
                        if ($keyword['prog']['Kind'] -cne 'string' -or $null -eq $keyword['prog']['Value']) { $diagnostics.Add(@{ Code = 'CLI_DYNAMIC_REGISTRATION'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); $cursor = $cursorAfter; continue }
                        $name = [string] $keyword['prog']['Value']
                        $nameSource = 'literal'
                    }
                } else {
                    if ($call['HasStar'] -or $call['Positional'].Count -eq 0 -or $call['Positional'][0]['Kind'] -cne 'string' -or $null -eq $call['Positional'][0]['Value']) { $diagnostics.Add(@{ Code = 'CLI_DYNAMIC_REGISTRATION'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); $cursor = $cursorAfter; continue }
                    $name = [string] $call['Positional'][0]['Value']
                }
                if ($keyword.ContainsKey('parents')) { $diagnostics.Add(@{ Code = 'CLI_PARENTS_UNRESOLVED'; Severity = 'warning'; Blocking = $false; Line = $siteLine }) }
                $property = @{ framework = 'argparse' }
                if ($keyword.ContainsKey('help') -and $keyword['help']['Kind'] -ceq 'string' -and $null -ne $keyword['help']['Value']) { $property['help'] = [string] $keyword['help']['Value'] }
                $id = if ($isBinding) { $boundName } else { '#argparse-' + $siteLine + '-' + $call['Start'] }
                $attach = $null
                if ($isConstructor) {
                    $attach = Get-DocsArgparseEnclosingFunction -Line $Line -Index $index
                    if ($null -eq $attach) { $attach = $id }
                }
                $sites.Add(@{
                        Kind       = $(if ($isConstructor) { 'root' } else { 'command' })
                        Framework  = 'argparse'
                        Id         = $id
                        ParentId   = $(if ($isConstructor) { $null } else { $node['Parser'] })
                        Name       = $name
                        NameSource = $nameSource
                        Span       = $span
                        Line       = $siteLine
                        Property   = $property
                        Attach     = $attach
                    })
            } else {
                $option = Read-DocsArgparseOption -Call $call
                if ($null -eq $option) { $diagnostics.Add(@{ Code = 'CLI_DYNAMIC_REGISTRATION'; Severity = 'warning'; Blocking = $false; Line = $siteLine }); $cursor = $cursorAfter; continue }
                $optionIndex++
                $sites.Add(@{ Kind = 'option'; Framework = 'argparse'; Id = '#option-' + $optionIndex; ParentId = $node['Parser']; Name = $option['Name']; NameSource = $null; Span = $span; Line = $siteLine; Property = $option['Property']; Attach = $null })
            }
            $cursor = $cursorAfter
        }
    }
    return @{ Site = $sites.ToArray(); Diagnostics = $diagnostics.ToArray() }
}

Export-ModuleMember -Function Get-DocsArgparseCommandSite
