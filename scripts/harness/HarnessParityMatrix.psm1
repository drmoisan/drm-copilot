Set-StrictMode -Version Latest

# Harness parity matrix (issue #1025): loads config/harness-parity-matrix.json and reports violations of
# spec `## Data & State` invariants 1 to 7 (invariant 7 as narrowed by decision D-R6: no per-field JSON
# type checking; the schema file is the type authority) and the `pending-source:` rule.

Import-Module (Join-Path $PSScriptRoot 'HarnessInventory.psm1')

function Get-HarnessParityMatrixRuleSet {
    <#
    .SYNOPSIS
        Returns the matrix rules as data: property-name sets, required lists, enums, conditional rules,
        the id pattern and the schema identifiers.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()
    return [pscustomobject]@{
        SchemaId             = 'https://drm-copilot.dev/schemas/harness-parity-matrix/1.0.0/schema.json'
        SchemaDialect        = 'https://json-schema.org/draft/2020-12/schema'
        SchemaVersionPattern = '^\d+\.\d+\.\d+$'
        TopLevelProperties   = @('$schema', 'schema_version', 'features')
        TopLevelRequired     = @('$schema', 'schema_version', 'features')
        EntryProperties      = @('id', 'ecosystem', 'kind', 'name', 'source_path', 'source_pointer', 'disposition', 'reason', 'target_paths', 'generated_from', 'generator', 'parity_group', 'consumers', 'owner_child', 'decision_status', 'decision_ref', 'notes')
        EntryRequired        = @('id', 'ecosystem', 'kind', 'name', 'source_path', 'disposition', 'parity_group', 'consumers', 'owner_child', 'decision_status')
        Enums                = [ordered]@{
            ecosystem       = @('claude', 'codex', 'copilot', 'cross-tool')
            kind            = @('instructions', 'path-scoped-rule', 'skill', 'skill-frontmatter-field', 'skill-metadata-file', 'agent', 'subagent-frontmatter-field', 'handoff', 'prompt', 'hook-registration', 'permission', 'setting', 'mcp-server')
            disposition     = @('shared', 'native', 'generated', 'dropped')
            consumers       = @('claude-code', 'codex', 'copilot-vscode', 'copilot-cli', 'copilot-cloud')
            decision_status = @('approved', 'provisional')
        }
        ConditionalRules     = @(
            [pscustomobject]@{ Name = 'dropped-requires-reason-and-decision-ref'; IfProperty = 'disposition'; IfValues = @('dropped'); Required = @('reason', 'decision_ref'); Forbidden = @('target_paths') }
            [pscustomobject]@{ Name = 'shared-or-generated-requires-target-paths'; IfProperty = 'disposition'; IfValues = @('shared', 'generated'); Required = @('target_paths'); Forbidden = @() }
            [pscustomobject]@{ Name = 'generated-requires-generated-from'; IfProperty = 'disposition'; IfValues = @('generated'); Required = @('generated_from'); Forbidden = @() }
            [pscustomobject]@{ Name = 'provisional-requires-decision-ref'; IfProperty = 'decision_status'; IfValues = @('provisional'); Required = @('decision_ref'); Forbidden = @() }
            [pscustomobject]@{ Name = 'pending-source-requires-provisional'; IfProperty = 'generated_from'; IfPattern = '^pending-source:'; Required = @('decision_status'); Forbidden = @(); RequiredValue = @{ decision_status = 'provisional' } }
        )
        IdPattern            = '^(claude|codex|copilot|cross-tool):[a-z-]+:(?:[A-Za-z0-9._-]|%[0-9A-F]{2})+(?:/(?:[A-Za-z0-9._-]|%[0-9A-F]{2})*)*(?:~(?:[A-Za-z0-9._-]|%[0-9A-F]{2})+(?:~[0-9]{2})?)?$'
        DecisionRefPattern   = '^#\d+:[^\s]+$'
        PendingSourcePattern = '^pending-source:[a-z-]+$'
        OwnerChildMinimum    = 3
        OwnerChildMaximum    = 7
    }
}

function Import-HarnessParityMatrix {
    <#
    .SYNOPSIS
        Reads and parses the matrix JSON.
    .PARAMETER Path
        Path of the matrix file.
    .PARAMETER ReadFile
        Script block returning the file text (default: read from disk).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string] $Path,
        [scriptblock] $ReadFile = { param([string] $FilePath) [IO.File]::ReadAllText($FilePath) }
    )
    return ((& $ReadFile $Path) | ConvertFrom-Json)
}

