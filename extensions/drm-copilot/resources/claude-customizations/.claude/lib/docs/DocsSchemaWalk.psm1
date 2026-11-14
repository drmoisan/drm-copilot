<#
.SYNOPSIS
    The structural walk of a composed docs schema: field-naming findings for a keyword subset.

.DESCRIPTION
    Get-DocsSchemaWalkFinding evaluates $ref (local only, depth bounded at 64), type, required,
    properties, patternProperties, additionalProperties false, enum, const, items, minItems,
    maxItems, allOf, if/then/else and anyOf over a parsed instance, and returns error findings
    that carry the instance pointer and a message naming the field. Every other keyword is left
    to Test-Json. DocsSchema.psm1 exposes the walk as Get-DocsSchemaStructuralFinding.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state; inputs are not mutated.

.NOTES
    Issue #1020. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop

$script:DocsSchemaWalkMaxRefDepth = 64

function New-DocsSchemaWalkResult {
    <#
    .SYNOPSIS
        Builds one walk error finding (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Pointer,
        [Parameter(Mandatory = $true)] [string] $Message,
        [Parameter(Mandatory = $true)] [string] $NextAction,
        [AllowNull()] [string] $ArtifactPath
    )

    return New-DocsFinding -Code $Code -Severity 'error' -Pointer $Pointer -Message $Message -NextAction $NextAction -ArtifactPath $ArtifactPath
}

function Get-DocsSchemaFieldName {
    <#
    .SYNOPSIS
        Returns the unescaped last pointer segment, or '(root)' (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Pointer)

    if ($Pointer.Length -eq 0) { return '(root)' }
    return $Pointer.Substring($Pointer.LastIndexOf('/') + 1).Replace('~1', '/').Replace('~0', '~')
}

function Get-DocsJsonTypeName {
    <#
    .SYNOPSIS
        Returns the JSON type names that a parsed value satisfies (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([AllowNull()] [object] $Value)

    if ($null -eq $Value) { return [string[]]@('null') }
    if ($Value -is [bool]) { return [string[]]@('boolean') }
    if ($Value -is [string]) { return [string[]]@('string') }
    if ($Value -is [long] -or $Value -is [int]) { return [string[]]@('integer', 'number') }
    if ($Value -is [double]) { if ([math]::Floor($Value) -eq $Value) { return [string[]]@('integer', 'number') } return [string[]]@('number') }
    if ($Value -is [System.Collections.IDictionary]) { return [string[]]@('object') }
    if ($Value -is [System.Collections.IList]) { return [string[]]@('array') }
    return [string[]]@('unknown')
}

function Resolve-DocsSchemaLocalRef {
    <#
    .SYNOPSIS
        Resolves a local '#/...' reference inside the root schema, or returns $null (private helper).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.IDictionary], [object])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $RootSchema,
        [Parameter(Mandatory = $true)] [string] $Ref
    )

    if ($Ref -ceq '#') { return $RootSchema }
    if (-not $Ref.StartsWith('#/', [System.StringComparison]::Ordinal)) { return $null }
    $node = $RootSchema
    foreach ($segment in $Ref.Substring(2).Split('/')) {
        $part = $segment.Replace('~1', '/').Replace('~0', '~')
        if ($node -is [System.Collections.IDictionary] -and $node.Contains($part)) { $node = $node[$part] } else { return $null }
    }
    return $node
}

