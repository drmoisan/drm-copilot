<#
.SYNOPSIS
    Parses and validates owner-directive decisions and coordinator-ledger appends (issue #1157).

.DESCRIPTION
    A worker records one decision per directive as one line, in a decision file or in its final
    message:

        OWNER-DIRECTIVE-DECISION: <id> | <class> | <honored|refused> | <decided_at|-> | <reason>

    ConvertFrom-OwnerDirectiveDecisionLine parses that line with an anchored pattern, and
    Test-OwnerDirectiveDecision applies the write-time rules: the class matches the directive
    (R4), a refused class is never honored (R6), an honored decision is not later than the
    directive's expires_at (R10), decided_at is not later than the supplied time, and the reason
    is at least 20 characters after trimming (R8). The module also composes decision-file paths,
    computes the pending set, validates an agent id, and checks that a ledger write keeps every
    existing line as an unchanged prefix and appends only B2-B8-valid lines.

.NOTES
    PowerShell 7+. Reads no clock, no file, and starts no process. Mirrored byte-identically
    into the bundled extension payload.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'OrchestratorStateOwnerDirectives.psm1') -ErrorAction Stop

$script:DecisionPattern = '\AOWNER-DIRECTIVE-DECISION: (OD-[1-9][0-9]*) \| ([a-z_]+) \| (honored|refused) \| (\S+) \| (.+)\z'
$script:AgentIdPattern = '\A[A-Za-z0-9][A-Za-z0-9._-]*\z'
$script:DecisionDirectory = 'artifacts/orchestration/owner-directive-decisions'
$script:MinimumReasonLength = 20
$script:NoDecidedAt = '-'

# Private: parse an ISO 8601 date-time with the invariant culture, read as UTC when it has no
# offset; any other text returns $null. The shape matches the B7 parse of the sibling module.
function ConvertFrom-OwnerDirectiveDecisionDate {
    [CmdletBinding()]
    [OutputType([datetime])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    $isoShape = '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\.[0-9]+)?)?(Z|[+-][0-9]{2}:[0-9]{2})?\z'
    if ($Text -cnotmatch $isoShape) { return $null }
    $parsed = [datetime]::MinValue
    $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
    if ([datetime]::TryParse($Text, [System.Globalization.CultureInfo]::InvariantCulture, $styles, [ref] $parsed)) { return $parsed }
    return $null
}

function ConvertFrom-OwnerDirectiveDecisionLine {
    <#
    .SYNOPSIS
        Parse one decision line, or return $null when it does not match the grammar.
    .DESCRIPTION
        Returns Id, Class, Outcome, DecidedAt (the recorded text, or '-'), and Reason (the rest of
        the line, which may contain '|'). Leading or trailing text outside the pattern, a missing
        field, an id outside OD-<positive integer>, and an outcome other than honored or refused
        return $null.
    .PARAMETER Line
        The line, without a line terminator.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()] [AllowEmptyString()] [string] $Line)

    if ($null -eq $Line) { return $null }
    $match = [regex]::Match($Line, $script:DecisionPattern)
    if (-not $match.Success) { return $null }
    return [pscustomobject]@{
        Id        = $match.Groups[1].Value
        Class     = $match.Groups[2].Value
        Outcome   = $match.Groups[3].Value
        DecidedAt = $match.Groups[4].Value
        Reason    = $match.Groups[5].Value
    }
}

function Test-OwnerDirectiveDecision {
    <#
    .SYNOPSIS
        Return the write-time rule errors of a parsed decision against its directive.
    .DESCRIPTION
        Returns an empty array when the decision is valid. Each rule has its own message.
    .PARAMETER Decision
        The ConvertFrom-OwnerDirectiveDecisionLine result, or $null for an unparseable line.
    .PARAMETER Directive
        The selected entry the decision answers (Id, Class, IsRefusedClass, ExpiresAt).
    .PARAMETER Now
        The time decided_at may not exceed.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [AllowNull()] [object] $Decision,
        [Parameter(Mandatory = $true)] [object] $Directive,
        [Parameter(Mandatory = $true)] [datetime] $Now
    )

    if ($null -eq $Decision) {
        return [string[]] @('the decision line does not match OWNER-DIRECTIVE-DECISION: <id> | <class> | <honored|refused> | <decided_at|-> | <reason>.')
    }
    $errors = [System.Collections.Generic.List[string]]::new()
    if (-not [string]::Equals($Decision.Id, [string] $Directive.Id, [System.StringComparison]::Ordinal)) {
        $errors.Add(('the decision names {0} but answers directive {1}.' -f $Decision.Id, $Directive.Id))
    }
    if (-not [string]::Equals($Decision.Class, [string] $Directive.Class, [System.StringComparison]::Ordinal)) {
        $errors.Add(('R4: class {0} does not match directive {1} class {2}.' -f $Decision.Class, $Directive.Id, $Directive.Class))
    }
    $honored = [string]::Equals($Decision.Outcome, 'honored', [System.StringComparison]::Ordinal)
    if ($honored -and [bool] $Directive.IsRefusedClass) {
        $errors.Add(('R6: directive {0} of refused class {1} accepts only refused.' -f $Directive.Id, $Directive.Class))
    }
    if (-not [string]::Equals($Decision.DecidedAt, $script:NoDecidedAt, [System.StringComparison]::Ordinal)) {
        $decided = ConvertFrom-OwnerDirectiveDecisionDate -Text $Decision.DecidedAt
        if ($null -eq $decided) {
            $errors.Add(('decided_at {0} must be an ISO 8601 UTC date-time or -.' -f $Decision.DecidedAt))
        }
        else {
            $expires = ConvertFrom-OwnerDirectiveDecisionDate -Text ([string] $Directive.ExpiresAt)
            if ($honored -and $null -ne $expires -and $decided -gt $expires) {
                $errors.Add(('R10: an honored decision at {0} is later than expires_at {1} of directive {2}.' -f $Decision.DecidedAt, $Directive.ExpiresAt, $Directive.Id))
            }
            if ($decided -gt $Now.ToUniversalTime()) {
                $errors.Add(('decided_at {0} is later than the hook clock {1}.' -f $Decision.DecidedAt, $Now.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ', [System.Globalization.CultureInfo]::InvariantCulture)))
            }
        }
    }
    if ($Decision.Reason.Trim().Length -lt $script:MinimumReasonLength) {
        $errors.Add(('R8: the reason must be at least {0} characters after trimming.' -f $script:MinimumReasonLength))
    }
    return $errors.ToArray()
}

function Get-OwnerDirectiveDecisionPath {
    <#
    .SYNOPSIS
        Compose the decision-file path of one directive for one agent beneath an item root.
    .PARAMETER ItemRoot
        The item worktree root.
    .PARAMETER AgentId
        The deciding agent id.
    .PARAMETER Id
        The directive id.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [string] $ItemRoot,
        [Parameter(Mandatory = $true)] [string] $AgentId,
        [Parameter(Mandatory = $true)] [string] $Id
    )

    return (Join-Path (Join-Path (Join-Path $ItemRoot $script:DecisionDirectory) $AgentId) ($Id + '.md'))
}

