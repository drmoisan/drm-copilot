<#
.SYNOPSIS
    Tool-name routing, controlled-operation derivation and request digests for the discovery gates.

.DESCRIPTION
    Every native discovery PreToolUse adapter classifies the host tool name into a
    family (controlled discovery MCP tool, foreign MCP server, shell, mutation,
    spawn, read-only native, other), derives the controlled operation a discovery
    tool performs from its input, and digests the request exactly as the gateway
    does: `sha256(canonical_json({inputs, operation, tool}))`. The fixed tables
    (controlled tools and their operations, root-only tools and operations, the
    caller identity fields tool input must never carry) live here and are exposed
    through read-only accessors, so DiscoveryAuthorization.psm1 and
    DiscoveryPlanning.psm1 share one routing surface.

    Pure functions over strings and objects: no filesystem access, no process, no
    network, no clock and no environment read.

.NOTES
    Issue #980. Compatible with PowerShell 7+. Depends only on the sibling
    DiscoveryEncoding module.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'DiscoveryEncoding.psm1') -ErrorAction Stop

$script:ControlledToolOperations = [ordered]@{
    read_discovery_source             = @('read-source')
    run_discovery_repo_inventory      = @('inventory')
    run_discovery_dotnet_analyzer     = @('inventory')
    run_discovery_vsto_analyzer       = @('inventory')
    create_discovery_artifact         = @('new-contract', 'new-scenario')
    update_discovery_artifact         = @('update-artifact')
    link_discovery_evidence           = @('link-evidence')
    run_discovery_scenario_generation = @('generate-acceptance')
    run_discovery_report              = @('coverage-report', 'parity-report', 'completion-report')
    validate_discovery_artifacts      = @('profile', 'validate-profile', 'validate-feature-contract', 'validate-coverage-ledger', 'validate-runtime-scenario', 'validate-parity-matrix', 'validate-unspecified-behavior', 'validate-product-decision', 'validate-evidence-reference', 'validate-decisions', 'validate-all')
    finalize_discovery_agent          = @('finalize-agent')
}
$script:RootOnlyOperations = @('init', 'configure', 'snapshot-export', 'snapshot-import', 'import-inventory', 'migrate', 'doctor', 'prepare-agent')
$script:RootOnlyTools = @('run_discovery_init', 'configure_discovery_workspace', 'prepare_discovery_agent', 'run_discovery_doctor', 'transfer_discovery_snapshot', 'import_discovery_inventory', 'migrate_discovery_artifacts')
$script:DiscoveryServerAliases = @('drm-copilot', 'drmCopilotExtension', 'drm_copilot')
$script:CallerIdentityKeys = @('agent_id', 'host', 'invocation_id', 'request_id', 'role', 'session_id')
$script:ValidateArtifactOperations = @{
    'profile' = 'validate-profile'; 'domain-profile' = 'validate-profile'; 'feature-contract' = 'validate-feature-contract'
    'coverage-ledger' = 'validate-coverage-ledger'; 'runtime-scenario' = 'validate-runtime-scenario'
    'runtime-characterization-scenario' = 'validate-runtime-scenario'; 'parity-matrix' = 'validate-parity-matrix'
    'unspecified-behavior' = 'validate-unspecified-behavior'; 'product-decision' = 'validate-product-decision'
    'evidence-reference' = 'validate-evidence-reference'; 'decisions' = 'validate-decisions'; 'all' = 'validate-all'
}
# Tool-name families. A shell-like token anywhere in a native tool name denies it;
# the mutation, spawn and read families are matched on the whole name.
$script:ShellToolPattern = '(?i)(^|[_.-])(bash|sh|zsh|shell|terminal|exec|execute|eval|cmd|powershell|pwsh|command)([_.-]|$)'
$script:MutationToolPattern = '(?i)^(write|edit|multiedit|notebookedit|apply_patch|create_file|edit_file|write_file|delete_file|delete|insert_edit_into_file|replace_string_in_file|create_directory|move_file|rename_file|remove_file)$'
$script:SpawnToolPattern = '(?i)^(agent|task|spawn_agent|run_subagent|runsubagent|delegate)$'
$script:ReadToolPattern = '(?i)^(read|glob|grep|ls|list_dir|list_directory|read_file|file_search|grep_search|semantic_search|get_file|todoread)$'

function Get-DiscoveryControlledToolName {
    <#
    .SYNOPSIS
        Returns the names of the controlled discovery tools, in table order.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()

    return [string[]]@($script:ControlledToolOperations.Keys)
}

function Get-DiscoveryRootOnlyToolName {
    <#
    .SYNOPSIS
        Returns the names of the root-only discovery tools.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()

    return [string[]]$script:RootOnlyTools
}

function Get-DiscoveryRootOnlyOperationName {
    <#
    .SYNOPSIS
        Returns the names of the root-only discovery operations.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()

    return [string[]]$script:RootOnlyOperations
}

