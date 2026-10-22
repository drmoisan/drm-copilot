#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Envelope normalization and principal attribution tests for `DiscoveryPayload.psm1` (issue #980).
.DESCRIPTION
    Uses captured synthetic Claude Code, Codex and GitHub Copilot envelopes and an
    explicit environment hashtable; no process environment is mutated and no file,
    process, network or clock is touched.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/discovery-validation/DiscoveryPayload.psm1') -Force

    $script:ClaudeEnvelope = '{"session_id":"session-alpha","hook_event_name":"PreToolUse","tool_name":"mcp__drm-copilot__read_discovery_source","tool_input":{"paths":["src"]},"cwd":"C:/repo","agent_id":"agent-alpha","agent_type":"legacy-parity-analyst"}'
    $script:CodexEnvelope = '{"session_id":"session-alpha","hook_event_name":"SubagentStop","agent_id":"agent-alpha","agent_type":"legacy-parity-analyst","cwd":"/repo"}'
    $script:CopilotEnvelope = '{"sessionId":"session-alpha","hookEventName":"PreToolUse","toolName":"read_discovery_source","toolInput":{"paths":["src"]},"cwd":"C:/repo"}'
    $script:AttestedEnvironment = @{
        DRM_DISCOVERY_HOST            = 'claude-code'
        DRM_DISCOVERY_SESSION_ID      = 'session-alpha'
        DRM_DISCOVERY_PARENT_AGENT_ID = 'root-alpha'
        DRM_DISCOVERY_PARENT_ROLE     = $null
        DRM_DISCOVERY_AGENT_ID        = 'agent-alpha'
        DRM_DISCOVERY_AGENT_ROLE      = 'legacy-parity-analyst'
    }
}

Describe 'ConvertFrom-DiscoveryHostEnvelope' {
    It 'normalizes a Claude Code PreToolUse envelope' {
        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text $script:ClaudeEnvelope
        $normalized.Anomaly | Should -BeNullOrEmpty
        $normalized.SessionId | Should -Be 'session-alpha'
        $normalized.Event | Should -Be 'PreToolUse'
        $normalized.ToolName | Should -Be 'mcp__drm-copilot__read_discovery_source'
        $normalized.ToolInput.paths | Should -Be @('src')
        $normalized.Cwd | Should -Be 'C:/repo'
        $normalized.AgentType | Should -Be 'legacy-parity-analyst'
    }

    It 'normalizes a Codex stop envelope without tool input' {
        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'codex' -Text $script:CodexEnvelope
        $normalized.Anomaly | Should -BeNullOrEmpty
        $normalized.Event | Should -Be 'SubagentStop'
        $normalized.ToolInput | Should -BeNullOrEmpty
        $normalized.AgentId | Should -Be 'agent-alpha'
    }

    It 'normalizes a Copilot camelCase envelope and falls back to snake_case members' {
        $camel = ConvertFrom-DiscoveryHostPayloadText -HostName 'github-copilot' -Text $script:CopilotEnvelope
        $camel.Anomaly | Should -BeNullOrEmpty
        $camel.SessionId | Should -Be 'session-alpha'
        $camel.ToolName | Should -Be 'read_discovery_source'
        $snake = ConvertFrom-DiscoveryHostEnvelope -HostName 'github-copilot' -Envelope @{ session_id = 's2'; hook_event_name = 'SubagentStart'; agent_id = 'a2' }
        $snake.Anomaly | Should -BeNullOrEmpty
        $snake.SessionId | Should -Be 's2'
        $snake.AgentId | Should -Be 'a2'
    }

    It 'classifies <Name> as <Anomaly>' -ForEach @(
        @{ Name = 'an unsupported host'; HostName = 'shell'; Text = '{"session_id":"s"}'; Anomaly = 'UnsupportedHost' }
        @{ Name = 'empty text'; HostName = 'claude-code'; Text = '   '; Anomaly = 'EmptyEnvelope' }
        @{ Name = 'unparseable text'; HostName = 'claude-code'; Text = '{'; Anomaly = 'EmptyEnvelope' }
        @{ Name = 'an array envelope'; HostName = 'claude-code'; Text = '[]'; Anomaly = 'EmptyEnvelope' }
        @{ Name = 'a missing session'; HostName = 'codex'; Text = '{"hook_event_name":"PreToolUse","tool_input":{}}'; Anomaly = 'MissingSessionId' }
        @{ Name = 'a blank session'; HostName = 'codex'; Text = '{"session_id":" ","hook_event_name":"PreToolUse","tool_input":{}}'; Anomaly = 'MissingSessionId' }
        @{ Name = 'a missing event'; HostName = 'claude-code'; Text = '{"session_id":"s","tool_input":{}}'; Anomaly = 'MissingEvent' }
        @{ Name = 'a tool event without tool input'; HostName = 'claude-code'; Text = '{"session_id":"s","hook_event_name":"PreToolUse"}'; Anomaly = 'NonObjectToolInput' }
        @{ Name = 'a tool event with scalar tool input'; HostName = 'github-copilot'; Text = '{"sessionId":"s","hookEventName":"PreToolUse","toolInput":"rm -rf"}'; Anomaly = 'NonObjectToolInput' }
    ) {
        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName $HostName -Text $Text
        $normalized.Anomaly | Should -Be $Anomaly
        Get-DiscoveryPayloadAnomalyReason -Code $Anomaly | Should -Not -BeNullOrEmpty
    }

    It 'rejects an unknown anomaly code and recognises the supported hosts' {
        { Get-DiscoveryPayloadAnomalyReason -Code 'Nope' } | Should -Throw
        Test-DiscoverySupportedHost -HostName 'codex' | Should -BeTrue
        Test-DiscoverySupportedHost -HostName '' | Should -BeFalse
    }
}

