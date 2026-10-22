#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the Codex discovery capability probe and the Codex event registration (issue #980).
.DESCRIPTION
    .codex/hooks/discovery-capability-probe.ps1 is dot-sourced in-process; the registration and
    handler bytes are the repository's real files served under the fixture workspace root and the
    sentinel runs through the real Codex PreToolUse adapter decision. The registration rows read
    .codex/config.toml directly. No file is written and no process, network or clock is touched.
#>

Describe 'discovery-capability-probe.ps1 (Codex)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/discovery-capability-probe.ps1'
        . $script:UnderTest
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')
        # Baseline null mock for the epic-state read seam in the loaded Codex hook closure (issue #737 guard).
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        if (Get-Command Test-CodexEpicChildRoutingLaunchAuthority -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Test-CodexEpicChildRoutingLaunchAuthority' -Surface 'Codex' }

        function Get-RepoReader {
            param([string[]]$Omit = @())
            $root = $script:RepoRoot
            $prefix = $script:GateWorkspaceRoot + '/'
            $omitted = $Omit
            return {
                param([string]$Path)
                if (-not $Path.StartsWith($prefix)) { return $null }
                $relative = $Path.Substring($prefix.Length)
                if ($omitted -contains $relative) { return $null }
                $full = Join-Path $root $relative
                if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { return $null }
                return , [System.IO.File]::ReadAllBytes($full)
            }.GetNewClosure()
        }

        function Invoke-Probe {
            param([scriptblock]$Reader = (Get-RepoReader), [hashtable]$Store = (Get-GateStore -HostName 'codex'))
            return Invoke-DiscoveryCapabilityProbe -WorkspaceRoot $script:GateWorkspaceRoot -SessionId 'session-alpha' -Nonce $script:GateNonce -HostEnvironment $script:GateHostEnvironment -Store $Store -ReadBytes $Reader -Now $script:GateNow
        }
    }

    It 'resolves the shared capability module to this repository when no published .codex/lib exists' {
        $resolved = Get-DiscoveryHelperModulePath -ModuleName 'DiscoveryCapability.psm1'
        ($resolved -replace '\\', '/') | Should -BeLike '*/.claude/lib/discovery-validation/DiscoveryCapability.psm1'
        Test-Path -LiteralPath $resolved | Should -BeTrue
        (Get-Command Get-DiscoveryCapabilityObservation).Source | Should -Be 'DiscoveryCapability'
    }

    It 'observes the registered Codex handlers and denies the sentinel through the real adapter' {
        $observation = Invoke-Probe
        $observation['status'] | Should -Be 'supported' -Because (($observation['findings'] | ForEach-Object { $_['message'] }) -join '; ')
        $observation['host'] | Should -Be 'codex'
        @($observation['handlers'] | ForEach-Object { $_['path'] } | Sort-Object) | Should -Be @('.codex/hooks/enforce-discovery-artifact-gate.ps1', '.codex/hooks/record-subagent-routing-attestation.ps1', '.codex/hooks/validate-discovery-agent-output.ps1')
        $observation['probe']['result'] | Should -Be 'denied'
        $observation['controls']['trusted_attribution'] | Should -BeTrue
    }

    It 'reports unsupported when the config omits the stop registration' {
        $observation = Invoke-Probe -Reader (Get-RepoReader -Omit @('.codex/hooks/validate-discovery-agent-output.ps1'))
        $observation['status'] | Should -Be 'unsupported'
        $observation['controls']['stop_event'] | Should -BeFalse
    }

    Context '.codex/config.toml registration' {
        BeforeAll {
            $script:Config = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot '.codex/config.toml')
        }

        It 'admits every discovery agent variant in the SubagentStart and SubagentStop matchers' {
            $matchers = @([regex]::Matches($script:Config, '(?m)^matcher = "(?<m>[^"]+)"$') | ForEach-Object { $_.Groups['m'].Value })
            $startStop = @($matchers | Where-Object { $_ -like '*epic-planner|epic-orchestrator*' })
            $startStop.Count | Should -Be 2
            foreach ($matcher in $startStop) {
                foreach ($agent in @('legacy-parity-analyst', 'legacy-parity-analyst-c3', 'runtime-characterization-analyst', 'requirements-reconciler-c3-elevated', 'migration-coverage-reviewer-c1')) { $agent | Should -Match $matcher }
            }
        }

        It 'registers the artifact gate on the broad and spawn PreToolUse groups, the planning gate on spawn, and the output validator on the discovery stop group' {
            $script:Config | Should -Match '(?m)^matcher = "\^\(Agent\|Task\|spawn_agent\|run_subagent\|delegate\)\$"'
            # Each registration carries a command and a command_windows line.
            ([regex]::Matches($script:Config, 'enforce-discovery-artifact-gate\.ps1"''')).Count | Should -Be 4
            ([regex]::Matches($script:Config, 'enforce-discovery-planning-gate\.ps1"''')).Count | Should -Be 2
            $script:Config | Should -Match '(?m)^matcher = "legacy-parity-analyst\|runtime-characterization-analyst\|requirements-reconciler\|migration-coverage-reviewer"'
            ([regex]::Matches($script:Config, 'validate-discovery-agent-output\.ps1"''')).Count | Should -Be 2
        }
    }
}
