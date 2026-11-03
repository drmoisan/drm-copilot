<#
.SYNOPSIS
    Schema table, schema reading, in-memory schema composition, artifact validation, the
    structural walk and the PowerShell version floor for the documentation library.

.DESCRIPTION
    Each docs schema file references the shared definitions through the docs common URN.
    Test-Json does not resolve a cross-file reference, so Join-DocsSchemaText composes a
    self-contained schema in memory: it copies every docs common definition into the target
    $defs as common.<name>, replaces the self-referential common.json-value with the equivalent
    empty schema {} (Test-Json rejects a self-referential $defs entry), reports any other
    self-referential copied definition, and rewrites every $ref to an inline #/$defs reference.
    No reference is ever fetched.

    Test-DocsArtifactText runs Test-Json as the schema gate and the structural walk
    Get-DocsSchemaStructuralFinding to name the failing field, because Test-Json messages do not
    locate failures behind an inline $ref.

    Read-DocsSchemaSet is the only read. Every other function is pure apart from the built-in
    Test-Json call, and no module keeps a schema or composition cache.

.NOTES
    Issue #1020. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop

$script:DocsSchemaMinimumPowerShellVersion = [version] '7.4'
$script:DocsSchemaCommonUrnPrefix = 'urn:drm-copilot:docs:1.0.0:common#/$defs/'
$script:DocsSchemaLocalDefsPrefix = '#/$defs/'
$script:DocsSchemaMaxRefDepth = 64

function Get-DocsSchemaName {
    <#
    .SYNOPSIS
        Returns the docs schema names in fixed order.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()

    return [string[]]@(
        'common'
        'docs-profile'
        'surface-inventory-snapshot'
        'docs-coverage-ledger'
        'docs-parity-matrix'
        'docs-evidence-pin'
        'docs-validation-receipt'
        'docs-command-envelope'
        # --- 1021: page-metadata ---
    )
}

function Get-DocsSchemaPath {
    <#
    .SYNOPSIS
        Returns an ordered map of schema name to the runtime schema file path.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()

    return [ordered]@{
        'common'                     = (Join-Path -Path $PSScriptRoot -ChildPath 'schemas/v1/common.schema.json')
        'docs-profile'               = (Join-Path -Path $PSScriptRoot -ChildPath 'schemas/v1/docs-profile.schema.json')
        'surface-inventory-snapshot' = (Join-Path -Path $PSScriptRoot -ChildPath 'schemas/v1/surface-inventory-snapshot.schema.json')
        'docs-coverage-ledger'       = (Join-Path -Path $PSScriptRoot -ChildPath 'schemas/v1/docs-coverage-ledger.schema.json')
        'docs-parity-matrix'         = (Join-Path -Path $PSScriptRoot -ChildPath 'schemas/v1/docs-parity-matrix.schema.json')
        'docs-evidence-pin'          = (Join-Path -Path $PSScriptRoot -ChildPath 'schemas/v1/docs-evidence-pin.schema.json')
        'docs-validation-receipt'    = (Join-Path -Path $PSScriptRoot -ChildPath 'schemas/v1/docs-validation-receipt.schema.json')
        'docs-command-envelope'      = (Join-Path -Path $PSScriptRoot -ChildPath 'schemas/v1/docs-command-envelope.schema.json')
    }
}

function Read-DocsSchemaSet {
    <#
    .SYNOPSIS
        Reads every schema file and returns an ordered map of schema name to text.
    .DESCRIPTION
        ReadText receives one path and returns its text; the default reads the file bytes and
        decodes them through ConvertFrom-DocsUtf8Bytes.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()] [System.Collections.IDictionary] $SchemaPath,
        [AllowNull()] [scriptblock] $ReadText
    )

    if ($null -eq $SchemaPath) { $SchemaPath = Get-DocsSchemaPath }
    if ($null -eq $ReadText) {
        $ReadText = {
            param($Path)
            ConvertFrom-DocsUtf8Bytes -Bytes ([System.IO.File]::ReadAllBytes([string] $Path))
        }
    }
    $set = [ordered]@{}
    foreach ($name in @($SchemaPath.Keys)) {
        $set[[string] $name] = [string] (& $ReadText $SchemaPath[$name])
    }
    return $set
}

