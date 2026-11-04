<#
.SYNOPSIS
    dotnet-public-api scanner: public types and their public and protected members in C#
    sources, emitted as public-symbol elements with qualified declarations.

.DESCRIPTION
    Invoke-DocsAnalyzerDotnetApi selects *.cs inputs, tokenizes each with
    ConvertTo-DocsCSharpToken and classifies public class, record, record struct, struct,
    interface, enum and delegate declarations in file-scoped and block namespaces, including
    nested types whose containing chain is public. Members with public, protected or protected
    internal accessibility (DocsCSharpMember.psm1) become elements declared as
    Namespace.Type<T>.Member with source-spelled type parameters and whitespace-free parameter
    types, so overloads stay distinct; interface members and enum members are public; positional
    record parameters are properties. A partial type yields one type element at the ordinally
    first path among its parts (partial_parts) and members in the file that declares them.
    internal, private, private protected and file declarations and explicit interface
    implementations yield no element. Elements are built only through New-DocsSurfaceElement
    -AnalysisMethod scanner -SourceText; the digest is never computed here. Every function is
    pure.

.NOTES
    Issue #1033. Requires PowerShell 7.4 or later. No external module dependencies.
    Get-DocsScannerPrecisionLimit is the shipped statement of this scanner's precision limit
    (CSHARP_DECLARATION_UNRECOGNIZED, CSHARP_CONDITIONAL_COMPILATION).
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsCSharpTokens.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsCSharpSyntax.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsCSharpMember.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsScannerCommon.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

$script:DocsApiAnalyzerId = 'dotnet-public-api'

function Add-DocsApiTypeMember {
    <#
    .SYNOPSIS
        Reads the members of one public type body into the type record, skipping nested type declarations (private helper).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $State,
        [Parameter(Mandatory = $true)] [hashtable] $Type,
        [Parameter(Mandatory = $true)] [hashtable] $Declaration
    )

    $tokens = $State['Tokens']
    $kind = [string] $Declaration['Kind']
    $start = [int] $Declaration['BodyOpen'] + 1
    $end = [int] $Declaration['BodyClose'] - 1
    foreach ($parameter in @($Declaration['PositionalParameter'])) {
        if ($null -eq $parameter['Name'] -or ($kind -cne 'record' -and $kind -cne 'record-struct')) { continue }
        $Type['Member'].Add(@{ Kind = 'property'; Declaration = [string] $parameter['Name']; Name = [string] $parameter['Name']; Accessibility = 'public'; Line = [int] $Type['Line']; EndLine = [int] $Type['EndLine'] })
    }
    if ($start -gt $end) { return }
    if ($kind -ceq 'enum') {
        [object[]] $enumMembers = Get-DocsCSharpEnumMember -Tokens $tokens -Start $start -End $end
        foreach ($member in $enumMembers) { $Type['Member'].Add(@{ Kind = 'enum-member'; Declaration = [string] $member['Name']; Name = [string] $member['Name']; Accessibility = 'public'; Line = [int] $member['Line']; EndLine = [int] $member['Line'] }) }
        return
    }
    $depth = [int] $tokens[$start - 1]['Depth'] + 1
    $index = $start
    while ($index -le $end) {
        if ([int] $tokens[$index]['Depth'] -ne $depth -or (Test-DocsCSharpToken -Tokens $tokens -Index $index -Kind 'punct' -Text @(';', '}'))) { $index++; continue }
        $section = Get-DocsCSharpAttributeSection -Tokens $tokens -Index $index
        $modifier = Get-DocsCSharpModifier -Tokens $tokens -Index ([int] $section['EndIndex'])
        $nested = Get-DocsCSharpTypeDeclaration -Tokens $tokens -Index ([int] $modifier['EndIndex'])
        if ($null -ne $nested) { $index = $(if ([int] $nested['BodyClose'] -ge 0) { [int] $nested['BodyClose'] + 1 } else { [int] $nested['HeaderEnd'] + 1 }); continue }
        $member = Get-DocsCSharpMember -Tokens $tokens -Index $index -End $end -TypeName ([string] $Declaration['Name']) -ImplicitPublic:($kind -ceq 'interface')
        if ($member['Unrecognized']) { Add-DocsScannerDiagnostic -Set $State['Set'] -Code 'CSHARP_DECLARATION_UNRECOGNIZED' -Path $State['Path'] -Line ([int] $tokens[$index]['Line']) }
        foreach ($entry in $member['Member']) { if ($null -ne $entry['Accessibility']) { $Type['Member'].Add($entry) } }
        $next = [int] $member['NextIndex']
        $index = $(if ($next -gt $index) { $next } else { $index + 1 })
    }
}

