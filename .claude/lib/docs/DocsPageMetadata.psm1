<#
.SYNOPSIS
    Page-metadata constraint evaluation and finding mapping for the documentation page checker.

.DESCRIPTION
    Refinement split of DocsPageFrontMatter.psm1 (issue #1021 specification, import graph). The
    structural walk of DocsSchema.psm1 does not evaluate pattern, minLength or uniqueItems, and
    Test-Json cannot name a failure behind an inline $ref, so Get-DocsPageConstraintFinding
    evaluates those three keywords over the composed schema value; no pattern constant is
    duplicated here. Get-DocsPageValueFinding adds the last_reviewed calendar check and the
    audience declaration check. ConvertTo-DocsPageFieldFinding maps schema findings to the
    per-field page codes by the first pointer segment. Test-DocsPageFrontMatter in
    DocsPageFrontMatter.psm1 orchestrates these functions.

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

$script:DocsPageFieldCode = @{
    'owner'         = 'DOCS_PAGE_OWNER_INVALID'
    'last_reviewed' = 'DOCS_PAGE_LAST_REVIEWED_INVALID'
    'audience'      = 'DOCS_PAGE_AUDIENCE_INVALID'
    'diataxis_mode' = 'DOCS_PAGE_MODE_INVALID'
    'surface_refs'  = 'DOCS_PAGE_SURFACE_REFS_INVALID'
    'title'         = 'DOCS_PAGE_TITLE_INVALID'
    'extensions'    = 'DOCS_PAGE_EXTENSIONS_INVALID'
}
$script:DocsPageFieldNextAction = @{
    'DOCS_PAGE_FIELD_MISSING'               = 'Add the field to the page front matter; the docs profile lists it in diataxis_policy.required_front_matter.'
    'DOCS_PAGE_FIELD_UNKNOWN'               = 'Remove the field, or move consumer-defined data under extensions with a namespaced key.'
    'DOCS_PAGE_OWNER_INVALID'               = 'Set owner to an identifier such as team-docs.'
    'DOCS_PAGE_LAST_REVIEWED_INVALID'       = 'Set last_reviewed to a YYYY-MM-DD date string.'
    'DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE'    = 'Set last_reviewed to a calendar date that exists.'
    'DOCS_PAGE_AUDIENCE_INVALID'            = 'Set audience to a non-empty list of distinct audience identifiers matching ^[a-z0-9][a-z0-9-]*$.'
    'DOCS_PAGE_AUDIENCE_UNDECLARED'         = 'Declare the audience in the docs profile audiences, or use a declared audience identifier.'
    'DOCS_PAGE_MODE_INVALID'                = 'Set diataxis_mode to tutorial, how-to, reference or explanation.'
    'DOCS_PAGE_SURFACE_REFS_INVALID'        = 'Set surface_refs to a list of distinct element identifiers.'
    'DOCS_PAGE_TITLE_INVALID'               = 'Set title to non-blank text.'
    'DOCS_PAGE_EXTENSIONS_INVALID'          = 'Use an object whose keys are namespaced identifiers such as vendor.note.'
    'DOCS_PAGE_FRONT_MATTER_SCHEMA_INVALID' = 'Correct the front matter so it conforms to the page-metadata schema.'
}

function Get-DocsPagePointerField {
    <#
    .SYNOPSIS
        Returns the unescaped first segment of a JSON pointer, or $null for the root (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Pointer)

    if ($Pointer.Length -lt 2) { return $null }
    $segment = $Pointer.Substring(1).Split('/')[0]
    return $segment.Replace('~1', '/').Replace('~0', '~')
}

function New-DocsPageFieldFinding {
    <#
    .SYNOPSIS
        Builds one page-metadata field finding with the fixed next action of its code.
    .DESCRIPTION
        When FieldLine holds the field named by the first pointer segment, the message is
        prefixed with "line <n>: ".
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Pointer,
        [Parameter(Mandatory = $true)] [string] $Message,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [AllowNull()] [System.Collections.IDictionary] $FieldLine
    )

    $field = Get-DocsPagePointerField -Pointer $Pointer
    $prefix = if ($null -ne $FieldLine -and $null -ne $field -and $FieldLine.Contains($field)) { "line $($FieldLine[$field]): " } else { '' }
    return New-DocsFinding -Code $Code -Severity 'error' -Message ($prefix + $Message) -NextAction $script:DocsPageFieldNextAction[$Code] -ArtifactPath $PagePath -Pointer $Pointer
}