function Test-HarnessRepositoryPath {
    <#
    .SYNOPSIS
        Returns $true for a repository-relative POSIX path (no leading '/', drive letter, backslash or '..').
    .PARAMETER Path
        The candidate path.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][AllowEmptyString()][object] $Path)
    if ($Path -isnot [string] -or $Path.Length -eq 0) { return $false }
    if ($Path.StartsWith('/') -or $Path -match '^[A-Za-z]:' -or $Path.Contains('\')) { return $false }
    return -not (@($Path.Split('/')) -contains '..')
}

function ConvertTo-HarnessViolation {
    <#
    .SYNOPSIS
        Builds one violation object naming the offending id (or features index, or top-level property).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][string] $Subject, [Parameter(Mandatory)][string] $Rule, [Parameter(Mandatory)][string] $Detail)
    return [pscustomobject]@{ Subject = $Subject; Rule = $Rule; Message = "${Subject}: [$Rule] $Detail" }
}

function Get-HarnessEntryViolation {
    <#
    .SYNOPSIS
        Returns the structural violations of one feature entry.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory)] $Entry, [Parameter(Mandatory)][string] $Subject, [Parameter(Mandatory)] $RuleSet)
    $found = [System.Collections.Generic.List[object]]::new()
    $names = @($Entry.PSObject.Properties.Name)
    $has = { param([string] $Name) $names -contains $Name }
    foreach ($name in $names) { if ($RuleSet.EntryProperties -notcontains $name) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'unknown-property' -Detail "unknown property '$name'")) } }
    foreach ($name in $RuleSet.EntryRequired) { if (-not (& $has $name)) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'required' -Detail "missing required field '$name'")) } }
    foreach ($field in @('ecosystem', 'kind', 'disposition', 'decision_status')) {
        if ((& $has $field) -and $RuleSet.Enums[$field] -cnotcontains [string]$Entry.$field) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'enum' -Detail "$field value '$($Entry.$field)' is not in the enum")) }
    }
    if (& $has 'consumers') {
        $items = @($Entry.consumers)
        foreach ($item in $items) { if ($RuleSet.Enums['consumers'] -cnotcontains [string]$item) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'enum' -Detail "consumers item '$item' is not in the enum")) } }
        if (@($items | Select-Object -Unique).Count -ne $items.Count) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'unique-items' -Detail 'consumers has a duplicate item')) }
    }
    if (& $has 'id') {
        $id = [string]$Entry.id
        if ($id -cnotmatch $RuleSet.IdPattern) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'id-pattern' -Detail 'id does not match the id pattern')) }
        $parts = $id.Split(':')
        if ((& $has 'ecosystem') -and $parts[0] -cne [string]$Entry.ecosystem) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'id-ecosystem' -Detail "id ecosystem segment differs from ecosystem '$($Entry.ecosystem)'")) }
        if ((& $has 'kind') -and ($parts.Count -lt 2 -or $parts[1] -cne [string]$Entry.kind)) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'id-kind' -Detail "id kind segment differs from kind '$($Entry.kind)'")) }
    }
    foreach ($field in @('name', 'parity_group')) { if ((& $has $field) -and ([string]$Entry.$field).Length -eq 0) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'min-length' -Detail "$field is empty")) } }
    if ((& $has 'source_path') -and -not (Test-HarnessRepositoryPath -Path $Entry.source_path)) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'path-shape' -Detail 'source_path is not a repository-relative POSIX path')) }
    if (& $has 'target_paths') {
        $targets = @($Entry.target_paths)
        if ($targets.Count -eq 0) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'min-items' -Detail 'target_paths is empty')) }
        if (@($targets | Select-Object -Unique).Count -ne $targets.Count) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'unique-items' -Detail 'target_paths has a duplicate item')) }
        foreach ($target in $targets) { if (-not (Test-HarnessRepositoryPath -Path $target)) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'path-shape' -Detail "target_paths item '$target' is not a repository-relative POSIX path")) } }
    }
    if (& $has 'generated_from') {
        $source = $Entry.generated_from
        $isPending = ($source -is [string]) -and ($source -cmatch $RuleSet.PendingSourcePattern)
        if (-not $isPending -and (([string]$source).StartsWith('pending-source:') -or -not (Test-HarnessRepositoryPath -Path $source))) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'generated-from-shape' -Detail "generated_from '$source' is neither a repository-relative path nor pending-source:<kind>")) }
    }
    if ((& $has 'reason') -and ([string]$Entry.reason).Length -eq 0) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'min-length' -Detail 'reason is empty')) }
    if ((& $has 'decision_ref') -and ([string]$Entry.decision_ref) -cnotmatch $RuleSet.DecisionRefPattern) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'decision-ref-pattern' -Detail "decision_ref '$($Entry.decision_ref)' does not match #<issue>:<path>")) }
    if (& $has 'owner_child') {
        $owner = $Entry.owner_child
        $isInteger = ($owner -is [int]) -or ($owner -is [long])
        if ($null -ne $owner -and (-not $isInteger -or $owner -lt $RuleSet.OwnerChildMinimum -or $owner -gt $RuleSet.OwnerChildMaximum)) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule 'owner-child' -Detail "owner_child '$owner' is not null or an integer from 3 to 7")) }
    }
    foreach ($rule in $RuleSet.ConditionalRules) {
        if (-not (& $has $rule.IfProperty)) { continue }
        $value = [string]$Entry.($rule.IfProperty)
        $applies = if ($rule.PSObject.Properties.Name -contains 'IfPattern') { $value -cmatch $rule.IfPattern } else { $rule.IfValues -ccontains $value }
        if (-not $applies) { continue }
        foreach ($name in $rule.Required) { if (-not (& $has $name)) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule $rule.Name -Detail "requires '$name'")) } }
        foreach ($name in $rule.Forbidden) { if (& $has $name) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule $rule.Name -Detail "forbids '$name'")) } }
        if ($rule.PSObject.Properties.Name -contains 'RequiredValue') {
            foreach ($key in $rule.RequiredValue.Keys) { if (-not (& $has $key) -or [string]$Entry.$key -cne $rule.RequiredValue[$key]) { $found.Add((ConvertTo-HarnessViolation -Subject $Subject -Rule $rule.Name -Detail "requires $key '$($rule.RequiredValue[$key])'")) } }
        }
    }
    return $found.ToArray()
}

