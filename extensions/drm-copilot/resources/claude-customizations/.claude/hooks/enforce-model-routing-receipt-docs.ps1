<#
.SYNOPSIS
    Docs-estate delegation leg of the model-routing gate (issue #1169).

.DESCRIPTION
    Dot-sourced by enforce-model-routing-receipt.ps1. Invoke-ModelRoutingReceiptDecision calls
    Get-ModelRoutingDocsEstateDecision only for an Agent(pr-author) delegation whose resolved
    worktree holds no checkpoint, after the cleanup exemption has declined. The leg lets a
    checkpoint-free documentation run delegate the pull request. It never throws: any error
    answers Allowed $false with an empty DenySuffix.

    Conditions, in order (the first failure denies):
      1. Labels  - the prompt carries exactly one line-anchored 'branch: <name>' line and exactly
                   one 'base: <branch>' line, each a conservative branch spelling without '..'
                   (Get-DocsEstateDelegationLabel). The base is explicit, so an epic integration
                   branch is accepted.
      2. Profile - the docs profile beneath R is structurally valid.
      3. Diff    - refs/remotes/origin/<base> and HEAD resolve in R, and the
                   refs/remotes/origin/<base>...HEAD diff (--name-only -z --no-renames
                   --no-relative) is readable, NUL-terminated, non-empty, and entirely in the docs
                   path set.
      4. Receipt - the receipt at artifact_paths.validation_receipt beneath R is a
                   docs-validation-receipt in docs-complete mode with validation_result pass, and
                   Get-DocsReceiptRevisionDecision allows it against the HEAD of R, with the
                   inventory snapshot revision and surface_selection.source_roots read beneath R.

    Every git call runs through Invoke-DocsOnlyGitExe, which is bounded and never throws; a
    timeout or a non-zero exit is a denial. DenySuffix is empty when no profile file exists beneath
    R, so the existing deny text is unchanged; otherwise it is
    ' Docs-estate delegation leg not applied: <SUB_CODE>: <detail>' with one of
    DOCS_DELEGATION_LABEL_INVALID, DOCS_DELEGATION_PROFILE_INVALID,
    DOCS_DELEGATION_DIFF_UNREADABLE, DOCS_DELEGATION_DIFF_EMPTY, DOCS_DELEGATION_PATH_NOT_ALLOWED,
    DOCS_DELEGATION_RECEIPT_INVALID, or a reason code of the receipt revision rule.

.NOTES
    PowerShell 7+. Claude only; mirrored byte-identically under
    extensions/drm-copilot/resources/claude-customizations/. A policy-level control, not a security
    boundary. Call-time dependency: Test-CleanupConsolidationRelativePath (hook-cleanup-context.ps1,
    which the gate loads).
#>

try { . (Join-Path $PSScriptRoot 'hook-docs-estate-context.ps1') } catch { Add-HookDependencyFailure -Name 'hook-docs-estate-context.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'hook-docs-only-diff.ps1') } catch { Add-HookDependencyFailure -Name 'hook-docs-only-diff.ps1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/docs/DocsReceiptRevision.psm1') -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'DocsReceiptRevision.psm1' -ErrorRecord $_ }

function Get-ModelRoutingDocsEstateFileText {
    <#
    .SYNOPSIS
        Return the UTF-8 text of a file, or $null when it does not exist (test seam).
    .PARAMETER Path
        The full path of the file.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $Path)

    try {
        return [System.IO.File]::ReadAllText($Path, [System.Text.UTF8Encoding]::new($false))
    }
    catch [System.IO.FileNotFoundException] {
        return $null
    }
    catch [System.IO.DirectoryNotFoundException] {
        return $null
    }
}

function ConvertFrom-ModelRoutingDocsEstateJson {
    <#
    .SYNOPSIS
        Parse JSON text into a hashtable, or return $null for absent, unreadable, or non-object text.
    .OUTPUTS
        System.Collections.Hashtable or $null
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([AllowNull()][object] $Text)

    if ($Text -isnot [string] -or $Text.Length -eq 0) {
        return $null
    }
    try {
        $value = ConvertFrom-Json -InputObject $Text -AsHashtable -ErrorAction Stop
    }
    catch {
        return $null
    }
    if ($value -is [hashtable]) {
        return $value
    }
    return $null
}

function Get-ModelRoutingDocsEstateCommit {
    <#
    .SYNOPSIS
        Resolve a ref to a full lowercase commit id in R through the bounded git seam, or $null.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $WorktreeRoot, [Parameter(Mandatory)][string] $Ref)

    $result = Invoke-DocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('rev-parse', '--verify', '--quiet', ($Ref + '^{commit}'))
    $commit = if ($null -ne $result) { ([string]$result.Output).Trim() } else { '' }
    if ($null -eq $result -or $result.ExitCode -ne 0 -or $commit -cnotmatch '^[0-9a-f]{40}([0-9a-f]{24})?$') {
        return $null
    }
    return $commit
}

