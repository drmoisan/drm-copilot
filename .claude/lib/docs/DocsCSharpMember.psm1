<#
.SYNOPSIS
    Member recognition for the dotnet-public-api scanner: accessibility from modifiers,
    parameter-list spelling, one member declaration head (constructor, method, property,
    indexer, field, constant, event, operator, conversion operator) and enum members.

.DESCRIPTION
    Get-DocsCSharpMember reads one member of a type body starting at a token index: attribute
    sections, modifiers, then the header up to its body-opening '{', '=>' or terminating ';'.
    It returns @{ Member; NextIndex; Unrecognized } where Member holds one record per declared
    name (@{ Kind; Declaration; Name; Accessibility; Line; EndLine }) with the declaration part
    spelled as the 1020 public-symbol convention expects (Type(int), Find<TKey>(TKey),
    this[int], operator+(T,T), implicit operator int(T)), or Unrecognized when the header cannot
    be delimited. Explicit interface implementations yield no record. Every function is pure.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Split from DocsAnalyzerDotnetApi.psm1 under the plan's 500-logical-line rule.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsCSharpSyntax.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsScannerCommon.psm1') -ErrorAction Stop

function Get-DocsCSharpAccessibility {
    <#
    .SYNOPSIS
        Returns 'public', 'protected' or 'protected internal' for a modifier list, or $null when the member is not part of the public surface.
    .DESCRIPTION
        private, internal, private protected and an absent accessibility modifier give $null,
        except that an interface or enum member without a modifier is public (ImplicitPublic).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Modifier,
        [switch] $ImplicitPublic
    )

    if ($Modifier -ccontains 'public') { return 'public' }
    if ($Modifier -ccontains 'private') { return $null }
    if ($Modifier -ccontains 'protected') { if ($Modifier -ccontains 'internal') { return 'protected internal' } return 'protected' }
    if ($Modifier -ccontains 'internal' -or $Modifier -ccontains 'file') { return $null }
    if ($ImplicitPublic) { return 'public' }
    return $null
}

function ConvertTo-DocsCSharpParameterText {
    <#
    .SYNOPSIS
        Returns '(type,type)' for a parameter list, keeping ref, out, in and params before the type.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Parameter)

    $parts = [System.Collections.Generic.List[string]]::new()
    foreach ($entry in $Parameter) {
        $type = if ($null -ne $entry['Type']) { [string] $entry['Type'] } else { [string] $entry['Name'] }
        if ($null -ne $entry['Modifier'] -and @('ref', 'out', 'in', 'params') -ccontains [string] $entry['Modifier']) { $type = [string] $entry['Modifier'] + ' ' + $type }
        $parts.Add($type)
    }
    return '(' + ($parts -join ',') + ')'
}

function Get-DocsCSharpMemberEnd {
    <#
    .SYNOPSIS
        Returns the index of the first '{', '=>' or ';' at the depth of token Index within End, or -1 (private helper).
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $Index,
        [Parameter(Mandatory = $true)] [int] $End
    )

    $depth = [int] $Tokens[$Index]['Depth']
    for ($scan = $Index; $scan -le $End; $scan++) {
        if ([int] $Tokens[$scan]['Depth'] -eq $depth -and (Test-DocsCSharpToken -Tokens $Tokens -Index $scan -Kind 'punct' -Text @('{', '=>', ';'))) { return $scan }
    }
    return -1
}

function Get-DocsCSharpMemberSkip {
    <#
    .SYNOPSIS
        Returns the first token index after the member whose header ends at HeaderEnd ('{' block with an optional '= initializer;', '=>' expression to ';', or ';') (private helper).
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $HeaderEnd,
        [Parameter(Mandatory = $true)] [int] $End
    )

    $depth = [int] $Tokens[$HeaderEnd]['Depth']
    $cursor = $HeaderEnd
    if (Test-DocsCSharpToken -Tokens $Tokens -Index $cursor -Kind 'punct' -Text @('{')) {
        $close = Get-DocsScannerMatchingClose -Tokens $Tokens -OpenIndex $cursor
        if ($close -lt 0) { return $End + 1 }
        if (-not (Test-DocsCSharpToken -Tokens $Tokens -Index ($close + 1) -Kind 'punct' -Text @('='))) { return $close + 1 }
        $cursor = $close + 1
    }
    for ($scan = $cursor; $scan -le $End; $scan++) {
        if ([int] $Tokens[$scan]['Depth'] -eq $depth -and (Test-DocsCSharpToken -Tokens $Tokens -Index $scan -Kind 'punct' -Text @(';'))) { return $scan + 1 }
    }
    return $End + 1
}