function New-DocsSchemaFinding {
    <#
    .SYNOPSIS
        Builds one error finding for this module (private helper).
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

function Test-DocsSchemaSelfReference {
    <#
    .SYNOPSIS
        Returns $true when any string-valued $ref in the subtree equals Ref (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] [object] $Node,
        [Parameter(Mandatory = $true)] [string] $Ref
    )

    if ($Node -is [System.Collections.IDictionary]) {
        foreach ($key in @($Node.Keys)) {
            $child = $Node[$key]
            if ([string] $key -ceq '$ref' -and $child -is [string] -and $child -ceq $Ref) { return $true }
            if (Test-DocsSchemaSelfReference -Node $child -Ref $Ref) { return $true }
        }
    } elseif ($Node -is [System.Collections.IList]) {
        foreach ($item in $Node) {
            if (Test-DocsSchemaSelfReference -Node $item -Ref $Ref) { return $true }
        }
    }
    return $false
}

function Update-DocsSchemaRef {
    <#
    .SYNOPSIS
        Rewrites every string-valued $ref of a parsed schema subtree in place (private helper).
    .DESCRIPTION
        InCommon selects the rules for a copied common definition, where #/$defs/<name> becomes
        #/$defs/common.<name>. In both modes the docs common URN form becomes
        #/$defs/common.<name>; outside copied definitions a ref beginning with # is unchanged.
        Every other ref, and a common name that does not exist, adds DOCS_SCHEMA_REF_UNRESOLVED.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Changes only the in-memory schema copy parsed inside Join-DocsSchemaText; no system state.')]
    [CmdletBinding()]
    param(
        [AllowNull()] [object] $Node,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Pointer,
        [Parameter(Mandatory = $true)] [System.Collections.Generic.HashSet[string]] $CommonName,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.List[object]] $Findings,
        [switch] $InCommon
    )

    if ($Node -is [System.Collections.IList] -and $Node -isnot [System.Collections.IDictionary]) {
        for ($index = 0; $index -lt $Node.Count; $index++) {
            Update-DocsSchemaRef -Node $Node[$index] -Pointer ($Pointer + '/' + $index) -CommonName $CommonName -Findings $Findings -InCommon:$InCommon
        }
        return
    }
    if ($Node -isnot [System.Collections.IDictionary]) { return }
    foreach ($key in @($Node.Keys)) {
        $childPointer = Get-DocsChildPointer -Pointer $Pointer -Part $key
        $value = $Node[$key]
        if ([string] $key -cne '$ref' -or $value -isnot [string]) {
            Update-DocsSchemaRef -Node $value -Pointer $childPointer -CommonName $CommonName -Findings $Findings -InCommon:$InCommon
            continue
        }
        $name = $null
        if ($value.StartsWith($script:DocsSchemaCommonUrnPrefix, [System.StringComparison]::Ordinal)) {
            $name = $value.Substring($script:DocsSchemaCommonUrnPrefix.Length)
        } elseif ($InCommon -and $value.StartsWith($script:DocsSchemaLocalDefsPrefix, [System.StringComparison]::Ordinal)) {
            $name = $value.Substring($script:DocsSchemaLocalDefsPrefix.Length)
        } elseif (-not $InCommon -and $value.StartsWith('#', [System.StringComparison]::Ordinal)) {
            continue
        }
        if ($null -ne $name -and $CommonName.Contains($name)) {
            $Node[$key] = $script:DocsSchemaLocalDefsPrefix + 'common.' + $name
            continue
        }
        $Findings.Add((New-DocsSchemaFinding -Code 'DOCS_SCHEMA_REF_UNRESOLVED' -Pointer $childPointer -Message "The reference '$value' does not name a docs common definition and is never fetched." -NextAction 'Reference a docs common definition through urn:drm-copilot:docs:1.0.0:common#/$defs/<name> or a local #/$defs entry.'))
    }
}