function Resolve-DocsPageSchemaNode {
    <#
    .SYNOPSIS
        Follows local #/$defs references of a composed schema node (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [AllowNull()] [object] $Schema,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $RootSchema
    )

    $node = $Schema
    for ($depth = 0; $depth -lt 64 -and $node -is [System.Collections.IDictionary] -and $node.Contains('$ref'); $depth++) {
        $ref = [string] $node['$ref']
        if (-not $ref.StartsWith('#/$defs/', [System.StringComparison]::Ordinal)) { return $node }
        $name = $ref.Substring(8).Replace('~1', '/').Replace('~0', '~')
        if (-not $RootSchema.Contains('$defs') -or -not $RootSchema['$defs'].Contains($name)) { return $node }
        $node = $RootSchema['$defs'][$name]
    }
    return $node
}

function Get-DocsPageConstraintFinding {
    <#
    .SYNOPSIS
        Evaluates pattern, minLength and uniqueItems over an instance and a composed schema.
    .DESCRIPTION
        Every constraint is read from the schema value: local $ref, properties,
        patternProperties, items and allOf are followed. A string failing pattern yields
        DOCS_SCHEMA_PATTERN_MISMATCH, a string shorter than minLength (UTF-16 length) yields
        DOCS_SCHEMA_TOO_SHORT, and an array with two equal items (ordinal comparison of their JSON
        text) yields DOCS_SCHEMA_ITEMS_NOT_UNIQUE; each finding carries the instance pointer.
        ConvertTo-DocsPageFieldFinding maps these codes to the per-field page codes. Values of
        the wrong JSON type are left to the structural walk.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Schema,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyCollection()] [AllowEmptyString()] [object] $Instance,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $RootSchema,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [AllowEmptyString()] [string] $Pointer = ''
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $node = Resolve-DocsPageSchemaNode -Schema $Schema -RootSchema $RootSchema
    if ($node -isnot [System.Collections.IDictionary]) { return , $findings.ToArray() }
    $field = Get-DocsPagePointerField -Pointer $Pointer
    $label = if ($null -eq $field) { 'front matter' } else { "front matter field '$field'" }
    $recurse = @{ RootSchema = $RootSchema; PagePath = $PagePath }
    if ($node.Contains('allOf')) {
        foreach ($member in @($node['allOf'])) { $findings.AddRange([object[]] (Get-DocsPageConstraintFinding @recurse -Schema $member -Instance $Instance -Pointer $Pointer)) }
    }
    if ($Instance -is [string]) {
        if ($node.Contains('minLength') -and $Instance.Length -lt [int] $node['minLength']) {
            $findings.Add((New-DocsFinding -Code 'DOCS_SCHEMA_TOO_SHORT' -Severity 'error' -Message "$label value at '$Pointer' is shorter than $($node['minLength']) characters" -NextAction 'Use a longer value.' -ArtifactPath $PagePath -Pointer $Pointer))
        }
        if ($node.Contains('pattern') -and -not [regex]::IsMatch($Instance, [string] $node['pattern'])) {
            $findings.Add((New-DocsFinding -Code 'DOCS_SCHEMA_PATTERN_MISMATCH' -Severity 'error' -Message "$label value '$Instance' at '$Pointer' does not match the pattern $($node['pattern'])" -NextAction 'Use a value that matches the pattern.' -ArtifactPath $PagePath -Pointer $Pointer))
        }
    } elseif ($Instance -is [System.Collections.IDictionary]) {
        $properties = if ($node.Contains('properties')) { $node['properties'] } else { @{} }
        $patterns = if ($node.Contains('patternProperties')) { $node['patternProperties'] } else { @{} }
        foreach ($member in @($Instance.Keys | Sort-Object -CaseSensitive)) {
            $memberPointer = Get-DocsChildPointer -Pointer $Pointer -Part $member
            if ($properties.Contains($member)) { $findings.AddRange([object[]] (Get-DocsPageConstraintFinding @recurse -Schema $properties[$member] -Instance $Instance[$member] -Pointer $memberPointer)) }
            foreach ($pattern in @($patterns.Keys)) {
                if ([regex]::IsMatch([string] $member, [string] $pattern)) { $findings.AddRange([object[]] (Get-DocsPageConstraintFinding @recurse -Schema $patterns[$pattern] -Instance $Instance[$member] -Pointer $memberPointer)) }
            }
        }
    } elseif ($Instance -is [System.Collections.IList]) {
        $items = @($Instance)
        if ($node.Contains('uniqueItems') -and [bool] $node['uniqueItems']) {
            $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
            for ($index = 0; $index -lt $items.Count; $index++) {
                if (-not $seen.Add((ConvertTo-DocsJsonText -Value $items[$index]))) {
                    $findings.Add((New-DocsFinding -Code 'DOCS_SCHEMA_ITEMS_NOT_UNIQUE' -Severity 'error' -Message "$label item $index repeats an earlier item" -NextAction 'Remove the repeated item.' -ArtifactPath $PagePath -Pointer (Get-DocsChildPointer -Pointer $Pointer -Part $index)))
                }
            }
        }
        if ($node.Contains('items')) {
            for ($index = 0; $index -lt $items.Count; $index++) { $findings.AddRange([object[]] (Get-DocsPageConstraintFinding @recurse -Schema $node['items'] -Instance $items[$index] -Pointer (Get-DocsChildPointer -Pointer $Pointer -Part $index))) }
        }
    }
    return , $findings.ToArray()
}