function Get-DiscoveryCallerIdentityKey {
    <#
    .SYNOPSIS
        Returns the tool-input field names that would assert an identity and are therefore refused.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param()

    return [string[]]$script:CallerIdentityKeys
}

function Resolve-DiscoveryToolName {
    <#
    .SYNOPSIS
        Classifies a host tool name into a family and, for MCP tools, its server and tool.
    .OUTPUTS
        [pscustomobject] Family (mcp-discovery, mcp-other, shell, mutation, spawn, read, other), Server, Name.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$ToolName)

    $name = [string]$ToolName
    $match = [regex]::Match($name, '^mcp__(?<server>[^_][^_]*?(?:_[^_]+)*?)__(?<tool>[A-Za-z0-9_.-]+)$')
    # Decision order: an MCP tool is routed by its server; a native tool by the
    # shell, mutation, spawn and read families; anything else is unknown.
    if ($match.Success) {
        $server = $match.Groups['server'].Value
        $family = $(if ($script:DiscoveryServerAliases -contains $server) { 'mcp-discovery' } else { 'mcp-other' })
        return [pscustomobject]@{ Family = $family; Server = $server; Name = $match.Groups['tool'].Value }
    }
    $family = 'other'
    if ($name -match $script:ShellToolPattern) { $family = 'shell' }
    elseif ($name -match $script:MutationToolPattern) { $family = 'mutation' }
    elseif ($name -match $script:SpawnToolPattern) { $family = 'spawn' }
    elseif ($name -match $script:ReadToolPattern) { $family = 'read' }
    return [pscustomobject]@{ Family = $family; Server = $null; Name = $name }
}

function Get-DiscoveryInputMember {
    <#
    .SYNOPSIS
        Reads one member of a tool-input object (hashtable or PSCustomObject), or $null.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)][object]$ToolInput,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if ($ToolInput -is [System.Collections.IDictionary]) {
        if ($ToolInput.Contains($Name)) { return $ToolInput[$Name] }
        return $null
    }
    $property = $ToolInput.PSObject.Properties[$Name]
    if ($null -eq $property) { return $null }
    return $property.Value
}

function Get-DiscoveryToolOperation {
    <#
    .SYNOPSIS
        Derives the controlled operation a tool call performs from the tool and its input.
    .DESCRIPTION
        Single-operation tools map directly. create_discovery_artifact selects by
        artifact_kind, run_discovery_report by report_type, and
        validate_discovery_artifacts by artifact_type (validate-all when absent).
        Returns $null when the operation cannot be derived, which the caller denies.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$Tool,
        [Parameter(Mandatory = $true)][object]$ToolInput
    )

    if (-not $script:ControlledToolOperations.Contains($Tool)) { return $null }
    $operations = @($script:ControlledToolOperations[$Tool])
    if ($operations.Count -eq 1) { return $operations[0] }
    # Multi-operation tools select by one input field; an unknown value is refused.
    switch ($Tool) {
        'create_discovery_artifact' {
            $kind = [string](Get-DiscoveryInputMember -ToolInput $ToolInput -Name 'artifact_kind')
            if ($kind -eq 'feature-contract') { return 'new-contract' }
            if ($kind -eq 'runtime-scenario' -or $kind -eq 'runtime-characterization-scenario') { return 'new-scenario' }
            return $null
        }
        'run_discovery_report' {
            $report = [string](Get-DiscoveryInputMember -ToolInput $ToolInput -Name 'report_type')
            if ($report -in @('coverage', 'parity', 'completion')) { return "$report-report" }
            return $null
        }
        'validate_discovery_artifacts' {
            $type = Get-DiscoveryInputMember -ToolInput $ToolInput -Name 'artifact_type'
            if ($null -eq $type) { return 'validate-all' }
            if ($script:ValidateArtifactOperations.ContainsKey([string]$type)) { return $script:ValidateArtifactOperations[[string]$type] }
            return $null
        }
    }
    return $null
}

function Get-DiscoveryInputDigest {
    <#
    .SYNOPSIS
        Returns sha256(canonical_json({inputs, operation, tool})) for a controlled request.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][string]$Tool,
        [Parameter(Mandatory = $true)][string]$Operation,
        [Parameter(Mandatory = $true)][object]$Inputs
    )

    $payload = [ordered]@{ inputs = $Inputs; operation = $Operation; tool = $Tool }
    return Get-DiscoverySha256Hex -Text (ConvertTo-DiscoveryCanonicalJson -Value $payload)
}

Export-ModuleMember -Function `
    Get-DiscoveryControlledToolName, `
    Get-DiscoveryRootOnlyToolName, `
    Get-DiscoveryRootOnlyOperationName, `
    Get-DiscoveryCallerIdentityKey, `
    Resolve-DiscoveryToolName, `
    Get-DiscoveryInputMember, `
    Get-DiscoveryToolOperation, `
    Get-DiscoveryInputDigest
