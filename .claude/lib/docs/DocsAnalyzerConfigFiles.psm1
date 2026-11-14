<#
.SYNOPSIS
    The config-files analyzer of issue #1022: TOML, template env, JSON Schema and YAML key paths
    as config-key elements.

.DESCRIPTION
    Invoke-DocsAnalyzerConfigFiles -CapturedInput -Selection returns @{ Elements; Diagnostics }
    (1020 analyzer contract). Get-DocsConfigFileFormat selects the format of one input: toml for
    the basename pyproject.toml, env for the four template names accepted by
    Test-DocsEnvTemplatePath (.env.example, .env.sample, .env.template and .env.dist), json-schema
    for a basename ending .schema.json or a .json input whose root $schema string contains
    json-schema.org, yaml for .yaml and .yml, and $null for every other input (including a
    non-template env-family file, which the inventory withholds before capture). Get-DocsEnvTemplateKey
    scans the env-template subset (blank and comment lines, an optional export prefix, the key
    grammar ^[A-Za-z_][A-Za-z0-9_]*$ before '=', and a quoted value that consumes lines until its
    closing quote) with ENV_LINE_UNRECOGNIZED, ENV_INVALID and ENV_KEY_DUPLICATE. TOML keys come
    from Get-DocsTomlKey restricted to tool.* without tool.poetry.scripts and the dependency
    subtrees; JSON Schema keys from Get-DocsJsonSchemaKey (JSON_INVALID for a parse finding); YAML
    keys from Get-DocsYamlKey. More than 10,000 keys in one input is CONFIG_KEY_LIMIT. Element
    properties carry key and shape names only (format, value_type, schema_type, required,
    conditional); no value is read into output. Every element is built through 1020
    New-DocsSurfaceElement -SourceText -LineRange by Select-DocsUniqueElement; this module computes
    no digest.

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
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSourceText.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsTomlKeys.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsYamlKeys.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJsonSchemaKeys.psm1') -ErrorAction Stop

$script:DocsConfigAnalyzerId = 'config-files'
$script:DocsConfigKeyLimit = 10000
$script:DocsConfigEnvTemplateNames = [string[]]@('.env.example', '.env.sample', '.env.template', '.env.dist')
$script:DocsConfigEnvKeyPattern = '^(?:export[ \t]+)?([A-Za-z_][A-Za-z0-9_]*)[ \t]*=(.*)$(?![\s\S])'

function Get-DocsConfigBaseName {
    <#
    .SYNOPSIS
        Returns the last '/'-separated segment of a path (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path)

    $slash = $Path.LastIndexOf('/')
    if ($slash -lt 0) { return $Path }
    return $Path.Substring($slash + 1)
}

function Test-DocsEnvTemplatePath {
    <#
    .SYNOPSIS
        Returns $true when the basename of Path is one of the four env template names.
    .DESCRIPTION
        Only .env.example, .env.sample, .env.template and .env.dist are read as templates
        (case-sensitive). Every other env-family file is withheld by the inventory.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Path)

    if ([string]::IsNullOrEmpty($Path)) { return $false }
    return $script:DocsConfigEnvTemplateNames -ccontains (Get-DocsConfigBaseName -Path $Path)
}

function Get-DocsConfigFileFormat {
    <#
    .SYNOPSIS
        Returns toml, env, json-schema, yaml or $null for one input path and its text.
    .DESCRIPTION
        The basename pyproject.toml is toml; a template name is env; a basename ending
        .schema.json is json-schema; another .json basename is json-schema only when Text parses
        and its root object carries a $schema string containing json-schema.org; .yaml and .yml
        are yaml. Any other input, including a non-template env-family file, is $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Path,
        [AllowNull()] [AllowEmptyString()] [string] $Text
    )

    $name = Get-DocsConfigBaseName -Path $Path
    if ($name -ceq 'pyproject.toml') { return 'toml' }
    if (Test-DocsEnvTemplatePath -Path $Path) { return 'env' }
    if ($name.EndsWith('.schema.json', [System.StringComparison]::Ordinal)) { return 'json-schema' }
    if ($name.EndsWith('.json', [System.StringComparison]::Ordinal)) {
        if ($null -eq $Text) { return $null }
        $parsed = ConvertFrom-DocsJsonText -Text $Text
        if ($parsed.Findings.Count -gt 0 -or $parsed.Value -isnot [System.Collections.IDictionary]) { return $null }
        $root = $parsed.Value
        if ($root.Contains('$schema') -and $root['$schema'] -is [string] -and ([string] $root['$schema']).Contains('json-schema.org')) { return 'json-schema' }
        return $null
    }
    if ($name.EndsWith('.yaml', [System.StringComparison]::Ordinal) -or $name.EndsWith('.yml', [System.StringComparison]::Ordinal)) { return 'yaml' }
    return $null
}

