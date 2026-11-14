<#
.SYNOPSIS
    Finding model, deterministic finding order, command results, the -Json envelope and the
    text report for the documentation library.

.DESCRIPTION
    New-DocsFinding builds a finding with exactly the eight keys of the docs common finding
    definition and rejects arguments outside its grammar. Get-DocsOrderedFinding sorts,
    de-duplicates and bounds findings in a fixed ordinal order. New-DocsCommandResult carries the
    outcome of one subcommand; ConvertTo-DocsEnvelopeText renders it as the canonical JSON
    envelope {command, exit_code, findings, ok, result}, and ConvertTo-DocsReportText as text
    ending with the summary line.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1020. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop

# Grammar of the docs common definitions that a finding references. The (?![\s\S]) suffix keeps
# .NET from accepting a value with a trailing newline, as in the schema patterns.
$script:DocsFindingCodePattern = '^[A-Z][A-Z0-9_]*$(?![\s\S])'
$script:DocsFindingPointerPattern = '^(?:/(?:[^~/]|~[01])*)*$(?![\s\S])'
$script:DocsFindingIdentifierPattern = '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])'
# The relative-path pattern excludes U+2028 and U+2029; they are inserted from their code points
# so that this source file stays ASCII.
$script:DocsFindingRelativePathPattern = '^(?!/)(?!.*(?:^|/)\.{1,2}(?:/|$))[^/\\:\x00-\x1fSEPARATORS*?<>|]+(?:/[^/\\:\x00-\x1fSEPARATORS*?<>|]+)*$(?![\s\S])'.Replace('SEPARATORS', [string][char]0x2028 + [char]0x2029)
$script:DocsFindingSeverity = @('error', 'warning', 'info')

function Get-DocsSortedUniqueText {
    <#
    .SYNOPSIS
        Returns the distinct values sorted by ordinal comparison (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([AllowNull()] [AllowEmptyCollection()] [string[]] $Value)

    if ($null -eq $Value -or $Value.Count -eq 0) { return , [string[]]@() }
    $set = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($item in $Value) { [void]$set.Add($item) }
    return , [string[]]@($set)
}

function New-DocsFinding {
    <#
    .SYNOPSIS
        Returns one finding as an ordered hashtable with the eight docs common finding keys.
    .DESCRIPTION
        Throws when the code, severity, pointer, a related identifier, a path, the message or the
        next action is outside its grammar. Related identifiers and paths are sorted and
        de-duplicated.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state; the exported name is fixed by the issue #1020 contract.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $Severity,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Message,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $NextAction,
        [AllowNull()] [string] $ArtifactPath,
        [AllowEmptyString()] [string] $Pointer = '',
        [AllowNull()] [AllowEmptyCollection()] [string[]] $RelatedId,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $RelatedPath
    )

    if ($Code -cnotmatch $script:DocsFindingCodePattern) { throw "DOCS_FINDING_INVALID: Code '$Code' does not match $($script:DocsFindingCodePattern)." }
    if ($script:DocsFindingSeverity -cnotcontains $Severity) { throw "DOCS_FINDING_INVALID: Severity '$Severity' is not one of $($script:DocsFindingSeverity -join ', ')." }
    if ($Pointer -cnotmatch $script:DocsFindingPointerPattern) { throw "DOCS_FINDING_INVALID: Pointer '$Pointer' is not an RFC 6901 JSON pointer." }
    if ([string]::IsNullOrWhiteSpace($Message)) { throw 'DOCS_FINDING_INVALID: Message must contain a non-whitespace character.' }
    if ([string]::IsNullOrWhiteSpace($NextAction)) { throw 'DOCS_FINDING_INVALID: NextAction must contain a non-whitespace character.' }
    $path = if ([string]::IsNullOrEmpty($ArtifactPath)) { $null } else { $ArtifactPath }
    if ($null -ne $path -and $path -cnotmatch $script:DocsFindingRelativePathPattern) { throw "DOCS_FINDING_INVALID: ArtifactPath '$path' is not a relative POSIX path." }
    foreach ($candidateId in @($RelatedId)) {
        if ($null -ne $candidateId -and $candidateId -cnotmatch $script:DocsFindingIdentifierPattern) { throw "DOCS_FINDING_INVALID: RelatedId '$candidateId' is not an identifier." }
    }
    foreach ($candidatePath in @($RelatedPath)) {
        if ($null -ne $candidatePath -and $candidatePath -cnotmatch $script:DocsFindingRelativePathPattern) { throw "DOCS_FINDING_INVALID: RelatedPath '$candidatePath' is not a relative POSIX path." }
    }

    return [ordered]@{
        code          = $Code
        severity      = $Severity
        artifact_path = $path
        pointer       = $Pointer
        related_ids   = (Get-DocsSortedUniqueText -Value $RelatedId)
        related_paths = (Get-DocsSortedUniqueText -Value $RelatedPath)
        message       = $Message
        next_action   = $NextAction
    }
}

function Get-DocsChildPointer {
    <#
    .SYNOPSIS
        Appends one reference token to a JSON pointer, escaping '~' and '/' per RFC 6901.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Pointer,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [object] $Part
    )

    return $Pointer + '/' + ([string] $Part).Replace('~', '~0').Replace('/', '~1')
}

function Get-DocsFindingSortKey {
    <#
    .SYNOPSIS
        Returns the ordinal sort and identity key of one finding (private helper).
    .DESCRIPTION
        Fields are joined with U+0000 and list items with U+0001, so ordinal comparison of the key
        orders findings by artifact path, pointer, code, related identifiers, related paths,
        severity, message and next action.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Finding)

    $fieldSeparator = [string][char]0
    $itemSeparator = [string][char]1
    $parts = @(
        [string] $Finding['artifact_path'],
        [string] $Finding['pointer'],
        [string] $Finding['code'],
        (@($Finding['related_ids']) -join $itemSeparator),
        (@($Finding['related_paths']) -join $itemSeparator),
        [string] $Finding['severity'],
        [string] $Finding['message'],
        [string] $Finding['next_action']
    )
    return $parts -join $fieldSeparator
}

