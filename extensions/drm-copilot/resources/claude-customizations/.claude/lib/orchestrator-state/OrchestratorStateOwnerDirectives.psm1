<#
.SYNOPSIS
    Validates the optional owner-directive keys of an orchestrator checkpoint (issue #1139).

.DESCRIPTION
    Applies the block rules B1-B8 to the top-level owner_directives list and the record rules
    R1-R10 to the top-level owner_directive_records list, and returns their error strings in
    entry order: block rules first, then record rules. Entry numbers are 1-based. A checkpoint
    without either key yields no error.

    The checkpoint text is parsed with System.Text.Json (JsonDocument), not with the PowerShell
    JSON-to-object cmdlet, which coerces ISO-8601 strings to DateTime values and reads property
    names case-insensitively. Properties are read through an ordinal, last-definition-wins
    enumeration, shapes are judged by ValueKind, and strings are read with GetString().

    Text that System.Text.Json cannot parse fails closed with an error whose message starts
    with OWNER_DIRECTIVE_UNEVALUABLE:.

.NOTES
    PowerShell 7+. Reads no file, starts no process, and reads no clock: the caller supplies
    the checkpoint text it has already read. Mirrored byte-identically into the bundled
    extension payload.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:UnevaluableToken = 'OWNER_DIRECTIVE_UNEVALUABLE:'
$script:DirectivesKey = 'owner_directives'
$script:RecordsKey = 'owner_directive_records'
$script:DirectiveFields = @('id', 'text', 'text_sha256', 'class', 'recorded_at', 'expires_at', 'issued_by_session')
$script:RecordFields = @('directive_id', 'class', 'outcome', 'reason', 'decided_by', 'decided_at')
$script:HonorableClasses = @('scheduling', 'merge_timing', 'extra_planner_revision', 'scope_narrowing', 'accept_nonblocking_deviation')
$script:RefusedClasses = @('gate_bypass', 'force_push', 'tag_or_publish', 'policy_or_settings_edit', 'evidence_alteration', 'unclassified')
$script:Outcomes = @('honored', 'refused')
$script:DirectiveIdPattern = '\AOD-[1-9][0-9]*\z'
$script:PositiveIntegerPattern = '\A[1-9][0-9]*\z'
$script:MinimumReasonLength = 20

# Private: the last property of an object element whose name equals Name (ordinal), so a
# duplicate key resolves to its last definition. Found is $false when there is none.
function Get-OwnerDirectiveProperty {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [System.Text.Json.JsonElement] $Element,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    $found = $false
    $value = $null
    foreach ($property in $Element.EnumerateObject()) {
        if ([string]::Equals($property.Name, $Name, [System.StringComparison]::Ordinal)) {
            $found = $true
            $value = $property.Value
        }
    }
    return [pscustomobject]@{ Found = $found; Value = $value }
}

# Private: the string value of a named property, or $null when it is absent or not a JSON string.
function Get-OwnerDirectiveString {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [System.Text.Json.JsonElement] $Element,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    $property = Get-OwnerDirectiveProperty -Element $Element -Name $Name
    if ($property.Found -and $property.Value.ValueKind -eq [System.Text.Json.JsonValueKind]::String) {
        return $property.Value.GetString()
    }
    return $null
}

# Private: whether a named property is a JSON string with non-whitespace content.
function Test-OwnerDirectiveNonEmptyString {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [System.Text.Json.JsonElement] $Element,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    return (-not [string]::IsNullOrWhiteSpace((Get-OwnerDirectiveString -Element $Element -Name $Name)))
}

# Private: parse an ISO-8601 date-time with the invariant culture, reading a zone-less value as
# UTC and adjusting an offset value to UTC. Returns $null when the text does not parse.
function ConvertFrom-OwnerDirectiveDateText {
    [CmdletBinding()]
    [OutputType([datetime])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text
    )

    $parsed = [datetime]::MinValue
    $invariant = [System.Globalization.CultureInfo]::InvariantCulture
    $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
    if ([datetime]::TryParse($Text, $invariant, $styles, [ref] $parsed)) {
        return $parsed
    }
    return $null
}

# Private: the lowercase hexadecimal SHA-256 digest of the UTF-8 bytes of Text.
function Get-OwnerDirectiveTextDigest {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text
    )

    $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($Text)
    return [System.Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
}

# Private: whether Value equals a member of Set under ordinal comparison.
function Test-OwnerDirectiveMember {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [string] $Value,
        [Parameter(Mandatory = $true)] [string[]] $Set
    )

    foreach ($member in $Set) {
        if ([string]::Equals($Value, $member, [System.StringComparison]::Ordinal)) { return $true }
    }
    return $false
}

