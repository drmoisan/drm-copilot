<#
.SYNOPSIS
    The one receipt revision rule of the documentation library: decides whether a docs-complete
    validation receipt still holds for a later head revision.

.DESCRIPTION
    Get-DocsReceiptRevisionDecision is pure: it takes strings, a nullable ancestry answer, and
    path lists, and does no git, filesystem, clock, or environment I/O. Each caller supplies the
    ancestry answer and the changed paths through its own bounded seam. It is shared by the
    validate command (DocsValidateCommands.psm1), the integration docs-complete gate
    (DocsCompleteGate.psm1 through enforce-docs-complete-gate.ps1), and the docs-estate
    delegation leg of the model-routing gate (issue #1169).

    Decision order (the first failing step decides):
      1. A blank receipt revision or head revision denies RECEIPT_REVISION_UNRESOLVED.
      2. A receipt revision that is not ordinally equal to the snapshot revision denies
         RECEIPT_REVISION_SNAPSHOT_MISMATCH.
      3. A head revision ordinally equal to the receipt revision allows; no ancestry or
         changed-path input is read.
      4. A $null ancestry answer denies RECEIPT_REVISION_UNRESOLVED with a fetch remediation.
      5. A $false ancestry answer denies RECEIPT_REVISION_NOT_ANCESTOR.
      6. A $null changed-path list denies RECEIPT_REVISION_UNRESOLVED with a fetch remediation.
      7. A changed path under a source root (ordinal, segment-anchored) denies
         RECEIPT_SOURCE_DRIFT; the message names at most $script:DocsReceiptRevisionDriftLimit
         paths and the count of the rest.
      8. Otherwise the receipt holds.

    Every deny message names the section 'Refresh After Rebase or Source Change' of the
    documentation-workflow skill.

.NOTES
    Issue #1169. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop
    (it currently imports none).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# The largest number of drifted paths a RECEIPT_SOURCE_DRIFT message names.
$script:DocsReceiptRevisionDriftLimit = 5
$script:DocsReceiptRevisionRefreshNote = 'Follow ## Refresh After Rebase or Source Change in the documentation-workflow skill, then write a new receipt.'

function Test-DocsReceiptRevisionPathUnderRoot {
    <#
    .SYNOPSIS
        Returns $true when a repository-relative path equals a source root or lies beneath it
        at a segment boundary (private helper).
    .DESCRIPTION
        Ordinal and case-sensitive. A trailing '/' on the root is ignored. The root '.' covers
        every path. A blank root covers no path.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $Path,
        [AllowNull()] [AllowEmptyString()] [string] $Root
    )

    if ([string]::IsNullOrEmpty($Path) -or [string]::IsNullOrWhiteSpace($Root)) { return $false }
    $trimmed = $Root.TrimEnd('/')
    if ($trimmed -ceq '.') { return $true }
    if ($trimmed.Length -eq 0) { return $false }
    if ([string]::Equals($Path, $trimmed, [System.StringComparison]::Ordinal)) { return $true }
    return $Path.StartsWith($trimmed + '/', [System.StringComparison]::Ordinal)
}

function New-DocsReceiptRevisionResult {
    <#
    .SYNOPSIS
        Returns one decision hashtable (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [bool] $Allow,
        [AllowNull()] [string] $Reason,
        [Parameter(Mandatory = $true)] [string] $Message
    )

    return @{ Allow = $Allow; Reason = $Reason; Message = $Message }
}