function Get-HarnessParityMatrixViolation {
    <#
    .SYNOPSIS
        Returns every violation of the matrix against the rule set and the inventory.
    .PARAMETER Matrix
        The parsed matrix object.
    .PARAMETER InventoryFeature
        The inventory entries (objects with an id property).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory)] $Matrix, [AllowEmptyCollection()][object[]] $InventoryFeature = @())
    $rules = Get-HarnessParityMatrixRuleSet
    $found = [System.Collections.Generic.List[object]]::new()
    $topNames = @($Matrix.PSObject.Properties.Name)
    foreach ($name in $topNames) { if ($rules.TopLevelProperties -notcontains $name) { $found.Add((ConvertTo-HarnessViolation -Subject $name -Rule 'unknown-property' -Detail "unknown top-level property '$name'")) } }
    foreach ($name in $rules.TopLevelRequired) { if ($topNames -notcontains $name) { $found.Add((ConvertTo-HarnessViolation -Subject $name -Rule 'required' -Detail "missing required top-level property '$name'")) } }
    if ($topNames -contains '$schema' -and [string]$Matrix.'$schema' -cne $rules.SchemaId) { $found.Add((ConvertTo-HarnessViolation -Subject '$schema' -Rule 'const' -Detail "`$schema must equal '$($rules.SchemaId)'")) }
    if ($topNames -contains 'schema_version' -and [string]$Matrix.schema_version -cnotmatch $rules.SchemaVersionPattern) { $found.Add((ConvertTo-HarnessViolation -Subject 'schema_version' -Rule 'pattern' -Detail "schema_version '$($Matrix.schema_version)' does not match $($rules.SchemaVersionPattern)")) }
    $features = @(if ($topNames -contains 'features') { $Matrix.features })
    if ($topNames -contains 'features' -and $features.Count -eq 0) { $found.Add((ConvertTo-HarnessViolation -Subject 'features' -Rule 'min-items' -Detail 'features is empty')) }
    $seen = [System.Collections.Generic.Dictionary[string, int]]::new([StringComparer]::Ordinal)
    $previous = $null
    for ($index = 0; $index -lt $features.Count; $index++) {
        $entry = $features[$index]
        $hasId = @($entry.PSObject.Properties.Name) -contains 'id'
        $subject = if ($hasId) { [string]$entry.id } else { "features[$index]" }
        foreach ($violation in (Get-HarnessEntryViolation -Entry $entry -Subject $subject -RuleSet $rules)) { $found.Add($violation) }
        if (-not $hasId) { continue }
        if ($seen.ContainsKey($subject)) { $found.Add((ConvertTo-HarnessViolation -Subject $subject -Rule 'unique-id' -Detail "duplicate id (also at features[$($seen[$subject])])")) } else { $seen[$subject] = $index }
        if ($null -ne $previous -and [string]::CompareOrdinal($previous, $subject) -gt 0) { $found.Add((ConvertTo-HarnessViolation -Subject $subject -Rule 'ordering' -Detail "features is not sorted by id: follows '$previous'")) }
        $previous = $subject
    }
    $inventoryIds = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($feature in $InventoryFeature) { [void]$inventoryIds.Add([string]$feature.id) }
    foreach ($id in $inventoryIds) { if (-not $seen.ContainsKey($id)) { $found.Add((ConvertTo-HarnessViolation -Subject $id -Rule 'missing-entry' -Detail 'inventoried feature has no matrix entry')) } }
    foreach ($id in $seen.Keys) {
        $entry = $features[$seen[$id]]
        if (-not $inventoryIds.Contains($id) -and [string]$entry.disposition -cne 'dropped') { $found.Add((ConvertTo-HarnessViolation -Subject $id -Rule 'orphan' -Detail 'entry is not inventoried and is not dropped')) }
    }
    return $found.ToArray()
}

