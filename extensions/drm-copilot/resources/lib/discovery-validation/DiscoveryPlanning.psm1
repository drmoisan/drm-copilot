<#
.SYNOPSIS
    Native PreToolUse gating of implementation planning on current configured discovery authority.

.DESCRIPTION
    Every native discovery planning adapter (Claude Code, Codex, GitHub Copilot)
    takes its decision from this module. A planning delegation is a native agent
    launch whose target is an atomic-planner or orchestrator profile. When the
    workspace has no protected activation, or a deliberate deactivation, the
    delegation is allowed and the existing planning gates apply unchanged. When the
    workspace is active, the delegation is admitted only when the workspace still
    carries the activated locator (`config/discovery.json`) and domain profile with
    the activated bytes, and the protected session holds a current gateway-written
    `validation-receipt` for mode `planning` issued to the native-root principal of
    this host and session, bound to the activation and workspace, passing, with
    every input it read unchanged and the profile's planning prerequisite
    (`none`, `discovery-complete`, `parity-complete`) reflected in its manifest. A
    structural, agent-output, completion-mode or receipt-version-1 receipt, a
    failing receipt, a stale receipt, a missing, deleted, disabled or malformed
    locator or profile all block before the delegation runs.

    The hooks verify authority only: no Python runtime is invoked and no
    validation is started here. Store and workspace access flows through injected
    seams.

.NOTES
    Issue #980. Compatible with PowerShell 7+. Depends only on the sibling
    DiscoveryEncoding, DiscoveryAuthority, DiscoveryManifest, DiscoveryPayload,
    DiscoveryAuthorization and DiscoveryStartRecord modules.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'DiscoveryEncoding.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryAuthority.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryManifest.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryPayload.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryToolRouting.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryAuthorization.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryStartRecord.psm1') -ErrorAction Stop

$script:PlanningAgentPattern = '^(?:atomic-planner|orchestrator)(?:-c(?:1|2|3|4|3-elevated))?$'
$script:PlanningTargetKeys = @('subagent_type', 'agent_type', 'agent')
$script:LocatorPath = 'config/discovery.json'
$script:ReceiptsPartition = 'receipts'
$script:Prerequisites = @('none', 'discovery-complete', 'parity-complete')
$script:PrerequisitePattern = '(?m)^\s*"?planning_prerequisite"?\s*[:=]\s*"?(?<value>none|discovery-complete|parity-complete)"?\s*,?\s*(?:#.*)?$'

function Get-DiscoveryPlanningOutcome {
    <#
    .SYNOPSIS
        Builds one planning outcome (allow or deny) with its code, reason and the authorizing receipt.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('allow', 'deny')][string]$Decision,
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$Reason,
        [Parameter(Mandatory = $false)][AllowNull()][object]$Receipt = $null,
        [Parameter(Mandatory = $false)][AllowNull()][string]$Prerequisite = $null
    )

    return [pscustomobject]@{ Decision = $Decision; Code = $Code; Reason = $Reason; Receipt = $Receipt; Prerequisite = $Prerequisite }
}

function Get-DiscoveryPlanningTarget {
    <#
    .SYNOPSIS
        Returns the planner or orchestrator profile a native agent launch targets, or $null for any other call.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][pscustomobject]$Normalized)

    $tool = Resolve-DiscoveryToolName -ToolName $Normalized.ToolName
    if ($tool.Family -ne 'spawn') { return $null }
    $toolInput = $Normalized.ToolInput
    foreach ($key in $script:PlanningTargetKeys) {
        $value = $null
        if ($toolInput -is [System.Collections.IDictionary]) { if ($toolInput.Contains($key)) { $value = $toolInput[$key] } }
        elseif ($toolInput -is [System.Management.Automation.PSCustomObject]) { $property = $toolInput.PSObject.Properties[$key]; if ($null -ne $property) { $value = $property.Value } }
        if ($value -is [string] -and $value -cmatch $script:PlanningAgentPattern) { return $value }
    }
    return $null
}

