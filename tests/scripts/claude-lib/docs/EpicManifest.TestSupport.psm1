<#
.SYNOPSIS
    Test support for issue #1038: a bounded epic-manifest frontmatter parser, schema checks and a
    wave calculator for the documentation-estate epic template.

.DESCRIPTION
    ConvertFrom-EpicManifestFrontmatter parses the YAML subset that the epic template uses: top-level
    plain scalars, the intent block (plain scalars and block sequences of plain scalars), a features
    block sequence of mappings with issue_num, feature_folder and a flow-sequence depends_on, and
    full-line '#' comments. Any other construct throws a message prefixed EPIC_MANIFEST_UNSUPPORTED.
    Get-EpicManifestSchemaFinding applies the epic-orchestrate manifest rules, Get-EpicManifestWave
    resolves depends_on entries and computes longest-path waves with cycle detection, and
    Get-EpicPlannedWave reads the '## Planned Waves' list of the template body.

    Every function is pure: it reads no file, starts no process and keeps no module-scope state.

.NOTES
    Issue #1038. Requires PowerShell 7.4 or later. Findings carry the codes EPIC_MANIFEST_UNSUPPORTED,
    EPIC_MANIFEST_KEY_MISSING, EPIC_MANIFEST_ISSUE_NUM_INVALID, EPIC_MANIFEST_BRANCH_MISMATCH,
    EPIC_MANIFEST_CREATED_AT_INVALID, EPIC_MANIFEST_INTENT_INVALID, EPIC_MANIFEST_DUPLICATE_ISSUE_NUM,
    EPIC_MANIFEST_DUPLICATE_FOLDER, EPIC_MANIFEST_UNRESOLVED_DEPENDENCY, EPIC_MANIFEST_SELF_EDGE and
    EPIC_MANIFEST_CYCLE.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-EpicManifestPlainScalar {
    <#
    .SYNOPSIS
        Returns $true when a value is a plain scalar of the supported subset (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Value)

    if ($Value.Length -eq 0) { return $false }
    if ($Value -match '^[\[\]{}"''|>&*!%@`#,?-]') { return $false }
    if ($Value.Contains(': ') -or $Value.EndsWith(':') -or $Value.Contains(' #')) { return $false }
    return $true
}