function Join-DocsSchemaText {
    <#
    .SYNOPSIS
        Composes one docs schema with docs common into a self-contained schema in memory.
    .DESCRIPTION
        Returns @{ Text; Value; Findings }. Text and Value are $null when a finding exists.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'JSON schema keys are case-sensitive; the @{} literal is case-insensitive, so an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $SchemaText,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $CommonSchemaText
    )

    $target = ConvertFrom-DocsJsonText -Text $SchemaText
    $common = ConvertFrom-DocsJsonText -Text $CommonSchemaText
    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($finding in @($target.Findings) + @($common.Findings)) { if ($null -ne $finding) { $findings.Add($finding) } }
    if ($findings.Count -gt 0) { return @{ Text = $null; Value = $null; Findings = $findings.ToArray() } }
    $schema = $target.Value
    $commonDefs = if ($common.Value -is [System.Collections.IDictionary] -and $common.Value.Contains('$defs')) { $common.Value['$defs'] } else { @{} }
    if (-not $schema.Contains('$defs')) { $schema['$defs'] = [hashtable]::new([System.StringComparer]::Ordinal) }
    $targetDefs = $schema['$defs']

    # Steps 1 and 2: copy the common definitions; a target key in the common. namespace conflicts.
    foreach ($key in @($targetDefs.Keys)) {
        if (([string] $key).StartsWith('common.', [System.StringComparison]::Ordinal)) {
            $findings.Add((New-DocsSchemaFinding -Code 'DOCS_SCHEMA_COMPOSITION_CONFLICT' -Pointer (Get-DocsChildPointer -Pointer '/$defs' -Part $key) -Message "The schema already defines '$key' in the reserved common. namespace." -NextAction 'Rename the local definition so it does not begin with common.'))
        }
    }
    $commonName = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($name in @($commonDefs.Keys)) { [void]$commonName.Add([string] $name) }

    # Step 3: remove the recursion hazard before any ref is rewritten.
    $copied = [ordered]@{}
    foreach ($name in @($commonDefs.Keys)) {
        $definition = $commonDefs[$name]
        if (Test-DocsSchemaSelfReference -Node $definition -Ref ($script:DocsSchemaLocalDefsPrefix + $name)) {
            if ([string] $name -ceq 'json-value') {
                $definition = [hashtable]::new([System.StringComparer]::Ordinal)
            } else {
                $findings.Add((New-DocsSchemaFinding -Code 'DOCS_SCHEMA_RECURSIVE_DEF' -Pointer (Get-DocsChildPointer -Pointer '/$defs' -Part $name) -Message "The docs common definition '$name' references itself; Test-Json rejects a self-referential definition." -NextAction "Remove the self-reference from the docs common definition '$name'."))
            }
        }
        $copied[[string] $name] = $definition
    }

    # Step 4: rewrite every string-valued $ref, then insert the copied definitions.
    Update-DocsSchemaRef -Node $schema -Pointer '' -CommonName $commonName -Findings $findings
    foreach ($name in @($copied.Keys)) {
        Update-DocsSchemaRef -Node $copied[$name] -Pointer (Get-DocsChildPointer -Pointer '/$defs' -Part ('common.' + $name)) -CommonName $commonName -Findings $findings -InCommon
        if (-not $targetDefs.Contains('common.' + $name)) { $targetDefs['common.' + $name] = $copied[$name] }
    }

    # Step 5: remove the document identity; the dialect stays.
    if ($schema.Contains('$id')) { $schema.Remove('$id') }
    if ($findings.Count -gt 0) { return @{ Text = $null; Value = $null; Findings = $findings.ToArray() } }
    return @{ Text = (ConvertTo-DocsJsonText -Value $schema); Value = $schema; Findings = [object[]]@() }
}

function Get-DocsComposedSchemaSet {
    <#
    .SYNOPSIS
        Composes every non-common schema of a schema set once.
    .DESCRIPTION
        Returns @{ Schemas; Findings }: Schemas is an ordered map of artifact kind to
        @{ Text; Value } and is the ComposedSchemaSet argument of Test-DocsArtifactText.
        Composition findings make the set unusable (exit 3 at the command boundary).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $SchemaSet)

    if (-not $SchemaSet.Contains('common')) { throw 'DOCS_SCHEMA_UNKNOWN_KIND: the schema set has no common schema.' }
    $schemas = [ordered]@{}
    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($name in @($SchemaSet.Keys)) {
        if ([string] $name -ceq 'common') { continue }
        $composed = Join-DocsSchemaText -SchemaText ([string] $SchemaSet[$name]) -CommonSchemaText ([string] $SchemaSet['common'])
        foreach ($finding in @($composed.Findings)) { if ($null -ne $finding) { $findings.Add($finding) } }
        $schemas[[string] $name] = @{ Text = $composed.Text; Value = $composed.Value }
    }
    return @{ Schemas = $schemas; Findings = (Get-DocsOrderedFinding -Finding $findings.ToArray()) }
}

