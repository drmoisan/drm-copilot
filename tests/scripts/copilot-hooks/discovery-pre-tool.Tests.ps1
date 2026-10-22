#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the GitHub Copilot native discovery PreToolUse adapter (issue #980).
.DESCRIPTION
    .github/hooks/discovery-pre-tool.ps1 is dot-sourced in-process and takes the shared
    helpers from .claude/lib/discovery-validation. Decision rows inject every seam from the
    shared gate fixtures with camelCase Copilot envelopes; the entry-point row redirects stdin
    and stderr through the console readers and restores them in finally. No file, process,
    network or clock is touched.
#>

Describe 'Copilot discovery-pre-tool.ps1' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.github/hooks/discovery-pre-tool.ps1'
        . $script:UnderTest
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')

        function Get-CopilotDecision {
            param(
                [Parameter(Mandatory = $true)][AllowNull()][AllowEmptyString()][string]$Json,
                [Parameter(Mandatory = $false)][hashtable]$Environment = (Get-GateEnvironment -HostName 'github-copilot'),
                [Parameter(Mandatory = $false)][hashtable]$Store = (Get-GateStore -HostName 'github-copilot')
            )
            return (Invoke-DiscoveryPreToolDecision -ToolInputRaw $Json -EnvironmentValues $Environment -HostEnvironment $script:GateHostEnvironment -Store $Store -Now $script:GateNow -Nonce $script:GateNonce).hookSpecificOutput
        }
    }

    It 'loads every helper module without a dependency failure' {
        $script:DiscoveryGateDependencyFailures.Count | Should -Be 0
    }

    It 'allows an ordinary Copilot session without an attested agent' {
        $decision = Get-CopilotDecision -Json (Get-GateEnvelope -HostName 'github-copilot' -ToolName 'run_in_terminal' -ToolInput @{ command = 'ls' }) -Environment (Get-GateEnvironment -HostName 'github-copilot' -NoAgent)
        $decision.permissionDecision | Should -Be 'allow'
    }

    It 'denies <Name> for an attested Copilot discovery agent' -ForEach @(
        @{ Name = 'a terminal command'; Tool = 'run_in_terminal'; Arguments = @{ command = 'rm -rf src' } }
        @{ Name = 'a file edit'; Tool = 'insert_edit_into_file'; Arguments = @{ filePath = 'src/Orders.cs'; code = 'x' } }
        @{ Name = 'a file creation'; Tool = 'create_file'; Arguments = @{ filePath = 'config/discovery.json'; content = '{}' } }
        @{ Name = 'a foreign MCP server'; Tool = 'mcp__github__create_issue'; Arguments = @{ title = 't' } }
        @{ Name = 'a root-only discovery tool'; Tool = 'mcp__drm-copilot__migrate_discovery_artifacts'; Arguments = @{ destination = 'docs/v2' } }
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
        $decision = Get-CopilotDecision -Json (Get-GateEnvelope -HostName 'github-copilot' -ToolName 'mcp__drm-copilot__run_discovery_repo_inventory' -ToolInput (Get-GateInventoryInput)) -Store $store
        $decision.permissionDecision | Should -Be 'allow'
        $store.Writes.Count | Should -Be 1
        $record = $store.Files[$store.Writes[0]] | ConvertFrom-Json
        $record.identity.host | Should -Be 'github-copilot'
        $record.input_sha256 | Should -Be $script:GateInventoryInputSha256
        $record.request_id | Should -Be 'tool-use-alpha'
    }

    It 'denies an unreadable envelope and a snake_case envelope whose session is not attested' {
        (Get-CopilotDecision -Json '{').permissionDecision | Should -Be 'deny'
        (Get-CopilotDecision -Json (Get-GateEnvelope -HostName 'github-copilot' -ToolName 'read_file' -ToolInput @{ filePath = 'x' } -SessionId 'session-beta')).permissionDecisionReason | Should -Match 'could not be attributed'
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
        Mock Get-DiscoveryHostEnvironmentValueTable { Get-GateEnvironment -HostName 'github-copilot' -NoAgent }
        $priorIn = [System.Console]::In
        $priorError = [System.Console]::Error
        $errorWriter = [System.IO.StringWriter]::new()
        try {
            [System.Console]::SetIn([System.IO.StringReader]::new((Get-GateEnvelope -HostName 'github-copilot' -ToolName 'create_file' -ToolInput @{ filePath = 'x'; content = 'y' })))
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
