Set-StrictMode -Version Latest

# Pure decision logic for the npm audit gate exception mechanism (issue #1204).
#
# The reusable workflow .github/workflows/_npm-audit-gate.yml runs scripts/ci/Invoke-NpmAuditGate.ps1
# for each manifest. That script reads config/npm-audit-exceptions.json, runs the production-only audit
# and the full audit, and hands the texts to Get-NpmAuditGateDecision. Every function here works on
# in-memory values only: no function reads or writes a file, reads the process environment or the
# clock, starts a process, or touches the network. Every rule fails closed: any input the gate cannot
# classify gives a failing decision.

# Failure codes; each is printed in the job log.
$script:NpmAuditGateInvalidCode = 'NPM_AUDIT_EXCEPTION_INVALID'
$script:NpmAuditGateExpiredCode = 'NPM_AUDIT_EXCEPTION_EXPIRED'
$script:NpmAuditGateProdCode = 'NPM_AUDIT_PROD_FINDING'
$script:NpmAuditGateUnexceptedCode = 'NPM_AUDIT_UNEXCEPTED_ADVISORY'
$script:NpmAuditGateUnparseableCode = 'NPM_AUDIT_OUTPUT_UNPARSEABLE'

# Severity ranks: info < low < moderate < high < critical. An unknown severity text ranks above every
# level, so an advisory that cannot be classified is never ignored.
$script:NpmAuditSeverityRank = @{ info = 0; low = 1; moderate = 2; high = 3; critical = 4 }
$script:NpmAuditUnknownSeverityRank = 99

$script:NpmAuditExceptionTopKeys = [string[]] @('version', 'exceptions')
$script:NpmAuditExceptionEntryKeys = [string[]] @('id', 'package', 'scope', 'reason', 'approved_at', 'expires')
$script:NpmAuditAdvisoryIdPattern = 'GHSA-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}'

function ConvertFrom-NpmAuditJsonElement {
    <#
    .SYNOPSIS
        Converts one System.Text.Json element to dictionaries, arrays, strings, numbers, booleans, or $null.
    .DESCRIPTION
        Strings stay strings (no date coercion). An object with a repeated property name throws, so a
        duplicate key is reported by the caller as an invalid file.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.IDictionary], [object[]], [string], [long], [double], [bool])]
    param(
        [Parameter(Mandatory = $true)][System.Text.Json.JsonElement] $Element
    )

    switch ($Element.ValueKind) {
        'Object' {
            $map = [ordered]@{}
            foreach ($property in $Element.EnumerateObject()) {
                if ($map.Contains($property.Name)) { throw "duplicate key '$($property.Name)'" }
                $map[$property.Name] = ConvertFrom-NpmAuditJsonElement -Element $property.Value
            }
            return , $map
        }
        'Array' {
            $items = [System.Collections.Generic.List[object]]::new()
            foreach ($item in $Element.EnumerateArray()) { $items.Add((ConvertFrom-NpmAuditJsonElement -Element $item)) }
            return , $items.ToArray()
        }
        'String' { return $Element.GetString() }
        'Number' {
            $whole = [long] 0
            if ($Element.TryGetInt64([ref] $whole)) { return $whole }
            return $Element.GetDouble()
        }
        'True' { return $true }
        'False' { return $false }
        default { return $null }
    }
}

function ConvertFrom-NpmAuditJsonText {
    <#
    .SYNOPSIS
        Parses JSON text into the dictionary form of ConvertFrom-NpmAuditJsonElement; throws on invalid text.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.IDictionary], [object[]], [string], [long], [double], [bool])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Text
    )

    $document = [System.Text.Json.JsonDocument]::Parse($Text)
    try {
        return , (ConvertFrom-NpmAuditJsonElement -Element $document.RootElement)
    }
    finally {
        $document.Dispose()
    }
}

function Get-NpmAuditExceptionResult {
    <#
    .SYNOPSIS
        Builds the result object of ConvertFrom-NpmAuditException.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][bool] $Valid,
        [object[]] $Entries = @(),
        [string] $Detail = ''
    )

    $errorDetail = ''
    if (-not $Valid) { $errorDetail = "$($script:NpmAuditGateInvalidCode): $Detail" }
    return [pscustomobject]@{ Valid = $Valid; Entries = [object[]] $Entries; ErrorDetail = $errorDetail }
}

function Test-NpmAuditDateText {
    <#
    .SYNOPSIS
        Returns $true when the value is a real calendar date written exactly as yyyy-MM-dd.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()][object] $Text
    )

    if ($Text -isnot [string]) { return $false }
    if ($Text -cnotmatch '^[0-9]{4}-[0-9]{2}-[0-9]{2}$') { return $false }
    $parsed = [datetime]::MinValue
    return [datetime]::TryParseExact($Text, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref] $parsed)
}

