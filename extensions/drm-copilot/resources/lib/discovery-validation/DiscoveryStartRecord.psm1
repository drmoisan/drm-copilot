<#
.SYNOPSIS
    Agent-profile, record and store primitives for native discovery start attestation.

.DESCRIPTION
    The SubagentStart adapters of Claude Code, Codex and GitHub Copilot share these
    primitives: the discovery agent-type grammar (four roles with an optional
    complexity suffix), the per-host agent profile location and its Markdown
    front-matter reader, UTC instant coercion for record timestamps, the started
    transition of a protected invocation record (System.Text.Json preserves every
    untouched value verbatim), the `start-attestation` record and the real
    filesystem store seams. Nothing here reads an environment value or decides;
    the decision lives in DiscoveryStart.psm1.

.NOTES
    Issue #980. Compatible with PowerShell 7+. Depends only on the sibling
    DiscoveryEncoding module.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'DiscoveryEncoding.psm1') -ErrorAction Stop

$script:StartAttestationSchema = 'urn:drm-copilot:discovery:2.0.0:start-attestation'
$script:StartAttestationFile = 'start-attestation.json'
$script:DiscoveryAgentTypePattern = '^(?<role>legacy-parity-analyst|runtime-characterization-analyst|requirements-reconciler|migration-coverage-reviewer)(?:-c(?:1|2|3|4|3-elevated))?$'
# Where each host keeps the generated specialist profile the root launches.
$script:AgentProfileLayout = @{
    'claude-code'    = @{ Directory = '.claude/agents'; Suffix = '.md' }
    'codex'          = @{ Directory = '.codex/agents'; Suffix = '.toml' }
    'github-copilot' = @{ Directory = '.github/agents'; Suffix = '.agent.md' }
}

function Get-DiscoveryAgentRole {
    <#
    .SYNOPSIS
        Returns the discovery role named by a native agent type, or $null for any other agent.
    .DESCRIPTION
        `legacy-parity-analyst-c3` and `legacy-parity-analyst` both name the
        legacy-parity-analyst role; the comparison is case-sensitive.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$AgentType)

    if ([string]::IsNullOrWhiteSpace($AgentType)) { return $null }
    $match = [regex]::Match($AgentType, $script:DiscoveryAgentTypePattern)
    if (-not $match.Success) { return $null }
    return $match.Groups['role'].Value
}

function Get-DiscoveryAgentProfilePath {
    <#
    .SYNOPSIS
        Returns the workspace-relative profile path of a native discovery agent on HostName.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('claude-code', 'codex', 'github-copilot')][string]$HostName,
        [Parameter(Mandatory = $true)][string]$AgentType
    )

    if ($AgentType -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$') {
        throw "AGENT_PROFILE_INVALID: '$AgentType' is not a valid agent profile name."
    }
    $layout = $script:AgentProfileLayout[$HostName]
    return "$($layout.Directory)/$AgentType$($layout.Suffix)"
}

function ConvertFrom-DiscoveryMarkdownProfile {
    <#
    .SYNOPSIS
        Reads name, model and effort from the YAML front matter of a Markdown agent profile.
    .DESCRIPTION
        Only scalar `key: value` lines of the first front-matter block are read; a
        missing block or a missing `name` is a typed failure. Model and effort are
        $null when the host profile does not declare them.
    .OUTPUTS
        [pscustomobject] ProfilePath, ProfileSha256, ProfileName, ProfileModel, ProfileReasoningEffort.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text,
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)][string]$Sha256
    )

    $lines = $Text -split "`r?`n"
    if ($lines.Count -lt 2 -or $lines[0].Trim() -ne '---') {
        throw "AGENT_PROFILE_INVALID: '$RelativePath' has no YAML front matter."
    }
    $values = @{}
    $closed = $false
    foreach ($line in $lines[1..($lines.Count - 1)]) {
        if ($line.Trim() -eq '---') { $closed = $true; break }
        if ($line -match '^(?<key>[A-Za-z_][A-Za-z0-9_-]*):\s*(?<value>[^#]*?)\s*(?:#.*)?$' -and -not [string]::IsNullOrWhiteSpace($Matches['value'])) {
            $values[$Matches['key']] = $Matches['value'].Trim().Trim('"', "'")
        }
    }
    if (-not $closed) { throw "AGENT_PROFILE_INVALID: '$RelativePath' has an unterminated front-matter block." }
    if (-not $values.ContainsKey('name')) { throw "AGENT_PROFILE_INVALID: '$RelativePath' declares no name." }
    return [pscustomobject]@{
        ProfilePath            = $RelativePath
        ProfileSha256          = $Sha256
        ProfileName            = [string]$values['name']
        ProfileModel           = $(if ($values.ContainsKey('model')) { [string]$values['model'] } else { $null })
        ProfileReasoningEffort = $(if ($values.ContainsKey('effort')) { [string]$values['effort'] } elseif ($values.ContainsKey('reasoning_effort')) { [string]$values['reasoning_effort'] } else { $null })
    }
}