function ConvertFrom-DocsSchemaErrorRecord {
    <#
    .SYNOPSIS
        Maps one Test-Json ErrorRecord to a DOCS_SCHEMA_INVALID finding.
    .DESCRIPTION
        The pointer is the final " at '<pointer>'" of the message when it is a JSON pointer,
        otherwise empty.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Management.Automation.ErrorRecord] $ErrorRecord,
        [AllowNull()] [string] $ArtifactPath
    )

    $message = [string] $ErrorRecord.Exception.Message
    $pointer = ''
    $match = [regex]::Match($message, " at '([^']*)'\s*\.?\s*$")
    if ($match.Success -and $match.Groups[1].Value -cmatch '^(?:/(?:[^~/]|~[01])*)*$(?![\s\S])') { $pointer = $match.Groups[1].Value }
    $text = if ([string]::IsNullOrWhiteSpace($message)) { 'Test-Json rejected the artifact.' } else { "Test-Json rejected the artifact: $message" }
    return New-DocsSchemaFinding -Code 'DOCS_SCHEMA_INVALID' -Pointer $pointer -Message $text -NextAction 'Correct the artifact so it conforms to its schema.' -ArtifactPath $ArtifactPath
}

function Test-DocsArtifactText {
    <#
    .SYNOPSIS
        Validates artifact JSON text against its composed schema and returns ordered findings.
    .DESCRIPTION
        ComposedSchemaSet is the Schemas map of Get-DocsComposedSchemaSet. Walk findings take
        precedence over Test-Json; when Test-Json fails and the walk finds nothing, each
        ErrorRecord becomes DOCS_SCHEMA_INVALID, or exactly one such finding at pointer '' is
        returned when there is no ErrorRecord. An unknown kind throws DOCS_SCHEMA_UNKNOWN_KIND.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [string] $ArtifactKind,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $JsonText,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet,
        [AllowNull()] [string] $ArtifactPath
    )

    if ($ArtifactKind -ceq 'common' -or -not $ComposedSchemaSet.Contains($ArtifactKind) -or $null -eq $ComposedSchemaSet[$ArtifactKind].Text) {
        throw "DOCS_SCHEMA_UNKNOWN_KIND: '$ArtifactKind' is not a composed docs schema."
    }
    $parsed = ConvertFrom-DocsJsonText -Text $JsonText -ArtifactPath $ArtifactPath
    if (@($parsed.Findings).Count -gt 0) { return Get-DocsOrderedFinding -Finding $parsed.Findings }
    $composed = $ComposedSchemaSet[$ArtifactKind]
    $source = if ($JsonText.StartsWith([char]0xFEFF)) { $JsonText.Substring(1) } else { $JsonText }
    $schemaErrors = @()
    $valid = $false
    try {
        $valid = [bool] (Test-Json -Json $source -Schema $composed.Text -ErrorAction SilentlyContinue -ErrorVariable schemaErrors)
    } catch {
        $schemaErrors = @($_)
    }
    $walk = Get-DocsSchemaStructuralFinding -Schema $composed.Value -Instance $parsed.Value -RootSchema $composed.Value -ArtifactPath $ArtifactPath
    if ($walk.Count -gt 0) { return Get-DocsOrderedFinding -Finding $walk }
    if ($valid) { return , [object[]]@() }
    $records = @($schemaErrors | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] })
    if ($records.Count -gt 0) {
        return Get-DocsOrderedFinding -Finding @($records | ForEach-Object { ConvertFrom-DocsSchemaErrorRecord -ErrorRecord $_ -ArtifactPath $ArtifactPath })
    }
    return Get-DocsOrderedFinding -Finding @(New-DocsSchemaFinding -Code 'DOCS_SCHEMA_INVALID' -Pointer '' -Message "The artifact does not conform to the '$ArtifactKind' schema." -NextAction 'Correct the artifact so it conforms to its schema.' -ArtifactPath $ArtifactPath)
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

