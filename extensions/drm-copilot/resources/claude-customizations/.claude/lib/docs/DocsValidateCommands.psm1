<#
.SYNOPSIS
    The validate command function of the documentation library and its argument validator.

.DESCRIPTION
    Test-DocsValidateArgument checks the validate argument map before any read and returns one
    DOCS_CLI_ARGUMENTS finding or $null. Invoke-DocsValidateCommand takes -Argument and -Context,
    returns a New-DocsCommandResult object, writes no output and never exits; only
    validate -WriteReceipt passes WriteText, and only to Invoke-DocsArtifactWrite. The two
    functions moved unchanged from DocsLedgerCommands.psm1 (issue #1169), whose shared private
    helpers they call through that module's exports. Identifier and path comparisons are ordinal
    and case-sensitive.

.NOTES
    Issue #1169 (moved from issue #1023). Requires PowerShell 7.4 or later. No external module
    dependencies. Mirrored byte-identically under
    extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSchema.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsProfile.psm1') -ErrorAction Stop
# The moved functions call the same siblings DocsLedgerCommands.psm1 imports, so this module imports
# each of them itself rather than relying on whatever another module or caller loaded.
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerRules.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsParity.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsEvidencePins.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsStaleness.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReceipt.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsValidation.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerMutation.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsCoverageReport.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerCommands.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReceiptRevision.psm1') -ErrorAction Stop

function Test-DocsValidateArgument {
    <#
    .SYNOPSIS
        Returns one DOCS_CLI_ARGUMENTS finding for an invalid validate argument map, or $null when it is valid.
    .DESCRIPTION
        Checks, before any read: Profile is a relative path; Mode is one of profile, ledger,
        matrix and docs-complete; Revision is a full revision (Test-DocsFullRevision); and
        WriteReceipt is given only with Mode docs-complete. Revision may be absent only when
        WriteReceipt is given with Mode docs-complete (issue #1169); the command then defaults it
        to the inventory snapshot revision.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument)

    $command = 'validate'
    if ((Test-DocsLedgerCommandOption -Argument $Argument -Name 'Profile') -and -not (Test-DocsRelativePath -Path ([string] $Argument['Profile']))) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "Profile '$($Argument['Profile'])' is not a repository-relative path." }
    if (-not (Test-DocsLedgerCommandOption -Argument $Argument -Name 'Mode')) { return New-DocsLedgerCommandUsageFinding -Command $command -Message 'The -Mode option is required.' }
    $mode = [string] $Argument['Mode']
    if ((Get-DocsValidationMode) -cnotcontains $mode) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "Mode '$mode' is not one of $((Get-DocsValidationMode) -join ', ')." }
    $writeReceipt = (Test-DocsLedgerCommandOption -Argument $Argument -Name 'WriteReceipt') -and [bool] $Argument['WriteReceipt']
    if (-not (Test-DocsLedgerCommandOption -Argument $Argument -Name 'Revision')) {
        if (-not ($writeReceipt -and $mode -ceq 'docs-complete')) { return New-DocsLedgerCommandUsageFinding -Command $command -Message 'The -Revision option is required unless -WriteReceipt is given with -Mode docs-complete.' }
    } elseif (-not (Test-DocsFullRevision -Revision ([string] $Argument['Revision']))) { return New-DocsLedgerCommandUsageFinding -Command $command -Message "Revision '$($Argument['Revision'])' is not a full lowercase hexadecimal revision." }
    if ($writeReceipt -and $mode -cne 'docs-complete') { return New-DocsLedgerCommandUsageFinding -Command $command -Message '-WriteReceipt is permitted only with -Mode docs-complete.' }
    return $null
}