function Get-DocsCSharpDeclaratorName {
    <#
    .SYNOPSIS
        Returns the declarator names of a field or constant header between Index and End: identifiers at the header depth that start a comma-separated entry (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $Index,
        [Parameter(Mandatory = $true)] [int] $End
    )

    $names = [System.Collections.Generic.List[string]]::new()
    $depth = [int] $Tokens[$Index]['Depth']
    $expectName = $true
    for ($scan = $Index; $scan -le $End; $scan++) {
        if ([int] $Tokens[$scan]['Depth'] -ne $depth) { continue }
        if ($expectName -and (Test-DocsCSharpToken -Tokens $Tokens -Index $scan -Kind 'identifier')) { $names.Add([string] $Tokens[$scan]['Text']); $expectName = $false; continue }
        if (Test-DocsCSharpToken -Tokens $Tokens -Index $scan -Kind 'punct' -Text @(',')) { $expectName = $true }
    }
    return , [object[]] $names.ToArray()
}

function Add-DocsCSharpMemberRecord {
    <#
    .SYNOPSIS
        Appends one member record to List (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.List[object]] $List,
        [Parameter(Mandatory = $true)] [string] $Kind,
        [Parameter(Mandatory = $true)] [string] $Declaration,
        [Parameter(Mandatory = $true)] [string] $Name,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Accessibility,
        [Parameter(Mandatory = $true)] [int] $Line,
        [Parameter(Mandatory = $true)] [int] $EndLine
    )

    $List.Add(@{ Kind = $Kind; Declaration = $Declaration; Name = $Name; Accessibility = $Accessibility; Line = $Line; EndLine = $EndLine })
}

