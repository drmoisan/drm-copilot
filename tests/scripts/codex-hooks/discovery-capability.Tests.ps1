#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the Codex discovery capability probe and the Codex event registration (issue #980).
.DESCRIPTION
    .codex/hooks/discovery-capability-probe.ps1 is dot-sourced in-process; the registration and
    handler bytes are the repository's real files served under the fixture workspace root and the
    protected store holds the host observations the Codex PreToolUse gate recorded for the
    capability sentinel agent (seeded through the shared fixtures). Whether Codex places agent_id
    on a PreToolUse payload is observed, never assumed: an observation without it is unsupported.
    The registration rows read .codex/config.toml directly. No file is written and no process,
    network or clock is touched.
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
            param([scriptblock]$Reader = (Get-RepoReader), [hashtable]$Store = (Add-GateSentinelObservation -Store (Get-GateStore -HostName 'codex') -HostName 'codex'))
            return Invoke-DiscoveryCapabilityProbe -WorkspaceRoot $script:GateWorkspaceRoot -SessionId 'session-alpha' -Nonce $script:GateNonce -HostEnvironment $script:GateHostEnvironment -Store $Store -ReadBytes $Reader -Now $script:GateNow
        }

        function Get-FindingText { param([System.Collections.IDictionary]$Observation) return (@($Observation['findings'] | ForEach-Object { $_['message'] }) -join ' | ') }
    }

    It 'resolves the shared capability module to this repository when no published .codex/lib exists' {
        $resolved = Get-DiscoveryHelperModulePath -ModuleName 'DiscoveryCapability.psm1'
        ($resolved -replace '\\', '/') | Should -BeLike '*/.claude/lib/discovery-validation/DiscoveryCapability.psm1'
        Test-Path -LiteralPath $resolved | Should -BeTrue
        (Get-Command Get-DiscoveryCapabilityObservation).Source | Should -Be 'DiscoveryCapability'
    }

    It 'observes the registered Codex handlers and proves attribution from the recorded sentinel observation pair' {
        $observation = Invoke-Probe
        $observation['status'] | Should -Be 'supported' -Because (Get-FindingText -Observation $observation)
        $observation['host'] | Should -Be 'codex'
        @($observation['handlers'] | ForEach-Object { $_['path'] } | Sort-Object) | Should -Be @('.codex/hooks/enforce-discovery-artifact-gate.ps1', '.codex/hooks/record-subagent-routing-attestation.ps1', '.codex/hooks/validate-discovery-agent-output.ps1')
        $observation['controls']['trusted_attribution'] | Should -BeTrue
        $observation['controls']['forbidden_tools_denied'] | Should -BeTrue
        $observation['probe']['result'] | Should -Be 'denied'
        $observation['probe']['sentinel_id'] | Should -Be $script:GateSentinelToolRef
        $observation['probe']['evidence_ref'] | Should -Be $script:GateSentinelShellRef
    }

    It 'reports unsupported naming <Control> for <Name>' -ForEach @(
        @{ Name = 'a session with no observation'; Seed = @{ NoTool = $true; NoShell = $true }; Control = 'trusted_attribution'; Text = 'no sentinel tool observation' }
        @{ Name = 'a session with no observation'; Seed = @{ NoTool = $true; NoShell = $true }; Control = 'forbidden_tools_denied'; Text = 'no SHELL deny observation' }
        @{ Name = 'a Codex-shaped observation without agent_id'; Seed = @{ Tool = @{ agent_id = $null; agent_type = $null } }; Control = 'trusted_attribution'; Text = 'carries no sentinel agent identity' }
        @{ Name = 'a stale observation'; Seed = @{ Tool = @{ observed_at = '2026-10-22T10:00:00Z' } }; Control = 'trusted_attribution'; Text = 'is stale' }
        @{ Name = 'a handler-hash mismatch'; Seed = @{ Tool = @{ handler_sha256 = ('f' * 64) } }; Control = 'trusted_attribution'; Text = 'hash differs' }
        @{ Name = 'an unconsumed sentinel grant'; Seed = @{ NoLatch = $true }; Control = 'trusted_attribution'; Text = 'was not consumed' }
    ) {
        $observation = Invoke-Probe -Store (Add-GateSentinelObservation -Store (Get-GateStore -HostName 'codex') -HostName 'codex' @Seed)
        $observation['status'] | Should -Be 'unsupported' -Because $Name
        $observation['controls'][$Control] | Should -BeFalse
        Get-FindingText -Observation $observation | Should -BeLike "*Native control $Control is not proved:*$Text*"
        $observation['probe']['result'] | Should -Be 'unavailable'
        $observation['probe']['evidence_ref'] | Should -BeNullOrEmpty
    }

    It 'reports unsupported when the config omits the stop registration' {
        $observation = Invoke-Probe -Reader (Get-RepoReader -Omit @('.codex/hooks/validate-discovery-agent-output.ps1'))
        $observation['status'] | Should -Be 'unsupported'
        $observation['controls']['stop_event'] | Should -BeFalse
    }

    It 'persists the observation as the protected session capability attestation' {
        $store = Add-GateSentinelObservation -Store (Get-GateStore -HostName 'codex') -HostName 'codex'
        $observation = Invoke-Probe -Store $store
        $path = "$(Get-DiscoverySessionDirectory -Location $script:GateLocation -SessionId 'session-alpha')/capability-attestation.json"
        @($store.Writes) | Should -Be @($path)
        (ConvertFrom-Json -InputObject $store.Files[$path] -Depth 16).attestation_ref | Should -Be $observation['attestation_ref']
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
