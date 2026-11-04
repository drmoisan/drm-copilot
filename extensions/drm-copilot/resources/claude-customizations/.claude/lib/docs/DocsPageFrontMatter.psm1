<#
.SYNOPSIS
    The bounded front-matter parser of the documentation page checker and the validation of
    parsed front matter against the page-metadata schema.

.DESCRIPTION
    ConvertFrom-DocsPageFrontMatter reads a block that starts on line 1 with exactly --- and
    ends at the next line that is exactly --- or ... . Inside the block only a documented YAML
    subset is accepted: top-level key lines, block sequences of scalars under a key with an
    empty value, comments and blank lines. Values are resolved by ConvertFrom-DocsPageYamlScalar:
    JSON values, single-line flow sequences, single-quoted scalars and plain scalars with YAML
    1.2 core-schema resolution. Every other construct yields DOCS_PAGE_FRONT_MATTER_UNSUPPORTED
    naming the construct. No YAML module is used and ConvertFrom-Json is not used.

    Test-DocsPageFrontMatter validates parsed front matter: required fields, the schema gate
    Test-DocsArtifactText -ArtifactKind 'page-metadata', and the constraint evaluator, value
    checks and finding mapping of the refinement module DocsPageMetadata.psm1.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state; inputs are not mutated.

.NOTES
    Issue #1021. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSchema.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageMarkdown.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsPageMetadata.psm1') -ErrorAction Stop

$script:DocsPageKeyPattern = '^(?<key>[A-Za-z_][A-Za-z0-9_-]*):(?:[ ]+(?<value>.*))?$'
$script:DocsPageItemPattern = '^(?<indent>[ ]*)- (?<item>.*)$'
$script:DocsPageIntegerPattern = '^[-+]?[0-9]+$'
$script:DocsPageFloatPattern = '^[-+]?(?:\.[0-9]+|[0-9]+(?:\.[0-9]*)?)(?:[eE][-+]?[0-9]+)?$'
$script:DocsPageSpecialFloatPattern = '^[-+]?\.(?:inf|Inf|INF)$|^\.(?:nan|NaN|NAN)$'
$script:DocsPageNextAction = @{
    'DOCS_PAGE_FRONT_MATTER_UNTERMINATED'  = 'Close the front matter block with a line that is exactly --- or ... .'
    'DOCS_PAGE_FRONT_MATTER_SYNTAX'        = 'Write each front matter line as key: value, a - item under a key, a # comment or a blank line.'
    'DOCS_PAGE_FRONT_MATTER_UNSUPPORTED'   = 'Rewrite the value with a JSON value, a flow sequence, a quoted scalar or a plain scalar.'
    'DOCS_PAGE_FRONT_MATTER_DUPLICATE_KEY' = 'Keep one line for each front matter key.'
}

function New-DocsPageParseFinding {
    <#
    .SYNOPSIS
        Builds one front-matter parse finding with the fixed next action of its code (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $Message,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [AllowEmptyString()] [string] $Pointer = ''
    )

    return New-DocsFinding -Code $Code -Severity 'error' -Message $Message -NextAction $script:DocsPageNextAction[$Code] -ArtifactPath $PagePath -Pointer $Pointer
}

function New-DocsPageScalarResult {
    <#
    .SYNOPSIS
        Builds one scalar-resolution result (private helper). Construct $null with Ok $false means a syntax error.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([bool] $Ok, [AllowNull()] [object] $Value = $null, [AllowNull()] [string] $Construct = $null)

    return @{ Ok = $Ok; Value = $Value; Construct = $(if ([string]::IsNullOrEmpty($Construct)) { $null } else { $Construct }) }
}