# Private: whether a list element is an array whose every item is an object.
function Test-OwnerDirectiveObjectList {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [System.Text.Json.JsonElement] $Element
    )

    if ($Element.ValueKind -ne [System.Text.Json.JsonValueKind]::Array) { return $false }
    foreach ($item in $Element.EnumerateArray()) {
        if ($item.ValueKind -ne [System.Text.Json.JsonValueKind]::Object) { return $false }
    }
    return $true
}

# Private: whether scope is an object with a positive integer issue and non-empty branch and step.
function Test-OwnerDirectiveScope {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)] [System.Text.Json.JsonElement] $Entry
    )

    $scope = Get-OwnerDirectiveProperty -Element $Entry -Name 'scope'
    if (-not $scope.Found -or $scope.Value.ValueKind -ne [System.Text.Json.JsonValueKind]::Object) { return $false }
    $issue = Get-OwnerDirectiveProperty -Element $scope.Value -Name 'issue'
    if (-not $issue.Found -or $issue.Value.ValueKind -ne [System.Text.Json.JsonValueKind]::Number) { return $false }
    if ($issue.Value.GetRawText() -cnotmatch $script:PositiveIntegerPattern) { return $false }
    return (Test-OwnerDirectiveNonEmptyString -Element $scope.Value -Name 'branch') -and
    (Test-OwnerDirectiveNonEmptyString -Element $scope.Value -Name 'step')
}

# Private: the B2-B8 errors of one owner_directives entry, in rule order.
function Get-OwnerDirectiveEntryError {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [System.Text.Json.JsonElement] $Entry,
        [Parameter(Mandatory = $true)] [int] $Number,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.HashSet[string]] $SeenIds
    )

    $prefix = 'Checkpoint owner_directives entry #{0}' -f $Number
    foreach ($field in $script:DirectiveFields) {
        if (-not (Test-OwnerDirectiveNonEmptyString -Element $Entry -Name $field)) {
            '{0} field {1} must be a non-empty string.' -f $prefix, $field
        }
    }
    $id = Get-OwnerDirectiveString -Element $Entry -Name 'id'
    if (-not [string]::IsNullOrWhiteSpace($id)) {
        if ($id -cnotmatch $script:DirectiveIdPattern) { '{0} id must match OD-<positive integer>.' -f $prefix }
        if (-not $SeenIds.Add($id)) { '{0} id {1} is duplicated.' -f $prefix, $id }
    }
    $text = Get-OwnerDirectiveString -Element $Entry -Name 'text'
    $digest = Get-OwnerDirectiveString -Element $Entry -Name 'text_sha256'
    if (-not [string]::IsNullOrWhiteSpace($text) -and -not [string]::IsNullOrWhiteSpace($digest) -and
        -not [string]::Equals((Get-OwnerDirectiveTextDigest -Text $text), $digest, [System.StringComparison]::Ordinal)) {
        '{0} text_sha256 does not match text.' -f $prefix
    }
    $class = Get-OwnerDirectiveString -Element $Entry -Name 'class'
    if (-not [string]::IsNullOrWhiteSpace($class) -and -not (Test-OwnerDirectiveMember -Value $class -Set ($script:HonorableClasses + $script:RefusedClasses))) {
        '{0} class must be one of: {1}.' -f $prefix, (($script:HonorableClasses + $script:RefusedClasses) -join ', ')
    }
    $recordedText = Get-OwnerDirectiveString -Element $Entry -Name 'recorded_at'
    $expiresText = Get-OwnerDirectiveString -Element $Entry -Name 'expires_at'
    if (-not [string]::IsNullOrWhiteSpace($recordedText) -and -not [string]::IsNullOrWhiteSpace($expiresText)) {
        $recorded = ConvertFrom-OwnerDirectiveDateText -Text $recordedText
        $expires = ConvertFrom-OwnerDirectiveDateText -Text $expiresText
        if ($null -eq $recorded -or $null -eq $expires -or $expires -le $recorded) {
            '{0} expires_at must be a date-time later than recorded_at.' -f $prefix
        }
    }
    if (-not (Test-OwnerDirectiveScope -Entry $Entry)) {
        '{0} scope must be an object with issue, branch, and step.' -f $prefix
    }
}

