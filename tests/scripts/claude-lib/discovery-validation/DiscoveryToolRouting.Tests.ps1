#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Tool-routing tests for `.claude/lib/discovery-validation/DiscoveryToolRouting.psm1` (issue #980).
.DESCRIPTION
    Proves tool-family routing, operation derivation, digest parity with the shared
    host fixture and the read-only table accessors. The routing cases moved here
    unchanged from the DiscoveryAuthorization suite when the tables and helpers moved
    into their own module. No file, process, network or clock is touched.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $lib = Join-Path $script:RepoRoot '.claude/lib/discovery-validation'
    # Leaf modules are imported last so no nested import replaces a visible one.
    Import-Module (Join-Path $lib 'DiscoveryToolRouting.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryAuthority.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryEncoding.psm1') -Force
    . (Join-Path $PSScriptRoot 'DiscoveryGate.TestSupport.ps1')
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

Describe 'routing table accessors' {
    It 'exposes the controlled tools, root-only tools and operations, and caller identity keys' {
        $controlled = @(Get-DiscoveryControlledToolName)
        $controlled | Should -Contain 'read_discovery_source'
        $controlled | Should -Contain 'finalize_discovery_agent'
        $controlled | Should -Not -Contain 'prepare_discovery_agent'
        @(Get-DiscoveryRootOnlyToolName) | Should -Contain 'prepare_discovery_agent'
        @(Get-DiscoveryRootOnlyToolName) | Should -Contain 'run_discovery_doctor'
        @(Get-DiscoveryRootOnlyOperationName) | Should -Contain 'prepare-agent'
        @(Get-DiscoveryCallerIdentityKey | Sort-Object) | Should -Be @('agent_id', 'host', 'invocation_id', 'request_id', 'role', 'session_id')
    }

    It 'reads a member of a hashtable and of a PSCustomObject tool input' {
        Get-DiscoveryInputMember -ToolInput @{ paths = @('src') } -Name 'paths' | Should -Be @('src')
        Get-DiscoveryInputMember -ToolInput ([pscustomobject]@{ report_type = 'parity' }) -Name 'report_type' | Should -Be 'parity'
        Get-DiscoveryInputMember -ToolInput @{} -Name 'absent' | Should -BeNullOrEmpty
    }
}
