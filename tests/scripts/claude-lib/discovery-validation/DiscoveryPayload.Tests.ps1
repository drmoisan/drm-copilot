#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Envelope normalization and principal attribution tests for `DiscoveryPayload.psm1` (issue #980).
.DESCRIPTION
    Uses captured synthetic Claude Code, Codex and GitHub Copilot envelopes. The
    principal is derived from the payload alone: no process environment is read or
    mutated and no file, process, network or clock is touched.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/discovery-validation/DiscoveryPayload.psm1') -Force

    $script:ClaudeEnvelope = '{"session_id":"session-alpha","hook_event_name":"PreToolUse","tool_name":"mcp__drm-copilot__read_discovery_source","tool_input":{"paths":["src"]},"cwd":"C:/repo","agent_id":"agent-alpha","agent_type":"legacy-parity-analyst"}'
    $script:CodexEnvelope = '{"session_id":"session-alpha","hook_event_name":"SubagentStop","agent_id":"agent-alpha","agent_type":"legacy-parity-analyst","cwd":"/repo"}'
    $script:CopilotEnvelope = '{"sessionId":"session-alpha","hookEventName":"PreToolUse","toolName":"read_discovery_source","toolInput":{"paths":["src"]},"cwd":"C:/repo"}'
    $script:RootEnvelope = '{"session_id":"session-alpha","hook_event_name":"PreToolUse","tool_name":"mcp__drm-copilot__prepare_discovery_agent","tool_input":{"workspace_root":"C:/repo"},"cwd":"C:/repo"}'
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
        $normalized.ParentAgentId | Should -BeNullOrEmpty
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

    It 'reads the Copilot parentAgentId and the snake_case parent_agent_id spelling' {
        $camel = ConvertFrom-DiscoveryHostEnvelope -HostName 'github-copilot' -Envelope @{ sessionId = 's'; hookEventName = 'SubagentStop'; agentId = 'a'; parentAgentId = 'parent-alpha' }
        $camel.ParentAgentId | Should -Be 'parent-alpha'
        $snake = ConvertFrom-DiscoveryHostEnvelope -HostName 'github-copilot' -Envelope @{ session_id = 's'; hook_event_name = 'SubagentStop'; agent_id = 'a'; parent_agent_id = 'parent-beta' }
        $snake.ParentAgentId | Should -Be 'parent-beta'
        $claude = ConvertFrom-DiscoveryHostEnvelope -HostName 'claude-code' -Envelope @{ session_id = 's'; hook_event_name = 'SubagentStop'; agent_id = 'a'; parent_agent_id = 'parent-gamma' }
        $claude.ParentAgentId | Should -Be 'parent-gamma'
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

Describe 'Get-DiscoveryAgentRole' {
    It 'maps <AgentType> to role <Role>' -ForEach @(
        @{ AgentType = 'legacy-parity-analyst'; Role = 'legacy-parity-analyst' }
        @{ AgentType = 'legacy-parity-analyst-c3-elevated'; Role = 'legacy-parity-analyst' }
        @{ AgentType = 'runtime-characterization-analyst-c1'; Role = 'runtime-characterization-analyst' }
        @{ AgentType = 'requirements-reconciler-c4'; Role = 'requirements-reconciler' }
        @{ AgentType = 'migration-coverage-reviewer-c2'; Role = 'migration-coverage-reviewer' }
        @{ AgentType = 'Legacy-Parity-Analyst'; Role = $null }
        @{ AgentType = 'legacy-parity-analyst-c5'; Role = $null }
        @{ AgentType = 'discovery-capability-sentinel'; Role = $null }
        @{ AgentType = 'epic-planner'; Role = $null }
        @{ AgentType = ''; Role = $null }
    ) {
        Get-DiscoveryAgentRole -AgentType $AgentType | Should -Be $Role
    }
}

Describe 'Get-DiscoveryTrustedPrincipal' {
    It 'attributes a specialist envelope with its agent id and role from the payload alone' {
        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text $script:ClaudeEnvelope
        $principal = Get-DiscoveryTrustedPrincipal -Normalized $normalized
        $principal.Attributed | Should -BeTrue
        $principal.Reason | Should -BeNullOrEmpty
        $principal.HostName | Should -Be 'claude-code'
        $principal.SessionId | Should -Be 'session-alpha'
        $principal.AgentId | Should -Be 'agent-alpha'
        $principal.Role | Should -Be 'legacy-parity-analyst'
        $principal.IsRoot | Should -BeFalse
        $principal.ParentAgentId | Should -Be 'root'
    }

    It 'attributes an envelope without agent_id as the root with parent root' {
        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text $script:RootEnvelope
        $principal = Get-DiscoveryTrustedPrincipal -Normalized $normalized
        $principal.Attributed | Should -BeTrue
        $principal.IsRoot | Should -BeTrue
        $principal.AgentId | Should -BeNullOrEmpty
        $principal.Role | Should -BeNullOrEmpty
        $principal.ParentAgentId | Should -Be 'root'
    }

    It 'yields no role for an agent_id whose agent_type is not a discovery role' {
        $normalized = ConvertFrom-DiscoveryHostEnvelope -HostName 'codex' -Envelope @{ session_id = 'session-alpha'; hook_event_name = 'SubagentStop'; agent_id = 'agent-other'; agent_type = 'atomic-executor-c3' }
        $principal = Get-DiscoveryTrustedPrincipal -Normalized $normalized
        $principal.Attributed | Should -BeTrue
        $principal.IsRoot | Should -BeFalse
        $principal.AgentId | Should -BeNullOrEmpty
        $principal.Role | Should -BeNullOrEmpty
    }

    It 'reads the parent from <Name>' -ForEach @(
        @{ Name = 'the Copilot parentAgentId'; HostName = 'github-copilot'; Envelope = @{ sessionId = 's'; hookEventName = 'SubagentStop'; agentId = 'agent-alpha'; agentType = 'legacy-parity-analyst'; parentAgentId = 'parent-alpha' }; Parent = 'parent-alpha' }
        @{ Name = 'the snake_case parent_agent_id'; HostName = 'github-copilot'; Envelope = @{ session_id = 's'; hook_event_name = 'SubagentStop'; agent_id = 'agent-alpha'; agent_type = 'legacy-parity-analyst'; parent_agent_id = 'parent-beta' }; Parent = 'parent-beta' }
        @{ Name = 'the literal root when no parent is supplied'; HostName = 'codex'; Envelope = @{ session_id = 's'; hook_event_name = 'SubagentStop'; agent_id = 'agent-alpha'; agent_type = 'legacy-parity-analyst' }; Parent = 'root' }
        @{ Name = 'the literal root when the parent is not an identifier'; HostName = 'codex'; Envelope = @{ session_id = 's'; hook_event_name = 'SubagentStop'; agent_id = 'agent-alpha'; agent_type = 'legacy-parity-analyst'; parent_agent_id = ' ' }; Parent = 'root' }
    ) {
        $principal = Get-DiscoveryTrustedPrincipal -Normalized (ConvertFrom-DiscoveryHostEnvelope -HostName $HostName -Envelope $Envelope)
        $principal.ParentAgentId | Should -Be $Parent
        $principal.AgentId | Should -Be 'agent-alpha'
    }

    It 'treats an agent_type without agent_id as the root' {
        $normalized = ConvertFrom-DiscoveryHostEnvelope -HostName 'claude-code' -Envelope @{ session_id = 's'; hook_event_name = 'SubagentStop'; agent_type = 'legacy-parity-analyst' }
        $principal = Get-DiscoveryTrustedPrincipal -Normalized $normalized
        $principal.IsRoot | Should -BeTrue
        $principal.AgentId | Should -BeNullOrEmpty
        $principal.Role | Should -BeNullOrEmpty
    }

    It 'leaves an agent_id outside the identifier grammar without agent identity and not root' {
        $normalized = ConvertFrom-DiscoveryHostEnvelope -HostName 'claude-code' -Envelope @{ session_id = 's'; hook_event_name = 'SubagentStop'; agent_id = 'agent alpha'; agent_type = 'legacy-parity-analyst' }
        $principal = Get-DiscoveryTrustedPrincipal -Normalized $normalized
        $principal.IsRoot | Should -BeFalse
        $principal.AgentId | Should -BeNullOrEmpty
        $principal.Role | Should -BeNullOrEmpty
    }

    It 'carries the anomaly reason and is unattributed for an anomalous envelope' {
        $anomalous = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text '{"session_id":"session-alpha"}'
        $principal = Get-DiscoveryTrustedPrincipal -Normalized $anomalous
        $principal.Attributed | Should -BeFalse
        $principal.Reason | Should -Be (Get-DiscoveryPayloadAnomalyReason -Code 'MissingEvent')
    }

    It 'exports no environment reader' {
        (Get-Module DiscoveryPayload).ExportedFunctions.Keys | Should -Not -Contain 'Get-DiscoveryHostEnvironmentValueTable'
    }
}