function Get-DiscoveryPlanningPrerequisite {
    <#
    .SYNOPSIS
        Reads `planning_prerequisite` from the profile text (YAML or JSON), defaulting to discovery-complete.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$ProfileText)

    $match = [regex]::Match($ProfileText, $script:PrerequisitePattern)
    if ($match.Success) { return $match.Groups['value'].Value }
    return 'discovery-complete'
}

function Get-DiscoveryWorkspaceFileMismatch {
    <#
    .SYNOPSIS
        Verifies that a workspace file still exists with the activated bytes and is decodable text.
    .OUTPUTS
        [pscustomobject] Code, Reason, Text (the decoded text when valid).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)][AllowNull()][AllowEmptyString()][string]$ExpectedSha256,
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][scriptblock]$ReadBytes
    )

    $bytes = & $ReadBytes (Get-DiscoveryWorkspacePath -WorkspaceRoot $WorkspaceRoot -RelativePath $RelativePath)
    if ($null -eq $bytes) {
        return [pscustomobject]@{ Code = "$($Label)_MISSING"; Reason = "the workspace is active but its $($Label.ToLowerInvariant()) $RelativePath is absent"; Text = $null }
    }
    [byte[]]$bytes = @($bytes)
    if ([string]::IsNullOrEmpty($ExpectedSha256) -or (Get-DiscoveryBytesSha256Hex -Bytes $bytes) -cne $ExpectedSha256) {
        return [pscustomobject]@{ Code = "$($Label)_CHANGED"; Reason = "the $($Label.ToLowerInvariant()) $RelativePath differs from the activated bytes"; Text = $null }
    }
    try {
        $text = [System.Text.UTF8Encoding]::new($false, $true).GetString($bytes)
    } catch {
        return [pscustomobject]@{ Code = "$($Label)_MALFORMED"; Reason = "the $($Label.ToLowerInvariant()) $RelativePath is not valid UTF-8"; Text = $null }
    }
    return [pscustomobject]@{ Code = $null; Reason = $null; Text = $text }
}

