#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Decision-matrix tests for `.claude/lib/discovery-validation/DiscoveryAuthorization.psm1` (issue #980).
.DESCRIPTION
    Proves tool-family routing, operation derivation, digest parity with the shared
    host fixture, invocation binding and the full PreToolUse decision over an
    in-memory protected store. No file, process, network or clock is touched.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $lib = Join-Path $script:RepoRoot '.claude/lib/discovery-validation'
    # Leaf modules are imported last so no nested import replaces a visible one.
    Import-Module (Join-Path $lib 'DiscoveryAuthorization.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryPayload.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryAuthority.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryEncoding.psm1') -Force
    . (Join-Path $PSScriptRoot 'DiscoveryGate.TestSupport.ps1')

    function Get-Outcome {
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            [Parameter(Mandatory = $true)][string]$ToolName,
            [Parameter(Mandatory = $false)][AllowNull()][object]$ToolInput = @{},
            [Parameter(Mandatory = $false)][hashtable]$Environment = (Get-GateEnvironment),
            [Parameter(Mandatory = $false)][hashtable]$Store = (Get-GateStore),
            [Parameter(Mandatory = $false)][string]$HostName = 'claude-code',
            [Parameter(Mandatory = $false)][string]$SessionId = 'session-alpha'
        )

        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName $HostName -Text (Get-GateEnvelope -HostName $HostName -ToolName $ToolName -ToolInput $ToolInput -SessionId $SessionId)
        return Get-DiscoveryPreToolDecision -Normalized $normalized -Environment $Environment -HostEnvironment $script:GateHostEnvironment `
            -HandlerSha256 ('ab' * 32) -Store $Store -Now $script:GateNow -Nonce $script:GateNonce
    }
}

Describe 'Resolve-DiscoveryToolName' {
    It 'classifies <Name> as <Family>' -ForEach @(
        @{ Name = 'mcp__drm-copilot__read_discovery_source'; Family = 'mcp-discovery' }
        @{ Name = 'mcp__drmCopilotExtension__run_discovery_report'; Family = 'mcp-discovery' }
        @{ Name = 'mcp__drm_copilot__finalize_discovery_agent'; Family = 'mcp-discovery' }
        @{ Name = 'mcp__github__create_issue'; Family = 'mcp-other' }
        @{ Name = 'Bash'; Family = 'shell' }
        @{ Name = 'run_in_terminal'; Family = 'shell' }
        @{ Name = 'execute_command'; Family = 'shell' }
        @{ Name = 'PowerShell'; Family = 'shell' }
        @{ Name = 'Write'; Family = 'mutation' }
        @{ Name = 'apply_patch'; Family = 'mutation' }
        @{ Name = 'NotebookEdit'; Family = 'mutation' }
        @{ Name = 'Agent'; Family = 'spawn' }
        @{ Name = 'Read'; Family = 'read' }
        @{ Name = 'Grep'; Family = 'read' }
        @{ Name = 'WebFetch'; Family = 'other' }
        @{ Name = ''; Family = 'other' }
    ) {
        $resolved = Resolve-DiscoveryToolName -ToolName $Name
        $resolved.Family | Should -Be $Family
    }

    It 'separates the MCP server from the tool name' {
        $resolved = Resolve-DiscoveryToolName -ToolName 'mcp__drm-copilot__run_discovery_repo_inventory'
        $resolved.Server | Should -Be 'drm-copilot'
        $resolved.Name | Should -Be 'run_discovery_repo_inventory'
    }
}

Describe 'Get-DiscoveryToolOperation and digests' {
    It 'derives <Expected> for <Tool>' -ForEach @(
        @{ Tool = 'read_discovery_source'; Arguments = @{}; Expected = 'read-source' }
        @{ Tool = 'create_discovery_artifact'; Arguments = @{ artifact_kind = 'feature-contract' }; Expected = 'new-contract' }
        @{ Tool = 'create_discovery_artifact'; Arguments = @{ artifact_kind = 'runtime-scenario' }; Expected = 'new-scenario' }
        @{ Tool = 'create_discovery_artifact'; Arguments = @{ artifact_kind = 'mystery' }; Expected = $null }
        @{ Tool = 'run_discovery_report'; Arguments = @{ report_type = 'parity' }; Expected = 'parity-report' }
        @{ Tool = 'run_discovery_report'; Arguments = @{}; Expected = $null }
        @{ Tool = 'validate_discovery_artifacts'; Arguments = @{}; Expected = 'validate-all' }
        @{ Tool = 'validate_discovery_artifacts'; Arguments = @{ artifact_type = 'coverage-ledger' }; Expected = 'validate-coverage-ledger' }
        @{ Tool = 'validate_discovery_artifacts'; Arguments = @{ artifact_type = 'nope' }; Expected = $null }
        @{ Tool = 'prepare_discovery_agent'; Arguments = @{}; Expected = $null }
    ) {
        Get-DiscoveryToolOperation -Tool $Tool -ToolInput $Arguments | Should -Be $Expected
    }

    It 'reproduces the shared host fixture input digest' {
        Get-DiscoveryInputDigest -Tool 'run_discovery_repo_inventory' -Operation 'inventory' -Inputs (Get-GateInventoryInput) | Should -Be $script:GateInventoryInputSha256
        $reordered = [ordered]@{ repository_id = 'legacy-crm'; draft = $false; analyzer_ids = @('repository') }
        Get-DiscoveryInputDigest -Tool 'run_discovery_repo_inventory' -Operation 'inventory' -Inputs $reordered | Should -Be $script:GateInventoryInputSha256
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

Describe 'Get-DiscoveryPreToolDecision' {
    It 'allows every tool for a process without an attested discovery agent' {
        foreach ($tool in @('Bash', 'Write', 'mcp__github__create_issue', 'mcp__drm-copilot__prepare_discovery_agent')) {
            $outcome = Get-Outcome -ToolName $tool -Environment (Get-GateEnvironment -NoAgent)
            $outcome.Decision | Should -Be 'allow' -Because $tool
            $outcome.Code | Should -Be 'NOT_DISCOVERY_AGENT'
        }
    }

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
        $outcome = Get-Outcome -ToolName $Tool -ToolInput $Arguments
        $outcome.Decision | Should -Be 'deny'
        $outcome.Code | Should -Be $Code
        $outcome.Reason | Should -Not -BeNullOrEmpty
    }

    It 'denies an unattributed, foreign-host or unknown-role principal' {
        (Get-Outcome -ToolName 'Read' -SessionId 'session-beta').Code | Should -Be 'IDENTITY'
        $foreign = Get-GateEnvironment; $foreign['DRM_DISCOVERY_HOST'] = 'codex'
        (Get-Outcome -ToolName 'Read' -Environment $foreign).Code | Should -Be 'IDENTITY'
        $role = Get-GateEnvironment; $role['DRM_DISCOVERY_AGENT_ROLE'] = 'orchestrator'
        (Get-Outcome -ToolName 'Read' -Environment $role).Code | Should -Be 'ROLE'
        $anomalous = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text '{'
        (Get-DiscoveryPreToolDecision -Normalized $anomalous -Environment (Get-GateEnvironment) -HostEnvironment $script:GateHostEnvironment -HandlerSha256 ('ab' * 32) -Store (Get-GateStore) -Now $script:GateNow -Nonce $script:GateNonce).Code | Should -Be 'ENVELOPE'
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
        @{ Name = 'the invocation is only prepared'; Store = { Get-GateStore -InvocationOverrides @{ state = 'prepared' } }; Code = 'NO_INVOCATION' }
        @{ Name = 'the invocation binds another profile'; Store = { Get-GateStore -InvocationOverrides @{ workspace = [ordered]@{ workspace_root = $script:GateWorkspaceRoot; workspace_sha256 = $script:GateWorkspaceSha256; profile_path = 'docs/other.yaml'; profile_sha256 = ('9' * 64) } } }; Code = 'BINDING' }
    ) {
        $outcome = Get-Outcome -ToolName 'mcp__drm-copilot__run_discovery_repo_inventory' -ToolInput (Get-GateInventoryInput) -Store (& $Store)
        $outcome.Decision | Should -Be 'deny'
        $outcome.Code | Should -Be $Code
    }

    It 'authorizes a controlled tool by writing one exact one-use record' {
        $store = Get-GateStore
        $outcome = Get-Outcome -ToolName 'mcp__drm-copilot__run_discovery_repo_inventory' -ToolInput (Get-GateInventoryInput) -Store $store

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
        $record.input_sha256 | Should -Be $script:GateInventoryInputSha256
        $record.request_id | Should -Be 'tool-use-alpha'
        $record.state | Should -Be 'issued'
        $record.consumed_at | Should -BeNullOrEmpty
        # ConvertFrom-Json turns ISO timestamps into DateTime values, so the literal
        # schema spelling is asserted on the stored text.
        $store.Files[$outcome.RecordPath] | Should -Match '"issued_at": "2026-10-22T12:00:00Z"'
        $store.Files[$outcome.RecordPath] | Should -Match '"expires_at": "2026-10-22T12:05:00Z"'
        $record.identity.agent_id | Should -Be 'agent-alpha'
        $record.identity.role | Should -Be 'legacy-parity-analyst'
        $record.identity.invocation_id | Should -Be 'invocation-alpha'
        # The grant references the invocation id the request carries, not the record id;
        # the runtime binding compares the two (installed-host defect, P12-T12).
        $record.invocation_ref | Should -Be 'invocation-alpha'
        $record.start_attestation_ref | Should -Be 'attestation-alpha-00000000001'
        $record.capability_ref | Should -Be 'capability-alpha-000000000001'
        $record.workspace.profile_sha256 | Should -Be $script:GateProfileSha256
        $record.writer.kind | Should -Be 'native-pretooluse'
        $record.writer.host | Should -Be 'claude-code'
        $record.writer.handler_sha256 | Should -Be ('ab' * 32)
    }

    It 'denies when the one-use record cannot be stored exclusively' {
        $store = Get-GateStore
        $first = Get-Outcome -ToolName 'mcp__drm-copilot__read_discovery_source' -ToolInput @{ paths = @('src') } -Store $store
        $second = Get-Outcome -ToolName 'mcp__drm-copilot__read_discovery_source' -ToolInput @{ paths = @('src') } -Store $store
        $first.Decision | Should -Be 'allow'
        $second.Decision | Should -Be 'deny'
        $second.Code | Should -Be 'STORE'
    }

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
