<#
.SYNOPSIS
    Parse and validate the regenerate-path configuration document.

.DESCRIPTION
    Pure functions for config/orchestration-regeneration.json (issue #1156).
    ConvertFrom-RegenerationConfigText parses the text with System.Text.Json so
    that the JSON integer 1 is distinguishable from the string "1", a boolean, and
    a fractional value, converts the document into ordinal ordered dictionaries
    and arrays, and applies Get-RegenerationConfigError, which implements
    validation rules 1 through 9 of the specification in rule order. Errors
    accumulate; each names the key path it concerns.

    Every function is pure: no filesystem, process, network, or clock access. The
    file is read by the I/O adapter, which passes the text in. This module imports
    no module; were it to import one, it imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:AllowedRegenerationKey = @('command', 'paths', 'idempotency_check', 'unit_gate')

function ConvertFrom-RegenerationJsonElement {
    <#
    .SYNOPSIS
        Convert one System.Text.Json element into plain PowerShell values.

    .DESCRIPTION
        Objects become ordinal ordered dictionaries (JSON keys are case-sensitive),
        arrays become object arrays that are never unwrapped, integers without a
        fraction or exponent become Int64 (or Decimal when out of range), other
        numbers become Double, and true, false, and null map to their PowerShell
        values.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary], [object[]], [long], [decimal], [double], [bool], [string])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Text.Json.JsonElement] $Element
    )

    switch ($Element.ValueKind) {
        'Object' {
            $map = [System.Collections.Specialized.OrderedDictionary]::new([System.StringComparer]::Ordinal)
            foreach ($property in $Element.EnumerateObject()) {
                $map[$property.Name] = ConvertFrom-RegenerationJsonElement -Element $property.Value
            }
            return $map
        }
        'Array' {
            $items = [System.Collections.Generic.List[object]]::new()
            foreach ($item in $Element.EnumerateArray()) {
                $items.Add((ConvertFrom-RegenerationJsonElement -Element $item))
            }
            return , $items.ToArray()
        }
        'String' { return $Element.GetString() }
        'Number' {
            $raw = $Element.GetRawText()
            if ($raw -match '^-?[0-9]+$') {
                $integer = [long] 0
                if ($Element.TryGetInt64([ref] $integer)) { return $integer }
                return [decimal]::Parse($raw, [System.Globalization.CultureInfo]::InvariantCulture)
            }
            return $Element.GetDouble()
        }
        'True' { return $true }
        'False' { return $false }
        default { return $null }
    }
}

function Test-RegenerationNonEmptyStringArray {
    <#
    .SYNOPSIS
        Report whether a value is a non-empty array of non-empty, non-whitespace strings.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object] $Value
    )

    if ($null -eq $Value -or $Value -isnot [object[]]) { return $false }
    if ($Value.Count -eq 0) { return $false }
    foreach ($element in $Value) {
        if ($element -isnot [string]) { return $false }
        if ([string]::IsNullOrWhiteSpace($element)) { return $false }
    }
    return $true
}

