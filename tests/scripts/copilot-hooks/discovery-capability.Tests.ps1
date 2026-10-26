#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the GitHub Copilot discovery capability probe and the .github/hooks/discovery.json registration (issue #980).
.DESCRIPTION
    .github/hooks/discovery-capability-probe.ps1 is dot-sourced in-process; the registration and
    handler bytes are the repository's real files served under the fixture workspace root and the
    sentinel runs through the real Copilot PreToolUse adapter decision. No file is written and no
    process, network or clock is touched.
#>

Describe 'discovery-capability-probe.ps1 (GitHub Copilot)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.github/hooks/discovery-capability-probe.ps1'
        . $script:UnderTest
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')

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
            param([scriptblock]$Reader = (Get-RepoReader), [bool]$Trusted = $true, [hashtable]$Store = (Get-GateStore -HostName 'github-copilot'))
            return Invoke-DiscoveryCapabilityProbe -WorkspaceRoot $script:GateWorkspaceRoot -SessionId 'session-alpha' -Nonce $script:GateNonce -WorkspaceTrusted $Trusted -HostEnvironment $script:GateHostEnvironment -Store $Store -ReadBytes $Reader -Now $script:GateNow
        }
    }

    It 'persists the observation as the protected session capability attestation' {
        $store = Get-GateStore -HostName 'github-copilot'
        $observation = Invoke-Probe -Store $store
        $path = "$(Get-DiscoverySessionDirectory -Location $script:GateLocation -SessionId 'session-alpha')/capability-attestation.json"
        @($store.Writes) | Should -Be @($path)
        (ConvertFrom-Json -InputObject $store.Files[$path] -Depth 16).attestation_ref | Should -Be $observation['attestation_ref']
    }

    It 'observes the registered Copilot handlers from discovery.json and denies the sentinel through the real adapter' {
        $observation = Invoke-Probe
        $observation['status'] | Should -Be 'supported' -Because (($observation['findings'] | ForEach-Object { $_['message'] }) -join '; ')
        $observation['host'] | Should -Be 'github-copilot'
        @($observation['handlers'] | ForEach-Object { $_['path'] } | Sort-Object) | Should -Be @('.github/hooks/discovery-agent-start.ps1', '.github/hooks/discovery-agent-stop.ps1', '.github/hooks/discovery-pre-tool.ps1')
        $observation['probe']['evidence_ref'] | Should -Match '^probe-[0-9a-f]{64}$'
    }

    It 'reports unsupported when Workspace Trust is not granted or the registration file is absent' {
        (Invoke-Probe -Trusted $false)['controls']['workspace_trusted'] | Should -BeFalse
        $observation = Invoke-Probe -Reader (Get-RepoReader -Omit @('.github/hooks/discovery.json'))
        $observation['status'] | Should -Be 'unsupported'
        $observation['controls']['hooks_enabled'] | Should -BeFalse
    }

    It 'registers the four Copilot hooks with Windows command variants and no Claude matcher' {
        $registration = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot '.github/hooks/discovery.json') | ConvertFrom-Json
        @($registration.hooks.PSObject.Properties.Name | Sort-Object) | Should -Be @('PreToolUse', 'SubagentStart', 'SubagentStop')
        $hooks = @($registration.hooks.PSObject.Properties | ForEach-Object { $_.Value })
        $hooks.Count | Should -Be 4
        foreach ($hook in $hooks) {
            $hook.type | Should -Be 'command'
            $hook.command | Should -BeLike 'pwsh -NoProfile -File .github/hooks/*.ps1'
            $hook.windows | Should -Be $hook.command
            @($hook.PSObject.Properties.Name) | Should -Not -Contain 'matcher'
            Test-Path -LiteralPath (Join-Path $script:RepoRoot ($hook.command -replace '^pwsh -NoProfile -File ', '')) | Should -BeTrue
        }
    }
}
