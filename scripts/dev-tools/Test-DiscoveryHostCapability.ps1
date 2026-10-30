<#
.SYNOPSIS
    Operator entry point that runs a native host's discovery capability probe and reports the verdict.

.DESCRIPTION
    Selects the probe of the named host (Claude Code, Codex or the GitHub Copilot
    local harness) under the workspace root, runs it in-process with the supplied
    session, workspace-trust and runtime identity, writes the
    capability-attestation-shaped JSON it produced and exits with its verdict:
    0 supported, 1 unsupported, 2 when the host is unknown or its probe is absent
    (a missing, disabled or unsupported host is a failure, never a pass). The
    probe never invokes Python or a shell and makes no in-process sentinel
    decision: attribution is proved only from the host observations the native
    PreToolUse gate recorded while the discovery-capability-sentinel agent ran.

.PARAMETER SessionId
    The host session in which the sentinel agent ran. A supported result requires
    it; the default session holds no observations and is reported unsupported.

.PARAMETER HostName
    claude-code, codex or github-copilot.
.PARAMETER WorkspaceRoot
    The repository to probe; defaults to the repository that holds this script.
.PARAMETER WorkspaceTrusted
    Whether the host reports the workspace as trusted; hooks only run in a trusted workspace.
.PARAMETER RuntimeJson
    Optional JSON of the runtime identity (package_version, schema_version, build_sha256, policy_version, policy_sha256).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][ValidateSet('claude-code', 'codex', 'github-copilot')][string]$HostName,
    [Parameter(Mandatory = $false)][string]$WorkspaceRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent),
    [Parameter(Mandatory = $false)][string]$SessionId = 'capability-probe',
    [Parameter(Mandatory = $false)][bool]$WorkspaceTrusted = $true,
    [Parameter(Mandatory = $false)][AllowNull()][string]$RuntimeJson = $null
)

function Resolve-DiscoveryHostProbe {
    <#
    .SYNOPSIS
        Returns the workspace-relative probe script of HostName, or $null for an unknown host.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$HostName)

    switch ($HostName) {
        'claude-code' { return '.claude/hooks/discovery-capability-probe.ps1' }
        'codex' { return '.codex/hooks/discovery-capability-probe.ps1' }
        'github-copilot' { return '.github/hooks/discovery-capability-probe.ps1' }
        default { return $null }
    }
}

function Invoke-DiscoveryHostCapabilityTest {
    <#
    .SYNOPSIS
        Runs the host probe and returns ExitCode plus the document (or an error document when the probe is absent).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][string]$HostName,
        [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)][string]$SessionId,
        [Parameter(Mandatory = $false)][bool]$WorkspaceTrusted = $true,
        [Parameter(Mandatory = $false)][AllowNull()][string]$RuntimeJson = $null,
        [Parameter(Mandatory = $false)][scriptblock]$RunProbe = {
            param([string]$Path, [hashtable]$Arguments)
            . $Path
            return Invoke-DiscoveryCapabilityProbe @Arguments
        }
    )

    $relative = Resolve-DiscoveryHostProbe -HostName $HostName
    $path = $(if ($null -ne $relative) { Join-Path $WorkspaceRoot $relative } else { $null })
    if ($null -eq $path -or -not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $document = [ordered]@{ host = $HostName; status = 'unsupported'; findings = @([ordered]@{ code = 'DISCOVERY_ENFORCEMENT_UNAVAILABLE'; severity = 'error'; message = "No capability probe is installed for host '$HostName' under $WorkspaceRoot."; next_action = 'Install the native discovery hooks for this host before launching discovery agents.' }) }
        return [pscustomobject]@{ ExitCode = 2; Document = $document }
    }
    $arguments = @{ WorkspaceRoot = $WorkspaceRoot; SessionId = $SessionId; WorkspaceTrusted = $WorkspaceTrusted }
    if (-not [string]::IsNullOrWhiteSpace($RuntimeJson)) { $arguments['RuntimeJson'] = $RuntimeJson }
    $observation = & $RunProbe $path $arguments
    return [pscustomobject]@{ ExitCode = $(if ([string]$observation['status'] -eq 'supported') { 0 } else { 1 }); Document = $observation }
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}
$result = Invoke-DiscoveryHostCapabilityTest -HostName $HostName -WorkspaceRoot $WorkspaceRoot -SessionId $SessionId -WorkspaceTrusted $WorkspaceTrusted -RuntimeJson $RuntimeJson
$result.Document | ConvertTo-Json -Depth 8 | Write-Output
exit $result.ExitCode
