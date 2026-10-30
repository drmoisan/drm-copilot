#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Root-grant record, precondition and exclusive-write tests for `DiscoveryRootGrant.psm1` (issue #980).
.DESCRIPTION
    Proves the record shape against the committed schema, the capability precondition
    over the in-memory start store (absent, expired, unsupported and current
    attestations) and the exclusive write through the store seam. No file is written,
    no process, network or clock is touched; the schema is read as a committed fixture.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $lib = Join-Path $script:RepoRoot '.claude/lib/discovery-validation'
    # Leaf modules are imported last so no nested import replaces a visible one.
    Import-Module (Join-Path $lib 'DiscoveryRootGrant.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryStartRecord.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryAuthority.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryEncoding.psm1') -Force
    . (Join-Path $PSScriptRoot 'DiscoveryGate.TestSupport.ps1')
    . (Join-Path $PSScriptRoot 'DiscoveryStart.TestSupport.ps1')

    $script:RootPrincipal = [pscustomobject]@{ HostName = 'claude-code'; SessionId = 'session-alpha'; ParentAgentId = 'root'; AgentId = $null; Role = $null; IsRoot = $true; Attributed = $true; Reason = $null }

    function Get-RootGrantRecord {
        [CmdletBinding()]
        [OutputType([System.Collections.Specialized.OrderedDictionary])]
        param([Parameter(Mandatory = $false)][AllowNull()][string]$ToolUseId = 'tool-use-alpha')
        return ConvertTo-DiscoveryRootGrantRecord -Principal $script:RootPrincipal -Tool 'prepare_discovery_agent' -Operation 'prepare-agent' `
            -InputSha256 ('a' * 64) -ToolUseId $ToolUseId -HandlerSha256 ('ab' * 32) -Now $script:GateNow -Nonce $script:GateNonce
    }
}

Describe 'ConvertTo-DiscoveryRootGrantRecord' {
    It 'carries exactly the keys the root-grant schema requires' {
        $schema = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot 'schemas/discovery/v2/root-grant.schema.json') | ConvertFrom-Json
        $record = Get-RootGrantRecord
        @($record.Keys | Sort-Object) | Should -Be @($schema.required | Sort-Object)
        $record['$schema'] | Should -Be 'urn:drm-copilot:discovery:2.0.0:root-grant'
        $record['artifact_kind'] | Should -Be 'root-grant'
        $record['grant_ref'] | Should -Be "grant-$($script:GateNonce)"
        $record['host'] | Should -Be 'claude-code'
        $record['parent_agent_id'] | Should -Be 'root'
        $record['tool_use_id'] | Should -Be 'tool-use-alpha'
        $record['issued_at'] | Should -Be '2026-10-22T12:00:00Z'
        $record['expires_at'] | Should -Be '2026-10-22T12:05:00Z'
        $record['state'] | Should -Be 'issued'
    }

    It 'records a null tool-call identifier when the host supplies none' {
        (Get-RootGrantRecord -ToolUseId $null)['tool_use_id'] | Should -BeNullOrEmpty
        (Get-RootGrantRecord -ToolUseId '')['tool_use_id'] | Should -BeNullOrEmpty
    }
}

Describe 'Write-DiscoveryRootGrant' {
    It 'writes the record exclusively under root-grants and refuses a second write to the same path' {
        $store = Get-GateStore
        $path = Write-DiscoveryRootGrant -Location $script:GateLocation -Record (Get-RootGrantRecord) -Store $store
        $path | Should -Be "$(Get-DiscoveryRootGrantDirectory -Location $script:GateLocation)/grant-$($script:GateNonce).json"
        $path | Should -BeLike "$($script:GateLocation.Directory)/root-grants/*"
        $store.Writes | Should -Be @($path)
        $store.Directories | Should -Contain (Get-DiscoveryRootGrantDirectory -Location $script:GateLocation)
        ($store.Files[$path] | ConvertFrom-Json).tool | Should -Be 'prepare_discovery_agent'
        { Write-DiscoveryRootGrant -Location $script:GateLocation -Record (Get-RootGrantRecord) -Store $store } | Should -Throw
        $store.Writes.Count | Should -Be 1
    }
}

Describe 'Test-DiscoveryRootGrantPrecondition' {
    It 'reports a deficiency when <Name>' -ForEach @(
        @{ Name = 'no capability attestation exists'; Store = { Get-StartStore -NoCapability }; Now = $null; Reason = 'no readable' }
        @{ Name = 'the attestation is expired'; Store = { Get-StartStore }; Now = [datetime]::new(2026, 10, 22, 14, 0, 0, [System.DateTimeKind]::Utc); Reason = 'not a current supported' }
        @{ Name = 'the attestation is unsupported'; Store = { Get-StartStore -CapabilityOverrides @{ status = 'unsupported' } }; Now = $null; Reason = 'not a current supported' }
        @{ Name = 'the attestation names another session'; Store = { Get-StartStore -CapabilityOverrides @{ session_id = 'session-beta' } }; Now = $null; Reason = 'another host, session or workspace' }
        @{ Name = 'the attestation lacks a status'; Store = { Get-StartStore -CapabilityOverrides @{ status = $null } }; Now = $null; Reason = 'not a current supported' }
    ) {
        $now = $(if ($null -ne $Now) { $Now } else { $script:GateNow })
        $deficiency = Test-DiscoveryRootGrantPrecondition -Location $script:GateLocation -Principal $script:RootPrincipal -Store (& $Store) -Now $now
        $deficiency | Should -BeLike "*$Reason*"
    }

    It 'returns nothing for a current supported attestation bound to this session and workspace' {
        Test-DiscoveryRootGrantPrecondition -Location $script:GateLocation -Principal $script:RootPrincipal -Store (Get-StartStore) -Now $script:GateNow | Should -BeNullOrEmpty
    }

    It 'reports an unreadable attestation as a deficiency' {
        $store = Get-StartStore
        $store.Files["$($script:StartSessionDirectory)/capability-attestation.json"] = '{'
        Test-DiscoveryRootGrantPrecondition -Location $script:GateLocation -Principal $script:RootPrincipal -Store $store -Now $script:GateNow | Should -BeLike '*not readable JSON*'
    }
}