function ConvertFrom-DocsPagePlainScalar {
    <#
    .SYNOPSIS
        Resolves a plain scalar with the YAML 1.2 core schema (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    if ($Text.Contains(': ')) { return New-DocsPageScalarResult -Ok $false -Construct 'mapping in plain scalar' }
    if ($Text -cmatch '^(?:|~|null|Null|NULL)$') { return New-DocsPageScalarResult -Ok $true -Value $null }
    if ($Text -cmatch '^(?:true|True|TRUE)$') { return New-DocsPageScalarResult -Ok $true -Value $true }
    if ($Text -cmatch '^(?:false|False|FALSE)$') { return New-DocsPageScalarResult -Ok $true -Value $false }
    if ($Text -cmatch $script:DocsPageIntegerPattern) {
        $number = [long] 0
        if ([long]::TryParse($Text, [System.Globalization.NumberStyles]::AllowLeadingSign, [cultureinfo]::InvariantCulture, [ref] $number)) { return New-DocsPageScalarResult -Ok $true -Value $number }
        return New-DocsPageScalarResult -Ok $false -Construct 'integer outside Int64'
    }
    if ($Text -cmatch $script:DocsPageSpecialFloatPattern) { return New-DocsPageScalarResult -Ok $false -Construct 'special float' }
    if ($Text -cmatch $script:DocsPageFloatPattern) { return New-DocsPageScalarResult -Ok $true -Value ([double]::Parse($Text, [cultureinfo]::InvariantCulture)) }
    return New-DocsPageScalarResult -Ok $true -Value $Text
}

function ConvertFrom-DocsPageQuotedScalar {
    <#
    .SYNOPSIS
        Resolves a single-quoted scalar; Rest receives the text after the closing quote (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [string] $Text)

    $builder = [System.Text.StringBuilder]::new()
    $index = 1
    while ($index -lt $Text.Length) {
        if ($Text[$index] -eq [char]"'") {
            if ($index + 1 -lt $Text.Length -and $Text[$index + 1] -eq [char]"'") { [void]$builder.Append("'"); $index += 2; continue }
            return @{ Ok = $true; Value = $builder.ToString(); Rest = $Text.Substring($index + 1) }
        }
        [void]$builder.Append($Text[$index])
        $index++
    }
    return @{ Ok = $false; Value = $null; Rest = '' }
}

function ConvertFrom-DocsPageFlowItem {
    <#
    .SYNOPSIS
        Resolves one flow-sequence item: single-quoted, JSON double-quoted or plain (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    if ($Text.StartsWith("'")) {
        $quoted = ConvertFrom-DocsPageQuotedScalar -Text $Text
        if (-not $quoted.Ok -or $quoted.Rest.Trim().Length -gt 0) { return New-DocsPageScalarResult -Ok $false }
        return New-DocsPageScalarResult -Ok $true -Value $quoted.Value
    }
    if ($Text.StartsWith('"')) {
        $json = ConvertFrom-DocsJsonText -Text $Text
        if (@($json.Findings).Count -gt 0 -or $json.Value -isnot [string]) { return New-DocsPageScalarResult -Ok $false -Construct 'YAML escape' }
        return New-DocsPageScalarResult -Ok $true -Value $json.Value
    }
    return ConvertFrom-DocsPagePlainScalar -Text $Text
}

function ConvertFrom-DocsPageFlowSequence {
    <#
    .SYNOPSIS
        Resolves a single-line flow sequence that is not JSON (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [string] $Text)

    $items = [System.Collections.Generic.List[string]]::new()
    $current = [System.Text.StringBuilder]::new()
    $quote = [char] 0
    # Escape state of the current double-quoted item: a backslash escapes exactly the next character.
    $escaped = $false
    $closedAt = -1
    for ($index = 1; $index -lt $Text.Length; $index++) {
        $char = $Text[$index]
        if ($quote -ne [char] 0) {
            [void]$current.Append($char)
            if ($escaped) { $escaped = $false; continue }
            if ($quote -eq [char]'"' -and $char -eq [char]'\') { $escaped = $true; continue }
            if ($char -eq $quote) { $quote = [char] 0 }
            continue
        }
        if ($char -eq [char]"'" -or $char -eq [char]'"') { $quote = $char; $escaped = $false; [void]$current.Append($char); continue }
        if ($char -eq [char]'[' -or $char -eq [char]'{') { return New-DocsPageScalarResult -Ok $false -Construct 'nested flow collection' }
        if ($char -eq [char]']') { $closedAt = $index; break }
        if ($char -eq [char]',') { $items.Add($current.ToString()); [void]$current.Clear(); continue }
        [void]$current.Append($char)
    }
    if ($closedAt -lt 0) { return New-DocsPageScalarResult -Ok $false -Construct 'unclosed flow sequence' }
    $rest = $Text.Substring($closedAt + 1)
    if ($rest.Trim().Length -gt 0 -and -not $rest.StartsWith(' #')) { return New-DocsPageScalarResult -Ok $false }
    $items.Add($current.ToString())
    $values = [System.Collections.Generic.List[object]]::new()
    for ($index = 0; $index -lt $items.Count; $index++) {
        $item = $items[$index].Trim()
        if ($item.Length -eq 0) {
            if ($index -eq $items.Count - 1) { continue }
            return New-DocsPageScalarResult -Ok $false
        }
        $resolved = ConvertFrom-DocsPageFlowItem -Text $item
        if (-not $resolved.Ok) { return $resolved }
        $values.Add($resolved.Value)
    }
    return New-DocsPageScalarResult -Ok $true -Value ([object[]] $values.ToArray())
}

function ConvertFrom-DocsPageYamlScalar {
    <#
    .SYNOPSIS
        Resolves one front-matter value text to @{ Ok; Value; Construct }.
    .DESCRIPTION
        Ok $false with a Construct means the value is outside the supported subset
        (DOCS_PAGE_FRONT_MATTER_UNSUPPORTED); Ok $false without a Construct is a syntax error
        (DOCS_PAGE_FRONT_MATTER_SYNTAX). Trailing spaces are removed first.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    $value = $Text.TrimEnd(' ')
    if ($value.Length -eq 0 -or $value.StartsWith('#')) { return New-DocsPageScalarResult -Ok $true -Value $null }
    $first = $value[0]
    if ($first -eq [char]'"' -or $first -eq [char]'[' -or $first -eq [char]'{') {
        $json = ConvertFrom-DocsJsonText -Text $value
        if (@($json.Findings).Count -eq 0) { return New-DocsPageScalarResult -Ok $true -Value $json.Value }
        if ($first -eq [char]'[') { return ConvertFrom-DocsPageFlowSequence -Text $value }
        if ($first -eq [char]'{') { return New-DocsPageScalarResult -Ok $false -Construct 'flow mapping' }
        $quoted = [regex]::Match($value, '^(?<string>"(?:[^"\\]|\\.)*")(?: #.*)?$')
        if (-not $quoted.Success) { return New-DocsPageScalarResult -Ok $false }
        $string = ConvertFrom-DocsJsonText -Text $quoted.Groups['string'].Value
        if (@($string.Findings).Count -eq 0) { return New-DocsPageScalarResult -Ok $true -Value $string.Value }
        return New-DocsPageScalarResult -Ok $false -Construct 'YAML escape'
    }
    if ($first -eq [char]"'") {
        $quoted = ConvertFrom-DocsPageQuotedScalar -Text $value
        if (-not $quoted.Ok) { return New-DocsPageScalarResult -Ok $false }
        if ($quoted.Rest.Length -gt 0 -and -not $quoted.Rest.StartsWith(' #')) { return New-DocsPageScalarResult -Ok $false }
        return New-DocsPageScalarResult -Ok $true -Value $quoted.Value
    }
    if ($first -eq [char]'|' -or $first -eq [char]'>') { return New-DocsPageScalarResult -Ok $false -Construct 'block scalar' }
    if ($first -eq [char]'&') { return New-DocsPageScalarResult -Ok $false -Construct 'anchor' }
    if ($first -eq [char]'*') { return New-DocsPageScalarResult -Ok $false -Construct 'alias' }
    if ($first -eq [char]'!') { return New-DocsPageScalarResult -Ok $false -Construct 'tag' }
    if ('%@`,]}?'.Contains([string] $first) -or $value -ceq '-' -or $value.StartsWith('- ')) { return New-DocsPageScalarResult -Ok $false -Construct 'reserved indicator' }
    $comment = $value.IndexOf(' #', [System.StringComparison]::Ordinal)
    if ($comment -ge 0) { $value = $value.Substring(0, $comment).TrimEnd(' ') }
    return ConvertFrom-DocsPagePlainScalar -Text $value
}

function Get-DocsPageLineConstruct {
    <#
    .SYNOPSIS
        Names the unsupported construct of a line outside the grammar, or $null for a syntax error (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Line)

    if ($Line -match '^[ ]*\t') { return 'tab indentation' }
    if ($Line -match '^[ ]*\?(?: |$)') { return 'complex key' }
    if ($Line -match '^["''][^"'']*["''][ ]*:') { return 'quoted key' }
    if ($Line -cmatch '^[ ]*- - ') { return 'nested sequence' }
    if ($Line -cmatch '^[ ]*- [A-Za-z_][A-Za-z0-9_-]*:(?: |$)') { return 'mapping in sequence item' }
    if ($Line -match '^[ ]+\S') { return 'indented line' }
    return $null
}

function ConvertTo-DocsPageScalarFinding {
    <#
    .SYNOPSIS
        Maps a failed scalar resolution to an UNSUPPORTED or SYNTAX finding (private helper).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Resolved,
        [Parameter(Mandatory = $true)] [int] $Number,
        [Parameter(Mandatory = $true)] [string] $PagePath
    )

    if ($null -ne $Resolved.Construct) {
        return New-DocsPageParseFinding -Code 'DOCS_PAGE_FRONT_MATTER_UNSUPPORTED' -Message "line ${Number}: front matter construct '$($Resolved.Construct)' is outside the supported subset" -PagePath $PagePath
    }
    return New-DocsPageParseFinding -Code 'DOCS_PAGE_FRONT_MATTER_SYNTAX' -Message "line ${Number}: front matter line is not a key, sequence item, comment or blank line" -PagePath $PagePath
}

function Complete-DocsPageSequence {
    <#
    .SYNOPSIS
        Stores the items of a key with an empty value: an array of the items, or $null without items (private helper).
    .DESCRIPTION
        The assignment is a plain statement so a one-item sequence stays an array; a $( ) or
        pipeline expression would unroll it to a scalar.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Value,
        [Parameter(Mandatory = $true)] [string] $Key,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.List[object]] $Item
    )

    if ($Item.Count -gt 0) {
        $Value[$Key] = [object[]] $Item.ToArray()
    } else {
        $Value[$Key] = $null
    }
}