function Get-DiscoveryPlanningReceiptMismatch {
    <#
    .SYNOPSIS
        Compares one candidate receipt against the planning authority contract.
    .DESCRIPTION
        Returns $null when the receipt authorizes planning, otherwise an object with
        Code (RECEIPT_VERSION, WRONG_MODE, IDENTITY, FORGED, BINDING, STALE_ACTIVATION,
        RESULT, PREREQUISITE or STALE_INPUTS) and Reason. The receipt must be a
        schema-2 `validation-receipt` of mode `planning` for the native-root
        principal of this host and session.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Receipt,
        [Parameter(Mandatory = $true)][pscustomobject]$Normalized,
        [Parameter(Mandatory = $true)][pscustomobject]$Activation,
        [Parameter(Mandatory = $true)][string]$ActivationSha256,
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $true)][string]$Prerequisite,
        [Parameter(Mandatory = $true)][scriptblock]$ReadBytes
    )

    $names = @($Receipt.PSObject.Properties.Name)
    foreach ($required in @('artifact_kind', 'receipt_version', 'mode', 'identity', 'writer', 'workspace', 'activation_sha256', 'validation_result', 'input_manifest')) {
        if ($names -notcontains $required) { return [pscustomobject]@{ Code = 'RECEIPT_VERSION'; Reason = "the receipt lacks '$required' and is not a schema 2.0.0 validation receipt" } }
    }
    if ($Receipt.artifact_kind -ne 'validation-receipt' -or [string]$Receipt.receipt_version -ne '2.0.0' -or [string]$Receipt.schema_version -ne '2.0.0') {
        return [pscustomobject]@{ Code = 'RECEIPT_VERSION'; Reason = 'the receipt is not a receipt-version 2.0.0 validation receipt; a v1 check cannot authorize planning' }
    }
    if ([string]$Receipt.mode -ne 'planning') {
        return [pscustomobject]@{ Code = 'WRONG_MODE'; Reason = "the receipt was issued for mode '$($Receipt.mode)'; only a planning-mode receipt authorizes planning" }
    }
    $identity = $Receipt.identity
    if ($identity -isnot [System.Management.Automation.PSCustomObject] -or $identity.kind -ne 'native-root' -or $identity.host -ne $Normalized.HostName -or $identity.session_id -ne $Normalized.SessionId) {
        return [pscustomobject]@{ Code = 'IDENTITY'; Reason = 'the receipt was not issued to the native-root principal of this host and session' }
    }
    $writer = $Receipt.writer
    if ($writer -isnot [System.Management.Automation.PSCustomObject] -or $writer.kind -ne 'host-gateway' -or $writer.host -ne $Normalized.HostName) {
        return [pscustomobject]@{ Code = 'FORGED'; Reason = 'the receipt was not written by the host gateway' }
    }
    $sameBinding = ([string]$Receipt.workspace.workspace_sha256 -eq $Location.WorkspaceSha256) -and
    ([string]$Receipt.workspace.profile_path -eq [string]$Activation.profile_path) -and
    ([string]$Receipt.workspace.profile_sha256 -eq [string]$Activation.profile_sha256)
    if (-not $sameBinding) {
        return [pscustomobject]@{ Code = 'BINDING'; Reason = 'the receipt is bound to another workspace or profile than the current activation' }
    }
    if ([string]$Receipt.activation_sha256 -cne $ActivationSha256) {
        return [pscustomobject]@{ Code = 'STALE_ACTIVATION'; Reason = 'the activation record changed after the planning receipt was issued' }
    }
    if ([string]$Receipt.validation_result -ne 'pass') {
        return [pscustomobject]@{ Code = 'RESULT'; Reason = "the planning receipt records '$($Receipt.validation_result)'; configured discovery is incomplete" }
    }
    try {
        $manifest = ConvertFrom-DiscoveryInputManifest -Value $Receipt.input_manifest
    } catch {
        return [pscustomobject]@{ Code = 'RECEIPT_VERSION'; Reason = "the receipt input manifest is invalid: $($_.Exception.Message)" }
    }
    # The prerequisite the profile configures must be visible in what the runtime validated.
    if ($Prerequisite -ne 'none' -and @($manifest['source_repositories']).Count -eq 0) {
        return [pscustomobject]@{ Code = 'PREREQUISITE'; Reason = "the profile requires $Prerequisite but the planning receipt validated no source repository" }
    }
    if ($Prerequisite -eq 'parity-complete' -and @($manifest['target_repositories']).Count -eq 0) {
        return [pscustomobject]@{ Code = 'PREREQUISITE'; Reason = 'the profile requires parity-complete but the planning receipt validated no target repository' }
    }
    $comparison = Compare-DiscoveryInputManifest -Manifest $manifest -WorkspaceRoot ([string]$Receipt.workspace.workspace_root) `
        -ProfilePath ([string]$Activation.profile_path) -ProfileSha256 ([string]$Activation.profile_sha256) -ReadBytes $ReadBytes
    if ($comparison.Drift.Count -gt 0) {
        $summary = @($comparison.Drift | ForEach-Object { "$($_.kind):$($_.path)" }) -join ', '
        return [pscustomobject]@{ Code = 'STALE_INPUTS'; Reason = "inputs changed after the planning receipt: $summary" }
    }
    return $null
}

function Get-DiscoveryPlanningDecision {
    <#
    .SYNOPSIS
        Decides one PreToolUse agent launch for a native discovery planning adapter.
    .DESCRIPTION
        Order: envelope anomalies deny; a call that is not a planner or orchestrator
        launch is allowed; a workspace without an activation or with a deliberate
        deactivation is allowed (existing planning behavior); an active workspace
        must still hold the activated locator and profile; then the protected
        session's planning receipts are examined newest first and the first one
        that passes Get-DiscoveryPlanningReceiptMismatch authorizes the launch.
        When none passes, the mismatch of the newest planning-mode candidate (or the
        newest candidate of any mode) is the deny reason.
    .OUTPUTS
        [pscustomobject] Decision, Code, Reason, Receipt, Prerequisite.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Normalized,
        [Parameter(Mandatory = $true)][hashtable]$HostEnvironment,
        [Parameter(Mandatory = $false)][hashtable]$Store = (Get-DiscoveryStartStore),
        [Parameter(Mandatory = $false)][AllowNull()][scriptblock]$ReadBytes = $null
    )

    if ($null -ne $Normalized.Anomaly) {
        return Get-DiscoveryPlanningOutcome -Decision 'deny' -Code 'ENVELOPE' -Reason ('payload anomaly - ' + (Get-DiscoveryPayloadAnomalyReason -Code $Normalized.Anomaly) + '. The gate fails closed on an envelope it cannot read.')
    }
    $target = Get-DiscoveryPlanningTarget -Normalized $Normalized
    if ($null -eq $target) {
        return Get-DiscoveryPlanningOutcome -Decision 'allow' -Code 'NOT_PLANNING' -Reason 'the call is not a planner or orchestrator launch'
    }
    if ([string]::IsNullOrWhiteSpace([string]$Normalized.Cwd)) {
        return Get-DiscoveryPlanningOutcome -Decision 'deny' -Code 'WORKSPACE' -Reason 'the native event carries no workspace directory'
    }
    try {
        $location = Resolve-DiscoveryAuthorityLocation -WorkspaceRoot ([string]$Normalized.Cwd) -Platform $HostEnvironment.Platform `
            -UserHome $HostEnvironment.UserHome -LocalAppData $HostEnvironment.LocalAppData -XdgStateHome $HostEnvironment.XdgStateHome
    } catch {
        return Get-DiscoveryPlanningOutcome -Decision 'deny' -Code 'WORKSPACE' -Reason $_.Exception.Message
    }
    $activation = Read-DiscoveryActivationState -Location $location -ReadText $Store.ReadText
    if ($activation.Status -eq 'missing' -or $activation.Status -eq 'inactive') {
        return Get-DiscoveryPlanningOutcome -Decision 'allow' -Code 'NOT_ACTIVE' -Reason "discovery is $($activation.Status) for this workspace; existing planning gates apply unchanged"
    }
    if ($activation.Status -ne 'active') {
        return Get-DiscoveryPlanningOutcome -Decision 'deny' -Code 'ACTIVATION' -Reason "the protected activation record is unreadable ($($activation.Reason)); the gate fails closed"
    }
    if ($null -eq $ReadBytes) {
        $ReadBytes = {
            param([string]$Path)
            if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
            return [System.IO.File]::ReadAllBytes($Path)
        }
    }
    $workspaceRoot = [string]$Normalized.Cwd
    $record = $activation.Record
    $locator = Get-DiscoveryWorkspaceFileMismatch -WorkspaceRoot $workspaceRoot -RelativePath $script:LocatorPath -ExpectedSha256 ([string]$record.locator_sha256) -Label 'LOCATOR' -ReadBytes $ReadBytes
    if ($null -ne $locator.Code) { return Get-DiscoveryPlanningOutcome -Decision 'deny' -Code $locator.Code -Reason $locator.Reason }
    try { $locatorRecord = ConvertFrom-Json -InputObject $locator.Text -Depth 4 } catch { $locatorRecord = $null }
    if ($locatorRecord -isnot [System.Management.Automation.PSCustomObject] -or $locatorRecord.enabled -ne $true -or [string]$locatorRecord.profile_path -cne [string]$record.profile_path) {
        return Get-DiscoveryPlanningOutcome -Decision 'deny' -Code 'LOCATOR_MALFORMED' -Reason "the locator $($script:LocatorPath) is disabled, malformed or names another profile than the activation"
    }
    $profileFile = Get-DiscoveryWorkspaceFileMismatch -WorkspaceRoot $workspaceRoot -RelativePath ([string]$record.profile_path) -ExpectedSha256 ([string]$record.profile_sha256) -Label 'PROFILE' -ReadBytes $ReadBytes
    if ($null -ne $profileFile.Code) { return Get-DiscoveryPlanningOutcome -Decision 'deny' -Code $profileFile.Code -Reason $profileFile.Reason }
    if ($profileFile.Text -notmatch 'schema_version') {
        return Get-DiscoveryPlanningOutcome -Decision 'deny' -Code 'PROFILE_MALFORMED' -Reason "the profile $($record.profile_path) declares no schema_version"
    }
    $prerequisite = Get-DiscoveryPlanningPrerequisite -ProfileText $profileFile.Text
    $activationSha256 = Get-DiscoverySha256Hex -Text ([string](Invoke-DiscoveryStoreSeam -Seam $Store.ReadText -Arguments @($activation.Path)))
    $directory = "$(Get-DiscoverySessionDirectory -Location $location -SessionId $Normalized.SessionId)/$($script:ReceiptsPartition)"
    $candidates = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in @(Invoke-DiscoveryStoreSeam -Seam $Store.ListEntries -Arguments @($directory))) {
        if ($entry -notlike '*.json') { continue }
        $text = Invoke-DiscoveryStoreSeam -Seam $Store.ReadText -Arguments @("$directory/$entry")
        if ($null -eq $text) { continue }
        try { $receipt = ConvertFrom-Json -InputObject ([string]$text) -Depth 16 } catch { continue }
        if ($receipt -isnot [System.Management.Automation.PSCustomObject]) { continue }
        $issued = ConvertTo-DiscoveryUtcInstant -Value $(if (@($receipt.PSObject.Properties.Name) -contains 'issued_at') { $receipt.issued_at } else { $null })
        $candidates.Add([pscustomobject]@{ Receipt = $receipt; IssuedAt = $(if ($null -ne $issued) { $issued } else { [datetime]::MinValue }) })
    }
    if ($candidates.Count -eq 0) {
        return Get-DiscoveryPlanningOutcome -Decision 'deny' -Code 'NO_RECEIPT' -Reason "discovery is active with prerequisite $prerequisite and the session holds no planning receipt; run validate_discovery_artifacts with mode planning before delegating" -Prerequisite $prerequisite
    }
    $firstMismatch = $null
    foreach ($candidate in @($candidates | Sort-Object -Property IssuedAt -Descending)) {
        $mismatch = Get-DiscoveryPlanningReceiptMismatch -Receipt $candidate.Receipt -Normalized $Normalized -Activation $record -ActivationSha256 $activationSha256 -Location $location -Prerequisite $prerequisite -ReadBytes $ReadBytes
        if ($null -eq $mismatch) {
            return Get-DiscoveryPlanningOutcome -Decision 'allow' -Code 'PLANNING_AUTHORIZED' -Reason "a current planning receipt authorizes $target (prerequisite $prerequisite)" -Receipt $candidate.Receipt -Prerequisite $prerequisite
        }
        # The newest planning-mode candidate explains the refusal; other modes only when nothing else exists.
        if ($null -eq $firstMismatch -or ($firstMismatch.Code -eq 'WRONG_MODE' -and $mismatch.Code -ne 'WRONG_MODE')) { $firstMismatch = $mismatch }
    }
    return Get-DiscoveryPlanningOutcome -Decision 'deny' -Code $firstMismatch.Code -Reason $firstMismatch.Reason -Prerequisite $prerequisite
}

function ConvertTo-DiscoveryPlanningHookOutput {
    <#
    .SYNOPSIS
        Renders a planning outcome as the PreToolUse hookSpecificOutput envelope with the hook's reason prefix.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Outcome,
        [Parameter(Mandatory = $true)][string]$ReasonPrefix
    )

    if ($Outcome.Decision -eq 'allow') {
        return [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' } }
    }
    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = "$ReasonPrefix $($Outcome.Reason)"
        }
    }
}

Export-ModuleMember -Function `
    Get-DiscoveryPlanningTarget, `
    Get-DiscoveryPlanningPrerequisite, `
    Get-DiscoveryPlanningReceiptMismatch, `
    Get-DiscoveryPlanningDecision, `
    ConvertTo-DiscoveryPlanningHookOutput
