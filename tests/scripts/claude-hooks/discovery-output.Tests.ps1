#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Per-role output validation tests for the Claude Code discovery SubagentStop adapter (issue #980).
.DESCRIPTION
    .claude/hooks/validate-discovery-artifact-gate.ps1 is dot-sourced in-process; the
    environment table, host roots, protected store and workspace bytes are injected from the
    shared gate, start and stop fixtures, so no file, process, network or clock is touched.
    Every role's stop result is derived from its protected invocation and receipt; the final
    message never grants authority.
#>

Describe 'validate-discovery-artifact-gate.ps1 per-role output validation' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.claude/hooks/validate-discovery-artifact-gate.ps1'
        . $script:UnderTest
        . (Join-Path $PSScriptRoot '../claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')
        . (Join-Path $PSScriptRoot '../claude-lib/discovery-validation/DiscoveryStart.TestSupport.ps1')
        . (Join-Path $PSScriptRoot '../claude-lib/discovery-validation/DiscoveryStop.TestSupport.ps1')

        function Invoke-Stop {
            param(
                [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$Json = (Get-StopEnvelope),
                [Parameter(Mandatory = $false)][hashtable]$Environment = (Get-StartEnvironment),
                [Parameter(Mandatory = $false)][hashtable]$Store = (Get-StopStore),
                [Parameter(Mandatory = $false)][hashtable]$Workspace = (Get-StopWorkspace)
            )
            return Invoke-DiscoveryArtifactGateValidation -InputText $Json -EnvironmentValues $Environment -HostEnvironment $script:GateHostEnvironment -Store $Store -ReadBytes (Get-StopByteReader -Workspace $Workspace)
        }
    }

    It 'allows a finalized <Role> stop (<AgentType>) and reads only the protected store' -ForEach @(
        @{ Role = 'legacy-parity-analyst'; AgentType = 'legacy-parity-analyst-c3' }
        @{ Role = 'runtime-characterization-analyst'; AgentType = 'runtime-characterization-analyst-c2' }
        @{ Role = 'requirements-reconciler'; AgentType = 'requirements-reconciler-c3-elevated' }
        @{ Role = 'migration-coverage-reviewer'; AgentType = 'migration-coverage-reviewer-c1' }
    ) {
        $store = Get-StopStore -Role $Role
        $result = Invoke-Stop -Json (Get-StopEnvelope -AgentType $AgentType) -Store $store
        $result.Ok | Should -BeTrue -Because $result.Message
        $result.Code | Should -Be 'VALIDATED'
        $store.Reads | Should -Not -Contain $script:StartMirrorPath
        @($store.Reads | Where-Object { $_ -like '*artifacts/orchestration*' }).Count | Should -Be 0
    }

    It 'blocks <Name> with the gate prefix and code <Code>' -ForEach @(
        @{ Name = 'a specialist that never finalized'; Code = 'NOT_FINALIZED'; Store = @{ State = 'started' }; Text = 'Result: PASS'; Mutation = $null }
        @{ Name = 'success prose and a filename without a receipt'; Code = 'RECEIPT'; Store = @{ NoReceipt = $true }; Text = 'Wrote docs/migration/discovery/coverage-ledger.json successfully. Result: PASS'; Mutation = $null }
        @{ Name = 'a blank final message over a valid receipt'; Code = 'RESULT_TEXT'; Store = @{}; Text = ''; Mutation = $null }
        @{ Name = 'a receipt for another session'; Code = 'IDENTITY'; Store = @{ IdentityOverrides = @{ session_id = 'session-beta' } }; Text = 'Result: PASS'; Mutation = $null }
        @{ Name = 'a receipt for a root gate mode'; Code = 'GATE'; Store = @{ ReceiptOverrides = @{ mode = 'planning' } }; Text = 'Result: PASS'; Mutation = $null }
        @{ Name = 'a forged workspace receipt'; Code = 'FORGED'; Store = @{ WriterOverrides = @{ kind = 'workspace-copy' } }; Text = 'Result: PASS'; Mutation = $null }
        @{ Name = 'an absent required output'; Code = 'OUTPUT_MISSING'; Store = @{}; Text = 'Result: PASS'; Mutation = 'no-output' }
        @{ Name = 'a stale input'; Code = 'STALE_INPUTS'; Store = @{}; Text = 'Result: PASS'; Mutation = 'edited-input' }
    ) {
        $workspace = Get-StopWorkspace
        if ($Mutation -eq 'no-output') { $workspace.Remove($script:StopOutputPath) }
        if ($Mutation -eq 'edited-input') { $workspace[$script:StopSourcePath] = [System.Text.Encoding]::UTF8.GetBytes('changed') }
        $result = Invoke-Stop -Json (Get-StopEnvelope -Text $Text) -Store (Get-StopStore @Store) -Workspace $workspace
        $result.Ok | Should -BeFalse -Because $Name
        $result.Code | Should -Be $Code -Because $result.Message
        $result.Message | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*'
    }

    It 'allows an output-valid failing reviewer report that states FAIL' {
        $result = Invoke-Stop -Json (Get-StopEnvelope -AgentType 'migration-coverage-reviewer-c1' -Text 'Coverage review complete. Result: FAIL') -Store (Get-StopStore -Role 'migration-coverage-reviewer' -ValidationResult 'fail')
        $result.Ok | Should -BeTrue -Because $result.Message
    }

    It 'allows an ordinary agent stop without reading the protected store' {
        $store = Get-StopStore
        $result = Invoke-Stop -Json (Get-StopEnvelope -AgentType 'atomic-executor' -Text 'Wrote discovery/coverage-ledger/coverage-ledger.json successfully.') -Store $store
        $result.Ok | Should -BeTrue
        $result.Code | Should -Be 'NOT_DISCOVERY_AGENT'
        $store.Reads.Count | Should -Be 0
    }

    It 'allows with CONTINUED once a continuation was already requested' {
        $result = Invoke-Stop -Json (Get-StopEnvelope -StopHookActive $true) -Store (Get-StopStore -NoReceipt)
        $result.Ok | Should -BeTrue
        $result.Code | Should -Be 'CONTINUED'
    }
}