function Format-EpicManifestUnsupportedError {
    <#
    .SYNOPSIS
        Returns the EPIC_MANIFEST_UNSUPPORTED message for one frontmatter line (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [int] $LineNumber, [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Line)

    return "EPIC_MANIFEST_UNSUPPORTED: frontmatter line $LineNumber is outside the supported subset: $Line"
}

function ConvertFrom-EpicManifestFrontmatter {
    <#
    .SYNOPSIS
        Parses the manifest frontmatter of an epic.md text into an ordered dictionary.
    .DESCRIPTION
        Returns [ordered]@{ Scalar; Intent; Features }: Scalar maps each top-level key to its plain
        scalar text; Intent is $null or an ordered dictionary of plain scalars and string arrays;
        Features is an array of ordered dictionaries with issue_num, feature_folder (strings) and
        depends_on (string array). Throws EPIC_MANIFEST_UNSUPPORTED for a missing frontmatter
        boundary or any construct outside the subset.
    .PARAMETER Text
        The full epic.md text.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    [string[]] $lines = $Text -split '\r?\n'
    if ($lines.Count -lt 2 -or $lines[0] -cne '---') { throw 'EPIC_MANIFEST_UNSUPPORTED: the text does not open with a --- frontmatter line.' }
    $end = -1
    for ($index = 1; $index -lt $lines.Count; $index++) { if ($lines[$index] -ceq '---') { $end = $index; break } }
    if ($end -lt 0) { throw 'EPIC_MANIFEST_UNSUPPORTED: the frontmatter has no closing --- line.' }

    $scalar = [ordered]@{}
    $intent = $null
    $features = [System.Collections.Generic.List[object]]::new()
    $section = ''
    $listKey = $null
    $feature = $null
    for ($index = 1; $index -lt $end; $index++) {
        $line = $lines[$index]
        $number = $index + 1
        if ($line.Trim().Length -eq 0 -or $line -match '^\s*#') { continue }
        if ($line -match '^([a-z_]+):(?: (.*))?$') {
            $key = $Matches[1]
            $value = if ($Matches.Count -gt 2) { $Matches[2] } else { '' }
            $listKey = $null
            $feature = $null
            if ($value.Length -eq 0 -and $key -ceq 'intent') { $section = 'intent'; $intent = [ordered]@{}; continue }
            if ($value.Length -eq 0 -and $key -ceq 'features') { $section = 'features'; continue }
            if (-not (Test-EpicManifestPlainScalar -Value $value) -or $scalar.Contains($key)) { throw (Format-EpicManifestUnsupportedError -LineNumber $number -Line $line) }
            $section = ''
            $scalar[$key] = $value
            continue
        }
        if ($section -ceq 'intent' -and $line -match '^  ([a-z_]+):(?: (.*))?$') {
            $key = $Matches[1]
            $value = if ($Matches.Count -gt 2) { $Matches[2] } else { '' }
            if ($intent.Contains($key)) { throw (Format-EpicManifestUnsupportedError -LineNumber $number -Line $line) }
            if ($value.Length -eq 0) { $intent[$key] = [System.Collections.Generic.List[string]]::new(); $listKey = $key; continue }
            if (-not (Test-EpicManifestPlainScalar -Value $value)) { throw (Format-EpicManifestUnsupportedError -LineNumber $number -Line $line) }
            $intent[$key] = $value
            $listKey = $null
            continue
        }
        if ($section -ceq 'intent' -and $null -ne $listKey -and $line -match '^    - (.+)$') {
            if (-not (Test-EpicManifestPlainScalar -Value $Matches[1])) { throw (Format-EpicManifestUnsupportedError -LineNumber $number -Line $line) }
            $intent[$listKey].Add($Matches[1])
            continue
        }
        if ($section -ceq 'features' -and $line -match '^  - ([a-z_]+): (.+)$') {
            $feature = [ordered]@{}
            $features.Add($feature)
        } elseif (-not ($section -ceq 'features' -and $null -ne $feature -and $line -match '^    ([a-z_]+): (.+)$')) {
            throw (Format-EpicManifestUnsupportedError -LineNumber $number -Line $line)
        }
        $key = $Matches[1]
        $value = $Matches[2]
        if ($feature.Contains($key)) { throw (Format-EpicManifestUnsupportedError -LineNumber $number -Line $line) }
        if ($key -ceq 'depends_on') {
            if ($value -notmatch '^\[([^\[\]{}]*)\]$') { throw (Format-EpicManifestUnsupportedError -LineNumber $number -Line $line) }
            $items = @($Matches[1] -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_.Length -gt 0 })
            foreach ($item in $items) { if (-not (Test-EpicManifestPlainScalar -Value $item)) { throw (Format-EpicManifestUnsupportedError -LineNumber $number -Line $line) } }
            $feature[$key] = [string[]]$items
        } elseif ($key -ceq 'issue_num' -or $key -ceq 'feature_folder') {
            if (-not (Test-EpicManifestPlainScalar -Value $value)) { throw (Format-EpicManifestUnsupportedError -LineNumber $number -Line $line) }
            $feature[$key] = $value
        } else {
            throw (Format-EpicManifestUnsupportedError -LineNumber $number -Line $line)
        }
    }
    if ($null -ne $intent) {
        foreach ($key in @($intent.Keys)) { if ($intent[$key] -is [System.Collections.Generic.List[string]]) { $intent[$key] = [string[]]$intent[$key].ToArray() } }
    }
    return [ordered]@{ Scalar = $scalar; Intent = $intent; Features = [object[]]$features.ToArray() }
}

function ConvertTo-EpicManifestFinding {
    <#
    .SYNOPSIS
        Builds one manifest finding with a Code and a Message (private helper).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)] [string] $Code, [Parameter(Mandatory = $true)] [string] $Message)

    return [pscustomobject]@{ Code = $Code; Message = $Message }
}