function Test-DocsPageReviewDate {
    <#
    .SYNOPSIS
        Returns $true when Value is an existing calendar date in the yyyy-MM-dd form.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Value)

    $parsed = [datetime]::MinValue
    return [datetime]::TryParseExact($Value, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref] $parsed)
}

function Get-DocsPageFieldPattern {
    <#
    .SYNOPSIS
        Returns the pattern of a property (or of its items) read from the composed schema, or $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $RootSchema,
        [Parameter(Mandatory = $true)] [string] $Field,
        [switch] $Items
    )

    $properties = if ($RootSchema.Contains('properties')) { $RootSchema['properties'] } else { @{} }
    $node = Resolve-DocsPageSchemaNode -Schema $(if ($properties.Contains($Field)) { $properties[$Field] } else { $null }) -RootSchema $RootSchema
    if ($Items -and $node -is [System.Collections.IDictionary]) { $node = Resolve-DocsPageSchemaNode -Schema $node['items'] -RootSchema $RootSchema }
    if ($node -is [System.Collections.IDictionary] -and $node.Contains('pattern')) { return [string] $node['pattern'] }
    return $null
}

function Get-DocsPageValueFinding {
    <#
    .SYNOPSIS
        Returns the last_reviewed calendar finding and the audience declaration findings.
    .DESCRIPTION
        Validation steps 4 and 5: a last_reviewed string that matches the review-date pattern of
        the composed schema but is not a calendar date yields DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE;
        each audience item that matches the audience-id pattern and is not in AudienceId yields
        DOCS_PAGE_AUDIENCE_UNDECLARED at /audience/<i>. Both patterns are read from Schema.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $FrontMatter,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Schema,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $AudienceId,
        [AllowNull()] [System.Collections.IDictionary] $FieldLine
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $reviewPattern = Get-DocsPageFieldPattern -RootSchema $Schema -Field 'last_reviewed'
    if ($FrontMatter.Contains('last_reviewed') -and $FrontMatter['last_reviewed'] -is [string] -and $null -ne $reviewPattern) {
        $reviewed = [string] $FrontMatter['last_reviewed']
        if ([regex]::IsMatch($reviewed, $reviewPattern) -and -not (Test-DocsPageReviewDate -Value $reviewed)) {
            $findings.Add((New-DocsPageFieldFinding -Code 'DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE' -Pointer '/last_reviewed' -Message "front matter field 'last_reviewed' value '$reviewed' is not a calendar date" -PagePath $PagePath -FieldLine $FieldLine))
        }
    }
    $audiencePattern = Get-DocsPageFieldPattern -RootSchema $Schema -Field 'audience' -Items
    if ($FrontMatter.Contains('audience') -and $FrontMatter['audience'] -is [System.Collections.IList] -and $null -ne $audiencePattern) {
        $declared = [System.Collections.Generic.HashSet[string]]::new([string[]] @($AudienceId), [System.StringComparer]::Ordinal)
        $items = @($FrontMatter['audience'])
        for ($index = 0; $index -lt $items.Count; $index++) {
            $item = $items[$index]
            if ($item -is [string] -and [regex]::IsMatch($item, $audiencePattern) -and -not $declared.Contains($item)) {
                $findings.Add((New-DocsPageFieldFinding -Code 'DOCS_PAGE_AUDIENCE_UNDECLARED' -Pointer "/audience/$index" -Message "audience '$item' is not declared in the docs profile" -PagePath $PagePath -FieldLine $FieldLine))
            }
        }
    }
    return , $findings.ToArray()
}