function Get-ModelRoutingDocsEstateReceiptReason {
    <#
    .SYNOPSIS
        Condition 4: return $null when the receipt passes, else the sub-code and detail text.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $WorktreeRoot,
        [Parameter(Mandatory)][hashtable] $ProfileDocument,
        [Parameter(Mandatory)][string] $HeadCommit
    )

    $paths = $ProfileDocument['artifact_paths']
    $receiptPath = [string]$paths['validation_receipt']
    $invalid = "DOCS_DELEGATION_RECEIPT_INVALID: the receipt at artifact_paths.validation_receipt is absent, unreadable, not a docs-complete pass receipt, or not at a plain repository-relative path."
    if (-not (Test-DocsEstatePlainRelativePath -RelativePath $receiptPath)) {
        return $invalid
    }
    $receipt = ConvertFrom-ModelRoutingDocsEstateJson -Text (Get-ModelRoutingDocsEstateFileText -Path (Join-Path -Path $WorktreeRoot -ChildPath $receiptPath))
    if ($null -eq $receipt -or $receipt['artifact_kind'] -cne 'docs-validation-receipt' -or $receipt['mode'] -cne 'docs-complete' -or $receipt['validation_result'] -cne 'pass' -or $receipt['revision'] -isnot [string]) {
        return $invalid
    }
    $revision = [string]$receipt['revision']
    $snapshotRevision = $null
    $snapshotPath = [string]$paths['inventory_snapshot']
    if (Test-DocsEstatePlainRelativePath -RelativePath $snapshotPath) {
        $snapshot = ConvertFrom-ModelRoutingDocsEstateJson -Text (Get-ModelRoutingDocsEstateFileText -Path (Join-Path -Path $WorktreeRoot -ChildPath $snapshotPath))
        if ($null -ne $snapshot -and $snapshot['revision'] -is [string]) {
            $snapshotRevision = [string]$snapshot['revision']
        }
    }
    $selection = $ProfileDocument['surface_selection']
    $roots = if ($selection -is [hashtable]) { [string[]]@(@($selection['source_roots']) | Where-Object { $_ -is [string] }) } else { [string[]]@() }
    $isAncestor = $null
    $changed = $null
    if ($revision -cmatch '^[0-9a-f]{40}([0-9a-f]{24})?$' -and $revision -cne $HeadCommit) {
        $ancestry = Invoke-DocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('merge-base', '--is-ancestor', $revision, $HeadCommit)
        if ($null -ne $ancestry -and $ancestry.ExitCode -eq 0) { $isAncestor = $true } elseif ($null -ne $ancestry -and $ancestry.ExitCode -eq 1) { $isAncestor = $false }
        $diff = Invoke-DocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('diff', '--name-only', '-z', '--no-renames', '--no-relative', $revision, $HeadCommit)
        if ($null -ne $diff -and $diff.ExitCode -eq 0 -and (([string]$diff.Output).Length -eq 0 -or ([string]$diff.Output).EndsWith([char]0))) {
            $changed = [string[]]@(ConvertFrom-DocsOnlyNameList -Text ([string]$diff.Output))
        }
    }
    $decision = Get-DocsReceiptRevisionDecision -ReceiptRevision $revision -SnapshotRevision $snapshotRevision -HeadRevision $HeadCommit -IsAncestor $isAncestor -ChangedPath $changed -SourceRoot $roots
    if ($decision.Allow) {
        return $null
    }
    return "$($decision.Reason): $($decision.Message)"
}

