<#
.SYNOPSIS
    Native SubagentStop validation of a discovery specialist's protected output authority.

.DESCRIPTION
    Every native discovery SubagentStop adapter (Claude Code, Codex, GitHub
    Copilot) takes its decision from this module. A stop whose agent type is not
    a discovery specialist is skipped, so ordinary and epic stop validation keeps
    its existing path. For a discovery specialist the stop result is derived from
    the protected invocation bound to the host-assigned agent identity, never from
    the final assistant message: the invocation must be finalized through the
    gateway, its completion receipt must be the gateway-written `validation-receipt`
    for this invocation, session, role and gate mode, bound to the current
    activation and workspace, with every required output still present, every
    input unchanged since the receipt (re-read and re-hashed) and output_valid
    true; only the migration-coverage-reviewer may stop on a valid failing report.
    Filenames or success prose in the final text cannot admit a stop, and a blank
    final text cannot skip the validation.

    Store and workspace access flows through injected seams; no process is invoked
    and no orchestrator checkpoint is read or written.

.NOTES
    Issue #980. Compatible with PowerShell 7+. Depends only on the sibling
    DiscoveryEncoding, DiscoveryAuthority, DiscoveryManifest, DiscoveryPayload and
    DiscoveryStartRecord modules.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'DiscoveryEncoding.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryAuthority.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryManifest.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryPayload.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryStartRecord.psm1') -ErrorAction Stop

$script:ReceiptsPartition = 'receipts'
$script:ReviewerRole = 'migration-coverage-reviewer'
$script:ResultTokenPattern = '(?<![A-Za-z])(PASS|FAIL|BLOCKED)(?![A-Za-z])'
$script:CorrelationIdPattern = '^[A-Za-z0-9][A-Za-z0-9._:-]*$'
$script:RuntimeKeys = @('build_sha256', 'package_version', 'policy_sha256', 'policy_version', 'schema_version')

function Get-DiscoveryStopOutcome {
    <#
    .SYNOPSIS
        Builds one stop outcome (skip, allow or block) with its code and reason.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('skip', 'allow', 'block')][string]$Decision,
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$Reason,
        [Parameter(Mandatory = $false)][AllowNull()][object]$Receipt = $null,
        [Parameter(Mandatory = $false)][AllowNull()][object]$Invocation = $null
    )

    return [pscustomobject]@{ Decision = $Decision; Code = $Code; Reason = $Reason; Receipt = $Receipt; Invocation = $Invocation }
}

function Read-DiscoveryStopJson {
    <#
    .SYNOPSIS
        Reads one JSON object from the store, returning Text and Record or $null members.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][hashtable]$Store,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $text = Invoke-DiscoveryStoreSeam -Seam $Store.ReadText -Arguments @($Path)
    if ($null -eq $text) { return [pscustomobject]@{ Text = $null; Record = $null } }
    try { $record = ConvertFrom-Json -InputObject ([string]$text) -Depth 16 } catch { $record = $null }
    if ($record -isnot [System.Management.Automation.PSCustomObject]) { $record = $null }
    return [pscustomobject]@{ Text = [string]$text; Record = $record }
}