function ConvertTo-DocsPageFieldFinding {
    <#
    .SYNOPSIS
        Maps schema-gate and evaluator findings to the per-field page codes and returns @{ Findings; SchemaInvalid }.
    .DESCRIPTION
        Validation step 6: an unknown top-level property (DOCS_SCHEMA_PROPERTY_UNKNOWN at /<key>)
        becomes DOCS_PAGE_FIELD_UNKNOWN; any other finding whose first pointer segment is a
        page-metadata field becomes that field's code, keeping the pointer and a message that
        names the field. DOCS_SCHEMA_INVALID, and any finding that names no field, set
        SchemaInvalid for the fail-closed rule of step 7.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [AllowNull()] [object[]] $Finding,
        [Parameter(Mandatory = $true)] [string] $PagePath,
        [AllowNull()] [System.Collections.IDictionary] $FieldLine
    )

    $mapped = [System.Collections.Generic.List[object]]::new()
    $schemaInvalid = $false
    foreach ($item in @($Finding)) {
        if ($null -eq $item) { continue }
        $code = [string] $item.code
        $pointer = [string] $item.pointer
        $field = Get-DocsPagePointerField -Pointer $pointer
        if ($code -ceq 'DOCS_SCHEMA_INVALID') { $schemaInvalid = $true; continue }
        if ($code -ceq 'DOCS_SCHEMA_PROPERTY_UNKNOWN' -and $null -ne $field -and $pointer -ceq (Get-DocsChildPointer -Pointer '' -Part $field)) {
            $mapped.Add((New-DocsPageFieldFinding -Code 'DOCS_PAGE_FIELD_UNKNOWN' -Pointer $pointer -Message "front matter field '$field' is not defined by page-metadata" -PagePath $PagePath -FieldLine $FieldLine))
            continue
        }
        if ($null -ne $field -and $script:DocsPageFieldCode.ContainsKey($field)) {
            $label = "front matter field '$field'"
            $message = if (([string] $item.message).StartsWith($label, [System.StringComparison]::Ordinal)) { [string] $item.message } else { "$label is invalid: $($item.message)" }
            $mapped.Add((New-DocsPageFieldFinding -Code $script:DocsPageFieldCode[$field] -Pointer $pointer -Message $message -PagePath $PagePath -FieldLine $FieldLine))
            continue
        }
        $schemaInvalid = $true
    }
    return @{ Findings = $mapped.ToArray(); SchemaInvalid = $schemaInvalid }
}

Export-ModuleMember -Function `
    New-DocsPageFieldFinding, `
    Get-DocsPageConstraintFinding, `
    Test-DocsPageReviewDate, `
    Get-DocsPageValueFinding, `
    ConvertTo-DocsPageFieldFinding
