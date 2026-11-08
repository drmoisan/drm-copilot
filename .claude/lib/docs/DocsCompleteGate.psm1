<#
.SYNOPSIS
    Pure predicates of the opt-in docs-complete merge gate: the profile switch, the receipt path,
    the integration-to-main target test, and the persisted validation receipt check.

.DESCRIPTION
    Every function takes strings only and is pure: no filesystem, clock, process, environment or
    module-scope mutable state. The hook enforce-docs-complete-gate.ps1 reads the profile and the
    receipt through its own seams and passes their text here.

    Get-DocsCompleteGateEnabled returns @{ Enabled; Reason; Message }: Reason is $null or
    PROFILE_UNREADABLE. Get-DocsCompleteGateReceiptPath returns @{ Path; Reason; Message }: Reason
    is $null or RECEIPT_PATH_INVALID. Test-DocsCompleteGateIntegrationTarget returns a boolean.
    Test-DocsCompleteGateReceipt returns @{ Allow; Reason; Message } with the first failing reason
    in the order RECEIPT_ABSENT, RECEIPT_UNREADABLE, RECEIPT_MODE, RECEIPT_FAILING,
    RECEIPT_REVISION_MISMATCH, or Allow $true with Reason 'pass'.

    The module imports only DocsJson.psm1 and DocsSurface.psm1, whose closure holds no runtime
    import, so the hook that imports it satisfies the hook dependency-guard rules.

.NOTES
    Issue #1034. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

function Get-DocsCompleteGateMember {
    <#
    .SYNOPSIS
        Returns the value at a member path of nested dictionaries, or $null when any step is absent
        (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [AllowNull()] [object] $Value,
        [Parameter(Mandatory = $true)] [string[]] $Name
    )

    $current = $Value
    foreach ($step in $Name) {
        if ($current -isnot [System.Collections.IDictionary] -or -not $current.Contains($step)) { return $null }
        $current = $current[$step]
    }
    return $current
}

function ConvertFrom-DocsCompleteGateText {
    <#
    .SYNOPSIS
        Parses JSON text into a dictionary, or returns $null for any parse finding or a
        non-object document (private helper).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.IDictionary])]
    param([AllowNull()] [AllowEmptyString()] [string] $Text)

    $parsed = ConvertFrom-DocsJsonText -Text $Text
    if (@($parsed.Findings).Count -gt 0 -or $parsed.Value -isnot [System.Collections.IDictionary]) { return $null }
    return $parsed.Value
}

function Get-DocsCompleteGateEnabled {
    <#
    .SYNOPSIS
        Returns whether the profile enables the integration pull-request gate.
    .DESCRIPTION
        $null text (no profile) is disabled. completion_gates.integration_pr_gate.enabled equal to
        the JSON boolean true is enabled; an absent member or any other value is disabled. Text
        that does not parse, holds a duplicate key, or is not a JSON object returns Reason
        PROFILE_UNREADABLE with Enabled $false.
    .PARAMETER ProfileText
        The profile text, or $null when the profile file is absent.
    .OUTPUTS
        System.Collections.Hashtable with Enabled, Reason and Message.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([AllowNull()] [object] $ProfileText)

    if ($null -eq $ProfileText) { return @{ Enabled = $false; Reason = $null; Message = 'No documentation profile exists; the gate is disabled.' } }
    $profileValue = ConvertFrom-DocsCompleteGateText -Text $ProfileText
    if ($null -eq $profileValue) {
        return @{ Enabled = $false; Reason = 'PROFILE_UNREADABLE'; Message = 'The documentation profile is not a readable JSON object (malformed text or a duplicate key); correct the profile.' }
    }
    $enabled = Get-DocsCompleteGateMember -Value $profileValue -Name @('completion_gates', 'integration_pr_gate', 'enabled')
    if ($enabled -is [bool] -and $enabled) { return @{ Enabled = $true; Reason = $null; Message = 'The integration pull-request gate is enabled.' } }
    return @{ Enabled = $false; Reason = $null; Message = 'The integration pull-request gate is disabled.' }
}

function Get-DocsCompleteGateReceiptPath {
    <#
    .SYNOPSIS
        Returns the repository-relative validation receipt path named by the profile.
    .DESCRIPTION
        Reads artifact_paths.validation_receipt. A value that Test-DocsRelativePath accepts is
        returned as Path; an absent, non-string or invalid value, or unreadable profile text,
        returns Reason RECEIPT_PATH_INVALID with Path $null.
    .PARAMETER ProfileText
        The profile text.
    .OUTPUTS
        System.Collections.Hashtable with Path, Reason and Message.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([AllowNull()] [AllowEmptyString()] [string] $ProfileText)

    $profileValue = ConvertFrom-DocsCompleteGateText -Text $ProfileText
    $path = Get-DocsCompleteGateMember -Value $profileValue -Name @('artifact_paths', 'validation_receipt')
    if ($path -is [string] -and (Test-DocsRelativePath -Path $path)) { return @{ Path = $path; Reason = $null; Message = $null } }
    return @{ Path = $null; Reason = 'RECEIPT_PATH_INVALID'; Message = 'The profile member artifact_paths.validation_receipt is absent or is not a repository-relative path; correct the profile.' }
}