function Find-DiscoveryAgentInvocationForStop {
    <#
    .SYNOPSIS
        Finds the discovery invocations bound to the stopping agent (started or finalized).
    .DESCRIPTION
        Enumerates `<session>/invocations/*/invocation.json` and keeps every
        `discovery-invocation` whose host, session, parent, agent type and agent id
        equal the stopping principal's. An unreadable record is skipped.
    .OUTPUTS
        [pscustomobject] Count, Record, Directory.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $true)][pscustomobject]$Principal,
        [Parameter(Mandatory = $true)][string]$AgentType,
        [Parameter(Mandatory = $true)][string]$AgentId,
        [Parameter(Mandatory = $true)][hashtable]$Store
    )

    $directory = "$(Get-DiscoverySessionDirectory -Location $Location -SessionId $Principal.SessionId)/invocations"
    $bindings = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in @(Invoke-DiscoveryStoreSeam -Seam $Store.ListEntries -Arguments @($directory))) {
        $read = Read-DiscoveryStopJson -Store $Store -Path "$directory/$entry/invocation.json"
        $record = $read.Record
        if ($null -eq $record) { continue }
        $names = @($record.PSObject.Properties.Name)
        $missing = @(@('artifact_kind', 'host', 'session_id', 'parent_agent_id', 'agent_id', 'state', 'deployment') | Where-Object { $names -notcontains $_ })
        if ($missing.Count -gt 0 -or $record.deployment -isnot [System.Management.Automation.PSCustomObject]) { continue }
        $bound = ($record.artifact_kind -eq 'discovery-invocation') -and ($record.host -eq $Principal.HostName) -and
        ($record.session_id -eq $Principal.SessionId) -and ($record.parent_agent_id -eq $Principal.ParentAgentId) -and
        ([string]$record.deployment.agent_name -ceq $AgentType) -and ([string]$record.agent_id -ceq $AgentId) -and
        (@('started', 'finalized') -contains [string]$record.state)
        if ($bound) { $bindings.Add([pscustomobject]@{ Record = $record; Directory = "$directory/$entry" }) }
    }
    if ($bindings.Count -ne 1) { return [pscustomobject]@{ Count = $bindings.Count; Record = $null; Directory = $null } }
    return [pscustomobject]@{ Count = 1; Record = $bindings[0].Record; Directory = $bindings[0].Directory }
}