# Private: the B1-B8 errors of the owner_directives value, and the directive index the record
# rules consult (the first entry per id; Class and Expires are $null when absent or unparseable).
function Get-OwnerDirectiveBlockResult {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [System.Text.Json.JsonElement] $Root
    )

    $errors = [System.Collections.Generic.List[string]]::new()
    $index = [System.Collections.Generic.Dictionary[string, pscustomobject]]::new([System.StringComparer]::Ordinal)
    $block = Get-OwnerDirectiveProperty -Element $Root -Name $script:DirectivesKey
    if (-not $block.Found) { return [pscustomobject]@{ Errors = $errors; Index = $index } }
    if (-not (Test-OwnerDirectiveObjectList -Element $block.Value) -or $block.Value.GetArrayLength() -eq 0) {
        $errors.Add('Checkpoint owner_directives must be a non-empty list of objects when present.')
        return [pscustomobject]@{ Errors = $errors; Index = $index }
    }
    $seenIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $number = 0
    foreach ($entry in $block.Value.EnumerateArray()) {
        $number++
        foreach ($message in @(Get-OwnerDirectiveEntryError -Entry $entry -Number $number -SeenIds $seenIds)) { $errors.Add($message) }
        $id = Get-OwnerDirectiveString -Element $entry -Name 'id'
        if ([string]::IsNullOrWhiteSpace($id) -or $index.ContainsKey($id)) { continue }
        $expiresText = Get-OwnerDirectiveString -Element $entry -Name 'expires_at'
        $expires = if ($null -eq $expiresText) { $null } else { ConvertFrom-OwnerDirectiveDateText -Text $expiresText }
        $index[$id] = [pscustomobject]@{ Class = (Get-OwnerDirectiveString -Element $entry -Name 'class'); Expires = $expires }
    }
    return [pscustomobject]@{ Errors = $errors; Index = $index }
}

# Private: the R2-R10 errors of one owner_directive_records entry, in rule order. HonoredCounts
# accumulates honored records per extra_planner_revision directive across the list.
function Get-OwnerDirectiveRecordError {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [System.Text.Json.JsonElement] $Record,
        [Parameter(Mandatory = $true)] [int] $Number,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.Dictionary[string, pscustomobject]] $Index,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.Dictionary[string, int]] $HonoredCounts
    )

    $prefix = 'Checkpoint owner_directive_records entry #{0}' -f $Number
    foreach ($field in $script:RecordFields) {
        if (-not (Test-OwnerDirectiveNonEmptyString -Element $Record -Name $field)) {
            '{0} field {1} must be a non-empty string.' -f $prefix, $field
        }
    }
    $directiveId = Get-OwnerDirectiveString -Element $Record -Name 'directive_id'
    $directive = $null
    if (-not [string]::IsNullOrWhiteSpace($directiveId)) {
        if ($Index.ContainsKey($directiveId)) { $directive = $Index[$directiveId] }
        else { '{0} references directive {1} that is not in owner_directives.' -f $prefix, $directiveId }
    }
    $class = Get-OwnerDirectiveString -Element $Record -Name 'class'
    if ($null -ne $directive -and -not [string]::IsNullOrWhiteSpace($class) -and
        -not [string]::Equals($class, $directive.Class, [System.StringComparison]::Ordinal)) {
        '{0} class does not match directive {1}.' -f $prefix, $directiveId
    }
    $outcome = Get-OwnerDirectiveString -Element $Record -Name 'outcome'
    if (-not [string]::IsNullOrWhiteSpace($outcome) -and -not (Test-OwnerDirectiveMember -Value $outcome -Set $script:Outcomes)) {
        '{0} outcome must be honored or refused.' -f $prefix
    }
    $honored = [string]::Equals($outcome, 'honored', [System.StringComparison]::Ordinal)
    if ($honored -and $null -ne $directive -and (Test-OwnerDirectiveMember -Value $directive.Class -Set $script:RefusedClasses)) {
        '{0} honors directive {1} of refused class {2}.' -f $prefix, $directiveId, $directive.Class
    }
    if ($honored -and $null -ne $directive -and [string]::Equals($directive.Class, 'extra_planner_revision', [System.StringComparison]::Ordinal)) {
        $count = 1
        if ($HonoredCounts.ContainsKey($directiveId)) { $count = $HonoredCounts[$directiveId] + 1 }
        $HonoredCounts[$directiveId] = $count
        if ($count -eq 2) { 'Checkpoint owner_directive_records directive {0} grants more than one extra planner revision.' -f $directiveId }
    }
    $reason = Get-OwnerDirectiveString -Element $Record -Name 'reason'
    if (-not [string]::IsNullOrWhiteSpace($reason) -and $reason.Trim().Length -lt $script:MinimumReasonLength) {
        '{0} reason must be at least {1} characters.' -f $prefix, $script:MinimumReasonLength
    }
    $decidedText = Get-OwnerDirectiveString -Element $Record -Name 'decided_at'
    if (-not [string]::IsNullOrWhiteSpace($decidedText)) {
        $decided = ConvertFrom-OwnerDirectiveDateText -Text $decidedText
        if ($null -eq $decided) { '{0} decided_at must be a date-time.' -f $prefix }
        elseif ($honored -and $null -ne $directive -and $null -ne $directive.Expires -and $decided -gt $directive.Expires) {
            '{0} honors directive {1} after its expires_at.' -f $prefix, $directiveId
        }
    }
}