function Get-NpmAuditExceptionEntryError {
    <#
    .SYNOPSIS
        Returns the first rule violation of one exception entry as text, or an empty string when it is valid.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()][object] $Entry,
        [Parameter(Mandatory = $true)][int] $Index
    )

    $label = "exceptions[$Index]"
    if ($Entry -isnot [System.Collections.IDictionary]) { return "$label is not an object" }
    $keys = [string[]] @($Entry.Keys)
    foreach ($key in $keys) {
        if ($script:NpmAuditExceptionEntryKeys -cnotcontains $key) { return "$label has unknown key '$key'" }
    }
    foreach ($required in $script:NpmAuditExceptionEntryKeys) {
        if ($keys -cnotcontains $required) { return "$label is missing '$required'" }
        $value = $Entry[$required]
        if ($value -isnot [string] -or [string]::IsNullOrWhiteSpace($value)) { return "$label field '$required' must be a non-empty string" }
    }
    if ($Entry['id'] -cnotmatch "^$($script:NpmAuditAdvisoryIdPattern)$") { return "$label id '$($Entry['id'])' is not a GHSA id" }
    foreach ($dateKey in @('approved_at', 'expires')) {
        if (-not (Test-NpmAuditDateText -Text $Entry[$dateKey])) { return "$label field '$dateKey' is not a yyyy-MM-dd date" }
    }
    if ([string]::CompareOrdinal([string] $Entry['expires'], [string] $Entry['approved_at']) -le 0) {
        return "$label expires is not after approved_at"
    }
    return ''
}

function ConvertFrom-NpmAuditException {
    <#
    .SYNOPSIS
        Parses and validates the text of config/npm-audit-exceptions.json.
    .DESCRIPTION
        Returns Valid, Entries (Id, Package, Scope, Reason, ApprovedAt, Expires per entry), and
        ErrorDetail. Any violation of the file contract gives Valid $false and an ErrorDetail that begins
        with NPM_AUDIT_EXCEPTION_INVALID.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Json
    )

    if ([string]::IsNullOrWhiteSpace($Json)) { return Get-NpmAuditExceptionResult -Valid $false -Detail 'the exception file is blank' }
    try {
        $root = ConvertFrom-NpmAuditJsonText -Text $Json
    }
    catch {
        return Get-NpmAuditExceptionResult -Valid $false -Detail "the exception file is not valid JSON ($($_.Exception.Message))"
    }
    if ($root -isnot [System.Collections.IDictionary]) { return Get-NpmAuditExceptionResult -Valid $false -Detail 'the exception file root is not an object' }

    $topKeys = [string[]] @($root.Keys)
    foreach ($key in $topKeys) {
        if ($script:NpmAuditExceptionTopKeys -cnotcontains $key) { return Get-NpmAuditExceptionResult -Valid $false -Detail "unknown top-level key '$key'" }
    }
    foreach ($required in $script:NpmAuditExceptionTopKeys) {
        if ($topKeys -cnotcontains $required) { return Get-NpmAuditExceptionResult -Valid $false -Detail "missing top-level key '$required'" }
    }
    if ($root['version'] -isnot [long] -or $root['version'] -ne 1) { return Get-NpmAuditExceptionResult -Valid $false -Detail 'version must be 1' }
    if ($root['exceptions'] -isnot [object[]]) { return Get-NpmAuditExceptionResult -Valid $false -Detail 'exceptions must be an array' }

    $entries = [System.Collections.Generic.List[object]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $index = 0
    foreach ($entry in $root['exceptions']) {
        $entryError = Get-NpmAuditExceptionEntryError -Entry $entry -Index $index
        if ($entryError) { return Get-NpmAuditExceptionResult -Valid $false -Detail $entryError }
        if (-not $seen.Add([string] $entry['id'])) { return Get-NpmAuditExceptionResult -Valid $false -Detail "duplicate id '$($entry['id'])'" }
        $entries.Add([pscustomobject]@{
                Id         = [string] $entry['id']
                Package    = [string] $entry['package']
                Scope      = [string] $entry['scope']
                Reason     = [string] $entry['reason']
                ApprovedAt = [string] $entry['approved_at']
                Expires    = [string] $entry['expires']
            })
        $index++
    }
    return Get-NpmAuditExceptionResult -Valid $true -Entries $entries.ToArray()
}