function Get-DocsSchemaWalkFinding {
    <#
    .SYNOPSIS
        Walks the structural keyword subset of a composed schema and returns error findings.
    .DESCRIPTION
        Each finding carries the instance pointer and a message that names the field (the last
        pointer segment, or the property name for a missing or unknown property).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Schema,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyCollection()] [AllowEmptyString()] [object] $Instance,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $RootSchema,
        [AllowEmptyString()] [string] $Pointer = '',
        [AllowNull()] [string] $ArtifactPath,
        [ValidateRange(0, 1024)] [int] $RefDepth = 0
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    if ($Schema -isnot [System.Collections.IDictionary]) { return , $findings.ToArray() }
    $field = Get-DocsSchemaFieldName -Pointer $Pointer
    $walk = @{ RootSchema = $RootSchema; ArtifactPath = $ArtifactPath }
    if ($Schema.Contains('$ref') -and $Schema['$ref'] -is [string]) {
        if ($RefDepth -ge $script:DocsSchemaWalkMaxRefDepth) {
            $findings.Add((New-DocsSchemaWalkResult -Code 'DOCS_SCHEMA_TOO_DEEP' -Pointer $Pointer -ArtifactPath $ArtifactPath -Message "Schema reference expansion for '$field' exceeds $($script:DocsSchemaWalkMaxRefDepth) levels." -NextAction 'Remove the reference cycle from the schema.'))
            return , $findings.ToArray()
        }
        $target = Resolve-DocsSchemaLocalRef -RootSchema $RootSchema -Ref $Schema['$ref']
        if ($null -ne $target) { $findings.AddRange((Get-DocsSchemaWalkFinding @walk -Schema $target -Instance $Instance -Pointer $Pointer -RefDepth ($RefDepth + 1))) }
    }
    $types = @(Get-DocsJsonTypeName -Value $Instance)
    if ($Schema.Contains('type')) {
        $allowed = @($Schema['type'])
        if (-not @($allowed | Where-Object { $types -ccontains [string] $_ }).Count) {
            $findings.Add((New-DocsSchemaWalkResult -Code 'DOCS_SCHEMA_TYPE_MISMATCH' -Pointer $Pointer -ArtifactPath $ArtifactPath -Message "Field '$field' has JSON type '$($types[0])'; allowed: $($allowed -join ', ')." -NextAction "Give '$field' a value of an allowed type."))
        }
    }
    foreach ($keyword in 'enum', 'const') {
        if (-not $Schema.Contains($keyword)) { continue }
        $options = if ($keyword -ceq 'const') { , [object[]]@(, $Schema['const']) } else { , [object[]]@($Schema['enum']) }
        $actual = ConvertTo-DocsCanonicalJson -Value $Instance
        $hit = $false
        foreach ($option in $options) { if ((ConvertTo-DocsCanonicalJson -Value $option) -ceq $actual) { $hit = $true; break } }
        if (-not $hit) {
            $allowedText = (@($options | ForEach-Object { (ConvertTo-DocsCanonicalJson -Value $_).TrimEnd("`n") }) -join ', ')
            $findings.Add((New-DocsSchemaWalkResult -Code 'DOCS_SCHEMA_VALUE_NOT_ALLOWED' -Pointer $Pointer -ArtifactPath $ArtifactPath -Message "Field '$field' has a value that is not allowed; allowed: $allowedText." -NextAction "Use one of the allowed values for '$field'."))
        }
    }
    if ($types -ccontains 'object') {
        $properties = if ($Schema.Contains('properties') -and $Schema['properties'] -is [System.Collections.IDictionary]) { $Schema['properties'] } else { @{} }
        $patterns = if ($Schema.Contains('patternProperties') -and $Schema['patternProperties'] -is [System.Collections.IDictionary]) { $Schema['patternProperties'] } else { @{} }
        if ($Schema.Contains('required')) {
            foreach ($name in @($Schema['required'])) {
                if (-not $Instance.Contains([string] $name)) {
                    $findings.Add((New-DocsSchemaWalkResult -Code 'DOCS_SCHEMA_REQUIRED_MISSING' -Pointer (Get-DocsChildPointer -Pointer $Pointer -Part $name) -ArtifactPath $ArtifactPath -Message "Required field '$name' is missing." -NextAction "Add the required field '$name'."))
                }
            }
        }
        foreach ($member in @($Instance.Keys)) {
            $memberPointer = Get-DocsChildPointer -Pointer $Pointer -Part $member
            $known = $properties.Contains([string] $member)
            if ($known) { $findings.AddRange((Get-DocsSchemaWalkFinding @walk -Schema $properties[[string] $member] -Instance $Instance[$member] -Pointer $memberPointer -RefDepth $RefDepth)) }
            foreach ($pattern in @($patterns.Keys)) {
                if (-not [regex]::IsMatch([string] $member, [string] $pattern)) { continue }
                $known = $true
                $findings.AddRange((Get-DocsSchemaWalkFinding @walk -Schema $patterns[$pattern] -Instance $Instance[$member] -Pointer $memberPointer -RefDepth $RefDepth))
            }
            if (-not $known -and $Schema.Contains('additionalProperties') -and $Schema['additionalProperties'] -is [bool] -and -not $Schema['additionalProperties']) {
                $findings.Add((New-DocsSchemaWalkResult -Code 'DOCS_SCHEMA_PROPERTY_UNKNOWN' -Pointer $memberPointer -ArtifactPath $ArtifactPath -Message "Field '$member' is not allowed here." -NextAction "Remove the field '$member' or correct its name."))
            }
        }
    }
    if ($types -ccontains 'array') {
        $count = @($Instance).Count
        if ($Schema.Contains('items') -and $Schema['items'] -is [System.Collections.IDictionary]) {
            for ($index = 0; $index -lt $count; $index++) {
                $findings.AddRange((Get-DocsSchemaWalkFinding @walk -Schema $Schema['items'] -Instance $Instance[$index] -Pointer ($Pointer + '/' + $index) -RefDepth $RefDepth))
            }
        }
        $tooFew = $Schema.Contains('minItems') -and $count -lt [long] $Schema['minItems']
        $tooMany = $Schema.Contains('maxItems') -and $count -gt [long] $Schema['maxItems']
        if ($tooFew -or $tooMany) {
            $findings.Add((New-DocsSchemaWalkResult -Code 'DOCS_SCHEMA_ITEM_COUNT' -Pointer $Pointer -ArtifactPath $ArtifactPath -Message "Field '$field' has $count items, outside the allowed bounds." -NextAction "Adjust the number of items in '$field'."))
        }
    }
    foreach ($member in @(if ($Schema.Contains('allOf')) { $Schema['allOf'] })) {
        $findings.AddRange((Get-DocsSchemaWalkFinding @walk -Schema $member -Instance $Instance -Pointer $Pointer -RefDepth $RefDepth))
    }
    if ($Schema.Contains('if')) {
        $holds = (Get-DocsSchemaWalkFinding @walk -Schema $Schema['if'] -Instance $Instance -Pointer $Pointer -RefDepth $RefDepth).Count -eq 0
        $branch = if ($holds) { 'then' } else { 'else' }
        if ($Schema.Contains($branch)) { $findings.AddRange((Get-DocsSchemaWalkFinding @walk -Schema $Schema[$branch] -Instance $Instance -Pointer $Pointer -RefDepth $RefDepth)) }
    }
    if ($Schema.Contains('anyOf')) {
        $matched = $false
        foreach ($member in @($Schema['anyOf'])) {
            if ((Get-DocsSchemaWalkFinding @walk -Schema $member -Instance $Instance -Pointer $Pointer -RefDepth $RefDepth).Count -eq 0) { $matched = $true; break }
        }
        if (-not $matched) {
            $findings.Add((New-DocsSchemaWalkResult -Code 'DOCS_SCHEMA_NO_BRANCH_MATCH' -Pointer $Pointer -ArtifactPath $ArtifactPath -Message "Field '$field' matches none of the allowed forms." -NextAction "Give '$field' a value of one of the allowed forms."))
        }
    }
    return , $findings.ToArray()
}

Export-ModuleMember -Function Get-DocsSchemaWalkFinding
