#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Decision-matrix tests for `.claude/lib/discovery-validation/DiscoveryAuthorization.psm1` (issue #980).
.DESCRIPTION
    Proves invocation binding and the full PreToolUse decision over an in-memory
    protected store with payload-attributed identity: root grants, the sentinel
    observation, specialist routing, the invocation_ref binding and the first-call
    start. Tool-family routing, operation derivation and digest parity live in the
    DiscoveryToolRouting suite. No file, process, network or clock is touched.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $lib = Join-Path $script:RepoRoot '.claude/lib/discovery-validation'
    # Leaf modules are imported last so no nested import replaces a visible one.
    Import-Module (Join-Path $lib 'DiscoveryAuthorization.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryStart.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryStartRecord.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryObservation.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryRootGrant.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryToolRouting.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryPayload.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryAuthority.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryEncoding.psm1') -Force
    . (Join-Path $PSScriptRoot 'DiscoveryGate.TestSupport.ps1')
    . (Join-Path $PSScriptRoot 'DiscoveryStart.TestSupport.ps1')

    function Get-Outcome {
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            [Parameter(Mandatory = $true)][string]$ToolName,
            [Parameter(Mandatory = $false)][AllowNull()][object]$ToolInput = @{},
            [Parameter(Mandatory = $false)][hashtable]$Store = (Get-GateStore),
            [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
            [Parameter(Mandatory = $false)][string]$SessionId = 'session-alpha',
            [Parameter(Mandatory = $false)][AllowNull()][string]$AgentId = 'agent-alpha',
            [Parameter(Mandatory = $false)][AllowNull()][string]$AgentType = 'legacy-parity-analyst',
            [Parameter(Mandatory = $false)][AllowNull()][string]$ParentAgentId = $null,
            [Parameter(Mandatory = $false)][string]$Nonce = $script:GateNonce,
            [Parameter(Mandatory = $false)][string]$ToolUseId = 'tool-use-alpha'
        )

        $json = Get-GateEnvelope -HostName $HostName -ToolName $ToolName -ToolInput $ToolInput -SessionId $SessionId -AgentId $AgentId -AgentType $AgentType -ParentAgentId $ParentAgentId -ToolUseId $ToolUseId
        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName $HostName -Text $json
        return Get-DiscoveryPreToolDecision -Normalized $normalized -HostEnvironment $script:GateHostEnvironment `
            -HandlerSha256 ('ab' * 32) -Store $Store -Now $script:GateNow -Nonce $Nonce
    }

    function Get-BoundInput {
        [CmdletBinding()]
        [OutputType([System.Collections.Specialized.OrderedDictionary])]
        param([Parameter(Mandatory = $false)][string]$InvocationRef = 'invocation-alpha')
        $bound = [ordered]@{ workspace_root = $script:GateWorkspaceRoot }
        foreach ($key in (Get-GateInventoryInput).Keys) { $bound[$key] = (Get-GateInventoryInput)[$key] }
        $bound['invocation_ref'] = $InvocationRef
        return $bound
    }

    function Get-FirstCallStore {
        # A start store (prepared invocation, capability) with the profile reader seam the gate needs to start it.
        [CmdletBinding()]
        [OutputType([hashtable])]
        param([Parameter(Mandatory = $false)][hashtable]$Options = @{})
        $store = Get-StartStore @Options
        $store['ReadBytes'] = Get-StartProfileReader
        return $store
    }
}

Describe 'Find-DiscoveryAgentInvocation' {
    It 'returns the single started invocation bound to the principal and ignores unreadable neighbours' {
        $store = Get-GateStore
        $store.Files["$($script:GateLocation.Directory)/sessions/$(Get-DiscoverySha256Hex -Text 'session-alpha')/invocations/zzzz/invocation.json"] = '{'
        $principal = [pscustomobject]@{ HostName = 'claude-code'; SessionId = 'session-alpha'; AgentId = 'agent-alpha'; Role = 'legacy-parity-analyst' }
        $found = Find-DiscoveryAgentInvocation -Location $script:GateLocation -Principal $principal -Store $store
        $found.Record.invocation_id | Should -Be 'invocation-alpha'
        $found.Directory | Should -Be $script:GateInvocationDirectory
    }

    It 'returns nothing for <Name>' -ForEach @(
        @{ Name = 'a prepared (not started) invocation'; Overrides = @{ state = 'prepared' }; AgentId = 'agent-alpha' }
        @{ Name = 'a missing start attestation'; Overrides = @{ start_attestation_ref = $null }; AgentId = 'agent-alpha' }
        @{ Name = 'another agent'; Overrides = @{}; AgentId = 'agent-beta' }
        @{ Name = 'another role'; Overrides = @{ role = 'requirements-reconciler' }; AgentId = 'agent-alpha' }
    ) {
        $store = Get-GateStore -InvocationOverrides $Overrides
        $principal = [pscustomobject]@{ HostName = 'claude-code'; SessionId = 'session-alpha'; AgentId = $AgentId; Role = 'legacy-parity-analyst' }
        Find-DiscoveryAgentInvocation -Location $script:GateLocation -Principal $principal -Store $store | Should -BeNullOrEmpty
    }

    It 'returns nothing when two started invocations claim the same agent' {
        $store = Get-GateStore
        $store.Files["$($script:GateLocation.Directory)/sessions/$(Get-DiscoverySha256Hex -Text 'session-alpha')/invocations/other/invocation.json"] = Get-GateInvocationText
        $principal = [pscustomobject]@{ HostName = 'claude-code'; SessionId = 'session-alpha'; AgentId = 'agent-alpha'; Role = 'legacy-parity-analyst' }
        Find-DiscoveryAgentInvocation -Location $script:GateLocation -Principal $principal -Store $store | Should -BeNullOrEmpty
    }
}

Describe 'Get-DiscoveryPreToolDecision for the root' {
    It 'allows <Tool> from the root with code ROOT and writes nothing' -ForEach @(
        @{ Tool = 'Read' }; @{ Tool = 'Bash' }; @{ Tool = 'Write' }; @{ Tool = 'mcp__github__create_issue' }; @{ Tool = 'mcp__drm-copilot__run_discovery_init' }
    ) {
        $store = Get-StartStore
        $outcome = Get-Outcome -ToolName $Tool -AgentId $null -AgentType $null -Store $store
        $outcome.Decision | Should -Be 'allow' -Because $Tool
        $outcome.Code | Should -Be 'ROOT'
        $store.Writes.Count | Should -Be 0
    }

    It 'writes one root grant for <Name> with operation <Operation>' -ForEach @(
        @{ Name = 'prepare'; Tool = 'mcp__drm-copilot__prepare_discovery_agent'; Arguments = @{ workspace_root = 'C:/Users/Example/Repos/Workspace'; skill_id = 'inventory-legacy-system' }; Operation = 'prepare-agent' }
        @{ Name = 'the doctor'; Tool = 'mcp__drm-copilot__run_discovery_doctor'; Arguments = @{ workspace_root = 'C:/Users/Example/Repos/Workspace' }; Operation = 'doctor' }
        @{ Name = 'read_discovery_source'; Tool = 'mcp__drm-copilot__read_discovery_source'; Arguments = @{ paths = @('src') }; Operation = 'read-source' }
        @{ Name = 'run_discovery_repo_inventory'; Tool = 'mcp__drm-copilot__run_discovery_repo_inventory'; Arguments = @{ analyzer_ids = @('repository') }; Operation = 'inventory' }
        @{ Name = 'run_discovery_dotnet_analyzer'; Tool = 'mcp__drm-copilot__run_discovery_dotnet_analyzer'; Arguments = @{}; Operation = 'inventory' }
        @{ Name = 'run_discovery_vsto_analyzer'; Tool = 'mcp__drm-copilot__run_discovery_vsto_analyzer'; Arguments = @{}; Operation = 'inventory' }
        @{ Name = 'create_discovery_artifact'; Tool = 'mcp__drm-copilot__create_discovery_artifact'; Arguments = @{ artifact_kind = 'feature-contract' }; Operation = 'new-contract' }
        @{ Name = 'update_discovery_artifact'; Tool = 'mcp__drm-copilot__update_discovery_artifact'; Arguments = @{ artifact_id = 'x' }; Operation = 'update-artifact' }
        @{ Name = 'link_discovery_evidence'; Tool = 'mcp__drm-copilot__link_discovery_evidence'; Arguments = @{}; Operation = 'link-evidence' }
        @{ Name = 'run_discovery_scenario_generation'; Tool = 'mcp__drm-copilot__run_discovery_scenario_generation'; Arguments = @{}; Operation = 'generate-acceptance' }
        @{ Name = 'run_discovery_report'; Tool = 'mcp__drm-copilot__run_discovery_report'; Arguments = @{ report_type = 'parity' }; Operation = 'parity-report' }
        @{ Name = 'validate_discovery_artifacts'; Tool = 'mcp__drm-copilot__validate_discovery_artifacts'; Arguments = @{}; Operation = 'validate-all' }
        @{ Name = 'finalize_discovery_agent'; Tool = 'mcp__drm-copilot__finalize_discovery_agent'; Arguments = @{}; Operation = 'finalize-agent' }
    ) {
        $store = Get-StartStore
        $outcome = Get-Outcome -ToolName $Tool -ToolInput $Arguments -AgentId $null -AgentType $null -Store $store
        $outcome.Decision | Should -Be 'allow' -Because $outcome.Reason
        $outcome.Code | Should -Be 'ROOT_GRANTED'
        $outcome.RecordPath | Should -Be "$(Get-DiscoveryRootGrantDirectory -Location $script:GateLocation)/grant-$($script:GateNonce).json"
        $store.Writes | Should -Be @($outcome.RecordPath)
        $record = $store.Files[$outcome.RecordPath] | ConvertFrom-Json
        $record.artifact_kind | Should -Be 'root-grant'
        $record.tool | Should -Be ($Tool -replace '^mcp__drm-copilot__', '')
        $record.operation | Should -Be $Operation
        $record.parent_agent_id | Should -Be 'root'
        $record.session_id | Should -Be 'session-alpha'
        $record.input_sha256 | Should -Be (Get-DiscoveryInputDigest -Tool $record.tool -Operation $Operation -Inputs $Arguments)
        $record.tool_use_id | Should -Be 'tool-use-alpha'
        $record.state | Should -Be 'issued'
    }

    It 'denies a prepare and a controlled root call with CAPABILITY when the session attestation is <Name>, but still grants the doctor' -ForEach @(
        @{ Name = 'absent'; Options = @{ NoCapability = $true } }
        @{ Name = 'unsupported'; Options = @{ CapabilityOverrides = @{ status = 'unsupported' } } }
        @{ Name = 'expired'; Options = @{ CapabilityOverrides = @{ expires_at = '2026-10-22T11:59:59Z' } } }
    ) {
        $store = Get-StartStore @Options
        (Get-Outcome -ToolName 'mcp__drm-copilot__prepare_discovery_agent' -ToolInput @{ skill_id = 'x' } -AgentId $null -AgentType $null -Store $store).Code | Should -Be 'CAPABILITY'
        (Get-Outcome -ToolName 'mcp__drm-copilot__read_discovery_source' -ToolInput @{ paths = @('src') } -AgentId $null -AgentType $null -Store $store).Code | Should -Be 'CAPABILITY'
        $store.Writes.Count | Should -Be 0
        (Get-Outcome -ToolName 'mcp__drm-copilot__run_discovery_doctor' -ToolInput @{} -AgentId $null -AgentType $null -Store $store).Code | Should -Be 'ROOT_GRANTED'
    }

    It 'denies a root call that carries <Name>' -ForEach @(
        @{ Name = 'invocation_ref'; Arguments = @{ paths = @('src'); invocation_ref = 'invocation-alpha' }; Code = 'INVOCATION_REF' }
        @{ Name = 'an identity field'; Arguments = @{ paths = @('src'); agent_id = 'agent-alpha' }; Code = 'CALLER_IDENTITY' }
        @{ Name = 'an underivable operation'; Arguments = @{ artifact_kind = 'mystery' }; Code = 'OPERATION'; Tool = 'mcp__drm-copilot__create_discovery_artifact' }
        @{ Name = 'no workspace directory'; Arguments = @{ paths = @('src') }; Code = 'WORKSPACE'; Cwd = '' }
    ) {
        $store = Get-StartStore
        $tool = $(if (Get-Variable -Name Tool -ErrorAction SilentlyContinue) { $Tool } else { 'mcp__drm-copilot__read_discovery_source' })
        if (Get-Variable -Name Cwd -ErrorAction SilentlyContinue) {
            $json = Get-GateEnvelope -ToolName $tool -ToolInput $Arguments -AgentId $null -AgentType $null -Cwd $Cwd
            $outcome = Get-DiscoveryPreToolDecision -Normalized (ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text $json) -HostEnvironment $script:GateHostEnvironment -HandlerSha256 ('ab' * 32) -Store $store -Now $script:GateNow -Nonce $script:GateNonce
        } else {
            $outcome = Get-Outcome -ToolName $tool -ToolInput $Arguments -AgentId $null -AgentType $null -Store $store
        }
        $outcome.Decision | Should -Be 'deny'
        $outcome.Code | Should -Be $Code
        $store.Writes.Count | Should -Be 0
    }

    It 'denies a second root grant that collides in the store' {
        $store = Get-StartStore
        (Get-Outcome -ToolName 'mcp__drm-copilot__run_discovery_doctor' -AgentId $null -AgentType $null -Store $store).Code | Should -Be 'ROOT_GRANTED'
        (Get-Outcome -ToolName 'mcp__drm-copilot__run_discovery_doctor' -AgentId $null -AgentType $null -Store $store).Code | Should -Be 'STORE'
    }

    It 'allows every tool for an agent that is not a discovery specialist and writes nothing' {
        $store = Get-StartStore
        foreach ($tool in @('Bash', 'Write', 'mcp__github__create_issue', 'mcp__drm-copilot__prepare_discovery_agent')) {
            $outcome = Get-Outcome -ToolName $tool -AgentId 'agent-other' -AgentType 'atomic-executor-c3' -Store $store
            $outcome.Decision | Should -Be 'allow' -Because $tool
            $outcome.Code | Should -Be 'NOT_DISCOVERY_AGENT'
        }
        (Get-Outcome -ToolName 'Bash' -AgentId 'agent-other' -AgentType $null -Store $store).Code | Should -Be 'NOT_DISCOVERY_AGENT'
        $store.Writes.Count | Should -Be 0
    }

    It 'denies a discovery agent type whose agent identifier is unusable with IDENTITY' {
        (Get-Outcome -ToolName 'Read' -AgentId 'agent alpha').Code | Should -Be 'IDENTITY'
        $anomalous = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text '{'
        (Get-DiscoveryPreToolDecision -Normalized $anomalous -HostEnvironment $script:GateHostEnvironment -HandlerSha256 ('ab' * 32) -Store (Get-GateStore) -Now $script:GateNow -Nonce $script:GateNonce).Code | Should -Be 'ENVELOPE'
    }
}

Describe 'Get-DiscoveryPreToolDecision for a specialist' {
    It 'denies <Name> with <Code>' -ForEach @(
        @{ Name = 'a shell tool'; Tool = 'Bash'; Arguments = @{ command = 'rm -rf .' }; Code = 'SHELL' }
        @{ Name = 'a terminal tool'; Tool = 'run_in_terminal'; Arguments = @{ command = 'ls' }; Code = 'SHELL' }
        @{ Name = 'a generic write'; Tool = 'Write'; Arguments = @{ file_path = 'src/Orders.cs'; content = 'x' }; Code = 'MUTATION' }
        @{ Name = 'a generic edit'; Tool = 'Edit'; Arguments = @{ file_path = 'docs/migration/discovery/domain-profile.yaml'; old_string = 'a'; new_string = 'b' }; Code = 'MUTATION' }
        @{ Name = 'an apply_patch'; Tool = 'apply_patch'; Arguments = @{ input = '*** Begin Patch' }; Code = 'MUTATION' }
        @{ Name = 'a nested agent launch'; Tool = 'Agent'; Arguments = @{ prompt = 'x' }; Code = 'SPAWN' }
        @{ Name = 'a foreign MCP server'; Tool = 'mcp__github__create_issue'; Arguments = @{ title = 'x' }; Code = 'FOREIGN_MCP' }
        @{ Name = 'an unknown native tool'; Tool = 'WebFetch'; Arguments = @{ url = 'https://example.test' }; Code = 'UNKNOWN_TOOL' }
        @{ Name = 'a root-only discovery tool'; Tool = 'mcp__drm-copilot__prepare_discovery_agent'; Arguments = @{ skill_id = 'x' }; Code = 'ROOT_ONLY' }
        @{ Name = 'the doctor tool'; Tool = 'mcp__drm-copilot__run_discovery_doctor'; Arguments = @{}; Code = 'ROOT_ONLY' }
        @{ Name = 'an approval tool'; Tool = 'mcp__drm-copilot__approve_discovery_decision'; Arguments = @{ decision_id = 'x' }; Code = 'UNKNOWN_TOOL' }
        @{ Name = 'a caller identity field'; Tool = 'mcp__drm-copilot__read_discovery_source'; Arguments = @{ paths = @('src'); role = 'root' }; Code = 'CALLER_IDENTITY' }
        @{ Name = 'an underivable operation'; Tool = 'mcp__drm-copilot__create_discovery_artifact'; Arguments = @{ artifact_kind = 'mystery' }; Code = 'OPERATION' }
    ) {
        $store = Get-GateStore
        $outcome = Get-Outcome -ToolName $Tool -ToolInput $Arguments -Store $store
        $outcome.Decision | Should -Be 'deny'
        $outcome.Code | Should -Be $Code
        $outcome.Reason | Should -Not -BeNullOrEmpty
        $store.Writes.Count | Should -Be 0
    }

    It 'allows read-only native tools without writing a record' {
        $store = Get-GateStore
        $outcome = Get-Outcome -ToolName 'Read' -ToolInput @{ file_path = 'src/Orders.cs' } -Store $store
        $outcome.Decision | Should -Be 'allow'
        $outcome.Code | Should -Be 'READ_ONLY'
        $store.Writes.Count | Should -Be 0
    }

    It 'denies a controlled tool when <Name>' -ForEach @(
        @{ Name = 'discovery is inactive'; Store = { Get-GateStore -ActivationAction 'deactivate' }; Code = 'ACTIVATION' }
        @{ Name = 'no activation record exists'; Store = { Get-GateStore -NoActivation }; Code = 'ACTIVATION' }
        @{ Name = 'no started invocation is bound'; Store = { Get-GateStore -NoInvocation }; Code = 'NO_INVOCATION' }
        @{ Name = 'the only record is prepared for another parent'; Store = { Get-GateStore -InvocationOverrides @{ state = 'prepared' } }; Code = 'NO_INVOCATION' }
        @{ Name = 'the invocation binds another profile'; Store = { Get-GateStore -InvocationOverrides @{ workspace = [ordered]@{ workspace_root = $script:GateWorkspaceRoot; workspace_sha256 = $script:GateWorkspaceSha256; profile_path = 'docs/other.yaml'; profile_sha256 = ('9' * 64) } } }; Code = 'BINDING' }
    ) {
        $store = & $Store
        $outcome = Get-Outcome -ToolName 'mcp__drm-copilot__run_discovery_repo_inventory' -ToolInput (Get-BoundInput) -Store $store
        $outcome.Decision | Should -Be 'deny'
        $outcome.Code | Should -Be $Code
        $store.Writes.Count | Should -Be 0
    }

    It 'denies a controlled call whose invocation_ref is <Name> with INVOCATION_REF and writes nothing' -ForEach @(
        @{ Name = 'missing'; Arguments = { Get-GateInventoryInput } }
        @{ Name = 'foreign'; Arguments = { Get-BoundInput -InvocationRef 'invocation-zeta' } }
    ) {
        $store = Get-GateStore
        $outcome = Get-Outcome -ToolName 'mcp__drm-copilot__run_discovery_repo_inventory' -ToolInput (& $Arguments) -Store $store
        $outcome.Decision | Should -Be 'deny'
        $outcome.Code | Should -Be 'INVOCATION_REF'
        $store.Writes.Count | Should -Be 0
    }

    It 'authorizes a controlled tool by writing one exact one-use record' {
        $store = Get-GateStore
        $inputs = Get-BoundInput
        $outcome = Get-Outcome -ToolName 'mcp__drm-copilot__run_discovery_repo_inventory' -ToolInput $inputs -Store $store

        $outcome.Decision | Should -Be 'allow'
        $outcome.Code | Should -Be 'AUTHORIZED'
        $outcome.RecordPath | Should -Be "$($script:GateInvocationDirectory)/authorizations/authz-$($script:GateNonce).json"
        $store.Writes | Should -Be @($outcome.RecordPath)
        $store.Directories | Should -Contain "$($script:GateInvocationDirectory)/authorizations"
        $record = $store.Files[$outcome.RecordPath] | ConvertFrom-Json
        @($record.PSObject.Properties.Name | Sort-Object) | Should -Be @(
            '$schema', 'artifact_kind', 'authorization_ref', 'capability_ref', 'consumed_at', 'expires_at', 'id', 'identity',
            'input_sha256', 'invocation_ref', 'issued_at', 'operation', 'request_id', 'schema_version', 'start_attestation_ref',
            'state', 'tool', 'workspace', 'writer'
        )
        $record.'$schema' | Should -Be 'urn:drm-copilot:discovery:2.0.0:tool-authorization'
        $record.tool | Should -Be 'run_discovery_repo_inventory'
        $record.operation | Should -Be 'inventory'
        # The digest covers the raw tool input, invocation_ref and workspace_root included, as the MCP gate digests it.
        $record.input_sha256 | Should -Be (Get-DiscoveryInputDigest -Tool 'run_discovery_repo_inventory' -Operation 'inventory' -Inputs $inputs)
        $record.request_id | Should -Be 'tool-use-alpha'
        $record.state | Should -Be 'issued'
        $record.consumed_at | Should -BeNullOrEmpty
        # ConvertFrom-Json turns ISO timestamps into DateTime values, so the literal
        # schema spelling is asserted on the stored text.
        $store.Files[$outcome.RecordPath] | Should -Match '"issued_at": "2026-10-22T12:00:00Z"'
        $store.Files[$outcome.RecordPath] | Should -Match '"expires_at": "2026-10-22T12:05:00Z"'
        $record.identity.host | Should -Be 'claude-code'
        $record.identity.session_id | Should -Be 'session-alpha'
        $record.identity.agent_id | Should -Be 'agent-alpha'
        $record.identity.role | Should -Be 'legacy-parity-analyst'
        $record.identity.invocation_id | Should -Be 'invocation-alpha'
        # The grant references the invocation itself (as the start attestation does), never the record id.
        $record.invocation_ref | Should -Be 'invocation-alpha'
        $record.start_attestation_ref | Should -Be 'attestation-alpha-00000000001'
        $record.capability_ref | Should -Be 'capability-alpha-000000000001'
        $record.workspace.profile_sha256 | Should -Be $script:GateProfileSha256
        $record.writer.kind | Should -Be 'native-pretooluse'
        $record.writer.host | Should -Be 'claude-code'
        $record.writer.handler_sha256 | Should -Be ('ab' * 32)
    }

    It 'starts the single prepared invocation on the first controlled call and reuses it on the second' {
        $store = Get-FirstCallStore
        $first = Get-Outcome -ToolName 'mcp__drm-copilot__run_discovery_repo_inventory' -ToolInput (Get-BoundInput) -AgentType 'legacy-parity-analyst-c3' -Store $store
        $first.Decision | Should -Be 'allow' -Because $first.Reason
        $first.Code | Should -Be 'AUTHORIZED'
        $store.Writes | Should -Be @("$($script:GateInvocationDirectory)/start-attestation.json", $first.RecordPath)
        $store.Replacements | Should -Be @("$($script:GateInvocationDirectory)/invocation.json")
        $started = $store.Files["$($script:GateInvocationDirectory)/invocation.json"] | ConvertFrom-Json
        $started.state | Should -Be 'started'
        $started.agent_id | Should -Be 'agent-alpha'
        $attestation = $store.Files["$($script:GateInvocationDirectory)/start-attestation.json"] | ConvertFrom-Json
        $attestation.parent_agent_id | Should -Be 'root'
        $attestation.agent_type | Should -Be 'legacy-parity-analyst-c3'
        ($store.Files[$first.RecordPath] | ConvertFrom-Json).start_attestation_ref | Should -Be $attestation.start_attestation_ref

        $second = Get-Outcome -ToolName 'mcp__drm-copilot__read_discovery_source' -ToolInput ([ordered]@{ paths = @('src'); invocation_ref = 'invocation-alpha' }) -AgentType 'legacy-parity-analyst-c3' -Store $store -Nonce ('f' * 20)
        $second.Code | Should -Be 'AUTHORIZED'
        $store.Writes.Count | Should -Be 3
        $store.Replacements.Count | Should -Be 1
    }

    It 'denies the first controlled call with <Code> when <Name>' -ForEach @(
        @{ Name = 'two prepared invocations match'; Options = @{ SecondInvocation = $true }; Code = 'AMBIGUOUS' }
        @{ Name = 'the prepared invocation names another parent'; Options = @{ InvocationOverrides = @{ parent_agent_id = 'root-beta' } }; Code = 'NO_INVOCATION' }
        @{ Name = 'the session capability attestation is missing'; Options = @{ NoCapability = $true }; Code = 'CAPABILITY' }
        @{ Name = 'the invocation was prepared for another role'; Options = @{ InvocationOverrides = @{ role = 'requirements-reconciler' } }; Code = 'ROLE' }
    ) {
        $store = Get-FirstCallStore -Options $Options
        $outcome = Get-Outcome -ToolName 'mcp__drm-copilot__run_discovery_repo_inventory' -ToolInput (Get-BoundInput) -AgentType 'legacy-parity-analyst-c3' -Store $store
        $outcome.Decision | Should -Be 'deny'
        $outcome.Code | Should -Be $Code -Because $outcome.Reason
        $store.Writes.Count | Should -Be 0
    }

    It 'denies when the one-use record cannot be stored exclusively' {
        $store = Get-GateStore
        $inputs = [ordered]@{ paths = @('src'); invocation_ref = 'invocation-alpha' }
        $first = Get-Outcome -ToolName 'mcp__drm-copilot__read_discovery_source' -ToolInput $inputs -Store $store
        $second = Get-Outcome -ToolName 'mcp__drm-copilot__read_discovery_source' -ToolInput $inputs -Store $store
        $first.Decision | Should -Be 'allow'
        $second.Decision | Should -Be 'deny'
        $second.Code | Should -Be 'STORE'
    }
}

Describe 'Get-DiscoveryPreToolDecision for the sentinel' {
    It 'observes the sentinel tool call with a grant and writes no root grant or tool authorization' {
        $store = Get-StartStore
        $outcome = Get-Outcome -ToolName 'mcp__drm-copilot__discovery_capability_sentinel' -ToolInput @{ workspace_root = $script:GateWorkspaceRoot } -AgentId 'agent-sentinel' -AgentType 'discovery-capability-sentinel' -Store $store
        $outcome.Decision | Should -Be 'allow'
        $outcome.Code | Should -Be 'SENTINEL'
        $outcome.RecordPath | Should -BeLike "$($script:StartSessionDirectory)/observations/observation-*.json"
        $store.Writes | Should -Be @($outcome.RecordPath)
        $record = $store.Files[$outcome.RecordPath] | ConvertFrom-Json
        $record.artifact_kind | Should -Be 'host-observation'
        $record.agent_id | Should -Be 'agent-sentinel'
        $record.agent_type | Should -Be 'discovery-capability-sentinel'
        $record.tool | Should -Be 'discovery_capability_sentinel'
        $record.state | Should -Be 'issued'
    }

    It 'denies the sentinel shell command with SHELL and observes it, from the sentinel and from a root-shaped payload' {
        $store = Get-StartStore
        $command = 'drm-copilot discovery capability probe probe-alpha: this command must be denied by the native hook and never executed'
        $sentinel = Get-Outcome -ToolName 'Bash' -ToolInput @{ command = $command } -AgentId 'agent-sentinel' -AgentType 'discovery-capability-sentinel' -Store $store
        $sentinel.Decision | Should -Be 'deny'
        $sentinel.Code | Should -Be 'SHELL'
        $root = Get-Outcome -ToolName 'Bash' -ToolInput @{ command = $command } -AgentId $null -AgentType $null -Store $store -Nonce ('e' * 20) -ToolUseId 'tool-use-beta'
        $root.Decision | Should -Be 'deny'
        $root.Code | Should -Be 'SHELL'
        $store.Writes.Count | Should -Be 2
        ($store.Files[$root.RecordPath] | ConvertFrom-Json).agent_id | Should -BeNullOrEmpty
        # One observation per host tool-call identifier: a replay of the same call is refused, not re-observed.
        (Get-Outcome -ToolName 'Bash' -ToolInput @{ command = $command } -AgentId $null -AgentType $null -Store $store -Nonce ('d' * 20) -ToolUseId 'tool-use-beta').Code | Should -Be 'STORE'
    }

    It 'denies any other tool from the sentinel agent type with UNKNOWN_TOOL and observes it' {
        $store = Get-StartStore
        $outcome = Get-Outcome -ToolName 'mcp__drm-copilot__read_discovery_source' -ToolInput @{ paths = @('src') } -AgentId 'agent-sentinel' -AgentType 'discovery-capability-sentinel' -Store $store
        $outcome.Decision | Should -Be 'deny'
        $outcome.Code | Should -Be 'UNKNOWN_TOOL'
        $store.Writes.Count | Should -Be 1
    }
}

Describe 'hook output and defaults' {
    It 'renders allow and deny outcomes as PreToolUse hook output' {
        $allow = ConvertTo-DiscoveryPreToolHookOutput -Outcome ([pscustomobject]@{ Decision = 'allow'; Code = 'READ_ONLY'; Reason = 'x' }) -ReasonPrefix 'PREFIX:'
        $allow.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $allow.hookSpecificOutput.Keys | Should -Not -Contain 'permissionDecisionReason'
        $deny = ConvertTo-DiscoveryPreToolHookOutput -Outcome ([pscustomobject]@{ Decision = 'deny'; Code = 'SHELL'; Reason = 'shell denied' }) -ReasonPrefix 'PREFIX:'
        $deny.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $deny.hookSpecificOutput.permissionDecisionReason | Should -Be 'PREFIX: shell denied'
    }

    It 'provides a filesystem store and a hex nonce by default' {
        $store = Get-DiscoveryDefaultStore
        @($store.Keys | Sort-Object) | Should -Be @('EnsureDirectory', 'ListEntries', 'ReadText', 'ReplaceText', 'WriteText')
        (& $store.ListEntries (Join-Path $script:RepoRoot 'tests/fixtures/discovery_authority')) | Should -Contain 'authority-vectors.json'
        (& $store.ListEntries (Join-Path $script:RepoRoot 'tests/fixtures/does-not-exist')) | Should -BeNullOrEmpty
        (& $store.ReadText (Join-Path $script:RepoRoot 'tests/fixtures/does-not-exist/x.json')) | Should -BeNullOrEmpty
        Get-DiscoveryAuthorizationNonce | Should -Match '^[0-9a-f]{20}$'
    }
}