# Private: the R1-R10 errors of the owner_directive_records value.
function Get-OwnerDirectiveRecordsError {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [System.Text.Json.JsonElement] $Root,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [System.Collections.Generic.Dictionary[string, pscustomobject]] $Index
    )

    $records = Get-OwnerDirectiveProperty -Element $Root -Name $script:RecordsKey
    if (-not $records.Found) { return }
    if (-not (Test-OwnerDirectiveObjectList -Element $records.Value)) {
        'Checkpoint owner_directive_records must be a list of objects when present.'
        return
    }
    $honoredCounts = [System.Collections.Generic.Dictionary[string, int]]::new([System.StringComparer]::Ordinal)
    $number = 0
    foreach ($record in $records.Value.EnumerateArray()) {
        $number++
        Get-OwnerDirectiveRecordError -Record $record -Number $number -Index $Index -HonoredCounts $honoredCounts
    }
}

function Get-OrchestratorStateOwnerDirectiveError {
    <#
    .SYNOPSIS
        Return the owner-directive rule errors (B1-B8, R1-R10) for a checkpoint's text.
    .DESCRIPTION
        Parses the text with System.Text.Json (comments skipped, trailing commas allowed) and
        returns an empty array when the root is not an object or when neither owner_directives
        nor owner_directive_records is a top-level property name (ordinal comparison of the
        decoded names). Otherwise returns the block-rule errors followed by the record-rule
        errors, in entry order. Throws an error whose message starts with
        OWNER_DIRECTIVE_UNEVALUABLE: for text System.Text.Json does not parse.
    .PARAMETER CheckpointText
        The raw checkpoint JSON text.
    .OUTPUTS
        System.String[]
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $CheckpointText
    )

    $options = [System.Text.Json.JsonDocumentOptions]::new()
    $options.CommentHandling = [System.Text.Json.JsonCommentHandling]::Skip
    $options.AllowTrailingCommas = $true
    $document = $null
    try {
        $document = [System.Text.Json.JsonDocument]::Parse($CheckpointText, $options)
    }
    catch {
        throw ('{0} the checkpoint is not parseable by System.Text.Json (a non-standard literal such as NaN or Infinity, or nesting deeper than 64 levels): {1}' -f
            $script:UnevaluableToken, $_.Exception.Message)
    }
    try {
        $root = $document.RootElement
        if ($root.ValueKind -ne [System.Text.Json.JsonValueKind]::Object) { return , [string[]] @() }
        $hasDirectives = (Get-OwnerDirectiveProperty -Element $root -Name $script:DirectivesKey).Found
        $hasRecords = (Get-OwnerDirectiveProperty -Element $root -Name $script:RecordsKey).Found
        if (-not $hasDirectives -and -not $hasRecords) { return , [string[]] @() }
        $block = Get-OwnerDirectiveBlockResult -Root $root
        $errors = [System.Collections.Generic.List[string]]::new($block.Errors)
        foreach ($message in @(Get-OwnerDirectiveRecordsError -Root $root -Index $block.Index)) { $errors.Add($message) }
        return , $errors.ToArray()
    }
    finally {
        $document.Dispose()
    }
}

Export-ModuleMember -Function Get-OrchestratorStateOwnerDirectiveError