function Invoke-DocsApiFileScan {
    <#
    .SYNOPSIS
        Scans one tokenized C# file for public types and their members, appending type records to State['Type'] (private helper).
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] [hashtable] $State)

    $tokens = $State['Tokens']
    [object[]] $namespaces = Get-DocsCSharpNamespaceRange -Tokens $tokens
    $enclosing = [System.Collections.Generic.List[object]]::new()
    $index = 0
    while ($index -lt $tokens.Count) {
        $isMember = Test-DocsCSharpToken -Tokens $tokens -Index ($index - 1) -Kind 'punct' -Text @('.', '?.', '::')
        $startsDeclaration = (Test-DocsCSharpToken -Tokens $tokens -Index $index -Kind 'punct' -Text @('[')) -and -not (Test-DocsCSharpName -Tokens $tokens -Index ($index - 1)) -and -not (Test-DocsCSharpToken -Tokens $tokens -Index ($index - 1) -Kind 'punct' -Text @(')', ']'))
        if (-not $startsDeclaration -and -not $isMember -and (Test-DocsCSharpName -Tokens $tokens -Index $index)) { $startsDeclaration = $true }
        if (-not $startsDeclaration) { $index++; continue }
        $section = Get-DocsCSharpAttributeSection -Tokens $tokens -Index $index
        $modifier = Get-DocsCSharpModifier -Tokens $tokens -Index ([int] $section['EndIndex'])
        $declaration = Get-DocsCSharpTypeDeclaration -Tokens $tokens -Index ([int] $modifier['EndIndex'])
        if ($null -eq $declaration) { $index++; continue }
        $headerEnd = [int] $declaration['HeaderEnd']
        $bodyOpen = [int] $declaration['BodyOpen']
        $bodyClose = [int] $declaration['BodyClose']
        $outerPublic = $true
        $outerNames = [System.Collections.Generic.List[string]]::new()
        foreach ($outer in $enclosing) {
            if ($index -lt [int] $outer['Start'] -or $index -gt [int] $outer['End']) { continue }
            if (-not $outer['Public']) { $outerPublic = $false }
            $outerNames.Add([string] $outer['Name'])
        }
        $isPublic = $outerPublic -and (([string[]] $modifier['Modifier']) -ccontains 'public')
        if ($bodyOpen -ge 0) { $enclosing.Add(@{ Name = [string] $declaration['Name'] + [string] $declaration['TypeParameter']; Start = $bodyOpen; End = $bodyClose; Public = $isPublic }) }
        if ($isPublic) {
            $namespace = Get-DocsCSharpNamespaceName -Range $namespaces -Index $index
            $prefix = @(@($namespace) + $outerNames.ToArray() | Where-Object { -not [string]::IsNullOrEmpty($_) }) -join '.'
            $qualified = $(if ($prefix.Length -gt 0) { $prefix + '.' } else { '' }) + [string] $declaration['Name'] + [string] $declaration['TypeParameter']
            $line = if ($section['Attribute'].Count -gt 0) { [int] $section['Attribute'][0]['Line'] } else { [int] $tokens[$index]['Line'] }
            $endLine = if ($bodyOpen -ge 0) { [int] $tokens[$bodyOpen]['Line'] } else { [int] $tokens[$headerEnd]['Line'] }
            $kind = switch ([string] $declaration['Kind']) { 'record-struct' { 'record' } default { [string] $declaration['Kind'] } }
            $type = @{ Qualified = $qualified; Name = [string] $declaration['Name']; Kind = $kind; Path = [string] $State['Path']; Line = $line; EndLine = $endLine; Partial = (([string[]] $modifier['Modifier']) -ccontains 'partial'); Member = [System.Collections.Generic.List[object]]::new() }
            Add-DocsApiTypeMember -State $State -Type $type -Declaration $declaration
            $State['Type'].Add($type)
        }
        $index = $(if ($bodyOpen -ge 0) { $bodyOpen + 1 } else { $headerEnd + 1 })
    }
}