function Get-DocsOrderedFinding {
    <#
    .SYNOPSIS
        Sorts, de-duplicates and bounds findings in the fixed docs order.
    .DESCRIPTION
        When more than Limit distinct findings remain, the first Limit are kept and one
        FINDINGS_LIMIT error finding is appended.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyCollection()] [object[]] $Finding,
        [ValidateRange(1, 10000)] [int] $Limit = 100
    )

    $byKey = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    foreach ($item in @($Finding)) {
        if ($null -eq $item) { continue }
        $key = Get-DocsFindingSortKey -Finding $item
        if (-not $byKey.ContainsKey($key)) { $byKey[$key] = $item }
    }
    [string[]] $keys = @($byKey.Keys)
    [Array]::Sort($keys, [System.StringComparer]::Ordinal)
    $ordered = [System.Collections.Generic.List[object]]::new()
    foreach ($key in $keys) { $ordered.Add($byKey[$key]) }
    if ($ordered.Count -gt $Limit) {
        $total = $ordered.Count
        $ordered = [System.Collections.Generic.List[object]]::new($ordered.GetRange(0, $Limit))
        $ordered.Add((New-DocsFinding -Code 'FINDINGS_LIMIT' -Severity 'error' -Message "Findings were truncated to $Limit of $total." -NextAction 'Resolve the reported findings and run the command again.'))
    }
    return , $ordered.ToArray()
}

function Test-DocsFindingHasError {
    <#
    .SYNOPSIS
        Returns $true when any finding has severity error.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyCollection()] [object[]] $Finding)

    foreach ($item in @($Finding)) {
        if ($null -ne $item -and [string] $item['severity'] -ceq 'error') { return $true }
    }
    return $false
}

function New-DocsCommandResult {
    <#
    .SYNOPSIS
        Returns the outcome of one subcommand as a [pscustomobject].
    .DESCRIPTION
        Command is the subcommand name or $null (missing or unknown command). Findings are ordered
        through Get-DocsOrderedFinding with its default limit.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state; the exported name is fixed by the issue #1020 contract.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyString()] [object] $Command,
        [Parameter(Mandatory = $true)] [ValidateSet(0, 1, 2, 3)] [int] $ExitCode,
        [Parameter(Mandatory = $true)] [AllowNull()] [AllowEmptyCollection()] [object[]] $Finding,
        [AllowNull()] [object] $Result = $null,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $Line
    )

    if ($null -ne $Command -and $Command -isnot [string]) { throw 'DOCS_FINDING_INVALID: Command must be a string or $null.' }
    $name = if ([string]::IsNullOrEmpty($Command)) { $null } else { [string] $Command }
    $lines = if ($null -eq $Line) { [string[]]@() } else { [string[]]@($Line) }
    return [pscustomobject]@{
        Command  = $name
        ExitCode = $ExitCode
        Findings = (Get-DocsOrderedFinding -Finding $Finding)
        Result   = $Result
        Line     = $lines
    }
}

function ConvertTo-DocsEnvelopeText {
    <#
    .SYNOPSIS
        Returns the canonical JSON envelope {command, exit_code, findings, ok, result}.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [object] $CommandResult)

    $findings = [object[]]@(@($CommandResult.Findings) | Where-Object { $null -ne $_ })
    $envelope = [ordered]@{
        command   = $CommandResult.Command
        exit_code = [long] $CommandResult.ExitCode
        findings  = $findings
        ok        = ([int] $CommandResult.ExitCode -eq 0)
        result    = $CommandResult.Result
    }
    return ConvertTo-DocsCanonicalJson -Value $envelope
}

function ConvertTo-DocsReportText {
    <#
    .SYNOPSIS
        Returns the text report: one line per finding, the command lines, then the summary line.
    .DESCRIPTION
        A finding line is '<severity> <code> <artifact_path><pointer>: <message>' with the path
        omitted when null. The summary line is
        '<command>: exit=<n> errors=<n> warnings=<n> infos=<n>'; a missing command is shown as
        'docs'.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [object] $CommandResult)

    $lines = [System.Collections.Generic.List[string]]::new()
    $counts = @{ error = 0; warning = 0; info = 0 }
    foreach ($finding in @(@($CommandResult.Findings) | Where-Object { $null -ne $_ })) {
        $severity = [string] $finding['severity']
        $counts[$severity] = $counts[$severity] + 1
        $location = ([string] $finding['artifact_path']) + ([string] $finding['pointer'])
        $prefix = if ($location.Length -gt 0) { "$severity $($finding['code']) $location" } else { "$severity $($finding['code'])" }
        $lines.Add("${prefix}: $($finding['message'])")
    }
    foreach ($line in @($CommandResult.Line)) {
        if ($null -ne $line) { $lines.Add([string] $line) }
    }
    $name = if ([string]::IsNullOrEmpty($CommandResult.Command)) { 'docs' } else { [string] $CommandResult.Command }
    $lines.Add("${name}: exit=$($CommandResult.ExitCode) errors=$($counts['error']) warnings=$($counts['warning']) infos=$($counts['info'])")
    return ($lines -join "`n") + "`n"
}

Export-ModuleMember -Function `
    New-DocsFinding, `
    Get-DocsChildPointer, `
    Get-DocsOrderedFinding, `
    Test-DocsFindingHasError, `
    New-DocsCommandResult, `
    ConvertTo-DocsEnvelopeText, `
    ConvertTo-DocsReportText