function Test-DocsCompleteGateIntegrationTarget {
    <#
    .SYNOPSIS
        Returns $true when a pull request merges an epic integration branch into main.
    .DESCRIPTION
        The base must be ordinally 'main' and the head must match
        ^epic/[A-Za-z0-9][A-Za-z0-9._-]*-integration$.
    .PARAMETER BaseRefName
        The pull request base branch name.
    .PARAMETER HeadRefName
        The pull request head branch name.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $BaseRefName,
        [AllowNull()] [AllowEmptyString()] [string] $HeadRefName
    )

    if (-not [string]::Equals($BaseRefName, 'main', [System.StringComparison]::Ordinal)) { return $false }
    return ($null -ne $HeadRefName) -and ($HeadRefName -cmatch '^epic/[A-Za-z0-9][A-Za-z0-9._-]*-integration$(?![\s\S])')
}

function Test-DocsCompleteGateReceipt {
    <#
    .SYNOPSIS
        Checks the persisted validation receipt against the pull request head revision.
    .DESCRIPTION
        Returns the first failing reason: RECEIPT_ABSENT ($null text), RECEIPT_UNREADABLE (text
        that does not parse as an object, or artifact_kind other than docs-validation-receipt),
        RECEIPT_MODE (mode other than docs-complete), RECEIPT_FAILING (validation_result other
        than pass), RECEIPT_REVISION_MISMATCH (revision not ordinally equal to HeadRevision; the
        message names both revisions). Otherwise Allow is $true and Reason is 'pass'.
    .PARAMETER ReceiptText
        The receipt text, or $null when no file exists at the receipt path.
    .PARAMETER HeadRevision
        The pull request head revision (headRefOid).
    .OUTPUTS
        System.Collections.Hashtable with Allow, Reason and Message.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [object] $ReceiptText,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $HeadRevision
    )

    if ($null -eq $ReceiptText) { return @{ Allow = $false; Reason = 'RECEIPT_ABSENT'; Message = 'No validation receipt exists; run Invoke-DocsCommand.ps1 -Command validate -Mode docs-complete with -Revision and -WriteReceipt for the pull request head.' } }
    $receipt = ConvertFrom-DocsCompleteGateText -Text $ReceiptText
    if ($null -eq $receipt -or -not [string]::Equals([string] (Get-DocsCompleteGateMember -Value $receipt -Name @('artifact_kind')), 'docs-validation-receipt', [System.StringComparison]::Ordinal)) {
        return @{ Allow = $false; Reason = 'RECEIPT_UNREADABLE'; Message = 'The validation receipt is not a readable docs-validation-receipt document; regenerate it with validate -WriteReceipt.' }
    }
    if (-not [string]::Equals([string] (Get-DocsCompleteGateMember -Value $receipt -Name @('mode')), 'docs-complete', [System.StringComparison]::Ordinal)) {
        return @{ Allow = $false; Reason = 'RECEIPT_MODE'; Message = 'The validation receipt was not produced in docs-complete mode; run validate -Mode docs-complete -WriteReceipt.' }
    }
    if (-not [string]::Equals([string] (Get-DocsCompleteGateMember -Value $receipt -Name @('validation_result')), 'pass', [System.StringComparison]::Ordinal)) {
        return @{ Allow = $false; Reason = 'RECEIPT_FAILING'; Message = 'The validation receipt records a failing validation; resolve its findings and regenerate the receipt.' }
    }
    $revision = [string] (Get-DocsCompleteGateMember -Value $receipt -Name @('revision'))
    if (-not [string]::Equals($revision, $HeadRevision, [System.StringComparison]::Ordinal)) {
        return @{ Allow = $false; Reason = 'RECEIPT_REVISION_MISMATCH'; Message = "The validation receipt revision '$revision' differs from the pull request head revision '$HeadRevision'; regenerate the receipt for the pull request head." }
    }
    return @{ Allow = $true; Reason = 'pass'; Message = 'The validation receipt passes for the pull request head.' }
}

Export-ModuleMember -Function `
    Get-DocsCompleteGateEnabled, `
    Get-DocsCompleteGateReceiptPath, `
    Test-DocsCompleteGateIntegrationTarget, `
    Test-DocsCompleteGateReceipt
