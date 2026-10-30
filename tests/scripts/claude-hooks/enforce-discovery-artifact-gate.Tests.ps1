#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the Claude Code native discovery PreToolUse adapter (issue #980).
.DESCRIPTION
    The hook is dot-sourced in-process; every seam (host roots, protected store,
    clock, nonce) is injected from the shared gate fixtures and the identity comes
    from the payload fixture (agent_id and agent_type, or neither for the root), so
    no file, process, network or clock is touched. The DISCOVERY_ARTIFACT_GATE_BLOCKED:
    reason envelope and the dependency-failure contract of the replaced validator
    hook are preserved.
#>

Describe 'enforce-discovery-artifact-gate.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-discovery-artifact-gate.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot '../claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')
        . (Join-Path $PSScriptRoot '../claude-lib/discovery-validation/DiscoveryStart.TestSupport.ps1')

        function Invoke-Gate {
            param(
                [Parameter(Mandatory = $true)][AllowNull()][AllowEmptyString()][string]$Json,
                [Parameter(Mandatory = $false)][hashtable]$Store = (Get-GateStore)
            )
            return Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $Json -HostEnvironment $script:GateHostEnvironment -Store $Store -Now $script:GateNow -Nonce $script:GateNonce
        }

        function Get-RootEnvelope {
            param([Parameter(Mandatory = $true)][string]$ToolName, [Parameter(Mandatory = $false)][AllowNull()][object]$ToolInput = @{})
            return Get-GateEnvelope -ToolName $ToolName -ToolInput $ToolInput -AgentId $null -AgentType $null
        }
    }

    Context 'envelope anomalies fail closed' {
        It 'denies <Name> with the gate prefix' -ForEach @(
            @{ Name = 'unparseable JSON'; Json = '{not-json'; Text = 'no envelope object' }
            @{ Name = 'an empty payload'; Json = ''; Text = 'no envelope object' }
            @{ Name = 'an absent payload'; Json = $null; Text = 'no envelope object' }
            @{ Name = 'the legacy flat root shape'; Json = '{"file_path":"x","content":"y"}'; Text = 'without a trusted session identifier' }
            @{ Name = 'a tool event without tool input'; Json = '{"session_id":"s","hook_event_name":"PreToolUse","tool_name":"Write"}'; Text = 'tool input is not an object' }
        ) {
            $decision = Invoke-Gate -Json $Json
            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match ([regex]::Escape($Text))
        }
    }

    Context 'root and ordinary sessions keep their behavior' {
        It 'allows <Tool> for the root without a record' -ForEach @(
            @{ Tool = 'Write'; Arguments = @{ file_path = 'discovery/coverage-ledger/coverage-ledger.json'; content = '{}' } }
            @{ Tool = 'Edit'; Arguments = @{ file_path = 'README.md'; old_string = 'a'; new_string = 'b' } }
            @{ Tool = 'Bash'; Arguments = @{ command = 'git status' } }
            @{ Tool = 'mcp__drm-copilot__run_discovery_init'; Arguments = @{ workspace_root = 'C:/Users/Example/Repos/Workspace' } }
        ) {
            $store = Get-StartStore
            $decision = Invoke-Gate -Json (Get-RootEnvelope -ToolName $Tool -ToolInput $Arguments) -Store $store
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decision.hookSpecificOutput.Keys | Should -Not -Contain 'permissionDecisionReason'
            $store.Writes.Count | Should -Be 0
        }

        It 'allows a root prepare with a one-use root grant bound to this session' {
            $store = Get-StartStore
            $decision = Invoke-Gate -Json (Get-RootEnvelope -ToolName 'mcp__drm-copilot__prepare_discovery_agent' -ToolInput @{ skill_id = 'inventory-legacy-system' }) -Store $store
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $store.Writes.Count | Should -Be 1
            $grant = $store.Files[$store.Writes[0]] | ConvertFrom-Json
            $grant.artifact_kind | Should -Be 'root-grant'
            $grant.operation | Should -Be 'prepare-agent'
            $grant.session_id | Should -Be 'session-alpha'
            $grant.handler_sha256 | Should -Be (Get-DiscoveryBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes($script:UnderTest)))
        }

        It 'allows every tool for an agent that is not a discovery specialist' {
            foreach ($tool in @('Write', 'Bash', 'mcp__drm-copilot__prepare_discovery_agent')) {
                $decision = Invoke-Gate -Json (Get-GateEnvelope -ToolName $tool -ToolInput @{ x = 1 } -AgentId 'agent-other' -AgentType 'atomic-executor-c3')
                $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because $tool
            }
        }
    }

    Context 'payload-attributed discovery agents are constrained' {
        It 'denies <Name>' -ForEach @(
            @{ Name = 'a shell command'; Tool = 'Bash'; Arguments = @{ command = 'rm -rf src' } }
            @{ Name = 'a generic write to a production path'; Tool = 'Write'; Arguments = @{ file_path = 'src/Orders/OrderService.cs'; content = 'x' } }
            @{ Name = 'a generic edit of the profile'; Tool = 'Edit'; Arguments = @{ file_path = 'docs/migration/discovery/domain-profile.yaml'; old_string = 'a'; new_string = 'b' } }
            @{ Name = 'a generic write to a hook'; Tool = 'Write'; Arguments = @{ file_path = '.claude/hooks/x.ps1'; content = 'x' } }
            @{ Name = 'a generic write to a schema'; Tool = 'Write'; Arguments = @{ file_path = 'schemas/discovery/v2/common.schema.json'; content = '{}' } }
            @{ Name = 'a nested agent'; Tool = 'Agent'; Arguments = @{ prompt = 'spawn' } }
            @{ Name = 'another MCP server'; Tool = 'mcp__github__create_issue'; Arguments = @{ title = 't' } }
            @{ Name = 'a root-only operation'; Tool = 'mcp__drm-copilot__configure_discovery_workspace'; Arguments = @{ configuration_action = 'activate' } }
            @{ Name = 'approval escalation'; Tool = 'mcp__drm-copilot__approve_discovery_decision'; Arguments = @{ decision_id = 'd' } }
            @{ Name = 'caller-supplied identity'; Tool = 'mcp__drm-copilot__read_discovery_source'; Arguments = @{ paths = @('src'); agent_id = 'root' } }
            @{ Name = 'a controlled call without invocation_ref'; Tool = 'mcp__drm-copilot__read_discovery_source'; Arguments = @{ paths = @('src') } }
        ) {
            $store = Get-GateStore
            $decision = Invoke-Gate -Json (Get-GateEnvelope -ToolName $Tool -ToolInput $Arguments) -Store $store
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*'
            $store.Writes.Count | Should -Be 0
        }

        It 'denies an envelope whose session holds no invocation for the agent' {
            $decision = Invoke-Gate -Json (Get-GateEnvelope -ToolName 'mcp__drm-copilot__read_discovery_source' -ToolInput ([ordered]@{ paths = @('src'); invocation_ref = 'invocation-alpha' }) -SessionId 'session-beta')
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'no prepared protected invocation'
        }

        It 'allows a bounded read-only native tool' {
            $decision = Invoke-Gate -Json (Get-GateEnvelope -ToolName 'Read' -ToolInput @{ file_path = 'src/Orders/OrderService.cs' })
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'authorizes a controlled draft mutation with a one-use record without any prior completion gate' {
            $store = Get-GateStore
            $toolInput = [ordered]@{ artifact_kind = 'feature-contract'; feature_id = 'orders'; name = 'Orders'; write = $true; invocation_ref = 'invocation-alpha' }
            $decision = Invoke-Gate -Json (Get-GateEnvelope -ToolName 'mcp__drm-copilot__create_discovery_artifact' -ToolInput $toolInput) -Store $store

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $store.Writes.Count | Should -Be 1
            $record = $store.Files[$store.Writes[0]] | ConvertFrom-Json
            $record.tool | Should -Be 'create_discovery_artifact'
            $record.operation | Should -Be 'new-contract'
            $record.input_sha256 | Should -Be (Get-DiscoveryInputDigest -Tool 'create_discovery_artifact' -Operation 'new-contract' -Inputs $toolInput)
            $record.identity.role | Should -Be 'legacy-parity-analyst'
            $record.identity.agent_id | Should -Be 'agent-alpha'
            $record.writer.handler_sha256 | Should -Be (Get-DiscoveryBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes($script:UnderTest)))
            $record.writer.event_id | Should -Be 'tool-use-alpha'
        }

        It 'digests the raw controlled input, invocation_ref included, as the MCP gate does' {
            $store = Get-GateStore
            $inputs = [ordered]@{ analyzer_ids = @('repository'); repository_id = 'legacy-crm'; draft = $false; invocation_ref = 'invocation-alpha' }
            $decision = Invoke-Gate -Json (Get-GateEnvelope -ToolName 'mcp__drm-copilot__run_discovery_repo_inventory' -ToolInput $inputs) -Store $store
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            ($store.Files[$store.Writes[0]] | ConvertFrom-Json).input_sha256 | Should -Be (Get-DiscoveryInputDigest -Tool 'run_discovery_repo_inventory' -Operation 'inventory' -Inputs $inputs)
        }

        It 'denies a controlled tool when discovery is inactive or no invocation is bound' {
            $inputs = [ordered]@{ paths = @('src'); invocation_ref = 'invocation-alpha' }
            (Invoke-Gate -Json (Get-GateEnvelope -ToolName 'mcp__drm-copilot__read_discovery_source' -ToolInput $inputs) -Store (Get-GateStore -ActivationAction 'deactivate')).hookSpecificOutput.permissionDecisionReason | Should -Match 'not active'
            (Invoke-Gate -Json (Get-GateEnvelope -ToolName 'mcp__drm-copilot__read_discovery_source' -ToolInput $inputs) -Store (Get-GateStore -NoInvocation)).hookSpecificOutput.permissionDecisionReason | Should -Match 'no prepared protected invocation'
        }
    }

    Context 'domain neutrality and transport' {
        It 'contains no TaskMaster/TMW/Outlook/VSTO token in its own source text' {
            $sourceText = Get-Content -LiteralPath $script:UnderTest -Raw
            $sourceText | Should -Not -Match 'TaskMaster|TMW|Outlook|VSTO'
        }

        It 'reads the payload through the shared reader and never invokes Python' {
            $hookText = Get-Content -LiteralPath $script:UnderTest -Raw
            $hookText | Should -BeLike '*HookPayload.psm1*'
            $hookText | Should -BeLike '*Read-ClaudeHookRawPayload*'
            $hookText | Should -Not -Match 'python -m|poetry run|Invoke-Expression'
        }

        It 'emits an allow decision at exit 0 through the entry point for a root session' {
            # The mock body returns a captured value so it does not depend on the suite's script scope.
            $envelope = Get-RootEnvelope -ToolName 'Write' -ToolInput @{ file_path = 'README.md'; content = 'x' }
            Mock Read-ClaudeHookRawPayload { $envelope }
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new(''))
                [System.Console]::SetError($errorWriter)
                $global:LASTEXITCODE = 0
                $stdout = @(& $script:UnderTest)
                $exitCode = $LASTEXITCODE
            } finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
            }
            $exitCode | Should -Be 0
            ((@($stdout | ForEach-Object { [string]$_ }) -join "`n") | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