function Read-DiscoveryAgentProfile {
    <#
    .SYNOPSIS
        Reads and hashes the Markdown agent profile of AgentType under WorkspaceRoot.
    .DESCRIPTION
        Claude Code and GitHub Copilot profiles are Markdown with front matter; the
        Codex adapter reads its TOML profiles through its own parser and converts the
        result, so this reader refuses the codex host. ReadBytes is the filesystem seam.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('claude-code', 'github-copilot')][string]$HostName,
        [Parameter(Mandatory = $true)][string]$AgentType,
        [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
        [Parameter(Mandatory = $false)][scriptblock]$ReadBytes = {
            param([string]$Path)
            if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
            return [System.IO.File]::ReadAllBytes($Path)
        }
    )

    $relativePath = Get-DiscoveryAgentProfilePath -HostName $HostName -AgentType $AgentType
    $bytes = & $ReadBytes "$($WorkspaceRoot.TrimEnd('/', '\'))/$relativePath"
    if ($null -eq $bytes) { throw "AGENT_PROFILE_INVALID: '$relativePath' does not exist." }
    $bytes = [byte[]]$bytes
    try {
        $text = [System.Text.UTF8Encoding]::new($false, $true).GetString($bytes)
    } catch {
        throw "AGENT_PROFILE_INVALID: '$relativePath' is not valid UTF-8."
    }
    return ConvertFrom-DiscoveryMarkdownProfile -Text $text -RelativePath $relativePath -Sha256 (Get-DiscoveryBytesSha256Hex -Bytes $bytes)
}

function ConvertTo-DiscoveryUtcInstant {
    <#
    .SYNOPSIS
        Coerces a decoded JSON timestamp (string or DateTime) to a UTC DateTime, or $null.
    #>
    [CmdletBinding()]
    [OutputType([nullable[datetime]])]
    param([Parameter(Mandatory = $false)][AllowNull()][object]$Value)

    if ($Value -is [datetime]) { return $Value.ToUniversalTime() }
    if ($Value -is [datetimeoffset]) { return $Value.UtcDateTime }
    $parsed = [datetimeoffset]::MinValue
    $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
    if ($Value -is [string] -and [datetimeoffset]::TryParse($Value, [cultureinfo]::InvariantCulture, $styles, [ref]$parsed)) { return $parsed.UtcDateTime }
    return $null
}

function ConvertTo-DiscoveryStartedInvocationText {
    <#
    .SYNOPSIS
        Rewrites a prepared invocation record text to the started state.
    .DESCRIPTION
        Only `state`, `agent_id` and `start_attestation_ref` change; every other value,
        including timestamps, keeps its original spelling because the document is
        edited as a JSON node tree rather than re-serialized from PowerShell objects.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$AgentId,
        [Parameter(Mandatory = $true)][string]$StartAttestationRef
    )

    $node = [System.Text.Json.Nodes.JsonNode]::Parse($Text)
    if ($node -isnot [System.Text.Json.Nodes.JsonObject]) { throw 'INVOCATION_RECORD_INVALID: the invocation record is not a JSON object.' }
    $node['state'] = [System.Text.Json.Nodes.JsonValue]::Create('started')
    $node['agent_id'] = [System.Text.Json.Nodes.JsonValue]::Create($AgentId)
    $node['start_attestation_ref'] = [System.Text.Json.Nodes.JsonValue]::Create($StartAttestationRef)
    $options = [System.Text.Json.JsonSerializerOptions]::new()
    $options.WriteIndented = $true
    $options.Encoder = [System.Text.Encodings.Web.JavaScriptEncoder]::UnsafeRelaxedJsonEscaping
    return $node.ToJsonString($options) + "`n"
}