function ConvertFrom-DocsPageFrontMatter {
    <#
    .SYNOPSIS
        Parses the front-matter block of a page and returns @{ Present; Terminated; Value; FieldLine; BodyStartLine; Findings }.
    .DESCRIPTION
        Value is an ordinal hashtable, or $null when the page has no block or any parse finding
        exists. FieldLine maps each key to its 1-based page line. BodyStartLine is the line after
        the terminator, or 1 when the page has no terminated block.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Front matter keys are case-sensitive; the @{} literal is case-insensitive, so an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [Parameter(Mandatory = $true)] [string] $PagePath
    )

    $lines = Split-DocsPageLine -Text $Text
    $fieldLine = [hashtable]::new([System.StringComparer]::Ordinal)
    if ($lines[0] -cne '---') { return @{ Present = $false; Terminated = $false; Value = $null; FieldLine = $fieldLine; BodyStartLine = 1; Findings = [object[]]@() } }
    $end = -1
    for ($index = 1; $index -lt $lines.Count; $index++) { if ($lines[$index] -ceq '---' -or $lines[$index] -ceq '...') { $end = $index; break } }
    if ($end -lt 0) {
        $finding = New-DocsPageParseFinding -Code 'DOCS_PAGE_FRONT_MATTER_UNTERMINATED' -Message 'front matter block opened on line 1 is not closed' -PagePath $PagePath
        return @{ Present = $true; Terminated = $false; Value = $null; FieldLine = $fieldLine; BodyStartLine = 1; Findings = [object[]]@($finding) }
    }

    $findings = [System.Collections.Generic.List[object]]::new()
    $value = [hashtable]::new([System.StringComparer]::Ordinal)
    $pendingKey = $null
    $pendingItems = $null
    for ($index = 1; $index -lt $end; $index++) {
        $line = $lines[$index]
        $number = $index + 1
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line -match '^[ ]*\t') {
            $findings.Add((New-DocsPageParseFinding -Code 'DOCS_PAGE_FRONT_MATTER_UNSUPPORTED' -Message "line ${number}: front matter construct 'tab indentation' is outside the supported subset" -PagePath $PagePath))
            continue
        }
        if ($line -match '^[ ]*#') { continue }
        $key = [regex]::Match($line, $script:DocsPageKeyPattern)
        if ($key.Success) {
            if ($null -ne $pendingKey) { Complete-DocsPageSequence -Value $value -Key $pendingKey -Item $pendingItems }
            $pendingKey = $null
            $name = $key.Groups['key'].Value
            if ($fieldLine.ContainsKey($name)) {
                $findings.Add((New-DocsPageParseFinding -Code 'DOCS_PAGE_FRONT_MATTER_DUPLICATE_KEY' -Message "line ${number}: front matter key '$name' repeats the key on line $($fieldLine[$name])" -PagePath $PagePath -Pointer (Get-DocsChildPointer -Pointer '' -Part $name)))
                continue
            }
            $fieldLine[$name] = $number
            $raw = $key.Groups['value'].Value.TrimEnd(' ')
            if ($raw.Length -eq 0) {
                $pendingKey = $name
                $pendingItems = [System.Collections.Generic.List[object]]::new()
                continue
            }
            $resolved = ConvertFrom-DocsPageYamlScalar -Text $raw
            if ($resolved.Ok) { $value[$name] = $resolved.Value; continue }
            $findings.Add((ConvertTo-DocsPageScalarFinding -Resolved $resolved -Number $number -PagePath $PagePath))
            continue
        }
        $item = [regex]::Match($line, $script:DocsPageItemPattern)
        if ($item.Success -and $null -ne $pendingKey) {
            $trimmed = $item.Groups['item'].Value.TrimEnd(' ')
            $resolved = if ($trimmed -cmatch '^- ') { New-DocsPageScalarResult -Ok $false -Construct 'nested sequence' }
            elseif ($trimmed -cmatch '^[A-Za-z_][A-Za-z0-9_-]*:(?: |$)') { New-DocsPageScalarResult -Ok $false -Construct 'mapping in sequence item' }
            elseif ($trimmed.StartsWith('[') -or $trimmed.StartsWith('{')) { New-DocsPageScalarResult -Ok $false -Construct 'flow collection in sequence item' }
            else { ConvertFrom-DocsPageYamlScalar -Text $trimmed }
            if ($resolved.Ok) { $pendingItems.Add($resolved.Value) } else { $findings.Add((ConvertTo-DocsPageScalarFinding -Resolved $resolved -Number $number -PagePath $PagePath)) }
            continue
        }
        $construct = Get-DocsPageLineConstruct -Line $line
        if ($null -ne $construct) {
            $findings.Add((New-DocsPageParseFinding -Code 'DOCS_PAGE_FRONT_MATTER_UNSUPPORTED' -Message "line ${number}: front matter construct '$construct' is outside the supported subset" -PagePath $PagePath))
        } else {
            $findings.Add((New-DocsPageParseFinding -Code 'DOCS_PAGE_FRONT_MATTER_SYNTAX' -Message "line ${number}: front matter line is not a key, sequence item, comment or blank line" -PagePath $PagePath))
        }
    }
    if ($null -ne $pendingKey) { Complete-DocsPageSequence -Value $value -Key $pendingKey -Item $pendingItems }
    $parsed = if ($findings.Count -gt 0) { $null } else { $value }
    return @{ Present = $true; Terminated = $true; Value = $parsed; FieldLine = $fieldLine; BodyStartLine = $end + 2; Findings = [object[]] $findings.ToArray() }
}