function Get-DocsCSharpMember {
    <#
    .SYNOPSIS
        Reads one member declaration of a type body starting at Index and returns @{ Member; NextIndex; Unrecognized }.
    .DESCRIPTION
        TypeName is the simple name of the containing type (constructors); ImplicitPublic marks
        an interface body. Member holds one record per declared name with Kind (constructor,
        method, property, indexer, field, constant, event, operator), the declaration part,
        Name, Accessibility ($null when excluded), Line (first attribute or modifier line) and
        EndLine (the line of '{', '=>' or ';'). NextIndex is the first token after the member;
        Unrecognized is $true when no header end exists at the member's depth.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $Index,
        [Parameter(Mandatory = $true)] [int] $End,
        [Parameter(Mandatory = $true)] [string] $TypeName,
        [switch] $ImplicitPublic
    )

    $members = [System.Collections.Generic.List[object]]::new()
    $section = Get-DocsCSharpAttributeSection -Tokens $Tokens -Index $Index
    $modifier = Get-DocsCSharpModifier -Tokens $Tokens -Index ([int] $section['EndIndex'])
    $cursor = [int] $modifier['EndIndex']
    $line = [int] $Tokens[$Index]['Line']
    $headerEnd = Get-DocsCSharpMemberEnd -Tokens $Tokens -Index $Index -End $End
    if ($headerEnd -lt 0 -or $cursor -ge $headerEnd) { return @{ Member = [object[]]@(); NextIndex = $End + 1; Unrecognized = $true } }
    $endLine = [int] $Tokens[$headerEnd]['Line']
    $next = Get-DocsCSharpMemberSkip -Tokens $Tokens -HeaderEnd $headerEnd -End $End
    $accessibility = Get-DocsCSharpAccessibility -Modifier $modifier['Modifier'] -ImplicitPublic:$ImplicitPublic
    [string[]] $modifiers = $modifier['Modifier']
    if ((Test-DocsCSharpToken -Tokens $Tokens -Index $cursor -Kind 'identifier' -Text @($TypeName)) -and (Test-DocsCSharpToken -Tokens $Tokens -Index ($cursor + 1) -Kind 'punct' -Text @('('))) {
        $list = Get-DocsCSharpParameterList -Tokens $Tokens -OpenIndex ($cursor + 1)
        Add-DocsCSharpMemberRecord -List $members -Kind 'constructor' -Declaration ($TypeName + (ConvertTo-DocsCSharpParameterText -Parameter $list['Parameter'])) -Name $TypeName -Accessibility $accessibility -Line $line -EndLine $endLine
        return @{ Member = [object[]] $members.ToArray(); NextIndex = $next; Unrecognized = $false }
    }
    if (Test-DocsCSharpToken -Tokens $Tokens -Index $cursor -Kind 'keyword' -Text @('implicit', 'explicit')) {
        $target = Get-DocsCSharpTypeText -Tokens $Tokens -Index ($cursor + 2)
        if ($null -eq $target -or -not (Test-DocsCSharpToken -Tokens $Tokens -Index ([int] $target['EndIndex'] + 1) -Kind 'punct' -Text @('('))) { return @{ Member = [object[]]@(); NextIndex = $next; Unrecognized = $true } }
        $list = Get-DocsCSharpParameterList -Tokens $Tokens -OpenIndex ([int] $target['EndIndex'] + 1)
        $spelling = [string] $Tokens[$cursor]['Text'] + ' operator ' + [string] $target['Text']
        Add-DocsCSharpMemberRecord -List $members -Kind 'operator' -Declaration ($spelling + (ConvertTo-DocsCSharpParameterText -Parameter $list['Parameter'])) -Name $spelling -Accessibility $accessibility -Line $line -EndLine $endLine
        return @{ Member = [object[]] $members.ToArray(); NextIndex = $next; Unrecognized = $false }
    }
    if (Test-DocsCSharpToken -Tokens $Tokens -Index $cursor -Kind 'keyword' -Text @('event')) {
        $type = Get-DocsCSharpTypeText -Tokens $Tokens -Index ($cursor + 1)
        if ($null -eq $type) { return @{ Member = [object[]]@(); NextIndex = $next; Unrecognized = $true } }
        [object[]] $names = Get-DocsCSharpDeclaratorName -Tokens $Tokens -Index ([int] $type['EndIndex'] + 1) -End ($headerEnd - 1)
        foreach ($name in $names) { if (-not $name.Contains('.')) { Add-DocsCSharpMemberRecord -List $members -Kind 'event' -Declaration $name -Name $name -Accessibility $accessibility -Line $line -EndLine $endLine } }
        return @{ Member = [object[]] $members.ToArray(); NextIndex = $next; Unrecognized = ($names.Count -eq 0) }
    }
    $type = Get-DocsCSharpTypeText -Tokens $Tokens -Index $cursor
    if ($null -eq $type) { return @{ Member = [object[]]@(); NextIndex = $next; Unrecognized = $true } }
    $nameIndex = [int] $type['EndIndex'] + 1
    if (Test-DocsCSharpToken -Tokens $Tokens -Index $nameIndex -Kind 'keyword' -Text @('operator')) {
        $builder = [System.Text.StringBuilder]::new('operator')
        $scan = $nameIndex + 1
        while ($scan -lt $headerEnd -and -not (Test-DocsCSharpToken -Tokens $Tokens -Index $scan -Kind 'punct' -Text @('('))) { [void]$builder.Append([string] $Tokens[$scan]['Text']); $scan++ }
        if ($scan -ge $headerEnd) { return @{ Member = [object[]]@(); NextIndex = $next; Unrecognized = $true } }
        $list = Get-DocsCSharpParameterList -Tokens $Tokens -OpenIndex $scan
        Add-DocsCSharpMemberRecord -List $members -Kind 'operator' -Declaration ($builder.ToString() + (ConvertTo-DocsCSharpParameterText -Parameter $list['Parameter'])) -Name $builder.ToString() -Accessibility $accessibility -Line $line -EndLine $endLine
        return @{ Member = [object[]] $members.ToArray(); NextIndex = $next; Unrecognized = $false }
    }
    if ((Test-DocsCSharpToken -Tokens $Tokens -Index $nameIndex -Kind 'keyword' -Text @('this')) -and (Test-DocsCSharpToken -Tokens $Tokens -Index ($nameIndex + 1) -Kind 'punct' -Text @('['))) {
        $list = Get-DocsCSharpParameterList -Tokens $Tokens -OpenIndex ($nameIndex + 1)
        $text = ConvertTo-DocsCSharpParameterText -Parameter $list['Parameter']
        Add-DocsCSharpMemberRecord -List $members -Kind 'indexer' -Declaration ('this[' + $text.Substring(1, $text.Length - 2) + ']') -Name 'this' -Accessibility $accessibility -Line $line -EndLine $endLine
        return @{ Member = [object[]] $members.ToArray(); NextIndex = $next; Unrecognized = $false }
    }
    if (-not (Test-DocsCSharpToken -Tokens $Tokens -Index $nameIndex -Kind 'identifier') -or $nameIndex -ge $headerEnd) { return @{ Member = [object[]]@(); NextIndex = $next; Unrecognized = $true } }
    $name = [string] $Tokens[$nameIndex]['Text']
    $after = $nameIndex + 1
    $generic = ''
    if (Test-DocsCSharpToken -Tokens $Tokens -Index $after -Kind 'punct' -Text @('<')) {
        $spelled = Get-DocsCSharpTypeText -Tokens $Tokens -Index $nameIndex
        if ($null -eq $spelled) { return @{ Member = [object[]]@(); NextIndex = $next; Unrecognized = $true } }
        $generic = ([string] $spelled['Text']).Substring($name.Length)
        $after = [int] $spelled['EndIndex'] + 1
    }
    if (Test-DocsCSharpToken -Tokens $Tokens -Index $after -Kind 'punct' -Text @('.')) { return @{ Member = [object[]]@(); NextIndex = $next; Unrecognized = $false } }
    if (Test-DocsCSharpToken -Tokens $Tokens -Index $after -Kind 'punct' -Text @('(')) {
        $list = Get-DocsCSharpParameterList -Tokens $Tokens -OpenIndex $after
        Add-DocsCSharpMemberRecord -List $members -Kind 'method' -Declaration ($name + $generic + (ConvertTo-DocsCSharpParameterText -Parameter $list['Parameter'])) -Name $name -Accessibility $accessibility -Line $line -EndLine $endLine
        return @{ Member = [object[]] $members.ToArray(); NextIndex = $next; Unrecognized = $false }
    }
    if ($after -eq $headerEnd -and (Test-DocsCSharpToken -Tokens $Tokens -Index $after -Kind 'punct' -Text @('{', '=>'))) {
        Add-DocsCSharpMemberRecord -List $members -Kind 'property' -Declaration $name -Name $name -Accessibility $accessibility -Line $line -EndLine $endLine
        return @{ Member = [object[]] $members.ToArray(); NextIndex = $next; Unrecognized = $false }
    }
    $kind = if ($modifiers -ccontains 'const') { 'constant' } else { 'field' }
    [object[]] $names = Get-DocsCSharpDeclaratorName -Tokens $Tokens -Index $nameIndex -End ($headerEnd - 1)
    foreach ($entry in $names) { Add-DocsCSharpMemberRecord -List $members -Kind $kind -Declaration $entry -Name $entry -Accessibility $accessibility -Line $line -EndLine $endLine }
    return @{ Member = [object[]] $members.ToArray(); NextIndex = $next; Unrecognized = ($names.Count -eq 0) }
}

