#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Host-observation record, sentinel decision and exclusive-write tests for `DiscoveryObservation.psm1` (issue #980).
.DESCRIPTION
    Builds sentinel envelopes through the shared gate fixtures, normalizes them with the
    payload module and decides them with Get-DiscoverySentinelDecision over the in-memory
    protected store. The record shape is compared with the committed host-observation
    example. No file is written, no process, network or clock is touched; the example is
    read as a committed fixture.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $lib = Join-Path $script:RepoRoot '.claude/lib/discovery-validation'
    # Leaf modules are imported last so no nested import replaces a visible one.
    Import-Module (Join-Path $lib 'DiscoveryObservation.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryToolRouting.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryPayload.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryAuthority.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryEncoding.psm1') -Force
    . (Join-Path $PSScriptRoot 'DiscoveryGate.TestSupport.ps1')

    $script:SentinelCommand = 'drm-copilot discovery capability probe probe-alpha: this command must be denied by the native hook and never executed'

    function Get-SentinelOutcome {
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            [Parameter(Mandatory = $true)][string]$ToolName,
            [Parameter(Mandatory = $true)][object]$ToolInput,
            [Parameter(Mandatory = $true)][hashtable]$Store,
            [Parameter(Mandatory = $false)][AllowNull()][string]$AgentId = 'agent-sentinel',
            [Parameter(Mandatory = $false)][AllowNull()][string]$AgentType = 'discovery-capability-sentinel',
            [Parameter(Mandatory = $false)][AllowNull()][string]$ToolUseId = 'tool-use-alpha',
            [Parameter(Mandatory = $false)][string]$Nonce = $script:GateNonce
        )
        $json = Get-GateEnvelope -ToolName $ToolName -ToolInput $ToolInput -AgentId $AgentId -AgentType $AgentType -ToolUseId $ToolUseId
        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text $json
        $principal = Get-DiscoveryTrustedPrincipal -Normalized $normalized
        $tool = Resolve-DiscoveryToolName -ToolName $normalized.ToolName
        return Get-DiscoverySentinelDecision -Normalized $normalized -Principal $principal -Tool $tool -Location $script:GateLocation -Store $Store `
            -HandlerSha256 ('ab' * 32) -Now $script:GateNow -Nonce $Nonce
    }
}

Describe 'ConvertTo-DiscoveryHostObservationRecord' {
    It 'carries exactly the keys of the committed host-observation example for a sentinel tool call' {
        $exampleKeys = @(Get-Content -LiteralPath (Join-Path $script:RepoRoot 'examples/discovery/v2/host-observation.example.yaml') |
                Where-Object { $_ -match '^[$A-Za-z_][A-Za-z0-9_]*:' } | ForEach-Object { $_.Split(':')[0] })
        $outcome = Get-SentinelOutcome -ToolName 'mcp__drm-copilot__discovery_capability_sentinel' -ToolInput @{ workspace_root = $script:GateWorkspaceRoot } -Store (Get-GateStore)
        @($outcome.Record.Keys | Sort-Object) | Should -Be @($exampleKeys | Sort-Object)
        $outcome.Record['$schema'] | Should -Be 'urn:drm-copilot:discovery:2.0.0:host-observation'
        $outcome.Record['observed_at'] | Should -Be '2026-10-22T12:00:00Z'
        $outcome.Record['expires_at'] | Should -Be '2026-10-22T12:05:00Z'
        $outcome.Record['handler_sha256'] | Should -Be ('ab' * 32)
        $outcome.Record['tool_use_id_present'] | Should -BeTrue
    }
}

Describe 'Get-DiscoverySentinelDecision' {
    It 'denies the sentinel shell command with SHELL and writes an observation without grant fields' {
        $store = Get-GateStore
        $outcome = Get-SentinelOutcome -ToolName 'Bash' -ToolInput @{ command = $script:SentinelCommand } -Store $store
        $outcome.Decision | Should -Be 'deny'
        $outcome.Code | Should -Be 'SHELL'
        $store.Writes | Should -Be @($outcome.RecordPath)
        $outcome.RecordPath | Should -BeLike "$(Get-DiscoveryObservationDirectory -Location $script:GateLocation -SessionId 'session-alpha')/observation-*.json"
        $record = $store.Files[$outcome.RecordPath] | ConvertFrom-Json -AsHashtable
        $record['decision'] | Should -Be 'deny'
        $record['code'] | Should -Be 'SHELL'
        $record['agent_id'] | Should -Be 'agent-sentinel'
        $record.Keys | Should -Not -Contain 'tool'
        $record.Keys | Should -Not -Contain 'state'
    }

    It 'allows the sentinel tool with SENTINEL and records the one-use grant fields' {
        $store = Get-GateStore
        $inputs = @{ workspace_root = $script:GateWorkspaceRoot }
        $outcome = Get-SentinelOutcome -ToolName 'mcp__drm-copilot__discovery_capability_sentinel' -ToolInput $inputs -Store $store
        $outcome.Decision | Should -Be 'allow'
        $outcome.Code | Should -Be 'SENTINEL'
        $record = $store.Files[$outcome.RecordPath] | ConvertFrom-Json -AsHashtable
        $record['tool'] | Should -Be 'discovery_capability_sentinel'
        $record['input_sha256'] | Should -Be (Get-DiscoveryInputDigest -Tool 'discovery_capability_sentinel' -Operation 'sentinel' -Inputs ([pscustomobject]$inputs))
        $store.Files[$outcome.RecordPath] | Should -BeLike '*"expires_at": "2026-10-22T12:05:00Z"*'
        $record['state'] | Should -Be 'issued'
        $record['agent_type'] | Should -Be 'discovery-capability-sentinel'
    }

    It 'still observes a sentinel tool call that carries no agent identity, with null identity fields' {
        $store = Get-GateStore
        $outcome = Get-SentinelOutcome -ToolName 'mcp__drm-copilot__discovery_capability_sentinel' -ToolInput @{ workspace_root = $script:GateWorkspaceRoot } -Store $store -AgentId $null -AgentType $null
        $outcome.Decision | Should -Be 'allow'
        $store.Writes.Count | Should -Be 1
        $record = $store.Files[$outcome.RecordPath] | ConvertFrom-Json -AsHashtable
        $record.Keys | Should -Contain 'agent_id'
        $record['agent_id'] | Should -BeNullOrEmpty
        $record['agent_type'] | Should -BeNullOrEmpty
        $record['parent_agent_id'] | Should -Be 'root'
    }

    It 'denies any other tool from the sentinel agent type with UNKNOWN_TOOL and observes it' {
        $store = Get-GateStore
        $outcome = Get-SentinelOutcome -ToolName 'Read' -ToolInput @{ file_path = 'src/Orders.cs' } -Store $store
        $outcome.Decision | Should -Be 'deny'
        $outcome.Code | Should -Be 'UNKNOWN_TOOL'
        $store.Writes.Count | Should -Be 1
    }

    It 'refuses a second observation for the same tool-call reference and denies with STORE' {
        $store = Get-GateStore
        $first = Get-SentinelOutcome -ToolName 'Bash' -ToolInput @{ command = $script:SentinelCommand } -Store $store
        $second = Get-SentinelOutcome -ToolName 'Bash' -ToolInput @{ command = $script:SentinelCommand } -Store $store -Nonce ('e' * 20)
        $first.Code | Should -Be 'SHELL'
        $second.Decision | Should -Be 'deny'
        $second.Code | Should -Be 'STORE'
        $store.Writes.Count | Should -Be 1
    }

    It 'derives the reference from the nonce when the host supplies no tool-call identifier' {
        $store = Get-GateStore
        $outcome = Get-SentinelOutcome -ToolName 'Bash' -ToolInput @{ command = $script:SentinelCommand } -Store $store -ToolUseId $null
        $outcome.Record['observation_ref'] | Should -Be "observation-$($script:GateNonce)"
        $outcome.Record['tool_use_id_present'] | Should -BeFalse
    }
}

Describe 'Test-DiscoverySentinelEnvelope' {
    It 'recognises <Name>: <Expected>' -ForEach @(
        @{ Name = 'the sentinel agent type'; ToolName = 'Read'; ToolInput = @{}; AgentType = 'discovery-capability-sentinel'; Expected = $true }
        @{ Name = 'the sentinel tool from the root'; ToolName = 'mcp__drm-copilot__discovery_capability_sentinel'; ToolInput = @{}; AgentType = $null; Expected = $true }
        @{ Name = 'the sentinel command from the root'; ToolName = 'Bash'; ToolInput = @{ command = 'drm-copilot discovery capability probe x' }; AgentType = $null; Expected = $true }
        @{ Name = 'an ordinary shell command'; ToolName = 'Bash'; ToolInput = @{ command = 'ls' }; AgentType = $null; Expected = $false }
        @{ Name = 'a specialist read'; ToolName = 'Read'; ToolInput = @{}; AgentType = 'legacy-parity-analyst'; Expected = $false }
    ) {
        $agentId = $(if ($AgentType) { 'agent-alpha' } else { $null })
        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text (Get-GateEnvelope -ToolName $ToolName -ToolInput $ToolInput -AgentId $agentId -AgentType $AgentType)
        Test-DiscoverySentinelEnvelope -Normalized $normalized -Tool (Resolve-DiscoveryToolName -ToolName $normalized.ToolName) | Should -Be $Expected
        Get-DiscoverySentinelCommandPrefix | Should -Be 'drm-copilot discovery capability probe '
    }
}