function Test-DocsPageFrontMatter {
    <#
    .SYNOPSIS
        Validates parsed front matter against the composed page-metadata schema and the profile.
    .DESCRIPTION
        ComposedSchemaSet is the Schemas map of Get-DocsComposedSchemaSet. Order: required
        fields; the schema gate Test-DocsArtifactText -ArtifactKind 'page-metadata'; the
        constraint evaluator; the last_reviewed calendar check; audience declaration; mapping of
        schema findings to per-field codes by the first pointer segment; and the fail-closed
        rule for DOCS_SCHEMA_INVALID. Returns ordered findings.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $FrontMatter,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $RequiredField,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $AudienceId,
        [AllowNull()] [System.Collections.IDictionary] $FieldLine
    )

    $schema = $ComposedSchemaSet['page-metadata'].Value
    $all = [System.Collections.Generic.List[object]]::new()
    foreach ($name in @($RequiredField)) {
        if (-not $FrontMatter.Contains($name)) {
            $all.Add((New-DocsPageFieldFinding -Code 'DOCS_PAGE_FIELD_MISSING' -Pointer (Get-DocsChildPointer -Pointer '' -Part $name) -Message "required front matter field '$name' is missing" -PagePath $PagePath))
        }
    }
    # Every called function returns its array with the unary comma, so direct assignments keep the arrays flat.
    $gate = Test-DocsArtifactText -ArtifactKind 'page-metadata' -JsonText (ConvertTo-DocsJsonText -Value $FrontMatter) -ComposedSchemaSet $ComposedSchemaSet -ArtifactPath $PagePath
    $constraint = Get-DocsPageConstraintFinding -Schema $schema -Instance $FrontMatter -RootSchema $schema -PagePath $PagePath
    $value = Get-DocsPageValueFinding -FrontMatter $FrontMatter -Schema $schema -PagePath $PagePath -AudienceId $AudienceId -FieldLine $FieldLine
    $mapping = ConvertTo-DocsPageFieldFinding -Finding (@($gate) + @($constraint)) -PagePath $PagePath -FieldLine $FieldLine
    $all.AddRange([object[]] $value)
    $all.AddRange([object[]] $mapping.Findings)
    if ($mapping.SchemaInvalid -and $all.Count -eq 0) {
        $all.Add((New-DocsPageFieldFinding -Code 'DOCS_PAGE_FRONT_MATTER_SCHEMA_INVALID' -Pointer '' -Message 'front matter does not validate against page-metadata' -PagePath $PagePath))
    }
    if ($all.Count -eq 0) { return , [object[]] @() }
    return , [object[]] (Get-DocsOrderedFinding -Finding $all.ToArray())
}

Export-ModuleMember -Function `
    ConvertFrom-DocsPageFrontMatter, `
    ConvertFrom-DocsPageYamlScalar, `
    Test-DocsPageFrontMatter