function Get-DiscoveryReceiptMismatch {
    <#
    .SYNOPSIS
        Compares the completion receipt against the invocation, principal, activation and current workspace.
    .DESCRIPTION
        Returns $null when the receipt authorizes the stop, otherwise an object with
        Code (RECEIPT, GATE, IDENTITY, FORGED, BINDING, STALE_ACTIVATION, RUNTIME,
        OUTPUTS, OUTPUT_INVALID, RESULT, STALE_INPUTS or OUTPUT_MISSING) and Reason.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Receipt,
        [Parameter(Mandatory = $true)][pscustomobject]$Record,
        [Parameter(Mandatory = $true)][pscustomobject]$Principal,
        [Parameter(Mandatory = $true)][string]$AgentId,
        [Parameter(Mandatory = $true)][pscustomobject]$Activation,
        [Parameter(Mandatory = $true)][string]$ActivationSha256,
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $true)][scriptblock]$ReadBytes
    )

    $names = @($Receipt.PSObject.Properties.Name)
    foreach ($required in @('artifact_kind', 'receipt_ref', 'mode', 'identity', 'writer', 'workspace', 'activation_sha256', 'runtime', 'required_outputs', 'output_valid', 'validation_result', 'input_manifest')) {
        if ($names -notcontains $required) { return [pscustomobject]@{ Code = 'RECEIPT'; Reason = "the completion receipt lacks '$required'" } }
    }
    if ($Receipt.artifact_kind -ne 'validation-receipt' -or [string]$Receipt.receipt_ref -cne [string]$Record.completion_receipt_ref) {
        return [pscustomobject]@{ Code = 'RECEIPT'; Reason = 'the completion receipt is not the validation-receipt the invocation names' }
    }
    if ([string]$Receipt.mode -ne 'agent-output') {
        return [pscustomobject]@{ Code = 'GATE'; Reason = "the completion receipt was issued for gate mode '$($Receipt.mode)', not agent-output" }
    }
    $identity = $Receipt.identity
    $identityBound = ($identity -is [System.Management.Automation.PSCustomObject]) -and ($identity.kind -eq 'discovery-agent') -and
    ($identity.host -eq $Principal.HostName) -and ($identity.session_id -eq $Principal.SessionId) -and
    ([string]$identity.agent_id -ceq $AgentId) -and ([string]$identity.role -ceq [string]$Record.role) -and
    ([string]$identity.invocation_id -ceq [string]$Record.invocation_id)
    if (-not $identityBound) {
        return [pscustomobject]@{ Code = 'IDENTITY'; Reason = 'the completion receipt is bound to another agent, session, role or invocation' }
    }
    $writer = $Receipt.writer
    if ($writer -isnot [System.Management.Automation.PSCustomObject] -or $writer.kind -ne 'host-gateway' -or $writer.host -ne $Principal.HostName) {
        return [pscustomobject]@{ Code = 'FORGED'; Reason = 'the completion receipt was not written by the host gateway' }
    }
    $sameBinding = ([string]$Receipt.workspace.workspace_sha256 -eq $Location.WorkspaceSha256) -and
    ([string]$Receipt.workspace.workspace_root -eq [string]$Record.workspace.workspace_root) -and
    ([string]$Receipt.workspace.profile_path -eq [string]$Activation.profile_path) -and
    ([string]$Receipt.workspace.profile_sha256 -eq [string]$Activation.profile_sha256)
    if (-not $sameBinding) {
        return [pscustomobject]@{ Code = 'BINDING'; Reason = 'the completion receipt is bound to another workspace or profile than the current activation' }
    }
    if ([string]$Receipt.activation_sha256 -cne $ActivationSha256) {
        return [pscustomobject]@{ Code = 'STALE_ACTIVATION'; Reason = 'the activation record changed after the completion receipt was issued' }
    }
    foreach ($key in $script:RuntimeKeys) {
        if ([string]$Receipt.runtime.$key -cne [string]$Record.runtime.$key) {
            return [pscustomobject]@{ Code = 'RUNTIME'; Reason = "runtime pin $key of the receipt differs from the invocation" }
        }
    }
    $outputs = $Receipt.required_outputs
    if ($outputs -isnot [System.Management.Automation.PSCustomObject] -or [string]$outputs.manifest_sha256 -cne [string]$Record.required_outputs.manifest_sha256) {
        return [pscustomobject]@{ Code = 'OUTPUTS'; Reason = 'the completion receipt does not carry the required-output manifest of the invocation' }
    }
    if ($Receipt.output_valid -isnot [bool] -or -not [bool]$Receipt.output_valid) {
        return [pscustomobject]@{ Code = 'OUTPUT_INVALID'; Reason = 'the completion receipt does not mark the required outputs valid' }
    }
    $result = [string]$Receipt.validation_result
    if ($result -ne 'pass' -and -not ($result -eq 'fail' -and [string]$Record.role -eq $script:ReviewerRole)) {
        return [pscustomobject]@{ Code = 'RESULT'; Reason = "validation result '$result' does not complete role $($Record.role); only the reviewer may stop on a valid failing report" }
    }
    try {
        $manifest = ConvertFrom-DiscoveryInputManifest -Value $Receipt.input_manifest
    } catch {
        return [pscustomobject]@{ Code = 'RECEIPT'; Reason = "the completion receipt input manifest is invalid: $($_.Exception.Message)" }
    }
    $comparison = Compare-DiscoveryInputManifest -Manifest $manifest -WorkspaceRoot ([string]$Record.workspace.workspace_root) `
        -ProfilePath ([string]$Activation.profile_path) -ProfileSha256 ([string]$Activation.profile_sha256) -ReadBytes $ReadBytes
    if ($comparison.Drift.Count -gt 0) {
        $summary = @($comparison.Drift | ForEach-Object { "$($_.kind):$($_.path)" }) -join ', '
        return [pscustomobject]@{ Code = 'STALE_INPUTS'; Reason = "inputs changed after the completion receipt: $summary" }
    }
    foreach ($output in @($outputs.outputs)) {
        $rowNames = @($output.PSObject.Properties.Name)
        if (@('artifact_kind', 'id', 'path') | Where-Object { $rowNames -notcontains $_ -or [string]::IsNullOrWhiteSpace([string]$output.$_) }) {
            return [pscustomobject]@{ Code = 'OUTPUTS'; Reason = 'a required output row lacks its kind, id or path' }
        }
        $bytes = & $ReadBytes (Get-DiscoveryWorkspacePath -WorkspaceRoot ([string]$Record.workspace.workspace_root) -RelativePath ([string]$output.path))
        if ($null -eq $bytes) {
            return [pscustomobject]@{ Code = 'OUTPUT_MISSING'; Reason = "required output $($output.path) ($($output.artifact_kind) $($output.id)) is absent from the workspace" }
        }
    }
    return $null
}

function Get-DiscoveryStopDecision {
    <#
    .SYNOPSIS
        Decides one SubagentStop event for a native discovery adapter.
    .DESCRIPTION
        Order: envelope anomalies block; a non-discovery agent type is skipped; a
        missing agent identity, a launching process that is itself a specialist or
        an unattributed principal blocks; the activation must be active; exactly one
        started or finalized invocation must bind this agent; the invocation must be
        finalized with a completion receipt that passes Get-DiscoveryReceiptMismatch;
        finally the final text must state the explicit result the receipt proves.
        When StopHookActive is true a block becomes an allow with code CONTINUED so
        the host does not loop; the authority remains with the receipts.
    .OUTPUTS
        [pscustomobject] Decision, Code, Reason, Receipt, Invocation.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Normalized,
        [Parameter(Mandatory = $true)][hashtable]$Environment,
        [Parameter(Mandatory = $true)][hashtable]$HostEnvironment,
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$AssistantText = '',
        [Parameter(Mandatory = $false)][bool]$StopHookActive = $false,
        [Parameter(Mandatory = $false)][hashtable]$Store = (Get-DiscoveryStartStore),
        [Parameter(Mandatory = $false)][AllowNull()][scriptblock]$ReadBytes = $null
    )

    $outcome = Get-DiscoveryStopVerdict -Normalized $Normalized -Environment $Environment -HostEnvironment $HostEnvironment `
        -AssistantText $AssistantText -Store $Store -ReadBytes $ReadBytes
    if ($outcome.Decision -eq 'block' -and $StopHookActive -and $outcome.Code -ne 'ENVELOPE') {
        return Get-DiscoveryStopOutcome -Decision 'allow' -Code 'CONTINUED' -Reason "$($outcome.Reason) (a continuation was already requested; the protected receipts remain authoritative)" -Receipt $outcome.Receipt -Invocation $outcome.Invocation
    }
    return $outcome
}

