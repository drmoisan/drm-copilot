#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Tests for scripts/dev-tools/Test-DiscoveryHostCapability.ps1 (issue #980).
.DESCRIPTION
    The operator entry point is dot-sourced in-process; the probe run is a script-block seam, so no
    process, network or clock is touched. A missing, disabled or unsupported host is a failure
    (exit 2), an unsupported observation exits 1 and a supported one exits 0.
#>

Describe 'Test-DiscoveryHostCapability.ps1' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot 'scripts/dev-tools/Test-DiscoveryHostCapability.ps1') -HostName 'claude-code'
    }

    It 'resolves the <HostName> probe to <Path>' -ForEach @(
        @{ HostName = 'claude-code'; Path = '.claude/hooks/discovery-capability-probe.ps1' }
        @{ HostName = 'codex'; Path = '.codex/hooks/discovery-capability-probe.ps1' }
        @{ HostName = 'github-copilot'; Path = '.github/hooks/discovery-capability-probe.ps1' }
        @{ HostName = 'cursor'; Path = $null }
    ) {
        Resolve-DiscoveryHostProbe -HostName $HostName | Should -Be $Path
        if ($null -ne $Path) { Test-Path -LiteralPath (Join-Path $script:RepoRoot $Path) | Should -BeTrue }
    }

    It 'exits 2 with an unsupported document when the host has no installed probe' {
        $result = Invoke-DiscoveryHostCapabilityTest -HostName 'codex' -WorkspaceRoot 'C:/Users/Example/Repos/NoHooks' -SessionId 's'
        $result.ExitCode | Should -Be 2
        $result.Document['status'] | Should -Be 'unsupported'
        $result.Document['findings'][0]['message'] | Should -BeLike "*No capability probe is installed for host 'codex'*"
    }

    It 'returns the probe verdict as the exit code and forwards the workspace, session, trust and runtime' {
        $script:Seen = $null
        $run = { param([string]$Path, [hashtable]$Arguments) $script:Seen = @{ Path = $Path; Arguments = $Arguments }; [ordered]@{ status = 'supported' } }
        $result = Invoke-DiscoveryHostCapabilityTest -HostName 'claude-code' -WorkspaceRoot $script:RepoRoot -SessionId 'session-alpha' -WorkspaceTrusted $false -RuntimeJson '{"schema_version":"2.0.0"}' -RunProbe $run
        $result.ExitCode | Should -Be 0
        ($script:Seen.Path -replace '\\', '/') | Should -BeLike '*/.claude/hooks/discovery-capability-probe.ps1'
        $script:Seen.Arguments.SessionId | Should -Be 'session-alpha'
        $script:Seen.Arguments.WorkspaceTrusted | Should -BeFalse
        $script:Seen.Arguments.RuntimeJson | Should -Be '{"schema_version":"2.0.0"}'
        (Invoke-DiscoveryHostCapabilityTest -HostName 'claude-code' -WorkspaceRoot $script:RepoRoot -SessionId 's' -RunProbe { [ordered]@{ status = 'unsupported' } }).ExitCode | Should -Be 1
    }
}