function Get-DocsCSharpEnumMember {
    <#
    .SYNOPSIS
        Returns @{ Name; Line } for every member of an enum body between Start and End.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Tokens,
        [Parameter(Mandatory = $true)] [int] $Start,
        [Parameter(Mandatory = $true)] [int] $End
    )

    $members = [System.Collections.Generic.List[object]]::new()
    if ($Start -gt $End) { return , $members.ToArray() }
    $depth = [int] $Tokens[$Start]['Depth']
    $expectName = $true
    for ($scan = $Start; $scan -le $End; $scan++) {
        if ([int] $Tokens[$scan]['Depth'] -ne $depth) { continue }
        if (Test-DocsCSharpToken -Tokens $Tokens -Index $scan -Kind 'punct' -Text @('[')) { $scan = (Get-DocsCSharpAttributeSection -Tokens $Tokens -Index $scan)['EndIndex'] - 1; continue }
        if ($expectName -and (Test-DocsCSharpToken -Tokens $Tokens -Index $scan -Kind 'identifier')) { $members.Add(@{ Name = [string] $Tokens[$scan]['Text']; Line = [int] $Tokens[$scan]['Line'] }); $expectName = $false; continue }
        if (Test-DocsCSharpToken -Tokens $Tokens -Index $scan -Kind 'punct' -Text @(',')) { $expectName = $true }
    }
    return , [object[]] $members.ToArray()
}

Export-ModuleMember -Function `
    Get-DocsCSharpAccessibility, `
    ConvertTo-DocsCSharpParameterText, `
    Get-DocsCSharpMember, `
    Get-DocsCSharpEnumMember