function Get-DocsValidateSnapshotRevision {
    <#
    .SYNOPSIS
        Returns the revision member of the inventory snapshot artifact entry, or $null when the
        entry is absent, unreadable, or holds no string revision (private helper, issue #1169).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] [object] $Entry)

    if ($Entry -isnot [System.Collections.IDictionary]) { return $null }
    $parsed = ConvertFrom-DocsJsonText -Text (ConvertFrom-DocsUtf8Bytes -Bytes ([byte[]] $Entry['Bytes']))
    if (@($parsed.Findings).Count -gt 0 -or $parsed.Value -isnot [System.Collections.IDictionary]) { return $null }
    $revision = Get-DocsLedgerCommandMember -Table $parsed.Value -Name 'revision'
    if ($revision -is [string] -and $revision.Length -gt 0) { return $revision }
    return $null
}

function Invoke-DocsValidateContextMember {
    <#
    .SYNOPSIS
        Invokes one optional context member and returns its result, or $null when the member is
        absent or throws (private helper, issue #1169).
    .DESCRIPTION
        The receipt revision rule treats an unreadable git answer as unresolved, so a timeout or a
        start failure of the member becomes $null here and RECEIPT_REVISION_UNRESOLVED there.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [object] $Context,
        [Parameter(Mandatory = $true)] [string] $Name,
        [AllowEmptyCollection()] [object[]] $ArgumentList = @()
    )

    $member = $Context.PSObject.Properties[$Name]
    if ($null -eq $member -or $member.Value -isnot [scriptblock]) { return $null }
    $value = Invoke-DocsValidateMemberBlock -Member ([scriptblock] $member.Value) -Name $Name -ArgumentList $ArgumentList
    if ($null -eq $value) { return $null }
    return , $value
}

function Invoke-DocsValidateMemberBlock {
    <#
    .SYNOPSIS
        Runs one context member scriptblock; returns its value, or $null when it returns $null or
        throws (private helper, issue #1169).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [scriptblock] $Member,
        [Parameter(Mandatory = $true)] [string] $Name,
        [AllowEmptyCollection()] [object[]] $ArgumentList = @()
    )

    try { $value = & $Member @ArgumentList } catch { Write-Verbose "The $Name member failed: $($_.Exception.Message)"; return $null }
    if ($null -eq $value) { return $null }
    # The comma keeps an empty path array as one value, so it is not read as $null.
    return , $value
}

function Get-DocsValidateRevisionFinding {
    <#
    .SYNOPSIS
        Applies the receipt revision rule against the repository HEAD; returns $null when it allows,
        or one DOCS_RECEIPT_REVISION_REJECTED error finding whose message begins with the A4 reason
        (private helper, issue #1169).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [object] $Context,
        [Parameter(Mandatory = $true)] [string] $Revision,
        [AllowNull()] [string] $SnapshotRevision,
        [AllowNull()] [System.Collections.IDictionary] $ProfileDocument
    )

    $head = [string] (Invoke-DocsValidateContextMember -Context $Context -Name 'ResolveRevision' -ArgumentList @('HEAD'))
    $isAncestor = $null
    $changed = $null
    if ($head.Length -gt 0 -and $head -cne $Revision) {
        $answer = Invoke-DocsValidateContextMember -Context $Context -Name 'TestAncestor' -ArgumentList @($Revision, $head)
        if ($answer -is [bool]) { $isAncestor = $answer }
        $listed = Invoke-DocsValidateContextMember -Context $Context -Name 'ListChangedPath' -ArgumentList @($Revision, $head)
        if ($null -ne $listed) { $changed = [string[]] @($listed) }
    }
    $selection = Get-DocsLedgerCommandMember -Table $ProfileDocument -Name 'surface_selection'
    [string[]] $roots = @(@(Get-DocsLedgerCommandMember -Table $selection -Name 'source_roots') | Where-Object { $_ -is [string] })
    $decision = Get-DocsReceiptRevisionDecision -ReceiptRevision $Revision -SnapshotRevision $SnapshotRevision -HeadRevision $head -IsAncestor $isAncestor -ChangedPath $changed -SourceRoot $roots
    if ($decision.Allow) { return $null }
    return New-DocsFinding -Code 'DOCS_RECEIPT_REVISION_REJECTED' -Severity 'error' -Message "$($decision.Reason): $($decision.Message)" -NextAction 'Follow ## Refresh After Rebase or Source Change in the documentation-workflow skill, then run validate -Mode docs-complete -WriteReceipt again.'
}

function Invoke-DocsValidateCommand {
    <#
    .SYNOPSIS
        Validates the documentation artifacts in one mode and returns the receipt; with -WriteReceipt in docs-complete mode the receipt is persisted.
    .DESCRIPTION
        Exit 0 with the pass receipt, exit 1 with the fail receipt (a null result when the profile
        does not load), exit 2 for a usage error before any read, exit 3 (DOCS_CLI_RUNTIME) for a
        read failure, a non-UTC clock, the receipt defect guard, or a receipt write conflict or
        failure. Without -WriteReceipt the WriteText member is never read; with it the receipt
        (pass or fail) is written to artifact_paths.validation_receipt, and only that document.
        Issue #1169: with -WriteReceipt in docs-complete mode and no -Revision, the revision is the
        inventory snapshot revision, and a null or absent snapshot revision is a usage error (exit
        2) naming inventory -Revision. A docs-complete result that passes validation is then
        checked with Get-DocsReceiptRevisionDecision against the repository HEAD (context members
        ResolveRevision, TestAncestor, and ListChangedPath; a member that is absent or throws
        supplies $null); a denial returns exit 1 with a DOCS_RECEIPT_REVISION_REJECTED error
        finding whose message begins with the reason code, a null result, and no receipt write.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument,
        [Parameter(Mandatory = $true)] [object] $Context
    )

    $command = 'validate'
    $usage = Test-DocsValidateArgument -Argument $Argument
    if ($null -ne $usage) { return New-DocsCommandResult -Command $command -ExitCode 2 -Finding @($usage) }
    try {
        $issuedAt = Get-DocsLedgerCommandTimestamp -UtcNow $Context.UtcNow
        $schemas = Get-DocsLedgerCommandSchemaSet
        $mode = [string] $Argument['Mode']
        $revision = [string] $Argument['Revision']
        $writeReceipt = [bool] (Get-DocsLedgerCommandArgumentValue -Argument $Argument -Name 'WriteReceipt' -Default $false)
        $profilePath = [string] (Get-DocsLedgerCommandArgumentValue -Argument $Argument -Name 'Profile' -Default (Get-DocsDefaultProfilePath))
        $profileRead = Read-DocsLedgerCommandProfile -Command $command -ProfilePath $profilePath -ReadBytes $Context.ReadBytes -TestFile $Context.TestFile -ComposedSchemaSet $schemas
        if ($null -eq $profileRead.Bytes) { return $profileRead.Result }
        $profileText = ConvertFrom-DocsUtf8Bytes -Bytes $profileRead.Bytes
        $artifact = [ordered]@{ 'docs-profile' = @{ Path = $profilePath; Bytes = $profileRead.Bytes } }
        $pagePath = [string[]]@()
        $loaded = (ConvertFrom-DocsProfileText -Text $profileText -ArtifactPath $profilePath -ComposedSchemaSet $schemas).Profile
        if ($null -ne $loaded) {
            $inputs = Read-DocsLedgerInputSet -Profile $loaded -Need (Get-DocsValidationInputKind -Mode $mode) -ReadBytes $Context.ReadBytes -TestFile $Context.TestFile -ListFile $Context.ListFile
            foreach ($kind in @($inputs.Artifact.Keys)) { $artifact[$kind] = $inputs.Artifact[$kind] }
            $pagePath = $inputs.PagePath
        }
        # Issue #1169: under -WriteReceipt in docs-complete mode -Revision defaults to the snapshot revision.
        $snapshotRevision = Get-DocsValidateSnapshotRevision -Entry $(if ($artifact.Contains('surface-inventory-snapshot')) { $artifact['surface-inventory-snapshot'] } else { $null })
        if ($revision.Length -eq 0) {
            if ($null -eq $snapshotRevision) {
                $finding = New-DocsLedgerCommandUsageFinding -Command $command -Message 'The inventory snapshot revision is null or absent, so -Revision has no default; run inventory -Revision <full revision> -Write first, or pass -Revision.'
                return New-DocsCommandResult -Command $command -ExitCode 2 -Finding @($finding)
            }
            $revision = $snapshotRevision
        }
        $validation = Invoke-DocsValidation -Mode $mode -Revision $revision -IssuedAt $issuedAt -ProfileText $profileText -ProfilePath $profilePath -Artifact $artifact -PagePath $pagePath -ComposedSchemaSet $schemas
        if ($null -eq $validation.Receipt) { return New-DocsCommandResult -Command $command -ExitCode 1 -Finding $validation.Findings }
        $receipt = $validation.Receipt
        if ($mode -ceq 'docs-complete' -and $validation.Ok) {
            # Issue #1169: a passing docs-complete result must also hold against the repository HEAD.
            $revisionFinding = Get-DocsValidateRevisionFinding -Context $Context -Revision $revision -SnapshotRevision $snapshotRevision -ProfileDocument $loaded
            if ($null -ne $revisionFinding) { return New-DocsCommandResult -Command $command -ExitCode 1 -Finding (@($validation.Findings) + @($revisionFinding)) }
        }
        $exitCode = if ($validation.Ok) { 0 } else { 1 }
        $lines = [System.Collections.Generic.List[string]]::new()
        $lines.Add("receipt $($receipt['id']) $mode $($receipt['validation_result'])")
        if ($writeReceipt) {
            $receiptPath = [string] (Get-DocsLedgerCommandMember -Table (Get-DocsLedgerCommandMember -Table $loaded -Name 'artifact_paths') -Name 'validation_receipt')
            $existing = (Read-DocsLedgerInputSet -Profile $loaded -Need @('docs-validation-receipt') -ReadBytes $Context.ReadBytes -TestFile $Context.TestFile -ListFile $Context.ListFile).Artifact['docs-validation-receipt']
            $before = if ($null -eq $existing) { $null } else { Get-DocsTextSha256Hex -Bytes ([byte[]] $existing['Bytes']) }
            $plans = Get-DocsArtifactWritePlan -Document @(@{ Path = $receiptPath; ArtifactKind = 'docs-validation-receipt'; ArtifactId = [string] $receipt['id']; Text = (ConvertTo-DocsJsonText -Value $receipt -Indented); BeforeSha256 = $before })
            $outcome = Invoke-DocsArtifactWrite -Plan $plans -ReadBytes $Context.ReadBytes -TestFile $Context.TestFile -WriteText $Context.WriteText
            if ($null -ne $outcome.Failed) {
                return New-DocsLedgerCommandRuntimeResult -Command $command -Message "The write of $($outcome.Failed['Path']) ended with status $($outcome.Failed['Status']): $($outcome.Failed['Message'])" -ArtifactPath $receiptPath -RelatedPath (@($receiptPath) + @($outcome.WrittenPath))
            }
            foreach ($plan in $outcome.Write) { $lines.Add("$($plan['Status']) $($plan['Path'])") }
        }
        return New-DocsCommandResult -Command $command -ExitCode $exitCode -Finding $validation.Findings -Result $receipt -Line $lines.ToArray()
    } catch {
        return New-DocsLedgerCommandRuntimeResult -Command $command -Message "The command failed: $($_.Exception.Message)"
    }
}

Export-ModuleMember -Function `
    Test-DocsValidateArgument, `
    Invoke-DocsValidateCommand