function Get-DocsEnvTemplateKey {
    <#
    .SYNOPSIS
        Returns @{ Keys; Diagnostics } for env-template text: key names with line spans, never values.
    .DESCRIPTION
        Each key is @{ Name; Span }. A blank line or a line beginning with '#' is skipped; a key
        line is an optional 'export ' prefix, a key matching ^[A-Za-z_][A-Za-z0-9_]*$, optional
        blanks and '='. A value opening with a single or double quote that does not close on its
        line consumes lines until the closing quote, so its span covers those lines and no line of
        it becomes a key; a quote still open at the end of the input is ENV_INVALID (blocking,
        Keys emptied). Any other line is ENV_LINE_UNRECOGNIZED and a repeated key is
        ENV_KEY_DUPLICATE (first occurrence kept); both are non-blocking.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [AllowNull()] [string] $Text)

    $lines = ConvertTo-DocsSourceLine -Text $Text
    $keys = [System.Collections.Generic.List[object]]::new()
    $diagnostics = [System.Collections.Generic.List[object]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $index = 0
    while ($index -lt $lines.Count) {
        $number = $index + 1
        $line = ([string] $lines[$index]).TrimStart(' ', "`t")
        $index++
        if ($line.Length -eq 0 -or $line.StartsWith('#')) { continue }
        $match = [regex]::Match($line, $script:DocsConfigEnvKeyPattern)
        if (-not $match.Success) {
            $diagnostics.Add(@{ Code = 'ENV_LINE_UNRECOGNIZED'; Severity = 'warning'; Blocking = $false; Line = $number })
            continue
        }
        $name = $match.Groups[1].Value
        $value = $match.Groups[2].Value.TrimStart(' ', "`t")
        $endLine = $number
        if ($value.Length -gt 0 -and ($value[0] -eq '"' -or $value[0] -eq "'")) {
            $quote = $value[0]
            $closed = $value.IndexOf($quote, 1) -ge 0
            while (-not $closed -and $index -lt $lines.Count) {
                $endLine = $index + 1
                $closed = ([string] $lines[$index]).IndexOf($quote) -ge 0
                $index++
            }
            if (-not $closed) {
                $diagnostics.Add(@{ Code = 'ENV_INVALID'; Severity = 'error'; Blocking = $true; Line = $number })
                return @{ Keys = [object[]]@(); Diagnostics = $diagnostics.ToArray() }
            }
        }
        if (-not $seen.Add($name)) {
            $diagnostics.Add(@{ Code = 'ENV_KEY_DUPLICATE'; Severity = 'warning'; Blocking = $false; Line = $number })
            continue
        }
        $keys.Add(@{ Name = $name; Span = [int[]]@($number, $endLine) })
    }
    return @{ Keys = $keys.ToArray(); Diagnostics = $diagnostics.ToArray() }
}

function Test-DocsConfigTomlKeyIncluded {
    <#
    .SYNOPSIS
        Returns $true when a TOML key path lies under tool.* outside the excluded subtrees (private helper).
    .DESCRIPTION
        Excluded: tool.poetry.scripts (owned by python-cli), tool.poetry.dependencies,
        tool.poetry.dev-dependencies, tool.poetry.group.<name>.dependencies and
        tool.poetry.extras, each with everything beneath it.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Segment)

    if ($Segment.Count -lt 2 -or $Segment[0] -cne 'tool') { return $false }
    if ($Segment[1] -cne 'poetry' -or $Segment.Count -lt 3) { return $true }
    if (@('scripts', 'dependencies', 'dev-dependencies', 'extras') -ccontains $Segment[2]) { return $false }
    if ($Segment[2] -ceq 'group' -and $Segment.Count -ge 5 -and $Segment[4] -ceq 'dependencies') { return $false }
    return $true
}