function Get-OwnerDirectivePendingSet {
    <#
    .SYNOPSIS
        Return the selected entries whose id has no decision file yet.
    .PARAMETER Selected
        Selected entries.
    .PARAMETER ExistingDecisionId
        The directive ids whose decision files exist for the agent.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Selected,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $ExistingDecisionId
    )

    $existing = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($id in @($ExistingDecisionId | Where-Object { $_ })) { $null = $existing.Add($id) }
    return [object[]] @($Selected | Where-Object { -not $existing.Contains([string] $_.Id) })
}

function Test-OwnerDirectiveAgentId {
    <#
    .SYNOPSIS
        Return $true when an agent id is safe to use as one path segment.
    .PARAMETER AgentId
        The payload agent_id.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] [AllowEmptyString()] [string] $AgentId)

    if ([string]::IsNullOrEmpty($AgentId)) { return $false }
    return ($AgentId -cmatch $script:AgentIdPattern)
}

# Private: the physical lines of a text with CRLF normalized, without the empty element a
# trailing terminator leaves.
function Get-OwnerDirectiveLedgerLine {
    [CmdletBinding()]
    [OutputType([string[]])]
    param([AllowNull()] [AllowEmptyString()] [string] $Text)

    if ([string]::IsNullOrEmpty($Text)) { return [string[]] @() }
    $lines = [System.Collections.Generic.List[string]]::new([string[]] ($Text.Replace("`r`n", "`n") -split "`n"))
    if ($lines.Count -gt 0 -and $lines[$lines.Count - 1] -eq '') { $lines.RemoveAt($lines.Count - 1) }
    return $lines.ToArray()
}

function Test-OwnerDirectiveLedgerAppend {
    <#
    .SYNOPSIS
        Return the errors of a ledger write, or an empty array when it is a valid append.
    .DESCRIPTION
        Every existing line must remain, unchanged and in order, as a prefix of the new lines, and
        every appended non-blank line must pass B2-B8 (duplicates are judged across the whole
        ledger) through Get-OrchestratorStateOwnerDirectiveValidEntry.
    .PARAMETER ExistingText
        The current ledger text, or $null when the ledger does not exist.
    .PARAMETER NewText
        The full text the write would leave.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $ExistingText,
        [AllowNull()] [AllowEmptyString()] [string] $NewText
    )

    $existing = @(Get-OwnerDirectiveLedgerLine -Text $ExistingText)
    $new = @(Get-OwnerDirectiveLedgerLine -Text $NewText)
    if ($new.Count -lt $existing.Count) {
        return [string[]] @(('the write removes existing ledger lines: {0} lines remain of {1}.' -f $new.Count, $existing.Count))
    }
    for ($index = 0; $index -lt $existing.Count; $index++) {
        if (-not [string]::Equals($existing[$index], $new[$index], [System.StringComparison]::Ordinal)) {
            return [string[]] @(('the write changes existing ledger line #{0}.' -f ($index + 1)))
        }
    }
    $validity = Get-OrchestratorStateOwnerDirectiveValidEntry -Text ($new -join "`n")
    $errors = [System.Collections.Generic.List[string]]::new()
    for ($position = 0; $position -lt $validity.Errors.Count; $position++) {
        if ($validity.ErrorNumber[$position] -gt $existing.Count) { $errors.Add($validity.Errors[$position]) }
    }
    return $errors.ToArray()
}

Export-ModuleMember -Function `
    ConvertFrom-OwnerDirectiveDecisionLine, `
    Test-OwnerDirectiveDecision, `
    Get-OwnerDirectiveDecisionPath, `
    Get-OwnerDirectivePendingSet, `
    Test-OwnerDirectiveAgentId, `
    Test-OwnerDirectiveLedgerAppend