function Get-HarnessParityGroup {
    <#
    .SYNOPSIS
        Returns the parity_group of an inventory entry (plan `## Matrix Bootstrap Rules`).
    .PARAMETER Feature
        The inventory entry.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)] $Feature)
    $components = @((ConvertFrom-HarnessFeatureId -Id ([string]$Feature.id)).NameComponent)
    $name = [string]$Feature.name
    switch ([string]$Feature.kind) {
        'skill' { return "skill:$name" }
        'skill-frontmatter-field' { return "skill-field:$name" }
        'skill-metadata-file' { return "skill-metadata:$name" }
        'agent' { return 'agent:' + ($name -replace '-(c1|c2|c3|c4|c3-elevated)$', '') }
        'subagent-frontmatter-field' { return "subagent-field:$name" }
        'handoff' { return "handoff:$name" }
        'prompt' { return "prompt:$name" }
        'hook-registration' { return "hook:$($components[-1])" }
        'permission' { return "permission:$name" }
        'setting' { return "setting:$name" }
        'mcp-server' { return "mcp:$name" }
        'path-scoped-rule' { return 'rule:' + ($name -replace '\.instructions$', '') }
        'instructions' { return "instructions:$name" }
        default { throw "Unknown kind '$($Feature.kind)' for '$($Feature.id)'." }
    }
}

function New-HarnessParityMatrixSkeleton {
    <#
    .SYNOPSIS
        Emits draft matrix entries (identity fields, parity_group, empty consumers, owner_child null)
        for the inventory entries that have no matrix entry.
    .PARAMETER InventoryFeature
        The inventory entries.
    .PARAMETER ExistingId
        Ids already present in the matrix; their features are skipped.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([object[]])]
    param([AllowEmptyCollection()][object[]] $InventoryFeature = @(), [AllowEmptyCollection()][string[]] $ExistingId = @())
    $existing = [System.Collections.Generic.HashSet[string]]::new([string[]]$ExistingId, [StringComparer]::Ordinal)
    $result = [System.Collections.Generic.List[object]]::new()
    if (-not $PSCmdlet.ShouldProcess('parity matrix skeleton', 'Emit draft entries')) { return $result.ToArray() }
    foreach ($feature in $InventoryFeature) {
        if ($existing.Contains([string]$feature.id)) { continue }
        $entry = [ordered]@{ id = $feature.id; ecosystem = $feature.ecosystem; kind = $feature.kind; name = $feature.name; source_path = $feature.source_path }
        if (@($feature.PSObject.Properties.Name) -contains 'source_pointer') { $entry['source_pointer'] = $feature.source_pointer }
        $entry['parity_group'] = Get-HarnessParityGroup -Feature $feature
        $entry['consumers'] = @()
        $entry['owner_child'] = $null
        $result.Add([pscustomobject]$entry)
    }
    return $result.ToArray()
}

Export-ModuleMember -Function Get-HarnessParityMatrixRuleSet, Import-HarnessParityMatrix, Get-HarnessParityMatrixViolation, New-HarnessParityMatrixSkeleton