Describe 'Get-DiscoveryTrustedPrincipal' {
    BeforeAll {
        $script:Normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text $script:ClaudeEnvelope
    }

    It 'attributes the principal when the attested host and session match the envelope' {
        $principal = Get-DiscoveryTrustedPrincipal -Normalized $script:Normalized -Environment $script:AttestedEnvironment
        $principal.Attributed | Should -BeTrue
        $principal.Reason | Should -BeNullOrEmpty
        $principal.HostName | Should -Be 'claude-code'
        $principal.SessionId | Should -Be 'session-alpha'
        $principal.ParentAgentId | Should -Be 'root-alpha'
        $principal.ParentRole | Should -BeNullOrEmpty
        $principal.AgentId | Should -Be 'agent-alpha'
        $principal.Role | Should -Be 'legacy-parity-analyst'
    }

    It 'leaves the principal unattributed when <Name>' -ForEach @(
        @{ Name = 'no host context is attested'; Overrides = @{ DRM_DISCOVERY_HOST = $null; DRM_DISCOVERY_SESSION_ID = $null }; Reason = 'did not attest' }
        @{ Name = 'the attested host differs'; Overrides = @{ DRM_DISCOVERY_HOST = 'codex' }; Reason = "attested host 'codex' differs" }
        @{ Name = 'the attested session differs'; Overrides = @{ DRM_DISCOVERY_SESSION_ID = 'session-beta' }; Reason = 'attested session differs' }
    ) {
        $environment = $script:AttestedEnvironment.Clone()
        foreach ($key in $Overrides.Keys) { $environment[$key] = $Overrides[$key] }
        $principal = Get-DiscoveryTrustedPrincipal -Normalized $script:Normalized -Environment $environment
        $principal.Attributed | Should -BeFalse
        $principal.Reason | Should -BeLike "*$Reason*"
    }

    It 'carries the anomaly reason and ignores a role asserted without an agent identity' {
        $anomalous = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text '{"session_id":"session-alpha"}'
        $principal = Get-DiscoveryTrustedPrincipal -Normalized $anomalous -Environment $script:AttestedEnvironment
        $principal.Attributed | Should -BeFalse
        $principal.Reason | Should -Be (Get-DiscoveryPayloadAnomalyReason -Code 'MissingEvent')

        $roleOnly = $script:AttestedEnvironment.Clone()
        $roleOnly['DRM_DISCOVERY_AGENT_ID'] = ''
        $rootPrincipal = Get-DiscoveryTrustedPrincipal -Normalized $script:Normalized -Environment $roleOnly
        $rootPrincipal.Attributed | Should -BeTrue
        $rootPrincipal.AgentId | Should -BeNullOrEmpty
        $rootPrincipal.Role | Should -BeNullOrEmpty
    }

    It 'reads only the six documented keys from the process environment' {
        $values = Get-DiscoveryHostEnvironmentValueTable
        @($values.Keys | Sort-Object) | Should -Be @(
            'DRM_DISCOVERY_AGENT_ID', 'DRM_DISCOVERY_AGENT_ROLE', 'DRM_DISCOVERY_HOST',
            'DRM_DISCOVERY_PARENT_AGENT_ID', 'DRM_DISCOVERY_PARENT_ROLE', 'DRM_DISCOVERY_SESSION_ID'
        )
    }
}