function Get-RegenerationPatternError {
    <#
    .SYNOPSIS
        Return the rule-7 reason a declared path pattern is rejected, or $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $Pattern
    )

    if ($Pattern.Length -eq 0) { return 'pattern is empty' }
    if ($Pattern.StartsWith('/')) { return 'pattern begins with a forward slash' }
    if ($Pattern.Contains('\')) { return 'pattern contains a backslash' }
    if ($Pattern -match '^[A-Za-z]:') { return 'pattern begins with a drive letter and colon' }
    if ($Pattern.Contains('[') -or $Pattern.Contains(']')) { return 'pattern contains a square bracket' }
    foreach ($segment in $Pattern.Split('/')) {
        if ($segment.Length -eq 0) { return 'pattern contains an empty segment' }
        if ($segment -ceq '.') { return 'pattern contains a . segment' }
        if ($segment -ceq '..') { return 'pattern contains a .. segment' }
    }
    return $null
}

function Get-RegenerationConfigError {
    <#
    .SYNOPSIS
        Return the validation errors of a parsed regeneration config document.

    .DESCRIPTION
        Applies validation rules 1 through 9 in rule order and returns every
        violation as one error string naming its key path. A document that is not
        a dictionary violates rule 1 and no later rule is evaluated. A
        regeneration value of $null, or an absent regeneration key, carries no
        rule 4 through 9 errors.

    .PARAMETER Document
        The parsed document, as produced by ConvertFrom-RegenerationConfigText.

    .OUTPUTS
        System.String[]. The ordered error list; empty for a valid document.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object] $Document
    )

    $errors = [System.Collections.Generic.List[string]]::new()
    if ($Document -isnot [System.Collections.IDictionary]) {
        $errors.Add('(document): text does not parse as a JSON object')
        return , $errors.ToArray()
    }

    # Rule 2: version must be the JSON integer 1.
    if (-not $Document.Contains('version')) {
        $errors.Add('version: required key is absent')
    }
    else {
        $version = $Document['version']
        $isIntegerOne = ($version -is [long]) -and ($version -eq 1)
        if (-not $isIntegerOne) { $errors.Add('version: must be the JSON integer 1') }
    }

    $hasRegeneration = $Document.Contains('regeneration')
    $regeneration = if ($hasRegeneration) { $Document['regeneration'] } else { $null }

    # Rule 3: regeneration, when present, is an object or null.
    if ($hasRegeneration -and $null -ne $regeneration -and $regeneration -isnot [System.Collections.IDictionary]) {
        $errors.Add('regeneration: must be an object or null')
    }
    if ($regeneration -isnot [System.Collections.IDictionary]) {
        return , $errors.ToArray()
    }

    # Rule 4: no unknown key inside regeneration.
    foreach ($key in $regeneration.Keys) {
        if ($script:AllowedRegenerationKey -cnotcontains $key) {
            $errors.Add("regeneration.$($key): unknown key")
        }
    }

    # Rule 5: command is a non-empty array of non-empty strings.
    if (-not $regeneration.Contains('command')) {
        $errors.Add('regeneration.command: required key is absent')
    }
    elseif (-not (Test-RegenerationNonEmptyStringArray -Value $regeneration['command'])) {
        $errors.Add('regeneration.command: must be a non-empty array of non-empty strings')
    }

    # Rule 6: paths is a non-empty array of strings.
    $paths = $null
    if (-not $regeneration.Contains('paths')) {
        $errors.Add('regeneration.paths: required key is absent')
    }
    else {
        $paths = $regeneration['paths']
        if ($paths -isnot [object[]] -or $paths.Count -eq 0) {
            $errors.Add('regeneration.paths: must be a non-empty array')
            $paths = $null
        }
        else {
            for ($index = 0; $index -lt $paths.Count; $index++) {
                if ($paths[$index] -isnot [string]) {
                    $errors.Add("regeneration.paths[$index]: must be a string")
                }
            }
        }
    }

    # Rule 7: each string pattern is a safe repository-relative glob.
    if ($null -ne $paths) {
        for ($index = 0; $index -lt $paths.Count; $index++) {
            if ($paths[$index] -isnot [string]) { continue }
            $reason = Get-RegenerationPatternError -Pattern $paths[$index]
            if ($null -ne $reason) { $errors.Add("regeneration.paths[$index]: $reason") }
        }
    }

    # Rule 8: idempotency_check, when present, is a non-empty array of non-empty strings.
    if ($regeneration.Contains('idempotency_check') -and -not (Test-RegenerationNonEmptyStringArray -Value $regeneration['idempotency_check'])) {
        $errors.Add('regeneration.idempotency_check: must be a non-empty array of non-empty strings')
    }

    # Rule 9: unit_gate, when present, is a non-empty array of argv arrays.
    if ($regeneration.Contains('unit_gate')) {
        $gate = $regeneration['unit_gate']
        $isValidGate = ($gate -is [object[]]) -and ($gate.Count -gt 0)
        if ($isValidGate) {
            foreach ($argv in $gate) {
                if (-not (Test-RegenerationNonEmptyStringArray -Value $argv)) { $isValidGate = $false }
            }
        }
        if (-not $isValidGate) {
            $errors.Add('regeneration.unit_gate: must be a non-empty array of non-empty arrays of non-empty strings')
        }
    }

    return , $errors.ToArray()
}

function ConvertFrom-RegenerationConfigText {
    <#
    .SYNOPSIS
        Parse regeneration config text into its configuration and error list.

    .DESCRIPTION
        Returns an object with Config and Errors. Config is the regeneration
        object when the document holds one, otherwise $null (absent text, absent
        key, null value, or a document that does not parse). Errors is the
        ordered list returned by Get-RegenerationConfigError, or the rule-1 parse
        error. $null text means the file is absent: Config is $null and Errors is
        empty (default-off).

    .PARAMETER Text
        The config file content, or $null when the file is absent.

    .OUTPUTS
        System.Management.Automation.PSCustomObject with Config and Errors.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [object] $Text
    )

    if ($null -eq $Text) {
        return [pscustomobject]@{ Config = $null; Errors = [string[]] @() }
    }

    $document = $null
    try {
        $parsed = [System.Text.Json.JsonDocument]::Parse([string] $Text)
        try {
            $document = ConvertFrom-RegenerationJsonElement -Element $parsed.RootElement
        }
        finally {
            $parsed.Dispose()
        }
    }
    catch [System.Text.Json.JsonException] {
        $document = $null
    }

    $errors = Get-RegenerationConfigError -Document $document
    $config = $null
    if ($document -is [System.Collections.IDictionary] -and $document.Contains('regeneration')) {
        $candidate = $document['regeneration']
        if ($candidate -is [System.Collections.IDictionary]) { $config = $candidate }
    }
    return [pscustomobject]@{ Config = $config; Errors = [string[]] $errors }
}

Export-ModuleMember -Function ConvertFrom-RegenerationConfigText, Get-RegenerationConfigError