function Get-DocsSchemaStructuralFinding {
    <#
    .SYNOPSIS
        Walks the structural keyword subset of a composed schema and returns error findings.
    .DESCRIPTION
        Evaluates $ref (local only, depth bounded at 64), type, required, properties,
        patternProperties, additionalProperties false, enum, const, items, minItems, maxItems,
        allOf, if/then/else and anyOf. Every other keyword is left to Test-Json. Each finding
        carries the instance pointer and a message that names the field. Inputs are not mutated.
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
        if ($RefDepth -ge $script:DocsSchemaMaxRefDepth) {
            $findings.Add((New-DocsSchemaFinding -Code 'DOCS_SCHEMA_TOO_DEEP' -Pointer $Pointer -ArtifactPath $ArtifactPath -Message "Schema reference expansion for '$field' exceeds $($script:DocsSchemaMaxRefDepth) levels." -NextAction 'Remove the reference cycle from the schema.'))
            return , $findings.ToArray()
        }
        $target = Resolve-DocsSchemaLocalRef -RootSchema $RootSchema -Ref $Schema['$ref']
        if ($null -ne $target) { $findings.AddRange((Get-DocsSchemaStructuralFinding @walk -Schema $target -Instance $Instance -Pointer $Pointer -RefDepth ($RefDepth + 1))) }
    }
    $types = @(Get-DocsJsonTypeName -Value $Instance)
    if ($Schema.Contains('type')) {
        $allowed = @($Schema['type'])
        if (-not @($allowed | Where-Object { $types -ccontains [string] $_ }).Count) {
            $findings.Add((New-DocsSchemaFinding -Code 'DOCS_SCHEMA_TYPE_MISMATCH' -Pointer $Pointer -ArtifactPath $ArtifactPath -Message "Field '$field' has JSON type '$($types[0])'; allowed: $($allowed -join ', ')." -NextAction "Give '$field' a value of an allowed type."))
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
            $findings.Add((New-DocsSchemaFinding -Code 'DOCS_SCHEMA_VALUE_NOT_ALLOWED' -Pointer $Pointer -ArtifactPath $ArtifactPath -Message "Field '$field' has a value that is not allowed; allowed: $allowedText." -NextAction "Use one of the allowed values for '$field'."))
        }
    }
    if ($types -ccontains 'object') {
        $properties = if ($Schema.Contains('properties') -and $Schema['properties'] -is [System.Collections.IDictionary]) { $Schema['properties'] } else { @{} }
        $patterns = if ($Schema.Contains('patternProperties') -and $Schema['patternProperties'] -is [System.Collections.IDictionary]) { $Schema['patternProperties'] } else { @{} }
        if ($Schema.Contains('required')) {
            foreach ($name in @($Schema['required'])) {
                if (-not $Instance.Contains([string] $name)) {
                    $findings.Add((New-DocsSchemaFinding -Code 'DOCS_SCHEMA_REQUIRED_MISSING' -Pointer (Get-DocsChildPointer -Pointer $Pointer -Part $name) -ArtifactPath $ArtifactPath -Message "Required field '$name' is missing." -NextAction "Add the required field '$name'."))
                }
            }
        }
        foreach ($member in @($Instance.Keys)) {
            $memberPointer = Get-DocsChildPointer -Pointer $Pointer -Part $member
            $known = $properties.Contains([string] $member)
            if ($known) { $findings.AddRange((Get-DocsSchemaStructuralFinding @walk -Schema $properties[[string] $member] -Instance $Instance[$member] -Pointer $memberPointer -RefDepth $RefDepth)) }
            foreach ($pattern in @($patterns.Keys)) {
                if (-not [regex]::IsMatch([string] $member, [string] $pattern)) { continue }
                $known = $true
                $findings.AddRange((Get-DocsSchemaStructuralFinding @walk -Schema $patterns[$pattern] -Instance $Instance[$member] -Pointer $memberPointer -RefDepth $RefDepth))
            }
            if (-not $known -and $Schema.Contains('additionalProperties') -and $Schema['additionalProperties'] -is [bool] -and -not $Schema['additionalProperties']) {
                $findings.Add((New-DocsSchemaFinding -Code 'DOCS_SCHEMA_PROPERTY_UNKNOWN' -Pointer $memberPointer -ArtifactPath $ArtifactPath -Message "Field '$member' is not allowed here." -NextAction "Remove the field '$member' or correct its name."))
            }
        }
    }
    if ($types -ccontains 'array') {
        $count = @($Instance).Count
        if ($Schema.Contains('items') -and $Schema['items'] -is [System.Collections.IDictionary]) {
            for ($index = 0; $index -lt $count; $index++) {
                $findings.AddRange((Get-DocsSchemaStructuralFinding @walk -Schema $Schema['items'] -Instance $Instance[$index] -Pointer ($Pointer + '/' + $index) -RefDepth $RefDepth))
            }
        }
        $tooFew = $Schema.Contains('minItems') -and $count -lt [long] $Schema['minItems']
        $tooMany = $Schema.Contains('maxItems') -and $count -gt [long] $Schema['maxItems']
        if ($tooFew -or $tooMany) {
            $findings.Add((New-DocsSchemaFinding -Code 'DOCS_SCHEMA_ITEM_COUNT' -Pointer $Pointer -ArtifactPath $ArtifactPath -Message "Field '$field' has $count items, outside the allowed bounds." -NextAction "Adjust the number of items in '$field'."))
        }
    }
    foreach ($member in @(if ($Schema.Contains('allOf')) { $Schema['allOf'] })) {
        $findings.AddRange((Get-DocsSchemaStructuralFinding @walk -Schema $member -Instance $Instance -Pointer $Pointer -RefDepth $RefDepth))
    }
    if ($Schema.Contains('if')) {
        $holds = (Get-DocsSchemaStructuralFinding @walk -Schema $Schema['if'] -Instance $Instance -Pointer $Pointer -RefDepth $RefDepth).Count -eq 0
        $branch = if ($holds) { 'then' } else { 'else' }
        if ($Schema.Contains($branch)) { $findings.AddRange((Get-DocsSchemaStructuralFinding @walk -Schema $Schema[$branch] -Instance $Instance -Pointer $Pointer -RefDepth $RefDepth)) }
    }
    if ($Schema.Contains('anyOf')) {
        $matched = $false
        foreach ($member in @($Schema['anyOf'])) {
            if ((Get-DocsSchemaStructuralFinding @walk -Schema $member -Instance $Instance -Pointer $Pointer -RefDepth $RefDepth).Count -eq 0) { $matched = $true; break }
        }
        if (-not $matched) {
            $findings.Add((New-DocsSchemaFinding -Code 'DOCS_SCHEMA_NO_BRANCH_MATCH' -Pointer $Pointer -ArtifactPath $ArtifactPath -Message "Field '$field' matches none of the allowed forms." -NextAction "Give '$field' a value of one of the allowed forms."))
        }
    }
    return , $findings.ToArray()
}

function Get-DocsRuntimeVersionError {
    <#
    .SYNOPSIS
        Returns the fail-closed message below PowerShell 7.4, otherwise $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([version] $PowerShellVersion = $PSVersionTable.PSVersion)

    if ($PowerShellVersion -ge $script:DocsSchemaMinimumPowerShellVersion) { return $null }
    return "The documentation tooling requires PowerShell $($script:DocsSchemaMinimumPowerShellVersion) or later (this host is PowerShell $PowerShellVersion), because schema validation uses Test-Json with JSON Schema Draft 2020-12."
}

Export-ModuleMember -Function `
    Get-DocsSchemaName, `
    Get-DocsSchemaPath, `
    Read-DocsSchemaSet, `
    Join-DocsSchemaText, `
    Get-DocsComposedSchemaSet, `
    Test-DocsArtifactText, `
    Get-DocsSchemaStructuralFinding, `
    ConvertFrom-DocsSchemaErrorRecord, `
    Get-DocsRuntimeVersionError