function ConvertTo-DiscoveryStartAttestationRecord {
    <#
    .SYNOPSIS
        Builds the `start-attestation` record binding the trusted principal to one prepared invocation.
    .DESCRIPTION
        Every identity value comes from the principal, the protected record and the
        host's profile read; the SubagentStart payload contributes only the agent
        identifier the host assigned. ActualModel and ActualReasoningEffort are $null
        when the host does not expose them in its start event.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Principal,
        [Parameter(Mandatory = $true)][string]$AgentId,
        [Parameter(Mandatory = $true)][string]$AgentType,
        [Parameter(Mandatory = $true)][pscustomobject]$Record,
        [Parameter(Mandatory = $true)][pscustomobject]$AgentProfile,
        [Parameter(Mandatory = $false)][AllowNull()][string]$ActualModel,
        [Parameter(Mandatory = $false)][AllowNull()][string]$ActualReasoningEffort,
        [Parameter(Mandatory = $true)][string]$HandlerSha256,
        [Parameter(Mandatory = $true)][datetime]$Now,
        [Parameter(Mandatory = $true)][string]$Nonce
    )

    return [ordered]@{
        '$schema'             = $script:StartAttestationSchema
        schema_version        = '2.0.0'
        artifact_kind         = 'start-attestation'
        id                    = "start-$Nonce"
        start_attestation_ref = "start-$Nonce"
        invocation_ref        = [string]$Record.invocation_id
        workspace             = [ordered]@{
            workspace_root   = [string]$Record.workspace.workspace_root
            workspace_sha256 = [string]$Record.workspace.workspace_sha256
            profile_path     = [string]$Record.workspace.profile_path
            profile_sha256   = [string]$Record.workspace.profile_sha256
        }
        host                  = $Principal.HostName
        session_id            = $Principal.SessionId
        parent_agent_id       = $Principal.ParentAgentId
        agent_id              = $AgentId
        agent_type            = $AgentType
        role                  = [string]$Record.role
        deployment            = [ordered]@{
            agent_name       = [string]$Record.deployment.agent_name
            model            = [string]$Record.deployment.model
            reasoning_effort = [string]$Record.deployment.reasoning_effort
            actual_model     = $(if ([string]::IsNullOrEmpty($ActualModel)) { $null } else { $ActualModel })
            actual_effort    = $(if ([string]::IsNullOrEmpty($ActualReasoningEffort)) { $null } else { $ActualReasoningEffort })
        }
        agent_profile         = [ordered]@{
            path   = $AgentProfile.ProfilePath
            sha256 = $AgentProfile.ProfileSha256
            name   = $AgentProfile.ProfileName
        }
        capability_ref        = [string]$Record.capability_ref
        runtime               = $Record.runtime
        attested_at           = $Now.ToUniversalTime().ToString("yyyy-MM-dd'T'HH:mm:ss'Z'")
        writer                = [ordered]@{ host = $Principal.HostName; event = 'SubagentStart'; handler_sha256 = $HandlerSha256 }
    }
}

function Get-DiscoveryStartStore {
    <#
    .SYNOPSIS
        Returns the real-filesystem store seams (ReadText, ListEntries, WriteText, ReplaceText).
    .DESCRIPTION
        WriteText creates the attestation exclusively, so a second start for the same
        invocation fails; ReplaceText rewrites the invocation record in place.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    return @{
        ReadText    = {
            param([string]$Path)
            if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
            return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
        }
        ListEntries = {
            param([string]$Directory)
            if (-not (Test-Path -LiteralPath $Directory -PathType Container)) { return @() }
            return @(Get-ChildItem -LiteralPath $Directory -Force | Sort-Object -Property Name | ForEach-Object { $_.Name })
        }
        WriteText   = {
            param([string]$Path, [string]$Text)
            $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
            try {
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
                $stream.Write($bytes, 0, $bytes.Length)
            } finally { $stream.Dispose() }
        }
        ReplaceText = {
            param([string]$Path, [string]$Text)
            [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
        }
    }
}

function Get-DiscoveryStartAttestationFileName {
    <#
    .SYNOPSIS
        Returns the file name of the start attestation inside an invocation directory.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return $script:StartAttestationFile
}

Export-ModuleMember -Function `
    Get-DiscoveryAgentRole, `
    Get-DiscoveryAgentProfilePath, `
    ConvertFrom-DiscoveryMarkdownProfile, `
    Read-DiscoveryAgentProfile, `
    ConvertTo-DiscoveryUtcInstant, `
    ConvertTo-DiscoveryStartedInvocationText, `
    ConvertTo-DiscoveryStartAttestationRecord, `
    Get-DiscoveryStartStore, `
    Get-DiscoveryStartAttestationFileName