function Get-DiscoveryStopVerdict {
    <#
    .SYNOPSIS
        Evaluates the stop without the continuation rule; see Get-DiscoveryStopDecision.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Normalized,
        [Parameter(Mandatory = $true)][hashtable]$Environment,
        [Parameter(Mandatory = $true)][hashtable]$HostEnvironment,
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$AssistantText = '',
        [Parameter(Mandatory = $true)][hashtable]$Store,
        [Parameter(Mandatory = $false)][AllowNull()][scriptblock]$ReadBytes = $null
    )

    if ($null -ne $Normalized.Anomaly) {
        return Get-DiscoveryStopOutcome -Decision 'block' -Code 'ENVELOPE' -Reason ('payload anomaly - ' + (Get-DiscoveryPayloadAnomalyReason -Code $Normalized.Anomaly))
    }
    $agentType = [string]$Normalized.AgentType
    $role = Get-DiscoveryAgentRole -AgentType $agentType
    if ($null -eq $role) {
        return Get-DiscoveryStopOutcome -Decision 'skip' -Code 'NOT_DISCOVERY_AGENT' -Reason 'the stopping agent is not a discovery specialist; the ordinary stop validation applies'
    }
    $agentId = [string]$Normalized.AgentId
    if ($agentId -notmatch $script:CorrelationIdPattern) {
        return Get-DiscoveryStopOutcome -Decision 'block' -Code 'IDENTITY' -Reason 'the native stop event carries no agent identifier for the discovery specialist'
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$Environment['DRM_DISCOVERY_AGENT_ID']) -or -not [string]::IsNullOrWhiteSpace([string]$Environment['DRM_DISCOVERY_AGENT_ROLE'])) {
        return Get-DiscoveryStopOutcome -Decision 'block' -Code 'NESTED' -Reason "discovery specialist $agentType was launched by an attested discovery agent; nested specialists have no stop authority"
    }
    $principal = Get-DiscoveryTrustedPrincipal -Normalized $Normalized -Environment $Environment
    if (-not $principal.Attributed -or $null -eq $principal.ParentAgentId) {
        $reason = $(if ($null -ne $principal.Reason) { $principal.Reason } else { 'the native host attested no parent agent for this launch' })
        return Get-DiscoveryStopOutcome -Decision 'block' -Code 'IDENTITY' -Reason "the stop could not be attributed: $reason"
    }
    if ([string]::IsNullOrWhiteSpace([string]$Normalized.Cwd)) {
        return Get-DiscoveryStopOutcome -Decision 'block' -Code 'WORKSPACE' -Reason 'the native event carries no workspace directory'
    }
    try {
        $location = Resolve-DiscoveryAuthorityLocation -WorkspaceRoot ([string]$Normalized.Cwd) -Platform $HostEnvironment.Platform `
            -UserHome $HostEnvironment.UserHome -LocalAppData $HostEnvironment.LocalAppData -XdgStateHome $HostEnvironment.XdgStateHome
    } catch {
        return Get-DiscoveryStopOutcome -Decision 'block' -Code 'WORKSPACE' -Reason $_.Exception.Message
    }
    $activation = Read-DiscoveryActivationState -Location $location -ReadText $Store.ReadText
    if ($activation.Status -ne 'active') {
        return Get-DiscoveryStopOutcome -Decision 'block' -Code 'ACTIVATION' -Reason "discovery is not active for this workspace ($($activation.Status): $($activation.Reason))"
    }
    $activationText = [string](Invoke-DiscoveryStoreSeam -Seam $Store.ReadText -Arguments @($activation.Path))
    $found = Find-DiscoveryAgentInvocationForStop -Location $location -Principal $principal -AgentType $agentType -AgentId $agentId -Store $Store
    if ($found.Count -eq 0) {
        return Get-DiscoveryStopOutcome -Decision 'block' -Code 'NO_INVOCATION' -Reason "no protected invocation binds agent $agentId ($agentType) in this session; the specialist stopped without an attested start"
    }
    if ($found.Count -gt 1) {
        return Get-DiscoveryStopOutcome -Decision 'block' -Code 'AMBIGUOUS' -Reason "$($found.Count) protected invocations bind agent $agentId; the stop cannot be attributed to one"
    }
    $record = $found.Record
    if ([string]$record.role -cne $role) {
        return Get-DiscoveryStopOutcome -Decision 'block' -Code 'ROLE' -Reason "agent type $agentType acts as $role but the invocation was prepared for role $($record.role)" -Invocation $record
    }
    if ([string]$record.state -ne 'finalized' -or [string]::IsNullOrWhiteSpace([string]$record.completion_receipt_ref)) {
        return Get-DiscoveryStopOutcome -Decision 'block' -Code 'NOT_FINALIZED' -Reason "invocation $($record.invocation_id) was not finalized through finalize_discovery_agent; no output authority exists for this stop" -Invocation $record
    }
    $read = Read-DiscoveryStopJson -Store $Store -Path "$($found.Directory)/$($script:ReceiptsPartition)/$($record.completion_receipt_ref).json"
    if ($null -eq $read.Record) {
        return Get-DiscoveryStopOutcome -Decision 'block' -Code 'RECEIPT' -Reason "the completion receipt $($record.completion_receipt_ref) is missing or unreadable in the protected store" -Invocation $record
    }
    if ($null -eq $ReadBytes) {
        $ReadBytes = {
            param([string]$Path)
            if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
            return [System.IO.File]::ReadAllBytes($Path)
        }
    }
    $mismatch = Get-DiscoveryReceiptMismatch -Receipt $read.Record -Record $record -Principal $principal -AgentId $agentId -Activation $activation.Record `
        -ActivationSha256 (Get-DiscoverySha256Hex -Text $activationText) -Location $location -ReadBytes $ReadBytes
    if ($null -ne $mismatch) {
        return Get-DiscoveryStopOutcome -Decision 'block' -Code $mismatch.Code -Reason $mismatch.Reason -Receipt $read.Record -Invocation $record
    }
    # The final text never grants authority; it must only state the result the receipt proves.
    $expectedToken = $(if ([string]$read.Record.validation_result -eq 'pass') { 'PASS' } else { 'FAIL' })
    $tokens = @([regex]::Matches([string]$AssistantText, $script:ResultTokenPattern) | ForEach-Object { $_.Groups[1].Value })
    if ($tokens -notcontains $expectedToken) {
        return Get-DiscoveryStopOutcome -Decision 'block' -Code 'RESULT_TEXT' -Reason "the final message must state the explicit $expectedToken result the protected receipt proves" -Receipt $read.Record -Invocation $record
    }
    return Get-DiscoveryStopOutcome -Decision 'allow' -Code 'VALIDATED' -Reason "invocation $($record.invocation_id) of $role completed with a current $($read.Record.validation_result) receipt" -Receipt $read.Record -Invocation $record
}

Export-ModuleMember -Function `
    Find-DiscoveryAgentInvocationForStop, `
    Get-DiscoveryReceiptMismatch, `
    Get-DiscoveryStopDecision, `
    Get-DiscoveryStopVerdict