function Get-EpicManifestSchemaFinding {
    <#
    .SYNOPSIS
        Returns the schema findings of a parsed manifest; an empty array when it conforms.
    .PARAMETER Manifest
        The dictionary returned by ConvertFrom-EpicManifestFrontmatter.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Manifest)

    $findings = [System.Collections.Generic.List[object]]::new()
    $scalar = $Manifest['Scalar']
    foreach ($key in 'epic', 'integration_branch', 'created_at') {
        if (-not $scalar.Contains($key)) { $findings.Add((ConvertTo-EpicManifestFinding -Code 'EPIC_MANIFEST_KEY_MISSING' -Message "The top-level key $key is missing.")) }
    }
    if (@($Manifest['Features']).Count -eq 0) { $findings.Add((ConvertTo-EpicManifestFinding -Code 'EPIC_MANIFEST_KEY_MISSING' -Message 'The features list is missing or empty.')) }
    if ($scalar.Contains('epic') -and $scalar.Contains('integration_branch') -and $scalar['integration_branch'] -cne "epic/$($scalar['epic'])-integration") {
        $findings.Add((ConvertTo-EpicManifestFinding -Code 'EPIC_MANIFEST_BRANCH_MISMATCH' -Message "integration_branch must be epic/$($scalar['epic'])-integration."))
    }
    if ($scalar.Contains('created_at')) {
        $parsed = [datetime]::MinValue
        $valid = $scalar['created_at'] -cmatch '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$' -and [datetime]::TryParseExact($scalar['created_at'], "yyyy-MM-dd'T'HH:mm:ss'Z'", [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AdjustToUniversal, [ref] $parsed)
        if (-not $valid) { $findings.Add((ConvertTo-EpicManifestFinding -Code 'EPIC_MANIFEST_CREATED_AT_INVALID' -Message 'created_at must be a UTC yyyy-MM-ddTHH:mm:ssZ timestamp.')) }
    }
    $intent = $Manifest['Intent']
    if ($null -ne $intent) {
        $typeValid = $intent.Contains('epic_type') -and $intent['epic_type'] -is [string] -and $intent['epic_type'] -cin @('business', 'enabler')
        $hypothesisValid = $intent.Contains('business_outcome_hypothesis') -and $intent['business_outcome_hypothesis'] -is [string] -and $intent['business_outcome_hypothesis'].Trim().Length -gt 0
        $listsValid = $true
        foreach ($key in 'leading_indicators', 'nfrs') { if ($intent.Contains($key) -and $intent[$key] -isnot [string[]]) { $listsValid = $false } }
        $unknown = @($intent.Keys | Where-Object { $_ -cnotin @('epic_type', 'business_outcome_hypothesis', 'leading_indicators', 'nfrs') })
        if (-not ($typeValid -and $hypothesisValid -and $listsValid) -or $unknown.Count -gt 0) {
            $findings.Add((ConvertTo-EpicManifestFinding -Code 'EPIC_MANIFEST_INTENT_INVALID' -Message 'intent needs epic_type business or enabler, a non-empty business_outcome_hypothesis and string lists only.'))
        }
    }
    $issueNums = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $folders = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($feature in @($Manifest['Features'])) {
        foreach ($key in 'issue_num', 'feature_folder', 'depends_on') {
            if (-not $feature.Contains($key)) { $findings.Add((ConvertTo-EpicManifestFinding -Code 'EPIC_MANIFEST_KEY_MISSING' -Message "A features entry has no $key.")) }
        }
        if ($feature.Contains('issue_num')) {
            if ($feature['issue_num'] -cnotmatch '^[1-9][0-9]*$') { $findings.Add((ConvertTo-EpicManifestFinding -Code 'EPIC_MANIFEST_ISSUE_NUM_INVALID' -Message "issue_num $($feature['issue_num']) is not a positive integer.")) }
            if (-not $issueNums.Add($feature['issue_num'])) { $findings.Add((ConvertTo-EpicManifestFinding -Code 'EPIC_MANIFEST_DUPLICATE_ISSUE_NUM' -Message "issue_num $($feature['issue_num']) is repeated.")) }
        }
        if ($feature.Contains('feature_folder') -and -not $folders.Add($feature['feature_folder'])) {
            $findings.Add((ConvertTo-EpicManifestFinding -Code 'EPIC_MANIFEST_DUPLICATE_FOLDER' -Message "feature_folder $($feature['feature_folder']) is repeated."))
        }
    }
    return [object[]]$findings.ToArray()
}

