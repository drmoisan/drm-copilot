#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the GitHub Copilot native discovery PreToolUse adapter (issue #980).
.DESCRIPTION
    .github/hooks/discovery-pre-tool.ps1 is dot-sourced in-process and takes the shared
    helpers from .claude/lib/discovery-validation. Decision rows inject every seam from the
    shared gate fixtures with camelCase Copilot envelopes whose agentId and agentType carry
    the identity; the entry-point row redirects stdin and stderr through the console
    readers and restores them in finally. No file, process, network or clock is touched.
#>

Describe 'Copilot discovery-pre-tool.ps1' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.github/hooks/discovery-pre-tool.ps1'
        . $script:UnderTest
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryStart.TestSupport.ps1')

        function Get-CopilotDecision {
            param(
                [Parameter(Mandatory = $true)][AllowNull()][AllowEmptyString()][string]$Json,
                [Parameter(Mandatory = $false)][hashtable]$Store = (Get-GateStore -HostName 'github-copilot')
            )
            return (Invoke-DiscoveryPreToolDecision -ToolInputRaw $Json -HostEnvironment $script:GateHostEnvironment -Store $Store -Now $script:GateNow -Nonce $script:GateNonce).hookSpecificOutput
        }
    }

    It 'loads every helper module without a dependency failure' {
        $script:DiscoveryGateDependencyFailures.Count | Should -Be 0
    }

    It 'allows a root Copilot session without an agent identity' {
        $decision = Get-CopilotDecision -Json (Get-GateEnvelope -HostName 'github-copilot' -ToolName 'run_in_terminal' -ToolInput @{ command = 'ls' } -AgentId $null -AgentType $null)
        $decision.permissionDecision | Should -Be 'allow'
    }

    It 'denies <Name> for a payload-attributed Copilot discovery agent' -ForEach @(
        @{ Name = 'a terminal command'; Tool = 'run_in_terminal'; Arguments = @{ command = 'rm -rf src' } }
        @{ Name = 'a file edit'; Tool = 'insert_edit_into_file'; Arguments = @{ filePath = 'src/Orders.cs'; code = 'x' } }
        @{ Name = 'a file creation'; Tool = 'create_file'; Arguments = @{ filePath = 'config/discovery.json'; content = '{}' } }
        @{ Name = 'a foreign MCP server'; Tool = 'mcp__github__create_issue'; Arguments = @{ title = 't' } }
        @{ Name = 'a root-only discovery tool'; Tool = 'mcp__drm-copilot__migrate_discovery_artifacts'; Arguments = @{ destination = 'docs/v2' } }
        @{ Name = 'a controlled call without invocation_ref'; Tool = 'mcp__drm-copilot__read_discovery_source'; Arguments = @{ paths = @('src') } }
    ) {
        $store = Get-GateStore -HostName 'github-copilot'
        $decision = Get-CopilotDecision -Json (Get-GateEnvelope -HostName 'github-copilot' -ToolName $Tool -ToolInput $Arguments) -Store $store
        $decision.permissionDecision | Should -Be 'deny'
        $decision.permissionDecisionReason | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*'
        $store.Writes.Count | Should -Be 0
    }

    It 'allows a read-only tool and authorizes a controlled request with a one-use record' {
        $store = Get-GateStore -HostName 'github-copilot'
        (Get-CopilotDecision -Json (Get-GateEnvelope -HostName 'github-copilot' -ToolName 'read_file' -ToolInput @{ filePath = 'src/Orders.cs' }) -Store $store).permissionDecision | Should -Be 'allow'
        $store.Writes.Count | Should -Be 0
        $inputs = [ordered]@{ analyzer_ids = @('repository'); repository_id = 'legacy-crm'; draft = $false; invocation_ref = 'invocation-alpha' }
        $decision = Get-CopilotDecision -Json (Get-GateEnvelope -HostName 'github-copilot' -ToolName 'mcp__drm-copilot__run_discovery_repo_inventory' -ToolInput $inputs) -Store $store
        $decision.permissionDecision | Should -Be 'allow'
        $store.Writes.Count | Should -Be 1
        $record = $store.Files[$store.Writes[0]] | ConvertFrom-Json
        $record.identity.host | Should -Be 'github-copilot'
        $record.input_sha256 | Should -Be (Get-DiscoveryInputDigest -Tool 'run_discovery_repo_inventory' -Operation 'inventory' -Inputs $inputs)
        $record.request_id | Should -Be 'tool-use-alpha'
    }

    It 'binds a Copilot specialist at its first controlled call when the harness supplied no start identity' {
        $store = Get-StartStore -HostName 'github-copilot'
        $store['ReadBytes'] = Get-StartProfileReader -HostName 'github-copilot'
        $decision = Get-CopilotDecision -Json (Get-GateEnvelope -HostName 'github-copilot' -ToolName 'mcp__drm-copilot__read_discovery_source' -ToolInput ([ordered]@{ paths = @('src'); invocation_ref = 'invocation-alpha' }) -AgentType 'legacy-parity-analyst-c3') -Store $store
        $decision.permissionDecision | Should -Be 'allow' -Because $decision.permissionDecisionReason
        $store.Writes.Count | Should -Be 2
        ($store.Files["$($script:GateInvocationDirectory)/invocation.json"] | ConvertFrom-Json).state | Should -Be 'started'
    }

    It 'grants a root prepare and denies an unreadable envelope' {
        $store = Get-StartStore -HostName 'github-copilot'
        (Get-CopilotDecision -Json (Get-GateEnvelope -HostName 'github-copilot' -ToolName 'mcp__drm-copilot__prepare_discovery_agent' -ToolInput @{ skill_id = 'inventory-legacy-system' } -AgentId $null -AgentType $null) -Store $store).permissionDecision | Should -Be 'allow'
        ($store.Files[$store.Writes[0]] | ConvertFrom-Json).artifact_kind | Should -Be 'root-grant'
        (Get-CopilotDecision -Json '{').permissionDecision | Should -Be 'deny'
    }

    It 'denies naming the helper when a module failed to load' {
        $script:DiscoveryGateDependencyFailures.Add([pscustomobject]@{ Name = 'DiscoveryAuthority.psm1'; Message = 'simulated' })
        try {
            $decision = Get-CopilotDecision -Json (Get-GateEnvelope -HostName 'github-copilot' -ToolName 'read_file' -ToolInput @{ filePath = 'x' })
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*DiscoveryAuthority.psm1*'
        } finally {
            $script:DiscoveryGateDependencyFailures.Clear()
        }
    }

    It 'emits the decision JSON at exit 0 through the entry point' {
        $priorIn = [System.Console]::In
        $priorError = [System.Console]::Error
        $errorWriter = [System.IO.StringWriter]::new()
        try {
            [System.Console]::SetIn([System.IO.StringReader]::new((Get-GateEnvelope -HostName 'github-copilot' -ToolName 'create_file' -ToolInput @{ filePath = 'x'; content = 'y' } -AgentId $null -AgentType $null)))
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