function Get-NpmAuditSeverityRank {
    <#
    .SYNOPSIS
        Returns the rank of a severity text; an unknown or missing text ranks above every level.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [AllowNull()][AllowEmptyString()][string] $Severity
    )

    if (-not [string]::IsNullOrEmpty($Severity) -and $script:NpmAuditSeverityRank.ContainsKey($Severity)) { return [int] $script:NpmAuditSeverityRank[$Severity] }
    return $script:NpmAuditUnknownSeverityRank
}

function Get-NpmAuditAdvisoryId {
    <#
    .SYNOPSIS
        Returns the advisory id of one via object: the GHSA id in url, else the numeric source, else a placeholder.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][System.Collections.IDictionary] $Via
    )

    if ($Via.Contains('url') -and $Via['url'] -is [string]) {
        $match = [regex]::Match([string] $Via['url'], $script:NpmAuditAdvisoryIdPattern)
        if ($match.Success) { return $match.Value }
    }
    if ($Via.Contains('source') -and $null -ne $Via['source']) { return [string] $Via['source'] }
    return 'UNIDENTIFIED'
}

function Get-NpmAuditAdvisories {
    <#
    .SYNOPSIS
        Extracts the unique advisories from the text of npm audit --json.
    .DESCRIPTION
        Returns Parsed, Advisories (Id, Package, Severity per advisory), and ErrorDetail. Only object
        elements of each via array are advisories; string elements name a dependent package and are
        ignored, because the dependent is covered by the advisory object of its chain. Advisories are
        deduplicated by id. Blank text, text that is not JSON, and JSON without a vulnerabilities
        object give Parsed $false.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'The exported name is fixed by the issue #1204 spec and plan.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Json
    )

    $unparsed = { param([string] $Detail) [pscustomobject]@{ Parsed = $false; Advisories = [object[]] @(); ErrorDetail = $Detail } }
    if ([string]::IsNullOrWhiteSpace($Json)) { return & $unparsed 'the audit output is blank' }
    try {
        $root = ConvertFrom-NpmAuditJsonText -Text $Json
    }
    catch {
        return & $unparsed 'the audit output is not valid JSON'
    }
    if ($root -isnot [System.Collections.IDictionary] -or -not $root.Contains('vulnerabilities') -or $root['vulnerabilities'] -isnot [System.Collections.IDictionary]) {
        return & $unparsed 'the audit output has no vulnerabilities object'
    }

    $byId = [ordered]@{}
    foreach ($packageName in $root['vulnerabilities'].Keys) {
        $vulnerability = $root['vulnerabilities'][$packageName]
        if ($vulnerability -isnot [System.Collections.IDictionary] -or -not $vulnerability.Contains('via') -or $vulnerability['via'] -isnot [object[]]) { continue }
        foreach ($via in $vulnerability['via']) {
            if ($via -isnot [System.Collections.IDictionary]) { continue }
            $id = Get-NpmAuditAdvisoryId -Via $via
            $severity = ''
            if ($via.Contains('severity') -and $via['severity'] -is [string]) { $severity = ([string] $via['severity']).ToLowerInvariant() }
            $package = [string] $packageName
            if ($via.Contains('name') -and $via['name'] -is [string]) { $package = [string] $via['name'] }
            if (-not $byId.Contains($id)) {
                $byId[$id] = [pscustomobject]@{ Id = $id; Package = $package; Severity = $severity }
            }
            elseif ((Get-NpmAuditSeverityRank -Severity $severity) -gt (Get-NpmAuditSeverityRank -Severity $byId[$id].Severity)) {
                $byId[$id].Severity = $severity
            }
        }
    }
    return [pscustomobject]@{ Parsed = $true; Advisories = [object[]] @($byId.Values); ErrorDetail = '' }
}

function Get-NpmAuditGateResult {
    <#
    .SYNOPSIS
        Builds the decision object and its summary text.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][bool] $Passed,
        [AllowNull()][string] $Code = $null,
        [string] $Detail = '',
        [object[]] $Applied = @(),
        [object[]] $Unused = @()
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    if ($Passed) {
        $lines.Add('NPM Audit Gate: PASS')
    }
    else {
        $lines.Add("NPM Audit Gate: FAIL $($Code): $Detail")
    }
    foreach ($item in $Applied) {
        $lines.Add("Exception applied: id=$($item.Id) package=$($item.Package) scope=$($item.Scope) approved_at=$($item.ApprovedAt) expires=$($item.Expires) days_remaining=$($item.DaysRemaining) reason=$($item.Reason)")
    }
    foreach ($item in $Unused) {
        $lines.Add("Exception unused (informational): id=$($item.Id) package=$($item.Package) expires=$($item.Expires)")
    }
    return [pscustomobject]@{
        Passed      = $Passed
        Code        = $Code
        Applied     = [object[]] $Applied
        Unused      = [object[]] $Unused
        SummaryText = ($lines -join "`n")
    }
}