function Get-ModelRoutingDocsEstateDecision {
    <#
    .SYNOPSIS
        Decide whether a checkpoint-free Agent(pr-author) delegation is a sanctioned docs-estate
        delegation.
    .DESCRIPTION
        Applies conditions 1 to 4 of the file header in order. Never throws: any error answers
        Allowed $false with an empty DenySuffix.
    .PARAMETER PromptText
        The delegation prompt.
    .PARAMETER WorktreeRoot
        The worktree root R that the gate's identity resolution returned.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with Allowed and DenySuffix.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $PromptText,
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot
    )

    $denied = [pscustomobject]@{ Allowed = $false; DenySuffix = '' }
    try {
        if ([string]::IsNullOrWhiteSpace($WorktreeRoot)) {
            return $denied
        }
        $profileText = Get-ModelRoutingDocsEstateFileText -Path (Join-Path -Path $WorktreeRoot -ChildPath $script:DocsEstateProfileRelativePath)
        if ($null -eq $profileText) {
            return $denied
        }
        $prefix = ' Docs-estate delegation leg not applied: '
        $labels = Get-DocsEstateDelegationLabel -PromptText $PromptText
        if ($null -eq $labels) {
            return [pscustomobject]@{ Allowed = $false; DenySuffix = "${prefix}DOCS_DELEGATION_LABEL_INVALID: the prompt must carry exactly one 'branch: <name>' line and exactly one 'base: <branch>' line, each without '..'." }
        }
        $profileDocument = ConvertFrom-DocsEstateProfileText -Text $profileText
        if ($null -eq $profileDocument) {
            return [pscustomobject]@{ Allowed = $false; DenySuffix = "${prefix}DOCS_DELEGATION_PROFILE_INVALID: $($script:DocsEstateProfileRelativePath) is not a structurally valid docs profile." }
        }
        $unreadable = [pscustomobject]@{ Allowed = $false; DenySuffix = "${prefix}DOCS_DELEGATION_DIFF_UNREADABLE: the diff against refs/remotes/origin/$($labels.Base) could not be read; run git fetch origin $($labels.Base), then retry." }
        $baseCommit = Get-ModelRoutingDocsEstateCommit -WorktreeRoot $WorktreeRoot -Ref ('refs/remotes/origin/' + $labels.Base)
        $headCommit = Get-ModelRoutingDocsEstateCommit -WorktreeRoot $WorktreeRoot -Ref 'HEAD'
        if ($null -eq $baseCommit -or $null -eq $headCommit) {
            return $unreadable
        }
        $diff = Invoke-DocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('diff', '--name-only', '-z', '--no-renames', '--no-relative', ('refs/remotes/origin/' + $labels.Base + '...HEAD'))
        $text = if ($null -ne $diff) { [string]$diff.Output } else { '' }
        if ($null -eq $diff -or $diff.ExitCode -ne 0 -or ($text.Length -gt 0 -and -not $text.EndsWith([char]0))) {
            return $unreadable
        }
        $paths = @(ConvertFrom-DocsOnlyNameList -Text $text)
        if ($paths.Count -eq 0) {
            return [pscustomobject]@{ Allowed = $false; DenySuffix = "${prefix}DOCS_DELEGATION_DIFF_EMPTY: the diff against refs/remotes/origin/$($labels.Base) lists no path." }
        }
        foreach ($path in $paths) {
            if (-not (Test-DocsEstatePath -RelativePath $path -ProfileDocument $profileDocument -InitWorkflowPath $script:DocsOnlyInitWorkflowPath)) {
                return [pscustomobject]@{ Allowed = $false; DenySuffix = "${prefix}DOCS_DELEGATION_PATH_NOT_ALLOWED: '$path' is not in the docs path set." }
            }
        }
        $receiptReason = Get-ModelRoutingDocsEstateReceiptReason -WorktreeRoot $WorktreeRoot -ProfileDocument $profileDocument -HeadCommit $headCommit
        if ($null -ne $receiptReason) {
            return [pscustomobject]@{ Allowed = $false; DenySuffix = $prefix + $receiptReason }
        }
        return [pscustomobject]@{ Allowed = $true; DenySuffix = '' }
    }
    catch {
        Write-Debug "MODEL_ROUTING_DOCS_LEG_ERROR: $($_.Exception.Message)"
        return $denied
    }
}