function Get-EpicManifestNodeWave {
    <#
    .SYNOPSIS
        Computes the wave of one node by memoized recursion; returns -1 on a cycle (private helper).
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)] [string] $Node,
        [Parameter(Mandatory = $true)] [hashtable] $Edge,
        [Parameter(Mandatory = $true)] [hashtable] $Memo,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.HashSet[string]] $Visiting
    )

    if ($Memo.ContainsKey($Node)) { return [int]$Memo[$Node] }
    if (-not $Visiting.Add($Node)) { return -1 }
    $wave = 0
    foreach ($dependency in @($Edge[$Node])) {
        $upstream = Get-EpicManifestNodeWave -Node $dependency -Edge $Edge -Memo $Memo -Visiting $Visiting
        if ($upstream -lt 0) { return -1 }
        $wave = [Math]::Max($wave, $upstream + 1)
    }
    [void]$Visiting.Remove($Node)
    $Memo[$Node] = $wave
    return $wave
}

function Get-EpicManifestWave {
    <#
    .SYNOPSIS
        Resolves depends_on entries and computes the wave of every features entry.
    .DESCRIPTION
        Returns @{ Wave; Findings }. Each depends_on entry is resolved through the union of the
        issue_num and feature_folder sets (EPIC_MANIFEST_UNRESOLVED_DEPENDENCY otherwise); a
        resolved self-dependency is EPIC_MANIFEST_SELF_EDGE. Only when both checks pass are waves
        computed: wave 0 for an empty depends_on, otherwise 1 + the largest upstream wave; a node
        reached while still being resolved is EPIC_MANIFEST_CYCLE. Wave maps issue_num to its wave
        and is empty when any finding exists.
    .PARAMETER Manifest
        The dictionary returned by ConvertFrom-EpicManifestFrontmatter.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Manifest)

    $findings = [System.Collections.Generic.List[object]]::new()
    $index = @{}
    foreach ($feature in @($Manifest['Features'])) {
        $index[[string]$feature['issue_num']] = [string]$feature['issue_num']
        $index[[string]$feature['feature_folder']] = [string]$feature['issue_num']
    }
    $edge = @{}
    foreach ($feature in @($Manifest['Features'])) {
        $node = [string]$feature['issue_num']
        $resolved = [System.Collections.Generic.List[string]]::new()
        foreach ($entry in @($feature['depends_on'])) {
            if (-not $index.ContainsKey([string]$entry)) { $findings.Add((ConvertTo-EpicManifestFinding -Code 'EPIC_MANIFEST_UNRESOLVED_DEPENDENCY' -Message "depends_on entry $entry of $node resolves to no features entry.")); continue }
            if ($index[[string]$entry] -ceq $node) { $findings.Add((ConvertTo-EpicManifestFinding -Code 'EPIC_MANIFEST_SELF_EDGE' -Message "$node depends on itself.")); continue }
            $resolved.Add($index[[string]$entry])
        }
        $edge[$node] = [string[]]$resolved.ToArray()
    }
    if ($findings.Count -gt 0) { return @{ Wave = @{}; Findings = [object[]]$findings.ToArray() } }
    $memo = @{}
    foreach ($node in @($edge.Keys | Sort-Object)) {
        $visiting = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        if ((Get-EpicManifestNodeWave -Node $node -Edge $edge -Memo $memo -Visiting $visiting) -lt 0) {
            return @{ Wave = @{}; Findings = [object[]]@(ConvertTo-EpicManifestFinding -Code 'EPIC_MANIFEST_CYCLE' -Message "The dependency chain of $node returns to a node still being resolved.") }
        }
    }
    return @{ Wave = $memo; Findings = [object[]]@() }
}

function Get-EpicPlannedWave {
    <#
    .SYNOPSIS
        Reads the '- Wave <n>: <issue_num list>' lines under '## Planned Waves' into issue_num to wave.
    .PARAMETER Text
        The full epic.md text.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    $planned = @{}
    $inside = $false
    foreach ($line in ($Text -split '\r?\n')) {
        if ($line -cmatch '^## ') { $inside = $line -ceq '## Planned Waves'; continue }
        if ($inside -and $line -cmatch '^- Wave ([0-9]+): (.+)$') {
            $wave = [int]$Matches[1]
            foreach ($issue in ($Matches[2] -split ',')) { $planned[$issue.Trim()] = $wave }
        }
    }
    return $planned
}

Export-ModuleMember -Function ConvertFrom-EpicManifestFrontmatter, Get-EpicManifestSchemaFinding, Get-EpicManifestWave, Get-EpicPlannedWave