function Invoke-DocsAnalyzerDotnetApi {
    <#
    .SYNOPSIS
        Scans the captured C# inputs for public types and members and returns @{ Elements; Diagnostics }.
    .DESCRIPTION
        Selection is accepted for the 1020 analyzer contract and not read. Every element is
        built by New-DocsSurfaceElement with -AnalysisMethod scanner and the captured text of
        the declaring file; diagnostics are aggregated per (code, path) and emitted through
        ConvertTo-DocsScannerDiagnostic under dotnet-public-api. A file containing #if also
        yields CSHARP_CONDITIONAL_COMPILATION at its first directive line.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Qualified names and paths are case-sensitive; ordinal-comparer hashtables are required.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Selection', Justification = 'The 1020 analyzer contract passes -Selection to every analyzer; this scanner reads no selection key.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [AllowNull()] [object] $Selection
    )

    $set = New-DocsScannerDiagnosticSet
    $types = [System.Collections.Generic.List[object]]::new()
    $text = [hashtable]::new([System.StringComparer]::Ordinal)
    $selected = Select-DocsScannerInput -CapturedInput $CapturedInput -Suffix @('.cs')
    foreach ($captured in $selected) {
        $path = [string] $captured['path']
        if ($null -eq $captured['text']) { Add-DocsScannerDiagnostic -Set $set -Code (Get-DocsScannerInputDiagnosticCode -CapturedInput $captured) -Path $path -Line 0 -Blocking $true; continue }
        $source = [string] $captured['text']
        $lexed = ConvertTo-DocsCSharpToken -Text $source
        if ($lexed['Diagnostics'].Count -gt 0) {
            foreach ($diagnostic in $lexed['Diagnostics']) { Add-DocsScannerDiagnostic -Set $set -Code ([string] $diagnostic['Code']) -Path $path -Line ([int] $diagnostic['Line']) -Blocking $true }
            continue
        }
        if ($lexed['HasConditional']) {
            $match = [regex]::Match($source, '(?m)^[ \t]*#[ \t]*if\b')
            $line = if ($match.Success) { [regex]::Matches($source.Substring(0, $match.Index), '\r\n|\r|\n').Count + 1 } else { 1 }
            Add-DocsScannerDiagnostic -Set $set -Code 'CSHARP_CONDITIONAL_COMPILATION' -Path $path -Line $line
        }
        $text[$path] = $source
        $state = @{ Tokens = $lexed['Tokens']; Path = $path; Set = $set; Type = $types }
        Invoke-DocsApiFileScan -State $state
    }
    $partialPath = [hashtable]::new([System.StringComparer]::Ordinal)
    $partialCount = [hashtable]::new([System.StringComparer]::Ordinal)
    foreach ($type in $types) {
        if (-not $type['Partial']) { continue }
        $qualified = [string] $type['Qualified']
        $partialCount[$qualified] = [int] $partialCount[$qualified] + 1
        if (-not $partialPath.ContainsKey($qualified) -or [string]::CompareOrdinal([string] $type['Path'], [string] $partialPath[$qualified]) -lt 0) { $partialPath[$qualified] = [string] $type['Path'] }
    }
    $elements = [System.Collections.Generic.List[object]]::new()
    foreach ($type in $types) {
        $qualified = [string] $type['Qualified']
        $typePath = if ($type['Partial']) { [string] $partialPath[$qualified] } else { [string] $type['Path'] }
        $parentId = $null
        try { $parentId = Get-DocsElementId -Kind 'public-symbol' -Path $typePath -Declaration $qualified } catch { Add-DocsScannerDiagnostic -Set $set -Code 'DECLARATION_INVALID' -Path ([string] $type['Path']) -Line ([int] $type['Line']); continue }
        if ($typePath -ceq [string] $type['Path']) {
            $property = [ordered]@{ symbol_kind = [string] $type['Kind']; accessibility = 'public' }
            if ($type['Partial']) { $property['partial_parts'] = [int] $partialCount[$qualified] }
            try {
                $elements.Add((New-DocsSurfaceElement -Kind 'public-symbol' -Path $typePath -Declaration $qualified -Name ([string] $type['Name']) -AnalyzerId $script:DocsApiAnalyzerId -AnalysisMethod 'scanner' -SourceText $text[$typePath] -LineRange @([int] $type['Line'], [int] $type['EndLine']) -Property $property))
            } catch { Add-DocsScannerDiagnostic -Set $set -Code 'DECLARATION_INVALID' -Path $typePath -Line ([int] $type['Line']) }
        }
        foreach ($member in $type['Member']) {
            $property = [ordered]@{ symbol_kind = [string] $member['Kind']; accessibility = [string] $member['Accessibility'] }
            try {
                $elements.Add((New-DocsSurfaceElement -Kind 'public-symbol' -Path ([string] $type['Path']) -Declaration ($qualified + '.' + [string] $member['Declaration']) -Name ([string] $member['Name']) -AnalyzerId $script:DocsApiAnalyzerId -AnalysisMethod 'scanner' -SourceText $text[[string] $type['Path']] -LineRange @([int] $member['Line'], [int] $member['EndLine']) -ParentId $parentId -Property $property))
            } catch { Add-DocsScannerDiagnostic -Set $set -Code 'DECLARATION_INVALID' -Path ([string] $type['Path']) -Line ([int] $member['Line']) }
        }
    }
    [object[]] $sorted = ConvertTo-DocsScannerElementList -Element $elements.ToArray() -Set $set
    return @{ Elements = $sorted; Diagnostics = [object[]] (ConvertTo-DocsScannerDiagnostic -Set $set -AnalyzerId $script:DocsApiAnalyzerId) }
}

Export-ModuleMember -Function Invoke-DocsAnalyzerDotnetApi
