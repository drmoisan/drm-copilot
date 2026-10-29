#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the Codex native discovery PreToolUse adapter (issue #980).
.DESCRIPTION
    .codex/hooks/enforce-discovery-artifact-gate.ps1 is dot-sourced in-process; the helper
    modules resolve to .claude/lib because this repository publishes .codex/lib only
    into destinations. Decision rows inject every seam from the shared gate fixtures and
    take the identity from the payload fixture; entry-point rows redirect stdin, stdout
    and stderr through the console readers and restore them in finally. No file,
    process, network or clock is touched.
#>

Describe 'Codex enforce-discovery-artifact-gate.ps1' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-discovery-artifact-gate.ps1'
        . $script:UnderTest
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryStart.TestSupport.ps1')

        function Get-CodexOutcome {
            param(
                [Parameter(Mandatory = $true)][AllowNull()][AllowEmptyString()][string]$Json,
                [Parameter(Mandatory = $false)][hashtable]$Store = (Get-GateStore -HostName 'codex')
            )
            return Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $Json -HostEnvironment $script:GateHostEnvironment -Store $Store -Now $script:GateNow -Nonce $script:GateNonce
        }

        function Invoke-CodexEntryPoint {
            param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$PayloadRaw)
            $originalIn = [System.Console]::In
            $originalOut = [System.Console]::Out
            $originalError = [System.Console]::Error
            $outWriter = [System.IO.StringWriter]::new()
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))
                [System.Console]::SetOut($outWriter)
                [System.Console]::SetError($errorWriter)
                $exitCode = Invoke-DiscoveryArtifactGateEntryPoint -PayloadRaw ([System.Console]::In.ReadToEnd())
                return [pscustomobject]@{ ExitCode = $exitCode; Stdout = $outWriter.ToString(); Stderr = $errorWriter.ToString() }
            } finally {
                [System.Console]::SetIn($originalIn)
                [System.Console]::SetOut($originalOut)
                [System.Console]::SetError($originalError)
            }
        }
    }

    It 'resolves the helper modules from the published location first and the repository second' {
        $published = Get-DiscoveryHelperModulePath -ModuleName 'DiscoveryAuthority.psm1' -ScriptRoot 'C:/dest/.codex/hooks'
        ($published -replace '\\', '/') | Should -Be 'C:/dest/.codex/hooks/../lib/discovery-validation/DiscoveryAuthority.psm1'
        $selfHosted = Get-DiscoveryHelperModulePath -ModuleName 'DiscoveryAuthority.psm1'
        ($selfHosted -replace '\\', '/') | Should -BeLike '*.claude/lib/discovery-validation/DiscoveryAuthority.psm1'
        Test-Path -LiteralPath $selfHosted | Should -BeTrue
    }

    It 'allows every non-grant tool for a root Codex payload without an agent identity' {
        $store = Get-StartStore -HostName 'codex'
        foreach ($tool in @('apply_patch', 'shell', 'mcp__drmCopilotExtension__run_discovery_init')) {
            (Get-CodexOutcome -Json (Get-GateEnvelope -HostName 'codex' -ToolName $tool -ToolInput @{ x = 1 } -AgentId $null -AgentType $null) -Store $store).Decision | Should -Be 'allow' -Because $tool
        }
        $store.Writes.Count | Should -Be 0
    }

    It 'grants a root Codex doctor call once with a root grant bound to the codex host' {
        $store = Get-StartStore -HostName 'codex'
        $outcome = Get-CodexOutcome -Json (Get-GateEnvelope -HostName 'codex' -ToolName 'mcp__drmCopilotExtension__run_discovery_doctor' -ToolInput @{} -AgentId $null -AgentType $null) -Store $store
        $outcome.Code | Should -Be 'ROOT_GRANTED'
        ($store.Files[$outcome.RecordPath] | ConvertFrom-Json).host | Should -Be 'codex'
    }

    It 'denies <Name> for a payload-attributed Codex discovery agent' -ForEach @(
        @{ Name = 'a shell command'; Tool = 'shell'; Arguments = @{ command = @('rm', '-rf', 'src') }; Code = 'SHELL' }
        @{ Name = 'an apply_patch mutation'; Tool = 'apply_patch'; Arguments = @{ input = '*** Begin Patch' }; Code = 'MUTATION' }
        @{ Name = 'a foreign MCP server'; Tool = 'mcp__github__create_issue'; Arguments = @{ title = 't' }; Code = 'FOREIGN_MCP' }
        @{ Name = 'a root-only discovery operation'; Tool = 'mcp__drmCopilotExtension__run_discovery_init'; Arguments = @{}; Code = 'ROOT_ONLY' }
        @{ Name = 'a caller-supplied invocation id'; Tool = 'mcp__drmCopilotExtension__read_discovery_source'; Arguments = @{ paths = @('src'); invocation_id = 'x' }; Code = 'CALLER_IDENTITY' }
        @{ Name = 'a controlled call without invocation_ref'; Tool = 'mcp__drmCopilotExtension__read_discovery_source'; Arguments = @{ paths = @('src') }; Code = 'INVOCATION_REF' }
    ) {
        $store = Get-GateStore -HostName 'codex'
        $outcome = Get-CodexOutcome -Json (Get-GateEnvelope -HostName 'codex' -ToolName $Tool -ToolInput $Arguments) -Store $store
        $outcome.Decision | Should -Be 'deny'
        $outcome.Code | Should -Be $Code
        $store.Writes.Count | Should -Be 0
    }

    It 'authorizes a controlled Codex request with a record bound to the codex host' {
        $store = Get-GateStore -HostName 'codex'
        $inputs = [ordered]@{ analyzer_ids = @('repository'); repository_id = 'legacy-crm'; draft = $false; invocation_ref = 'invocation-alpha' }
        $outcome = Get-CodexOutcome -Json (Get-GateEnvelope -HostName 'codex' -ToolName 'mcp__drmCopilotExtension__run_discovery_repo_inventory' -ToolInput $inputs) -Store $store
        $outcome.Decision | Should -Be 'allow'
        $record = $store.Files[$outcome.RecordPath] | ConvertFrom-Json
        $record.identity.host | Should -Be 'codex'
        $record.identity.agent_id | Should -Be 'agent-alpha'
        $record.writer.host | Should -Be 'codex'
        $record.input_sha256 | Should -Be (Get-DiscoveryInputDigest -Tool 'run_discovery_repo_inventory' -Operation 'inventory' -Inputs $inputs)
        $record.writer.handler_sha256 | Should -Be (Get-DiscoveryBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes($script:UnderTest)))
    }

    It 'denies a Codex agent whose invocation is bound to the Claude host' {
        $store = Get-GateStore -HostName 'claude-code'
        (Get-CodexOutcome -Json (Get-GateEnvelope -HostName 'codex' -ToolName 'mcp__drmCopilotExtension__read_discovery_source' -ToolInput ([ordered]@{ paths = @('src'); invocation_ref = 'invocation-alpha' })) -Store $store).Code | Should -Be 'NO_INVOCATION'
    }

    It 'reports PROFILE when a Codex specialist without an attested start makes its first controlled call' {
        # The Codex SubagentStart attestation binds the prepared invocation; the gate reads no TOML profile itself.
        $store = Get-StartStore -HostName 'codex'
        $outcome = Get-CodexOutcome -Json (Get-GateEnvelope -HostName 'codex' -ToolName 'mcp__drmCopilotExtension__read_discovery_source' -ToolInput ([ordered]@{ paths = @('src'); invocation_ref = 'invocation-alpha' }) -AgentType 'legacy-parity-analyst-c3') -Store $store
        $outcome.Decision | Should -Be 'deny'
        $outcome.Code | Should -Be 'PROFILE'
        $store.Writes.Count | Should -Be 0
    }

    Context 'entry point' {
        It 'exits 2 with the reason on stderr for an unreadable envelope' {
            $result = Invoke-CodexEntryPoint -PayloadRaw '{'
            $result.ExitCode | Should -Be 2
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*'
        }

        It 'allows silently for a root session' {
            $result = Invoke-CodexEntryPoint -PayloadRaw (Get-GateEnvelope -HostName 'codex' -ToolName 'apply_patch' -ToolInput @{ input = 'patch' } -AgentId $null -AgentType $null)
            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -BeNullOrEmpty
        }

        It 'writes the deny decision for a payload-attributed agent using a shell tool' {
            $result = Invoke-CodexEntryPoint -PayloadRaw (Get-GateEnvelope -HostName 'codex' -ToolName 'shell' -ToolInput @{ command = @('ls') })
            $result.ExitCode | Should -Be 0
            $decision = ($result.Stdout | ConvertFrom-Json).hookSpecificOutput
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*'
        }

        It 'denies naming the dependency when a helper failed to load' {
            Add-HookDependencyFailure -Name 'DiscoveryAuthorization.psm1'
            try {
                $outcome = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw (Get-GateEnvelope -HostName 'codex' -ToolName 'shell' -ToolInput @{ command = @('ls') })
                $outcome.hookSpecificOutput.permissionDecision | Should -Be 'deny'
                $outcome.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*DiscoveryAuthorization.psm1*'
            } finally {
                $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            }
        }
    }
}