function Get-DocsConfigKeyScan {
    <#
    .SYNOPSIS
        Scans one input of a known format; returns @{ Keys (Segment, Span, Property); Diagnostics } (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $Format,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text
    )

    $keys = [System.Collections.Generic.List[object]]::new()
    $diagnostics = [System.Collections.Generic.List[object]]::new()
    switch ($Format) {
        'toml' {
            $scan = Get-DocsTomlKey -Text $Text
            foreach ($entry in $scan['Diagnostics']) { $diagnostics.Add($entry) }
            foreach ($key in $scan['Keys']) {
                [string[]] $segment = @($key['Segment'])
                if (-not (Test-DocsConfigTomlKeyIncluded -Segment $segment)) { continue }
                $keys.Add(@{ Segment = $segment; Span = $key['Span']; Property = @{ format = 'toml'; value_type = [string] $key['ValueType'] } })
            }
        }
        'env' {
            $scan = Get-DocsEnvTemplateKey -Text $Text
            foreach ($entry in $scan['Diagnostics']) { $diagnostics.Add($entry) }
            foreach ($key in $scan['Keys']) { $keys.Add(@{ Segment = [string[]]@($key['Name']); Span = $key['Span']; Property = @{ format = 'env' } }) }
        }
        'json-schema' {
            $parsed = ConvertFrom-DocsJsonText -Text $Text
            if ($parsed.Findings.Count -gt 0 -or $parsed.Value -isnot [System.Collections.IDictionary]) {
                $diagnostics.Add(@{ Code = 'JSON_INVALID'; Severity = 'error'; Blocking = $true; Line = 1 })
                break
            }
            $scan = Get-DocsJsonSchemaKey -Value $parsed.Value -MemberSpan (Get-DocsJsonMemberSpan -Text $Text)
            foreach ($entry in $scan['Diagnostics']) { $diagnostics.Add($entry) }
            foreach ($key in $scan['Keys']) {
                $property = @{ format = 'json-schema'; required = [bool] $key['Required'] }
                if ($null -ne $key['SchemaType']) { $property['schema_type'] = [string] $key['SchemaType'] }
                if ($key['Conditional']) { $property['conditional'] = $true }
                $keys.Add(@{ Segment = [string[]]@($key['Segment']); Span = $key['Span']; Property = $property })
            }
        }
        'yaml' {
            $scan = Get-DocsYamlKey -Text $Text
            foreach ($entry in $scan['Diagnostics']) { $diagnostics.Add($entry) }
            foreach ($key in $scan['Keys']) { $keys.Add(@{ Segment = [string[]]@($key['Segment']); Span = $key['Span']; Property = @{ format = 'yaml'; value_type = [string] $key['ValueType'] } }) }
        }
        default { throw "DOCS_CONFIG_FORMAT_UNKNOWN: '$Format' is not a config-files format." }
    }
    return @{ Keys = $keys.ToArray(); Diagnostics = $diagnostics.ToArray() }
}

function Invoke-DocsAnalyzerConfigFiles {
    <#
    .SYNOPSIS
        Runs the config-files scanner over the captured inputs and returns @{ Elements; Diagnostics }.
    .DESCRIPTION
        Selection is the analyzer selection record of the 1020 contract ($null or a dictionary);
        this analyzer reads no member of it. An input whose format is $null, whose text is $null
        or that carries a blocking diagnostic contributes no element; CONFIG_KEY_LIMIT (blocking)
        applies above 10,000 keys in one input.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'The exported name is fixed by the issue #1022 analyzer registration contract (config-files).')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $CapturedInput,
        [Parameter(Mandatory = $true)] [AllowNull()] [object] $Selection
    )

    if ($null -ne $Selection -and $Selection -isnot [System.Collections.IDictionary]) { throw 'DOCS_ANALYZER_SELECTION_INVALID: Selection must be $null or a dictionary.' }
    $aggregate = New-DocsDiagnosticAggregate
    [object[]] $inputs = @($CapturedInput | Where-Object { $null -ne $_ -and $null -ne $_['text'] })
    [string[]] $inputKeys = @($inputs | ForEach-Object { [string] $_['path'] })
    [Array]::Sort($inputKeys, $inputs, [System.StringComparer]::Ordinal)
    $candidates = [System.Collections.Generic.List[object]]::new()
    foreach ($captured in $inputs) {
        $path = [string] $captured['path']
        $text = [string] $captured['text']
        $format = Get-DocsConfigFileFormat -Path $path -Text $text
        if ($null -eq $format) { continue }
        $scan = Get-DocsConfigKeyScan -Format $format -Text $text
        $blocked = $false
        foreach ($entry in $scan['Diagnostics']) {
            Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsConfigAnalyzerId -Code $entry['Code'] -Path $path -Line ([int] $entry['Line']) -Severity ([string] $entry['Severity'])
            if ($entry['Blocking']) { $blocked = $true }
        }
        if ($blocked) { continue }
        if ($scan['Keys'].Count -gt $script:DocsConfigKeyLimit) {
            Add-DocsDiagnosticOccurrence -Aggregate $aggregate -AnalyzerId $script:DocsConfigAnalyzerId -Code 'CONFIG_KEY_LIMIT' -Path $path -Line 1 -Severity 'error'
            continue
        }
        foreach ($key in $scan['Keys']) {
            [string[]] $segment = $key['Segment']
            $candidates.Add(@{
                    Line      = [int] $key['Span'][0]
                    Parameter = @{
                        Kind           = 'config-key'
                        Path           = $path
                        Declaration    = (ConvertTo-DocsKeyPathDeclaration -Segment $segment)
                        Name           = $segment[$segment.Count - 1]
                        AnalyzerId     = $script:DocsConfigAnalyzerId
                        AnalysisMethod = 'scanner'
                        SourceText     = $text
                        ParentId       = $null
                        LineRange      = (ConvertTo-DocsLineRange -Span @(, $key['Span']))
                        Property       = $key['Property']
                    }
                })
        }
    }
    $elements = Select-DocsUniqueElement -Candidate $candidates.ToArray() -Aggregate $aggregate
    return @{ Elements = [object[]]@($elements); Diagnostics = [object[]]@($aggregate.Diagnostics) }
}

Export-ModuleMember -Function Invoke-DocsAnalyzerConfigFiles, Get-DocsConfigFileFormat, Test-DocsEnvTemplatePath, Get-DocsEnvTemplateKey