function Get-DocsReceiptRevisionDecision {
    <#
    .SYNOPSIS
        Decides whether a receipt written at ReceiptRevision still holds for HeadRevision.
    .DESCRIPTION
        Pure. See the module help for the decision order. Allow is $true only when the receipt
        revision equals the snapshot revision and either equals the head or is its ancestor with
        no changed path under a source root.
    .PARAMETER ReceiptRevision
        The revision recorded in the receipt.
    .PARAMETER SnapshotRevision
        The revision recorded in the surface inventory snapshot.
    .PARAMETER HeadRevision
        The head the receipt is checked against (the repository HEAD or a pull request head).
    .PARAMETER IsAncestor
        $true when ReceiptRevision is an ancestor of HeadRevision, $false when it is not, and
        $null when the caller could not decide (a git failure, a timeout, or a missing commit).
    .PARAMETER ChangedPath
        The repository-relative paths changed between ReceiptRevision and HeadRevision, or $null
        when the caller could not read them.
    .PARAMETER SourceRoot
        The surface_selection.source_roots entries of the profile.
    .OUTPUTS
        System.Collections.Hashtable with Allow, Reason ($null on allow), and Message.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $ReceiptRevision,
        [AllowNull()] [AllowEmptyString()] [string] $SnapshotRevision,
        [AllowNull()] [AllowEmptyString()] [string] $HeadRevision,
        [AllowNull()] [Nullable[bool]] $IsAncestor,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $ChangedPath,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $SourceRoot
    )

    $refresh = $script:DocsReceiptRevisionRefreshNote
    $fetch = 'Run git fetch origin so that both revisions are present locally, then retry.'
    if ([string]::IsNullOrWhiteSpace($ReceiptRevision) -or [string]::IsNullOrWhiteSpace($HeadRevision)) {
        return New-DocsReceiptRevisionResult -Allow $false -Reason 'RECEIPT_REVISION_UNRESOLVED' -Message "The receipt revision or the head revision is blank, so the receipt cannot be checked. $fetch $refresh"
    }
    if (-not [string]::Equals($ReceiptRevision, $SnapshotRevision, [System.StringComparison]::Ordinal)) {
        return New-DocsReceiptRevisionResult -Allow $false -Reason 'RECEIPT_REVISION_SNAPSHOT_MISMATCH' -Message "The receipt revision '$ReceiptRevision' differs from the inventory snapshot revision '$SnapshotRevision'. $refresh"
    }
    if ([string]::Equals($HeadRevision, $ReceiptRevision, [System.StringComparison]::Ordinal)) {
        return New-DocsReceiptRevisionResult -Allow $true -Reason $null -Message "The receipt revision '$ReceiptRevision' is the head revision."
    }
    if ($null -eq $IsAncestor) {
        return New-DocsReceiptRevisionResult -Allow $false -Reason 'RECEIPT_REVISION_UNRESOLVED' -Message "Whether the receipt revision '$ReceiptRevision' is an ancestor of the head '$HeadRevision' could not be decided (a git failure, a timeout, or a revision that is not present locally). $fetch $refresh"
    }
    if (-not $IsAncestor) {
        return New-DocsReceiptRevisionResult -Allow $false -Reason 'RECEIPT_REVISION_NOT_ANCESTOR' -Message "The receipt revision '$ReceiptRevision' is not an ancestor of the head '$HeadRevision', as after a rebase. $refresh"
    }
    if ($null -eq $ChangedPath) {
        return New-DocsReceiptRevisionResult -Allow $false -Reason 'RECEIPT_REVISION_UNRESOLVED' -Message "The paths changed between the receipt revision '$ReceiptRevision' and the head '$HeadRevision' could not be read. $fetch $refresh"
    }
    $drifted = [System.Collections.Generic.List[string]]::new()
    foreach ($path in $ChangedPath) {
        foreach ($root in @($SourceRoot)) {
            if (Test-DocsReceiptRevisionPathUnderRoot -Path $path -Root $root) {
                $drifted.Add($path)
                break
            }
        }
    }
    if ($drifted.Count -gt 0) {
        $limit = $script:DocsReceiptRevisionDriftLimit
        $named = @($drifted | Select-Object -First $limit)
        $rest = $drifted.Count - $named.Count
        $list = ($named | ForEach-Object { "'$_'" }) -join ', '
        $more = if ($rest -gt 0) { " and $rest more" } else { '' }
        return New-DocsReceiptRevisionResult -Allow $false -Reason 'RECEIPT_SOURCE_DRIFT' -Message "Source paths changed after the receipt revision '$ReceiptRevision': $list$more. $refresh"
    }
    return New-DocsReceiptRevisionResult -Allow $true -Reason $null -Message "The receipt revision '$ReceiptRevision' is an ancestor of the head '$HeadRevision' and no source path changed."
}

Export-ModuleMember -Function Get-DocsReceiptRevisionDecision