function Get-NpmAuditGateDecision {
    <#
    .SYNOPSIS
        Decides the gate result from the exception file, the UTC date, and the two audit results.
    .DESCRIPTION
        Evaluation order: NPM_AUDIT_EXCEPTION_INVALID, NPM_AUDIT_EXCEPTION_EXPIRED (expires strictly
        before the UTC date), NPM_AUDIT_PROD_FINDING (the production-only audit exited non-zero),
        NPM_AUDIT_OUTPUT_UNPARSEABLE (the full audit output cannot be read), NPM_AUDIT_UNEXCEPTED_ADVISORY
        (an advisory at or above the audit level that no exception covers). The first failing check
        decides the code. Returns Passed, Code, Applied (with DaysRemaining), Unused, and SummaryText.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $ExceptionJson,
        [Parameter(Mandatory = $true)][ValidatePattern('^[0-9]{4}-[0-9]{2}-[0-9]{2}$')][string] $UtcDate,
        [Parameter(Mandatory = $true)][ValidateSet('info', 'low', 'moderate', 'high', 'critical')][string] $AuditLevel,
        [Parameter(Mandatory = $true)][int] $ProductionExitCode,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $FullAuditJson
    )

    $exceptions = ConvertFrom-NpmAuditException -Json $ExceptionJson
    if (-not $exceptions.Valid) {
        return Get-NpmAuditGateResult -Passed $false -Code $script:NpmAuditGateInvalidCode -Detail $exceptions.ErrorDetail
    }
    $expired = @($exceptions.Entries | Where-Object { [string]::CompareOrdinal($_.Expires, $UtcDate) -lt 0 })
    if ($expired.Count -gt 0) {
        $names = (@($expired | ForEach-Object { "$($_.Id) (expired $($_.Expires))" })) -join ', '
        return Get-NpmAuditGateResult -Passed $false -Code $script:NpmAuditGateExpiredCode -Detail "expired exception(s) on $($UtcDate): $names"
    }
    if ($ProductionExitCode -ne 0) {
        return Get-NpmAuditGateResult -Passed $false -Code $script:NpmAuditGateProdCode -Detail "npm audit --omit=dev exited $ProductionExitCode; production dependencies carry findings at or above '$AuditLevel' and no exception applies to them"
    }
    $audit = Get-NpmAuditAdvisories -Json $FullAuditJson
    if (-not $audit.Parsed) {
        return Get-NpmAuditGateResult -Passed $false -Code $script:NpmAuditGateUnparseableCode -Detail $audit.ErrorDetail
    }

    $levelRank = Get-NpmAuditSeverityRank -Severity $AuditLevel
    $atLevel = @($audit.Advisories | Where-Object { (Get-NpmAuditSeverityRank -Severity $_.Severity) -ge $levelRank })
    $exceptionIds = [string[]] @($exceptions.Entries | ForEach-Object { $_.Id })
    $remaining = @($atLevel | Where-Object { $exceptionIds -cnotcontains $_.Id })
    $presentIds = [string[]] @($atLevel | ForEach-Object { $_.Id })

    $applied = [System.Collections.Generic.List[object]]::new()
    $unused = [System.Collections.Generic.List[object]]::new()
    $today = [datetime]::ParseExact($UtcDate, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture)
    foreach ($entry in $exceptions.Entries) {
        if ($presentIds -ccontains $entry.Id) {
            $expires = [datetime]::ParseExact($entry.Expires, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture)
            $applied.Add([pscustomobject]@{
                    Id            = $entry.Id
                    Package       = $entry.Package
                    Scope         = $entry.Scope
                    Reason        = $entry.Reason
                    ApprovedAt    = $entry.ApprovedAt
                    Expires       = $entry.Expires
                    DaysRemaining = [int] ($expires - $today).TotalDays
                })
        }
        else {
            $unused.Add($entry)
        }
    }
    if ($remaining.Count -gt 0) {
        $list = (@($remaining | ForEach-Object { "$($_.Id) ($($_.Package), $($_.Severity))" })) -join ', '
        return Get-NpmAuditGateResult -Passed $false -Code $script:NpmAuditGateUnexceptedCode -Detail "advisories at or above '$AuditLevel' with no exception: $list" -Applied $applied.ToArray() -Unused $unused.ToArray()
    }
    return Get-NpmAuditGateResult -Passed $true -Applied $applied.ToArray() -Unused $unused.ToArray()
}

Export-ModuleMember -Function ConvertFrom-NpmAuditException, Get-NpmAuditAdvisories, Get-NpmAuditGateDecision, Get-NpmAuditSeverityRank
